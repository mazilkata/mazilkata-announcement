(() => {
  const notice = document.getElementById('notice');
  const titleEl = document.getElementById('title');
  const textEl = document.getElementById('text');

  const queue = [];
  let current = null;
  let busy = false;
  let gen = 0;

  function rescale() {
    document.documentElement.style.setProperty('--s', (window.innerHeight / 1080).toFixed(4));
  }
  window.addEventListener('resize', rescale);
  rescale();

  const fill = (str, vars) => String(str).replace(/\{(\w+)\}/g, (_, k) => (vars[k] !== undefined ? vars[k] : ''));

  function formatTime(totalSeconds, lang) {
    if (totalSeconds >= 60) {
      const m = Math.ceil(totalSeconds / 60);
      return `${m} ${m === 1 ? lang.minute : lang.minutes}`;
    }
    return `${totalSeconds} ${totalSeconds === 1 ? lang.second : lang.seconds}`;
  }

  function restartTitle(payload, seconds) {
    const lang = payload.lang || {};
    return fill(lang.restartIn || 'SERVER RESTARTING IN {time}', { time: formatTime(seconds, lang) });
  }

  let audioCtx = null;
  function getAudioContext() {
    if (!audioCtx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) audioCtx = new AudioCtx();
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  function playTone(freq, type, startTime, duration, startVol, endVol) {
    const ctx = getAudioContext();
    if (!ctx) return;
    try {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = type || 'sine';
      osc.frequency.setValueAtTime(freq, startTime);
      gain.gain.setValueAtTime(startVol, startTime);
      gain.gain.exponentialRampToValueAtTime(Math.max(0.0001, endVol || 0.0001), startTime + duration);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(startTime);
      osc.stop(startTime + duration);
    } catch (_) { }
  }

  const SOUND_FILES = {
    announcement: 'sounds/announcement.mp3',
    restart: 'sounds/announcement.mp3',
    dm: 'sounds/message.mp3',
    warn: 'sounds/warning_open.mp3',
    countdown: 'sounds/warning_pulse.mp3'
  };

  const audioCache = {};

  function playSynthesizedSound(kind, vol) {
    const ctx = getAudioContext();
    if (!ctx) return;
    const now = ctx.currentTime;

    if (kind === 'announcement') {
      playTone(784.00, 'sine', now, 0.35, vol * 0.40, 0.001);
      playTone(1568.0, 'triangle', now, 0.25, vol * 0.12, 0.001);
      playTone(1046.5, 'sine', now + 0.10, 0.65, vol * 0.45, 0.001);
      playTone(2093.0, 'triangle', now + 0.10, 0.45, vol * 0.15, 0.001);
    } else if (kind === 'restart') {
      playTone(523.25, 'sine', now, 0.40, vol * 0.35, 0.001);
      playTone(659.25, 'sine', now + 0.08, 0.45, vol * 0.35, 0.001);
      playTone(783.99, 'sine', now + 0.16, 0.50, vol * 0.40, 0.001);
      playTone(1046.5, 'sine', now + 0.24, 0.80, vol * 0.45, 0.001);
    } else if (kind === 'countdown') {
      playTone(1000.0, 'sine', now, 0.05, vol * 0.30, 0.001);
    } else if (kind === 'dm') {
      playTone(880.00, 'sine', now, 0.22, vol * 0.35, 0.001);
      playTone(1318.5, 'sine', now + 0.09, 0.45, vol * 0.40, 0.001);
    } else if (kind === 'warn') {
      playTone(660.00, 'sawtooth', now, 0.16, vol * 0.25, 0.01);
      playTone(660.00, 'sine', now, 0.16, vol * 0.35, 0.01);
      playTone(880.00, 'sawtooth', now + 0.18, 0.30, vol * 0.25, 0.001);
      playTone(880.00, 'sine', now + 0.18, 0.30, vol * 0.35, 0.001);
    } else {
      playTone(880.00, 'sine', now, 0.40, vol * 0.40, 0.001);
    }
  }

  function playNotificationSound(kind, volume = 0.5) {
    const vol = Math.max(0.05, Math.min(1.0, Number(volume) || 0.5));
    const soundPath = SOUND_FILES[kind] || 'sounds/announcement.mp3';

    try {
      let audio = audioCache[soundPath];
      if (!audio) {
        audio = new Audio(soundPath);
        audioCache[soundPath] = audio;
      }
      audio.volume = vol;
      audio.currentTime = 0;
      const playPromise = audio.play();
      if (playPromise !== undefined) {
        playPromise.catch(() => {
          playSynthesizedSound(kind, vol);
        });
      }
    } catch (_) {
      playSynthesizedSound(kind, vol);
    }
  }

  function clearCurrent() {
    if (!current) return;
    clearTimeout(current.hideTimer);
    clearInterval(current.tickTimer);
    current = null;
  }

  function display(payload) {
    busy = true;
    gen++;
    clearCurrent();

    const state = { payload, hideTimer: null, tickTimer: null };
    current = state;

    const sConf = payload.soundConfig || {};
    if (sConf.enabled !== false) {
      playNotificationSound(payload.kind || 'announcement', sConf.volume);
    }

    if (payload.kind === 'restart') {
      let secs = Math.max(0, Number(payload.seconds) || 0);
      titleEl.textContent = restartTitle(payload, secs);

      if (payload.countdown && secs > 0) {
        const endsAt = Date.now() + secs * 1000;
        state.tickTimer = setInterval(() => {
          const left = Math.max(0, Math.ceil((endsAt - Date.now()) / 1000));
          if (left !== secs) {
            secs = left;
            titleEl.textContent = restartTitle(payload, secs);
            if (sConf.enabled !== false && sConf.countdownTicks !== false && secs > 0) {
              playNotificationSound('countdown', sConf.volume);
            }
          }
          if (left <= 0) clearInterval(state.tickTimer);
        }, 200);
      }
    } else {
      titleEl.textContent = payload.title || '';
    }

    textEl.textContent = payload.body || '';

    void notice.offsetWidth;
    notice.classList.add('show');

    const duration = Math.max(1500, Number(payload.duration) || 8000);
    state.hideTimer = setTimeout(() => hide(), duration);
  }

  function hide() {
    clearCurrent();
    notice.classList.remove('show');
    const g = gen;
    setTimeout(() => {
      if (g !== gen) return;
      busy = false;
      next();
    }, 320);
  }

  function next() {
    if (busy || queue.length === 0) return;
    display(queue.shift());
  }

  function push(payload) {
    if (!payload) return;
    if (payload.kind === 'restart') {
      queue.length = 0;
      display(payload);
      return;
    }
    if (payload.kind === 'dm' || payload.kind === 'warn') {
      if (current && current.payload && current.payload.kind === 'announcement') {
        display(payload);
        return;
      }
      queue.unshift(payload);
      if (!busy) {
        next();
      }
      return;
    }
    queue.push(payload);
    next();
  }

  window.addEventListener('message', (e) => {
    const msg = e.data;
    if (!msg || msg.action !== 'show') return;
    push(msg.data);
  });
})();

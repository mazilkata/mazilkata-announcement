Config = {}

-- Language: 'en' or 'bg' (add your own in Config.Locales below)
Config.Locale = 'en'

-- Hide txAdmin's own default announcement / restart-warning / DM / warning display so players only see ours.
-- IMPORTANT: txAdmin reads its suppression convars when FXServer starts up.
-- To ensure the default yellow txAdmin popups are 100% blocked, make sure to add these to the TOP of server.cfg:
--   set txAdmin-hideDefaultAnnouncement true
--   set txAdmin-hideDefaultScheduledRestartWarning true
--   set txAdmin-hideDefaultDirectMessage true
--   set txAdmin-hideDefaultWarning true
-- (Or check them in txAdmin Web Dashboard -> Settings -> Game -> Notifications, then RESTART the server.)
Config.HideTxAdminDefaults = true

-- How long (ms) a normal announcement stays on screen = Duration + (message length * PerCharMs)
Config.Duration = 8000
Config.PerCharMs = 45

-- How long (ms) a scheduled-restart warning (30, 15, 10, 5, 4, 3, 2, 1 min) stays on screen
Config.RestartWarningDuration = 10000

-- Show the admin's name in announcements, DMs, and warnings ("ANNOUNCEMENT BY <name>")
-- Set to true to always show who announced it (e.g. "ANNOUNCEMENT BY Void4o")
Config.ShowAuthor = true

-- Also show "txAdmin" if the announcement was sent by the system rather than an admin
Config.ShowAuthorForSystem = false

-- Show txAdmin's own text (e.g. the restart reason) in the white box instead of the fixed warning text
Config.ShowShutdownReason = false

-- Sound configuration (txAdmin chimes for announcements, restarts, countdown ticks, DMs, warnings)
Config.Sound = {
    enabled = true,        -- Play sound effects when notices appear
    volume = 0.5,          -- Sound volume (0.0 to 1.0)
    countdownTicks = true, -- Play tick sound on every second of live restart countdown (5, 4, 3, 2, 1)
    -- Also play GTA native frontend sound (optional)
    gtaSound = false,
    gtaSoundName = 'TIMER_STOP',
    gtaSoundSet = 'HUD_MINI_GAME_SOUNDSET'
}

-- Local preview command for testing the design without txAdmin (client side, /mazilkata_announce_preview)
Config.PreviewCommand = true

-- Texts. {time} {author} are replaced automatically.
Config.Locales = {
    en = {
        restartIn = 'SERVER RESTARTING IN {time}',
        second = 'SECOND', seconds = 'SECONDS',
        minute = 'MINUTE', minutes = 'MINUTES',
        restartBody = 'Please find a safe place to log out or you may lose progress.',
        announcementTitle = 'ANNOUNCEMENT',
        announcementBy = 'ANNOUNCEMENT BY {author}',
        dmTitle = 'DIRECT MESSAGE',
        dmBy = 'DIRECT MESSAGE FROM {author}',
        warnTitle = 'ADMIN WARNING',
        warnBy = 'WARNING FROM {author}',
    },
    bg = {
        restartIn = 'СЪРВЪРЪТ СЕ РЕСТАРТИРА СЛЕД {time}',
        second = 'СЕКУНДА', seconds = 'СЕКУНДИ',
        minute = 'МИНУТА', minutes = 'МИНУТИ',
        restartBody = 'Моля, намерете безопасно място и излезте, иначе може да изгубите прогрес.',
        announcementTitle = 'ОБЯВА',
        announcementBy = 'ОБЯВА ОТ {author}',
        dmTitle = 'ЛИЧНО СЪОБЩЕНИЕ',
        dmBy = 'ЛИЧНО СЪОБЩЕНИЕ ОТ {author}',
        warnTitle = 'ПРЕДУПРЕЖДЕНИЕ',
        warnBy = 'ПРЕДУПРЕЖДЕНИЕ ОТ {author}',
    },
}

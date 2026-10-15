![Uploading banner.png…]()
<img width="1240" height="244" alt="announcement" src="https://github.com/user-attachments/assets/b3d66fdb-cb5e-44a0-a99d-27f73e68ff6a" />
<img width="1240" height="244" alt="restart" src="https://github.com/user-attachments/assets/3c26d6a1-097f-40d6-b053-48bb2326c47b" />
<img width="1600" height="900" alt="banner" src="https://github.com/user-attachments/assets/eae52050-c675-4e50-8f6b-e7e3247ef27d" />
<p align="center">
  <img src="previews/banner.png" alt="mazilkata-announcement - NPV Inspired Announcement System" width="100%">
</p>

# mazilkata-announcement

**NPV Inspired Announcement System** for FiveM by **Mazilkata Development**.
Replaces the default txAdmin **restart warnings** and **announcements** with a clean black-and-white notice at the top of the screen. Standalone: no framework, no ox_lib, no build step.

<p align="center">
  <img src="previews/restart.png" alt="Restart notice" width="640"><br>
  <img src="previews/announcement.png" alt="Announcement" width="640"><br>
  <img src="previews/announcement-long.png" alt="Long announcement" width="640">
</p>

---

## Features

- **Restart notices** with a **live countdown** (`SERVER RESTARTING IN 5 SECONDS`, 4, 3, 2, 1...)
- **Scheduled restart warnings** (30, 15, 10, 5, 4, 3, 2, 1 minutes) and **normal txAdmin announcements**
- Long messages wrap onto more lines and stay on screen longer
- Notices are **queued**; restart warnings always jump the queue
- **English and Bulgarian** (Cyrillic works) built in, easy to add more
- Scales to any resolution (designed at 1920x1080)
- Safe: messages are shown as plain text (no HTML injection)
- Exports to send your own notices from other resources
- Direct Message (DM) & Admin Warning support

## Installation

1. Put the `mazilkata-announcement` folder in your `resources` folder.
2. Add this to your `server.cfg`:
   ```cfg
   ensure mazilkata-announcement
   ```
3. **Hide the default txAdmin yellow messages** so players only see this custom white-and-black UI.
   Because txAdmin reads its suppression convars when FXServer initially boots up, add these lines to the **very top of your `server.cfg`** (before `ensure` commands):
   ```cfg
   set txAdmin-hideDefaultAnnouncement true
   set txAdmin-hideDefaultScheduledRestartWarning true
   set txAdmin-hideDefaultDirectMessage true
   set txAdmin-hideDefaultWarning true
   ```
   **OR** in your **txAdmin Web Dashboard -> Settings -> Game -> Notifications**:
   - Check *Hide Announcement notification*
   - Check *Hide Scheduled Restart warning*
   - Check *Hide Direct Message notification*
   - Check *Hide Warning notification*
   - Click **Save** and **Restart Server**.

4. Restart your FXServer.

## How it works

The script listens to txAdmin's server events:

| txAdmin event | What players see |
|---|---|
| `txAdmin:events:scheduledRestart` | `SERVER RESTARTING IN X MINUTES` + warning text |
| `txAdmin:events:serverShuttingDown` | `SERVER RESTARTING IN X SECONDS` with a live countdown |
| `txAdmin:events:announcement` | `ANNOUNCEMENT` + the admin's message |
| `txAdmin:events:playerDirectMessage` | `DIRECT MESSAGE FROM <Admin>` + the private message (only target player) |
| `txAdmin:events:playerWarned` | `ADMIN WARNING` + the reason (only warned player) |

## Configuration (`config.lua`)

| Option | Default | Description |
|---|---|---|
| `Config.Locale` | `'en'` | `'en'` or `'bg'` (add more in `Config.Locales`) |
| `Config.HideTxAdminDefaults` | `true` | Suppresses txAdmin's default displays |
| `Config.Duration` / `Config.PerCharMs` | `8000` / `45` | Announcement time = Duration + characters x PerCharMs (ms) |
| `Config.RestartWarningDuration` | `10000` | How long scheduled restart warnings stay (ms) |
| `Config.ShowAuthor` | `true` | Show `ANNOUNCEMENT BY <admin>`, `DIRECT MESSAGE FROM <admin>` |
| `Config.ShowShutdownReason` | `false` | Show txAdmin's restart reason instead of the fixed warning text |
| `Config.Sound` | enabled | txAdmin notification chimes & live countdown ticks (volume configurable) |
| `Config.PreviewCommand` | `true` | Enables `/mazilkata_announce_preview` |

All texts (announcements, restarts, DMs, warnings) can be customized in `Config.Locales`.

## Testing

Server console (or give yourself the ACE permission `command.mazilkata_announce`):

```
mazilkata_announce restart 300          # scheduled-style warning, "5 MINUTES"
mazilkata_announce shutdown 5           # live 5 second countdown
mazilkata_announce msg Hello everyone   # normal announcement
mazilkata_announce dm 1 Hello there     # direct message to player ID 1
mazilkata_announce warn 1 RDM Warning   # warning to player ID 1
```

In game, to preview only for yourself:
- `/mazilkata_announce_preview announcement`
- `/mazilkata_announce_preview restart`
- `/mazilkata_announce_preview dm`
- `/mazilkata_announce_preview warn`

## Exports

```lua
-- server
exports['mazilkata-announcement']:Announce('TITLE', 'Message text', 8000)
exports['mazilkata-announcement']:Restart(60, true)  -- seconds, live countdown
exports['mazilkata-announcement']:DirectMessage(targetId, 'Admin', 'Your message', 8000)
exports['mazilkata-announcement']:Warn(targetId, 'Admin', 'Reason', 8000)

-- client (only for local player)
exports['mazilkata-announcement']:Show('TITLE', 'Message text', 8000)
exports['mazilkata-announcement']:DirectMessage('Admin', 'Your message', 8000)
exports['mazilkata-announcement']:Warn('Admin', 'Reason', 8000)
```

## Credits

- Developed by **Mazilkata Development** for the FiveM Community.
- Fonts: **Barlow Condensed** and **Roboto Condensed** (SIL Open Font License, see `html/fonts/`).
- Licensed under the **Void Development License** (see `LICENSE`).

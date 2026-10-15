local function lang()
    return Config.Locales[Config.Locale] or Config.Locales.en
end

local function clean(text, max)
    text = tostring(text or '')
    text = text:gsub('[%c]', function(c) return c == '\n' and '\n' or ' ' end)
    if #text > (max or 500) then text = text:sub(1, max or 500) .. '...' end
    return text
end

local function broadcast(payload, target)
    payload.lang = lang()
    payload.soundConfig = Config.Sound
    TriggerClientEvent('mazilkata-announcement:client:show', target or -1, payload)
end

local function authorHiddenInMessages()
    return GetConvar('txAdmin-hideAdminInMessages', 'false') == 'true'
end

local function authorHiddenInPunishments()
    return GetConvar('txAdmin-hideAdminInPunishments', 'false') == 'true'
end

---@param title string|nil
---@param body string
---@param duration number|nil ms
---@param target number|nil player source (default everyone)
local function announce(title, body, duration, target)
    body = clean(body)
    broadcast({
        kind = 'announcement',
        title = clean(title ~= nil and title ~= '' and title or lang().announcementTitle, 80),
        body = body,
        duration = duration or (Config.Duration + (#body * Config.PerCharMs))
    }, target)
end

---@param seconds number seconds until restart
---@param countdown boolean tick the number down live
---@param body string|nil custom body text
---@param target number|nil
local function restart(seconds, countdown, body, target)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    broadcast({
        kind = 'restart',
        seconds = seconds,
        countdown = countdown and true or false,
        body = clean(body or lang().restartBody),
        duration = countdown and ((seconds * 1000) + 1500) or Config.RestartWarningDuration
    }, target)
end

---@param target number player server id (source)
---@param author string|nil admin name
---@param message string
---@param duration number|nil ms
local function directMessage(target, author, message, duration)
    local src = tonumber(target)
    if not src then return end
    message = clean(message)
    local title = lang().dmTitle
    if Config.ShowAuthor and author and author ~= '' then
        local who = clean(author, 32)
        title = lang().dmBy:gsub('{author}', function() return who end)
    end
    broadcast({
        kind = 'dm',
        title = clean(title, 80),
        body = message,
        duration = duration or (Config.Duration + (#message * Config.PerCharMs))
    }, src)
end

---@param target number player server id (source)
---@param author string|nil admin name
---@param reason string
---@param duration number|nil ms
local function warn(target, author, reason, duration)
    local src = tonumber(target)
    if not src then return end
    reason = clean(reason)
    local title = lang().warnTitle
    if Config.ShowAuthor and author and author ~= '' then
        local who = clean(author, 32)
        title = lang().warnBy:gsub('{author}', function() return who end)
    end
    broadcast({
        kind = 'warn',
        title = clean(title, 80),
        body = reason,
        duration = duration or (Config.Duration + (#reason * Config.PerCharMs))
    }, src)
end

exports('Announce', announce)
exports('Restart', restart)
exports('DirectMessage', directMessage)
exports('Warn', warn)

AddEventHandler('txAdmin:events:announcement', function(data)
    if type(data) ~= 'table' or not data.message then return end

    local title = lang().announcementTitle
    if Config.ShowAuthor and data.author and data.author ~= '' then
        local who = clean(data.author, 32)
        if who:lower() ~= 'txadmin' or Config.ShowAuthorForSystem then
            title = lang().announcementBy:gsub('{author}', function() return who end)
        end
    end
    announce(title, data.message)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(data)
    if type(data) ~= 'table' or not data.secondsRemaining then return end
    restart(data.secondsRemaining, false)
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function(data)
    if type(data) ~= 'table' then return end
    local seconds = math.ceil((tonumber(data.delay) or 0) / 1000)
    local body = (Config.ShowShutdownReason and data.message and data.message ~= '') and data.message or nil
    restart(seconds, seconds > 0, body)
end)

AddEventHandler('txAdmin:events:playerDirectMessage', function(data)
    if type(data) ~= 'table' or not data.message or not data.target then return end
    directMessage(data.target, data.author, data.message)
end)

AddEventHandler('txAdmin:events:playerWarned', function(data)
    if type(data) ~= 'table' then return end
    local target = data.targetNetId or data.target
    if not target then return end
    warn(target, data.author, data.reason or 'Warning')
end)

local function applyTxAdminConvars()
    if not Config.HideTxAdminDefaults then return end

    local convars = {
        'txAdmin-hideDefaultAnnouncement',
        'txAdmin-hideDefaultScheduledRestartWarning',
        'txAdmin-hideDefaultDirectMessage',
        'txAdmin-hideDefaultWarning'
    }

    for _, c in ipairs(convars) do
        SetConvar(c, 'true')
        SetConvarReplicated(c, 'true')
        ExecuteCommand(('set %s true'):format(c))
        ExecuteCommand(('setr %s true'):format(c))
    end
end

applyTxAdminConvars()

CreateThread(function()
    Wait(2000)
    if not Config.HideTxAdminDefaults then return end
    local announcementHidden = GetConvar('txAdmin-hideDefaultAnnouncement', 'false') == 'true'
    local restartHidden = GetConvar('txAdmin-hideDefaultScheduledRestartWarning', 'false') == 'true'
    local dmHidden = GetConvar('txAdmin-hideDefaultDirectMessage', 'false') == 'true'
    local warnHidden = GetConvar('txAdmin-hideDefaultWarning', 'false') == 'true'

    if not (announcementHidden and restartHidden and dmHidden and warnHidden) then
        print('^3[mazilkata-announcement]^7 ^1NOTE:^7 To ensure default yellow txAdmin popups are fully blocked, make sure to add:')
        print('^3set txAdmin-hideDefaultAnnouncement true^7')
        print('^3set txAdmin-hideDefaultScheduledRestartWarning true^7')
        print('^3set txAdmin-hideDefaultDirectMessage true^7')
        print('^3set txAdmin-hideDefaultWarning true^7')
        print('^3at the TOP of your server.cfg, or tick them in txAdmin -> Settings -> Game -> Notifications, then RESTART the server!^7')
    end
end)

RegisterCommand('mazilkata_announce', function(source, args)
    local mode = (args[1] or ''):lower()
    if mode == 'restart' then
        restart(tonumber(args[2]) or 300, false)
    elseif mode == 'shutdown' then
        restart(tonumber(args[2]) or 5, true)
    elseif mode == 'msg' and args[2] then
        announce(nil, table.concat(args, ' ', 2))
    elseif mode == 'dm' and args[2] and args[3] then
        directMessage(args[2], 'Console', table.concat(args, ' ', 3))
    elseif mode == 'warn' and args[2] and args[3] then
        warn(args[2], 'Console', table.concat(args, ' ', 3))
    else
        print('Usage: mazilkata_announce restart [seconds] | shutdown [seconds] | msg <text> | dm <id> <text> | warn <id> <text>')
    end
end, true)


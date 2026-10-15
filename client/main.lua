local function playGtaSound()
    local s = Config.Sound
    if s and s.enabled and s.gtaSound then
        PlaySoundFrontend(-1, s.gtaSoundName or 'TIMER_STOP', s.gtaSoundSet or 'HUD_MINI_GAME_SOUNDSET', true)
    end
end

RegisterNetEvent('mazilkata-announcement:client:show', function(payload)
    if type(payload) ~= 'table' then return end
    payload.soundConfig = payload.soundConfig or Config.Sound
    SendNUIMessage({ action = 'show', data = payload })
    playGtaSound()
end)

exports('Show', function(title, body, duration)
    local lang = Config.Locales[Config.Locale] or Config.Locales.en
    SendNUIMessage({
        action = 'show',
        data = {
            kind = 'announcement',
            title = tostring(title or lang.announcementTitle),
            body = tostring(body or ''),
            duration = tonumber(duration) or Config.Duration,
            lang = lang,
            soundConfig = Config.Sound
        }
    })
    playGtaSound()
end)

exports('DirectMessage', function(author, message, duration)
    local lang = Config.Locales[Config.Locale] or Config.Locales.en
    local title = lang.dmTitle
    if Config.ShowAuthor and author and author ~= '' then
        title = lang.dmBy:gsub('{author}', function() return tostring(author) end)
    end
    SendNUIMessage({
        action = 'show',
        data = {
            kind = 'dm',
            title = title,
            body = tostring(message or ''),
            duration = tonumber(duration) or Config.Duration,
            lang = lang,
            soundConfig = Config.Sound
        }
    })
    playGtaSound()
end)

exports('Warn', function(author, reason, duration)
    local lang = Config.Locales[Config.Locale] or Config.Locales.en
    local title = lang.warnTitle
    if Config.ShowAuthor and author and author ~= '' then
        title = lang.warnBy:gsub('{author}', function() return tostring(author) end)
    end
    SendNUIMessage({
        action = 'show',
        data = {
            kind = 'warn',
            title = title,
            body = tostring(reason or ''),
            duration = tonumber(duration) or Config.Duration,
            lang = lang,
            soundConfig = Config.Sound
        }
    })
    playGtaSound()
end)

if Config.PreviewCommand then
    RegisterCommand('mazilkata_announce_preview', function(_, args)
        local lang = Config.Locales[Config.Locale] or Config.Locales.en
        local mode = (args[1] or 'restart'):lower()
        if mode == 'announcement' then
            local title = lang.announcementTitle
            if Config.ShowAuthor then
                title = lang.announcementBy:gsub('{author}', 'Admin')
            end
            SendNUIMessage({ action = 'show', data = {
                kind = 'announcement', title = title,
                body = 'This is a preview of a normal announcement.', duration = 6000, lang = lang,
                soundConfig = Config.Sound } })
        elseif mode == 'dm' then
            local title = lang.dmTitle
            if Config.ShowAuthor then
                title = lang.dmBy:gsub('{author}', 'Admin')
            end
            SendNUIMessage({ action = 'show', data = {
                kind = 'dm', title = title,
                body = 'Please come to the admin office or Discord support channel.', duration = 7000, lang = lang,
                soundConfig = Config.Sound } })
        elseif mode == 'warn' then
            local title = lang.warnTitle
            if Config.ShowAuthor then
                title = lang.warnBy:gsub('{author}', 'Admin')
            end
            SendNUIMessage({ action = 'show', data = {
                kind = 'warn', title = title,
                body = 'Rule violation: FailRP is not tolerated. Final warning.', duration = 8000, lang = lang,
                soundConfig = Config.Sound } })
        else
            SendNUIMessage({ action = 'show', data = {
                kind = 'restart', seconds = 5, countdown = true,
                body = lang.restartBody, duration = 6500, lang = lang,
                soundConfig = Config.Sound } })
        end
        playGtaSound()
    end, false)
end

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'mazilkata-announcement'
author 'Mazilkata Development'
description 'NPV Inspired Announcement System for txAdmin restart warnings and announcements'
version '1.0.0'

shared_script 'config.lua'

server_script 'server/main.lua'
client_script 'client/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/*.woff2',
    'html/sounds/*.mp3'
}

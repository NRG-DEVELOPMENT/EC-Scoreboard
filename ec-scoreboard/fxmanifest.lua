fx_version 'cerulean'
game 'gta5'

author 'NRG Development'
description 'EC-Scoreboard'
version '1.0.0'

ui_page 'html/index.html'

shared_script 'config.lua'
client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Only needed for ESX identity
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    '/onesync'
}

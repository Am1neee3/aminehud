fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Amine'
description 'AmineHud - Premium Movable ESX HUD'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png' -- Just in case we add images later, though we might use CSS shapes/SVGs
}

dependencies {
    'es_extended'
}

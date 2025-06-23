fx_version 'cerulean'
game 'gta5'
author 'AProject'
description 'Starter pack script for QBCore'
version '1.2.0'

dependencies {
    'qb-core',
    'qb-target',
    'ox_lib',
    'oxmysql'
}


shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/sv_discord.lua'
}
fx_version 'cerulean'
game 'gta5'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'geneva#3054, Andyyy#7666'
description 'A dealership for ND-Framework.'

client_scripts {
    '@ox_lib/init.lua',
    'client/*.lua',
}

shared_script 'shared/shared_config.lua'

server_script 'server/server.lua'

dependencies {
    'ND_Core',
    '/server:2372',
    'ND_VehicleSystem',
    'ox_lib'
}
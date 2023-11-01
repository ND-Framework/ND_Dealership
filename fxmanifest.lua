-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy"
description "Basic dealership for ND-Framework"
version "2.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "data/dealerships.lua",
    "data/vehicles.lua",
    "client/showroom.lua",
    "client/testdrive.lua",
    "client/menu.lua",
    "client/ped.lua"
}
shared_script {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua"
}
server_script "server/main.lua"
client_script "client/main.lua"

dependency "ND_Core"

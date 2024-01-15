Data = {
    dealerships = require "data.dealerships",
    vehicles = require "data.vehicles"
}
Showroom = require "client.showroom"
Menu = require "client.menu"
Testdrive = require "client.testdrive"
Target = exports.ox_target
local pedInteract = require "client.ped"
local selectedVehicle = nil
local createdBlips = {}

function PurchaseVehicle(dealer, info)
    local input = lib.inputDialog(("Purchase vehicle for $%s"):format(info.price), {
        {type = "checkbox", label = "Send to garage"}
    })
    if not input or not info then return end
    TriggerServerEvent("ND_Dealership:purchaseVehicle", input[1], dealer, info)
end

function HasPermissionGroup(permission, groups)
    local player = NDCore.getPlayer()
    if not player then return end
    if not groups then return true end
    
    local hasPerms = false
    for group, info in pairs(groups) do
        if info[permission] and player.groups[group] then
            hasPerms = true
        end
    end
    return hasPerms or groups["default"] and groups["default"][permission]
end

local function clearBlips()
    for i=1, #createdBlips do
        local blip = createdBlips[i]
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    createdBlips = {}
end

local function createBlip(info)
    local blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
    SetBlipSprite(blip, info.sprite)
    SetBlipColour(blip, info.color or 0)
    SetBlipScale(blip, info.scale or 1.0)
    SetBlipAsShortRange(blip, true)
    if info.label then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.label)
        EndTextCommandSetBlipName(blip)
    end
    createdBlips[#createdBlips+1] = blip
end

local function updateBlips()
    clearBlips()
    Wait(100)
    for dealer, info in pairs(Data.dealerships) do
        if info.blip and HasPermissionGroup("blip", info.groups) then
            createBlip(info.blip)
        end
    end
end

lib.zones.box({
    name = "testdrivezone",
    coords = vec3(-1984.0, 1111.0, -23.0),
    size = vec3(302.0, 252.5, 11.0),
    rotation = 0.0,
    onEnter = Testdrive.enterZone,
    onExit = Testdrive.exitZone,
    inside = Testdrive.insideZone
})

RegisterNetEvent("ND_Dealership:updateShowroomVehicle", function(selected, dealer, index, vehicleInfo)
    Showroom.createVehicle(selected, dealer, index, vehicleInfo)
end)

AddEventHandler("ND_Dealership:menuItemSelected", function(selected)
    if selected.menuType == "switch" then
        local properties = nil
        if not selected.info.properties then            
            local pedCoords = GetEntityCoords(cache.ped)
            lib.requestModel(selected.model)
            local vehicle = CreateVehicle(selected.model, pedCoords.x, pedCoords.y, pedCoords.z-50.0, 0.0, false, false)
            while not DoesEntityExist(vehicle) do Wait(100) end
            properties = json.encode(lib.getVehicleProperties(vehicle))
            DeleteEntity(vehicle)
        end
        TriggerServerEvent("ND_Dealership:switchShowroomVehicle", selectedVehicle, selected.dealership, selected.category, selected.index, properties)
    elseif selected.menuType == "interact" then
        pedInteract.viewVehicle(selected)
    end
end)

AddEventHandler("ND_Dealership:createVehicleTargets", function(vehicles, dealer)
    Target:addLocalEntity(vehicles.testdrive, {
        {
            name = "nd_dealership:showroomTestDrive",
            icon = "fa-solid fa-key",
            label = "Test drive",
            distance = 1.5,
            onSelect = Testdrive.start
        }
    })
    Target:addLocalEntity(vehicles.switch, {
        {
            name = "nd_dealership:showroomSwitchVeh",
            icon = "fa-solid fa-warehouse",
            label = "Switch vehicle",
            distance = 1.5,
            onSelect = function(data)
                selectedVehicle = Showroom.getSlotFromEntity(data.entity)
                Menu.show(dealer, "switch")
            end
        }
    })
    Target:addLocalEntity(vehicles.purchase, {
        {
            name = "nd_dealership:showroomPurchase",
            icon = "fa-solid fa-money-check-dollar",
            label = "Purchase",
            distance = 1.5,
            onSelect = function(data)
                local veh = data.entity
                local info, dealer = Showroom.getVehicleData(veh)
                PurchaseVehicle(dealer, info)
            end
        }
    })
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    for _, vehicles in pairs(Showroom.vehicles) do
        Showroom.deleteVehicles(vehicles)
    end
end)

RegisterNetEvent("ND_Dealership:updateShowroomData", function(showrooms)
    Showroom.createShowrooms(showrooms)
    pedInteract.create()
    updateBlips()
end)

RegisterNetEvent("ND:updateCharacter", function(character)
    updateBlips()
end)

RegisterCommand("vehprops", function(source, args, rawCommand)
    local veh = cache.vehicle
    if not DoesEntityExist(veh) then return end
    lib.setClipboard(("[[%s]]"):format(json.encode(lib.getVehicleProperties(veh))))
end, false)

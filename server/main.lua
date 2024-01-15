local showrooms = nil
local testDriveLocation = vec4(-2086.23, 1144.44, -27.99, 179.39)
local testDrivesStarted = {}
local data = {
    dealerships = require("data.dealerships"),
    vehicles = require("data.vehicles")
}

local function getRandomShowroomVehicle(categories)
    local category = categories[math.random(1, #categories)]
    local categoryVehicles = data.vehicles[category]
    if #categoryVehicles == 0 then
        return
    end
    return categoryVehicles[math.random(1, #categoryVehicles)]
end

local function getShowrooms()
    local updatedShowrooms = {}
    for dealer, info in pairs(data.dealerships) do
        local showroomLocations = info.showroomLocations
        if not showroomLocations then goto next end

        local sr = {}
        for i=1, #showroomLocations do
            local vehicle = getRandomShowroomVehicle(info.showroomCategories or info.categories)
            if vehicle then
                sr[#sr+1] = {
                    model = vehicle.model,
                    price = vehicle.price,
                    label = vehicle.label,
                    properties = vehicle.properties,
                    groups = info.groups,
                    location = showroomLocations[i]
                }
            end
        end
        updatedShowrooms[dealer] = sr

        ::next::
    end
    return updatedShowrooms
end

local function getNetworkId(entity)
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do
        Wait(10)
    end
    return NetworkGetNetworkIdFromEntity(entity)
end

local function stopTestDrive(src, testDrive)
    if not testDrive then return end
    if DoesEntityExist(testDrive.vehicle) then
        DeleteEntity(testDrive.vehicle)
    end
    if DoesEntityExist(testDrive.fakePed) then
        DeleteEntity(testDrive.fakePed)
    end
    if DoesEntityExist(testDrive.tablet) then
        DeleteEntity(testDrive.tablet)
    end

    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return end
    SetEntityCoords(ped, testDrive.lastCoords)
end

CreateThread(function()
    Wait(1000)
    showrooms = getShowrooms()
    TriggerClientEvent("ND_Dealership:updateShowroomData", -1, showrooms)
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    for src, info in pairs(testDrivesStarted) do
        stopTestDrive(src, info)
    end
end)

AddEventHandler("ND:characterLoaded", function(character)
    TriggerClientEvent("ND_Dealership:updateShowroomData", character.source, showrooms)
end)

RegisterNetEvent("ND_Dealership:updateDealerProperties", function(dealer, properties)
    local sr = showrooms[dealer]
    for i=1, #sr do
        local info = sr[i]
        local props = properties[i]
        if not info.properties and props then
            info.properties = props
        end
    end
end)

local function hasPermissionGroup(src, permission, dealership)
    local dealer = data.dealerships[dealership]
    local groups = dealer.groups
    if not groups then return true end

    local player = NDCore.getPlayer(src)
    if not player then return end
    
    local hasPerms = false
    for group, info in pairs(groups) do
        if info[permission] and player.getGroup(group) then
            hasPerms = true
        end
    end
    return hasPerms or groups["default"] and groups["default"][permission]
end

lib.callback.register("ND_Dealership:setupTestDrive", function(src, pedModel, dealership, lastCoords)
    if not hasPermissionGroup(src, "testdrive", dealership) then return end

    if not lastCoords then        
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        lastCoords = vec4(coords.x, coords.y, coords.z, GetEntityHeading(ped))
    end

    if not pedModel then
        testDrivesStarted[src] = {
            lastCoords = lastCoords
        }
        return true
    end

    local fakePed = CreatePed(0, pedModel, lastCoords.x, lastCoords.y, lastCoords.z, lastCoords.w, true, true)
    local tablet = CreateObject(`prop_cs_tablet`, lastCoords.x, lastCoords.y, lastCoords.z, true, true, false)
    local pedNetId = getNetworkId(fakePed)
    local tabletNetId = getNetworkId(tablet)
    testDrivesStarted[src] = {
        lastCoords = lastCoords,
        fakePed = fakePed,
        tablet = tablet
    }

    return pedNetId, tabletNetId
end)

RegisterNetEvent("ND_Dealership:startTestDrive", function(properties, dealership)
    local src = source
    if not hasPermissionGroup(src, "testdrive", dealership) then return end

    local ped = GetPlayerPed(src)
    SetEntityCoords(ped, testDriveLocation.x, testDriveLocation.y, testDriveLocation.z)
    Wait(100)

    local vehicle = NDCore.createVehicle({
        model = properties.model,
        coords = testDriveLocation
    })
    
    local state = Entity(vehicle.entity).state
    state.hotwired = true
    state.locked = false

    while GetPedInVehicleSeat(vehicle.entity, -1) ~= ped do
        SetPedIntoVehicle(ped, vehicle.entity, -1)
        Wait(10)
    end
    TriggerClientEvent("ox_lib:setVehicleProperties", NetworkGetEntityOwner(vehicle.entity), vehicle.netId, properties)
    if not testDrivesStarted[src] then
        testDrivesStarted[src] = {}
    end
    testDrivesStarted[src].vehicle = vehicle.entity
end)

RegisterNetEvent("ND_Dealership:exitTestDrive", function()
    local src = source
    stopTestDrive(src, testDrivesStarted[src])
end)

RegisterNetEvent("ND_Dealership:switchShowroomVehicle", function(selectedVehicle, dealership, category, index, properties)
    local src = source
    if not hasPermissionGroup(src, "switch", dealership) then return end

    local showRoom = showrooms[dealership]
    local dealer = data.dealerships[dealership]
    local categoryVehicles = data.vehicles[category]
    if not dealer or not lib.table.contains(dealer.categories, category) or not showRoom or not categoryVehicles then return end

    local locations = dealer.showroomLocations
    if not locations then return end

    local location = locations[selectedVehicle]
    if not location then return end

    local vehicleInfo = categoryVehicles[index]
    if not vehicleInfo then return end

    local info = {
        model = vehicleInfo.model,
        price = vehicleInfo.price,
        label = vehicleInfo.label,
        properties = vehicleInfo.properties or properties,
        location = location
    }

    showRoom[selectedVehicle] = info
    TriggerClientEvent("ND_Dealership:updateShowroomVehicle", -1, selectedVehicle, dealership, index, info)
end)

local function getVehicleCategory(dealership, model, price)
    for category, vehicles in pairs(data.vehicles) do
        for i=1, #vehicles do
            local info = vehicles[i]
            if info.model == model and info.price == price then
                return category, info
            end
        end
    end
end

local function getAvailableParking(spawns)
    local vehicles = GetAllVehicles()
    for _, vehicle in ipairs(vehicles) do
        local coords = GetEntityCoords(vehicle)
        for i=1, #spawns do
            local spawn = spawns[i]
            if #(coords-spawn.xyz) > 2 then
                return spawn
            end
        end
    end
end

RegisterNetEvent("ND_Dealership:purchaseVehicle", function(stored, dealer, info)
    local src = source
    if not hasPermissionGroup(src, "purchase", dealer) then return end

    local model = info?.model
    local properties = info?.properties
    local dealership = data.dealerships?[dealer]
    if not info or not model or not properties or not dealership then return end

    local category, categoryInfo = getVehicleCategory(dealership, model, info.price)
    if not category or not lib.table.contains(dealership.categories, category) then return end

    local price = categoryInfo.price
    local player = NDCore.getPlayer(src)
    
    if price > 0 then
        if not player or player.bank < price then
            return player.notify({
                title = "insufficient funds",
                description = "You can't affoard this vehicle!",
                type = "error",
                duration = 8000,
                position = "bottom"
            })
        end
        player.deductMoney("bank", price, "Vehicle purchase")
    end

    local vehicleProps = json.decode(properties)
    if categoryInfo.callsign then
        vehicleProps.callsign = true
    end

    local vehicleId = NDCore.setVehicleOwned(player.id, vehicleProps, true)
    local spawns = dealership.spawns
    local coords = spawns and getAvailableParking(spawns)
    if not vehicleId or not coords then
        return player.notify({
            title = "Vehicle sent to garage",
            description = "No parking spot found, your vehicle can be found in your garage.",
            type = "inform",
            duration = 8000,
            position = "bottom"
        })
    elseif stored then
        return player.notify({
            title = "Transaction complete",
            description = "Vehicle successfully purchased, the vehicle can now be found in your garage.",
            type = "success",
            duration = 8000,
            position = "bottom"
        })
    else
        player.notify({
            title = "Transaction complete",
            description = "Vehicle successfully purchased, the vehicle can be found in the parking lot.",
            type = "success",
            duration = 8000,
            position = "bottom"
        })
    end
    local newInfo = NDCore.spawnOwnedVehicle(src, vehicleId, coords)
    if not newInfo then return end
    TriggerClientEvent("ND_Vehicles:blip", src, newInfo.netId, true)
end)

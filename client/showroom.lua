local showroom = {
    rooms = {},
    vehicles = {},
    pointsCreated = false,
    slots = {}
}

function showroom.deleteVehicles(vehicles)
    if not vehicles then return end
    Target:removeLocalEntity(vehicles, {"nd_dealership:showroomTestDrive", "nd_dealership:showroomSwitchVeh", "nd_dealership:showroomPurchase"})
    for i=1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
end

function showroom.getSlotFromEntity(entity)
    for slot, slotEntity in ipairs(showroom.slots) do
        if DoesEntityExist(slotEntity) and slotEntity == entity then
            return slot
        end
    end
end

function showroom.getVehicleData(entity)
    for dealer, vehicles in pairs(showroom.rooms) do
        for i=1, #vehicles do
            local info = vehicles[i]
            if info and info.vehicle == entity then
                return info, dealer
            end
        end
    end
end

local function setTargetPerms(vehicle, groups, vehicleTargets)
    if groups then        
        if HasPermissionGroup("switch", groups) then
            vehicleTargets.switch[#vehicleTargets.switch+1] = vehicle
        end
        if HasPermissionGroup("testdrive", groups) then
            vehicleTargets.testdrive[#vehicleTargets.testdrive+1] = vehicle
        end
        if HasPermissionGroup("purchase", groups) then
            vehicleTargets.purchase[#vehicleTargets.purchase+1] = vehicle
        end
    else
        vehicleTargets.switch[#vehicleTargets.switch+1] = vehicle
        vehicleTargets.testdrive[#vehicleTargets.testdrive+1] = vehicle
        vehicleTargets.purchase[#vehicleTargets.purchase+1] = vehicle
    end
end

function showroom.spawnVehicles(dealer, sr)
    local vehiclesCreated = {}
    local dealerProperties = {}
    local vehicleTargets = {
        switch = {},
        testdrive = {},
        purchase = {}
    }

    for i=1, #sr do
        local info = sr[i]
        local loc = info.location
        ClearAreaOfVehicles(loc.x, loc.y, loc.z, 10.0, false, false, false, false, false)
        lib.requestModel(info.model)

        local vehicle = CreateVehicle(info.model, loc.x, loc.y, loc.z, loc.w, false, false)
        vehiclesCreated[#vehiclesCreated+1] = vehicle
        showroom.slots[#showroom.slots+1] = vehicle

        setTargetPerms(vehicle, info.groups, vehicleTargets)
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleOnGroundProperly(vehicle)
        FreezeEntityPosition(vehicle, true)

        info.vehicle = vehicle
        local props = info.properties
        if props then
            lib.setVehicleProperties(vehicle, json.decode(props))
        else
            info.properties = json.encode(lib.getVehicleProperties(vehicle))
            dealerProperties[i] = info.properties
        end
    end
    showroom.vehicles[dealer] = vehiclesCreated
    TriggerEvent("ND_Dealership:createVehicleTargets", vehicleTargets, dealer)
    return dealerProperties
end

local function replaceCreatedVehicle(dealer, oldVehicle, newVehicle)
    local vehiclesCreated = showroom.vehicles[dealer]
    for i=1, #vehiclesCreated do
        local veh = vehiclesCreated[i]
        if veh == oldVehicle then
            vehiclesCreated[i] = newVehicle
            return
        end
    end
    vehiclesCreated[#vehiclesCreated+1] = newVehicle
end

function showroom.createVehicle(selectedVehicle, dealer, index, vehicleInfo)
    local sr = showroom.rooms[dealer]
    local vehicleTargets = {
        switch = {},
        testdrive = {},
        purchase = {}
    }

    local oldVehicle = sr[selectedVehicle]?.vehicle
    if oldVehicle and DoesEntityExist(oldVehicle) then
        DeleteEntity(oldVehicle)
    end

    vehicleInfo.groups = sr[selectedVehicle]?.groups
    sr[selectedVehicle] = vehicleInfo
    local info = sr[selectedVehicle]

    local loc = info.location
    ClearAreaOfVehicles(loc.x, loc.y, loc.z, 10.0, false, false, false, false, false)
    lib.requestModel(info.model)
    local vehicle = CreateVehicle(info.model, loc.x, loc.y, loc.z, loc.w, false, false)

    setTargetPerms(vehicle, info.groups, vehicleTargets)
    replaceCreatedVehicle(dealer, oldVehicle, vehicle)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleOnGroundProperly(vehicle)
    FreezeEntityPosition(vehicle, true)

    info.vehicle = vehicle
    local props = info.properties
    lib.setVehicleProperties(vehicle, json.decode(props))
    showroom.slots[selectedVehicle] = vehicle

    TriggerEvent("ND_Dealership:createVehicleTargets", vehicleTargets, dealer)
end

function showroom.createPoints()
    showroom.pointsCreated = true
    for dealer, sr in pairs(showroom.rooms) do
        local location = sr[1].location
        local point = lib.points.new({
            coords = location,
            distance = 30
        })
    
        function point:onEnter()
            SetTimeout(500, function()
                local dealerProperties = showroom.spawnVehicles(dealer, sr)
                if next(dealerProperties) then
                    TriggerServerEvent("ND_Dealership:updateDealerProperties", dealer, dealerProperties)
                end
            end)
        end
    
        function point:onExit()
            showroom.deleteVehicles(showroom.vehicles[dealer])
        end
    end
end

function showroom.createShowrooms(rooms)
    showroom.rooms = rooms
    if not showroom.pointsCreated then
        showroom.createPoints()
    end
end

return showroom
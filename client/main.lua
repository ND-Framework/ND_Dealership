local showroom = require "client.showroom"
local testdrive = require "client.testdrive"
local menu = require "client.menu"
local selectedVehicle = nil
Target = exports.ox_target

lib.zones.box({
    name = "testdrivezone",
    coords = vec3(-1984.0, 1111.0, -23.0),
    size = vec3(302.0, 252.5, 11.0),
    rotation = 0.0,
    onEnter = testdrive.enterZone,
    onExit = testdrive.exitZone,
    inside = testdrive.insideZone
})

RegisterNetEvent("ND_Dealership:updateShowroomVehicle", function(selectedVehicle, dealer, index, vehicleInfo)
    showroom.createVehicle(selectedVehicle, dealer, index, vehicleInfo)
end)

AddEventHandler("ND_Dealership:menuItemSelected", function(selected)
    if selected.menuType == "switch" then
        local pedCoords = GetEntityCoords(cache.ped)

        lib.requestModel(selected.model)
        local vehicle = CreateVehicle(selected.model, pedCoords.x, pedCoords.y, pedCoords.z-50.0, 0.0, false, false)
        while not DoesEntityExist(vehicle) do Wait(100) end
        
        local properties = json.encode(lib.getVehicleProperties(vehicle))
        DeleteEntity(vehicle)
        TriggerServerEvent("ND_Dealership:switchShowroomVehicle", selectedVehicle, selected.dealership, selected.category, selected.index, properties)
    end
end)

AddEventHandler("ND_Dealership:createVehicleTargets", function(vehicles, dealer, vehicleSlots)
    Target:addLocalEntity(vehicles, {
        {
            name = "nd_dealership:showroomTestDrive",
            icon = "fa-solid fa-key",
            label = "Test drive",
            distance = 1.5,
            onSelect = testdrive.start
        },
        {
            name = "nd_dealership:showroomSwitchVeh",
            icon = "fa-solid fa-warehouse",
            label = "Switch vehicle",
            distance = 1.5,
            onSelect = function(data)
                selectedVehicle = showroom.getSlotFromEntity(data.entity, vehicleSlots)
                menu.show(dealer, "switch")
            end
        },
        {
            name = "nd_dealership:showroomPurchase",
            icon = "fa-solid fa-money-check-dollar",
            label = "Purchase",
            distance = 1.5,
            onSelect = function(data)
                local veh = data.entity
                local info, dealer = showroom.getVehicleData(veh)
                local input = lib.inputDialog(("Purchase vehicle for $%s"):format(info.price), {
                    {type = "checkbox", label = "Send to garage"}
                })
                if not input or not info then return end
                TriggerServerEvent("ND_Dealership:purchaseVehicle", input[1], dealer, info)
            end
        }
    })
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end
    for _, vehicles in pairs(showroom.vehicles) do
        showroom.deleteVehicles(vehicles)
    end
end)

RegisterNetEvent("ND_Dealership:updateShowroomData", function(showrooms)
    showroom.createShowrooms(showrooms)
end)


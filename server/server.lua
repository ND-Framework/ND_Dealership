NDCore = exports["ND_Core"]:GetCoreObject()

function getPriceFromModel(model)
    for _, category in pairs(Config.vehicles) do
        for _, veh in pairs(category) do
            if veh.model == model then
                return veh.price
            end
        end
    end
    return false
end

RegisterNetEvent('ND_Dealership:purchaseVehicle', function(props, inGarage, method)
    local source = source
    local player = NDCore.Functions.GetPlayer(source)
    local price = getPriceFromModel(props.model)

    if not price or (player[method] < price) then return end
    NDCore.Functions.DeductMoney(price, source, method)

    local vehid = exports["ND_VehicleSystem"]:setVehicleOwned(source, props, inGarage)
    if not inGarage then
        local spawnVehicleCoords = Config.purchasedVehicleSpawns[math.random(1, #Config.purchasedVehicleSpawns)]
        exports["ND_VehicleSystem"]:spawnOwnedVehicle(source, vehid, spawnVehicleCoords)
    end
end)
local random = math.random
local seed = math.randomseed
local time = os.time

NDCore = exports.ND_Core:GetCoreObject()

local function getPriceFromModel(model)
    for _, category in pairs(Config.vehicles) do
        for _, veh in pairs(category) do
            if veh.model == model then
                return veh.price
            end
        end
    end
    return false
end

RegisterNetEvent('ND_Dealership:purchaseVehicle', function(props, inGarage, method, dealerName)
    local source = source
    local player = NDCore.Functions.GetPlayer(source)
    local price = getPriceFromModel(props.model)

    if not price or (player[method] < price) then return end
    NDCore.Functions.DeductMoney(price, source, method)

    local vehid = exports.ND_VehicleSystem:setVehicleOwned(source, props, true)
    if not inGarage then
        if not dealerName or not Config.dealerships[dealerName] then return end
        local spawns = Config.dealerships[dealerName].spawns
        if not spawns then return end
        exports.ND_VehicleSystem:spawnOwnedVehicle(source, vehid, spawns)
    end
end)

RegisterNetEvent('ND_Dealership:setTestDriveBucket', function(returnToDefaultBucket)
    local source = source
    local bucket = 0

    if not returnToDefaultBucket then
        seed(time())
        bucket = random(1, 100)
    else
        bucket = bucket
    end

    SetPlayerRoutingBucket(source, tonumber(bucket))
end)
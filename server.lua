NDCore = exports["ND_Core"]:GetCoreObject()

RegisterNetEvent('ND_Dealership:purchaseVehicle', function(props, inGarage, price, method)
    local source = source
    NDCore.Functions.DeductMoney(price, source, method)

    exports.ND_VehicleSystem:saveVehicle(source, props, inGarage)
end)
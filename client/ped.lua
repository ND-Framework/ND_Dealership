local created = false
local pedInteract = {}
local lastLocation = nil
local vehicleView = false
local currentVehicle = nil

local function getInteractGroups(dealership)
    local groups = Data.dealerships[dealership].groups
    if not groups then return end
    
    local allowedGroups = {}
    for group, info in pairs(groups) do
        if info.interact then
            allowedGroups[#allowedGroups+1] = group
        end
    end
    return allowedGroups
end

function pedInteract.create()
    if created then return end
    created = true
    for dealer, info in pairs(Data.dealerships) do
        local groups = getInteractGroups(dealer)
        local interact = Data.dealerships[dealer].interact
        if not interact then goto skip end
        NDCore.createAiPed({
            model = interact.pedModel,
            coords = interact.pedCoords,
            distance = 45.0,
            anim = {
                dict = "anim@amb@casino@valet_scenario@pose_d@",
                clip = "base_a_m_y_vinewood_01"
            },
            options = {
                {
                    name = "nd_core:dealershipPed",
                    icon = "fa-solid fa-warehouse",
                    label = "View vehicles",
                    distance = 2.0,
                    canInteract = function(entity, distance, coords, name, bone)
                        if not groups then return true end
                        local player = NDCore.getPlayer()
                        for i=1, #groups do
                            if player.groups?[groups[i]] then
                                return true
                            end
                        end
                    end,
                    onSelect = function(data)
                        Menu.show(dealer, "interact")
                    end
                }
            },
        })
        ::skip::
    end
end

function pedInteract.exitVehicleView(loc)
    vehicleView = false
    lib.hideTextUI()
    DoScreenFadeOut(1500)
    Wait(1500)

    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
    end
    if loc then        
        SetEntityCoords(cache.ped, loc.x, loc.y, loc.z-0.5)
        SetEntityHeading(cache.ped, loc.w)
        NetworkFadeInEntity(cache.ped, false)
        SetGameplayCamRelativeHeading(0.0)
        Wait(500)
        DoScreenFadeIn(1500)
    end
end

function pedInteract.testdrive(vehicle, dealer, properties)
    local alert = lib.alertDialog({
        header = "Vehicle test drive",
        content = "Start a test drive with this vehicle?  \nYou can leave the test drive at any time.",
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then return end
    if not lib.callback.await("ND_Dealership:setupTestDrive", nil, nil, dealer, lastLocation) then return end
    Testdrive.active = true
    pedInteract.exitVehicleView(loc)
    NetworkFadeInEntity(cache.ped, false)
    TriggerServerEvent("ND_Dealership:startTestDrive", properties, dealer)
end

function pedInteract.viewVehicle(selected)
    local dealer = selected.dealership
    local info = Data.dealerships[dealer]
    local loc = info?.interact?.vehicleCoords
    if not loc then return end
    vehicleView = true

    local oldPedCoords = GetEntityCoords(cache.ped)
    lastLocation = vec4(oldPedCoords.x, oldPedCoords.y, oldPedCoords.z, GetEntityHeading(cache.ped))
    DoScreenFadeOut(1500)
    Wait(1500)
    NetworkFadeOutEntity(cache.ped, true, false)
    Wait(150)
    SetEntityCoords(cache.ped, loc.x, loc.y, loc.z)
    Wait(250)
    local int = GetInteriorAtCoords(loc.x, loc.y, loc.z)
    RefreshInterior(int)

    lib.requestModel(selected.model)
    local vehicle = CreateVehicle(selected.model, loc.x, loc.y, loc.z, loc.w, false, false)
    while not DoesEntityExist(vehicle) do Wait(100) end
    currentVehicle = vehicle

    while GetPedInVehicleSeat(vehicle, -1) ~= cache.ped do
        SetPedIntoVehicle(cache.ped, vehicle, -1)
        Wait(10)
    end

    Wait(100)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleDoorsLocked(vehicle, 4)
    FreezeEntityPosition(vehicle, true)
    SetGameplayCamRelativeHeading(0.0)
    
    if selected.info.properties then
        lib.setVehicleProperties(vehicle, json.decode(selected.info.properties))
    end

    local properties = json.decode(selected.info.properties) or lib.getVehicleProperties(vehicle)
    local groups = info.groups
    local perms = {
        testdrive = HasPermissionGroup("testdrive", groups),
        purchase = HasPermissionGroup("purchase", groups)
    }

    local text = ("[F] - return%s%s"):format(perms.testdrive and "  \n[E] - test drive" or "", perms.purchase and "  \n[G] - purchase" or "")
    lib.showTextUI(text)
    
    CreateThread(function()
        while vehicleView do
            Wait(0)
            if IsControlJustPressed(0, 75) then
                pedInteract.exitVehicleView(lastLocation)
            elseif perms.testdrive and IsControlJustPressed(0, 38) then
                pedInteract.testdrive(vehicle, dealer, properties)
            elseif perms.purchase and IsControlJustPressed(0, 58) then
                PurchaseVehicle(dealer, {
                    model = selected.model,
                    price = selected.price,
                    properties = json.encode(properties)
                })
            end
        end
    end)

    Wait(500)
    DoScreenFadeIn(1500)
end

return pedInteract
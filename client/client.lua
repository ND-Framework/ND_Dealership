local workerLocation = vec4(-33.17, -1100.59, 26.42, 68.77)
local worker = 0
local dealerShown = false
local pedCoords = vec3(0, 0, 0)
local nearDealer = false
local cam = 0
local displayVehicle = 0
local vehicle = 0
local cellphone = 0
local seed = math.randomseed
local random = math.random

NDCore = exports["ND_Core"]:GetCoreObject()

local function purchaseVehicle(model, price)
    local labelName = GetLabelText(GetDisplayNameFromVehicleModel(model))

    local input = lib.inputDialog('Purchase ' .. labelName .. ' for $' .. price .. '?', {
        { type = 'select', label = 'Method Of Pay', options = {
            { value = 'cash', label = 'Cash' },
            { value = 'bank', label = 'Bank' },
        }},
        { type = 'checkbox', label = 'Send to Garage', checked = false }
    })

    if input then
        local method = input[1]
        local inGarage = input[2]

        if method == nil then return end
        if inGarage == nil then store = false end

        local tempVeh = CreateVehicle(model, 0.0, 0.0, 0.0, 0.0, false, false)
        local props = lib.getVehicleProperties(tempVeh)
        props.class = GetVehicleClass(tempVeh)
        SetEntityAsMissionEntity(tempVeh, true, true)
        DeleteVehicle(tempVeh)

        local selectedCharacter = NDCore.Functions.GetSelectedCharacter()

        local oldBalance = method == 'cash' and selectedCharacter.cash or selectedCharacter.bank

        if oldBalance >= price then
            TriggerServerEvent('ND_Dealership:purchaseVehicle', props, inGarage, price, method)

            local newBalance = oldBalance - price

            lib.notify({
                title = 'Vehicle Purchased',
                position = 'top',
                icon = 'car',
                description = 'You purchased a ' .. labelName .. ' for $' .. price .. ' (' .. oldBalance .. ' -> ' .. newBalance .. ')! ' .. (inGarage and 'It has been sent to your garage.' or 'Spawning outside momentarily.'),
                duration = 5000,
                type = 'success'
            })

            if not inGarage then
                seed(GetGameTimer())
                local spawnVehicleCoords = Config.purchasedVehicleSpawns[random(1, #Config.purchasedVehicleSpawns)]
                vehicle = CreateVehicle(model, spawnVehicleCoords.x, spawnVehicleCoords.y, spawnVehicleCoords.z, spawnVehicleCoords.h, true, false)
                lib.setVehicleProperties(vehicle, props)
            end
        else
            lib.notify({
                title = 'Insufficent Funds',
                position = 'top',
                icon = 'car',
                description = 'You\'re short $' .. (price - oldBalance) .. ' to be able to purchase this vehicle.',
                duration = 3000,
                type = 'error'
            })
        end
    end
end

local function createVehicleCam(model, price)
    if not IsModelAVehicle(model) or not IsModelInCdimage(model) then return end

    lib.requestModel(model)

    displayVehicle = CreateVehicle(model, -44.38, -1098.05, 26.42, 248.96, false, false)
    repeat Wait(0) until DoesEntityExist(displayVehicle)
    SetVehicleNumberPlateText(displayVehicle, 'DEALER')
    SetVehicleNumberPlateTextIndex(displayVehicle, 4)
    SetModelAsNoLongerNeeded(model)

    local offset = GetOffsetFromEntityInWorldCoords(displayVehicle, 0.0, 6.0, 0.0)
    cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
    SetCamActive(cam, true)
    PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
    RenderScriptCams(true, true, 500, true, true)

    FreezeEntityPosition(cache.ped, true)

    while IsCamActive(cam) do
        Wait(0)

        lib.showTextUI('($' .. price .. ') ' .. GetLabelText(GetDisplayNameFromVehicleModel(model)), {
            position = 'top-center',
            icon = 'car'
        })

        lib.showTextUI('[A] Left View, [D] Right View, [S] Center View, [E] Exit, [ENTER] Purchase (Confirmation Dialog)', {
            position = 'right-center',
            icon = 'camera-retro'
        })

        -- S key (center cam, default)
        if IsControlJustPressed(0, 8) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- D key (cam right)
        if IsControlJustPressed(0, 9) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y + 5.0, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- A key (cam left)
        if IsControlJustPressed(0, 34) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y - 3.8, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- ENTER key (open purchase dialog)
        if IsControlJustPressed(0, 18) then
            SetCamActive(cam, false)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(cam, false)
            DeleteVehicle(displayVehicle)
            purchaseVehicle(model, price)
        end

        -- E key (exit cam)
        if IsControlJustPressed(0, 54) then
            SetCamActive(cam, false)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(cam, false)
            SetEntityAsMissionEntity(displayVehicle, true, true)
            DeleteVehicle(displayVehicle)
        end
    end

    FreezeEntityPosition(cache.ped, false)
    dealerShown = false
    lib.hideTextUI()

    local blip = AddBlipForEntity(vehicle)
    SetBlipSprite(blip, 225)
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Purchased Car')
    EndTextCommandSetBlipName(blip)

    while cache.vehicle ~= vehicle do
        Wait(250)
    end

    RemoveBlip(blip)
end

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end

    lib.registerMenu({
        id = 'dealer_menu',
        title = 'Dealer Menu',
        position = 'top-right',
        onClose = function()
            dealerShown = false
        end,
        options = {
            { icon = 'car', label = 'Compacts', args = 'compacts' },
            { icon = 'car', label = 'Sedans', args = 'sedans' },
            { icon = 'car', label = 'SUVs', args = 'suvs' },
            { icon = 'car', label = 'Coupes', args = 'coupes' },
            { icon = 'car', label = 'Muscle', args = 'muscle' },
            { icon = 'car', label = 'Sports Classics', args = 'sportsclassics' },
            { icon = 'car', label = 'Sports', args = 'sports' },
            { icon = 'car', label = 'Super', args = 'super' },
            { icon = 'car', label = 'Motorcycles', args = 'motorcycles' },
            { icon = 'car', label = 'Off-Road', args = 'offroad' }
        }
    }, function(_, _, args)
        if args == 'compacts' then
            lib.showMenu('dealer_menu_compacts')
        elseif args == 'coupes' then
            lib.showMenu('dealer_menu_coupes')
        end
    end)

    lib.registerMenu({
        id = 'dealer_menu_compacts',
        title = 'Compacts',
        position = 'top-right',
        onClose = function()
            dealerShown = false
        end,
        options = {
            { label = 'Compacts', icon = 'car', values = { 'Asbo', 'Blista', 'Brioso R/A', 'Dilettante', 'Issi', 'Panto', 'Prairie', 'Rhapsody' } },
        }
    }, function(_, scrollIndex, _)
        for i = 1, #Config.vehicles.compacts do
            if i == scrollIndex then
                lib.hideMenu()
                createVehicleCam(Config.vehicles.compacts[i].model, Config.vehicles.compacts[i].price)
            end
        end
    end)

    local blip = AddBlipForCoord(workerLocation.x, workerLocation.y, workerLocation.z)
    SetBlipSprite(blip, 523)
    SetBlipColour(blip, 3)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Dealership')
    EndTextCommandSetBlipName(blip)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end

    lib.hideMenu()
    lib.hideTextUI()
    if worker ~= 0 then
        print('Deleting dealership worker: ' .. worker)
        DeletePed(worker)
    end

    if displayVehicle ~= 0 then
        print('Deleting display vehicle: ' .. displayVehicle)
        DeleteVehicle(displayVehicle)
    end

    if cam ~= 0 then
        print('Destroying camera' .. cam)
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
    end

    if cellphone ~= 0 then
        print('Deleting cellphone: ' .. cellphone)
        SetEntityAsMissionEntity(cellphone, true, true)
        DeleteObject(cellphone)
    end
end)

CreateThread(function()
    while true do
        pedCoords = GetEntityCoords(cache.ped)
        Wait(500)
    end
end)

CreateThread(function()
    local sleep = 0

    while true do
        nearDealer = false
        local dist = #(pedCoords - vec3(workerLocation.x, workerLocation.y, workerLocation.z))

        if dist <= 80.0 then
            nearDealer = true

            if worker == 0 then
                worker, cellphone = spawnWorker(workerLocation)
                print('Spawning dealership worker: ' .. worker)
            end

            if dist < 1.5 then
                sleep = 0

                if not dealerShown then
                    lib.showTextUI('[E] - Open Dealer Menu', {
                        icon = 'car'
                    })
                else
                    lib.hideTextUI()
                end

                if not dealerShown and IsControlJustPressed(0, 54) then
                    dealerShown = true
                    lib.showMenu('dealer_menu')
                end
            else
                lib.hideTextUI()
                sleep = 500
            end
        end

        if not nearDealer and worker ~= 0 then
            print('Deleting dealership worker: ' .. worker)
            DeletePed(worker)
            worker = 0
        end

        Wait(sleep)
    end
end)
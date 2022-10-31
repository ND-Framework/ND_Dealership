local workerLocation = vec4(-33.17, -1100.59, 26.42, 68.77)
local worker = 0
local dealerShown = false
local pedCoords = vec3(0, 0, 0)
local nearDealer = false
local cam = 0
local displayVehicle = 0
local cellphone = 0

local function createVehicleCam(model, price)
    if not IsModelAVehicle(model) or not IsModelInCdimage(model) then return end

    lib.requestModel(model)

    displayVehicle = CreateVehicle(model, -44.38, -1098.05, 26.42, 248.96, false, false)
    repeat Wait(0) until DoesEntityExist(displayVehicle)
    SetVehicleNumberPlateText(displayVehicle, 'DEALER')
    SetVehicleNumberPlateTextIndex(displayVehicle, 4)
    SetModelAsNoLongerNeeded(model)

    local offset = GetOffsetFromEntityInWorldCoords(displayVehicle, 0.0, 6.0, 0.0)
    cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)
    SetCamActive(cam, true)
    PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
    RenderScriptCams(true, true, 500, true, true)

    while IsCamActive(cam) do
        Wait(0)

        lib.showTextUI('($' .. price .. ') ' .. GetLabelText(GetDisplayNameFromVehicleModel(model)), {
            position = 'top-center',
            icon = 'car'
        })

        -- S key
        if IsControlJustPressed(0, 8) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- D key
        if IsControlJustPressed(0, 9) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y + 5.0, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- A key
        if IsControlJustPressed(0, 34) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y - 3.8, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- E key
        if IsControlJustPressed(0, 54) then
            SetCamActive(cam, false)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(cam, false)
            DeleteVehicle(displayVehicle)
        end
    end

    dealerShown = false
    lib.hideTextUI()
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

        if dist <= 95.0 then
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
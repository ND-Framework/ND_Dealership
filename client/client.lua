local workerLocation = vec4(-33.67, -1100.36, 26.42, 78.64)
local worker = 0
local dealerShown = false
local pedCoords = vec3(0, 0, 0)
local newCam = 0
local vehicle = 0

--- Creates and returns a camera.
---@param view string (left, right)
---@return number cam
local function changeCamera(view)
    local offset = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 6.0, 0.0)

    if view == 'left' then local cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y - 5.0, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0) return cam end

    local cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y + 5.0, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)

    return cam
end

local function createVehicleCam(model)
    if not IsModelAVehicle(model) or not IsModelInCdimage(model) then return end

    lib.requestModel(model)

    vehicle = CreateVehicle(model, -44.38, -1098.05, 26.42, 255.33, false, false)
    local offset = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 6.0, 0.0)
    local cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y + 1.5, offset.z+ 0.8, 0.0, 0.0, 0.0, 30.0, false, 0)

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    PointCamAtCoord(cam, -44.38, -1098.05, 26.42)

    while IsCamActive(cam) or IsCamActive(newCam) do
        Wait(0)

        -- S key
        if IsControlJustPressed(0, 8) then
            newCam = cam
            SetCamActive(newCam, true)
            RenderScriptCams(true, true, 500, true, true)
            PointCamAtCoord(newCam, -44.38, -1098.05, 26.42)
        end

        -- D key
        if IsControlJustPressed(0, 9) then
            newCam = changeCamera('right')
            SetCamActive(newCam, true)
            RenderScriptCams(true, true, 500, true, true)
            PointCamAtCoord(newCam, -44.38, -1098.05, 26.42)
        end

        -- A key
        if IsControlJustPressed(0, 34) then
            newCam = changeCamera('left')
            SetCamActive(newCam, true)
            RenderScriptCams(true, true, 500, true, true)
            PointCamAtCoord(newCam, -44.38, -1098.05, 26.42)
        end

        -- E key
        if IsControlJustPressed(0, 54) then
            SetCamActive(cam, false)
            RenderScriptCams(false, true, 500, true, true)
            DestroyCam(cam, false)
            DeleteVehicle(vehicle)
            break
        end
    end
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
                lib.defaultNotify({
                    title = 'Vehicle Selected',
                    description = 'You are viewing the ' .. GetLabelText(GetDisplayNameFromVehicleModel(Config.vehicles.compacts[i].model)) .. ', [A] to go left, [D] to go right, [S] to center (offset) camera, [E] to exit',
                    icon = 'car',
                    position = 'top',
                    status = 'success',
                    duration = '4000'
                })
                createVehicleCam(Config.vehicles.compacts[i].model)
            end
        end
    end)

    if worker == 0 then
        worker = spawnWorker(workerLocation)
        print('Spawning dealership worker: ' .. worker)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource ~= resourceName then return end

    lib.hideMenu()
    lib.hideTextUI()
    if worker ~= 0 then
        print('Deleting dealership worker: ' .. worker)
        DeletePed(worker)
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
        if #(pedCoords - vec3(workerLocation.x, workerLocation.y, workerLocation.z)) <= 1.5 then
            sleep = 0

            if not dealerShown then
                lib.showTextUI('[E] - Open Dealer Menu', {
                    icon = 'car'
                })
            else
                lib.hideTextUI()
            end

            if IsControlJustPressed(0, 54) then
                dealerShown = true
                lib.showMenu('dealer_menu')
            end
        else
            lib.hideTextUI()
            sleep = 1500
        end

        Wait(sleep)
    end
end)
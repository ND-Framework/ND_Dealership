local workerLocation = vec4(-33.17, -1100.59, 26.42, 68.77)
local worker = 0
local dealerShown = false
local pedCoords = vec3(0, 0, 0)
local cam = 0
local displayVehicle = 0
local testDriveVehicle = 0
local vehicle = 0
local cellphone = 0

NDCore = exports.ND_Core:GetCoreObject()

local function testDrive(model)
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(model))
    local labelName = GetLabelText(GetDisplayNameFromVehicleModel(model))
    local testDriveSpawnCoords = vec3(-44.88, -1082.68, 26.69)
    testDriveVehicle = CreateVehicle(model, testDriveSpawnCoords.x, testDriveSpawnCoords.y, testDriveSpawnCoords.z, 67.59, true, false)
    SetVehicleEngineOn(testDriveVehicle, true, true, true)
    FreezeEntityPosition(cache.ped, false)
    SetPedIntoVehicle(cache.ped, testDriveVehicle, -1)

    lib.notify({
        title = 'Test-Drive Started',
        position = 'top',
        icon = 'vial',
        description = 'You are now test-driving the ' .. makeName ..' ' .. labelName .. ' for ' .. Config.testDriveTime ..'s (test-drive radius is ' .. Config.testDriveRadius .. ').',
        duration = 5000,
        type = 'inform'
    })

    Wait(2000)

    local tempTimer = GetGameTimer()

    while true do
        if GetGameTimer() - tempTimer > Config.testDriveTime * 1000 then
            lib.notify({
                title = 'Test-Drive Ended',
                position = 'top',
                icon = 'vial',
                description = 'Your test-drive of the ' .. makeName .. ' ' .. labelName .. ' has ended.',
                duration = 5000,
                type = 'inform'
            })
            break
        end

        if cache.vehicle ~= testDriveVehicle then
            lib.notify({
                title = 'Test-Drive Ended',
                position = 'top',
                icon = 'vial',
                description = 'You have ended your test-drive of the ' .. makeName .. ' ' .. labelName .. ', due to exiting the vehicle.',
                duration = 5000,
                type = 'inform'
            })
            break
        end

        local testDriveVehicleCoords = GetEntityCoords(testDriveVehicle)
        local distance = #(testDriveVehicleCoords - testDriveSpawnCoords)

        if distance > Config.testDriveRadius then
            lib.notify({
                title = 'Test-Drive Ended',
                position = 'top',
                icon = 'vial',
                description = 'You have ended your test-drive of the ' .. makeName .. ' ' .. labelName .. ', due to venturing outside of the test-drive area (' .. Config.testDriveRadius .. ').',
                duration = 5000,
                type = 'inform'
            })
            break
        end

        Wait(0)
    end

    SetEntityAsMissionEntity(testDriveVehicle, true, true)
    DeleteVehicle(testDriveVehicle)
    SetEntityCoords(cache.ped, -44.88, -1082.68, 26.69, false, false, false, false)

    onTestDrive = false
    testDriveVehicle = 0
    testVehicleCoords = vec3(0, 0, 0)
    distance = 0
end

local function purchaseVehicle(model, price)
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(model))
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
            TriggerServerEvent('ND_Dealership:purchaseVehicle', props, inGarage, method)

            local newBalance = oldBalance - price

            lib.notify({
                title = 'Vehicle Purchased',
                position = 'top',
                icon = 'car',
                description = 'You purchased a '.. makeName .. ' ' .. labelName .. ' for $' .. price .. ' (' .. oldBalance .. ' -> ' .. newBalance .. '). ' .. (inGarage and 'It has been sent to your garage.' or 'Spawning outside momentarily.'),
                duration = 6000,
                type = 'success'
            })
        else
            lib.notify({
                title = 'Insufficent Funds',
                position = 'top',
                icon = 'car',
                description = 'You\'re short $' .. (price - oldBalance) .. ' to be able to purchase this vehicle.',
                duration = 4500,
                type = 'error'
            })
        end
    end
end

local function createVehicleCam(model, price)
    if not IsModelAVehicle(model) or not IsModelInCdimage(model) then return end

    inCamView = true

    lib.requestModel(model)

    displayVehicle = CreateVehicle(model, -44.38, -1098.05, 26.42, 248.96, false, false)
    repeat Wait(0) until DoesEntityExist(displayVehicle)
    ClearArea(-44.38, -1098.05, 26.42, 5.0, true, false, true, false)
    SetVehicleNumberPlateText(displayVehicle, 'DEALER')
    SetVehicleNumberPlateTextIndex(displayVehicle, 4)
    SetModelAsNoLongerNeeded(model)

    local offset = GetOffsetFromEntityInWorldCoords(displayVehicle, 0.0, 6.0, 0.0)
    cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
    SetCamActive(cam, true)
    PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
    RenderScriptCams(true, true, 500, true, true)

    FreezeEntityPosition(displayVehicle, true)
    SetEntityCollision(vehicle, false, false)
    FreezeEntityPosition(cache.ped, true)

    lib.showTextUI('[A] Left View  \n[D] Right View  \n[W] Center View  \n[S] Rear View  ' .. (Config.testDriveEnabled and '\n[G] Test-Drive' or ' ') .. '  \n[E] Exit  \n[ENTER] Purchase ($' .. price .. ')')

    while IsCamActive(cam) do
        Wait(0)

        -- S key (rear cam)
        if IsControlJustPressed(0, 8) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x - 15.0, offset.y + 5.6, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
            SetCamActive(cam, true)
            PointCamAtCoord(cam, -44.38, -1098.05, 26.42)
            RenderScriptCams(true, true, 500, true, true)
        end

        -- W key (center cam, default)
        if IsControlJustPressed(0, 32) then
            cam = CreateCameraWithParams('DEFAULT_SCRIPTED_CAMERA', offset.x, offset.y, offset.z + 0.8, 0.0, 0.0, 0.0, 30.0, false, 2)
            SetCamActive(cam, true)
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

        if Config.testDriveEnabled then
            -- G key (test-drive)
            if IsControlJustPressed(0, 113) then
                SetCamActive(cam, false)
                RenderScriptCams(false, true, 500, true, true)
                DestroyCam(cam, false)
                DeleteVehicle(displayVehicle)
                inCamView = false
                testDrive(model)
            end
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
    inCamView = false
    displayVehicle = 0
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
        options = getDealerMenu()
    }, function(_, scrollIndex, args)

        for i = 1, #Config.vehicles[args.category] do
            if i == scrollIndex then
                lib.hideMenu()
                createVehicleCam(Config.vehicles[args.category][i].model, Config.vehicles[args.category][i].price)
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
        print('Destroying camera: ' .. cam)
        SetCamActive(cam, false)
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
    end

    if cellphone ~= 0 then
        print('Deleting cellphone: ' .. cellphone)
        SetEntityAsMissionEntity(cellphone, true, true)
        DeleteObject(cellphone)
    end

    if testDriveVehicle ~= 0 then
        print('Deleting test-drive vehicle: ' .. testDriveVehicle)
        SetEntityAsMissionEntity(testDriveVehicle, true, true)
        DeleteVehicle(testDriveVehicle)
    end
end)

CreateThread(function()
    while true do
        pedCoords = GetEntityCoords(cache.ped)
        Wait(500)
    end
end)

CreateThread(function()
    local sleep = 500
    local notified = false

    while true do
        local dist = #(pedCoords - vec3(workerLocation.x, workerLocation.y, workerLocation.z))

        if dist <= 80.0 then
            if worker == 0 then
                worker, cellphone = spawnWorker(workerLocation)
                print('Spawning dealership worker: ' .. worker)
            end

            if dist < 1.5 then
                sleep = 0

                if not dealerShown or not notified then
                    notified = true
                    lib.showTextUI('[E] - Open Dealer Menu', {
                        icon = 'car'
                    })
                end

                if not dealerShown and IsControlJustPressed(0, 54) then
                    dealerShown = true
                    lib.hideTextUI()
                    lib.showMenu('dealer_menu')
                end
            else
                if lib.getOpenMenu() ~= nil then lib.hideMenu(true) end
                if notified then
                    notified = false
                    lib.hideTextUI()
                end
                sleep = 500
            end
        elseif worker ~= 0 then
            print('Deleting dealership worker: ' .. worker)
            DeletePed(worker)
            worker = 0
        end

        Wait(sleep)
    end
end)
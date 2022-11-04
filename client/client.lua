local workerLocation = vec4(-33.17, -1100.59, 26.42, 68.77)
local worker = 0
local dealerShown = false
local pedCoords = vec3(0, 0, 0)
local displayVehicle = 0
local testDriveVehicle = 0
local cellphone = 0
local tablet = 0
local dummyPed = 0
local vehicleView = false

NDCore = exports.ND_Core:GetCoreObject()

local function cleanupVehicleView(returnCoords)
    SetEntityHeading(cache.ped, 255.23)
    SetEntityCoords(cache.ped, returnCoords.x, returnCoords.y, returnCoords.z - 1.0, false, false, false, false)
    SetEntityVisible(cache.ped, true, true)
    DeleteVehicle(displayVehicle)
    DeletePed(dummyPed)
    SetEntityAsMissionEntity(tablet, true, true)
    DeleteObject(tablet)

    lib.hideTextUI()
    dealerShown = false
    tablet = 0
    dummyPed = 0
    displayVehicle = 0
end

local function testDrive(model)
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(model))
    local labelName = GetLabelText(GetDisplayNameFromVehicleModel(model))
    local testDriveSpawnCoords = vec3(-44.88, -1082.68, 26.69)

    if makeName == 'NULL' then makeName = '' end

    TriggerServerEvent('ND_Dealership:setTestDriveBucket', false)

    Wait(500)

    testDriveVehicle = CreateVehicle(model, testDriveSpawnCoords.x, testDriveSpawnCoords.y, testDriveSpawnCoords.z, 67.59, true, true)
    repeat Wait(0) until DoesEntityExist(testDriveVehicle)

    SetVehRadioStation(testDriveVehicle, 'OFF')
    SetVehicleNumberPlateText(testDriveVehicle, 'DEALER')
    SetVehicleNumberPlateTextIndex(testDriveVehicle, 4)
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

    lib.showTextUI('[F] End Test-Drive')

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

        -- F key (end test-drive)
        if IsControlJustPressed(0, 49) then
            lib.notify({
                title = 'Test-Drive Ended',
                position = 'top',
                icon = 'vial',
                description = 'You\'ve prematurely ended your test-drive of the ' .. makeName .. ' ' .. labelName .. '.',
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

    TriggerServerEvent('ND_Dealership:setTestDriveBucket', true)

    lib.hideTextUI()

    SetEntityAsMissionEntity(testDriveVehicle, true, true)
    DeleteVehicle(testDriveVehicle)
    SetEntityCoords(cache.ped, -40.51, -1080.91, 26.63, false, false, false, false)
    SetEntityHeading(cache.ped, 72.07)

    onTestDrive = false
    testDriveVehicle = 0
    testVehicleCoords = vec3(0, 0, 0)
    distance = 0
end

local function purchaseVehicle(model, price)
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(model))
    local labelName = GetLabelText(GetDisplayNameFromVehicleModel(model))

    if makeName == 'NULL' then makeName = '' end

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
        if inGarage == nil then inGarage = false end

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
                description = 'You purchased a '.. makeName .. ' ' .. labelName .. ' for $' .. price .. ' (' .. oldBalance .. ' -> ' .. newBalance .. '). ' .. (inGarage and 'It has been sent to your garage.' or 'It has spawned outside.'),
                duration = 6000,
                type = 'success'
            })
        else
            lib.notify({
                title = 'Insufficent Funds',
                position = 'top',
                icon = 'car',
                description = 'You\'re short $' .. (price - oldBalance) .. ' to afford the ' .. makeName .. ' ' .. labelName .. '.',
                duration = 4500,
                type = 'error'
            })
        end
    end
end

local function createVehicleView(model, price)
    lib.requestModel(model)

    displayVehicle = CreateVehicle(model, -44.38, -1098.05, 26.42, 248.96, false, false)
    repeat Wait(0) until DoesEntityExist(displayVehicle)
    ClearArea(-44.38, -1098.05, 26.42, 10.0, true, false, true, false)
    SetVehicleNumberPlateText(displayVehicle, 'DEALER')
    SetVehicleNumberPlateTextIndex(displayVehicle, 4)
    SetModelAsNoLongerNeeded(model)

    local returnCoords = GetEntityCoords(cache.ped)

    dummyPed, tablet = spawnClonePed()
    SetEntityHeading(dummyPed, 255.23)
    SetEntityVisible(cache.ped, false, false)
    FreezeEntityPosition(displayVehicle, true)
    SetVehicleEngineOn(displayVehicle, true, true, true)
    SetVehRadioStation(displayVehicle, 'OFF')
    SetPedIntoVehicle(cache.ped, displayVehicle, -1)
    SetEntityCollision(displayVehicle, false, false)
    SetGameplayCamRelativeRotation(155.0, 20.0, 0.0)
    vehicleView = true

    lib.showTextUI('[ENTER] Purchase ($' .. price .. ')  ' .. (Config.testDriveEnabled and '\n[G] Test-Drive' or ' ') .. '  \n[F] Exit')

    while vehicleView do
        Wait(0)

        DisableControlAction(1, 0, true) -- V: change view
        DisableControlAction(1, 80, true) -- R: cinematic cam
        DisableControlAction(1, 75, true) -- F: Vehicle exit

        -- V key change view
        if IsDisabledControlJustPressed(0, 0) then
            local viewTypes = {
                [0] = 4,
                [1] = 4,
                [2] = 4,
                [3] = 4,
                [4] = 0
            }
            local view = GetFollowPedCamViewMode()
            if viewTypes[view] ~= nil then
                SetFollowVehicleCamViewMode(viewTypes[view])
                SetGameplayCamRelativeHeading(0.0)
            end
        end

        if Config.testDriveEnabled then
            -- G key (test-drive)
            if IsControlJustPressed(0, 113) then
                cleanupVehicleView(returnCoords)
                testDrive(model)
                vehicleView = false
            end
        end

        if IsControlJustPressed(0, 191) then -- ENTER key (purchase)
            cleanupVehicleView(returnCoords)
            purchaseVehicle(model, price)
            vehicleView = false
        end

        if IsDisabledControlJustPressed(0, 75) then -- F key (exit)
            cleanupVehicleView(returnCoords)
            vehicleView = false
        end
    end
end

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
            createVehicleView(Config.vehicles[args.category][i].model, Config.vehicles[args.category][i].price)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource ~= resourceName then return end

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

    TriggerServerEvent('ND_Dealership:setTestDriveBucket', true)

    lib.hideMenu()
    lib.hideTextUI()
    if worker > 0 then
        print('Deleting dealership worker: ' .. worker)
        DeletePed(worker)
    end

    if displayVehicle > 0 then
        print('Deleting display vehicle: ' .. displayVehicle)
        DeleteVehicle(displayVehicle)
    end

    if cellphone > 0 then
        print('Deleting cellphone: ' .. cellphone)
        SetEntityAsMissionEntity(cellphone, true, true)
        DeleteObject(cellphone)
    end

    if testDriveVehicle > 0 then
        print('Deleting test-drive vehicle: ' .. testDriveVehicle)
        SetEntityAsMissionEntity(testDriveVehicle, true, true)
        DeleteVehicle(testDriveVehicle)
    end

    if dummyPed > 0 then
        print('Deleting dummy ped: ' .. dummyPed)
        DeletePed(dummyPed)
    end

    if tablet > 0 then
        print('Deleting tablet: ' .. tablet)
        SetEntityAsMissionEntity(tablet, true, true)
        DeleteObject(tablet)
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
                if notified and not vehicleView then
                    notified = false
                    lib.hideTextUI()
                end
                sleep = 500
            end
        elseif worker > 0 then
            print('Deleting dealership worker: ' .. worker)
            DeletePed(worker)
            worker = 0
        end

        Wait(sleep)
    end
end)
local random = math.random

function jobHasAccess(job, info)
    if not info.jobs then return true end
    for _, jobName in pairs(info.jobs) do
        if job == jobName then return true end
    end
    return false
end

function spawnWorker(info)
    lib.requestModel(info.pedModel)
    lib.requestAnimDict('anim@amb@casino@valet_scenario@pose_d@')
    local worker = CreatePed(4, info.pedModel, info.pedCoords.x, info.pedCoords.y, info.pedCoords.z - 0.8, info.pedCoords.w, false, false)

    if info.pedModel == `cs_siemonyetarian` then
        SetPedComponentVariation(worker, 3, 0, random(0, 1), 0) -- hands
    end

    SetPedCanBeTargetted(worker, false)
    SetPedCanRagdoll(worker, false)
    SetEntityCanBeDamaged(worker, false)
    SetBlockingOfNonTemporaryEvents(worker, true)
    SetPedCanRagdollFromPlayerImpact(worker, false)
    SetPedResetFlag(worker, 249, true)
    SetPedConfigFlag(worker, 185, true)
    SetPedConfigFlag(worker, 108, true)
    SetPedConfigFlag(worker, 208, true)

    TaskPlayAnim(worker, "anim@amb@casino@valet_scenario@pose_d@", "base_a_m_y_vinewood_01", 2.0, 8.0, -1, 1, 0, false, false, false)
    RemoveAnimDict('anim@amb@casino@valet_scenario@pose_d@')
    SetModelAsNoLongerNeeded(info.pedModel)

    return worker
end

function spawnClonePed()
    local dummyPed = ClonePed(cache.ped, true, false, true)
    lib.requestModel(`prop_cs_tablet`)
    lib.requestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')

    SetPedCanBeTargetted(dummyPed, false)
    SetPedCanRagdoll(dummyPed, false)
    SetEntityCanBeDamaged(dummyPed, false)
    SetBlockingOfNonTemporaryEvents(dummyPed, true)
    SetPedCanRagdollFromPlayerImpact(dummyPed, false)
    SetPedResetFlag(dummyPed, 249, true)
    SetPedConfigFlag(dummyPed, 185, true)
    SetPedConfigFlag(dummyPed, 108, true)
    SetPedConfigFlag(dummyPed, 208, true)

    local bone = GetPedBoneIndex(dummyPed, 26610)
    local tablet = CreateObject(`prop_cs_tablet`, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(tablet, dummyPed, bone, 0.15, -0.03, 0.0075, 180.0, -20.0, 0.0, true, false, false, false, 2, true)
    TaskPlayAnim(dummyPed, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base', 8.0, 8.0, -1, 49, 0, false, false, false)

    RemoveAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    SetModelAsNoLongerNeeded(`prop_cs_tablet`)

    return dummyPed, tablet
end

function getDealerVehicles(category)
    local values = {}

    for _, categoryVeh in pairs(category) do
        if not IsModelInCdimage(categoryVeh.model) or not IsModelAVehicle(categoryVeh.model) then
            print(('^3Hash: %s isn\'t in the game\'s CD image or isn\'t a vehicle at all. If this is a valid vehicle model hash you may need to update your server\'s game build. Skipping^0.'):format(categoryVeh.model))
            goto skip
        end

        if categoryVeh.label then
            values[#values + 1] = categoryVeh.label
        else
            local make = GetLabelText(GetMakeNameFromVehicleModel(categoryVeh.model))
            local model = GetLabelText(GetDisplayNameFromVehicleModel(categoryVeh.model))

            if make ~= 'NULL' then
                values[#values+1] = make .. ' ' .. model
            else
                values[#values+1] = model
            end
        end

        :: skip ::
    end
    return values
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    local iter = function ()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function sort(tableToSort)
    local t = {}
    for k, v in pairsByKeys(tableToSort) do
        table.insert(t, {category = k, vehicles = v})
    end
    return t
end

function getDealerMenu(categories)
    local options = {}
    local vehiclesTable = {}

    for _, category in pairs(categories) do
        vehiclesTable[category] = Config.vehicles[category]
    end

    local vehicles = sort(vehiclesTable)

    for _, vehiclesStuff in pairs(vehicles) do
        options[#options + 1] = {
            icon = 'car',
            label = vehiclesStuff.category,
            values = getDealerVehicles(vehiclesStuff.vehicles),
            args = {category = vehiclesStuff.category}
        }
    end
    return options
end

function cleanupVehicleView(returnCoords)
    SetEntityHeading(cache.ped, 255.23)
    SetEntityCoords(cache.ped, returnCoords.x, returnCoords.y, returnCoords.z - 1.0, false, false, false, false)
    SetEntityVisible(cache.ped, true, true)
    UnpinInterior(25090)
    DeleteVehicle(displayVehicle)
    DeletePed(dummyPed)
    SetEntityAsMissionEntity(tablet, true, false)
    DeleteObject(tablet)

    lib.hideTextUI()
    dealerShown = false
    tablet = 0
    dummyPed = 0
    displayVehicle = 0
end

function testDrive(model)
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(model))
    local labelName = GetLabelText(GetDisplayNameFromVehicleModel(model))
    local returnCoords, returnHeading = GetEntityCoords(cache.ped), GetEntityHeading(cache.ped)
    if makeName == 'NULL' then makeName = '' end

    PinInteriorInMemory(285697)
    repeat Wait(0) until IsInteriorReady(285697)

    TriggerServerEvent('ND_Dealership:setTestDriveBucket', false)

    Wait(500)

    testDriveVehicle = CreateVehicle(model, currentDealer.testDriveLocation.x, currentDealer.testDriveLocation.y, currentDealer.testDriveLocation.z, currentDealer.testDriveLocation.w, true, true)
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

        Wait(0)
    end

    TriggerServerEvent('ND_Dealership:setTestDriveBucket', true)

    lib.hideTextUI()

    DeleteVehicle(testDriveVehicle)
    SetEntityCoords(cache.ped, returnCoords.x, returnCoords.y, returnCoords.z - 0.3, false, false, false, false)
    SetEntityHeading(cache.ped, returnHeading)
    UnpinInterior(285697)

    onTestDrive = false
    testDriveVehicle = 0
    testVehicleCoords = vec3(0, 0, 0)
    distance = 0
end

function purchaseVehicle(model, price)
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
        
        if not IsModelInCdimage(model) then return end
        RequestModel(model)
        repeat Wait(10) until HasModelLoaded(model)
        local tempVeh = CreateVehicle(model, 0.0, 0.0, 0.0, 0.0, false, true)
        local props = lib.getVehicleProperties(tempVeh)
        props.class = GetVehicleClass(tempVeh)
        DeleteVehicle(tempVeh)

        local selectedCharacter = NDCore.Functions.GetSelectedCharacter()

        local oldBalance = method == 'cash' and selectedCharacter.cash or selectedCharacter.bank

        if oldBalance >= price then
            TriggerServerEvent('ND_Dealership:purchaseVehicle', props, inGarage, method, currentDealerName)

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

function createVehicleView(model, price)
    lib.requestModel(model)
    PinInteriorInMemory(25090)
    repeat Wait(0) until IsInteriorReady(25090)

    displayVehicle = CreateVehicle(model, currentDealer.displayLocation.x, currentDealer.displayLocation.y, currentDealer.displayLocation.z-0.4, currentDealer.displayLocation.w, false, true)
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

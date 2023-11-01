local testdrive = {
    active = false,
}

local function endTestDrive()
    testdrive.active = false
    CreateThread(function()
        DoScreenFadeOut(1500)
        Wait(1500)
        TriggerServerEvent("ND_Dealership:exitTestDrive")
        Wait(1500)
        DoScreenFadeIn(1500)
    end)
end

local function setupClonedPed(ped)
    ClonePedToTarget(cache.ped, ped)
    SetPedCanBeTargetted(ped, false)
    SetPedCanRagdoll(ped, false)
    SetEntityCanBeDamaged(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedResetFlag(ped, 249, true)
    SetPedConfigFlag(ped, 185, true)
    SetPedConfigFlag(ped, 108, true)
    SetPedConfigFlag(ped, 208, true)
end

local function getEntityFromNetId(netId)
    local time = GetCloudTimeAsInt()
    while not NetworkDoesNetworkIdExist(netId) and GetCloudTimeAsInt()-time < 5 do
        Wait(10)
    end
    return NetworkGetEntityFromNetworkId(netId)
end

function testdrive.start(data)
    local alert = lib.alertDialog({
        header = "Vehicle test drive",
        content = "Start a test drive with this vehicle?  \nYou can leave the test drive at any time.",
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then return end

    testdrive.active = true
    DoScreenFadeOut(1500)
    Wait(1500)

    local _, dealer = Showroom.getVehicleData(data.entity)
    local pedNetId, tabletNetId = lib.callback.await("ND_Dealership:setupTestDrive", nil, GetEntityModel(cache.ped), dealer)
    if not pedNetId or not tabletNetId then return end
    local fakePed, tablet = getEntityFromNetId(pedNetId), getEntityFromNetId(tabletNetId)

    if fakePed then
        setupClonedPed(fakePed)
        AttachEntityToEntity(tablet, fakePed, GetPedBoneIndex(fakePed, 26610), 0.15, -0.03, 0.0075, 180.0, -20.0, 0.0, true, false, false, false, 2, true)

        lib.requestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
        TaskPlayAnim(fakePed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 8.0, 8.0, -1, 49, 0, false, false, false)
        Wait(1500)
    end

    TriggerServerEvent("ND_Dealership:startTestDrive", lib.getVehicleProperties(data.entity), dealer)
end

function testdrive.enterZone(self)
    if not testdrive.active then return end
    SetTimeout(500, function()
        if cache.vehicle then
            SetVehicleOnGroundProperly(cache.vehicle)
            SetVehicleDoorsLocked(cache.vehicle, 4)
            SetGameplayCamRelativeHeading(0)

            local int = GetInteriorAtCoords(self.coords)
            RefreshInterior(int)
        end
        Wait(1000)
        DoScreenFadeIn(1500)
    end)
    Wait(1500)
    lib.showTextUI("[F] - Leave test drive", {
        icon = "person-walking-arrow-right"
    })
end

function testdrive.exitZone(self)
    lib.hideTextUI()
    if testdrive.active then
        if cache.vehicle then
            BringVehicleToHalt(cache.vehicle, 1.0, 500, true)
        end
        endTestDrive()
    end
end

function testdrive.insideZone(self)
    if testdrive.active and IsControlJustPressed(0, 75) then
        endTestDrive()
    end
end

return testdrive
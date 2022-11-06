local random = math.random

function spawnWorker(location)
    lib.requestModel(`cs_siemonyetarian`)
    lib.requestModel(`prop_v_m_phone_01`)
    lib.requestAnimDict('anim@amb@nightclub@peds@')
    local worker = CreatePed(4, `cs_siemonyetarian`, location.x, location.y, location.z - 0.8, location.w, false, false)
    local bone = GetPedBoneIndex(worker, 28422)

    SetPedComponentVariation(worker, 3, 0, random(0, 1), 0) -- hands

    SetPedCanBeTargetted(worker, false)
    SetPedCanRagdoll(worker, false)
    SetEntityCanBeDamaged(worker, false)
    SetBlockingOfNonTemporaryEvents(worker, true)
    SetPedCanRagdollFromPlayerImpact(worker, false)
    SetPedResetFlag(worker, 249, true)
    SetPedConfigFlag(worker, 185, true)
    SetPedConfigFlag(worker, 108, true)
    SetPedConfigFlag(worker, 208, true)

    TaskPlayAnim(worker, 'anim@amb@nightclub@peds@', 'amb_world_human_leaning_male_wall_back_mobile_idle_a', 2.0, 8.0, -1, 1, 0, false, false, false)

    local cellphone = CreateObject(`prop_v_m_phone_01`, 0.0, 0.0, 0.0, true, false, false)
    AttachEntityToEntity(cellphone, worker, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)

    RemoveAnimDict('anim@amb@nightclub@peds@')
    SetModelAsNoLongerNeeded(`cs_siemonyetarian`)
    SetModelAsNoLongerNeeded(`prop_v_m_phone_01`)

    return worker, cellphone
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
    local tablet = CreateObject(`prop_cs_tablet`, 0.0, 0.0, 0.0, true, false, false)
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
            print('^3Hash: ' .. categoryVeh.model .. ' isn\'t in the game\'s CD image or isn\'t a vehicle at all. If this is a valid vehicle model hash you may need to update your server\'s game build. Skipping^0.')
            goto skip
        end

        local make = GetLabelText(GetMakeNameFromVehicleModel(categoryVeh.model))
        local model = GetLabelText(GetDisplayNameFromVehicleModel(categoryVeh.model))

        if make ~= 'NULL' then
            values[#values+1] = make .. ' ' .. model
        else
            values[#values+1] = model
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

function getDealerMenu()
    local options = {}
    local vehiclesTable = sort(Config.vehicles)

    for _, vehiclesStuff in pairs(vehiclesTable) do
        options[#options+1] = {
            icon = 'car',
            label = vehiclesStuff.category,
            values = getDealerVehicles(vehiclesStuff.vehicles),
            args = {category = vehiclesStuff.category}
        }
    end
    return options
end
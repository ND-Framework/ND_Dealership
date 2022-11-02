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

    SetModelAsNoLongerNeeded(`cs_siemonyetarian`)
    SetModelAsNoLongerNeeded(`prop_v_m_phone_01`)

    return worker, cellphone
end

function getDealerVehicles(category)
    local values = {}

    for _, categoryVeh in pairs(category) do
        local make = GetLabelText(GetMakeNameFromVehicleModel(categoryVeh.model))
        local model = GetLabelText(GetDisplayNameFromVehicleModel(categoryVeh.model))

        if not IsModelInCdimage(categoryVeh.model) or not IsModelAVehicle(categoryVeh.model) then
            print('^3Hash: ' .. categoryVeh.model .. ' - ' .. (model ~= 'NULL' and model .. ' ' or '') .. 'isn\'t in the game\'s CD image or isn\'t a vehicle. If this is a valid vehicle model hash you may need to update your server\'s game build. Skipping^0.')
            goto skip
        end

        if make ~= 'NULL' then
            values[#values+1] = make .. ' ' .. model
        else
            values[#values+1] = model
        end

        :: skip ::
    end
    return values
end

function getDealerMenu()
    local options = {}

    for category, vehicles in pairs(Config.vehicles) do
        options[#options+1] = {
            icon = 'car',
            label = category,
            values = getDealerVehicles(vehicles),
            args = {category = category}
        }
    end
    return options
end
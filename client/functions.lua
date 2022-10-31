local random = math.random

function spawnWorker(location)
    lib.requestModel(`cs_siemonyetarian`)
    lib.requestAnimDict('anim@amb@casino@valet_scenario@pose_d@')
    local worker = CreatePed(4, `cs_siemonyetarian`, location.x, location.y, location.z - 0.8, location.w, false, false)

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

    TaskPlayAnim(worker, 'anim@amb@casino@valet_scenario@pose_d@', 'base_a_m_y_vinewood_01', 2.0, 8.0, -1, 1, 0, false, false, false)
    return worker
end
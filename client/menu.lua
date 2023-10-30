local data = {
    dealerships = require "data.dealerships",
    vehicles = require "data.vehicles"
}

local function pairsByKeys(t, f)
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

local function sort(tableToSort)
    local t = {}
    for k, v in pairsByKeys(tableToSort) do
        table.insert(t, {
            category = k,
            vehicles = v
        })
    end
    return t
end

local function getVehicleLabel(model)
    local make = GetLabelText(GetMakeNameFromVehicleModel(model))
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if make == "NULL" then
        return name
    elseif name == "NULL" then
        return make
    end
    return ("%s %s"):format(make, name)
end

local function getDealerVehicles(categoryVehicles)
    local values = {}
    for i=1, #categoryVehicles do
        local vehicleInfo = categoryVehicles[i]
        local model = vehicleInfo.model
        if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
            local text = ("^3Vehicle model '%s' wasn't found, this could be because it isn't a vehicle or doesn't exist on your current game build."):format(model)
            print(text)
            goto skip
        end

        if vehicleInfo.label then
            values[#values+1] = vehicleInfo.label
        else
            values[#values+1] = getVehicleLabel(model)
        end
        ::skip::
    end
    return values
end

local function getDealerMenu(categories)
    local options = {}
    local categoryVehicles = {}
    for _, category in pairs(categories) do
        categoryVehicles[category] = data.vehicles[category]
    end

    local vehicles = sort(categoryVehicles)
    for _, vehicleInfo in ipairs(vehicles) do
        options[#options+1] = {
            icon = 'car',
            label = vehicleInfo.category,
            values = getDealerVehicles(vehicleInfo.vehicles),
            args = {category = vehicleInfo.category}
        }
    end
    return options
end

for dealership, dealerInfo in pairs(data.dealerships) do
    local info = {
        id = ("ND_Dealership:%s"):format(dealership),
        title = dealership,
        position = "top-right",
        options = getDealerMenu(dealerInfo.categories)
    }
    lib.registerMenu(info, function(_, scrollIndex, args)
        local category = args.category
        local categoryVehicles = data.vehicles[category]
        for i=1, #categoryVehicles do
            if i == scrollIndex then
                lib.hideMenu()
                local info = categoryVehicles[i]
                TriggerEvent("ND_Dealership:menuItemSelected", {
                    dealership = dealership,
                    category = category,
                    index = scrollIndex,
                    price = info.price,
                    model = info.model,
                    info = info,
                    menuType = data.menuShowType
                })
            end
        end
    end)
end

function data.show(dealer, showType)
    data.menuShowType = showType
    local dealerMenu = ("ND_Dealership:%s"):format(dealer)
    lib.showMenu(dealerMenu)
end

return data
local QBCore = exports['qb-core']:GetCoreObject()

local function GenerateCustomPlate()
    local plate = ""; local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; local nums = "0123456789"
    for i = 1, 3 do plate = plate .. chars:sub(math.random(1, #chars), math.random(1, #chars)) end; plate = plate .. " "
    for i = 1, 3 do plate = plate .. nums:sub(math.random(1, #nums), math.random(1, #nums)) end; return plate:upper()
end

local function GivePlayerItems(source, items)
    local Player = QBCore.Functions.GetPlayer(source)
    local itemsGiven = {}
    
    for _, itemData in ipairs(items) do
        local itemAdded = false
        if Config.Inventory == 'qb' then
            itemAdded = Player.Functions.AddItem(itemData.name, itemData.amount, itemData.slot, itemData.metadata)
        elseif Config.Inventory == 'ox' then
            local result = exports.ox_inventory:AddItem(source, itemData.name, itemData.amount, itemData.metadata)
            itemAdded = result ~= false
        end

        if itemAdded then
            table.insert(itemsGiven, itemData)
        else
            for _, givenItem in ipairs(itemsGiven) do
                if Config.Inventory == 'qb' then
                    Player.Functions.RemoveItem(givenItem.name, givenItem.amount, givenItem.slot)
                elseif Config.Inventory == 'ox' then
                    exports.ox_inventory:RemoveItem(source, givenItem.name, givenItem.amount)
                end
            end
            return { success = false, itemsGiven = {} }
        end
    end
    return { success = true, itemsGiven = itemsGiven }
end

RegisterNetEvent('ap_starterpack:server:beriPaket', function(vehicleModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.metadata['has_claimed_starterpack'] then return end
    
    local itemResult = GivePlayerItems(src, Config.StarterPack.Items)

    if itemResult.success then
        if Config.StarterPack.Money.cash > 0 then Player.Functions.AddMoney('cash', Config.StarterPack.Money.cash, 'claimed-starterpack') end
        if Config.StarterPack.Money.bank > 0 then Player.Functions.AddMoney('bank', Config.StarterPack.Money.bank, 'claimed-starterpack') end
        
        if Config.Vehicle.enabled and vehicleModel then
            local plate = GenerateCustomPlate()
            local vehicleHash = GetHashKey(vehicleModel)
            local params = {Player.PlayerData.citizenid, vehicleModel, vehicleHash, plate, Config.Vehicle.garage}

            if Config.Vehicle.spawnMethod == 'spawn' then
                MySQL.Async.execute('INSERT INTO player_vehicles (citizenid, vehicle, hash, plate, garage, state) VALUES (?, ?, ?, ?, ?, 0)', params, function()
                    TriggerClientEvent('ap_starterpack:client:spawnVehicle', src, vehicleModel, plate)
                end)
            elseif Config.Vehicle.spawnMethod == 'garage' then
                MySQL.Async.execute('INSERT INTO player_vehicles (citizenid, vehicle, hash, plate, garage, state) VALUES (?, ?, ?, ?, ?, 1)', params)
                local vehicleLabel = QBCore.Shared.Vehicles[vehicleModel] and QBCore.Shared.Vehicles[vehicleModel].name or vehicleModel
                local garageLabel = QBCore.Shared.Garages[Config.Vehicle.garage] and QBCore.Shared.Garages[Config.Vehicle.garage].label or Config.Vehicle.garage
                TriggerClientEvent('QBCore:Notify', src, string.format(Config.Pesan.mobil_ke_garasi, vehicleLabel, plate, garageLabel), "success", 10000)
            end
        end

        Player.Functions.SetMetaData('has_claimed_starterpack', true)
        Player.Functions.Save()
        exports['ap_starterpack']:SendDiscordLog(Player, 'starter', {vehicle = vehicleModel, items = itemResult.itemsGiven, money = Config.StarterPack.Money})
        TriggerClientEvent('QBCore:Notify', src, Config.Pesan.sukses_starter, 'success', 8000)
    else 
        TriggerClientEvent('QBCore:Notify', src, Config.Pesan.inventaris_penuh, 'error', 7000)
    end
end)

local function GetRandomItemsFromPool(pool, amount)
    local rewards = {}
    local weightedPool = {}
    local totalWeight = 0

    for _, item in ipairs(pool) do
        totalWeight = totalWeight + item.chance
        table.insert(weightedPool, { item = item, weight = totalWeight })
    end

    for i = 1, amount do
        if #weightedPool == 0 then break end

        local randomWeight = math.random() * totalWeight
        local chosenIndex
        for index, data in ipairs(weightedPool) do
            if randomWeight <= data.weight then
                chosenIndex = index
                break
            end
        end

        if chosenIndex then
            local chosenItem = table.remove(weightedPool, chosenIndex).item
            table.insert(rewards, chosenItem)
            
            totalWeight = totalWeight - chosenItem.chance
            for j = chosenIndex, #weightedPool do
                weightedPool[j].weight = weightedPool[j].weight - chosenItem.chance
            end
        end
    end
    return rewards
end

local function FormatTimeLeft(seconds)
    if seconds <= 0 then return "now" end
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)

    local parts = {}
    if days > 0 then table.insert(parts, ("%d day(s)"):format(days)) end
    if hours > 0 then table.insert(parts, ("%d hour(s)"):format(hours)) end
    if minutes > 0 then table.insert(parts, ("%d minute(s)"):format(minutes)) end
    
    return table.concat(parts, ", ")
end

RegisterNetEvent('ap_starterpack:server:claimWeekly', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not Config.WeeklyClaim.enabled then return end

    local cooldownSeconds = Config.WeeklyClaim.cooldown_days * 24 * 60 * 60
    local nextClaimTime = Player.PlayerData.metadata['next_weekly_claim'] or 0
    local currentTime = os.time()

    if currentTime < nextClaimTime then
        local message = FormatTimeLeft(nextClaimTime - currentTime)
        TriggerClientEvent('QBCore:Notify', src, Config.Pesan.tunggu_weekly .. message, "error", 7000)
        return
    end

    local rewards = GetRandomItemsFromPool(Config.WeeklyClaim.RewardPool, Config.WeeklyClaim.itemsToGive)
    if #rewards == 0 then return end 

    local itemResult = GivePlayerItems(src, rewards)

    if itemResult.success then
        Player.Functions.SetMetaData('next_weekly_claim', currentTime + cooldownSeconds)
        Player.Functions.Save()
        local itemNames = {}
        for _, item in ipairs(itemResult.itemsGiven) do
            table.insert(itemNames, ("%dx %s"):format(item.amount, QBCore.Shared.Items[item.name].label))
        end
        TriggerClientEvent('ap_starterpack:client:notifyWeeklyItems', src, itemNames)
        
        exports['ap_starterpack']:SendDiscordLog(Player, 'weekly', {items=itemResult.itemsGiven})
    else
        TriggerClientEvent('QBCore:Notify', src, Config.Pesan.inventaris_penuh, "error", 7000)
    end
end)
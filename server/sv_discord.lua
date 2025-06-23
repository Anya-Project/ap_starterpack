local QBCore = exports['qb-core']:GetCoreObject()

local function SendToDiscord(playerData, claimType, data)
    if not Config.Discord.enabled or not Config.Discord.webhook or Config.Discord.webhook == "" then return end
    if not playerData or not data then
        print('^1[ap_starterpack] [Discord ERROR] Missing playerData or data to log.^7')
        return
    end

    local embedConfig = Config.Discord.embeds[claimType]
    if not embedConfig then return end
    local charinfo = playerData.PlayerData.charinfo
    local playerName = (charinfo and charinfo.firstname and charinfo.lastname and (charinfo.firstname .. " " .. charinfo.lastname)) or "Unknown Player"
    local citizenId = playerData.PlayerData.citizenid or "N/A"
    local license = playerData.PlayerData.license or "N/A"
    local fields = {
        { name = "Character Name", value = playerName, inline = true },
        { name = "Citizen ID", value = citizenId, inline = true },
        { name = "Account License", value = "||" .. license .. "||", inline = false }
    }

    local description = ("**%s** has just claimed their %s reward."):format(playerName, claimType)

    if data.money and (type(data.money.cash) == 'number' or type(data.money.bank) == 'number') then
        local cash = data.money.cash or 0
        local bank = data.money.bank or 0
        if cash > 0 or bank > 0 then
            local moneyString = string.format("Cash: **$%d** | Bank: **$%d**", cash, bank)
            table.insert(fields, { name = "💰 Money Received", value = moneyString, inline = false })
        end
    end
    if data.vehicle and data.vehicle ~= "" then
        local vehicleLabel = (QBCore.Shared.Vehicles[data.vehicle] and QBCore.Shared.Vehicles[data.vehicle].name) or data.vehicle
        table.insert(fields, { name = "🚗 Vehicle Received", value = vehicleLabel, inline = false })
    end

    if data.items and #data.items > 0 then
        local itemString = ""
        for _, itemData in ipairs(data.items) do
            if itemData and itemData.name and itemData.amount then
                local itemLabel = (QBCore.Shared.Items[itemData.name] and QBCore.Shared.Items[itemData.name].label) or itemData.name
                itemString = itemString .. ("- %dx %s\n"):format(itemData.amount, itemLabel)
            end
        end

        if itemString ~= "" then
            table.insert(fields, { name = "📦 Items Received", value = "```\n" .. itemString .. "```", inline = false })
        end
    end

    local embed = {
        {
            title = embedConfig.title,
            description = description,
            type = "rich",
            color = embedConfig.color,
            fields = fields,
            footer = { text = "Server Log | ap_starterpack" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
    }

    PerformHttpRequest(Config.Discord.webhook, function(err, text, headers)
        if err == 204 or err == 200 then
            print('^2[ap_starterpack] Discord log sent successfully.^7')
        else
            print('^1[ap_starterpack] Failed to send Discord log. Error code: ' .. tostring(err) .. '^7')
            print('^1[ap_starterpack] Response text: ' .. tostring(text) .. '^7')
        end
    end, 'POST', json.encode({ username = "Server Logs", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

exports('SendDiscordLog', SendToDiscord)
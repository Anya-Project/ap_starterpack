local QBCore = nil
local npcPed = nil
local isPlayerLoaded = false

function Cleanup()
    print('[ap_starterpack] Cleaning up resources for restart/stop...')
    if npcPed and DoesEntityExist(npcPed) then
        print('[ap_starterpack] Deleting existing NPC.')
        DeleteEntity(npcPed)
        npcPed = nil
    end
    exports['qb-target']:RemoveTargetModel(Config.NPC.model, { Config.Target.label, Config.Target.label_weekly })
    print('[ap_starterpack] Cleanup complete.')
end

function StartLogic()
    if not isPlayerLoaded then
        print('[ap_starterpack] StartLogic called, but player is not loaded yet. Waiting...')
        return
    end
    print('[ap_starterpack] StartLogic called. Player is loaded. Initializing...')
    Cleanup()
    Initialize()
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    print('[ap_starterpack] Resource started.')
    QBCore = exports['qb-core']:GetCoreObject()
    if QBCore.Functions.GetPlayerData().citizenid then
        print('[ap_starterpack] Player already in-game during resource start.')
        isPlayerLoaded = true
        StartLogic()
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    Cleanup()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    print('[ap_starterpack] QBCore:Client:OnPlayerLoaded event received.')
    isPlayerLoaded = true
    QBCore = exports['qb-core']:GetCoreObject()
    StartLogic()
end)

function Initialize()
    print('[ap_starterpack] Initialize() function called.')
    SpawnNPC()
    AddTarget()
    print('[ap_starterpack] Initialization COMPLETE.')
end

      
function SpawnNPC()
    print('[ap_starterpack] SpawnNPC() function called.')
    local model = Config.NPC.model
    local coords = Config.NPC.coords

    if npcPed and DoesEntityExist(npcPed) then
        DeleteEntity(npcPed)
        npcPed = nil
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(5)
    end
    print('[ap_starterpack] [DEBUG] Model ' .. model .. ' loaded.')

    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 20.0, false)

    local spawnZ
    if foundGround then

        spawnZ = groundZ
        print('[ap_starterpack] [SUCCESS] Ground found. Using precise Z-coordinate: ' .. spawnZ)
    else
        spawnZ = coords.z
        print('[ap_starterpack] [WARNING] Could not find ground. Using config Z-coordinate: ' .. spawnZ .. '. NPC may float.')
    end
    npcPed = CreatePed(4, model, coords.x, coords.y, spawnZ, coords.w, false, true)
    if not DoesEntityExist(npcPed) then
        print('^1[ap_starterpack] [FATAL ERROR] Failed to create ped entity even with a valid Z coordinate. Aborting.^7')
        return
    end
    FreezeEntityPosition(npcPed, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)

    if Config.NPC.animDict and Config.NPC.anim then
        TaskPlayAnim(npcPed, Config.NPC.animDict, Config.NPC.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    print('[ap_starterpack] NPC setup complete with Ped ID: ' .. npcPed)
end
function AddTarget()
    print('[ap_starterpack] AddTarget() function called.')
    exports['qb-target']:AddTargetModel(Config.NPC.model, {
        options = {
            {
                type = 'client',
                event = 'ap_starterpack:client:showRules',
                icon = Config.Target.icon,
                label = Config.Target.label,
                canInteract = function()
                    local currentData = QBCore.Functions.GetPlayerData()
                    return isPlayerLoaded and not currentData.metadata['has_claimed_starterpack']
                end
            },
            {
                type = 'server',
                event = 'ap_starterpack:server:claimWeekly',
                icon = Config.Target.icon_weekly,
                label = Config.Target.label_weekly,
                canInteract = function()
                    if not Config.WeeklyClaim.enabled then return false end
                    local currentData = QBCore.Functions.GetPlayerData()
                    return isPlayerLoaded and currentData.metadata['has_claimed_starterpack']
                end
            },
        },
        distance = 2.5,
    })
    print('[ap_starterpack] AddTargetModel function executed.')
end

function PlayClaimAnimation()
    local playerPed = PlayerPedId()
    if npcPed and DoesEntityExist(npcPed) then
        ClearPedTasks(npcPed)
        TaskTurnPedToFaceEntity(npcPed, playerPed, 500)
        Wait(500)
    end
    FreezeEntityPosition(playerPed, true)
    local animDict = "mp_common"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    TaskPlayAnim(playerPed, animDict, "givetake1_a", 8.0, -8.0, 1500, 49, 0, false, false, false)

    if npcPed and DoesEntityExist(npcPed) then
        TaskPlayAnim(npcPed, animDict, "givetake1_a", 8.0, -8.0, 1500, 48, 0, false, false, false)
    end
    PlaySoundFrontend(-1, "LOCAL_BANK_UPDATE", "DLC_HEIST_FINALE_SOUNDSET", true)
    Wait(1500)
    ClearPedTasks(playerPed)
    if npcPed and DoesEntityExist(npcPed) then
        if Config.NPC.animDict and Config.NPC.anim then
            TaskPlayAnim(npcPed, Config.NPC.animDict, Config.NPC.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        else
            ClearPedTasks(npcPed)
        end
    end
    FreezeEntityPosition(playerPed, false)
end
     
function ChooseVehicle()
    local vehicleOptions = Config.Vehicle.options
    
    if not vehicleOptions or #vehicleOptions == 0 then
        print('^1[ap_starterpack] ERROR: Config.Vehicle.options is missing!^7')
        return
    end

    if #vehicleOptions == 1 then
        local result = exports.ox_lib:alertDialog({
            header = 'Confirm Vehicle Choice',
            content = 'You will receive the **' .. vehicleOptions[1].label .. '**. This choice is final. Are you sure?',
            centered = true,
            cancel = true, -- Ini juga penting di sini
            labels = { confirm = "Yes, I'm Sure", cancel = "Cancel Claim" }
        })
        if result == 'confirm' then
            PlayClaimAnimation()
            QBCore.Functions.Notify(Config.Pesan.terima_kasih_setuju, "success", 7000)
            TriggerServerEvent('ap_starterpack:server:beriPaket', vehicleOptions[1].model)
        else
            QBCore.Functions.Notify("Claim cancelled.", "error")
        end
        return
    end

    local currentIndex = 1

    local function showNextOption()
        if not vehicleOptions[currentIndex] then
            QBCore.Functions.Notify("Claim cancelled. You can try again by talking to the NPC.", "error")
            return
        end

        local currentVehicle = vehicleOptions[currentIndex]

        local result = exports.ox_lib:alertDialog({
            header = 'Vehicle Choice (' .. currentIndex .. '/' .. #vehicleOptions .. ')',
            content = 'Would you like to claim the **' .. currentVehicle.label .. '**?',
            centered = true,
            cancel = true,
            labels = {
                confirm = "Yes, Claim This One!",
                cancel = "No, Show Next Option"
            }
        })

        if result == 'confirm' then
            local confirmResult = exports.ox_lib:alertDialog({
                header = 'Final Confirmation',
                content = 'Are you sure you want the **' .. currentVehicle.label .. '**? This choice cannot be undone.',
                centered = true,
                cancel = true,
                labels = { confirm = "Yes, I\'m Sure", cancel = "No, Go Back" }
            })

            if confirmResult == 'confirm' then
                PlayClaimAnimation()
                QBCore.Functions.Notify(Config.Pesan.terima_kasih_setuju, "success", 7000)
                TriggerServerEvent('ap_starterpack:server:beriPaket', currentVehicle.model)
            else
                showNextOption() 
            end
        else
            currentIndex = currentIndex + 1
            showNextOption()
        end
    end

    showNextOption()
end

RegisterNetEvent('ap_starterpack:client:showRules', function()
    local result = exports.ox_lib:alertDialog({
        header = Config.Rules.header,
        content = Config.Rules.text,
        centered = true,
        cancel = true,
        labels = { confirm = Config.Rules.button.submit, cancel = Config.Rules.button.cancel }
    })
    if result == 'confirm' then
        if Config.Vehicle.enabled and #Config.Vehicle.options > 1 then
            ChooseVehicle()
        else
            PlayClaimAnimation()
            QBCore.Functions.Notify(Config.Pesan.terima_kasih_setuju, "success", 7000)
            local vehicleModel = nil
            if Config.Vehicle.enabled and Config.Vehicle.options[1] then
                vehicleModel = Config.Vehicle.options[1].model
            end
            TriggerServerEvent('ap_starterpack:server:beriPaket', vehicleModel)
        end
    else
        QBCore.Functions.Notify(Config.Pesan.tolak_aturan, "error")
    end
end)

RegisterNetEvent('ap_starterpack:client:spawnVehicle', function(vehicleModel, plate)
    local playerPed = PlayerPedId()
    local spawnPoint = Config.Vehicle.spawnPoint
    QBCore.Functions.Notify(Config.Pesan.mobil_disiapkan, "primary", 5000)
    QBCore.Functions.SpawnVehicle(vehicleModel, function(vehicle)
        SetVehicleNumberPlateText(vehicle, plate)
        SetEntityHeading(vehicle, spawnPoint.w)
        if Config.FuelSystem.setFuelToFull then
            local FuelHandlers = {
                ['legacy'] = function(v) if exports['LegacyFuel'] then exports['LegacyFuel']:SetFuel(v, 100.0); return true end; return false end,
                ['cdn'] = function(v) if exports['cdn-fuel'] then exports['cdn-fuel']:SetFuel(v, 100.0); return true end; return false end,
                ['ox'] = function(v) if exports.ox_fuel then Entity(v).state:set('fuel', 100, true); return true end; return false end,
                ['none'] = function(v) SetVehicleFuelLevel(v, 100.0); return true end,
            }
            local handler = FuelHandlers[Config.FuelSystem.system]
            if handler and handler(vehicle) then
                print(('[ap_starterpack] Fuel set to 100%% using %s system.'):format(Config.FuelSystem.system))
            else
                print(('[ap_starterpack] Fuel system "%s" not found or failed. Falling back to native.'):format(Config.FuelSystem.system))
                SetVehicleFuelLevel(vehicle, 100.0)
            end
        end
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
        SetVehicleEngineOn(vehicle, true, true)
        QBCore.Functions.Notify(Config.Pesan.mobil_sukses, "success", 8000)
    end, spawnPoint, true)
end)

RegisterNetEvent('ap_starterpack:client:notifyWeeklyItems', function(items)
    local itemString = table.concat(items, ", ")
    QBCore.Functions.Notify(string.format(Config.Pesan.sukses_weekly, itemString), "success", 8000)
end)


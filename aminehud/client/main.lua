local ESX = exports["es_extended"]:getSharedObject()
local isHudHidden = false
local isPaused = false

-- Use local variables for status to cache them
local currentHealth = 100
local currentArmor = 0
local currentHunger = 100
local currentThirst = 100
local currentStamina = 100

-- Vehicle vars
local currentFuel = 100
local currentSpeed = 0
local currentEngine = 1000

-- Main Loop: Update Status per frame or slow interval? 
-- Native calls are fast, but NUI messages are slow. We collect data then send.

CreateThread(function()
    while true do
        Wait(500) -- Update status every 500ms (sufficient for health/food)

        local playerPed = PlayerPedId()
        
        -- Health (0-100)
        currentHealth = GetEntityHealth(playerPed) - 100
        if currentHealth < 0 then currentHealth = 0 end
        
        -- Armor (0-100)
        currentArmor = GetPedArmour(playerPed)

        -- Stamina
        -- 0 to 100 usually (Recharging is ID 1 for stamina)
        currentStamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
        -- NOTE: GetPlayerSprintStaminaRemaining returns 100 when full? or 0? 
        -- Actually GetPlayerSprintStaminaRemaining returns % remaining.
        -- We want to show what is FILLED. So just use the value directly.
        currentStamina = GetPlayerSprintStaminaRemaining(PlayerId())

        -- Hunger/Thirst are handled by events usually, but we need to send them all together.
        
        SendNUIMessage({
            action = "updateStatus",
            health = currentHealth,
            armor = currentArmor,
            hunger = currentHunger,
            thirst = currentThirst,
            stamina = currentStamina
        })
    end
end)

-- Vehicle Loop
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            sleep = 100 -- Faster update for speed (10fps for HUD is smooth enough)
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            -- Speed
            local speed = GetEntitySpeed(vehicle)
            local speedUnit = "KMH"
            local displaySpeed = math.floor(speed * 3.6) -- KMH by default
            
            if Config.SpeedUnit == 'mph' then
                displaySpeed = math.floor(speed * 2.236936)
                speedUnit = "MPH"
            end

            -- Fuel (LegacyFuel / ox_fuel / built-in)
            -- Try GetVehicleFuelLevel first
            currentFuel = GetVehicleFuelLevel(vehicle)

            -- Engine Health
            currentEngine = GetVehicleEngineHealth(vehicle)

            SendNUIMessage({
                action = "vehicleUpdate",
                inVehicle = true,
                speed = displaySpeed,
                speedUnit = speedUnit,
                fuel = currentFuel,
                engine = currentEngine
            })
        else
            -- If we just exited, ensure we hide the car hud once
            SendNUIMessage({
                action = "vehicleUpdate",
                inVehicle = false
            })
        end

        Wait(sleep)
    end
end)

-- ESX Status Handler (Hunger/Thirst)
RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(status)
    for _, s in pairs(status) do
        if s.name == 'hunger' then
            currentHunger = s.percent
        elseif s.name == 'thirst' then
            currentThirst = s.percent
        end
    end
end)

-- Toggle HUD Command/Key
if Config.ToggleKey then
    RegisterCommand('togglehud', function()
        isHudHidden = not isHudHidden
        SendNUIMessage({
            action = "toggleHud"
        })
    end)
    RegisterKeyMapping('togglehud', 'Toggle HUD Visibility', 'keyboard', Config.ToggleKey)
end

-- Edit Mode Command/Key
if Config.EditModeCommand then
    RegisterCommand(Config.EditModeCommand, function()
        SendNUIMessage({
            action = "toggleEditMode"
        })
        SetNuiFocus(true, true)
    end)
    if Config.EditModeKey then
        RegisterKeyMapping(Config.EditModeCommand, 'Toggle HUD Edit Mode', 'keyboard', Config.EditModeKey)
    end
end

-- NUI Callbacks
RegisterNUICallback('closeEditMode', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('savePositions', function(data, cb)
    -- data is { "status-container": {top:.., left:..}, ... }
    -- We can save this to KVP (SetResourceKvp) for persistence across restarts
    for id, pos in pairs(data) do
        SetResourceKvp('aminehud_pos_'..id, json.encode(pos))
    end
    -- Note: We need to load these on start!
    cb('ok')
end)

-- Load Positions on Start (Optional, requires JS update to accept position updates)
-- For now, we rely on default CSS, but basic KVP retrieval could be added if requested.

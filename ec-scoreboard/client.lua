local QBCore = nil
local ESX = nil
local isScoreboardOpen = false
local cachedData = {
    players = {},
    jobs = {}
}
local refreshTimer = nil
local framework = 'standalone'

-- Framework detection
CreateThread(function()
    if Config.Framework == 'auto' or Config.Framework == 'qbcore' then
        if GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            framework = 'qbcore'
            print('[Scoreboard] QBCore Framework detected')
            return
        end
    end
    
    if Config.Framework == 'auto' or Config.Framework == 'esx' then
        if GetResourceState('es_extended') == 'started' then
            ESX = exports['es_extended']:getSharedObject()
            framework = 'esx'
            print('[Scoreboard] ESX Framework detected')
            return
        end
    end
    
    if framework == 'standalone' then
        print('[Scoreboard] Running in standalone mode')
    end
end)

-- Initialize and register keybinding
RegisterCommand('scoreboard', function()
    ToggleScoreboard()
end)

RegisterKeyMapping('scoreboard', 'Toggle Scoreboard', 'keyboard', Config.DefaultKey)

-- Main toggle function
function ToggleScoreboard()
    isScoreboardOpen = not isScoreboardOpen
    
    if isScoreboardOpen then
        RefreshScoreboardData()
        SendNUIMessage({
            action = "open",
            serverName = Config.ServerName,
            maxPlayers = Config.MaxPlayers,
            showJobs = Config.ShowJobsPanel
        })
        SetNuiFocus(false, false) 

        if refreshTimer then
            ClearInterval(refreshTimer)
        end
        
        refreshTimer = SetInterval(function()
            if isScoreboardOpen then
                RefreshScoreboardData()
            end
        end, Config.RefreshTime)
    else
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)
        
        -- Clear refresh timer
        if refreshTimer then
            ClearInterval(refreshTimer)
            refreshTimer = nil
        end
    end
end

-- Get fresh data from server
function RefreshScoreboardData()
    TriggerServerEvent('scoreboard:getServerData')
end

-- Receive data from server
RegisterNetEvent('scoreboard:receiveServerData')
AddEventHandler('scoreboard:receiveServerData', function(players, jobs)
    cachedData.players = players
    cachedData.jobs = jobs
    
    if isScoreboardOpen then
        SendNUIMessage({
            action = "updateData",
            players = players,
            jobs = jobs
        })
    end
end)

-- Close on ESC or TAB
RegisterNUICallback('close', function()
    if isScoreboardOpen then
        isScoreboardOpen = false
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(true, true)
        
        if refreshTimer then
            ClearInterval(refreshTimer)
            refreshTimer = nil
        end
    end
end)

-- Listen for ESC key to close scoreboard
CreateThread(function()
    while true do
        Wait(0)
        if isScoreboardOpen then
            if IsControlJustReleased(0, 200) or IsControlJustReleased(0, 73) then 
                ToggleScoreboard()
            end
        end
    end
end)

-- Helper function for timer
function SetInterval(callback, interval)
    local timer = 0
    local id = GetGameTimer()
    
    CreateThread(function()
        while timer >= 0 do
            if GetGameTimer() > timer + interval then
                callback()
                timer = GetGameTimer()
            end
            Wait(0)
        end
    end)
    
    return id
end

function ClearInterval(id)
    if id then
        timer = -1
    end
end

-- Resource cleanup
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and isScoreboardOpen then
        SetNuiFocus(false, false)
    end
end)

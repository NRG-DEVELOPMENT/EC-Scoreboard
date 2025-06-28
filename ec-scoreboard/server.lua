local ESX = nil
local QBCore = nil
local framework = 'standalone'

-- Framework detection and initialization
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

-- Get player data based on framework
function GetAllPlayers()
    local players = {}
    
    for _, playerId in ipairs(GetPlayers()) do
        local playerName = GetPlayerName(playerId)
        local jobName = "Civilian"
        local jobGrade = ""
        local onDuty = true
        
        -- Get job based on framework
        if framework == 'esx' and ESX then
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                -- Get job info
                jobName = xPlayer.job.label or xPlayer.job.name
                
                -- Add job grade if enabled
                if Config.ESX.ShowJobGrade and xPlayer.job.grade_label then
                    jobGrade = " (" .. xPlayer.job.grade_label .. ")"
                end
                
                -- Get identity name if enabled
                if Config.ESX.UseIdentity then
                    local identifier = xPlayer.getIdentifier()
                    local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users WHERE identifier = @identifier', {
                        ['@identifier'] = identifier
                    })
                    
                    if result[1] then
                        playerName = result[1].firstname .. " " .. result[1].lastname
                    end
                end
            end
        elseif framework == 'qbcore' and QBCore then
            local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
            if Player then
                -- Get job info
                jobName = Player.PlayerData.job.label
                
                -- Add duty status if enabled
                onDuty = Player.PlayerData.job.onduty
                if Config.QBCore.ShowJobDuty and not onDuty then
                    jobGrade = " (Off Duty)"
                end
                
                -- Get character name
                local charInfo = Player.PlayerData.charinfo
                if charInfo then
                    playerName = charInfo.firstname .. " " .. charInfo.lastname
                end
            end
        end
        
        table.insert(players, {
            id = tonumber(playerId),
            name = playerName,
            job = jobName .. jobGrade,
            onDuty = onDuty
        })
    end
    
    -- Sort players by ID if configured
    if Config.SortPlayersByID then
        table.sort(players, function(a, b)
            return a.id < b.id
        end)
    else
        table.sort(players, function(a, b)
            return a.name:lower() < b.name:lower()
        end)
    end
    
    return players
end

-- Get job counts based on framework
function GetJobCounts()
    local jobCounts = {}
    
    for _, job in ipairs(Config.TrackedJobs) do
        local count = 0
        
        if framework == 'esx' and ESX then
            local xPlayers = ESX.GetExtendedPlayers('job', job.name)
            count = #xPlayers
        elseif framework == 'qbcore' and QBCore then
            for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
                if v.PlayerData.job.name == job.name and v.PlayerData.job.onduty then
                    count = count + 1
                end
            end
        else
            -- Standalone fallback - basic count
            for _, playerId in ipairs(GetPlayers()) do
                -- This would need to be implemented based on your standalone job system
                -- For example, you might have a global table tracking player jobs
                -- count = count + (PlayerJobs[playerId] == job.name and 1 or 0)
            end
        end
        
        table.insert(jobCounts, {
            name = job.name,
            label = job.label,
            icon = job.icon,
            count = count
        })
    end
    
    return jobCounts
end

-- Main event to send data to client
RegisterNetEvent('scoreboard:getServerData')
AddEventHandler('scoreboard:getServerData', function()
    local source = source
    local players = GetAllPlayers()
    local jobs = GetJobCounts()
    
    TriggerClientEvent('scoreboard:receiveServerData', source, players, jobs)
end)

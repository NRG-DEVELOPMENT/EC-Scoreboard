Config = {}

-- General settings
Config.ServerName = "YOUR SERVER NAME"
Config.MaxPlayers = 64
Config.RefreshTime = 200 -- How often to refresh the scoreboard data (in ms)

-- Framework settings
Config.Framework = 'qbcore' -- 'auto', 'esx', 'qbcore', or 'standalone'

-- Key binding
Config.DefaultKey = 'HOME'

-- Jobs to track and display counts
Config.TrackedJobs = {
    {name = "police", label = "LSPD", icon = "🚓"},
    {name = "ambulance", label = "EMS", icon = "🚑"},
    {name = "realestate", label = "Realty", icon = "🏠"},
    {name = "mechanic", label = "Mech", icon = "🔧"},
    {name = "taxi", label = "Taxi", icon = "🚕"}
}

-- Display settings
Config.ShowJobsPanel = true
Config.SortPlayersByID = true -- If false, will sort alphabetically by name

-- ESX specific settings
Config.ESX = {
    UseIdentity = true, -- If true, will use first and last name from identity
    ShowJobGrade = true -- If true, will show job grade label
}

-- QBCore specific settings
Config.QBCore = {
    ShowJobDuty = true -- If true, will show (Off Duty) for players not on duty
}

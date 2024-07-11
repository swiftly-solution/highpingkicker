local immune_steamids = {}
local checks = {}
local max_ping = 150
local checks_to_kick = 10

function PingCheckerTimer()
    for i = 0, playermanager:GetPlayerCap() - 1, 1 do
        local player = GetPlayer(i)
        if not player then goto continue end
        if player:IsFakeClient() then goto continue end
        local steamid = tostring(player:GetSteamID())
        if immune_steamids[steamid] then goto continue end
        if not checks[steamid] then checks[steamid] = 0 end

        local ping = player:CCSPlayerController().Ping
        if ping > max_ping then
            checks[steamid] = checks[steamid] + 1
            if checks[steamid] >= checks_to_kick then
                player:Drop(DisconnectReason.Timedout)
            end
        else
            if checks[steamid] > 0 then
                checks[steamid] = checks[steamid] - 1
            end
        end

        ::continue::
    end
end

function LoadConfiguration()
    immune_steamids = {}

    for i = 0, config:FetchArraySize("highpingkicker.immune_steamids") - 1, 1 do
        immune_steamids[tostring(config:Fetch("highpingkicker.immune_steamids[" .. i .. "]"))] = true
    end

    max_ping = config:Fetch("highpingkicker.max_ping")
    checks_to_kick = config:Fetch("highpingkicker.checks_to_kick")
end

AddEventHandler("OnPlayerConnectFull", function(event)
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)
    if not player then return end

    checks[tostring(player:GetSteamID())] = 0
end)

AddEventHandler("OnClientDisconnect", function(event)
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)
    if not player then return end

    checks[tostring(player:GetSteamID())] = nil
end)

AddEventHandler("OnPluginStart", function()
    SetTimer(5000, PingCheckerTimer)

    LoadConfiguration()
end)

function GetPluginAuthor()
    return "Swiftly Solution"
end

function GetPluginVersion()
    return "v1.0.0"
end

function GetPluginName()
    return "High Ping Kicker"
end

function GetPluginWebsite()
    return "https://github.com/swiftly-solution/highpingkicker"
end

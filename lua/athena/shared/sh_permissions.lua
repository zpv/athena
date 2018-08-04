--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena
local recheck = false

function Athena.hasPermission(ply)
    local adminPlugin = Athena.Configuration.AdminPlugin

    if adminPlugin == "auto" or (adminPlugin == "other" && !recheck) then
        Athena.detectAdminSystem()
    end

    if adminPlugin == "ulx" then
		return ply:query("athena")
	elseif adminPlugin == "serverguard" then
		return serverguard.player:HasPermission(ply, "Athena")
    else 
        for k,v in pairs(Athena.Configuration.PlayerRanks) do
            if ply:IsUserGroup(v[1]) then
                return true
            end
        end
    end
    return false
end

function Athena.detectAdminSystem()
    if ulx then
        Athena.Configuration.AdminPlugin = "ulx"
    elseif serverguard then
        Athena.Configuration.AdminPlugin = "serverguard"
    else
        Athena.Configuration.AdminPlugin = "other"
    end
end

function Athena.addPermissions() 
    local adminPlugin = Athena.Configuration.AdminPlugin

    if adminPlugin == "ulx" then
        if SERVER then
            ULib.ucl.registerAccess("athena", ULib.ACCESS_ADMIN, "Access to the Athena panel", "Athena")
        end
    elseif adminPlugin == "serverguard" then
        serverguard.permission:Add("Athena")
    end
end

function Athena.addActions()
    local adminPlugin = Athena.Configuration.AdminPlugin
    
    if adminPlugin == "ulx" then
        Athena.Actions = {
            {"Spectate", "ulx spectate %p"},
            {"Bring", "ulx bring %p"},
            {"Goto", "ulx goto %p"},
            {"Teleport", "ulx teleport %p"},
            {"Return", "ulx return %p"}
        }
    elseif adminPlugin == "serverguard" then
        Athena.Actions = {
            {"Spectate", "sg spectate %p"},
            {"Bring", "sg bring %p"},
            {"Goto", "sg goto %p"},
            {"Send", "sg send %p"},
            {"Return", "sg return %p"}
        }
    end
end

hook.Add("InitPostEntity", "Athena_RegisterAdminSystem", function()
    if Athena.Configuration.AdminPlugin == "auto" then
        Athena.detectAdminSystem()
    end
    Athena.addPermissions()
    Athena.addActions()
end)

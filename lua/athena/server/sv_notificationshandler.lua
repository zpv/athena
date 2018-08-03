--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

util.AddNetworkString("Athena_newNotification")
util.AddNetworkString("Athena_warnNotify")

Athena.Notifications = {}

ATHENA_NOTIFICATION_COMPLETE = 3
ATHENA_NOTIFICATION_REPORT = 4

--[[
Athena.Notifications.writeNotification = function(...)
	local args = {...}
	local sends = {}
	for i = 1, #args do
		local o = args[i]
		sends[#sends + 1] = o
	end
	net.WriteUInt(#sends, 4)
	for i = 1, #sends do
		local o = sends[i]
		local typ = type(o)
		if typ == "string" or typ == "number" or typ == "boolean" then
			net.WriteString(tostring(o))
		end
	end
end
]]

Athena.Notifications.startNotification = function(type, data, extra)
	net.Start("Athena_newNotification")
	net.WriteTable(data)
	net.WriteInt(type, 4)

	local validPlayers = {}
	for k,v in pairs(player.GetAll()) do
		if Athena.hasPermission(v) then
			table.insert(validPlayers, v)
		end
	end
	if extra and IsValid(extra) then
		table.insert(validPlayers, extra)
	end
	net.Send(validPlayers)
end

net.Receive("Athena_newNotification", function(len, ply)
	if not Athena.hasPermission(ply) then print("Cannot make new notification. Access denied to " .. ply:Nick()) return end
	Athena.Notifications.startNotification()

end)

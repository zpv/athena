--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.Client.Warnings = Athena.Client.Warnings or {}

Athena.Client.requestWarnings = function(ply)
	local id = type(ply) == table and ply:SteamID64() or ply

	net.Start("Athena_RequestWarnings")
	net.WriteString(id)
	net.SendToServer()
end

net.Receive("Athena_TransferWarnings", function(len)
	local playerUID = net.ReadString()
	local warningsTable = net.ReadTable()

	-- refresh warnings list in warnings module
	Athena.Client.Warnings[playerUID] = warningsTable
	if IsValid(Athena.Elements.warningDetailsElements) then
		Athena.Elements.warningDetailsElements.repopulateTable()
	end
	-- refresh viewWarnings
	if IsValid(Athena.Elements.warningsDetailsElements) then
		Athena.Elements.warningsDetailsElements.repopulateTable()
	end
end)

Athena.Client.newWarning = function(target, description, severity)
	if not target then return end
	net.Start("Athena_SendWarning")
	net.WriteString(target)
	net.WriteString(description)
	math.Clamp( tonumber(severity), 1, 3 )
	net.WriteUInt(severity, 2)
	net.SendToServer()
end

Athena.Client.removeWarning = function(target, time)
	if not target then return end
	net.Start("Athena_RemoveWarning")
	net.WriteString(time)
	net.WriteString(target)
	net.SendToServer()
end
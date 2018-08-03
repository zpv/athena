--[[

╔══╦╗╔╗─────────╔═╗───────╔╗─╔══╗─╔═╦╗
║╔╗║╚╣╚╦═╦═╦╦═╗─║╬╠═╦═╦═╦╦╣╚╗║══╬╦╣═╣╚╦═╦══╗
║╠╣║╔╣║║╩╣║║║╬╚╗║╗╣╩╣╬║╬║╔╣╔╣╠══║║╠═║╔╣╩╣║║║
╚╝╚╩═╩╩╩═╩╩═╩══╝╚╩╩═╣╔╩═╩╝╚═╝╚══╬╗╠═╩═╩═╩╩╩╝
────────────────────╚╝──────────╚═╝
  Designed and Coded by Divine
        www.AuroraEN.com
────────────────────────────────

]]

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

	// refresh warnings list in warnings module
	Athena.Client.Warnings[playerUID] = warningsTable
	if IsValid(Athena.Elements.warningDetailsElements) then
		Athena.Elements.warningDetailsElements.repopulateTable()
	end
	// refresh viewWarnings
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

--[[
local function AutoComplete(cmd, stringargs)
	print(stringargs)
	stringargs = string.Trim( stringargs ) -- Remove any spaces before or after.
	stringargs = string.lower( stringargs )

	local tbl = {}

	for k, v in pairs( player.GetAll() ) do
		local nick = v:Nick()
		if string.find( string.lower( nick ), stringargs ) then
			nick = "\"" .. nick .. "\"" -- We put quotes around it incase players have spaces in their names.
			nick = "athena_warn " .. nick -- We also need to put the cmd before for it to work properly.

			table.insert( tbl, nick )
		end
	end

	return tbl
end

concommand.Add("athena_warn", function(ply, cmd, args, argstr)


end, AutoComplete)
]]
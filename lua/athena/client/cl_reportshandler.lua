--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.Client.Reports = Athena.Client.Reports or {}
Athena.Client.ReportStatuses = Athena.Client.ReportStatuses or {}
Athena.Client.CompletedReports = 0

ATHENA_STATUS_WAITING		= 1
ATHENA_STATUS_INPROGRESS	= 2
ATHENA_STATUS_COMPLETED		= 3

--[[

Athena.Client.readReport = function()
	local len = net.ReadUInt(32)
	local ret = {}
	for i = 1, len do
		ret[#ret + 1] = net.ReadString()
	end
	return ret
end

Athena.Client.readStatuses = function()
	local len = net.ReadUInt(32)
	local ret = {}
	for i = 1, len do
		ret[#ret + 1] = net.ReadUInt(2)
	end
	return ret
end

]]

Athena.Client.requestReports = function()
	net.Start("Athena_RequestReports") 
	net.SendToServer()
end

Athena.Client.updateStatus = function(reportIndex, reportStatus)
	if Athena.Client.ReportStatuses[tonumber(reportIndex)] ~= ATHENA_STATUS_COMPLETED and reportStatus == ATHENA_STATUS_COMPLETED then
		if not Athena.Client.Reports[reportIndex].GivenStat then
			Athena.Client.CompletedReports = Athena.Client.CompletedReports + 1
			Athena.Client.Reports[reportIndex].GivenStat = true
		end
	end

	Athena.Client.ReportStatuses[tonumber(reportIndex)] = reportStatus

	net.Start("Athena_TransferStatuses")
	net.WriteInt(reportIndex, 16)
	net.WriteInt(reportStatus, 16)
	net.SendToServer()
end

Athena.Client.sendReport = function(reportedPlayer, reportedPlayerID, message)
	net.Start("Athena_SendReport")
	net.WriteString(message)
	if reportedPlayerID ~= "None" then
		net.WriteBool(true)
		net.WriteString(reportedPlayerID)
		net.WriteString(reportedPlayer)
	else
		net.WriteBool(false)
	end
	net.SendToServer()
end

net.Receive("Athena_TransferReports", function(len)

	local renamedTable = {}
--	renamedTable["UID"] = net.ReadUInt(32)
	local receivedTable = net.ReadTable()
	renamedTable["UID"] = net.ReadUInt(32)
	renamedTable["reporter"] = receivedTable[1]
	renamedTable["reporterID"] = receivedTable[2]
	renamedTable["timeOfReport"] = receivedTable[3]
	renamedTable["message"] = receivedTable[4]
	if receivedTable[5] then
		renamedTable["reportedID"] = receivedTable[5]
	end
	if receivedTable[6] then
		renamedTable["reported"] = receivedTable[6]
	end

	table.insert(Athena.Client.Reports, renamedTable)
	if not Athena.Client.ReportStatuses[renamedTable["UID"]] then
		Athena.Client.ReportStatuses[renamedTable["UID"]] = ATHENA_STATUS_WAITING
	end

end)

net.Receive("Athena_TransferStatuses", function(len)
	local receivedTable = net.ReadTable()
	Athena.Client.ReportStatuses = receivedTable
	Athena.Client.CompletedReports = LocalPlayer():GetNWInt('Athena_CompletedReports')
end)

net.Receive("Athena_QueueFinish", function(len)
	if Athena.Client.Queued then
		if Athena.Client.QueueType and Athena.Client.QueueType == 1 then
			Athena.buildMenu()
		elseif Athena.Client.QueueType and Athena.Client.QueueType == 2 then
			Athena.Elements.mainFrame:ToggleMenu()
		end
		Athena.Client.QueueType = nil
		Athena.Client.Queued = nil
	end
end)

hook.Add("InitPostEntity","FirstRequestStatuses", function() if Athena.hasPermission(LocalPlayer()) then net.Start("Athena_RequestStatuses") net.SendToServer() end end)

concommand.Add("athena_stats", function()
	if LocalPlayer():IsAdmin() then
		print("-=-=-=-=- Athena Statistics -=-=-=-=-\n")
		for k,v in pairs(player.GetAll()) do
			if Athena.hasPermission(v) then
				print(v:Nick() .. "'s Completed Reports: " .. v:GetNWInt('Athena_CompletedReports'))
			end
		end
		print("\n-=-=-=-=- Athena Statistics -=-=-=-=-")
	end
end)
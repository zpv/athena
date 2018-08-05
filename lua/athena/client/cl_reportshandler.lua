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
ATHENA_STATUS_REJECTED		= 4
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

Athena.Client.updateStatus = function(reportId, reportStatus)
	if Athena.Client.Reports[reportId].status ~= ATHENA_STATUS_COMPLETED and reportStatus == ATHENA_STATUS_COMPLETED then
		if not Athena.Client.Reports[reportId].GivenStat then
			Athena.Client.CompletedReports = Athena.Client.CompletedReports + 1
			Athena.Client.Reports[reportId].GivenStat = true
		end
	end

	Athena.Client.Reports[reportId].status = reportStatus

	net.Start("Athena_TransferStatuses")
	net.WriteInt(reportId, 16)
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

Athena.Client.sendRating = function(reportId, rating)
	net.Start("Athena_RequestRating")

	net.WriteInt(reportId, 16)
	net.WriteInt(rating, 16)

	net.SendToServer()
end

net.Receive("Athena_RequestRating", function(len)
	local reportId = net.ReadInt(16)

	if Athena.Client.Reports[reportId] then
		Athena.rateMenu.startMenu(reportId)
	end
end)

net.Receive("Athena_TransferReports", function(len)
	local report = net.ReadTable()

	Athena.Client.Reports[report.id] = report
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
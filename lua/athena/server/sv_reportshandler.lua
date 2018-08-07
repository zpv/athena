--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

util.AddNetworkString("Athena_TransferReports")
util.AddNetworkString("Athena_SendReport")
util.AddNetworkString("Athena_TransferStats")
util.AddNetworkString("Athena_TransferStatuses")
util.AddNetworkString("Athena_RequestReports")
util.AddNetworkString("Athena_RequestStats")
util.AddNetworkString("Athena_QueueFinish")
util.AddNetworkString("Athena_RequestRating")
util.AddNetworkString("Athena_SendRating")

ATHENA_STATUS_WAITING		= 1
ATHENA_STATUS_INPROGRESS	= 2
ATHENA_STATUS_COMPLETED		= 3
ATHENA_STATUS_REJECTED		= 4

Athena.Server.LastId = Athena.Server.LastId or -1

Athena.Server.Reports = Athena.Server.Reports or {}
Athena.Server.SentReports = Athena.Server.SentReports or {}
Athena.Server.ReportStatuses = {}

--[[
Athena.Server.writeReport = function(...)
	local args = {...}
	local sends = {}
	for i = 1, #args do
		local o = args[i]
		sends[#sends + 1] = o
	end
	net.WriteUInt(#sends, 32)
	for i = 1, #sends do
		local o = sends[i]
		local typ = type(o)
		if typ == "string" or typ == "number" or typ == "boolean" then
			net.WriteString(tostring(o))
		end
	end
end

Athena.Server.writeStatuses = function(...)
	local args = {...}
	local sends = {}
	for i = 1, #args do
		local o = args[i]
		sends[#sends + 1] = o
	end
	net.WriteUInt(#sends, 32)
	for i = 1, #sends do
		local o = sends[i]
		net.WriteUInt(o,2)
	end
end

Athena.Server.sendReports = function(ply)
	if not Athena.Server.SentReports[ply:SteamID()] then
		Athena.Server.SentReports[ply:SteamID()] = {}
	end
	local count = 0
	local sentCount = 0
	for k,v in pairs(Athena.Server.Reports) do
		count = count + 1
		if not Athena.Server.SentReports[ply:SteamID()][k] then
			sentCount = sentCount + 1
			net.Start("Athena_TransferReports")
			print("SENDDD DA REPORT")
			Athena.Server.writeReport(k, v[1], v[2], v[3], v[4], v[5], v[6])
			net.Send(ply)
			Athena.Server.SentReports[ply:SteamID()][k] = true
			if count == #Athena.Server.Reports then
				Athena.Server.sendStatuses(ply)
			end
		end
	end
	if sentCount == 0 then
		Athena.Server.sendStatuses(ply)
	end
end

]]

Athena.Server.sendReports = function(ply)
	if not Athena.Server.SentReports[ply:SteamID()] then
		Athena.Server.SentReports[ply:SteamID()] = {}
	end
	local count = 0
	local sentCount = 0
	for k,v in pairs(Athena.Server.Reports) do
		count = count + 1
		if not Athena.Server.SentReports[ply:SteamID()][v.id] then
			sentCount = sentCount + 1
			net.Start("Athena_TransferReports")

			net.WriteTable(v)

			net.Send(ply)
			Athena.Server.SentReports[ply:SteamID()][v.id] = true
			if count == #Athena.Server.Reports then
				net.Start("Athena_QueueFinish")
				net.Send(ply)
			end
		end
	end
	if sentCount == 0 then
		net.Start("Athena_QueueFinish")
		net.Send(ply)
	end
end

net.Receive("Athena_RequestRating", function(len, ply)
	local reportId = net.ReadInt(16)
	local rating = net.ReadInt(16)

	local report = Athena.Server.Reports[reportId]

	if report == nil or report.reporterId != ply:SteamID() then return end
	report.rating = math.Clamp(rating, 0, 5)
	
	Athena:AddRating(util.SteamIDTo64(report.adminId), rating)
	Athena.UpdateReport(report)

	local admin = player.GetBySteamID(report.adminId)

	if admin then
		Athena.Notifications.startNotification(ATHENA_NOTIFICATION_RATED, {report.reporterName, report.rating}, admin)
	end
end)

Athena.Server.requestRating = function(ply, reportId)
	if Athena.Server.Reports[reportId] and Athena.Server.Reports[reportId].reporterId == ply:SteamID() then
		net.Start("Athena_RequestRating")
		net.WriteInt(reportId, 16)
		net.Send(ply)
	end
end

net.Receive("Athena_RequestStats", function(len, ply)
	if not Athena.hasPermission(ply) then print("Cannot send stats. Access denied to: " .. ply:Nick()) return end
	Athena:RefreshStats(ply)
end)

net.Receive("Athena_RequestReports", function(len, ply)
	if not Athena.hasPermission(ply) then print("No permissions ... bitch.") return end
	Athena.Server.sendReports(ply)
end)

net.Receive("Athena_TransferStatuses", function(len, ply)
	if not Athena.hasPermission(ply) then print("Cannot update statuses. Access denied to: " .. ply:Nick()) return end

	local reportId = net.ReadInt(16)
	local reportStatus = net.ReadInt(16)

	local report = Athena.Server.Reports[reportId]
	local reporter = player.GetBySteamID(report.reporterId)

	if report.status ~= ATHENA_STATUS_COMPLETED and reportStatus == ATHENA_STATUS_COMPLETED then
		if not report.GivenStat then
			Athena:SaveStats(ply, Athena:RetrieveStats(ply) + 1)
			report.GivenStat = true
		end
	end

	report.adminName = ply:Nick()
	report.adminId = ply:SteamID()
	report.status = reportStatus

	Athena.UpdateReport(report)

	if (reportStatus == ATHENA_STATUS_COMPLETED and (not report.rating or report.rating == 0)) then 
		Athena.Server.requestRating(reporter, report.id)
	end
	
	if reporter then
		Athena.Notifications.startNotification(reportStatus, {reportId, ply:Nick(), report.reporterName}, reporter)
	end
end)

net.Receive("Athena_SendReport", function(len, ply)
	if Athena.Server.LastId == -1 then
		ErrorNoHalt("Failed to create report - database not initalized.")
		return
	end

	local report = {}
	local reportedPlayer,reportedPlayerId
	local message = net.ReadString()
	local isReportedPlayer = net.ReadBool()

	report.id = Athena.Server.LastId + 1
	Athena.Server.LastId = Athena.Server.LastId + 1

	report.reporterName = ply:Nick()
	report.reporterId = ply:SteamID()
	report.time = os.time()
	report.message = message
	
	if isReportedPlayer then
		reportedPlayerId = net.ReadString()
		reportedPlayer = net.ReadString()

		report.reportedName = reportedPlayer
		report.reportedId = reportedPlayerId
	end

	report.status = ATHENA_STATUS_WAITING

	Athena.Server.Reports[report.id] = report
	Athena.SaveNewReport(report)
	--table.insert(Athena.Server.ReportStatuses, ATHENA_STATUS_WAITING)

	Athena.Notifications.startNotification(ATHENA_NOTIFICATION_REPORT, {ply:Nick(), reportedPlayer}, ply)

	for k,v in pairs(player.GetAll()) do
		if Athena.hasPermission(v) then
			Athena.Server.sendReports(v)
		end
	end
end)

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "FlushPlayerTable", function( data )
	if Athena.Server.SentReports[data.networkid] then
		Athena.Server.SentReports[data.networkid] = nil
	end
end )

hook.Add( "PlayerSay", "ReportMenuCommand", function(ply, text)
	local t = string.lower(text)
	if ( string.sub(t, 1, 7) == '!report' or string.sub(t, 1, 7) == '/report' ) then
		local staffOnline = false
		for k,v in pairs(player.GetAll()) do 
			if Athena.hasPermission(v) then
				staffOnline = true
				break
			end
		end
		if staffOnline then
			ply:ConCommand("athena_report")
		else
			ply:SendLua("gui.OpenURL(\"" .. Athena.Configuration.ForumsRedirect .. "\")")
		end
	end
end)
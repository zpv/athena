--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

for _, dir in ipairs( { "athena/", "athena/stats/", "athena/warnings/" } ) do
	if not ( file.IsDir( dir, "DATA" ) ) then
		file.CreateDir( dir )
	end
end

function Athena.ConnectDatabase()
	local config = Athena.Configuration.MySQL

	if (config.Enabled) then
		Athena.mysql:Connect(config.Host, config.Username, config.Password, config.Database, config.Port, config.Socket, nil, config.Module)
		return
	end

	Athena.mysql:Connect();
end

hook.Add("Initialize", "Athena_ConnectDatabase", Athena.ConnectDatabase)

function Athena.InitDatabase()
	local reportsTableQuery = Athena.mysql:Create("athena_reports")
		reportsTableQuery:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
		reportsTableQuery:Create("reporterid","VARCHAR(17) NOT NULL")
		reportsTableQuery:Create("reportername","VARCHAR(45)")
		reportsTableQuery:Create("reportedid","VARCHAR(17)")
		reportsTableQuery:Create("reportedname","VARCHAR(45)")
		reportsTableQuery:Create("time","TIMESTAMP")
		reportsTableQuery:Create("message","TEXT")
		reportsTableQuery:Create("status","INTEGER")
		reportsTableQuery:Create("adminname","VARCHAR(45)")
		reportsTableQuery:Create("adminid","VARCHAR(17)")
		reportsTableQuery:Create("rating", "INTEGER")
		reportsTableQuery:PrimaryKey("id");
	reportsTableQuery:Execute()

	local warningsTableQuery = Athena.mysql:Create("athena_warnings")
		warningsTableQuery:Create("id", "VARCHAR(17) NOT NULL")
		warningsTableQuery:Create("data", "TEXT")

	warningsTableQuery:Execute()

	local statsTableQuery = Athena.mysql:Create("athena_stats")
		statsTableQuery:Create("id", "VARCHAR(17) NOT NULL")
		statsTableQuery:Create("name", "VARCHAR(45)")
		statsTableQuery:Create("completed", "INTEGER")
		statsTableQuery:Create("rated", "INTEGER")
		statsTableQuery:Create("rating", "DECIMAL(13,4)")
		statsTableQuery:PrimaryKey("id");
	statsTableQuery:Execute()


	local lastInsert = "last_insert_rowid"

	if Athena.Configuration.MySQL.Enabled then
		lastInsert = "last_insert_id"
	end

	Athena.mysql:RawQuery("SELECT count(id) FROM athena_reports", function(result)
		if result then
			Athena.Server.LastId = result[1]["count(id)"]
		end
	end)

	-- MySQLite.query([[
	-- 	SELECT last_insert_rowid() as id
	-- 	]], function(tbl)
	-- 		if tbl then
	-- 			Athena.Server.LastId = tbl.id
	-- 		end
	-- 	end)
end

hook.Add("Athena_DatabaseConnected", "Athena_InitDatabase", Athena.InitDatabase)

function Athena.SaveNewReport(report)
	local reporterId64, reportedId64

	reporterId64 = util.SteamIDTo64(report.reporterId)

	if reportedId then
		reportedId64 = util.SteamIDTo64(report.reportedId)
	end

	local insertObj = Athena.mysql:Insert("athena_reports")
			insertObj:Insert("reporterid", reporterId64)
			insertObj:Insert("reportername", report.reporterName)
			insertObj:Insert("reportedid", reportedId64)
			insertObj:Insert("reportedname", report.reportedName)
			insertObj:Insert("time", os.time())
			insertObj:Insert("message", report.message)
			insertObj:Insert("status", report.status)
		insertObj:Execute()
end

function Athena.UpdateReport(report)
	local adminId64 = util.SteamIDTo64(report.adminId)
	local updateObj = Athena.mysql:Update("athena_reports")
		updateObj:Update("adminname", report.adminName)
		updateObj:Update("adminid", adminId64)
		updateObj:Update("status", report.status)
		updateObj:Update("rating", report.rating)
		updateObj:Where("id", report.id)
	updateObj:Execute()
end

-- function Athena:RetrieveStats(ply)
-- 	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
-- 	local data = file.Read(path, "DATA")

-- 	return tonumber(data) or 0
-- end

-- function Athena:RetrieveAverageRating(ply)

-- 	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
-- 	local data = file.Read(path, "DATA")

-- 	return tonumber(data) or 0
-- end

-- function Athena:SaveStats(ply, count)
-- 	local updateObj = Athena.mysql:Update("athena_stats")
-- 		updateObj:Update("completed", count)
-- 		updateObj:Where("id", report.id)
-- 	updateObj:Execute()

-- 	Athena:RefreshStats(ply)
-- end


function Athena:RetrieveStats(ply, callback)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)

	local queryObj = Athena.mysql:Select("athena_stats")
		queryObj:Where("id", id)
		queryObj:Callback(function(result, status, lastID)
			local stats = {}
			if (type(result) == "table" and #result > 0) then
				stats.completed = result[1].completed
				stats.rated = result[1].rated
				stats.rating = result[1].rating
			else
				Athena:InitStats(id)
			end
			callback(stats)
		end)
	queryObj:Execute()
end

function Athena:SaveCompleted(ply, completed)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)
	local updateObj = Athena.mysql:Update("athena_stats");
		updateObj:Update("completed", completed);
		updateObj:Where("id", id);
	updateObj:Execute();
end

function Athena:SaveRating(ply, rating, num)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)
	local updateObj = Athena.mysql:Update("athena_stats");
		updateObj:Update("rated", num);
		updateObj:Update("rating", rating);
		updateObj:Where("id", id);
	updateObj:Execute();
end

-- Moving average calculation
function Athena:AddRating(ply, rating)
	Athena:RetrieveStats(ply, function(stats)
		local num = stats.rated + 1
		local newRating = stats.rating + tonumber(rating)

		Athena:SaveRating(ply, newRating, num)
	end)
end

function Athena:AddCompleted(ply)
	Athena:RetrieveStats(ply, function(stats)
		local num = stats.completed + 1

		Athena:SaveCompleted(ply, num)
	end)
end

function Athena:InitStats(id)
	local insertObj = Athena.mysql:Insert("athena_stats");
		insertObj:Insert("completed", 0);
		insertObj:Insert("rated", 0);
		insertObj:Insert("rating", 0);
		insertObj:Insert("id", id);
	insertObj:Execute();
end 

function Athena:RetrieveWarnings(ply, callback)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)

	local queryObj = Athena.mysql:Select("athena_warnings")
		queryObj:Where("id", id)
		queryObj:Callback(function(result, status, lastID)
			local warnings = {}
			if (type(result) == "table" and #result > 0) then
				if (result[1].data != "NULL" and result[1].data != nil) then
					warnings = util.JSONToTable(result[1].data)
				end
			else
				Athena:SaveWarnings(id, warnings, true)
			end
			callback(warnings)
		end)
	queryObj:Execute()
end

function Athena:SaveWarnings(id, warnings, bNew)
	--local path = "athena/warnings/" .. tostring(ply) .. ".txt"
	local data = util.TableToJSON(warnings or {})

	if (bNew) then
		local insertObj = Athena.mysql:Insert("athena_warnings");
			insertObj:Insert("data", data);
			insertObj:Insert("id", id);
		insertObj:Execute();
	else
		local updateObj = Athena.mysql:Update("athena_warnings");
			updateObj:Update("data", data);
			updateObj:Where("id", id);
		updateObj:Execute();
	end;
end 

function Athena:RefreshStats(ply)
	Athena:RetrieveStats(ply, function(stats)
		
		ply:SetNWInt('Athena_CompletedReports', stats.completed)
		ply:SetNWInt('Athena_Rating', stats.rating)
		ply:SetNWInt('Athena_RatingNum', stats.rated)

		net.Start("Athena_RequestStats")
		net.Send(ply)
		net.Start("Athena_QueueFinish")
		net.Send(ply)
	end)
	-- ply:SetNWInt('Athena_CompletedReports', Athena:RetrieveStats(ply))
	-- ply:SetNWInt('Athena_AverageRating', Athena:RetrieveAverageRating(ply))
end
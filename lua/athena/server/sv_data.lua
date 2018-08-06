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
		reportsTableQuery:Create("reporterid","BIGINT NOT NULL")
		reportsTableQuery:Create("reportername","VARCHAR(45)")
		reportsTableQuery:Create("reportedid","BIGINT")
		reportsTableQuery:Create("reportedname","VARCHAR(45)")
		reportsTableQuery:Create("time","TIMESTAMP")
		reportsTableQuery:Create("message","TEXT")
		reportsTableQuery:Create("status","INTEGER")
		reportsTableQuery:Create("adminname","VARCHAR(45)")
		reportsTableQuery:Create("adminid","BIGINT")
		reportsTableQuery:Create("rating", "INTEGER")
		reportsTableQuery:PrimaryKey("id");
	reportsTableQuery:Execute()

	local warningsTableQuery = Athena.mysql:Create("athena_warnings")
		warningsTableQuery:Create("id", "BIGINT NOT NULL")
		warningsTableQuery:Create("data", "TEXT")

	warningsTableQuery:Execute()

	local statsTableQuery = Athena.mysql:Create("athena_stats")
		statsTableQuery:Create("id", "BIGINT NOT NULL")
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

	reporterId64 = tonumber(util.SteamIDTo64(report.reporterId))

	if reportedId then
		reportedId64 = tonumber(util.SteamIDTo64(report.reportedId))
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
	local adminId64 = tonumber(util.SteamIDTo64(report.adminId))
	local updateObj = Athena.mysql:Update("athena_reports")
		updateObj:Update("adminname", report.adminName)
		updateObj:Update("adminid", adminId64)
		updateObj:Update("status", report.status)
		updateObj:Update("rating", report.rating)
		updateObj:Where("id", report.id)
	updateObj:Execute()
end

function Athena:RetrieveStats(ply)
	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
	local data = file.Read(path, "DATA")

	return tonumber(data) or 0
end

function Athena:RetrieveAverageRating(ply)

	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
	local data = file.Read(path, "DATA")

	return tonumber(data) or 0
end

function Athena:SaveStats(ply, count)
	local updateObj = Athena.mysql:Update("athena_stats")
		updateObj:Update("completed", count)
		updateObj:Where("id", report.id)
	updateObj:Execute()
	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
	local data = count

	file.Write(path, data)
	Athena:RefreshStats(ply)
end

function Athena:RetrieveWarnings(ply, callback)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)

	local queryObj = Athena.mysql:Select("athena_warnings")
		queryObj:Where("id", tonumber(id))
		queryObj:Callback(function(result, status, lastID)
			local warnings = {}
			if (type(result) == "table" and #result > 0) then
				if (result[1].data != "NULL") then
					warnings = Athena.von.deserialize(result[1].data) or {}
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
	local data = Athena.von.serialize(warnings or {})

	if (bNew) then
		local insertObj = Athena.mysql:Insert("athena_warnings");
			insertObj:Insert("data", data);
			insertObj:Insert("id", tonumber(id));
		insertObj:Execute();
	else
		local updateObj = Athena.mysql:Update("athena_warnings");
			updateObj:Update("data", data);
			updateObj:Where("id", tonumber(id));
		updateObj:Execute();
	end;
end 

function Athena:RefreshStats(ply)
	ply:SetNWInt('Athena_CompletedReports', Athena:RetrieveStats(ply))
	ply:SetNWInt('Athena_AverageRating', Athena:RetrieveAverageRating(ply))
end
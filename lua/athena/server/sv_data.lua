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
		warningsTableQuery:Create("id", "BIGINT NOT NULL PRIMARY KEY")
		warningsTableQuery:Create("name", "VARCHAR(45)")
		warningsTableQuery:Create("adminid", "BIGINT NOT NULL")
		warningsTableQuery:Create("adminname", "VARCHAR(45)")
		warningsTableQuery:Create("severity", "INTEGER NOT NULL")
		warningsTableQuery:Create("description", "TEXT NOT NULL")
	warningsTableQuery:Execute()

	local lastInsert = "last_insert_rowid"

	if Athena.Configuration.MySQL.Enabled then
		lastInsert = "last_insert_id"
	end

	Athena.mysql:RawQuery("SELECT ".. lastInsert .."() as id", function(result)
		if result then
			PrintTable(result)
			Athena.Server.LastId = result[1].id
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
	local insertObj = Athena.mysql:Insert("athena_reports")
			insertObj:Insert("reporterid", report.reporterId)
			insertObj:Insert("reportername", report.reporterName)
			insertObj:Insert("reportedid", report.reportedId)
			insertObj:Insert("reportedname", report.reportedName)
			insertObj:Insert("time", os.time())
			insertObj:Insert("message", report.message)
			insertObj:Insert("status", report.status)
		insertObj:Execute()
end

function Athena.UpdateReport(report)
	local updateObj = Athena.mysql:Update("athena_reports")
		updateObj:Update("adminname", report.adminName)
		updateObj:Update("adminid", report.adminId)
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

function Athena:SaveStats(ply, count)
	local path = "athena/stats/" .. ply:UniqueID() .. ".txt"
	local data = count

	file.Write(path, data)
	Athena:RefreshStats(ply)
end

function Athena:RetrieveWarnings(ply)
	local id = type(ply) == table and ply:SteamID64() or tostring(ply)

	local path = "athena/warnings/" .. id .. ".txt"
	local data = util.JSONToTable(file.Read(path, "DATA") or "")

	return data or {}
end

function Athena:SaveWarnings(ply, warnings)
	local path = "athena/warnings/" .. tostring(ply) .. ".txt"
	local data = util.TableToJSON(warnings or {})

	file.Write(path, data)
end 

function Athena:RefreshStats(ply)
	ply:SetNWInt('Athena_CompletedReports', Athena:RetrieveStats(ply))
end
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
	if (file.Exists("addons/serverguard/mysql.cfg", "MOD")) then
		local config = util.KeyValuesToTable(
			file.Read("addons/serverguard/mysql.cfg", "MOD")
		);

		if (config and config.enabled == 1) then
			if (config.module != Module) then
				Module = config.module;
			end;

			serverguard.mysql:Connect(config.host, config.username, config.password, config.database, config.port, config.unixsocket);
			return;
		end;
	end;

	serverguard.mysql:Connect();
end

hook.Add("Initialize", "Athena_ConnectDatabase", Athena.ConnectDatabase)

function Athena.InitDatabase()
	print("ATHENA - INIT DATABASE")
	local AUTOINCREMENT = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"

	MySQLite.query([[
		CREATE TABLE IF NOT EXISTS athena_reports(
			id INTEGER NOT NULL PRIMARY KEY ]] .. AUTOINCREMENT .. [[,
			reporterid BIGINT NOT NULL,
			reportername VARCHAR(45),
			reportedid BIGINT,
			reportedname VARCHAR(45),
			time TIMESTAMP,
			message TEXT,
			status INTEGER,
			adminid BIGINT,
			rating INTEGER
		);
	]])
	MySQLite.query([[
			CREATE TABLE IF NOT EXISTS athena_warnings(
				id BIGINT NOT NULL PRIMARY KEY,
				name VARCHAR(45),
				warnerid BIGINT NOT NULL,
				warnername VARCHAR(45),
				severity INTEGER NOT NULL,
				description TEXT NOT NULL
			);
		]])
	MySQLite.query([[
		SELECT last_insert_rowid() as id
		]], function(tbl)
			if tbl then
				Athena.Server.LastId = tbl.id
			end
		end)
end



function Athena.SaveReport(report)
	
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
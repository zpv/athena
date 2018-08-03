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
--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

util.AddNetworkString("Athena_TransferWarnings")
util.AddNetworkString("Athena_SendWarning")
util.AddNetworkString("Athena_RequestWarnings")
util.AddNetworkString("Athena_WarningsQueueFinish")
util.AddNetworkString("Athena_RemoveWarning")

net.Receive("Athena_RequestWarnings", function(len, ply)
	local targetUID = net.ReadString()
	if ply:SteamID64() ~= targetUID and not Athena.hasPermission(ply) then print("No permissions ... bitch.") return end
	Athena.Server.sendWarnings(ply, targetUID)
end)

Athena.Server.filterOldWarnings = function(warnings)

	local filteredWarnings = {}

	for k,v in pairs(warnings) do
		if not ((os.time() - tonumber(v["time"])) > Athena.Configuration.WarningDecay) then
			table.insert(filteredWarnings, v)
		end
	end

	return filteredWarnings

end

Athena.Server.sendWarnings = function(ply, targetUID)
	local targetWarnings = Athena:RetrieveWarnings(targetUID)

	targetWarnings = Athena.Server.filterOldWarnings(targetWarnings)

	net.Start("Athena_TransferWarnings")
	net.WriteString(targetUID)
	net.WriteTable(targetWarnings)
	net.Send(ply)

	net.Start("Athena_WarningsQueueFinish")
	net.Send(ply)
end

Athena.Server.WarnPlayer = function(target, description, severity, warner)
	local newWarning = {}

	severity = math.Clamp( tonumber(severity), 1, 3 )

	newWarning["time"] = os.time()
	newWarning["description"] = description
	newWarning["severity"] = severity
	newWarning["warner"] = warner:Nick()

	

	local targetWarnings = Athena:RetrieveWarnings(target)
	table.insert(targetWarnings, newWarning)
	Athena:SaveWarnings(target, targetWarnings)

	net.Start("Athena_warnNotify")
	net.WriteString(warner:Nick())
	local playerEntity = player.GetBySteamID64(target)
	if playerEntity:IsValid() then net.WriteString(playerEntity:Nick()) else
		net.WriteString(Athena.CommunityIDToSteamID(target))
	end
	net.WriteString(description)
	net.WriteUInt(severity, 2)
	net.Broadcast()

	local totalSeverity = 0
	local ply = player.GetBySteamID64(target)

	for k,v in pairs(Athena.Server.filterOldWarnings(targetWarnings)) do
		totalSeverity = totalSeverity + tonumber(v["severity"])
	end

	if totalSeverity >= Athena.Configuration.Warning3DayBanThreshold then
		if ply:IsValid() then
			ULib.ban(ply, 4320, "[Athena] Banned for reaching warning threshhold. Exceeding 20 severity", nil)
		end
	elseif totalSeverity >= Athena.Configuration.Warning1DayBanThreshold then
		if ply:IsValid() then
			ULib.ban(ply, 1440, "[Athena] Banned for reaching warning threshhold. Exceeding 10 severity", nil)
		end
	elseif totalSeverity >= Athena.Configuration.WarningKickThreshold then
		if ply:IsValid() then
			ULib.kick(ply, "[Athena] Kicked for reaching warning threshhold. Exceeding 5 severity", nil)
		end
	end

end

net.Receive("Athena_SendWarning", function(len, ply)
	if not Athena.hasPermission(ply) then print("No permissions ... bitch.") return end
	local targetID = net.ReadString()
	local description = net.ReadString()
	local severity = net.ReadUInt(2)

	Athena.Server.WarnPlayer(targetID, description, severity, ply)
end)

net.Receive("Athena_RemoveWarning", function(len, ply)
	if not Athena.hasPermission(ply) then print("No permissions ... bitch.") return end

	local warningTime = tonumber(net.ReadString())
	local playerID = net.ReadString()

	local targetWarnings = Athena:RetrieveWarnings(playerID)
	for k,v in pairs(targetWarnings) do
		if v["time"] == tonumber(warningTime) then
			table.remove(targetWarnings, k)
		end
	end

	Athena:SaveWarnings(playerID, targetWarnings)

	--Athena.Server.sendWarnings(ply, targetUID)
end)

local function parseString(text)
	local words = {}

	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	for str in text:gmatch("%S+") do
	  local squoted = str:match(spat)
	  local equoted = str:match(epat)
	  local escaped = str:match([=[(\*)['"]$]=])
	  if squoted and not quoted and not equoted then
	    buf, quoted = str, squoted
	  elseif buf and equoted == quoted and #escaped % 2 == 0 then
	    str, buf, quoted = buf .. ' ' .. str, nil, nil
	  elseif buf then
	    buf = buf .. ' ' .. str
	  end
	  if not buf then table.insert(words, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then return nil end
	return words
end

local function WarnChatHook(ply, text)
	local t = string.lower(text)

	if ( (string.sub(t, 1, 9) == '!warnings' or string.sub(t, 1, 9) == '/warnings')) then
		ply:ConCommand("athena_viewwarnings")
	elseif( (string.sub(t, 1, 5) == '!warn' or string.sub(t, 1, 5) == '/warn')) then
		if(string.len(t) == 5) then
			ply:ConCommand("athena_warn")
		elseif (Athena.hasPermission(ply)) then
			local words = parseString(text)
			if words ~= nil then 
				if words[2] == nil then ply:ChatPrint("Invalid syntax: !warn {player} {severity} {reason}") return end
				local target = DarkRP.findPlayer(words[2])
				if target == nil then ply:ChatPrint("Invalid syntax: !warn {player} {severity} {reason}") return end

				local warnedPlayerID = target:SteamID64()

				if words[3] == nil then ply:ChatPrint("Invalid syntax: !warn {player} {severity} {reason}") return end
				local severity = tonumber(words[3])
				if severity == nil then ply:ChatPrint("Invalid syntax: !warn {player} {severity} {reason}") return end

				local reason = ""

				for i=4, (#words) do
					reason = (((reason != "") and (reason .. " ")) or reason) .. words[i]
				end

				Athena.Server.WarnPlayer(warnedPlayerID, reason, severity, ply)
				return ''
				
			end
		end
	end

end
hook.Add( "PlayerSay", "WarnMenuCommand", WarnChatHook)
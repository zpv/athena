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

function Athena.getPlayerInfo(ply, permission)
	if not IsValid(ply) and not ply:IsPlayer() then return end
	local playerRank = ply:GetUserGroup()

	for k,v in pairs(Athena.Configuration.PlayerRanks) do
		if ply:CheckGroup(v[1]) or (playerRank == v[1]) then
			if permission then
				if v[3] == permission then
					return v
				end
			else
				return v
			end
		end
	end

	return false
end

function Athena.isSteamID(steamId)
	return string.match (steamId, "STEAM_%d+:%d+:%d+") ~= nil
end

function Athena.SteamIdToCommunityId(steamId)
	local x, y, z = string.match (steamId, "STEAM_(%d+):(%d+):(%d+)")
	x = tonumber (x)
	y = tonumber (y)
	z = tonumber (z)
	
	local communityId = z * 2 + y + 1197960265728
	
	return "7656" .. tostring (communityId)
end

function Athena.CommunityIDToSteamID(cid)
  local steam64=tonumber(cid:sub(2))
  local a = steam64 % 2 == 0 and 0 or 1
  local b = math.abs(6561197960265728 - steam64 - a) / 2
  local sid = "STEAM_0:" .. a .. ":" .. (a == 1 and b -1 or b)
  return sid
end

function Athena.findUserByID(steamid)
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			return v
		end
	end
	return false
end
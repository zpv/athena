--[[
	░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
	▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
	▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 

	NOTICE: Manage access in your admin plugin's built-in permission system.
		ULX: Groups -> Manage Permissions -> Athena
		ServerGuard: Rank Editor -> Right Click on {rank} -> Change Permissions -> Athena

	For support, feel free to add me directly on Steam: https://steamcommunity.com/id/CanadianSteve/
]]

-- Select from http://wiki.garrysmod.com/page/Enums/KEY
Athena.Configuration.KeyBind = KEY_BACKSLASH
Athena.Configuration.UseKeyBind = true

Athena.Configuration.ConsoleCommand = "athena"

-- If there are no staff online, redirect players to this URL. (i.e. submit a report forums)
Athena.Configuration.ForumsRedirect = ""

-- Warning Severity Thresholds
-- FORMAT: {threshold, "kick" or "ban", ban_time}
Athena.Configuration.WarningThresholds = {
	{5, "kick"},			-- Kick at 5
	{10, "ban", 1440},		-- One day ban at 10
	{20, "ban", 4320},		-- Three day ban at 20
	{50, "ban", 0}			-- Permanent ban at 50
}

-- Warning Decay Threshold - In Seconds
Athena.Configuration.WarningDecay = 604800

-- Valid settings are: "auto", "ulx", "serverguard", "other"
Athena.Configuration.AdminPlugin = "auto"

-- Enable ability for players to rate staff after admin sit
Athena.Configuration.StaffRatings = true

Athena.Configuration.WarnReasons = {
	"Breaking NLR",
	"Committing RDM",
	"Propblock",
	"Propspam",
	"Propclimb",
	"Harassment",
	"FailRP"
}

-- Custom actions.
-- %p is replaced with the target's nickname.
Athena.Configuration.CustomActions = {
	--{"Slay", "ulx slay %p"}
}

-- If you are NOT using ULX or ServerGuard, manually configure ranks.
-- This will have NO effect if you are using ULX or ServerGuard.
-- FORMAT: {"rank_name", "friendly_name"}
Athena.Configuration.PlayerRanks = {
	{"superadmin", "Super Admin"},
    {"moderator", "Moderator"}
}

-- Networking: Do not touch unless you know what you are doing --
Athena.Configuration.ServerBroadcastInterval = 60
Athena.Configuration.ClientRequestInterval = 30
Athena.Configuration.QueueTimeout = 10

Athena.Configuration.FadeMultiplier = 0.2
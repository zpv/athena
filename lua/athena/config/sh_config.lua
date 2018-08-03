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
Athena.Configuration.WarningKickThreshold = 5
Athena.Configuration.Warning1DayBanThreshold = 10
Athena.Configuration.Warning3DayBanThreshold = 20

-- Warning Decay Threshold - In Seconds
Athena.Configuration.WarningDecay = 604800

-- Valid settings are: "auto", "ulx", "serverguard", "other"
Athena.Configuration.AdminPlugin = "auto"

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
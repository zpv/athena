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
----- Do not edit -----
Athena = Athena or {}
if SERVER then
	Athena.Server = {}
else
	Athena.Client = {}
end

Athena.Configuration = {}

ATHENA_ACCESS_FULL 		= 3
ATHENA_ACCESS_LIMITED 	= 2
ATHENA_ACCESS_REPORT 	= 1
ATHENA_ACCESS_NONE 		= 0

Athena.Version = "2.0"
-----------------------

----------------------------------------------------------
-- Select from http://wiki.garrysmod.com/page/Enums/KEY --
----------------------------------------------------------
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

-- {rank, name, access_level}
Athena.Configuration.PlayerRanks = {
	{"superadmin", "Super Admin", ATHENA_ACCESS_FULL},
    {"moderator", "Prime Enforcer", ATHENA_ACCESS_FULL}
}

Athena.Configuration.WarnReasons = {
	"Breaking NLR",
	"Committing RDM",
	"Propblock",
	"Propspam",
	"Propclimb",
	"Harassment",
	"FailRP"
}

-- Networking: Do not touch unless you know what you are doing --
Athena.Configuration.ServerBroadcastInterval = 60
Athena.Configuration.ClientRequestInterval = 30
Athena.Configuration.QueueTimeout = 10

Athena.Configuration.FadeMultiplier = 0.2
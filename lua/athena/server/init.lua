--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

AddCSLuaFile("athena/config/sh_config.lua")
include("athena/config/sh_config.lua")
include("athena/server/libraries/sv_mysql.lua")
include("athena/config/sv_sql_config.lua")

AddCSLuaFile("athena/client/cl_init.lua")
AddCSLuaFile("athena/shared/sh_utils.lua")
AddCSLuaFile("athena/shared/sh_permissions.lua")
AddCSLuaFile("athena/client/cl_menu.lua")
AddCSLuaFile("athena/client/cl_overview.lua")
AddCSLuaFile("athena/client/cl_data.lua")
AddCSLuaFile("athena/client/cl_reports.lua")
AddCSLuaFile("athena/client/cl_reportshandler.lua")
AddCSLuaFile("athena/client/cl_warningshandler.lua")
AddCSLuaFile("athena/client/cl_viewwarnings.lua")
AddCSLuaFile("athena/client/cl_warnings.lua")
AddCSLuaFile("athena/client/cl_notificationshandler.lua")
AddCSLuaFile("athena/client/cl_reportmenu.lua")
AddCSLuaFile("athena/client/cl_warnmenu.lua")
AddCSLuaFile("athena/client/cl_gui_library.lua")
AddCSLuaFile("athena/client/cl_ratemenu.lua")

include("athena/server/sv_resources.lua")
include("athena/shared/sh_utils.lua")
include("athena/shared/sh_permissions.lua")
include("athena/server/sv_data.lua")
include("athena/server/sv_reportshandler.lua")
include("athena/server/sv_warningshandler.lua")
include("athena/server/sv_notificationshandler.lua")
include("athena/server/sv_helpers.lua")


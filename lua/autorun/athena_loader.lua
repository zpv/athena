--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

Athena = Athena or {}
if SERVER then
	Athena.Server = {}
else
	Athena.Client = {}
end

Athena.Configuration = {}
Athena.Version = "2.0"

if SERVER then
	include("athena/server/init.lua")
else
	include("athena/client/cl_init.lua")
end

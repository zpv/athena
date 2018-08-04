function Athena.kick(ply, reason)
    local adminPlugin = Athena.Configuration.AdminPlugin

    if adminPlugin == "ulx" then
        ULib.kick(ply, reason, nil)
    elseif adminPlugin == "serverguard" then
        RunConsoleCommand("serverguard_kick", ply:SteamID(), reason)
    else
        ply:Kick(reason)
    end
end

function Athena.ban(ply, length, reason)
    local adminPlugin = Athena.Configuration.AdminPlugin

    if adminPlugin == "ulx" then
        ULib.ban(ply, length, reason, nil)
    elseif adminPlugin == "serverguard" then
        serverguard:BanPlayer(nil, ply, length, reason)
    else
        RunConsoleCommand("ban", ply:SteamID(), length, reason)
    end
end
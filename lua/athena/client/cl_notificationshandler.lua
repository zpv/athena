--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

Athena.Notifications = {}

ATHENA_NOTIFICATION_RATED 		= 5
ATHENA_NOTIFICATION_REPORT 		= 4
ATHENA_NOTIFICATION_WAITING 	= 1
ATHENA_NOTIFICATION_ONGOING 	= 2
ATHENA_NOTIFICATION_COMPLETE 	= 3


Athena.Notifications.Actions = {
	[ATHENA_NOTIFICATION_REPORT] = function(details) Athena.Notifications.drawNotification(4, details[1] .. " has submitted a report" .. ((details[2] != nil) and (" on " .. details[2]) or ".")) surface.PlaySound("athena/notifications/newreport.mp3") end,
	[ATHENA_NOTIFICATION_COMPLETE] = function(details) Athena.Notifications.drawNotification(2, details[2] .. " updated the status of " .. details[3] .. "'s report to complete.") Athena.Client.Reports[tonumber(details[1])].status = ATHENA_STATUS_COMPLETED surface.PlaySound("athena/notifications/statuscomplete.mp3") end,
	[ATHENA_NOTIFICATION_ONGOING] = function(details) Athena.Notifications.drawNotification(2, details[2] .. " updated the status of " .. details[3] .. "'s report to ongoing.") Athena.Client.Reports[tonumber(details[1])].status = ATHENA_STATUS_INPROGRESS surface.PlaySound("athena/notifications/statusongoing.mp3") end,
	[ATHENA_NOTIFICATION_WAITING] = function(details) Athena.Notifications.drawNotification(2, details[2] .. " updated the status of " .. details[3] .. "'s report to waiting.") Athena.Client.Reports[tonumber(details[1])].status = ATHENA_STATUS_WAITING surface.PlaySound("athena/notifications/statusongoing.mp3") end,
	[ATHENA_NOTIFICATION_RATED]	  = function(details) Athena.Notifications.drawNotification(5, details[1] .. " rated your report: " .. details[2] .. "/5") surface.PlaySound("athena/notifications/statuscomplete.mp3") end
}

Athena.Notifications.newNotification = function(notificationType, ...)
	Athena.Notifications.Actions[notificationType]({...})
end

Athena.Notifications.drawNotification = function(length, text) 
	local startTime = CurTime()
	local notificationPanel = vgui.Create("DPanel")
	local pulseOffset = 5*(math.sin((15)*(CurTime())))
	notificationPanel:SetSize(400, 24)
	notificationPanel:SetPos(ScrW() / 2 - 200, -24)
	notificationPanel:MoveTo(ScrW() / 2 - 200, 0, 0.25)
	notificationPanel.Think = function(self)
		if CurTime() - startTime > length and not self.startRemove then 
			self.startRemove = true
			notificationPanel:MoveTo(ScrW() / 2 - 200, -24, 0.25, 0, -1, function(data, self) self:Remove() end)
		end

		pulseOffset = 5*(math.sin((15)*(CurTime())))
	end
	notificationPanel.Paint = function(self, w, h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 200, 200, 200, 255 ), false, false, true, true )
		draw.RoundedBoxEx( 4, 1, 1, w-2, h - 2, Color( 222, 222, 222, 255 ), false, false, true, true )
		surface.SetDrawColor( Color(189, 189, 189, 255) )
		surface.DrawLine( 54, 4, 54, h - 4 )
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 )

		draw.SimpleText( text, "AthenaCourierNew13", 220, 5, Color( 149, 149, 149, 255), TEXT_ALIGN_CENTER)

		surface.DrawLine( 1, h-1, w-2, h-1 )
	end

	local headerTitle = vgui.Create("DLabel", notificationPanel)
	headerTitle:SetPos(7, 3)
	headerTitle:SetFont("AthenaNotificationTitle")
	headerTitle:SetText("Athena")
	headerTitle.Think = function(self)
		self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255))
	end
	headerTitle:SizeToContents()
end

net.Receive("Athena_newNotification", function(len)
	local data = net.ReadTable()
	local notificationType = net.ReadInt(4)
	Athena.Notifications.newNotification(notificationType, unpack(data))
end)

net.Receive("Athena_warnNotify", function(len)
	local admin = net.ReadString()
	local target = net.ReadString()
	local reason = net.ReadString()
	local severity = net.ReadUInt(2)

	chat.AddText( Color(21,101,192), ":: ", Color(25,118,210), "Athena", Color(21,101,192), " :: ", Color(94,53,177), admin, Color(151,211,255), " warned ", Color(94,53,177), target, Color(151,211,255), " for ", Color(150,40,40), reason, Color(151,211,255), " with severity ", Color(150,40,40), tostring(severity))

end)
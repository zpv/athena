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

function Athena.openOverview()
	local pageCreated = CurTime()
	local pageAlpha = 0
	local pulseOffset

	if Athena.Elements.displayedPage or IsValid(Athena.Elements.displayedPage) then Athena.Elements.displayedPage:Remove() end		
	Athena.Elements.displayedPage = vgui.Create("Panel", Athena.Elements.mainPanel)
	local parent = Athena.Elements.displayedPage:GetParent()
	Athena.Elements.displayedPage:SetPos(0, 0)
	Athena.Elements.displayedPage:SetSize(parent:GetWide(), parent:GetTall())
	Athena.Elements.displayedPage.Think = function()
		pulseOffset = 5*(math.sin((2)*(CurTime())))
		if (CurTime() - pageCreated) < 0.1 then return end
		if !Athena.initToggle and !(pageAlpha == 1) then
			pageAlpha = Lerp(0.05, pageAlpha, 1)
		elseif Athena.initToggle then
			pageAlpha = (pageAlpha < 0.01) and 0 or Lerp(Athena.Configuration.FadeMultiplier /1.5, pageAlpha, 0)
		end
	end

	
	--[[
	Athena.Elements.informationSection = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.informationSection:SetPos(0, 0)
	Athena.Elements.informationSection:SetSize(parent:GetWide() - 250, parent:GetTall())

	Athena.Elements.statisticsSection = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.statisticsSection:SetPos(649, 0)
	Athena.Elements.statisticsSection:SetSize(250, parent:GetTall())
	]]

	Athena.Elements.pageHeader = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.pageHeader:SetPos(0, 1)
	Athena.Elements.pageHeader:SetSize(parent:GetWide(), 90)
	Athena.Elements.pageHeader.Paint = function(self, w, h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )
		surface.SetDrawColor( Color( 232, 232, 232, 255*pageAlpha ) )
		surface.DrawLine( 0, h - 2, w-2, h - 2 )
		
		surface.SetDrawColor( Color( 242, 242, 242, 255*pageAlpha ) )
		surface.DrawLine( 0, h - 1, w-2, h - 1 )


		--
		surface.SetDrawColor( Color( 232, 232, 232, 255*pageAlpha ) )
		surface.DrawLine( w-2, 0, w-2, h - h )
		
		surface.SetDrawColor( Color( 242, 242, 242, 255*pageAlpha ) )
		surface.DrawLine( w-1, 0, w-1, h )

		draw.SimpleText( "Overview", "AthenaOswald40Bold", 25, 42, Color(51, 51, 51, 255*pageAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	--[[
	Athena.Elements.statisticsHeader = vgui.Create("Panel", Athena.Elements.statisticsSection)
	Athena.Elements.statisticsHeader:SetPos(0, 1)
	Athena.Elements.statisticsHeader:SetSize(251, 90)
	Athena.Elements.statisticsHeader.Paint = function(self, w, h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )
		surface.SetDrawColor( Color( 232, 232, 232, 255*pageAlpha ) )
		surface.DrawLine( 0, h - 2, w-2, h - 2 )
		
		surface.SetDrawColor( Color( 242, 242, 242, 255*pageAlpha ) )
		surface.DrawLine( 0, h - 1, w-2, h - 1 )

		
		surface.SetDrawColor( Color( 242, 242, 242, 255*pageAlpha ) )
		surface.DrawLine( 0, 0, 0, h - 1 )


		--
		surface.SetDrawColor( Color( 232, 232, 232, 255*pageAlpha ) )
		surface.DrawLine( w-2, 0, w-2, h - h )
		
		surface.SetDrawColor( Color( 242, 242, 242, 255*pageAlpha ) )
		surface.DrawLine( w-1, 0, w-1, h )

		draw.SimpleText( "Statistics", "AthenaOswald40Bold", 25, 42, Color(51, 51, 51, 255*pageAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end ]]

	Athena.Elements.onlinePlayers = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.onlinePlayers:SetPos(210, - 100)
	Athena.Elements.onlinePlayers:SetSize(185, 100)
	Athena.Elements.onlinePlayers.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )

		draw.SimpleText( "Online Players", "AthenaOswald25Normal", w / 2, 12, Color( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha ), TEXT_ALIGN_CENTER )

		surface.SetDrawColor( Color( 200, 200, 200, 255 * pageAlpha ) )
		surface.DrawLine( 24, 40, 156, 40 )
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha )

		surface.DrawLine( 27, 41, 153, 41 )
	end

	Athena.Elements.onlinePlayers:MoveToBack()
	Athena.Elements.onlinePlayers:MoveTo(210, 100, 0.4, 0, 0.3)

	Athena.Elements.reportQueue = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.reportQueue:SetPos(-200, 100)
	Athena.Elements.reportQueue:SetSize(190, 370)
	Athena.Elements.reportQueue.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )

		draw.SimpleText( "Queued Reports", "AthenaOswald25Normal", w / 2 - 5, 12, Color( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha ), TEXT_ALIGN_CENTER )

		surface.SetDrawColor( Color( 200, 200, 200, 255 * pageAlpha ) )
		surface.DrawLine( 24, 40, 156, 40 )
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha )

		surface.DrawLine( 27, 41, 153, 41 )
	end

	Athena.Elements.reportQueueScroll = vgui.Create("DScrollPanel", Athena.Elements.reportQueue)
	Athena.Elements.reportQueueScroll:SetSize(155, 310)
	Athena.Elements.reportQueueScroll:SetPos(20,50)
	Athena.Elements.reportQueueScroll.VBar.Paint = function(s, w, h)
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	Athena.Elements.reportQueueScroll.VBar.btnUp.Paint = function( s, w, h ) end
	Athena.Elements.reportQueueScroll.VBar.btnDown.Paint = function( s, w, h ) end
	Athena.Elements.reportQueueScroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end

	Athena.Elements.drawReportQueueList = function()

		if Athena.Elements.reportQueueList then Athena.Elements.reportQueueList:Remove() end

		Athena.Elements.reportQueueList = vgui.Create( "DIconLayout", Athena.Elements.reportQueueScroll )
		Athena.Elements.reportQueueList:SetSize( 140, Athena.Elements.reportQueueList:GetParent():GetTall() )
		Athena.Elements.reportQueueList:SetPos( 0, 0 )
		Athena.Elements.reportQueueList:SetSpaceY( 5 )

		for k,v in pairs(Athena.Client.Reports) do 
			if not (Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_COMPLETED	) then
				local ListItem = Athena.Elements.reportQueueList:Add( "DButton" )
				local timeOfReport = os.date("%I:%M %p",v["timeOfReport"])
				ListItem:SetSize( 140, 40 )
				ListItem:SetText("")
				ListItem.drawAvatar = function(self)
					Athena.Elements.Avatars[v["UID"]] = vgui.Create("AvatarImage", self)
					Athena.Elements.Avatars[v["UID"]]:SetSize(32, 32)
					Athena.Elements.Avatars[v["UID"]]:SetPos(4, 4)
					if Athena.isSteamID(v["reporterID"]) then Athena.Elements.Avatars[v["UID"]]:SetSteamID(Athena.SteamIdToCommunityId(v["reporterID"]), 32) return end
					Athena.Elements.Avatars[v["UID"]]:SetSteamID(v["reporterID"], 32)
				end
				ListItem.Paint = function(self, w, h)
					draw.RoundedBox( 2, 0, 1, w, h, Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS and Color( 200, 200, 200, 150*pageAlpha ) or Color( 200, 200, 200, 255*pageAlpha ) )
					draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS and Color( 244, 244, 244, 150*pageAlpha ) or Color( 244, 244, 244, 255*pageAlpha ), false, false, true, true )
					if not IsValid(Athena.Elements.Avatars[v["UID"]]) then
						self:drawAvatar()
					end
					draw.SimpleText( v["reporter"], "AthenaOswald20Normal", 40, 1, Color( 144, 144, 144, 255* pageAlpha ) )
					draw.SimpleText( timeOfReport, "AthenaOswald20Light", 40, 18, Color( 144, 144, 144, 255* pageAlpha ) )
					draw.SimpleText( Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS and "Ongoing" or Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_WAITING and "Waiting" or Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_COMPLETED and "Complete", "AthenaCourierNew11", 135, 25, Color( 144, 144, 144, 255* pageAlpha ),TEXT_ALIGN_RIGHT)
					if Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS then

						draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 100*pageAlpha ), false, false, true, true )
					elseif Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_COMPLETED then
						draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 155, 244, 155, 100*pageAlpha ), false, false, true, true )
					end

				end 

				ListItem.DoClick = function(self)
					local ply = Athena.findUserByID(v["reporterID"])
					local hasReported = v["reportedID"] or false
					local rply = hasReported and Athena.findUserByID(v["reportedID"]) or false

					local context = DermaMenu(self)
					local status = context:AddOption(ply and "Reporter | Online" or "Reporter | Offline")
					status:SetTextColor( Color( 170, 170, 170 ) )
					status.OnMousePressed = function() end
					
					context:AddSpacer()
					context:AddOption("Copy Name: " .. v["reporter"], function() SetClipboardText(v["reporter"]) end):SetImage("icon16/user_edit.png")
					context:AddOption("Copy SteamID: " .. v["reporterID"], function() SetClipboardText(v["reporterID"]) end):SetImage("icon16/tag_blue.png")
					context:AddOption("Steam Community Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. Athena.SteamIdToCommunityId(v["reporterID"])) end):SetImage("icon16/world.png")
					context:Open()
					if ply and IsValid(ply) then
						local admintools,menuimg = context:AddSubMenu("Admin")
						menuimg:SetImage("icon16/shield.png")
						admintools:AddOption("Spectate", function() RunConsoleCommand("ulx", "spectate", ply:Nick()) end)
						context:AddSpacer()
						admintools:AddOption("Bring", function() RunConsoleCommand("ulx", "bring", ply:Nick()) end)
						admintools:AddOption("Goto", function() RunConsoleCommand("ulx", "goto", ply:Nick()) end)
						admintools:AddOption("Teleport", function() RunConsoleCommand("ulx", "teleport", ply:Nick()) end)
					else
						context:AddSpacer()
					end

					if hasReported then
						local rstatus = context:AddOption(rply and "Reported | Online" or "Reported | Offline")
						rstatus:SetTextColor( Color( 170, 170, 170 ) )
						rstatus.OnMousePressed = function() end
						context:AddSpacer()
						context:AddOption("Copy Name: " .. v["reported"], function() SetClipboardText(v["reported"]) end):SetImage("icon16/user_edit.png")
						context:AddOption("Copy SteamID: " .. v["reportedID"], function() SetClipboardText(v["reportedID"]) end):SetImage("icon16/tag_blue.png")
						context:AddOption("Steam Community Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. Athena.SteamIdToCommunityId(v["reportedID"])) end):SetImage("icon16/world.png")
						context:Open()
						if rply and IsValid(rply) then
							local admintools,menuimg = context:AddSubMenu("Admin")
							menuimg:SetImage("icon16/shield.png")
							admintools:AddOption("Spectate", function() RunConsoleCommand("ulx", "spectate", rply:Nick()) end)
							context:AddSpacer()
							admintools:AddOption("Bring", function() RunConsoleCommand("ulx", "bring", rply:Nick()) end)
							admintools:AddOption("Goto", function() RunConsoleCommand("ulx", "goto", rply:Nick()) end)
							admintools:AddOption("Teleport", function() RunConsoleCommand("ulx", "teleport", rply:Nick()) end)
						else
							context:AddSpacer()
						end
					end
				end

				ListItem.DoRightClick = function(self)
					local context = DermaMenu(self)
					
					context:AddSpacer()
					context:AddOption("Mark as Complete", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_COMPLETED) end):SetImage("icon16/tick.png")
					context:AddOption("Mark as Ongoing", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_INPROGRESS) end):SetImage("icon16/time_go.png")
					context:AddOption("Mark as Waiting", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_WAITING) end):SetImage("icon16/time.png")
					context:Open()
				end
			end
		end

		Athena.Elements.reportQueue:MoveTo(10, 100, 0.4, 0, 0.3)

	end

	Athena.Elements.drawReportQueueList()


end
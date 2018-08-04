--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

function Athena.openReports()
	
	local pageAlpha = 0
	local reportAlpha = 0
	Athena.pageCreated = CurTime()
	Athena.reportCreated = CurTime()
	local pulseOffset
	local selectedReportID
	local selectedReport

	if Athena.Elements.displayedPage or IsValid(Athena.Elements.displayedPage) then Athena.Elements.displayedPage:Remove() end		
	Athena.Elements.displayedPage = vgui.Create("Panel", Athena.Elements.mainPanel)
	local parent = Athena.Elements.displayedPage:GetParent()
	Athena.Elements.displayedPage:SetPos(0, 0)
	Athena.Elements.displayedPage:SetSize(parent:GetWide(), parent:GetTall())
	Athena.Elements.displayedPage.Think = function()
		pulseOffset = 5*(math.sin((2)*(CurTime())))
		if (CurTime() - Athena.pageCreated) < 0.1 then return end
		if !Athena.initToggle and !(pageAlpha == 1) then
			pageAlpha = math.Clamp((CurTime()-Athena.pageCreated)/0.5,0,1)
		elseif Athena.initToggle then
			pageAlpha = (pageAlpha < 0.01) and 0 or math.Clamp((-(CurTime()-Athena.initRemoveTime)/Athena.Configuration.FadeMultiplier)+ 1,0,1)
			reportAlpha = (reportAlpha < 0.01) and 0 or math.Clamp((-(CurTime()-Athena.initRemoveTime)/Athena.Configuration.FadeMultiplier)+ 1,0,1)
		end

		if selectedReportID and !(Athena.initToggle) then
			reportAlpha = math.Clamp((CurTime()-Athena.reportCreated)/0.25,0,1)
		end
	end

	--[[

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

		draw.SimpleText( "Reports", "AthenaOswald40Bold", 25, 42, Color(51, 51, 51, 255*pageAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	]]

	Athena.Elements.report = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.report:SetPos(-200, 12)
	Athena.Elements.report:SetSize(190, 457)
	Athena.Elements.report.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )

		draw.SimpleText( "Queued Reports", "AthenaOswald25Normal", w / 2 - 5, 12, Color( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha ), TEXT_ALIGN_CENTER )

		surface.SetDrawColor( Color( 200, 200, 200, 255 * pageAlpha ) )
		surface.DrawLine( 24, 40, 156, 40 )
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha )

		surface.DrawLine( 27, 41, 153, 41 )
	end

	Athena.Elements.reportDetailsPanel = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.reportDetailsPanel:SetPos(210, 12)
	Athena.Elements.reportDetailsPanel:SetSize(675, 457)
	Athena.Elements.reportDetailsPanel.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )
		if not selectedReportID then
			draw.SimpleText( "NO REPORT SELECTED", "AthenaBebas33Normal", w / 2 - 5, h / 2 - 35, Color(183,183,183, 255*pageAlpha), TEXT_ALIGN_CENTER )
		end

	end

	Athena.Elements.reportDetails = vgui.Create("Panel", Athena.Elements.reportDetailsPanel)
	Athena.Elements.reportDetails:SetPos(0,0)
	Athena.Elements.reportDetails:SetSize(675, 456)
	Athena.Elements.reportDetails:SetVisible(false)
	Athena.Elements.reportDetails.Paint = function(self, w, h)
		if selectedReportID then
			selectedReport = Athena.Client.Reports[selectedReportID]
			draw.SimpleText( selectedReport and (selectedReport.reporter .. "'s Report [ID #" .. selectedReportID .."]") or "Select A Report", "AthenaOswald25Normal", w / 2 - 5, 9, Color(150, 150, 150, 255 *reportAlpha ), TEXT_ALIGN_CENTER )
			surface.SetDrawColor( Color( 200, 200, 200, 255 * reportAlpha ) )
			surface.DrawLine( 24, 40, w - 24, 40 )

		end
	end
	Athena.Elements.reportDetailsElements = vgui.Create("Panel", Athena.Elements.reportDetails)
	Athena.Elements.reportDetailsElements:SetPos(24,50)
	Athena.Elements.reportDetailsElements:SetSize(627, 400)

	Athena.Elements.reportDetailsElements.Paint = function(self, w, h)
		surface.SetDrawColor( Color( 200, 200, 200, 255 * reportAlpha ) )
		surface.DrawLine( 0, 40, w, 40 )
		if selectedReport then
			draw.SimpleText("Time of Report: " .. os.date("%c", selectedReport.timeOfReport), "DebugFixed", w-235, 1, Color(150,150,150, 255*reportAlpha))
			local statusText = Athena.Client.Reports[tonumber(selectedReport.id)].status == ATHENA_STATUS_INPROGRESS and "Ongoing" or Athena.Client.Reports[tonumber(selectedReport.id)].status == ATHENA_STATUS_WAITING and "Waiting" or Athena.Client.Reports[tonumber(selectedReport.id)].status == ATHENA_STATUS_COMPLETED and "Complete" or "nil"
			draw.SimpleText("Report Status: " .. statusText, "DebugFixed", w-235, 15, Color(150,150,150, 255*reportAlpha))
			draw.SimpleText("Reporter: " .. selectedReport.reporter .. " ["..selectedReport.reporterID.."]", "DebugFixed", 5, 1, Color(150,150,150, 255*reportAlpha))
			draw.SimpleText("Reported: " .. (selectedReport.reported and selectedReport.reported .. " [" ..selectedReport.reportedID.."]" or "N/A"), "DebugFixed", 5, 15, Color(150,150,150, 255*reportAlpha))

			draw.SimpleText("Report Transcript: ", "DebugFixed", 5, 45, Color(150,150,150, 255*reportAlpha))
			--Athena.Elements.reportDetailsElements.reportMessage:SetText(selectedReport.message)

			surface.SetDrawColor( Color( 200, 200, 200, 255 * reportAlpha ) )
			surface.DrawLine( 475, 40, 475, h )

		end
	end
	
	Athena.Elements.reportDetailsElements.reportMessage = vgui.Create("DTextEntry", Athena.Elements.reportDetailsElements)
	Athena.Elements.reportDetailsElements.reportMessage:SetPos(2,60)
	Athena.Elements.reportDetailsElements.reportMessage:SetSize(465,350)
	Athena.Elements.reportDetailsElements.reportMessage:SetText("")
	Athena.Elements.reportDetailsElements.reportMessage:SetDrawBackground(false)
	Athena.Elements.reportDetailsElements.reportMessage:SetFont("DebugFixed")
	Athena.Elements.reportDetailsElements.reportMessage:SetMultiline(true)
	Athena.Elements.reportDetailsElements.reportMessage:AllowInput(false)
	Athena.Elements.reportDetailsElements.reportMessage.reportID = nil
	Athena.Elements.reportDetailsElements.Think = function()
		Athena.Elements.reportDetailsElements.reportMessage:SetTextColor(Color(150,150,150,255*reportAlpha))
		if selectedReportID and selectedReport != Athena.Elements.reportDetailsElements.reportMessage.reportID then
			Athena.Elements.reportDetailsElements.reportMessage.reportID = selectedReportID
			Athena.Elements.reportDetailsElements.reportMessage:SetText(selectedReport.message)
		end
	end

	Athena.Elements.reportDetailsElements.managementActions = vgui.Create("DButton", Athena.Elements.reportDetailsElements)
	Athena.Elements.reportDetailsElements.managementActions:SetPos(480, 45)
	Athena.Elements.reportDetailsElements.managementActions:SetSize(147, 30)
	Athena.Elements.reportDetailsElements.managementActions:SetText("")
	Athena.Elements.reportDetailsElements.managementActions.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 1, w, h, Color( 200, 200, 200, 255*reportAlpha ) )
		draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 255*reportAlpha ), false, false, true, true )
		draw.SimpleText("Quick Actions", "AthenaCourierNew11", w/2, h/2, Color(155,155,155,255*reportAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	Athena.Elements.reportDetailsElements.managementActions.DoClick = function(self)
		Athena.Tick()
		local ply = Athena.findUserByID(selectedReport["reporterID"])
		local hasReported = selectedReport["reportedID"] or false
		local rply = (hasReported and Athena.findUserByID(selectedReport["reportedID"])) or false

		local context = DermaMenu(self)
		local status = context:AddOption(ply and "Reporter | Online" or "Reporter | Offline")
		status:SetTextColor( Color( 170, 170, 170 ) )
		status.OnMousePressed = function() end
		
		context:AddSpacer()
		context:AddOption("Copy Name: " .. selectedReport["reporter"], function() SetClipboardText(selectedReport["reporter"]) end):SetImage("icon16/user_edit.png")
		context:AddOption("Copy SteamID: " .. selectedReport["reporterID"], function() SetClipboardText(selectedReport["reporterID"]) end):SetImage("icon16/tag_blue.png")
		context:AddOption("Steam Community Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. Athena.SteamIdToCommunityId(selectedReport["reporterID"])) end):SetImage("icon16/world.png")
		context:Open()
		if ply and IsValid(ply) then
			local admintools,menuimg = context:AddSubMenu("Admin")
			menuimg:SetImage("icon16/shield.png")
			Athena.Elements.BuildActions(admintools,ply)
		end
		context:AddSpacer()

		if hasReported then
			local rstatus = context:AddOption(rply and "Reported | Online" or "Reported | Offline")
			rstatus:SetTextColor( Color( 170, 170, 170 ) )
			rstatus.OnMousePressed = function() end
			context:AddSpacer()
			context:AddOption("Copy Name: " .. selectedReport["reported"], function() SetClipboardText(selectedReport["reported"]) end):SetImage("icon16/user_edit.png")
			context:AddOption("Copy SteamID: " .. selectedReport["reportedID"], function() SetClipboardText(selectedReport["reportedID"]) end):SetImage("icon16/tag_blue.png")
			context:AddOption("Steam Community Profile", function() gui.OpenURL("http://steamcommunity.com/profiles/" .. Athena.SteamIdToCommunityId(selectedReport["reportedID"])) end):SetImage("icon16/world.png")
			context:Open()
			if rply and IsValid(rply) then
				local admintools,menuimg = context:AddSubMenu("Admin")
				menuimg:SetImage("icon16/shield.png")
				Athena.Elements.BuildActions(admintools,rply)
			end
			context:AddSpacer()
		end 
	end


	Athena.Elements.reportDetailsElements.markOngoing = vgui.Create("DButton", Athena.Elements.reportDetailsElements)
	Athena.Elements.reportDetailsElements.markOngoing:SetPos(480, 80)
	Athena.Elements.reportDetailsElements.markOngoing:SetSize(147, 30)
	Athena.Elements.reportDetailsElements.markOngoing:SetText("")
	Athena.Elements.reportDetailsElements.markOngoing.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 1, w, h, Color( 200, 200, 200, 255*reportAlpha ) )
		draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 255*reportAlpha ), false, false, true, true )
	
		draw.SimpleText("Mark as Ongoing", "AthenaCourierNew11", w/2, h/2, Color(155,155,155,255*reportAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	Athena.Elements.reportDetailsElements.markOngoing.DoClick = function()
		Athena.Tick()
		Athena.Client.updateStatus(selectedReport.id, ATHENA_STATUS_INPROGRESS)
	end

	Athena.Elements.reportDetailsElements.markComplete = vgui.Create("DButton", Athena.Elements.reportDetailsElements)
	Athena.Elements.reportDetailsElements.markComplete:SetPos(480, 115)
	Athena.Elements.reportDetailsElements.markComplete:SetSize(147, 30)
	Athena.Elements.reportDetailsElements.markComplete:SetText("")
	Athena.Elements.reportDetailsElements.markComplete.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 1, w, h, Color( 200, 200, 200, 255*reportAlpha ) )
		draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 255*reportAlpha ), false, false, true, true )
		draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 155, 244, 155, 100*reportAlpha ), false, false, true, true )
		draw.SimpleText("Mark as Complete", "AthenaCourierNew11", w/2, h/2, Color(155,155,155,255*reportAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	Athena.Elements.reportDetailsElements.markComplete.DoClick = function()
		Athena.Tick()
		Athena.Client.updateStatus(selectedReport.id, ATHENA_STATUS_COMPLETED)
	end

	Athena.Elements.reportDetailsElements.copyTranscript = vgui.Create("DButton", Athena.Elements.reportDetailsElements)
	Athena.Elements.reportDetailsElements.copyTranscript:SetPos(480, 368)
	Athena.Elements.reportDetailsElements.copyTranscript:SetSize(147, 30)
	Athena.Elements.reportDetailsElements.copyTranscript:SetText("")
	Athena.Elements.reportDetailsElements.copyTranscript.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 1, w, h, Color( 200, 200, 200, 255*reportAlpha ) )
		draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 255*reportAlpha ), false, false, true, true )

		draw.SimpleText("Copy Transcript", "AthenaCourierNew11", w/2, h/2, Color(155,155,155,255*reportAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	Athena.Elements.reportDetailsElements.copyTranscript.DoClick = function()
		Athena.Tick()
		SetClipboardText(selectedReport.message)
	end

	Athena.Elements.reportScroll = vgui.Create("DScrollPanel", Athena.Elements.report)
	Athena.Elements.reportScroll:SetSize(155, 400)
	Athena.Elements.reportScroll:SetPos(20,50)
	Athena.Elements.reportScroll.VBar.Paint = function(s, w, h)
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	Athena.Elements.reportScroll.VBar.btnUp.Paint = function( s, w, h ) end
	Athena.Elements.reportScroll.VBar.btnDown.Paint = function( s, w, h ) end
	Athena.Elements.reportScroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end

	Athena.Elements.drawreportList = function()

		if Athena.Elements.reportList then Athena.Elements.reportList:Remove() end

		Athena.Elements.reportList = vgui.Create( "DIconLayout", Athena.Elements.reportScroll )
		Athena.Elements.reportList:SetSize( 140, Athena.Elements.reportList:GetParent():GetTall() )
		Athena.Elements.reportList:SetPos( 0, 0 )
		Athena.Elements.reportList:SetSpaceY( 5 )
		Athena.HideCompleted = true
		Athena.Elements.reportList.reportsCopy = table.Copy(Athena.Client.Reports)
		table.sort(Athena.Elements.reportList.reportsCopy, function(a, b) return a["timeOfReport"] < b["timeOfReport"] end)
		for k,v in pairs(Athena.Elements.reportList.reportsCopy) do 
			if not (Athena.HideCompleted and Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_COMPLETED) then
				local ListItem = Athena.Elements.reportList:Add( "DButton" )
				local timeOfReport = os.date("%I:%M %p",v["timeOfReport"])
				ListItem:SetSize( 140, 40 )
				ListItem:SetText("")
				ListItem.drawAvatar = function(self)
					Athena.Elements.Avatars[v.id] = vgui.Create("AvatarImage", self)
					Athena.Elements.Avatars[v.id]:SetSize(32, 32)
					Athena.Elements.Avatars[v.id]:SetPos(4, 4)
					if Athena.isSteamID(v["reporterID"]) then Athena.Elements.Avatars[v.id]:SetSteamID(Athena.SteamIdToCommunityId(v["reporterID"]), 32) return end
					Athena.Elements.Avatars[v.id]:SetSteamID(v["reporterID"], 32)
				end
				ListItem.Paint = function(self, w, h)
					draw.RoundedBox( 2, 0, 1, w, h, Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_INPROGRESS and Color( 200, 200, 200, 150*pageAlpha ) or Color( 200, 200, 200, 255*pageAlpha ) )
					draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_INPROGRESS and Color( 244, 244, 244, 150*pageAlpha ) or Color( 244, 244, 244, 255*pageAlpha ), false, false, true, true )
					if not IsValid(Athena.Elements.Avatars[v.id]) then
						self:drawAvatar()
					end
					Athena.Elements.Avatars[v.id]:SetAlpha(255 * pageAlpha)
					draw.SimpleText( v["reporter"], "AthenaOswald20Normal", 40, 1, Color( 144, 144, 144, 255* pageAlpha ) )
					draw.SimpleText( timeOfReport, "AthenaOswald20Light", 40, 18, Color( 144, 144, 144, 255* pageAlpha ) )
					draw.SimpleText( Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_INPROGRESS and "Ongoing" or Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_WAITING and "Waiting" or Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_COMPLETED and "Complete", "AthenaCourierNew11", 135, 25, Color( 144, 144, 144, 255* pageAlpha ),TEXT_ALIGN_RIGHT)
					if Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_INPROGRESS then

						draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 244, 244, 244, 100*pageAlpha ), false, false, true, true )
					elseif Athena.Client.ReportStatuses[tonumber(v.id)] == ATHENA_STATUS_COMPLETED then
						draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 155, 244, 155, 100*pageAlpha ), false, false, true, true )
					end

				end 

				ListItem.DoClick = function(self)
					Athena.Tick()
					selectedReportID = k
					Athena.reportCreated = CurTime()
					Athena.reportAlpha = 0
					Athena.Elements.reportDetails:SetVisible(true)

					--[[

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
					end ]]
				end

				ListItem.DoRightClick = function(self)
					local context = DermaMenu(self)
					
					context:AddSpacer()
					context:AddOption("Mark as Complete", function() Athena.Client.updateStatus(v.id, ATHENA_STATUS_COMPLETED) end):SetImage("icon16/tick.png")
					context:AddOption("Mark as Ongoing", function() Athena.Client.updateStatus(v.id, ATHENA_STATUS_INPROGRESS) end):SetImage("icon16/time_go.png")
					context:AddOption("Mark as Waiting", function() Athena.Client.updateStatus(v.id, ATHENA_STATUS_WAITING) end):SetImage("icon16/time.png")
					context:Open()
				end
			end
		end

		Athena.Elements.report:MoveTo(10, 12, 0.4, 0, 0.3)

	end

	Athena.Elements.drawreportList()


end
--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

function Athena.openWarnings()

	local pageAlpha = 0
	local warningAlpha = 0
	Athena.pageCreated = CurTime()
	Athena.warningCreated = CurTime()
	local pulseOffset
	local selectedPlayerID
	local selectedPlayer

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
			warningAlpha = (warningAlpha < 0.01) and 0 or math.Clamp((-(CurTime()-Athena.initRemoveTime)/Athena.Configuration.FadeMultiplier)+ 1,0,1)
		end

		if selectedPlayerID and !(Athena.initToggle) then
			warningAlpha = math.Clamp((CurTime()-Athena.warningCreated)/0.25,0,1)
		end
	end

	Athena.Elements.players = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.players:SetPos(-200, 12)
	Athena.Elements.players:SetSize(190, 457)
	Athena.Elements.players.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )

		draw.SimpleText( "Online Players", "AthenaOswald25Normal", w / 2 - 5, 12, Color( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha ), TEXT_ALIGN_CENTER )

		surface.SetDrawColor( Color( 200, 200, 200, 255 * pageAlpha ) )
		surface.DrawLine( 24, 40, 156, 40 )
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *pageAlpha )

		surface.DrawLine( 27, 41, 153, 41 )
	end

	Athena.Elements.warningDetailsPanel = vgui.Create("Panel", Athena.Elements.displayedPage)
	Athena.Elements.warningDetailsPanel:SetPos(210, 12)
	Athena.Elements.warningDetailsPanel:SetSize(675, 457)
	Athena.Elements.warningDetailsPanel.Paint = function(self, w, h)
		draw.RoundedBox( 2, 0, 0, w, h, Color( 239, 239, 239, 255*pageAlpha ) )
		draw.RoundedBoxEx( 2, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255*pageAlpha ), false, false, true, true )
		if not selectedPlayerID then
			draw.SimpleText( "NO PLAYER SELECTED", "AthenaBebas33Normal", w / 2 - 5, h / 2 - 35, Color(183,183,183, 255*pageAlpha), TEXT_ALIGN_CENTER )
		end

	end

	Athena.Elements.warningDetails = vgui.Create("Panel", Athena.Elements.warningDetailsPanel)
	Athena.Elements.warningDetails:SetPos(0,0)
	Athena.Elements.warningDetails:SetSize(675, 456)
	Athena.Elements.warningDetails:SetVisible(false)
	Athena.Elements.warningDetails.Paint = function(self, w, h)
		if selectedPlayerID then
			selectedPlayer = player.GetBySteamID64(selectedPlayerID)
			draw.SimpleText( selectedPlayer and (selectedPlayer:Nick() .. "'s Warnings") or "Player Not Online", "AthenaOswald25Normal", w / 2 - 5, 9, Color(150, 150, 150, 255 *warningAlpha ), TEXT_ALIGN_CENTER )
			surface.SetDrawColor( Color( 200, 200, 200, 255 * warningAlpha ) )
			surface.DrawLine( 24, 40, w - 24, 40 )
		end
	end

	Athena.Elements.warningDetailsElements = vgui.Create("DListView", Athena.Elements.warningDetails)
	Athena.Elements.warningDetailsElements:SetPos(24,50)
	Athena.Elements.warningDetailsElements:SetSize(627, 400)
	Athena.Elements.warningDetailsElements.Think = function()
		Athena.Elements.warningDetailsElements:SetAlpha(255 * warningAlpha)
	end
	Athena.Elements.warningDetailsElements:AddColumn("Reason"):SetFixedWidth( 280 )
	Athena.Elements.warningDetailsElements:AddColumn("Time")
	Athena.Elements.warningDetailsElements:AddColumn("Warner")
	Athena.Elements.warningDetailsElements:AddColumn("Severity")

	Athena.Elements.warningDetailsElements.repopulateTable = function()
		Athena.Elements.warningDetailsElements:Clear()
		if Athena.Client.Warnings[selectedPlayerID] then
			for k,v in pairs(Athena.Client.Warnings[selectedPlayerID]) do
				local line = Athena.Elements.warningDetailsElements:AddLine(v["description"], os.date("%x %I:%M %p",v["time"]), v["warner"], v["severity"])
				line.timeID = v["time"]
				line.OnRightClick = function()
					if LocalPlayer():IsSuperAdmin() then				
						local context = DermaMenu(self)
						context:AddSpacer()
						context:AddOption("Remove Warning", function() Athena.Client.removeWarning(selectedPlayerID, v["time"]) table.remove(Athena.Client.Warnings[selectedPlayerID], k) Athena.Elements.warningDetailsElements.refreshData() end):SetImage("icon16/cross.png")
						context:Open()
					end
				end
			end
		end

	end

	Athena.Elements.warningDetailsElements.refreshData = function()
		Athena.Client.requestWarnings(selectedPlayerID)
		Athena.Elements.warningDetailsElements.repopulateTable()
	end

	Athena.Elements.playersScroll = vgui.Create("DScrollPanel", Athena.Elements.players)
	Athena.Elements.playersScroll:SetSize(155, 400)
	Athena.Elements.playersScroll:SetPos(20,50)
	Athena.Elements.playersScroll.VBar.Paint = function(s, w, h)
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	Athena.Elements.playersScroll.VBar.btnUp.Paint = function( s, w, h ) end
	Athena.Elements.playersScroll.VBar.btnDown.Paint = function( s, w, h ) end
	Athena.Elements.playersScroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end


	Athena.Elements.drawwarningList = function()

		if Athena.Elements.playersList then Athena.Elements.playersList:Remove() end

		Athena.Elements.playersList = vgui.Create( "DIconLayout", Athena.Elements.playersScroll )
		Athena.Elements.playersList:SetSize( 140, Athena.Elements.playersList:GetParent():GetTall() )
		Athena.Elements.playersList:SetPos( 0, 0 )
		Athena.Elements.playersList:SetSpaceY( 5 )
	--	Athena.HideCompleted = true
	--	Athena.Elements.playersList.warningsCopy = table.Copy(Athena.Client.Reports)
	--	table.sort(Athena.Elements.playersList.warningsCopy, function(a, b) return a["timeOfReport"] < b["timeOfReport"] end)
		for k,v in pairs(player.GetAll()) do 
				local pID = v:SteamID64()
				local pName = v:Nick()
				local ListItem = Athena.Elements.playersList:Add( "DButton" )
				ListItem:SetSize( 140, 30 )
				ListItem:SetText("")
				ListItem.drawAvatar = function(self)
					Athena.Elements.Avatars[pID or "BOT"] = vgui.Create("AvatarImage", self)
					Athena.Elements.Avatars[pID or "BOT"]:SetSize(24, 24)
					Athena.Elements.Avatars[pID or "BOT"]:SetPos(3, 3)
					Athena.Elements.Avatars[pID or "BOT"]:SetSteamID(pID or "BOT", 32)
				end
				ListItem.Paint = function(self, w, h)
					draw.RoundedBox( 2, 0, 1, w, h, Color( 200, 200, 200, 150*pageAlpha ) )

					draw.RoundedBoxEx( 2, 0, 0, w - 1, h - 1, Color( 244, 244, 244, 150*pageAlpha ), false, false, true, true )

					if not IsValid(Athena.Elements.Avatars[pID]) then
						self:drawAvatar()
					end
					Athena.Elements.Avatars[pID or "BOT"]:SetAlpha(255 * pageAlpha)
					draw.SimpleText( pName, "AthenaOswald20Normal", 33, 5, Color( 100, 100, 100, 255* pageAlpha ) )
				--	draw.SimpleText( timeOfReport, "AthenaOswald20Light", 40, 18, Color( 144, 144, 144, 255* pageAlpha ) )
				--	draw.SimpleText( Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS and "Ongoing" or Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_WAITING and "Waiting" or Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_COMPLETED and "Complete", "AthenaCourierNew11", 135, 25, Color( 144, 144, 144, 255* pageAlpha ),TEXT_ALIGN_RIGHT)
				--	if Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_INPROGRESS then

						draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 244, 244, 244, 100*pageAlpha ), false, false, true, true )
				--	elseif Athena.Client.ReportStatuses[tonumber(v["UID"])] == ATHENA_STATUS_COMPLETED then
				--		draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 155, 244, 155, 100*pageAlpha ), false, false, true, true )
				--	end

				end 

				ListItem.DoClick = function(self)
					Athena.Tick()
					selectedPlayerID = pID
					Athena.warningCreated = CurTime()
					Athena.warningAlpha = 0
					Athena.Elements.warningDetails:SetVisible(true)
					Athena.Elements.warningDetailsElements.refreshData()
				end

				ListItem.DoRightClick = function(self)
					local context = DermaMenu(self)
					
					context:AddSpacer()
				--	context:AddOption("Mark as Complete", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_COMPLETED) end):SetImage("icon16/tick.png")
				--	context:AddOption("Mark as Ongoing", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_INPROGRESS) end):SetImage("icon16/time_go.png")
				--	context:AddOption("Mark as Waiting", function() Athena.Client.updateStatus(v["UID"], ATHENA_STATUS_WAITING) end):SetImage("icon16/time.png")
					context:Open()
				end
			end

		Athena.Elements.players:MoveTo(10, 12, 0.4, 0, 0.3)

	end

	Athena.Elements.drawwarningList()

end
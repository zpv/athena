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

Athena.warningsMenu = {}
Athena.Elements.warningsMenu= {}

local blur = Material( "pp/blurscreen" )
local function drawPanelBlur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 3 do
        blur:SetFloat( "$blur", ( i / layers ) * density )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

function Athena.buildWarningsMenu()
		local createdTime = CurTime()
		--alpha = math.Clamp((CurTime()-createdTime/Athena.Configuration.FadeTime),0,1)
		local alpha = 0
		local initRemoveTime = 0
		local totalSeverity = 0
		local pulseOffset = 5*(math.sin((10)*(CurTime())))

		local selectedPlayerID = LocalPlayer():SteamID64()

		Athena.warningsMenu.initToggle = false
		Athena.warningsMenu.menuExists = true
		Athena.warningsMenu.menuOpen = true

		Athena.Elements.warningsMenu.blurredBackground = vgui.Create("Panel")
		Athena.Elements.warningsMenu.blurredBackground:SetSize(645, 435)
		Athena.Elements.warningsMenu.blurredBackground:Center()
		Athena.Elements.warningsMenu.blurredBackground.Paint = function(self, w, h)
			drawPanelBlur(self, 4, 12, 255*alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 155+ pulseOffset * 4, 155+ pulseOffset * 4, 155+ pulseOffset * 4, 50*alpha ), false, false, false, false )
		end


		Athena.Elements.warningsMenu.mainFrame = vgui.Create("DFrame")
		Athena.Elements.warningsMenu.mainFrame:SetSize(650, 435)
		Athena.Elements.warningsMenu.mainFrame:Center()
		Athena.Elements.warningsMenu.mainFrame:SetTitle("")
		Athena.Elements.warningsMenu.mainFrame:MakePopup()
		Athena.Elements.warningsMenu.mainFrame:SetKeyboardInputEnabled(true)
		Athena.Elements.warningsMenu.mainFrame:ShowCloseButton(false)
		Athena.Elements.warningsMenu.mainFrame:SetDraggable(false)

		Athena.Elements.warningsMenu.mainFrame.ToggleMenu = function(self)
			if Athena.warningsMenu.menuOpen then
				self:SetVisible(false)
				--self:SetKeyboardInputEnabled(false)
				--self:SetMouseInputEnabled(false)
				Athena.warningsMenu.initToggle = false
			else
				self:SetVisible(true)
				--self:SetKeyboardInputEnabled(true)
				self:SetMouseInputEnabled(true)
				createdTime = CurTime()
			end
			Athena.warningsMenu.menuOpen = !Athena.warningsMenu.menuOpen

		end

		Athena.Elements.warningsMenu.mainFrame.StartToggle = function(self)
			self:SetKeyboardInputEnabled(false)
			self:SetMouseInputEnabled(false)
			Athena.warningsMenu.initToggle = true
			initRemoveTime = CurTime()
		end

		Athena.Elements.warningsMenu.mainFrame.oldRemove = Athena.Elements.warningsMenu.mainFrame.Remove
		Athena.Elements.warningsMenu.mainFrame.Remove = function(self)
			timer.Simple(5, function()
				Athena.Elements.warningsMenu.mainFrame.oldRemove(self)
				Athena.warningsMenu.menuExists = false
			end)
			return
		end

		Athena.Elements.warningsMenu.mainFrame.Close = function(self)
			self:Remove()
		end

		Athena.Elements.warningsMenu.mainFrame.OnRemove = function()
			Athena.menuOpen = false
		end

		Athena.Elements.warningsMenu.mainFrame.Paint = function(self, w, h)
			if !Athena.warningsMenu.initToggle and !(alpha == 1) then
				alpha = math.Clamp((CurTime()-createdTime)/0.4,0,1)
				--alpha = Lerp(Athena.Configuration.FadeMultiplier / 6, alpha, 1)
			elseif Athena.warningsMenu.initToggle then
				--if alpha == 0 then
				--	oldRemove(self)
				--end
				--alpha = math.Clamp((-(CurTime()-initRemoveTime)/Athena.Configuration.FadeTime)+ 1,0,1)
				alpha = (alpha < 0.01) and self.oldRemove(self) and 0 or math.Clamp((-(CurTime()-initRemoveTime)/Athena.Configuration.FadeMultiplier)+ 1,0,1)
			end
			draw.RoundedBoxEx( 4, 0, 0, w, 45, Color( 200, 200, 200, 255*alpha ), true, true, false, false )
			draw.RoundedBoxEx( 4, 1, 1, w-2, 43, Color( 222, 222, 222, 255*alpha ), true, true, false, false )
			
			surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *alpha )

			surface.DrawLine( 1, 45, w-2, 45 )
		end

		local oldMainFrameThink = Athena.Elements.warningsMenu.mainFrame.Think
		Athena.Elements.warningsMenu.mainFrame.Think = function(self)
			pulseOffset = 5*(math.sin((10)*(CurTime())))
			oldMainFrameThink(self)
		end

		local closeButton = vgui.Create("DButton", Athena.Elements.warningsMenu.mainFrame)
		closeButton:SetSize(32, 32)
		closeButton:SetPos(Athena.Elements.warningsMenu.mainFrame:GetWide() - 38, 6)
		closeButton:SetText("r")
		closeButton:SetFont( "marlett" )
		closeButton.Paint = function(self)
			self:SetTextColor(Color(166, 169, 172, 255*alpha))
		end
		closeButton.DoClick = function(self)
			self:GetParent():StartToggle()
			Athena.Tick()
		end

		-- Color(209, 209, 209, 255)
		
		local headerTitle = vgui.Create("DLabel", Athena.Elements.warningsMenu.mainFrame)
		headerTitle:SetPos(15, 9)
		headerTitle:SetFont("AthenaTitle")
		headerTitle:SetText("Athena")
		headerTitle.Think = function(self)
			self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255*alpha))
		end
		headerTitle:SizeToContents()

		local headerVersion = vgui.Create("DLabel", Athena.Elements.warningsMenu.mainFrame)
		local htx, hty = headerTitle:GetPos()
		headerVersion:SetFont("AthenaVersion")
		headerVersion:SetText("v" .. Athena.Version)
		headerVersion:SetPos(htx + headerTitle:GetWide() + 2, 11)
		headerVersion.Think = function(self)
			self:SetColor(Color(0,153,204, 255*alpha))
		end
		headerVersion:SizeToContents()

		local headerTagline = vgui.Create("DLabel", Athena.Elements.warningsMenu.mainFrame)
		local htx, hty = headerVersion:GetPos()
		headerTagline:SetFont("AthenaTagline")
		headerTagline:SetText(" | Ultimate Report Management Suite | Total Severity:      ")
		headerTagline:SetPos(htx + headerVersion:GetWide() + 2, 14)
		headerTagline.Think = function(self)
			self:SetColor(Color(149, 149, 149, 255*alpha))
		end
		headerTagline:SizeToContents()

		Athena.Elements.warningsMenu.tabPanel = vgui.Create("Panel", Athena.Elements.mainFrame)
		Athena.Elements.warningsMenu.tabPanel:SetSize(Athena.Elements.warningsMenu.mainFrame:GetWide()-553, 43)
		Athena.Elements.warningsMenu.tabPanel:SetPos(350,1)
		Athena.Elements.warningsMenu.tabPanel.Paint = function(self, w, h)
		--	draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 246, 246, 246, 255*alpha ), false, false, false, false )
		--	draw.SimpleText( "|", "AthenaTabButton", 66, 23, Color(189, 189, 189, 255*alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		Athena.Elements.warningsMenu.mainPanel = vgui.Create("Panel", Athena.Elements.warningsMenu.mainFrame)
		Athena.Elements.warningsMenu.mainPanel:SetPos( 0, 55)
		Athena.Elements.warningsMenu.mainPanel:SetSize( Athena.Elements.warningsMenu.mainFrame:GetWide() , 501)
		Athena.Elements.warningsMenu.mainPanel:SetAlpha(0)
		
		Athena.Elements.warningsMenu.mainPanel.Paint = function(self, w, h)
			self:SetAlpha(255 * alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h-122, Color( 244, 244, 244, 255 ), true, true, false, false )
			surface.SetDrawColor( 51, 181, 229, 255 )
			surface.DrawLine( 1, h-122, w-1, h-122 )

			//surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255)
			//draw.SimpleText("Report a Player (optional): ", "AthenaBebas18Medium", 8, 10, Color(149,149,149,255*alpha))
			//draw.SimpleText("Message to Staff: ", "AthenaBebas18Medium", 8, 30, Color(149,149,149,255*alpha))

			//surface.DrawLine( 1, 0, w-1, 0 )
		end

		Athena.Elements.warningsDetailsElements = vgui.Create("DListView", Athena.Elements.warningsMenu.mainPanel)
		Athena.Elements.warningsDetailsElements:SetPos(11,4)
		Athena.Elements.warningsDetailsElements:SetSize(627, 370)
		Athena.Elements.warningsDetailsElements.Think = function()
			Athena.Elements.warningsDetailsElements:SetAlpha(255 * alpha)
		end
		Athena.Elements.warningsDetailsElements:AddColumn("Reason"):SetFixedWidth( 280 )
		Athena.Elements.warningsDetailsElements:AddColumn("Time")
		Athena.Elements.warningsDetailsElements:AddColumn("Warner")
		Athena.Elements.warningsDetailsElements:AddColumn("Severity")

		Athena.Elements.warningsDetailsElements.repopulateTable = function()
			Athena.Elements.warningsDetailsElements:Clear()
			totalSeverity = 0
			if Athena.Client.Warnings[selectedPlayerID] then
				for k,v in pairs(Athena.Client.Warnings[selectedPlayerID]) do
					local line = Athena.Elements.warningsDetailsElements:AddLine(v["description"], os.date("%x %I:%M %p",v["time"]), v["warner"], v["severity"])
					totalSeverity = totalSeverity + tonumber(v["severity"])
				end
			end
			headerTagline:SetText(" | Ultimate Report Management Suite | Total Severity: " .. totalSeverity)

		end

		Athena.Elements.warningsDetailsElements.refreshData = function()
			Athena.Client.requestWarnings(selectedPlayerID)
			Athena.Elements.warningsDetailsElements.repopulateTable()
		end

		Athena.Elements.warningsDetailsElements.refreshData()

		--Athena.Elements.Combobox{ x=150, y=7, w=150, parent=Athena.Elements.warningsMenu.mainPanel, enableinput=true, selectall=true, choices={"Divinity","BanLorenzo"} }

end

Athena.warningsMenu.startMenu = function()
	if !Athena.warningsMenu.menuExists or !IsValid(Athena.Elements.warningsMenu.mainFrame) then
		Athena.buildWarningsMenu()
	end
end

concommand.Add("athena_viewwarnings", Athena.warningsMenu.startMenu)
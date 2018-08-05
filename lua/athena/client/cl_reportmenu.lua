--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.reportMenu = {}
Athena.Elements.reportMenu= {}

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

function Athena.buildReportMenu()
		local createdTime = CurTime()
		--alpha = math.Clamp((CurTime()-createdTime/Athena.Configuration.FadeTime),0,1)
		local alpha = 0
		local initRemoveTime = 0
		Athena.reportMenu.initToggle = false
		local pulseOffset = 5*(math.sin((10)*(CurTime())))
		Athena.reportMenu.menuExists = true
		Athena.reportMenu.menuOpen = true

		Athena.Elements.reportMenu.blurredBackground = vgui.Create("Panel")
		Athena.Elements.reportMenu.blurredBackground:SetSize(421, 335)
		Athena.Elements.reportMenu.blurredBackground:Center()
		Athena.Elements.reportMenu.blurredBackground.Paint = function(self, w, h)
			drawPanelBlur(self, 4, 12, 255*alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 155+ pulseOffset * 4, 155+ pulseOffset * 4, 155+ pulseOffset * 4, 50*alpha ), false, false, false, false )
		end


		Athena.Elements.reportMenu.mainFrame = vgui.Create("DFrame")
		Athena.Elements.reportMenu.mainFrame:SetSize(425, 335)
		Athena.Elements.reportMenu.mainFrame:Center()
		Athena.Elements.reportMenu.mainFrame:SetTitle("")
		Athena.Elements.reportMenu.mainFrame:MakePopup()
		Athena.Elements.reportMenu.mainFrame:SetKeyboardInputEnabled(true)
		Athena.Elements.reportMenu.mainFrame:ShowCloseButton(false)
		Athena.Elements.reportMenu.mainFrame:SetDraggable(false)

		Athena.Elements.reportMenu.mainFrame.ToggleMenu = function(self)
			if Athena.reportMenu.menuOpen then
				self:SetVisible(false)
				--self:SetKeyboardInputEnabled(false)
				--self:SetMouseInputEnabled(false)
				Athena.reportMenu.initToggle = false
			else
				self:SetVisible(true)
				--self:SetKeyboardInputEnabled(true)
				self:SetMouseInputEnabled(true)
				createdTime = CurTime()
				for k,v in pairs(Athena.Elements.Avatars) do
					if IsValid(v) then
						v:SetVisible(true)
					end
				end
			end
			Athena.reportMenu.menuOpen = !Athena.reportMenu.menuOpen

		end

		Athena.Elements.reportMenu.mainFrame.StartToggle = function(self)
			self:SetKeyboardInputEnabled(false)
			self:SetMouseInputEnabled(false)
			Athena.reportMenu.initToggle = true
			initRemoveTime = CurTime()
		end

		Athena.Elements.reportMenu.mainFrame.oldRemove = Athena.Elements.reportMenu.mainFrame.Remove
		Athena.Elements.reportMenu.mainFrame.Remove = function(self)
			timer.Simple(5, function()
				Athena.Elements.reportMenu.mainFrame.oldRemove(self)
				Athena.reportMenu.menuExists = false
			end)
			return
		end

		Athena.Elements.reportMenu.mainFrame.Close = function(self)
			self:Remove()
		end

		Athena.Elements.reportMenu.mainFrame.OnRemove = function()
			Athena.menuOpen = false
		end

		Athena.Elements.reportMenu.mainFrame.Paint = function(self, w, h)
			if !Athena.reportMenu.initToggle and !(alpha == 1) then
				alpha = math.Clamp((CurTime()-createdTime)/0.4,0,1)
				--alpha = Lerp(Athena.Configuration.FadeMultiplier / 6, alpha, 1)
			elseif Athena.reportMenu.initToggle then
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

		local oldMainFrameThink = Athena.Elements.reportMenu.mainFrame.Think
		Athena.Elements.reportMenu.mainFrame.Think = function(self)
			pulseOffset = 5*(math.sin((10)*(CurTime())))
			oldMainFrameThink(self)
			if input.IsKeyDown(Athena.Configuration.KeyBind) and Athena.Configuration.UseKeyBind then
				if CurTime() - createdTime > 0.4 then
					Athena.reportMenu.nextToggle = CurTime() + 0.4
					self:StartToggle()
					return
				end
			end
		end

		local closeButton = vgui.Create("DButton", Athena.Elements.reportMenu.mainFrame)
		closeButton:SetSize(32, 32)
		closeButton:SetPos(Athena.Elements.reportMenu.mainFrame:GetWide() - 38, 6)
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
		
		local headerTitle = vgui.Create("DLabel", Athena.Elements.reportMenu.mainFrame)
		headerTitle:SetPos(15, 9)
		headerTitle:SetFont("AthenaTitle")
		headerTitle:SetText("Athena")
		headerTitle.Think = function(self)
			self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255*alpha))
		end
		headerTitle:SizeToContents()

		local headerVersion = vgui.Create("DLabel", Athena.Elements.reportMenu.mainFrame)
		local htx, hty = headerTitle:GetPos()
		headerVersion:SetFont("AthenaVersion")
		headerVersion:SetText("v" .. Athena.Version)
		headerVersion:SetPos(htx + headerTitle:GetWide() + 2, 11)
		headerVersion.Think = function(self)
			self:SetColor(Color(0,153,204, 255*alpha))
		end
		headerVersion:SizeToContents()

		local headerTagline = vgui.Create("DLabel", Athena.Elements.reportMenu.mainFrame)
		local htx, hty = headerVersion:GetPos()
		headerTagline:SetFont("AthenaTagline")
		headerTagline:SetText(" | Ultimate Report Management Suite")
		headerTagline:SetPos(htx + headerVersion:GetWide() + 2, 14)
		headerTagline.Think = function(self)
			self:SetColor(Color(149, 149, 149, 255*alpha))
		end
		headerTagline:SizeToContents()

		Athena.Elements.reportMenu.tabPanel = vgui.Create("Panel", Athena.Elements.mainFrame)
		Athena.Elements.reportMenu.tabPanel:SetSize(Athena.Elements.reportMenu.mainFrame:GetWide()-553, 43)
		Athena.Elements.reportMenu.tabPanel:SetPos(350,1)
		Athena.Elements.reportMenu.tabPanel.Paint = function(self, w, h)
		--	draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 246, 246, 246, 255*alpha ), false, false, false, false )
		--	draw.SimpleText( "|", "AthenaTabButton", 66, 23, Color(189, 189, 189, 255*alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		Athena.Elements.reportMenu.mainPanel = vgui.Create("Panel", Athena.Elements.reportMenu.mainFrame)
		Athena.Elements.reportMenu.mainPanel:SetPos( 0, 55)
		Athena.Elements.reportMenu.mainPanel:SetSize( Athena.Elements.reportMenu.mainFrame:GetWide() , 401)
		Athena.Elements.reportMenu.mainPanel:SetAlpha(0)
		
		Athena.Elements.reportMenu.mainPanel.Paint = function(self, w, h)
			self:SetAlpha(255 * alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h-122, Color( 244, 244, 244, 255 ), true, true, false, false )
			surface.SetDrawColor( 51, 181, 229, 255 )
			surface.DrawLine( 1, h-122, w-1, h-122 )

			surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255)
			draw.SimpleText("Report a Player (optional): ", "AthenaBebas18Medium", 8, 10, Color(149,149,149,255*alpha))
			draw.SimpleText("Message to Staff: ", "AthenaBebas18Medium", 8, 30, Color(149,149,149,255*alpha))

			surface.DrawLine( 1, 0, w-1, 0 )
		end

		Athena.Elements.reportMenu.playerDropdown = vgui.Create("DComboBox", Athena.Elements.reportMenu.mainPanel)
		Athena.Elements.reportMenu.playerDropdown:SetPos(150, 9)
		Athena.Elements.reportMenu.playerDropdown:SetSize(100,18)
		
		for k,v in pairs(player.GetAll()) do
			Athena.Elements.reportMenu.playerDropdown:AddChoice(v:Nick(), v:SteamID())
		end
		Athena.Elements.reportMenu.playerDropdown:AddChoice("*No Player*", "None", true)
		Athena.Elements.reportMenu.playerDropdown.OnSelect = function( panel, index, value )
			Athena.Tick()
		end

		Athena.Elements.reportMenu.messageEntry = vgui.Create("DTextEntry", Athena.Elements.reportMenu.mainPanel)
		Athena.Elements.reportMenu.messageEntry:SetMultiline(true)
		Athena.Elements.reportMenu.messageEntry:SetPos(8, 50)
		Athena.Elements.reportMenu.messageEntry:SetSize(408,200)

		Athena.Elements.reportMenu.sendReport = vgui.Create("DButton", Athena.Elements.reportMenu.mainPanel)
		Athena.Elements.reportMenu.sendReport:SetPos(316, 255)
		Athena.Elements.reportMenu.sendReport:SetSize(100,19)
		Athena.Elements.reportMenu.sendReport:SetText("")
		Athena.Elements.reportMenu.sendReport.Paint = function(self, w, h)

			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(189, 195, 199, 255 ), false, false, false, false )
			draw.SimpleText("Send Report", "AthenaBebas18Medium", w/2, 2, Color(127, 140, 141) , TEXT_ALIGN_CENTER)
		end

		Athena.Elements.reportMenu.sendReport.DoClick = function(self)
			Athena.Tick()
			self:GetParent():GetParent():SetKeyboardInputEnabled(false)
			self:GetParent():GetParent():SetMouseInputEnabled(false)
			local reportedPlayer, reportedPlayerID = Athena.Elements.reportMenu.playerDropdown:GetSelected()
			Athena.Client.sendReport(reportedPlayer,reportedPlayerID, Athena.Elements.reportMenu.messageEntry:GetValue())
			Athena.Elements.reportMenu.mainFrame.StartToggle(self:GetParent())
		end

		--Athena.Elements.Combobox{ x=150, y=7, w=150, parent=Athena.Elements.reportMenu.mainPanel, enableinput=true, selectall=true, choices={"Divinity","BanLorenzo"} }

end

Athena.reportMenu.startMenu = function()
	if !Athena.reportMenu.menuExists or !IsValid(Athena.Elements.reportMenu.mainFrame) then
		Athena.buildReportMenu()
	end
end

concommand.Add("athena_report", Athena.reportMenu.startMenu)
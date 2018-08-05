--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.rateMenu = {}
Athena.Elements.rateMenu = {}

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

function Athena.buildRateMenu(reportId)
		local createdTime = CurTime()
		--alpha = math.Clamp((CurTime()-createdTime/Athena.Configuration.FadeTime),0,1)
		local alpha = 0
		local initRemoveTime = 0

		local rating = 0

		Athena.rateMenu.initToggle = false
		local pulseOffset = 5*(math.sin((10)*(CurTime())))
		Athena.rateMenu.menuExists = true
		Athena.rateMenu.menuOpen = true

		Athena.Elements.rateMenu.mainFrame = vgui.Create("DFrame")
		Athena.Elements.rateMenu.mainFrame:SetSize(425, 200)
		Athena.Elements.rateMenu.mainFrame:Center()
		Athena.Elements.rateMenu.mainFrame:SetTitle("")
		Athena.Elements.rateMenu.mainFrame:MakePopup()
		Athena.Elements.rateMenu.mainFrame:SetKeyboardInputEnabled(true)
		Athena.Elements.rateMenu.mainFrame:ShowCloseButton(false)
		Athena.Elements.rateMenu.mainFrame:SetDraggable(false)

		Athena.Elements.rateMenu.blurredBackground = vgui.Create("Panel")
		Athena.Elements.rateMenu.blurredBackground:SetSize(421, Athena.Elements.rateMenu.mainFrame:GetTall())
		Athena.Elements.rateMenu.blurredBackground:Center()
		Athena.Elements.rateMenu.blurredBackground.Paint = function(self, w, h)
			drawPanelBlur(self, 4, 12, 255*alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 155+ pulseOffset * 4, 155+ pulseOffset * 4, 155+ pulseOffset * 4, 50*alpha ), false, false, false, false )
		end


		Athena.Elements.rateMenu.mainFrame.ToggleMenu = function(self)
			if Athena.rateMenu.menuOpen then
				self:SetVisible(false)
				--self:SetKeyboardInputEnabled(false)
				--self:SetMouseInputEnabled(false)
				Athena.rateMenu.initToggle = false
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
			Athena.rateMenu.menuOpen = !Athena.rateMenu.menuOpen

		end

		Athena.Elements.rateMenu.mainFrame.StartToggle = function(self)
			self:SetKeyboardInputEnabled(false)
			self:SetMouseInputEnabled(false)
			Athena.rateMenu.initToggle = true
			initRemoveTime = CurTime()
		end

		Athena.Elements.rateMenu.mainFrame.oldRemove = Athena.Elements.rateMenu.mainFrame.Remove
		Athena.Elements.rateMenu.mainFrame.Remove = function(self)
			timer.Simple(5, function()
				Athena.Elements.rateMenu.mainFrame.oldRemove(self)
				Athena.rateMenu.menuExists = false
			end)
			return
		end

		Athena.Elements.rateMenu.mainFrame.Close = function(self)
			self:Remove()
		end

		Athena.Elements.rateMenu.mainFrame.OnRemove = function()
			Athena.menuOpen = false
		end

		Athena.Elements.rateMenu.mainFrame.Paint = function(self, w, h)
			if !Athena.rateMenu.initToggle and !(alpha == 1) then
				alpha = math.Clamp((CurTime()-createdTime)/0.4,0,1)
				--alpha = Lerp(Athena.Configuration.FadeMultiplier / 6, alpha, 1)
			elseif Athena.rateMenu.initToggle then
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

		local oldMainFrameThink = Athena.Elements.rateMenu.mainFrame.Think
		Athena.Elements.rateMenu.mainFrame.Think = function(self)
			pulseOffset = 5*(math.sin((10)*(CurTime())))
			oldMainFrameThink(self)
			if input.IsKeyDown(Athena.Configuration.KeyBind) and Athena.Configuration.UseKeyBind then
				if CurTime() - createdTime > 0.4 then
					Athena.rateMenu.nextToggle = CurTime() + 0.4
					self:StartToggle()
					return
				end
			end
		end

		local closeButton = vgui.Create("DButton", Athena.Elements.rateMenu.mainFrame)
		closeButton:SetSize(32, 32)
		closeButton:SetPos(Athena.Elements.rateMenu.mainFrame:GetWide() - 38, 6)
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
		
		local headerTitle = vgui.Create("DLabel", Athena.Elements.rateMenu.mainFrame)
		headerTitle:SetPos(15, 9)
		headerTitle:SetFont("AthenaTitle")
		headerTitle:SetText("Athena")
		headerTitle.Think = function(self)
			self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255*alpha))
		end
		headerTitle:SizeToContents()

		local headerVersion = vgui.Create("DLabel", Athena.Elements.rateMenu.mainFrame)
		local htx, hty = headerTitle:GetPos()
		headerVersion:SetFont("AthenaVersion")
		headerVersion:SetText("v" .. Athena.Version)
		headerVersion:SetPos(htx + headerTitle:GetWide() + 2, 11)
		headerVersion.Think = function(self)
			self:SetColor(Color(0,153,204, 255*alpha))
		end
		headerVersion:SizeToContents()

		local headerTagline = vgui.Create("DLabel", Athena.Elements.rateMenu.mainFrame)
		local htx, hty = headerVersion:GetPos()
		headerTagline:SetFont("AthenaTagline")
		headerTagline:SetText(" | How was your experience?")
		headerTagline:SetPos(htx + headerVersion:GetWide() + 2, 14)
		headerTagline.Think = function(self)
			self:SetColor(Color(149, 149, 149, 255*alpha))
		end
		headerTagline:SizeToContents()

		Athena.Elements.rateMenu.tabPanel = vgui.Create("Panel", Athena.Elements.mainFrame)
		Athena.Elements.rateMenu.tabPanel:SetSize(Athena.Elements.rateMenu.mainFrame:GetWide()-553, 43)
		Athena.Elements.rateMenu.tabPanel:SetPos(350,1)
		Athena.Elements.rateMenu.tabPanel.Paint = function(self, w, h)
		--	draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 246, 246, 246, 255*alpha ), false, false, false, false )
		--	draw.SimpleText( "|", "AthenaTabButton", 66, 23, Color(189, 189, 189, 255*alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		end

		Athena.Elements.rateMenu.mainPanel = vgui.Create("Panel", Athena.Elements.rateMenu.mainFrame)
		Athena.Elements.rateMenu.mainPanel:SetPos( 0, 55)
		Athena.Elements.rateMenu.mainPanel:SetSize( Athena.Elements.rateMenu.mainFrame:GetWide() , Athena.Elements.rateMenu.mainFrame:GetTall() + 66)
		Athena.Elements.rateMenu.mainPanel:SetAlpha(0)
		
		Athena.Elements.rateMenu.mainPanel.Paint = function(self, w, h)
			self:SetAlpha(255 * alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h-122, Color( 244, 244, 244, 255 ), true, true, false, false )
			surface.SetDrawColor( 51, 181, 229, 255 )
			surface.DrawLine( 1, h-122, w-1, h-122 )

			surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255)
			draw.SimpleText("Rate the admin who handled your report: ", "AthenaBebas18Medium", 8, 10, Color(149,149,149,255*alpha))
			draw.SimpleText("Comments: ", "AthenaBebas18Medium", 8, 30, Color(149,149,149,255*alpha))

			surface.DrawLine( 1, 0, w-1, 0 )
		end

		-- Athena.Elements.rateMenu.playerDropdown = vgui.Create("DComboBox", Athena.Elements.rateMenu.mainPanel)
		-- Athena.Elements.rateMenu.playerDropdown:SetPos(150, 9)
		-- Athena.Elements.rateMenu.playerDropdown:SetSize(100,18)
		
		-- for k,v in pairs(player.GetAll()) do
		-- 	Athena.Elements.rateMenu.playerDropdown:AddChoice(v:Nick(), v:SteamID())
		-- end
		-- Athena.Elements.rateMenu.playerDropdown:AddChoice("*No Player*", "None", true)
		-- Athena.Elements.rateMenu.playerDropdown.OnSelect = function( panel, index, value )
		-- 	Athena.Tick()
		-- end

		Athena.Elements.rateMenu.messageEntry = vgui.Create("DTextEntry", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.messageEntry:SetMultiline(true)
		Athena.Elements.rateMenu.messageEntry:SetPos(8, 50)
		Athena.Elements.rateMenu.messageEntry:SetSize(408,55)

		Athena.Elements.rateMenu.sendRating = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.sendRating:SetPos(316, 115)
		Athena.Elements.rateMenu.sendRating:SetSize(100,19)
		Athena.Elements.rateMenu.sendRating:SetText("")
		Athena.Elements.rateMenu.sendRating.Paint = function(self, w, h)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(189, 195, 199, 255 ), false, false, false, false )
			draw.SimpleText("Submit", "AthenaBebas18Medium", w/2, 2, Color(127, 140, 141) , TEXT_ALIGN_CENTER)
		end

		Athena.Elements.rateMenu.sendRating.DoClick = function(self)
			Athena.Tick()
			self:GetParent():GetParent():SetKeyboardInputEnabled(false)
			self:GetParent():GetParent():SetMouseInputEnabled(false)
			local reportedPlayer, reportedPlayerID = Athena.Elements.rateMenu.playerDropdown:GetSelected()
			Athena.Client.sendRating(reportedPlayer,reportedPlayerID, Athena.Elements.rateMenu.messageEntry:GetValue())
			Athena.Elements.rateMenu.mainFrame.StartToggle(self:GetParent())
		end

		local starIcon = Material("icon16/star.png")
		
		Athena.Elements.rateMenu.rateStar1 = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.rateStar1:SetPos(215,10)
		Athena.Elements.rateMenu.rateStar1:SetSize(16,16)
		Athena.Elements.rateMenu.rateStar1:SetText("")
		Athena.Elements.rateMenu.rateStar1.Paint = function(self, w, h)
			if rating >= 1 then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.SetMaterial(starIcon)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		Athena.Elements.rateMenu.rateStar1.DoClick = function(self)
			Athena.Tick()
			rating = 1
		end

		Athena.Elements.rateMenu.rateStar2 = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.rateStar2:SetPos(230,10)
		Athena.Elements.rateMenu.rateStar2:SetSize(16,16)
		Athena.Elements.rateMenu.rateStar2:SetText("")
		Athena.Elements.rateMenu.rateStar2.Paint = function(self, w, h)
			if rating >= 2 then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.SetMaterial(starIcon)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		Athena.Elements.rateMenu.rateStar2.DoClick = function(self)
			Athena.Tick()
			rating = 2
		end

		Athena.Elements.rateMenu.rateStar3 = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.rateStar3:SetPos(245,10)
		Athena.Elements.rateMenu.rateStar3:SetSize(16,16)
		Athena.Elements.rateMenu.rateStar3:SetText("")
		Athena.Elements.rateMenu.rateStar3.Paint = function(self, w, h)
			if rating >= 3 then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(255,255,255,150)
			end

			surface.SetMaterial(starIcon)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		Athena.Elements.rateMenu.rateStar3.DoClick = function(self)
			Athena.Tick()
			rating = 3
		end

		Athena.Elements.rateMenu.rateStar4 = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.rateStar4:SetPos(260,10)
		Athena.Elements.rateMenu.rateStar4:SetSize(16,16)
		Athena.Elements.rateMenu.rateStar4:SetText("")
		Athena.Elements.rateMenu.rateStar4.Paint = function(self, w, h)
			if rating >= 4 then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.SetMaterial(starIcon)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		Athena.Elements.rateMenu.rateStar4.DoClick = function(self)
			Athena.Tick()
			rating = 4
		end

		Athena.Elements.rateMenu.rateStar5 = vgui.Create("DButton", Athena.Elements.rateMenu.mainPanel)
		Athena.Elements.rateMenu.rateStar5:SetPos(265,10)
		Athena.Elements.rateMenu.rateStar5:SetSize(16,16)
		Athena.Elements.rateMenu.rateStar5:SetText("")
		Athena.Elements.rateMenu.rateStar5.Paint = function(self, w, h)
			if rating >= 5 then
				surface.SetDrawColor(255,255,255,255)
			else
				surface.SetDrawColor(255,255,255,150)
			end
			surface.SetMaterial(starIcon)
			surface.DrawTexturedRect(0, 0, w, h)
		end

		Athena.Elements.rateMenu.rateStar5.DoClick = function(self)
			Athena.Tick()
			rating = 5
		end

		--Athena.Elements.Combobox{ x=150, y=7, w=150, parent=Athena.Elements.rateMenu.mainPanel, enableinput=true, selectall=true, choices={"Divinity","BanLorenzo"} }

end

Athena.rateMenu.startMenu = function(rating)
	if !Athena.rateMenu.menuExists or !IsValid(Athena.Elements.rateMenu.mainFrame) then
		Athena.buildRateMenu(rating)
	end
end
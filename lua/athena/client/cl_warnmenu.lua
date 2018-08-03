--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.warnMenu = {}
Athena.Elements.warnMenu= {}

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

function Athena.buildWarnMenu()
		local createdTime = CurTime()
		--alpha = math.Clamp((CurTime()-createdTime/Athena.Configuration.FadeTime),0,1)
		local alpha = 0
		local initRemoveTime = 0
		Athena.warnMenu.initToggle = false
		local pulseOffset = 5*(math.sin((10)*(CurTime())))
		Athena.warnMenu.menuExists = true
		Athena.warnMenu.menuOpen = true

		Athena.Elements.warnMenu.blurredBackground = vgui.Create("Panel")
		Athena.Elements.warnMenu.blurredBackground:SetSize(263, 160)
		Athena.Elements.warnMenu.blurredBackground:Center()
		Athena.Elements.warnMenu.blurredBackground.Paint = function(self, w, h)
			drawPanelBlur(self, 4, 12, 255*alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 155+ pulseOffset * 4, 155+ pulseOffset * 4, 155+ pulseOffset * 4, 50*alpha ), false, false, false, false )
		end


		Athena.Elements.warnMenu.mainFrame = vgui.Create("DFrame")
		Athena.Elements.warnMenu.mainFrame:SetSize(268, 160)
		Athena.Elements.warnMenu.mainFrame:Center()
		Athena.Elements.warnMenu.mainFrame:SetTitle("")
		Athena.Elements.warnMenu.mainFrame:MakePopup()
		Athena.Elements.warnMenu.mainFrame:SetKeyboardInputEnabled(true)
		Athena.Elements.warnMenu.mainFrame:ShowCloseButton(false)
		Athena.Elements.warnMenu.mainFrame:SetDraggable(false)

		Athena.Elements.warnMenu.mainFrame.ToggleMenu = function(self)
			if Athena.warnMenu.menuOpen then
				self:SetVisible(false)
				--self:SetKeyboardInputEnabled(false)
				--self:SetMouseInputEnabled(false)
				Athena.warnMenu.initToggle = false
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
			Athena.warnMenu.menuOpen = !Athena.warnMenu.menuOpen

		end

		Athena.Elements.warnMenu.mainFrame.StartToggle = function(self)
			self:SetKeyboardInputEnabled(false)
			self:SetMouseInputEnabled(false)
			Athena.warnMenu.initToggle = true
			initRemoveTime = CurTime()
		end

		Athena.Elements.warnMenu.mainFrame.oldRemove = Athena.Elements.warnMenu.mainFrame.Remove
		Athena.Elements.warnMenu.mainFrame.Remove = function(self)
			timer.Simple(5, function()
				Athena.Elements.warnMenu.mainFrame.oldRemove(self)
				Athena.warnMenu.menuExists = false
			end)
			return
		end

		Athena.Elements.warnMenu.mainFrame.Close = function(self)
			self:Remove()
		end

		Athena.Elements.warnMenu.mainFrame.OnRemove = function()
			Athena.menuOpen = false
		end

		Athena.Elements.warnMenu.mainFrame.Paint = function(self, w, h)
			if !Athena.warnMenu.initToggle and !(alpha == 1) then
				alpha = math.Clamp((CurTime()-createdTime)/0.4,0,1)
				--alpha = Lerp(Athena.Configuration.FadeMultiplier / 6, alpha, 1)
			elseif Athena.warnMenu.initToggle then
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

		local oldMainFrameThink = Athena.Elements.warnMenu.mainFrame.Think
		Athena.Elements.warnMenu.mainFrame.Think = function(self)
			pulseOffset = 5*(math.sin((10)*(CurTime())))
			oldMainFrameThink(self)
			if input.IsKeyDown(Athena.Configuration.KeyBind) and Athena.Configuration.UseKeyBind then
				if CurTime() - createdTime > 0.4 then
					Athena.warnMenu.nextToggle = CurTime() + 0.4
					self:StartToggle()
					return
				end
			end
		end

		local closeButton = vgui.Create("DButton", Athena.Elements.warnMenu.mainFrame)
		closeButton:SetSize(32, 32)
		closeButton:SetPos(Athena.Elements.warnMenu.mainFrame:GetWide() - 38, 6)
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
		
		local headerTitle = vgui.Create("DLabel", Athena.Elements.warnMenu.mainFrame)
		headerTitle:SetPos(15, 9)
		headerTitle:SetFont("AthenaTitle")
		headerTitle:SetText("Athena")
		headerTitle.Think = function(self)
			self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255*alpha))
		end
		headerTitle:SizeToContents()

		local headerVersion = vgui.Create("DLabel", Athena.Elements.warnMenu.mainFrame)
		local htx, hty = headerTitle:GetPos()
		headerVersion:SetFont("AthenaVersion")
		headerVersion:SetText("v" .. Athena.Version)
		headerVersion:SetPos(htx + headerTitle:GetWide() + 2, 11)
		headerVersion.Think = function(self)
			self:SetColor(Color(0,153,204, 255*alpha))
		end
		headerVersion:SizeToContents()


		Athena.Elements.warnMenu.mainPanel = vgui.Create("Panel", Athena.Elements.warnMenu.mainFrame)
		Athena.Elements.warnMenu.mainPanel:SetPos( 0, 55)
		Athena.Elements.warnMenu.mainPanel:SetSize( Athena.Elements.warnMenu.mainFrame:GetWide() , 105)
		Athena.Elements.warnMenu.mainPanel:SetAlpha(0)
		
		Athena.Elements.warnMenu.mainPanel.Paint = function(self, w, h)
			self:SetAlpha(255 * alpha)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 244, 244, 244, 255 ), true, true, true, true )
			surface.SetDrawColor( 51, 181, 229, 255 )
			surface.DrawLine( 1, h-1, w-1, h-1)

			surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255)
			draw.SimpleText("Warn a Player: ", "AthenaBebas18Medium", 100, 10, Color(149,149,149,255*alpha), TEXT_ALIGN_RIGHT)
			draw.SimpleText("Warning Reason: ", "AthenaBebas18Medium", 100, 32, Color(149,149,149,255*alpha), TEXT_ALIGN_RIGHT)
			draw.SimpleText("Severity Level:", "AthenaBebas18Medium", 100, 54, Color(149,149,149,255*alpha), TEXT_ALIGN_RIGHT)

			surface.DrawLine( 1, 0, w-1, 0 )
		end

		Athena.Elements.warnMenu.playerDropdown = vgui.Create("DComboBox", Athena.Elements.warnMenu.mainPanel)
		Athena.Elements.warnMenu.playerDropdown:SetPos(105, 9)
		Athena.Elements.warnMenu.playerDropdown:SetSize(100,18)
		
		for k,v in pairs(player.GetAll()) do
			Athena.Elements.warnMenu.playerDropdown:AddChoice(v:Nick(), v:SteamID64())
		end
		Athena.Elements.warnMenu.playerDropdown:SetValue("Select a player")
		Athena.Elements.warnMenu.playerDropdown.OnSelect = function( panel, index, value )
			Athena.Tick()
		end

		Athena.Elements.warnMenu.reasonDropdown = Athena.Elements.Combobox{parent=Athena.Elements.warnMenu.mainPanel, x=105, y = 29, w = 145, enableinput = true}
		for k,v in pairs(Athena.Configuration.WarnReasons) do
			Athena.Elements.warnMenu.reasonDropdown:AddChoice(v, v)
		end
		Athena.Elements.warnMenu.reasonDropdown.OnSelect = function( panel, index, value )
			Athena.Tick()
		end

		Athena.Elements.warnMenu.severitySlider = Athena.Elements.Slider{min=1, max=3, value=1, parent=Athena.Elements.warnMenu.mainPanel, x = 105, y = 52}

		Athena.Elements.warnMenu.sendWarn = vgui.Create("DButton", Athena.Elements.warnMenu.mainPanel)
		Athena.Elements.warnMenu.sendWarn:SetPos(163, 80)
		Athena.Elements.warnMenu.sendWarn:SetSize(100,19)
		Athena.Elements.warnMenu.sendWarn:SetText("")
		Athena.Elements.warnMenu.sendWarn.Paint = function(self, w, h)

			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(189, 195, 199, 255 ), false, false, false, false )
			draw.SimpleText("Warn Player", "AthenaBebas18Medium", w/2, 2, Color(127, 140, 141) , TEXT_ALIGN_CENTER)
		end

		Athena.Elements.warnMenu.sendWarn.DoClick = function(self)
			Athena.Tick()
			self:GetParent():GetParent():SetKeyboardInputEnabled(false)
			self:GetParent():GetParent():SetMouseInputEnabled(false)
			local warnedPlayer, warnedPlayerID = Athena.Elements.warnMenu.playerDropdown:GetSelected()
			if warnedPlayerID == nil then Athena.Elements.warnMenu.mainFrame.StartToggle(self:GetParent()) return end
			Athena.Client.newWarning(warnedPlayerID, Athena.Elements.warnMenu.reasonDropdown:GetValue(), Athena.Elements.warnMenu.severitySlider:GetValue())
			Athena.Elements.warnMenu.mainFrame.StartToggle(self:GetParent())
		end

		--Athena.Elements.Combobox{ x=150, y=7, w=150, parent=Athena.Elements.warnMenu.mainPanel, enableinput=true, selectall=true, choices={"Divinity","BanLorenzo"} }

end

Athena.warnMenu.startMenu = function()
	if Athena.hasPermission(LocalPlayer()) then
		if !Athena.warnMenu.menuExists or !IsValid(Athena.Elements.warnMenu.mainFrame) then
			Athena.buildWarnMenu()
		end
	end
end

concommand.Add("athena_warn", Athena.warnMenu.startMenu)
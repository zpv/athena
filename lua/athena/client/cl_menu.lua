--[[
░█▀▀█ ▀▀█▀▀ █░░█ █▀▀ █▀▀▄ █▀▀█ 
▒█▄▄█ ░░█░░ █▀▀█ █▀▀ █░░█ █▄▄█ 
▒█░▒█ ░░▀░░ ▀░░▀ ▀▀▀ ▀░░▀ ▀░░▀ 
]]

local Athena = Athena

Athena.Elements = {}
Athena.Elements.Avatars = {}
Athena.nextToggle = CurTime()
Athena.lastUpdate = -10

include("cl_gui_library.lua")
include("cl_overview.lua")
include("cl_reports.lua")
include("cl_reportmenu.lua")
include("cl_warnings.lua")
include("cl_warnmenu.lua")
include("cl_ratemenu.lua")

ATHENA_PAGE_OVERVIEW 	= 1;
ATHENA_PAGE_REPORTS		= 2;
ATHENA_PAGE_WARNINGS		= 3;

Athena.Elements.actions = {
	[ATHENA_PAGE_OVERVIEW] = function() Athena.openOverview() end,
	[ATHENA_PAGE_REPORTS] = function() Athena.openReports() end,
	[ATHENA_PAGE_WARNINGS] = function() Athena.openWarnings() end
}

surface.CreateFont( "AthenaTitle", {
	font = "Bebas Neue",
	size = 30,
	weight = 0,
	antialias = true
} )

surface.CreateFont( "AthenaVersion", {
	font = "Bebas Neue",
	size = 15,
	weight = 500,
	antialias = true
})

surface.CreateFont( "AthenaMisc", {
	font = "Roboto Cn",
	size = 14,
	weight = 500,
	antialias = true
})

surface.CreateFont( "AthenaTagline", {
	font = "Bebas Neue",
	size = 20,
	weight = 500,
	antialias = true
})

surface.CreateFont( "AthenaTabButton", {
	font = "Bebas Neue",
	size = 25,
	weight = 500,
	antialias = true
})

surface.CreateFont( "AthenaBebas33Normal", {
	font = "Bebas Neue",
	size = 33,
	weight = 500,
	antialias = true
})

surface.CreateFont( "AthenaOswald25Normal", {
	font = "Oswald",
	size = 25,
	weight = 400,
	antialias = true
})

surface.CreateFont( "AthenaOswald20Normal", {
	font = "Oswald",
	size = 20,
	weight = 400,
	antialias = true
})

surface.CreateFont( "AthenaOswald25Normal", {
	font = "Oswald",
	size = 25,
	weight = 400,
	antialias = true
})


surface.CreateFont( "AthenaOswald20Light", {
	font = "Oswald",
	size = 20,
	weight = 300,
	antialias = true
})

surface.CreateFont( "AthenaOswald40Bold", {
	font = "Oswald",
	size = 40,
	weight = 700,
	antialias = true
})

surface.CreateFont( "AthenaCourierNew11", {
	font = "Tahoma",
	size = 11,
	weight = 400,
	antialias = true
})

surface.CreateFont( "AthenaCourierNew13", {
	font = "Tahoma",
	size = 13,
	weight = 400,
	antialias = true
})

surface.CreateFont( "AthenaNotificationTitle", {
	font = "Bebas Neue",
	size = 20,
	weight = 0,
	antialias = true
} )

surface.CreateFont( "AthenaBebas18Medium", {
	font = "Bebas Neue",
	size = 18,
	weight = 500,
	antialias = true
})


local blur = Material( "pp/blurscreen" )
local function drawPanelBlur( panel, layers, density, alpha )
    local x, y = panel:LocalToScreen(0, 0)
   -- print(x .." ".. y)

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 3 do
        blur:SetFloat( "$blur", ( i / layers ) * density )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

function Athena.Tick()
	surface.PlaySound("athena/ui/tick.mp3")
end

function Athena.buildMenu()

	local createdTime = CurTime()
	local alpha = 0
	local pulseOffset = 5*(math.sin((10)*(CurTime())))

	Athena.initRemoveTime = 0
	Athena.initToggle = false

	Athena.menuExists = true
	Athena.menuOpen = true

	Athena.currentPage = ATHENA_PAGE_REPORTS

	Athena.Elements.blurredBackground = vgui.Create("Panel")
	Athena.Elements.blurredBackground:SetSize(900, 600)
	Athena.Elements.blurredBackground:Center()
	Athena.Elements.blurredBackground.Paint = function(self, w, h)
		drawPanelBlur(self, 4, 12, 255*alpha)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color( 155, 155, 155, 50*alpha ), false, false, false, false )
	end

	Athena.Elements.mainFrame = vgui.Create("DFrame")
	Athena.Elements.mainFrame:SetSize(900, 600)
	Athena.Elements.mainFrame:Center()
	Athena.Elements.mainFrame:SetTitle("")
	Athena.Elements.mainFrame:MakePopup()
	Athena.Elements.mainFrame:SetKeyboardInputEnabled(false)
	Athena.Elements.mainFrame:ShowCloseButton(false)
	Athena.Elements.mainFrame:SetDraggable(false)

	Athena.Elements.mainFrame.ToggleMenu = function(self)
		if Athena.menuOpen then
			-- Final step after StartToggle & Fade
			self:SetVisible(false)
			Athena.initToggle = false
		else
			self:SetVisible(true)
			self:SetMouseInputEnabled(true)
			createdTime = CurTime()
			Athena.pageCreated = CurTime()
	--		for k,v in pairs(Athena.Elements.Avatars) do
	--			if IsValid(v) then
	--				v:SetVisible(true)
	--			end
	--		end
			if Athena.currentPage == ATHENA_PAGE_REPORTS then
				Athena.Elements.drawreportList()
			end
		end
		Athena.menuOpen = !Athena.menuOpen

	end

	Athena.Elements.mainFrame.StartToggle = function(self)
		self:SetMouseInputEnabled(false)
		Athena.initToggle = true
		Athena.initRemoveTime = CurTime()
	--	for k,v in pairs(Athena.Elements.Avatars) do
	--		if IsValid(v) then
	--			v:SetVisible(false)
	--		end
	--	end
	end

	local oldRemove = Athena.Elements.mainFrame.Remove
	Athena.Elements.mainFrame.Remove = function(self)
		Athena.initRemoveTime = CurTime()
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
		timer.Simple(5, function()
			oldRemove(self)
			Athena.menuExists = false
		end)
		return
	end

	Athena.Elements.mainFrame.Close = function(self)
		self:Remove()
	end

	Athena.Elements.mainFrame.OnRemove = function()
		Athena.menuOpen = false
	end

	Athena.Elements.mainFrame.Paint = function(self, w, h)
		if !Athena.initToggle and !(alpha == 1) then
			alpha = math.Clamp((CurTime()-createdTime)/Athena.Configuration.FadeMultiplier,0,1)
		elseif Athena.initToggle then
			alpha = (alpha < 0.01) and self:ToggleMenu() and 0 or math.Clamp((-(CurTime()-Athena.initRemoveTime)/Athena.Configuration.FadeMultiplier)+ 1,0,1)
		end
		draw.RoundedBoxEx( 4, 0, 0, w, 45, Color( 200, 200, 200, 255*alpha ), true, true, false, false )
		draw.RoundedBoxEx( 4, 1, 1, w-2, 43, Color( 222, 222, 222, 255*alpha ), true, true, false, false )
		
		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *alpha )

		surface.DrawLine( 1, 45, w-2, 45 )
	end

	local oldMainFrameThink = Athena.Elements.mainFrame.Think
	Athena.Elements.mainFrame.Think = function(self)
		pulseOffset = 5*(math.sin((10)*(CurTime())))
		oldMainFrameThink(self)
		if input.IsKeyDown(Athena.Configuration.KeyBind) and Athena.Configuration.UseKeyBind then
			if CurTime() - createdTime > 0.4 then
				Athena.nextToggle = CurTime() + 0.4
				self:StartToggle()
				return
			end
		end
	end

	local closeButton = vgui.Create("DButton", Athena.Elements.mainFrame)
	closeButton:SetSize(32, 32)
	closeButton:SetPos(Athena.Elements.mainFrame:GetWide() - 38, 6)
	closeButton:SetText("r")
	closeButton:SetFont( "marlett" )
	closeButton.Paint = function(self)
		self:SetTextColor(Color(166, 169, 172, 255*alpha))
	end
	closeButton.DoClick = function(self)
		self:GetParent():StartToggle()
		Athena.Tick()
	end

	local headerTitle = vgui.Create("DLabel", Athena.Elements.mainFrame)
	headerTitle:SetPos(15, 9)
	headerTitle:SetFont("AthenaTitle")
	headerTitle:SetText("Athena")
	headerTitle.Think = function(self)
		self:SetColor(Color(math.Clamp(0 + pulseOffset * 4, 0, 255), math.Clamp(153 + pulseOffset*3, 0, 255),math.Clamp(204 + pulseOffset*5,0,255), 255*alpha))
	end
	headerTitle:SizeToContents()

	local headerVersion = vgui.Create("DLabel", Athena.Elements.mainFrame)
	local htx, hty = headerTitle:GetPos()
	headerVersion:SetFont("AthenaVersion")
	headerVersion:SetText("v" .. Athena.Version)
	headerVersion:SetPos(htx + headerTitle:GetWide() + 2, 11)
	headerVersion.Think = function(self)
		self:SetColor(Color(0,153,204, 255*alpha))
	end
	headerVersion:SizeToContents()

	local miscText = vgui.Create("DLabel", Athena.Elements.mainFrame)
	miscText:SetFont("AthenaMisc")
	miscText:SetText("")
	miscText:SetPos(615, 16)
	miscText.Think = function(self)
		self:SetColor(Color(0,153,204, 255*alpha))
	end
	miscText:SizeToContents()

	local headerTagline = vgui.Create("DLabel", Athena.Elements.mainFrame)
	local htx, hty = headerVersion:GetPos()
	headerTagline:SetFont("AthenaTagline")
	headerTagline:SetText(" | Ultimate Report Management Suite")
	headerTagline:SetPos(htx + headerVersion:GetWide() + 2, 14)
	headerTagline.Think = function(self)
		self:SetColor(Color(149, 149, 149, 255*alpha))
	end
	headerTagline:SizeToContents()

	Athena.Elements.tabPanel = vgui.Create("Panel", Athena.Elements.mainFrame)
	Athena.Elements.tabPanel:SetSize(Athena.Elements.mainFrame:GetWide()-553, 43)
	Athena.Elements.tabPanel:SetPos(350,1)
	Athena.Elements.tabPanel.Paint = function(self, w, h)

	end

	local reportsButton = vgui.Create("DButton", Athena.Elements.tabPanel)
	reportsButton:SetPos(1,0)
	reportsButton:SetSize(100, 45)
	reportsButton:SetText("Reports")
	reportsButton:SetFont("AthenaTabButton")
	reportsButton.btnColor = Color(149, 149, 149, 255)
	reportsButton.Think = function(self)
		if self.Hovered then
			self.btnColor.r = Lerp(0.05, self.btnColor.r, 0)
			self.btnColor.g = Lerp(0.05, self.btnColor.g, 153)
			self.btnColor.b = Lerp(0.05, self.btnColor.b, 204)
		else
			self.btnColor.r = Lerp(0.1, self.btnColor.r, 149)
			self.btnColor.g = Lerp(0.1, self.btnColor.g, 149)
			self.btnColor.b = Lerp(0.1, self.btnColor.b, 149)
		end
	end

	reportsButton.Paint = function(self, w, h)
		if Athena.currentPage == ATHENA_PAGE_REPORTS then
			draw.RoundedBox( 0, 0, 0, w, h, Color(200, 200, 200, 70* alpha) )
			self.btnColor2 = Color(0, 153, 204, 255 * alpha)

		else
			if self.Hovered then
				self.btnColor2 = Color(math.Clamp(self.btnColor.r + pulseOffset * 4, 0, 255), math.Clamp(self.btnColor.g + pulseOffset * 4, 0, 255), math.Clamp(self.btnColor.b + pulseOffset * 4, 0, 255), 255 * alpha)
			else
				self.btnColor2 = self.btnColor
				self.btnColor2.a = 255 * alpha
			end
		end
		self:SetTextColor(self.btnColor2)
		surface.SetDrawColor( Color(189, 189, 189, 255*alpha) )
		surface.DrawLine( 0, 0, 0, h )
		surface.DrawLine( w-1, 0, w-1, h )
	end

	reportsButton.DoClick = function()
		Athena.Tick()
		Athena.Elements.mainPanel.switchPage(ATHENA_PAGE_REPORTS)
	end

	local warningsButton = vgui.Create("DButton", Athena.Elements.tabPanel)
	warningsButton:SetPos(101,0)
	warningsButton:SetSize(100, 45)
	warningsButton:SetText("Warnings")
	warningsButton:SetFont("AthenaTabButton")
	warningsButton.btnColor = Color(149, 149, 149, 255)
	warningsButton.Think = function(self)
		if self.Hovered then
			self.btnColor.r = Lerp(0.05, self.btnColor.r, 0)
			self.btnColor.g = Lerp(0.05, self.btnColor.g, 153)
			self.btnColor.b = Lerp(0.05, self.btnColor.b, 204)
		else
			self.btnColor.r = Lerp(0.1, self.btnColor.r, 149)
			self.btnColor.g = Lerp(0.1, self.btnColor.g, 149)
			self.btnColor.b = Lerp(0.1, self.btnColor.b, 149)
		end
	end

	warningsButton.Paint = function(self, w, h)
		if Athena.currentPage == ATHENA_PAGE_WARNINGS then
			draw.RoundedBox( 0, 0, 0, w, h, Color(200, 200, 200, 70* alpha) )
			self.btnColor2 = Color(0, 153, 204, 255 * alpha)

		else
			if self.Hovered then
				self.btnColor2 = Color(math.Clamp(self.btnColor.r + pulseOffset * 4, 0, 255), math.Clamp(self.btnColor.g + pulseOffset * 4, 0, 255), math.Clamp(self.btnColor.b + pulseOffset * 4, 0, 255), 255 * alpha)
			else
				self.btnColor2 = self.btnColor
				self.btnColor2.a = 255 * alpha
			end
		end
		self:SetTextColor(self.btnColor2)
		surface.SetDrawColor( Color(189, 189, 189, 255*alpha) )
		surface.DrawLine( w-1, 0, w-1, h )
	end

	warningsButton.DoClick = function()
		Athena.Tick()
		Athena.Elements.mainPanel.switchPage(ATHENA_PAGE_WARNINGS)
	end

	Athena.Elements.adminCard = vgui.Create("Panel", Athena.Elements.mainFrame)
	Athena.Elements.adminCard:SetPos( 10, 300)
	Athena.Elements.adminCard:SetSize( 190, 67)
	Athena.Elements.adminCard.drawAvatar = function(self)
		Athena.Elements.Avatars.playerAvatar = vgui.Create("AvatarImage", self)
		Athena.Elements.Avatars.playerAvatar:SetSize(48, 48)
		
		Athena.Elements.Avatars.playerAvatar:SetPos( 10 + 4, 9)
		Athena.Elements.Avatars.playerAvatar:SetPlayer( LocalPlayer(), 48 )
	end

	Athena.Elements.adminCard.Paint = function(self, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color( 150, 150, 150, 120*alpha ))
		draw.RoundedBox( 4, 1, 1, w-2, h-2, Color( 200, 200, 200, 80*alpha ))

		draw.RoundedBox( 0, 8 + 4, 7, 8, 8, Color( 41, 128, 185, 255*alpha ) )
		draw.RoundedBox( 0, 52 + 4, 7, 8, 8, Color( 41, 128, 185, 255*alpha) )
		draw.RoundedBox( 0, 8 + 4, 51, 8, 8, Color( 41, 128, 185, 255*alpha ) )
		draw.RoundedBox( 0, 52 + 4, 51, 8, 8, Color( 41, 128, 185, 255*alpha ) )

		if not IsValid(Athena.Elements.Avatars.playerAvatar) then
			self:drawAvatar()
		end
		Athena.Elements.Avatars.playerAvatar:SetAlpha(255 * alpha)
	end

	local adminNick = vgui.Create("DLabel", Athena.Elements.adminCard)
	adminNick:SetPos(75 + 4, 11)
	adminNick:SetFont("AthenaOswald25Normal")
	adminNick:SetText(LocalPlayer():Nick())
	adminNick.Think = function(self)
		self:SetColor(Color(55,55,55, 255*alpha))
	end
	adminNick:SetSize(100,25)

	local adminID = vgui.Create("DLabel", Athena.Elements.adminCard)
	adminID:SetPos(75 + 4, 32)
	adminID:SetFont("AthenaOswald20Light")
	adminID:SetText(LocalPlayer():SteamID())
	adminID.Think = function(self)
		self:SetColor(Color(55,55,55, 255*alpha))
	end
	adminID:SizeToContents()


	Athena.Elements.completedCard = vgui.Create("Panel", Athena.Elements.mainFrame)
	Athena.Elements.completedCard:SetPos( 70, 300)
	Athena.Elements.completedCard:SetSize( 120, 67)

	Athena.Elements.completedCard.Paint = function(self, w, h)
		draw.RoundedBox( 4, 0, 0, w, h, Color( 150, 150, 150, 120*alpha ))
		draw.RoundedBox( 4, 1, 1, w-2, h-2, Color( 200, 200, 200, 80*alpha ))
		draw.SimpleText("Completed Reports ", "AthenaOswald20Light", w / 2, 11, Color(55, 55, 55, 255 * alpha), TEXT_ALIGN_CENTER)
		draw.SimpleText(Athena.Client.CompletedReports, "AthenaOswald25Normal", w / 2, 32, Color(55, 55, 55, 255 * alpha), TEXT_ALIGN_CENTER)
	end

	if Athena.Configuration.StaffRatings then
		Athena.Elements.ratingCard = vgui.Create("Panel", Athena.Elements.mainFrame)
		Athena.Elements.ratingCard:SetPos( 70, 300)
		Athena.Elements.ratingCard:SetSize( 120, 67)

		Athena.Elements.ratingCard.Paint = function(self, w, h)
			draw.RoundedBox( 4, 0, 0, w, h, Color( 150, 150, 150, 120*alpha ))
			draw.RoundedBox( 4, 1, 1, w-2, h-2, Color( 200, 200, 200, 80*alpha ))
			draw.SimpleText("Your Rating", "AthenaOswald20Light", w / 2, 11, Color(55, 55, 55, 255 * alpha), TEXT_ALIGN_CENTER)
			draw.SimpleText(Athena.Client.AverageRating .. " / 5", "AthenaOswald25Normal", w / 2, 32, Color(55, 55, 55, 255 * alpha), TEXT_ALIGN_CENTER)
		end

		Athena.Elements.ratingCard:MoveTo(340, 50,0.3,0,0.2)
	end

	--[[

	Athena.Elements.reportsCard = vgui.Create("Panel", Athena.Elements.adminCard)
	Athena.Elements.reportsCard:SetPos(0, 0)
	Athena.Elements.reportsCard:SetSize( 195, 67)
	Athena.Elements.reportsCard:SetVisible(false)
	Athena.Elements.reportsCard:MoveToBack()
	Athena.Elements.reportsCard.Paint = function(self, w, h)

	end

	timer.Simple(0.3, function()
		Athena.Elements.reportsCard:SetVisible(true)
	end)

	Athena.Elements.reportsCard:MoveTo(355, 0,0.7,0.3,0.4)

	]]

	Athena.Elements.adminCard:MoveTo(10, 50,0.3,0,0.2)
	Athena.Elements.completedCard:MoveTo(210, 50,0.3,0,0.2)

	Athena.Elements.mainPanel = vgui.Create("Panel", Athena.Elements.mainFrame)
	Athena.Elements.mainPanel:SetPos( 0, 121)
	Athena.Elements.mainPanel:SetSize( Athena.Elements.mainFrame:GetWide() , Athena.Elements.mainFrame:GetTall())
	Athena.Elements.mainPanel.Paint = function(self, w, h)
		draw.RoundedBoxEx( 4, 0, 0, w, h-122, Color( 244, 244, 244, 255*alpha ), true, true, false, false )
		surface.SetDrawColor( 51, 181, 229, 150 *alpha )
		surface.DrawLine( 1, h-122, w-2, h-122 )

		surface.SetDrawColor( math.Clamp(51 + pulseOffset * 4, 0, 255), math.Clamp(181 + pulseOffset * 4, 0, 255), math.Clamp(229 + pulseOffset * 4, 0, 255), 255 *alpha )

		surface.DrawLine( 1, 0, w-2, 0 )
	end

	Athena.openReports()

	Athena.Elements.mainPanel.switchPage = function(page)
		Athena.currentPage = page
		Athena.Elements.displayedPage:Remove()
		Athena.Elements.actions[page]()
	end
end

Athena.StartMenu = function()
	if not Athena.hasPermission(LocalPlayer()) then return end
	if Athena.Client.Queued then 
		if (CurTime() - Athena.Client.Queued > Athena.Configuration.QueueTimeout) then
			Athena.Client.Queued = false
		else return end
	end
	if !Athena.menuExists or !IsValid(Athena.Elements.mainFrame) then
		if (CurTime() - Athena.lastUpdate) > Athena.Configuration.ClientRequestInterval then
			Athena.Client.Queued = CurTime()
			Athena.lastUpdate = CurTime()
			Athena.Client.QueueType = 1
			Athena.Client.requestReports()
			return
		end
		Athena.buildMenu()
	elseif Athena.menuExists and !Athena.menuOpen then
		if CurTime() - Athena.lastUpdate > Athena.Configuration.ClientRequestInterval then
			Athena.Client.Queued = CurTime()
			Athena.lastUpdate = CurTime()
			Athena.Client.QueueType = 2
			Athena.Client.requestReports()
			return
		end
		Athena.Elements.mainFrame:ToggleMenu()
	end
end
concommand.Add(Athena.Configuration.ConsoleCommand, Athena.StartMenu)

if Athena.Configuration.UseKeyBind then
	hook.Add("Think", "AthenaToggle", function()
		if input.IsKeyDown(Athena.Configuration.KeyBind) then
			if not Athena.hasPermission(LocalPlayer()) then return end

			if Athena.Client.Queued then 
				if (CurTime() - Athena.Client.Queued > Athena.Configuration.QueueTimeout) then
					Athena.Client.Queued = false
				else return end
			end
			if !Athena.menuExists or !IsValid(Athena.Elements.mainFrame) then
				if (CurTime() - Athena.lastUpdate) > Athena.Configuration.ClientRequestInterval then
					Athena.Client.Queued = CurTime()
					Athena.lastUpdate = CurTime()
					Athena.Client.QueueType = 1
					Athena.Client.requestReports()
					return
				end
				Athena.buildMenu()
			elseif Athena.menuExists and !Athena.menuOpen then
				if CurTime() - Athena.lastUpdate > Athena.Configuration.ClientRequestInterval then
					Athena.Client.Queued = CurTime()
					Athena.lastUpdate = CurTime()
					Athena.Client.QueueType = 2
					Athena.Client.requestReports()
					return
				end
				Athena.Elements.mainFrame:ToggleMenu()
			end
		end
	end)
end


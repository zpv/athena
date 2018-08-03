function Athena.Elements.Combobox( t )
	local pnl = vgui.Create( "DComboBox", t.parent )
	t.w = t.w or 100
	t.h = t.h or 20
	pnl:SetPos( t.x, t.y )
	pnl:SetSize( t.w, t.h )

	--Create a textbox to use in place of the button
	if ( t.enableinput == true ) then
		pnl.TextEntry = vgui.Create( "DTextEntry", pnl )
		pnl.TextEntry.selectAll = t.selectall
		pnl.TextEntry:SetEditable( true )

		pnl.TextEntry.OnGetFocus = function( self ) --Close the menu when the textbox is clicked, IF the menu was open.
			hook.Run( "OnTextEntryGetFocus", self )
			if ( pnl.Menu ) then
				pnl.Menu:Remove()
				pnl.Menu = nil
			end
		end

		--Override GetValue/SetValue to get/set the text from the TextEntry instead of itself.
		pnl.GetValue = function( self ) return self.TextEntry:GetValue() end
		pnl.SetText = function( self, val ) self.TextEntry:SetValue( val ) end

		pnl.ChooseOption = function( self, value, index ) --Update the text of the TextEntry when an option is selected.
			if ( self.Menu ) then
				self.Menu:Remove()
				self.Menu = nil
			end
			self.TextEntry:SetText( value )
			self:OnSelect( index, value, self.Data[index] )
		end

		pnl.PerformLayout = function( self ) --Update the size of the textbox when the combobox's PerformLayout is called.
			self.DropButton:SetSize( 15, 15 )
			self.DropButton:AlignRight( 4 )
			self.DropButton:CenterVertical()
			self.TextEntry:SetSize( self:GetWide()-20, self:GetTall() )
		end
	end

	pnl:SetText( t.text or "" )

	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetToolTip( t.tooltip )
	end

	if t.choices then
		for i, v in ipairs( t.choices ) do
			pnl:AddChoice( v )
		end
	end

	function pnl:SetDisabled( val ) --enabling/disabling of a textbox
		self:SetMouseInputEnabled( not val )
		self:SetAlpha( val and 128 or 255 )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end

	--Garrys function with no comments, just adding support for Spacers
	function pnl:OpenMenu()
		if ( #self.Choices == 0 ) then return end
		if ( IsValid( self.Menu ) ) then
			self.Menu:Remove()
			self.Menu = nil
		end
		self.Menu = DermaMenu()
			for k, v in pairs( self.Choices ) do
				if v == "--*" then --This is the string to determine where to add the spacer
					self.Menu:AddSpacer()
				else
					self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
				end
			end
			local x, y = self:LocalToScreen( 0, self:GetTall() )
			self.Menu:SetMinimumWidth( self:GetWide() )
			self.Menu:Open( x, y, false, self )
	end

	--Replicated Convar Updating
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		if t.isNumberConvar then --This is for convar settings stored via numbers (like ulx_rslotsMode)
			if t.numOffset == nil then t.numOffset = 1 end
			local cvar = GetConVar( t.repconvar ):GetInt()
			if tonumber( cvar ) and cvar + t.numOffset <= #pnl.Choices and cvar + t.numOffset > 0 then
				pnl:ChooseOptionID( cvar + t.numOffset )
			else
				pnl:SetText( "Invalid Convar Value" )
			end
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					if tonumber( new_val ) and new_val + t.numOffset <= #pnl.Choices and new_val + t.numOffset > 0 then
						pnl:ChooseOptionID( new_val + t.numOffset )
					else
						pnl:SetText( "Invalid Convar Value" )
					end
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnSelect( index )
				RunConsoleCommand( t.repconvar, tostring( index - t.numOffset ) )
			end
		else  --Otherwise, use each choice as a string for the convar
			pnl:SetText( GetConVar( t.repconvar ):GetString() )
			function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
				if cl_cvar == t.repconvar:lower() then
					if t.convarblanklabel and new_val == "" then new_val = t.convarblanklabel end
					pnl:SetText( new_val )
				end
			end
			hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
			function pnl:OnSelect( index, value )
				if t.convarblanklabel and value == "<not specified>" then value = "" end
				RunConsoleCommand( t.repconvar, value )
			end
		end
	end

	return pnl
end

function Athena.Elements.Slider( t )
	local pnl = vgui.Create( "DNumSlider", t.parent )
	
	pnl.PerformLayout = function() end  -- Clears the code that automatically sets the width of the label to 41% of the entire width.
	
	pnl:SetPos( t.x, t.y )
	pnl:SetWide( t.w or 100 )
	pnl:SetTall( t.h or 20 )
	pnl:SetText( t.label or "" )
	pnl:SetMinMax( t.min or 0, t.max or 100 )
	pnl:SetDecimals( t.decimal or 0 )
	pnl.TextArea:SetDrawBackground( true )
	pnl.TextArea.selectAll = t.selectall
	pnl.Label:SizeToContents()
	
	if t.textcolor then
		pnl.Label:SetTextColor( t.textcolor )
	else
		pnl.Label:SetTextColor( SKIN.text_dark )
	end
	
	if t.fixclip then pnl.Slider.Knob:NoClipping( false ) end --Fixes clipping on the knob, an example is the sandbox limit sliders.
	
	if t.convar then pnl:SetConVar( t.convar ) end
	if not t.tooltipwidth then t.tooltipwidth = 250 end
	if t.tooltip then
		if t.tooltipwidth ~= 0 then
			t.tooltip = xlib.wordWrap( t.tooltip, t.tooltipwidth, "Default" )
		end
		pnl:SetToolTip( t.tooltip )
	end
	
	--Support for enabling/disabling slider
	pnl.SetDisabled = function( self, val )
		pnl:SetAlpha( val and 128 or 255 )
		pnl:SetEnabled( not val )
		pnl.TextArea:SetEnabled( not val )
		pnl.TextArea:SetMouseInputEnabled( not val )
		pnl.Scratch:SetMouseInputEnabled( not val )
		pnl.Slider:SetMouseInputEnabled( not val )
	end
	if t.disabled then pnl:SetDisabled( t.disabled ) end
	
	pnl:SizeToContents()
	
	--
	--The following code bits are basically copies of Garry's code with changes to prevent the slider from sending updates so often
	pnl.GetValue = function( self ) return tonumber( self.TextArea:GetValue() ) end
	function pnl.SetValue( self, val )
		if ( val == nil ) then return end
		if t.clampmin then val = math.max( tonumber( val ) or 0, self:GetMin() ) end
		if t.clampmax then val = math.min( tonumber( val ) or 0, self:GetMax() ) end
		self.Scratch:SetValue( val )
		self.ValueUpdated( val )
		self:ValueChanged( val )
	end
	function pnl.ValueChanged( self, val )
		if t.clampmin then val = math.max( tonumber( val ) or 0, self:GetMin() ) end
		if t.clampmax then val = math.min( tonumber( val ) or 0, self:GetMax() ) end
		self.Slider:SetSlideX( self.Scratch:GetFraction( val ) )
		if ( self.TextArea != vgui.GetKeyboardFocus() ) then
			self.TextArea:SetValue( self.Scratch:GetTextValue() )
		end
		self:OnValueChanged( val )
	end
	
	--Textbox
	function pnl.ValueUpdated( value )
		pnl.TextArea:SetText( string.format("%." .. ( pnl.Scratch:GetDecimals() ) .. "f", tonumber( value ) or 0) )
	end
	pnl.TextArea.OnTextChanged = function() end
	function pnl.TextArea:OnEnter()
		pnl.TextArea:SetText( string.format("%." .. ( pnl.Scratch:GetDecimals() ) .. "f", tonumber( pnl.TextArea:GetText() ) or 0) )
		if pnl.OnEnter then pnl:OnEnter() end
	end
	function pnl.TextArea:OnLoseFocus()
		pnl:SetValue( pnl.TextArea:GetText() )
		hook.Call( "OnTextEntryLoseFocus", nil, self )
	end
	
	--Slider
	local pnl_val
	function pnl:TranslateSliderValues( x, y )
		pnl_val = self.Scratch:GetMin() + (x * self.Scratch:GetRange()) --Store the value and update the textbox to the new value
		pnl.ValueUpdated( pnl_val )
		self.Scratch:SetFraction( x )
		
		return self.Scratch:GetFraction(), y
	end
	local tmpfunc = pnl.Slider.Knob.OnMouseReleased
	pnl.Slider.Knob.OnMouseReleased = function( self, mcode )
		tmpfunc( self, mcode )
		pnl.Slider:OnMouseReleased( mcode )
	end
	local tmpfunc = pnl.Slider.SetDragging
	pnl.Slider.SetDragging = function( self, bval )
		tmpfunc( self, bval )
		if ( !bval ) then pnl:SetValue( pnl.TextArea:GetText() ) end
	end
	pnl.Slider.OnMouseReleased = function( self, mcode )
		self:SetDragging( false )
		self:MouseCapture( false )
	end
	
	--Scratch
	function pnl.Scratch:OnCursorMoved( x, y )
		if ( !self:GetActive() ) then return end

		x = x - math.floor( self:GetWide() * 0.5 )
		y = y - math.floor( self:GetTall() * 0.5 )

		local zoom = self:GetZoom()
		local ControlScale = 100 / zoom;
		local maxzoom = 20
		if ( self:GetDecimals() ) then
			maxzoom = 10000
		end
		zoom = math.Clamp( zoom + ((y * -0.6) / ControlScale), 0.01, maxzoom );
		self:SetZoom( zoom )

		local value = self:GetFloatValue()
		value = math.Clamp( value + (x * ControlScale * 0.002), self:GetMin(), self:GetMax() );
		self:SetFloatValue( value )
		pnl_val = value --Store value for later
		pnl.ValueUpdated( pnl_val )
		
		self:LockCursor()
	end
	pnl.Scratch.OnMouseReleased = function( self, mousecode )
		g_Active = nil

		self:SetActive( false )
		self:MouseCapture( false )
		self:SetCursor( "sizewe" )
		
		pnl:SetValue( pnl.TextArea:GetText() )
	end
	--End code changes
	--
	
	if t.value then pnl:SetValue( t.value ) end
	
	--Replicated Convar Updating
	if t.repconvar then
		xlib.checkRepCvarCreated( t.repconvar )
		pnl:SetValue( GetConVar( t.repconvar ):GetFloat() )
		function pnl.ConVarUpdated( sv_cvar, cl_cvar, ply, old_val, new_val )
			if cl_cvar == t.repconvar:lower() then
				if ( IsValid( pnl ) ) then	--Prevents random errors when joining.
					pnl:SetValue( new_val )
				end
			end
		end
		hook.Add( "ULibReplicatedCvarChanged", "XLIB_" .. t.repconvar, pnl.ConVarUpdated )
		function pnl:OnValueChanged( val )
			RunConsoleCommand( t.repconvar, tostring( val ) )
		end
		--Override think functions to remove Garry's convar check to (hopefully) speed things up
		pnl.ConVarNumberThink = function() end
		pnl.ConVarStringThink = function() end
		pnl.ConVarChanged = function() end
	end
	
	return pnl
end
--[[
	 _
	( )
   _| |   __   _ __   ___ ___     _ _
 /´_` | /´__`\( '__)/´ _ ` _ `\ /´_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_)

	DColorPalette
--]]

local color_Error = Color( 255, 0, 255 )

local PANEL = {}

AccessorFunc( PANEL, "m_ConVarR", "ConVarR" )
AccessorFunc( PANEL, "m_ConVarG", "ConVarG" )
AccessorFunc( PANEL, "m_ConVarB", "ConVarB" )
AccessorFunc( PANEL, "m_ConVarA", "ConVarA" )

AccessorFunc( PANEL, "curCol", "Color" )

AccessorFunc( PANEL, "m_buttonsize", "ButtonSize", FORCE_NUMBER )

--[[---------------------------------------------------------
	Default palette
-----------------------------------------------------------]]
local function CreateColorTable( self )

	local x, y = self:GetSize()
	local bsize = self.m_buttonsize
	x = math.floor(x/bsize)
	y = math.floor(y/bsize)

	//local rows = rows or 12
	local buttons = y*x
	local butspercat = math.floor(buttons/5)-1
	local leftover = buttons - math.floor(buttons/5)*5
	local index = 0
	local ColorTable = {}
	for i=0, butspercat + leftover do -- HSV 
		local col = math.Round( math.min( i * ( 360 / ( butspercat + leftover ) ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 1, 1 )
	end

	for i=0, butspercat do -- HSV dark
		local col = math.Round( math.min( i * ( 360 / butspercat ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 1, 0.5 )
	end

	for i=0, butspercat do -- HSV grey
		local col = math.Round( math.min( i * ( 360 / butspercat ), 359 ) )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 0.5, 0.5 )
	end

	for i=0, butspercat do -- HSV bright
		local col = math.min( i * ( 360 / butspercat ), 359 )
		index = index + 1
		ColorTable[index] = HSVToColor( 360 - col, 0.5, 1 )
	end

	for i=0, butspercat do -- Greyscale
		local white = 255 - math.Round( math.min( i * ( 256 / ( butspercat - 1 ) ), 255 ) )
		index = index + 1
		ColorTable[index] = Color( white, white, white )
	end

	return ColorTable

end

local function AddButton( panel, color, size, id )

	local button = vgui.Create( "DColorButton", panel )
	button:SetSize( size or 10, size or 10 )
	button:SetID( id )

	--
	-- If the cookie value exists, then use it
	--
	local col_saved = panel:GetCookie( "col."..id, nil );
	if ( col_saved != nil ) then
		color = col_saved:ToColor()
	end

	button:SetColor( color or color_Error )

	button.DoClick = function( self )
		local col = self:GetColor() or color_Error
		panel:UpdateConVars( col )
		panel:DoClick( col, button )
	end

	button.DoRightClick = function( self )
		panel:OnRightClickButton( self )
	end

	return button

end

--[[---------------------------------------------------------
	Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetSize( 120, 120 )
	self:SetButtonSize( 12 )
	self:Reset()
	self:SetCookieName( "palette" )


end

--[[---------------------------------------------------------
	Name: DoClick
-----------------------------------------------------------]]
function PANEL:DoClick( color, button )

	self.curCol = color
	self:OnColorChanged()

end


--[[---------------------------------------------------------
	Name: OnColorChanged
-----------------------------------------------------------]]
function PANEL:OnColorChanged( color )

end



--[[---------------------------------------------------------
	Name: Reset
-----------------------------------------------------------]]
function PANEL:Reset()

	self:SetColorButtons( CreateColorTable( self ) )

end

--[[---------------------------------------------------------
	Name: SetColorButtons
-----------------------------------------------------------]]
function PANEL:SetColorButtons( tab )

	self:Clear()

	for i, color in pairs( tab or {} ) do

		local index = tonumber( i )
		if ( !index ) then break end

		AddButton( self, color, self.m_buttonsize, i )

	end

	self:InvalidateLayout()

end

--[[---------------------------------------------------------
	Name: SetButtonSize
-----------------------------------------------------------]]
function PANEL:SetButtonSize( val )

	self.m_buttonsize = math.floor( val )

	for k, v in pairs( self:GetChildren() ) do
		v:SetSize( self.m_buttonsize, self.m_buttonsize )	
	end

	self:InvalidateLayout()

end

--[[---------------------------------------------------------
	Name: UpdateConVar
-----------------------------------------------------------]]
function PANEL:UpdateConVar( strName, strKey, color )

	if ( !strName ) then return end

	RunConsoleCommand( strName, tostring( color[ strKey ] ) )

end

--[[---------------------------------------------------------
	Name: UpdateConVars
-----------------------------------------------------------]]
function PANEL:UpdateConVars( color )

	self:UpdateConVar( self.m_ConVarR, 'r', color )
	self:UpdateConVar( self.m_ConVarG, 'g', color )
	self:UpdateConVar( self.m_ConVarB, 'b', color )
	self:UpdateConVar( self.m_ConVarA, 'a', color )

end

--[[---------------------------------------------------------
	Name: SaveColor
-----------------------------------------------------------]]
function PANEL:SaveColor( btn, color )

	-- Avoid unintended color changing.
	color = table.Copy( color or color_Error ) 

	btn:SetColor( color )
	self:SetCookie( "col."..btn:GetID(), string.FromColor( color ) );

end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetSize( 256, 256 )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DColorPalette_Holopad", "", PANEL, "DIconLayout" )
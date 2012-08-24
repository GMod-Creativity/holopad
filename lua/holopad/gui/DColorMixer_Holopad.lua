/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DColorMixer_Holopad
	
*/

local PANEL = {}

AccessorFunc( PANEL, "m_ConVarR", 				"ConVarR" )
AccessorFunc( PANEL, "m_ConVarG", 				"ConVarG" )
AccessorFunc( PANEL, "m_ConVarB", 				"ConVarB" )
AccessorFunc( PANEL, "m_ConVarA", 				"ConVarA" )

AccessorFunc( PANEL, "m_fSpacer", 				"Spacer" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.RGBBar = vgui.Create( "DRGBBar", self )
	self.RGBBar.OnColorChange = function( ctrl, color ) self:SetBaseColor( color )	self:OnColorChanged(color) end
	
	self.AlphaBar = vgui.Create( "DAlphaBar", self )
	self.AlphaBar.OnChange = function( ctrl, alpha ) self:SetColorAlpha( alpha )	self:OnColorChanged(color) end
	
	self.ColorCube = vgui.Create( "DColorCube", self )
	self.ColorCube.OnUserChanged = function( ctrl ) self:ColorCubeChanged( ctrl )	self:OnColorChanged(color) end
	
	self:SetColor( Color( 255, 100, 100, 255 ) )
	
	self:SetSpacer( 3 )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local SideBoxSize = self:GetTall() * 0.15

	self.RGBBar:SetWide( SideBoxSize )
	self.RGBBar:StretchToParent( 0, 0, nil, 0 )
	
	self.AlphaBar:CopyBounds( self.RGBBar )
	self.AlphaBar:MoveRightOf( self.RGBBar, self.m_fSpacer )

	self.ColorCube:MoveRightOf( self.AlphaBar, self.m_fSpacer )
	self.ColorCube:StretchToParent( nil, 0, SideBoxSize + self.m_fSpacer, 0 )
	
end



/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:SetConVarA( val )

	self.m_ConVarA = val

	if ( val == nil ) then
		self.AlphaBar:SetLockY( 0 )
	else
		self.AlphaBar:SetLockY( nil )
	end
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:SetColorAlpha( alpha )

	alpha = alpha or 0

	if ( !self.m_ConVarA ) then return end
	
	RunConsoleCommand( self.m_ConVarA, alpha )
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:TranslateValues( x, y )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetBaseColor( color )

	self.RGBBar:SetColor( color )
	self.ColorCube:SetBaseRGB( color )
	
	self:UpdateConVars( self.ColorCube:GetRGB() )
	self.AlphaBar:SetImageColor( self:GetColor() )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetColor( color )

	self.ColorCube:SetColor( color )
	self.RGBBar:SetColor( color )
	self.AlphaBar:SetImageColor( color )
	self.AlphaBar:SetSlideY( 1 - (color.a / 255) )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:UpdateConVar( strName, strKey, color )

	if ( !strName ) then return end
	
	RunConsoleCommand( strName, tostring( color[ strKey ] ) )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:UpdateConVars( color )

	self.NextConVarCheck = SysTime() + 0.1

	self:UpdateConVar( self.m_ConVarR, 'r', color )
	self:UpdateConVar( self.m_ConVarG, 'g', color )
	self:UpdateConVar( self.m_ConVarB, 'b', color )
	self:UpdateConVar( self.m_ConVarA, 'a', color )	
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:ColorCubeChanged( cube )

	self:UpdateConVars( self:GetColor() )
	self.AlphaBar:SetImageColor( self:GetColor() )

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:GetColor()

	local color = self.ColorCube:GetRGB()
	
	//if ( self.m_ConVarA ) then
		color.a = 255 - (self.AlphaBar:GetSlideY() * 255)
	//else
	//	color.a = 255
	//end
	
	return color

end



function PANEL:OnColorChanged(color)
	// hello :D
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Think()

	self:ConVarThink()
	
end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:ConVarThink()

	// Don't update the convars while we're changing them!
	if ( self.ColorCube:GetDragging() ) then return end

	self:DoConVarThink( self.m_ConVarR, 'r' )
	self:DoConVarThink( self.m_ConVarG, 'g' )
	self:DoConVarThink( self.m_ConVarB, 'b' )
	self:DoConVarThink( self.m_ConVarA, 'a' )

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:DoConVarThink( convar, key )

	if ( !convar ) then return end
	
	local fValue = GetConVarNumber( convar )
	local fOldValue = self[ 'ConVarOld'..convar ]
	if ( fOldValue && fValue == fOldValue ) then return end
	
	self[ 'ConVarOld'..convar ] = fValue

	local r = GetConVarNumber( self.m_ConVarR )
	local g = GetConVarNumber( self.m_ConVarG )
	local b = GetConVarNumber( self.m_ConVarB )
	
	local a = 255
	
	if ( self.m_ConVarA ) then
		a = GetConVarNumber( self.m_ConVarA )
	end
	
	local color = Color( r, g, b, a )
	self:SetColor( color )	

end

vgui.Register( "DColorMixer_Holopad", PANEL, "DPanel" )

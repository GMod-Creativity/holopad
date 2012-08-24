/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Background Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Coloured background with colour changing and image display
	
//*/

local PANEL = {}


function PANEL:Init()

	self:SetPaintBackgroundEnabled( false )
    self:SetPaintBorderEnabled( false )
	self.colour = Holopad.BACKGROUND_COLOUR()

end



function PANEL:Paint()
	local col = self.colour
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	if !self.picture then return end
	// TODO: draw picture
end



/**
	Set the colour of this panel to the parameter, or default.
	Args;
		colour	Color
			desired colour of the panel
 */
function PANEL:SetColour(colour)
	self.colour = colour or Holopad.BACKGROUND_COLOUR()
end

	
derma.DefineControl( "DBackground_Holopad", "Coloured background with colour changing and image display", PANEL, "DPanel" )
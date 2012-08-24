/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Corner Button Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Coloured background with colour changing and image display
	
//*/

local PANEL = {}


function PANEL:Init()

	self:SetImage("holopad/magnifier")
	self:SetText("")
	self:SetWide(self:GetTall()+2)

end



function PANEL:DoClick()

	local menu = DermaMenu()
	local viewport = self.viewpanel:GetViewport()
	local glasspane = self.viewpanel:GetGlassPane()
	
		local submenu1 = menu:AddSubMenu( "View Modes" )
	
			submenu1:AddOption( "Coloured Lights", function()
				viewport:resetRenderSettings()
				viewport:SetAmbientLight( Color( 255, 255, 255 ) )
				viewport:SetDirectionalLight( BOX_FRONT,	Color( 255, 0, 0 ) )
				viewport:SetDirectionalLight( BOX_BACK,		Color( 0, 255, 255 ) )
				viewport:SetDirectionalLight( BOX_RIGHT,	Color( 0, 255, 0 ) )
				viewport:SetDirectionalLight( BOX_LEFT,		Color( 255, 0, 255 ) )
				viewport:SetDirectionalLight( BOX_TOP,		Color( 0, 0, 255 ) )
				viewport:SetDirectionalLight( BOX_BOTTOM,	Color( 255, 255, 0 ) )
			end)
			
			submenu1:AddOption( "White Lights", function()
				viewport:resetRenderSettings()
				viewport:SetAmbientLight( Color( 50, 50, 50 ) )
				viewport:SetDirectionalLight( BOX_RIGHT, Color( 255, 255, 255 ) )
				viewport:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
			end)
			
			submenu1:AddOption( "Shadowless", function()
				viewport:resetRenderSettings()
				viewport:SetAmbientLight( Color( 255, 255, 255 ) )
			end)
			
			submenu1:AddOption( "Wireframe", function()
				viewport:resetRenderSettings()
				viewport:SetOverrideMaterial("models/wireframe")
			end)
		
		
		local submenu2 = menu:AddSubMenu( "Preset Cameras" )
	
			submenu2:AddOption( "Front", function()
				viewport:SetLookAt(Vector(0,0,0))
				viewport:SetCamAng(Angle(0,180,0), 100)
			end)
			submenu2:AddOption( "Right", function()
				viewport:SetLookAt(Vector(0,0,0))
				viewport:SetCamAng(Angle(0,270,0), 100)
			end)
			submenu2:AddOption( "Top", function()
				viewport:SetLookAt(Vector(0,0,0))
				viewport:SetCamAng(Angle(89,0,0), 100)
			end)
			submenu2:AddOption( "Default", function()
				viewport:SetLookAt(Vector(0,0,0))
				viewport:SetCamAng(Angle(30,210,0), 100)
			end)
		
		
	menu:AddOption( viewport:GetShowStats() and "Hide Statistics" or "Show Statistics", function() viewport:ToggleShowStats() end )
	
	menu:AddOption( glasspane:GetShouldDraw() and "Screenshot Mode" or "Editor Mode", 	function()
																							local bool = !glasspane:GetShouldDraw()
																							glasspane:ShouldDraw(bool)
																							viewport:ShowGrid(bool)
																							viewport:GetModelObj():deselectAll()
																						end )
		
	menu:Open()
end	



/**
	Set the DViewPanel which this button interacts with
	Args;
		panel	DViewPanel_Holopad
			panel to interface with
 */
function PANEL:SetViewPanel(panel)
	self.viewpanel = panel
end

	
derma.DefineControl( "DViewCornerButton_Holopad", "Corner button for DViewPanel_Holopad", PANEL, "DButton" )



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
				viewport:SetLightingScheme("coloured")
			end)
			
			submenu1:AddOption( "White Lights", function()
				viewport:SetLightingScheme("white")
			end)

			submenu1:AddOption( "White Lights 2", function()
				viewport:SetLightingScheme("white2")
			end)
			
			submenu1:AddOption( "Shadowless", function()
				viewport:SetLightingScheme("shadowless")
			end)
			
			submenu1:AddOption( "Wireframe", function()
				viewport:SetLightingScheme("wireframe")
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
																						
	local submenu3 = menu:AddSubMenu("Grid Styles")
	
		submenu3:AddOption( "Grey Lines", function()
			viewport:GetGrid():SetMaterial("holopad/gridbw")
			Holopad.GridMaterial = "holopad/gridbw"
		end)
		
		submenu3:AddOption( "Grey Crosses", function()
			viewport:GetGrid():SetMaterial("holopad/gridbwcr")
			Holopad.GridMaterial = "holopad/gridbwcr"
		end)
		
		submenu3:AddOption( "Grey Points", function()
			viewport:GetGrid():SetMaterial("holopad/gridbwpt")
			Holopad.GridMaterial = "holopad/gridbwpt"
		end)
		
		submenu3:AddOption( "Colour Lines", function()
			viewport:GetGrid():SetMaterial("holopad/gridcol")
			Holopad.GridMaterial = "holopad/gridcol"
		end)
		
		submenu3:AddOption( "Colour Crosses", function()
			viewport:GetGrid():SetMaterial("holopad/gridcolcr")
			Holopad.GridMaterial = "holopad/gridcolcr"
		end)
		
		submenu3:AddOption( "Colour Points", function()
			viewport:GetGrid():SetMaterial("holopad/gridcolpt")
			Holopad.GridMaterial = "holopad/gridcolpt"
		end)
		
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



/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Measure Tool Context Control Derma
	splambob@gmail.com	 |_| 15/09/2012               

	for measuring!
	
//*/


include("holopad/gui/DColorMixer_Holopad.lua")
include("holopad/gui/DEntityDialogue_Holopad.lua")


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 300
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "select"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Tool Config", self:createControls(), "holopad/tools/measure", false, false, "Tool Config" )
	
	self:SetTitle("Holopad 2; Tool Config")
	local parent	 = self:GetParent()//:GetViewPanel():GetViewport()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	//self:SetPos(parx + pwidth + 1, pary)
	self:MoveLeftOf(parent, 1)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	self.Close = 	function(self)
						if self.tool then
							self.tool:Quit()
						end
						oldclose(self)
					end
	
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end



function PANEL:SetTool(mdl)
	if self.tool then Error("Can't reset the tool bound to a tool gui!") return end
	if !mdl:class() == Holopad.Tools.Mirror then Error("Can't bind this gui to this tool!") return end
	self.tool = mdl
end

function PANEL:GetTool()
	return self.tool
end



function PANEL:SetDistLabelValue(dist)
	self.distlabel:SetText(dist)
	self.distlabel:SizeToContents()
end



function PANEL:createControls()	
	
	local listOfCats = vgui.Create( "DPanelList", Edit )
	listOfCats:SetSpacing( 5 )
	listOfCats:EnableVerticalScrollbar( true )
	
	
	local category = vgui.Create("DCollapsibleCategory")
	category:SetSize( self.ContentX, self.ContentY )
	category:SetExpanded( 1 )
	category:SetLabel( "Measure Tool" )
	category.Header:SetMouseInputEnabled(false)
	
	local categoryList = vgui.Create( "DPanelList" )
	categoryList:SetAutoSize( true )
	categoryList:SetSpacing( 5 )
	categoryList:EnableHorizontal( false )
	categoryList:EnableVerticalScrollbar( true )
	
	category:SetContents(categoryList)
	
	
	local apppanel = vgui.Create("DPanel")
	apppanel.Paint = function() end
	
	local collabel = vgui.Create("DLabel", apppanel)
	collabel:SetText(
[[This is the Measure Tool!

Move the endpoints to measure!
Distances are measured in GLU
(GMod Length Units)

TODO: more units (mm, m, in, ft).
TODO: above with 0.75 / 1 selector
TODO: onscreen display
]]
	)
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	local ypos = 20 + collabel:GetTall()
	
	local cdlabel1 = vgui.Create("DLabel", apppanel)
	cdlabel1:SetText("Distance:")
	cdlabel1:SizeToContents()
	cdlabel1:SetPos(5, ypos)
	
	local cdlabel2 = vgui.Create("DLabel", apppanel)
	cdlabel2:SetText("")
	cdlabel2:SizeToContents()
	cdlabel2:SetPos(5 + cdlabel1:GetWide(), ypos)
	self.distlabel = cdlabel2
	
	ypos = ypos + 10 + cdlabel1:GetTall()
	
	apppanel:SetTall(ypos + 5)
	
	categoryList:AddItem(apppanel)
	
	listOfCats:AddItem(category)
	
	return listOfCats
	
end



derma.DefineControl( "DMeasureTool_Holopad", "Context controls for Measure Tool", PANEL, "DFrame" )



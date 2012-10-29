/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Mirror Tool Context Control Derma
	splambob@gmail.com	 |_| 14/09/2012               

	for mirroring!
	
//*/


include("holopad/gui/DEntityDialogue_Holopad.lua")


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 370
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "select"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Tool Config", self:createControls(), "holopad/tools/mirror", false, false, "Tool Config" )
	
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



function PANEL:createControls()
	
	
	local function apply()
		if self.tool then self.tool:Apply() end
	end
	
	local function selectplane()
		if self.tool then self.tool:GetModelObj():selectEnt(self.tool:GetMirrorPlane()) end
	end
	
	
	local listOfCats = vgui.Create( "DPanelList", Edit )
	listOfCats:SetSpacing( 5 )
	listOfCats:EnableVerticalScrollbar( true )
	
	
	local category = vgui.Create("DCollapsibleCategory")
	category:SetSize( self.ContentX, self.ContentY )
	category:SetExpanded( 1 )
	category:SetLabel( "Mirror Tool" )
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
[[This is the Mirror Tool!

Move the plane, then select the
things you want to mirror.

Press Apply to mirror the
selected objects!

Warning: Clip-planes apply to
ALL selected entities!!]]
	)
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	local ypos = 20 + collabel:GetTall()
	
	local clonecheck = vgui.Create( "DCheckBoxLabel", apppanel )
	clonecheck:SetPos( 5, ypos )
	clonecheck:SetText( "Copy Across Mirror Plane" )
	clonecheck.OnChange = function(check) if self.tool then self.tool:SetCloneEnts(clonecheck:GetChecked()) end end
	clonecheck:SetChecked(true)
	clonecheck:SizeToContents()
	
	ypos = ypos + 10 + clonecheck:GetTall()
	
	local slicecheck = vgui.Create( "DCheckBoxLabel", apppanel )
	slicecheck:SetPos( 5, ypos )
	slicecheck:SetText( "Mirror Plane = Clip Plane" )
	slicecheck.OnChange = function(check) if self.tool then self.tool:SetPlaneSlice(slicecheck:GetChecked()) end end
	slicecheck:SetChecked(true)
	slicecheck:SizeToContents()
	
	ypos = ypos + 10 + slicecheck:GetTall()
	
	local selectbutton = vgui.Create("DButton", apppanel)
	selectbutton:SetText( "Select Mirror Plane" )
	selectbutton.DoClick = selectplane
	selectbutton:SetSize(180, 20)
	selectbutton:SetPos(5, ypos)
	
	ypos = ypos + 30
	
	local setColourButton = vgui.Create("DButton", apppanel)
	setColourButton:SetText( "Apply" )
	setColourButton.DoClick = apply
	setColourButton:SetSize(180, 40)
	setColourButton:SetPos(5, ypos)
	
	ypos = ypos + 40
	
	apppanel:SetTall(ypos + 5)
	
	categoryList:AddItem(apppanel)
	
	listOfCats:AddItem(category)
	
	print("ypos", ypos)
	
	return listOfCats
	
end



derma.DefineControl( "DMirrorTool_Holopad", "Context controls for Mirror Tool", PANEL, "DFrame" )



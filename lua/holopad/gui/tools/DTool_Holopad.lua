/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Base Tool Context Control Derma
	splambob@gmail.com	 |_| 14/09/2012               

	for testing!
	
//*/


include("holopad/gui/DColorMixer_Holopad.lua")
include("holopad/gui/DEntityDialogue_Holopad.lua")


local PANEL = {}
Holopad.Tools = Holopad.Tools or {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 600
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "select"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Tool Config", self:createControls(), "holopad/tools/tool", false, false, "Tool Config" )
	
	self:SetTitle("Holopad 2; Tool Config")
	local parent	 = self:GetParent()//:GetViewPanel():GetViewport()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	//self:SetPos(parx + pwidth + 1, pary)
	self:MoveRightOf(parent, 1)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	self.Close = function(self) self.Close2(self) oldclose(self) end
	
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end



function PANEL:Close2()
	hook.Remove(Holopad.MODEL_UPDATE .. tostring(self:GetModelObj()), tostring(self))
	self:GetParent():closingContext(self)
end



function PANEL:SetModelObj(mdl)
	if self.mdlobj then
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.mdlobj), tostring(self))
	end
	self.mdlobj = mdl
	hook.Add(Holopad.MODEL_UPDATE .. tostring(mdl), tostring(self), self.receiveUpdate)
end

function PANEL:GetModelObj()
	return self.mdlobj
end


/*
function PANEL:SetMirrorPlane(ent)
	self.plane = ent
end

function PANEL:GetMirrorPlane()
	return self.plane
end
//*/



function PANEL:createControls()
	
	
	local function close()
		self:Close()
	end
	
	
	local listOfCats = vgui.Create( "DPanelList", Edit )
	listOfCats:SetSpacing( 5 )
	listOfCats:EnableVerticalScrollbar( true )
	
	
	local category = vgui.Create("DCollapsibleCategory")
	category:SetSize( self.ContentX, self.ContentY )
	category:SetExpanded( 1 )
	category:SetLabel( "Appearance" )
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
[[This is the Generic Tool!
This tool has no features.
It is the base which all tools use.]]
	)
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	local ypos = 5 + collabel:GetTall()
	
	setColourButton = vgui.Create("DButton", apppanel)
	setColourButton:SetText( "OK!" )
	setColourButton.DoClick = close
	setColourButton:SetSize(180, 40)
	setColourButton:SetPos(5, ypos)
	
	listOfCats:AddItem(category)
	
	return listOfCats
	
end



derma.DefineControl( "DTool_Holopad", "Context controls for Tool", PANEL, "DFrame" )



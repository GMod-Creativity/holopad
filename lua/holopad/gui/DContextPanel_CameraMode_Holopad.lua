/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | CameraMode Context Control Derma
	splambob@gmail.com	 |_| 29/07/2012               

	Controls for camera settings and preferences
	
//*/


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 210, 375
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "camera"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Camera", self:createControls(), "holopad/arrowup_solid", false, false, "Camera Settings" )
	
	self:SetTitle("Holopad 2; Camera Settings")
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
	self:GetParent():closingContext(self)
end



function PANEL:SetModelObj(mdl)
	if !mdl then return end
	if self.mdlobj then
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.mdlobj), tostring(self))
	end
	self.mdlobj = mdl
	hook.Add(Holopad.MODEL_UPDATE .. tostring(mdl), tostring(self), self.receiveUpdate)
end



function PANEL:GetModelObj()
	return self.mdlobj
end



function PANEL:createControls()
	
	local MOVEMAX = 500
	local invXCheck, invYCheck, invPXCheck, invPYCheck
	local colourCube
	local bgcol = Holopad.BACKGROUND_COLOUR
	
	
	
	local dholoSetBGCol = function()
		local colour = colourCube:GetColor()
		Holopad.BACKGROUND_COLOUR = colour
	end
	

	
	local category = vgui.Create("DCollapsibleCategory")
	category:SetSize( self.ContentX, self.ContentY )
	category:SetExpanded( 1 )
	category:SetLabel( "Camera Settings" )
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
	collabel:SetText("Rotation:")
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	ypos = 10 + collabel:GetTall()
	
	invXCheck = vgui.Create( "DCheckBoxLabel", apppanel )
	invXCheck:SetPos( 5, ypos )
	invXCheck:SetText( "Invert X Axis" )
	invXCheck.OnChange = function(check) Holopad.InvertCameraX = invXCheck:GetChecked() and -1 or 1 end
	invXCheck:SetValue( Holopad.InvertCameraX and math.Clamp(Holopad.InvertCameraX, 0, 1) or 1 )
	invXCheck:SizeToContents()
	
	ypos = ypos + 5 + invXCheck:GetTall()
	
	invYCheck = vgui.Create( "DCheckBoxLabel", apppanel )
	invYCheck:SetPos( 5, ypos )
	invYCheck:SetText( "Invert Y Axis" )
	invYCheck.OnChange = function(check) Holopad.InvertCameraY = invYCheck:GetChecked() and -1 or 1 end
	invYCheck:SetValue( Holopad.InvertCameraY and math.Clamp(Holopad.InvertCameraY, 0, 1) or 1 )
	invYCheck:SizeToContents()
	
	ypos = ypos + 10 + invXCheck:GetTall()
	
	local panlabel = vgui.Create("DLabel", apppanel)
	panlabel:SetText("Panning:")
	panlabel:SizeToContents()
	panlabel:SetPos(5, ypos)
	
	ypos = ypos + 5 + panlabel:GetTall()
	
	invPXCheck = vgui.Create( "DCheckBoxLabel", apppanel )
	invPXCheck:SetPos( 5, ypos )
	invPXCheck:SetText( "Invert X Direction" )
	invPXCheck.OnChange = function(check) Holopad.InvertPanningX = invPXCheck:GetChecked() and -1 or 1 end
	invPXCheck:SetValue( Holopad.InvertPanningX and math.Clamp(Holopad.InvertPanningX, 0, 1) or 1 )
	invPXCheck:SizeToContents()
	
	ypos = ypos + 5 + invPXCheck:GetTall()
	
	invPYCheck = vgui.Create( "DCheckBoxLabel", apppanel )
	invPYCheck:SetPos( 5, ypos )
	invPYCheck:SetText( "Invert Y Direction" )
	invPYCheck.OnChange = function(check) Holopad.InvertPanningY = invPYCheck:GetChecked() and -1 or 1 end
	invPYCheck:SetValue( Holopad.InvertPanningY and math.Clamp(Holopad.InvertPanningY, 0, 1) or 1 )
	invPYCheck:SizeToContents()
	
	ypos = ypos + 5 + invPYCheck:GetTall()
	
	apppanel:SetSize(230, ypos)
	categoryList:AddItem(apppanel)
	
	
	local colpanel = vgui.Create("DPanel")
	colpanel.Paint = function() end
	
	colourCube = vgui.Create( "DColorPanel_Holopad", colpanel )
	colourCube.OnColorChanged = function() dholoCubeChanged() end
	
	local setMdlButton = vgui.Create("DButton", colpanel)
	setMdlButton:SetText( "Set Background Colour" )
	setMdlButton.DoClick = dholoSetBGCol
	setMdlButton:SetSize(180, 20)
	setMdlButton:SetPos(5, 5 + colourCube:GetTall())
	
	colpanel:SetSize(230, 70 + colourCube:GetTall())
	categoryList:AddItem(colpanel)

	return category
	
end



derma.DefineControl( "DContextPanel_CameraMode_Holopad", "Context controls for CameraMode", PANEL, "DFrame" )



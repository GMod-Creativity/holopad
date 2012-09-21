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
	self.ContentX, self.ContentY	= 200, 375
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
	local wanging = false
	local colourCube, wangR, wangG, wangB, wangA
	local bgcol = Holopad.BACKGROUND_COLOUR
	
	
	local function wanged()
		if !(wangR and wangG and wangB and wangA) then return end
		colourCube:SetColor(Color(wangR:GetValue(), wangG:GetValue(), wangB:GetValue(), wangA:GetValue()))
	end
	
	local dholoCubeChanged = function(cube)
		local colour = cube:GetColor()
		if wanging then return end
		wangR:SetValue(colour.r)
		wangG:SetValue(colour.g)
		wangB:SetValue(colour.b)
		wangA:SetValue(colour.a)
	end
	
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
	
	local collabel = vgui.Create("DLabel", colpanel)
	collabel:SetText("Background Colour:")
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	colourCube = vgui.Create( "DColorMixer_Holopad", colpanel )
	colourCube:SetPos( 5, 10 + collabel:GetTall() )
	colourCube:SetSize( 140, 100 )
	colourCube.OnColorChanged = dholoCubeChanged

	wangR = vgui.Create("DNumberWang", colpanel)
	wangR:SetValue(bgcol.r or 50)
	local oldendwangR, oldstartwangR = wangR.EndWang, wangR.StartWang
	wangR.EndWang	= function(self)	wanging = false		oldendwangR(self)	wanged()	end
	wangR.StartWang = function(self)	wanging = true		oldstartwangR(self)	end
	wangR.OnValueChanged = wanged
	wangR:GetTextArea():SetEditable(true)	// TODO: make typable
	wangR:GetTextArea().OnEnter = wanged
	wangR:SetMax(255)
	wangR:SetMin(0)
	wangR:SetDecimals(0)
	wangR:SetSize(55, 20)
	wangR:SetPos(130, 10 + collabel:GetTall())
	
	wangG = vgui.Create("DNumberWang", colpanel)
	wangG:SetValue(bgcol.g or 50)
	local oldendwangG, oldstartwangG = wangG.EndWang, wangG.StartWang
	wangG.EndWang	= function(self)	wanging = false		oldendwangG(self)	wanged()	end
	wangG.StartWang = function(self)	wanging = true		oldstartwangG(self)	end
	wangG.OnValueChanged = wanged
	wangG:GetTextArea():SetEditable(true)	// TODO: make typable
	wangG:GetTextArea().OnEnter = wanged
	wangG:SetMax(255)
	wangG:SetMin(0)
	wangG:SetDecimals(0)
	wangG:SetSize(55, 20)
	wangG:SetPos(130, 10 + collabel:GetTall() + wangR:GetTall() + 6)
	
	wangB = vgui.Create("DNumberWang", colpanel)
	wangB:SetValue(bgcol.b or 50)
	local oldendwangB, oldstartwangB = wangB.EndWang, wangB.StartWang
	wangB.EndWang	= function(self)	wanging = false		oldendwangB(self)	wanged()	end
	wangB.StartWang = function(self)	wanging = true		oldstartwangB(self)	end
	wangB.OnValueChanged = wanged
	wangB:GetTextArea():SetEditable(true)	// TODO: make typable
	wangB:GetTextArea().OnEnter = wanged
	wangB:SetMax(255)
	wangB:SetMin(0)
	wangB:SetDecimals(0)
	wangB:SetSize(55, 20)
	wangB:SetPos(130, 10 + collabel:GetTall() + wangR:GetTall()*2 + 12)
	
	wangA = vgui.Create("DNumberWang", colpanel)
	wangA:SetValue(bgcol.a or 255)
	local oldendwangA, oldstartwangA = wangA.EndWang, wangA.StartWang
	wangA.EndWang	= function(self)	wanging = false		oldendwangA(self)	wanged()	end
	wangA.StartWang = function(self)	wanging = true		oldstartwangA(self)	end
	wangA.OnValueChanged = wanged
	wangA:GetTextArea():SetEditable(false)	// TODO: make typable
	wangA:SetMax(255)
	wangA:SetMin(0)
	wangA:SetDecimals(0)
	wangA:SetSize(55, 20)
	wangA:SetPos(130, 10 + collabel:GetTall() + wangR:GetTall()*3 + 18)
	
	local setMdlButton = vgui.Create("DButton", colpanel)
	setMdlButton:SetText( "Set Background Colour" )
	setMdlButton.DoClick = dholoSetBGCol
	setMdlButton:SetSize(180, 20)
	setMdlButton:SetPos(5, 40 + collabel:GetTall() + wangR:GetTall()*3 + 18)
	
	colpanel:SetSize(230, 70 + collabel:GetTall() + wangR:GetTall()*3 + 18)
	categoryList:AddItem(colpanel)

	return category
	
end



derma.DefineControl( "DContextPanel_CameraMode_Holopad", "Context controls for CameraMode", PANEL, "DFrame" )



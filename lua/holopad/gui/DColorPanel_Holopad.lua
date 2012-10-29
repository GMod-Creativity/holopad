/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | DColorPanel_Holopad
	splambob@gmail.com	 |_| 26/10/2012               

	For all your colour changing needs.
	
//*/

include("holopad/gui/DColorPalette_Holopad.lua")

local PANEL = {}

function PANEL:Init()
	
	self.Paint = function() end
	
	self.wanging = false
	
	self.collabel = vgui.Create("DLabel", self)
	local collabel = self.collabel
	collabel:SetText("Colour:")
	collabel:SizeToContents()
	collabel:SetPos(5, 5)
	
	self.colprevpanel = vgui.Create("DPanel", self)
	local colprevpanel = self.colprevpanel
	colprevpanel.curcol = Color(234,234,234)
	colprevpanel:SetPos(130, 10 + collabel:GetTall())
	colprevpanel:SetSize(126, 126)
	colprevpanel:SetPos( 5, 10 + collabel:GetTall() )
	
	//*
	colprevpanel.Paint = 	function()
								//local xcp, ycp = self:LocalToScreen()
								local wcp, tcp = colprevpanel:GetSize()
								surface.SetDrawColor(colprevpanel.curCol or Color(234, 234, 234))
								//surface.DrawRect(xcp, ycp, wcp, tcp)
								surface.DrawRect(0, 0, wcp, tcp)
							end
	//*/
	
	self.colourCube = vgui.Create( "DColorPalette_Holopad", colprevpanel)
	local colourCube = self.colourCube
	colourCube:SetPos( 3, 3 )
	colourCube.OnColorChanged = function() self:OnCubeChanged1() end
	
	self.saveColourButton = vgui.Create("DButton", self)
	local saveColourButton = self.saveColourButton
	saveColourButton:SetText( "Save" )
	saveColourButton.DoClick = function() self.storedColour = colourCube:GetColor() end
	saveColourButton:SetSize(30, collabel:GetTall() + 2)
	saveColourButton:SetPos(10 + collabel:GetWide(), 5)
	
	self.loadColourButton = vgui.Create("DButton", self)
	local loadColourButton = self.loadColourButton
	loadColourButton:SetText( "Load" )
	loadColourButton.DoClick = function() self:SetColor(self.storedColour) end
	loadColourButton:SetSize(30, collabel:GetTall() + 2)
	loadColourButton:SetPos(45 + collabel:GetWide(), 5)
	
	local doWangChanged = function() self:OnWangChanged1() end
	
	self.wangR = vgui.Create("DNumberWang", self)
	local wangR = self.wangR
	wangR:SetValue(255)
	local oldendwangR, oldstartwangR = wangR.EndWang, wangR.StartWang
	wangR.EndWang	= function(self)	self.wanging = false		oldendwangR(self)	self.OnWangChanged()	end
	wangR.StartWang = function(self)	self.wanging = true		oldstartwangR(self)	end
	wangR.OnValueChanged = doWangChanged
	wangR:GetTextArea():SetEditable(true)	// TODO: make typable
	wangR:GetTextArea().OnEnter = doWangChanged
	wangR:SetMax(255)
	wangR:SetMin(0)
	wangR:SetDecimals(0)
	wangR:SetSize(50, 20)
	wangR:SetPos(136, 10 + collabel:GetTall())
	//wangR:SetDrawBackground(false)
	
	self.wangG = vgui.Create("DNumberWang", self)
	local wangG = self.wangG
	wangG:SetValue(0)
	local oldendwangG, oldstartwangG = wangG.EndWang, wangG.StartWang
	wangG.EndWang	= function(self)	self.wanging = false		oldendwangG(self)	self.OnWangChanged()	end
	wangG.StartWang = function(self)	self.wanging = true		oldstartwangG(self)	end
	wangG.OnValueChanged = doWangChanged
	wangG:GetTextArea():SetEditable(true)	// TODO: make typable
	wangG:GetTextArea().OnEnter = doWangChanged
	wangG:SetMax(255)
	wangG:SetMin(0)
	wangG:SetDecimals(0)
	wangG:SetSize(50, 20)
	wangG:SetPos(136, 10 + collabel:GetTall() + wangR:GetTall() + 6)
	//wangG:SetDrawBackground(false)
	
	self.wangB = vgui.Create("DNumberWang", self)
	local wangB = self.wangB
	wangB:SetValue(255)
	local oldendwangB, oldstartwangB = wangB.EndWang, wangB.StartWang
	wangB.EndWang	= function(self)	self.wanging = false		oldendwangB(self)	self.OnWangChanged()	end
	wangB.StartWang = function(self)	self.wanging = true		oldstartwangB(self)	end
	wangB.OnValueChanged = doWangChanged
	wangB:GetTextArea():SetEditable(true)	// TODO: make typable
	wangB:GetTextArea().OnEnter = doWangChanged
	wangB:SetMax(255)
	wangB:SetMin(0)
	wangB:SetDecimals(0)
	wangB:SetSize(50, 20)
	wangB:SetPos(136, 10 + collabel:GetTall() + wangR:GetTall()*2 + 12)
	//wangB:SetDrawBackground(false)
	
	self.wangA = vgui.Create("DNumberWang", self)
	local wangA = self.wangA
	wangA:SetValue(255)
	local oldendwangA, oldstartwangA = wangA.EndWang, wangA.StartWang
	wangA.EndWang	= function(self)	self.wanging = false		oldendwangA(self)	self.OnWangChanged()	end
	wangA.StartWang = function(self)	self.wanging = true		oldstartwangA(self)	end
	wangA.OnValueChanged = doWangChanged
	wangA:GetTextArea():SetEditable(false)	// TODO: make typable
	wangA:GetTextArea().OnEnter = doWangChanged
	wangA:SetMax(255)
	wangA:SetMin(0)
	wangA:SetDecimals(0)
	wangA:SetSize(50, 20)
	wangA:SetPos(136, 10 + collabel:GetTall() + wangR:GetTall()*3 + 18)
	//wangA:SetDrawBackground(false)
	
	colprevpanel.curCol = colourCube:GetColor()
	
	self:SetSize(186, 136 + collabel:GetTall())

end



function PANEL:OnCubeChanged()
end

function PANEL:OnCubeChanged1()
	local colour = self.colourCube:GetColor()
	if self.wanging then return end
	self.wangR:SetValue(colour.r)
	self.wangG:SetValue(colour.g)
	self.wangB:SetValue(colour.b)
	self.wangA:SetValue(colour.a)
	self.colprevpanel.curCol = colour
	self:OnCubeChanged()
end



function PANEL:OnWangChanged()
end

function PANEL:OnWangChanged1()
	if !(self.wangR and self.wangG and self.wangB and self.wangA) then return end
	local col = Color(self.wangR:GetValue(), self.wangG:GetValue(), self.wangB:GetValue(), self.wangA:GetValue())
	self.colourCube:SetColor(col)
	self.colprevpanel.curCol = col
	self:OnWangChanged()
end



function PANEL:SetColor(colour)
	if !colour then return end
	self.wangR:SetValue(colour.r)
	self.wangG:SetValue(colour.g)
	self.wangB:SetValue(colour.b)
	self.wangA:SetValue(colour.a)
	self.colourCube:SetColor(colour)
	self.colprevpanel.curCol = colour
end



function PANEL:GetColor()
	return self.colourCube:GetColor()
end



derma.DefineControl( "DColorPanel_Holopad", "", PANEL, "DPanel" )




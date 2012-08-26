/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | ScaleMode Context Control Derma
	splambob@gmail.com	 |_| 29/07/2012               

	Controls for Entity scale and scaling.
	
//*/


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 240
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "scale"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Scale", self:createControls(), "holopad/square_hollow", false, false, "Scale Holos" )
	
	self:SetTitle("Holopad 2; Scale Holos")
	local parent	 = self:GetParent()//:GetViewPanel():GetViewport()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	//self:SetPos(parx + pwidth + 1, pary)
	self:MoveRightOf(parent, 1)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	self.Close = function(self) self.Close2(self) oldclose(self) end
	
	
	local model	= self:GetParent():GetModelObj()
	self:SetModelObj(model)
	local selent = model:getSelectedEnts()
	local count	= #selent
	selent = selent[1]
	
	if count == 1 then	// make a fake update to send to itself
		update = {ent = selent, selected = true}
		self.receiveUpdate(update)
	end
	
end



function PANEL:Close2()
	hook.Remove(Holopad.MODEL_UPDATE .. tostring(self:GetParent():GetModelObj()), tostring(self))
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
	local wangX, wangY, wangZ, checkLocal	// TODO: checkLocal
	local MoveWangLabel, MoveManualButton
	local GridLabel, GridWang, GridButton
	local wanging = false
	
	
	local dholoWangMove = function(this)
	
		local model	= self:GetParent():GetModelObj()
		local selent = model:getSelectedEnts()
		local count	= #selent
		selent = selent[1]
		
		if count == 0 or count > 1 then return end // TODO: move multiple entities as group
		if !selent:instanceof(Holopad.DynamicEnt) then return end
		
		selent:setScale(Vector(wangX:GetValue(), wangY:GetValue(), wangZ:GetValue()))
		
	end
	
	
	local function dholoSetGrid()
		Holopad.ScaleSnap = GridWang:GetValue()
	end
	
	
	
	self.receiveUpdate = function(update)
	
		if !(update.scale or update.selected or update.deselected) then return end
		
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		local count	= #selent
		selent = selent[1]
		
		if count > 1 then return end // TODO: move multiple entities as group
		if update.ent != selent and !update.deselected then return end
		
		// TODO: deltas
		if count == 0 then
			MoveWangLabel:SetText("No holos selected!")
			MoveManualButton:SetText("Can't scale\nnothing!")
		else
			MoveWangLabel:SetText("Local Scale Coefficient (XYZ)")
			MoveManualButton:SetText("Set Scale")
		end
		
		if !(update.deselected or wanging) then
			local pos = selent:getScale()
			wangX:SetValue(pos.x)
			wangY:SetValue(pos.y)
			wangZ:SetValue(pos.z)
		end
		
	end
	
	
	
	local listOfCats = vgui.Create( "DPanelList", Edit )
	listOfCats:SetSpacing( 5 )
	listOfCats:EnableVerticalScrollbar( true )
	
	
	
	local category = vgui.Create("DCollapsibleCategory")
	category:SetSize( self.ContentX, self.ContentY )
	category:SetExpanded( 1 )
	category:SetLabel( "Scale Controls" )
	category.Header:SetMouseInputEnabled(false)
	
	local categoryList = vgui.Create( "DPanelList" )
	categoryList:SetAutoSize( true )
	categoryList:SetSpacing( 5 )
	categoryList:EnableHorizontal( false )
	categoryList:EnableVerticalScrollbar( true )
	
	category:SetContents(categoryList)
	
	
	
	local movepanel = vgui.Create("DPanel")
	movepanel.Paint = function() end
	
	local ypos = 5
	
	MoveWangLabel = vgui.Create("DLabel", movepanel)
	MoveWangLabel:SetColor(Color(255,255,255))
	MoveWangLabel:SetFont("default")
	MoveWangLabel:SetText("Local Scale Coefficient (XYZ)")
	MoveWangLabel:SetPos(5, ypos)
	MoveWangLabel:SizeToContents()
	
	ypos = ypos + MoveWangLabel:GetTall() + 5
	local butpos = ypos
	
	local xpanel = vgui.Create("DPanel", movepanel)
	xpanel.Paint = function() end
	xpanel:SetPos(5, ypos)
	
	local xlabel = vgui.Create("DLabel", xpanel)
	xlabel:SetText("X:")
	xlabel:SizeToContents()
	xlabel:SetPos(5, 5)
	
	wangX = vgui.Create("DNumberWang", xpanel)
	wangX:SetValue(1)
	local oldendwangx, oldstartwangx = wangX.EndWang, wangX.StartWang
	wangX.EndWang	= function(self)	wanging = false		oldendwangx(self)	end
	wangX.StartWang = function(self)	wanging = true		oldstartwangx(self)	end
	wangX:SetMax(MOVEMAX)
	wangX:SetMin(-MOVEMAX)
	wangX:SetPos(xlabel:GetWide() + 9, 2)
	wangX:SetDecimals(3)
	
	xpanel:SizeToContents()
	xpanel:SetWidth(wangX:GetWide() + xlabel:GetWide() + 10)
	
	
	ypos = ypos + xpanel:GetTall() + 5
	
	
	local ypanel = vgui.Create("DPanel", movepanel)
	ypanel.Paint = function() end
	ypanel:SetPos(5, ypos)
	
	local ylabel = vgui.Create("DLabel", ypanel)
	ylabel:SetText("Y:")
	ylabel:SizeToContents()
	ylabel:SetPos(5, 5)
	
	wangY = vgui.Create("DNumberWang", ypanel)
	wangY:SetValue(1)
	local oldendwangy, oldstartwangy = wangY.EndWang, wangY.StartWang
	wangY.EndWang	= function(self)	wanging = false		oldendwangy(self)	end
	wangY.StartWang = function(self)	wanging = true		oldstartwangy(self)	end
	wangY:SetMax(MOVEMAX)
	wangY:SetMin(-MOVEMAX)
	wangY:SetPos(ylabel:GetWide() + 9, 2)
	wangY:SetDecimals(3)
	
	ypanel:SizeToContents()
	ypanel:SetWidth(wangY:GetWide() + ylabel:GetWide() + 10)
	
	
	ypos = ypos + ypanel:GetTall() + 5
	
	
	local zpanel = vgui.Create("DPanel", movepanel)
	zpanel.Paint = function() end
	zpanel:SetPos(5, ypos)
	
	local zlabel = vgui.Create("DLabel", zpanel)
	zlabel:SetText("Z:")
	zlabel:SizeToContents()
	zlabel:SetPos(5, 5)
	
	wangZ = vgui.Create("DNumberWang", zpanel)
	wangZ:SetValue(1)
	local oldendwangz, oldstartwangz = wangZ.EndWang, wangZ.StartWang
	wangZ.EndWang	= function(self)	wanging = false		oldendwangz(self)	end
	wangZ.StartWang = function(self)	wanging = true		oldstartwangz(self)	end
	wangZ:SetMax(MOVEMAX)
	wangZ:SetMin(-MOVEMAX)
	wangZ:SetPos(zlabel:GetWide() + 9, 2)
	wangZ:SetDecimals(3)
	
	zpanel:SizeToContents()
	zpanel:SetWidth(wangZ:GetWide() + zlabel:GetWide() + 10)
	
	
	ypos = ypos + zpanel:GetTall()


	MoveManualButton = vgui.Create("DButton", movepanel)
	MoveManualButton:SetText( "Set Scale" )
	MoveManualButton.DoClick = dholoWangMove
	MoveManualButton:SetSize(170 - zpanel:GetWide(), ypos - butpos)
	MoveManualButton:SetPos(10 + zpanel:GetWide(), butpos)
	
	ypos = ypos + 5
	
	movepanel:SizeToContents()
	movepanel:SetTall(ypos)
	
	categoryList:AddItem(movepanel)
	category:SizeToContents()	
	
	listOfCats:AddItem(category)

	
	local category2 = vgui.Create("DCollapsibleCategory")
	category2:SetSize( self.ContentX, self.ContentY )
	category2:SetExpanded( 1 )
	category2:SetLabel( "Snap Controls" )
	category2.Header:SetMouseInputEnabled(false)
	
	local categoryList2 = vgui.Create( "DPanelList" )
	categoryList2:SetAutoSize( true )
	categoryList2:SetSpacing( 5 )
	categoryList2:EnableHorizontal( false )
	categoryList2:EnableVerticalScrollbar( true )
	
	category2:SetContents(categoryList2)
	//*
	local gridpanel = vgui.Create("DPanel")
	gridpanel.Paint = function() end
	
	ypos = 5
	
	GridLabel = vgui.Create("DLabel", gridpanel)
	GridLabel:SetColor(Color(255,255,255))
	GridLabel:SetFont("default")
	GridLabel:SetText("Scale Snap Multiplier")
	GridLabel:SetPos(5, ypos)
	GridLabel:SizeToContents()
	
	ypos = ypos + 5 + GridLabel:GetTall()
	
	GridWang = vgui.Create("DNumberWang", gridpanel)
	GridWang:SetValue(Holopad.ScaleSnap or 0.1)
	GridWang:SetMax(1)
	GridWang:SetMin(0.01)
	GridWang:SetDecimals(2)
	GridWang:SetPos(5, ypos)
	
	GridButton = vgui.Create("DButton", gridpanel)
	GridButton:SetText( "Set Scale Snap" )
	GridButton.DoClick = dholoSetGrid
	GridButton:SetSize(175 - GridWang:GetWide(), 20)
	GridButton:SetPos(10 + GridWang:GetWide(), ypos)
	
	ypos = ypos + 25
	
	gridpanel:SetHeight(ypos)
	
	categoryList2:AddItem(gridpanel)
	
	listOfCats:AddItem(category2)

	return listOfCats
	
end



derma.DefineControl( "DContextPanel_ScaleMode_Holopad", "Context controls for ScaleMode", PANEL, "DFrame" )



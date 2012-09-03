/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | MoveMode Context Control Derma
	splambob@gmail.com	 |_| 29/07/2012               

	Controls for Entity position and movement.
	
//*/


//include("holopad/gui/DHoloSelect_Holopad.lua")


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 200, 335
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "move"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Position", self:createControls(), "holopad/arrowup_solid", false, false, "Move Holos" )
	
	self:SetTitle("Holopad 2; Move Holos")
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
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
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
	local GridLabel, GridWang, GridButton, GridCenButton, GridWorldButton, GridLocalButton
	local CheckCentre, CheckOrient
	local wanging = false
	
	
	local dholoWangMove = function(this)
	
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		local count	= #selent
		selent = selent[1]
		
		if count == 0 or count > 1 then return end // TODO: move multiple entities as group
		if !selent:instanceof(Holopad.DynamicEnt) then return end
		
		selent:setPos(Vector(wangX:GetValue(), wangY:GetValue(), wangZ:GetValue()))
		
	end
	
	
	local function dholoSetGrid()
		local viewport = self:GetParent():GetViewPanel():GetViewport()
		viewport:SetGridSize(GridWang:GetValue())
	end
	
	
	local function dholoCentreGrid()
		local grid = self:GetParent():GetViewPanel():GetViewport():GetGrid()
		local sel	= self:GetModelObj():getSelectedEnts()
		
		if #sel != 1 then
			GridCenButton:SetText("Select one holo!")
			timer.Simple(3, GridCenButton.SetText, GridCenButton, "Centre Grid on Holo")
			return
		end
		sel = sel[1]
		
		grid:SetPos(sel:getPos())
	end
	
	
	local function dholoWorldGrid()
		local grid = self:GetParent():GetViewPanel():GetViewport():GetGrid()
		grid:SetPos(Vector(0,0,0))
		grid:SetAngles(Angle(0,0,0))
	end
	
	
	local function dholoLocalGrid()
		local grid	= self:GetParent():GetViewPanel():GetViewport():GetGrid()
		local sel	= self:GetModelObj():getSelectedEnts()
		
		if #sel != 1 then
			GridLocalButton:SetText("Select one holo!")
			timer.Simple(3, GridLocalButton.SetText, GridLocalButton, "Orient Grid to Holo")
			return
		end
		sel = sel[1]
		
		//grid:SetPos(sel:getPos())
		grid:SetAngles(sel:getAng())
	end
	
	
	
	self.receiveUpdate = function(update)
	
		if !(update.pos or update.selected or update.deselected) then return end
		
		local model		= self:GetModelObj()
		local selent	= model:getSelectedEnts()
		local count		= #selent
		selent = selent[1]
		
		if count > 1 then return end // TODO: move multiple entities as group
		if update.ent != selent and !update.deselected then return end
		
		
		if update.selected then
			if Holopad.GridAutoCenter == 1 then
				dholoCentreGrid()
			end
			if Holopad.GridAutoOrient == 1 then
				dholoLocalGrid()
			end
		end
		
		
		if update.deselected then
			/*if Holopad.GridAutoCenter == 1 then
				dholoCentreGrid()
			end*/
			if Holopad.GridAutoOrient == 1 then
				dholoWorldGrid()
			end
		end
		
		
		if count == 0 then
			MoveWangLabel:SetText("No holos selected!")
			MoveManualButton:SetText("Can't move\nnothing!")
		else
			MoveWangLabel:SetText("World Origin Offset (XYZ)")
			MoveManualButton:SetText("Set Origin\nOffset")
		end
		
		if !(update.deselected or wanging) then
			local pos = selent:getPos()
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
	category:SetLabel( "Position Controls" )
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
	MoveWangLabel:SetText("World Origin Offset (XYZ)")
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
	MoveManualButton:SetText( "Set Origin\nOffset" )
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
	category2:SetLabel( "Grid Controls" )
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
	GridLabel:SetText("Grid Separation (glu)")
	GridLabel:SetPos(5, ypos)
	GridLabel:SizeToContents()
	
	ypos = ypos + 5 + GridLabel:GetTall()
	
	GridWang = vgui.Create("DNumberWang", gridpanel)
	GridWang:SetValue(Holopad.GridSize or 12)
	GridWang:SetMax(Holopad.DEFAULT_GRIDSIZE*10)
	GridWang:SetMin(0.5)
	GridWang:SetDecimals(1)
	GridWang:SetPos(5, ypos)
	
	GridButton = vgui.Create("DButton", gridpanel)
	GridButton:SetText( "Set Grid Size" )
	GridButton.DoClick = dholoSetGrid
	GridButton:SetSize(175 - GridWang:GetWide(), 20)
	GridButton:SetPos(10 + GridWang:GetWide(), ypos)
	
	ypos = ypos + 25
	
	GridCenButton = vgui.Create("DButton", gridpanel)
	GridCenButton:SetText( "Centre Grid on Holo" )
	GridCenButton.DoClick = dholoCentreGrid
	GridCenButton:SetSize(180, 20)
	GridCenButton:SetPos(5, ypos)
	
	ypos = ypos + 25
	
	GridWorldButton = vgui.Create("DButton", gridpanel)
	GridWorldButton:SetText( "Orient Grid to World" )
	GridWorldButton.DoClick = dholoWorldGrid
	GridWorldButton:SetSize(180, 20)
	GridWorldButton:SetPos(5, ypos)
	
	ypos = ypos + 25
	
	GridLocalButton = vgui.Create("DButton", gridpanel)
	GridLocalButton:SetText( "Orient Grid to Holo" )
	GridLocalButton.DoClick = dholoLocalGrid
	GridLocalButton:SetSize(180, 20)
	GridLocalButton:SetPos(5, ypos)
	
	ypos = ypos + 25
	
	CheckCenter = vgui.Create( "DCheckBoxLabel", gridpanel )
	CheckCenter:SetPos( 5, ypos )
	CheckCenter:SetText( "Auto Center" )
	CheckCenter.OnChange = function(check) Holopad.GridAutoCenter = CheckCenter:GetChecked() and 1 or 0 end
	CheckCenter:SetValue( Holopad.GridAutoCenter or 1 )
	CheckCenter:SizeToContents()
	
	CheckOrient = vgui.Create( "DCheckBoxLabel", gridpanel )
	CheckOrient:SetPos( 95, ypos )
	CheckOrient:SetText( "Auto Orient" )
	CheckOrient.OnChange = function(check) Holopad.GridAutoOrient = CheckOrient:GetChecked() and 1 or 0 end
	CheckOrient:SetValue( Holopad.GridAutoOrient or 1 )
	CheckOrient:SizeToContents()
	
	ypos = ypos + 5 + CheckCenter:GetTall()
	
	gridpanel:SetHeight(ypos)
	
	categoryList2:AddItem(gridpanel)
	
	listOfCats:AddItem(category2)

	return listOfCats
	
end



derma.DefineControl( "DContextPanel_MoveMode_Holopad", "Context controls for MoveMode", PANEL, "DFrame" )



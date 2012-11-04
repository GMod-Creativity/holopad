/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | SelectMode Context Control Derma
	splambob@gmail.com	 |_| 29/07/2012               

	Controls for Entity properties and misc.
	
//*/


include("holopad/gui/DColorPanel_Holopad.lua")
include("holopad/gui/DEntityDialogue_Holopad.lua")


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 210, 640
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self.ControlType = "select"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.PropSheet = vgui.Create( "DPropertySheet", self )
	self.PropSheet:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.PropSheet:SetSize( self.ContentX, self.ContentY )
	self.PropSheet:AddSheet( "Properties", self:createControls(), "holopad/arrowup_solid", false, false, "Move Holos" )
	
	self:SetTitle("Holopad 2; Holo Properties")
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
	self:SetModelObj(model)	// just in case i guess
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
	hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.mdlobj), tostring(self))
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
	local colourCube, setColourButton
	local matEntry, setMatButton, matMenuButton, setMdlButton
	local nameEntry, setNameButton, addClipButton, cloneButton
	local RED, GREEN, BLUE, ALPHA = 1, 2, 3, 4
	
	
	local dholoSetColour = function(this)
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end // TODO: move multiple entities as group
		
		local col = colourCube:GetColor()
		for k, v in pairs(selent) do
			if v:instanceof(Holopad.DynamicEnt) then
				v:setColour(col)
			end
		end
	end
	
	
	local function dholoSetMaterial(this)
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end // TODO: move multiple entities as group
		
		local mat = matEntry:GetText()	// TODO: check for path validity, check entity type
		for k, v in pairs(selent) do
			if v:instanceof(Holopad.DynamicEnt) then
				v:setMaterial(mat)
			end
		end
	end
	
	
	local function dholoMatCallback(success, mat)
		if !(success or self.ModelObj) then return end
		if !mat then Error("Selected material is nil?!?!  Report this to Bubbus!") return end
		local sel = self:GetModelObj():getSelectedEnts()
		
		for i=1, #sel do
			sel[i]:setMaterial(mat)
		end
	end
	
	
	local function dholoMatMenu()
		if !self:GetModelObj() then Error("No ModelObj exists, cannot create selection list.") return end
		local menu = vgui.Create("DMatSelect_Holopad", self)
		//menu:SetModelObj(self:GetModelObj())
		menu:SetCallback(dholoMatCallback)
	end
	
	
	local function dholoSetModel2(status, path)
		if !status then return end
	
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		for k, v in pairs(selent) do
			if v:instanceof(Holopad.DynamicEnt) then
				v:setModel(path)
			end
		end
	end
	
	
	local function dholoValidateModel(path)
		if util.IsValidModel(path) then return false else return "Invalid model path!" end
	end
	
	
	local function dholoSetModel(this)
		local entry = vgui.Create("DTextDialogue_Holopad", self)
		entry:SetLabel("Enter a model path; (ex. \"" .. Holopad.ERROR_MODEL .. "\")")
		entry:SetCallback(dholoSetModel2)
		//entry:SetValidator(dholoValidateModel)
		// TODO: fix and re-add validator
		
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		if #selent != 0 then entry:SetText(selent[1]:getModel()) end
	end
	
	
	local function dholoSetName(this)
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		local mat = nameEntry:GetText()
		for k, v in pairs(selent) do
			if v:instanceof(Holopad.Entity) then
				v:setName(mat)
			end
		end
	end
	
	
	local function dholoAddClip(this)
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent != 1 then return end
		selent = selent[1]
		
		//for k, v in pairs(selent) do
			if selent:class() == Holopad.Hologram then
				local clip = Holopad.ClipPlane:New(selent, selent:getAng():Up(), nil)
				model:addEntity(clip)
				model:selectEnt(clip, true)
			end
		//end
	end
	
	
	local function dholoClone()
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		model:deselectAll()
		
		local clone
		for _, v in pairs(selent) do
			if v:instanceof(Holopad.DynamicEnt) then
				clone = v:cloneToModel(nil, model)
				model:selectEnt(clone)
			end
		end
	end
	
	
	
	local function dholoparent2(status, ent)
		if !status then return end
		
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		Msg("Parenting " .. #selent .. " ents to " .. ent:getName() .. "\n\n\n")
		for _, v in pairs(selent) do
			if v:class() != Holopad.ClipPlane and v:instanceof(Holopad.DynamicEnt) and v != ent then
				v:setParent(ent)
			end
		end
	end
	
	
	
	local function dholoparent()
		local menu = vgui.Create("DEntityDialogue_Holopad", self)
		menu:SetModelObj(self:GetModelObj())
		menu:SetCallback(dholoparent2)
	end
	
	
	
	local function dholodeparent()
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		for _, v in pairs(selent) do
			if v:class() != Holopad.ClipPlane and v:instanceof(Holopad.DynamicEnt) then
				v:deparent()
			end
		end
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
	
	
	colourCube = vgui.Create("DColorPanel_Holopad", apppanel)
	
	
	local ypos = colourCube:GetTall() + 5
	
	setColourButton = vgui.Create("DButton", apppanel)
	setColourButton:SetText( "Set Colour (RGBA)" )
	setColourButton.DoClick = dholoSetColour
	setColourButton:SetSize(180, 20)
	setColourButton:SetPos(5, ypos)
	
	ypos = ypos + 30	
	
	local matlabel = vgui.Create("DLabel", apppanel)
	matlabel:SetText("Material:")
	matlabel:SizeToContents()
	matlabel:SetPos(5, ypos)
	
	ypos = ypos + 5 + matlabel:GetTall()
	
	
	matMenuButton = vgui.Create( "DCentredImageButton", apppanel )
	matMenuButton:SetSize( 20, 20 )
	matMenuButton:SetText("")
	matMenuButton:SetImage("icon16/application_view_detail.png")
	matMenuButton:SetTooltip( "Find Material in List" )
	matMenuButton.OnMousePressed =	dholoMatMenu
	matMenuButton:SetDrawBorder( true )
    matMenuButton:SetDrawBackground( true )
	matMenuButton:SetPos(165, ypos)
	
	matEntry = vgui.Create("DTextEntry", apppanel)
	matEntry:SetWidth(155)
	matEntry:SetPos(5, ypos)
	
	ypos = ypos + 25
	
	setMatButton = vgui.Create("DButton", apppanel)
	setMatButton:SetText( "Set Material Path" )
	setMatButton.DoClick = dholoSetMaterial
	setMatButton:SetSize(180, 20)
	setMatButton:SetPos(5, ypos)
	
	ypos = ypos + 30
	
	local mdllabel = vgui.Create("DLabel", apppanel)
	mdllabel:SetText("Model:")
	mdllabel:SizeToContents()
	mdllabel:SetPos(5, ypos)
	
	ypos = ypos + 5 + mdllabel:GetTall()
	
	setMdlButton = vgui.Create("DButton", apppanel)
	setMdlButton:SetText( "Set Model" )
	setMdlButton.DoClick = dholoSetModel
	setMdlButton:SetSize(180, 20)
	setMdlButton:SetPos(5, ypos)
	
	ypos = ypos + 25
	
	apppanel:SetSize(230, ypos)
	categoryList:AddItem(apppanel)
	
	
	local updaters = {}
	updaters.selected 	= 	function(update)
								local upd2 =
								{
									ent 	 = update.ent,
									colour 	 = update.ent:getColour(),
									material = update.ent:getMaterial(),
									name	 = update.ent:getName()
								}
															
								updaters.colour(upd2)
								updaters.material(upd2)
								updaters.name(upd2)
							end
						
	updaters.name		=	function(update) 	nameEntry:SetText(update.name) end
	updaters.deselected	=	function()	end		
	updaters.colour 	= 	function(update)	colourCube:SetColor(update.colour)	end
	updaters.material	= 	function(update)	matEntry:SetText(update.material or "")	end
	
	self.receiveUpdate = function(update)
	
		local doUpdate = false
		for k, v in pairs(update) do
			if updaters[k] then
				doUpdate = true
				break
			end
		end
		
		if !doUpdate then return end
		
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		local count	= #selent
		selent = selent[1]
		
		if update.ent == selent then		
			for k, v in pairs(update) do
				if updaters[k] then
					updaters[k](update)
				end
			end
			
			colourCube:SetColor(selent:getColour())
			
			setColourButton:SetText("Set Colour (RGBA)")
			setMatButton:SetText("Set Material Path")
			setNameButton:SetText("Set Name")
			addClipButton:SetText("Add a New Clipping Plane")
			cloneButton:SetText("Clone Selected Holos")
		end
		
		// TODO: deltas
		if count == 0 then
			setColourButton:SetText("Can't colour nothing!")
			setMatButton:SetText("Can't material nothing!")
			setNameButton:SetText("Can't name nothing!")
			addClipButton:SetText("Can't add clips to nothing!")
			cloneButton:SetText("Can't clone nothing!")
		end
		
	end
	//hook.Add(Holopad.MODEL_UPDATE .. tostring(self:GetModelObj()), tostring(self), self.receiveUpdate)
	
	categoryList:AddItem(MoveManualButton)

	//category:SizeToContents()
	
	listOfCats:AddItem(category)
	
	local category2 = vgui.Create("DCollapsibleCategory")
	category2:SetSize( self.ContentX, self.ContentY )
	category2:SetExpanded( 1 )
	category2:SetLabel( "Interaction" )
	category2.Header:SetMouseInputEnabled(false)
	
	local categoryList2 = vgui.Create( "DPanelList" )
	categoryList2:SetAutoSize( true )
	categoryList2:SetSpacing( 5 )
	categoryList2:EnableHorizontal( false )
	categoryList2:EnableVerticalScrollbar( true )
	
	category2:SetContents(categoryList2)
	
	local intpanel = vgui.Create("DPanel")
	intpanel.Paint = function() end
	
	
	local namelabel = vgui.Create("DLabel", intpanel)
	namelabel:SetText("Name:")
	namelabel:SizeToContents()
	namelabel:SetPos(5, 5)
	
	local ypos2 = 10 + namelabel:GetTall()
	
	nameEntry = vgui.Create("DTextEntry", intpanel)
	nameEntry:SetWidth(180)
	nameEntry:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 25
	
	setNameButton = vgui.Create("DButton", intpanel)
	setNameButton:SetText( "Set Name" )
	setNameButton.DoClick = dholoSetName
	setNameButton:SetSize(180, 20)
	setNameButton:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 30
	
	local cliplabel = vgui.Create("DLabel", intpanel)
	cliplabel:SetText("Clipping Planes:")
	cliplabel:SizeToContents()
	cliplabel:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 5 + cliplabel:GetTall()
	
	addClipButton = vgui.Create("DButton", intpanel)
	addClipButton:SetText( "Add a New Clipping Plane" )
	addClipButton.DoClick = dholoAddClip
	addClipButton:SetSize(180, 20)
	addClipButton:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 30
	
	
	local clonelabel = vgui.Create("DLabel", intpanel)
	clonelabel:SetText("Duplication:")
	clonelabel:SizeToContents()
	clonelabel:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 5 + clonelabel:GetTall()
	
	cloneButton = vgui.Create("DButton", intpanel)
	cloneButton:SetText( "Clone Selected Holos" )
	cloneButton.DoClick = dholoClone
	cloneButton:SetSize(180, 20)
	cloneButton:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 30
	
	local parentlabel = vgui.Create("DLabel", intpanel)
	parentlabel:SetText("Parenting:")
	parentlabel:SizeToContents()
	parentlabel:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 5 + parentlabel:GetTall()
	
	parentButton = vgui.Create("DButton", intpanel)
	parentButton:SetText( "Parent by Name" )
	parentButton.DoClick = dholoparent
	parentButton:SetSize(180, 20)
	parentButton:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 25
	
	deparentButton = vgui.Create("DButton", intpanel)
	deparentButton:SetText( "Deparent Entity" )
	deparentButton.DoClick = dholodeparent
	deparentButton:SetSize(180, 20)
	deparentButton:SetPos(5, ypos2)
	
	ypos2 = ypos2 + 25
	
	intpanel:SetSize(230, ypos2)
	
	categoryList2:AddItem(intpanel)
	
	listOfCats:AddItem(category2)
	
	return listOfCats
	
end



derma.DefineControl( "DContextPanel_SelectMode_Holopad", "Context controls for SelectMode", PANEL, "DFrame" )



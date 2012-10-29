/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Holopad Derma
	splambob@gmail.com	 |_| 12/07/2012               

	It's Holopad!
	
//*/

include("holopad/gui/DBackground_Holopad.lua")
include("holopad/gui/DCentredImageButton.lua")
include("holopad/gui/DViewPanel_Holopad.lua")
include("holopad/gui/DFileDialogue_Holopad.lua")
include("holopad/gui/DE2ExportDialogue_Holopad.lua")
include("holopad/gui/DSaveOptionsDialogue_Holopad.lua")
include("holopad/gui/DCreateHoloMenu_Holopad.lua")
include("holopad/gui/DContextPanel_MoveMode_Holopad.lua")
include("holopad/gui/DContextPanel_RotateMode_Holopad.lua")
include("holopad/gui/DContextPanel_ScaleMode_Holopad.lua")
include("holopad/gui/DContextPanel_SelectMode_Holopad.lua")
include("holopad/gui/DContextPanel_CameraMode_Holopad.lua")
include("holopad/gui/DToolSelect_Holopad.lua")
include("holopad/gui/DMatSelect_Holopad.lua")
include("holopad/mouse/obj_Keyboard.lua")


local PANEL = {}



local function autosave(pad)
	if !pad or pad.closed or !pad.GetModelObj then timer.Remove(Holopad.AUTOSAVE_TIMER) return end
	
	local path = Holopad.AUTOSAVE_DIR .. "/autosave_timed_" .. Holopad.AutosaveCurrent .. ".txt"
	Msg("Holopad; Autosaving current project as " .. path .. "\n")
	Holopad.PRJ.Save( pad:GetModelObj(), path, true ) 
	Holopad.AutosaveCurrent = (Holopad.AutosaveCurrent % Holopad.AutosaveMax) + 1
end



function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 590, 50
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.LastButtonX = 0
	
	self.Background = vgui.Create( "DBackground_Holopad", self )
	self.Background:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.Background:SetSize( self.ContentX, self.ContentY )	
	
	self.ModelObj = Holopad.Model:New()
	
	local openedpath = nil

	local savebutton = self:addButton("holopad/save", 		"Save to Project File...",	function()
																		if self.fileDialogue then Error("A file dialogue is already open.  Please use it or close it ok thanks!") return end
																		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
																		self.fileDialogue:SetRootFolder("Holopad", true)
																		self.fileDialogue:SetTitle("Holopad 2; Save to PRJ")
																		self.fileDialogue:SetCallback(function(success, filepath) self.fileDialogue = nil if success then Holopad.PRJ.Save( self:GetModelObj(), filepath, true ) openedpath = filepath end end)
																	end)
																	
	local savemenubutton = vgui.Create( "DCentredImageButton", savebutton )
	savemenubutton:SetSize( 18, 18 )
	savemenubutton:SetText("")
	savemenubutton:SetImage("icon16/application_view_detail.png")
	savemenubutton:SetTooltip( "Set Save Options" )
	savemenubutton.OnMousePressed =	function()
										if !self.ModelObj then Error("No ModelObj exists, cannot create selection list.") return end
										local menu = vgui.Create("DSaveOptionsDialogue_Holopad", self)
									end
	savemenubutton:SetDrawBorder( true )
    savemenubutton:SetDrawBackground( true )
	savemenubutton:SetPos(savebutton:GetWide() - savemenubutton:GetWide(), 0)
	
																	
	local loadbutton = self:addButton("holopad/load", 		"Load a Project File...",
																	function()
																		if self.fileDialogue then Error("A dialogue is already open.  Please use it or close it ok thanks!") return end
																		self.fileDialogue = vgui.Create("DFileDialogue_Holopad", self)
																		self.fileDialogue:SetRootFolder("Holopad", true)
																		self.fileDialogue:SetLoading(true)
																		self.fileDialogue:SetTitle("Holopad 2; Load from PRJ")
																		self.fileDialogue:SetCallback(	function(success, filepath)
																											self.fileDialogue = nil
																											if success then
																												local newmdl = Holopad.PRJ.Load( filepath )
																												if newmdl then
																													self:SetModelObj(newmdl)
																													openedpath = filepath
																												end
																											end
																										end)
																	end)																	
	
	self:addButton("holopad/export", 	"Export to E2...", 			function()
																		if self.fileDialogue then Error("A dialogue is already open.  Please use it or close it ok thanks!") return end
																		self.fileDialogue = vgui.Create("DE2ExportDialogue_Holopad", self)
																		self.fileDialogue:SetRootFolder("Expression2")
																		self.fileDialogue:SetModelObj(self.ModelObj)
																		self.fileDialogue:SetCallback(function(success, path) self.fileDialogue = nil end)
																	end)
	self:placeSpacer()
	
	self:addButton("holopad/addholo", 	"Create Holos", 			function()
																		if self.holoMenu then self.holoMenu:Close() end
																		self.holoMenu = vgui.Create( "DCreateHoloMenu_Holopad", self )
																		self.holoMenu:SetCallback(function() self.holoMenu = nil end)
																	end)
	
	self:addButton("holopad/removeholo", "Delete Holos", 			function() for _, v in pairs(self.ModelObj:getSelectedEnts()) do self.ModelObj:removeEntity(v) end end)
	
	self:addButton("holopad/tools/tool", "Use a Tool", 				function()
																		if self.fileDialogue then Error("A dialogue is already open.  Please use it or close it ok thanks!") return end
																		self.fileDialogue = vgui.Create( "DToolSelect_Holopad", self )
																		self.fileDialogue:SetCallback(	function(success, gooey, tool)
																											self.fileDialogue = nil
																											if !success then return end
																											local vp = self:GetViewPanel() or Error("No ViewPanel?!?! TELL BUBBUS.")
																											tool:SetViewport(vp:GetViewport())
																											tool:SetGlassPane(vp:GetGlassPane())
																											tool:SetModelObj(self:GetModelObj())
																											tool:OnCreatedGUI(gooey)
																										end)
																	end)
	
	self:placeSpacer()
	self:addButton("holopad/camera", 	"Move Camera", 				function()
																		self.ViewPanel:GetMouseHandler():setActiveMode("camera")
																		if self.contextPanel then if self.contextPanel.ControlType != "camera" then self.contextPanel:Close() else return end end
																		self.contextPanel = vgui.Create( "DContextPanel_CameraMode_Holopad", self )
																		self.contextPanel:SetModelObj(self.ModelObj)
																	end)
	
	local sel = self:addButton("holopad/select", 	"Select Holos", function()
																		self.ViewPanel:GetMouseHandler():setActiveMode("select")
																		if self.contextPanel then if self.contextPanel.ControlType != "select" then self.contextPanel:Close() else return end end
																		self.contextPanel = vgui.Create( "DContextPanel_SelectMode_Holopad", self )
																		self.contextPanel:SetModelObj(self.ModelObj)
																	end)
	
	local function selholo(success, holo)
		if !(success and self.ModelObj) then return end
		if !holo then Error("Selected holo does not exist?!?!  Report this to Bubbus!") return end
		self.ModelObj:selectEnt(holo, true)
	end
	
	local selmenubutton = vgui.Create( "DCentredImageButton", sel )
	selmenubutton:SetSize( 18, 18 )
	selmenubutton:SetText("")
	selmenubutton:SetImage("icon16/application_view_detail.png")
	selmenubutton:SetTooltip( "Find Hologram in List" )
	selmenubutton.OnMousePressed =	function()
										if !self.ModelObj then Error("No ModelObj exists, cannot create selection list.") return end
										local menu = vgui.Create("DEntityDialogue_Holopad", self)
										menu:SetModelObj(self.ModelObj)
										menu:SetCallback(selholo)
									end
	selmenubutton:SetDrawBorder( true )
    selmenubutton:SetDrawBackground( true )
	selmenubutton:SetPos(sel:GetWide() - selmenubutton:GetWide(), 0)
	
	self:addButton("holopad/move", 		"Move Holos", 				function()
																		self.ViewPanel:GetMouseHandler():setActiveMode("move")
																		if self.contextPanel then if self.contextPanel.ControlType != "move" then self.contextPanel:Close() else return end end
																		self.contextPanel = vgui.Create( "DContextPanel_MoveMode_Holopad", self )
																		self.contextPanel:SetModelObj(self.ModelObj)
																	end)
																	
	self:addButton("holopad/rotate", 	"Rotate Holos", 			function()
																		self.ViewPanel:GetMouseHandler():setActiveMode("rotate")
																		if self.contextPanel then if self.contextPanel.ControlType != "rotate" then self.contextPanel:Close() else return end end
																		self.contextPanel = vgui.Create( "DContextPanel_RotateMode_Holopad", self )
																		self.contextPanel:SetModelObj(self.ModelObj)
																	end)
																	
	self:addButton("holopad/scale", 	"Scale Holos", 				function()
																		self.ViewPanel:GetMouseHandler():setActiveMode("scale")
																		if self.contextPanel then if self.contextPanel.ControlType != "scale" then self.contextPanel:Close() else return end end
																		self.contextPanel = vgui.Create( "DContextPanel_ScaleMode_Holopad", self )
																		self.contextPanel:SetModelObj(self.ModelObj)
																	end)
	
	self:resizeFrame()
	
	self:SetTitle("Holopad 2, update " .. Holopad.LAST_UPDATED .. ", '" .. Holopad.LODSA_HURRS[math.random(#Holopad.LODSA_HURRS)] .. "' edition")
	
	self.ViewPanel = vgui.Create("DViewPanel_Holopad", self)
	self.ViewPanel:SetWide(self.WindowX)
	self.ViewPanel:Center()
	self.ViewPanel:SetModelObj(self.ModelObj)
	
	self:SetPos(self.ViewPanel:GetPos())
	self:MoveAbove(self.ViewPanel, 1)
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
	self:SetFocusTopLevel(true)
	
	self.ViewPanel:GetMouseHandler():setActiveMode("select")
	//if self.contextPanel and self.contextPanel.ControlType != "select" then self.contextPanel:Close() end
	self.contextPanel = vgui.Create( "DContextPanel_SelectMode_Holopad", self )
	
	local last = Holopad.AUTOSAVE_DIR .. "/autosave_onclose.txt"
	local newmdl = Holopad.PRJ.Load(file.Exists(last, "DATA") and last or "Holopad/holopad.txt")
	self:SetModelObj(newmdl)
	
	local oldclose = self.Close
	
	self.Close =	function(self)
						self.closed = true
						if Holopad.AutosaveOnClose then
							Holopad.PRJ.Save( self:GetModelObj(), Holopad.AUTOSAVE_DIR .. "/autosave_onclose.txt", true )
						end
						oldclose(self)
					end
	
	timer.Create(Holopad.AUTOSAVE_TIMER, Holopad.AutosaveWait, 0, function() autosave(self) end)
	
	
	
	// CTRL+A : Select all
	Holopad.Keyboard.AddBind({key = KEY_A, ctrl = true},
		function()
			if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
			local mdl = self:GetModelObj()
			local dyns = mdl:getType(Holopad.Hologram)
			for i=1, #dyns do
				mdl:selectEnt(dyns[i])
			end
		end)

	// CTRL+S : Save (as)
	Holopad.Keyboard.AddBind({key = KEY_S, ctrl = true},
		function()
			if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
			if openedpath then
				Holopad.PRJ.Save( self:GetModelObj(), openedpath, true )
			else
				savebutton.OnMousePressed()
			end
		end)

	// CTRL+O: Load file
	Holopad.Keyboard.AddBind({key = KEY_O, ctrl = true},
		function()
			if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
			loadbutton.OnMousePressed()
		end)

	// CTRL+N: New file
	Holopad.Keyboard.AddBind({key = KEY_N, ctrl = true},
		function()
			if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
			Holopad.PRJ.Save( self:GetModelObj(), Holopad.AUTOSAVE_DIR .. "/autosave_onclose.txt", true )
			self:SetModelObj(Holopad.Model:New())
		end)
	
	// DEL : Delete selected
	Holopad.Keyboard.AddBind({key = KEY_DELETE},
		function()
			if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
			local mdl = self:GetModelObj()
			local sel = mdl:getSelectedEnts()
			for i=1, #sel do
				if mdl:contains(sel[i]) then mdl:removeEntity(sel[i]) end
			end
		end)
	
	
	local function dholoClone()
		if !(self:GetViewPanel() and self:GetViewPanel():IsActive()) then return end
		local model	= self:GetModelObj()
		local selent = model:getSelectedEnts()
		
		if #selent == 0 then return end
		
		model:deselectAll()
		
		local clone
		for _, v in pairs(selent) do
			//if v:class() != Holopad.ClipPlane and v:instanceof(Holopad.DynamicEnt) then
			if v:instanceof(Holopad.DynamicEnt) then
				print("calling ctm")
				clone = v:cloneToModel(nil, model)
				model:selectEnt(clone)
			end
		end
	end


	// CTRL+C : Clone selected
	Holopad.Keyboard.AddBind({key = KEY_C, ctrl = true}, dholoClone)
	
end



function PANEL:closingContext(context)
	self.contextPanel = nil
end



function PANEL:SetModelObj(model)
	self.ModelObj = model
	self.ViewPanel:SetModelObj(model)
	if self.contextPanel then self.contextPanel:SetModelObj(self.ModelObj) end
end



/**
	Updates the size-related fields based on the current buttons in this panel, and resizes it to encompass them.
	Only works if the only buttons in this panel were added using the addButton function.
 */
function PANEL:resizeFrame()
	self.ContentX = self.LastButtonX + 1
	self.WindowX = self.ContentX + self.PaddingX*2
	self.WindowY = self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	self:SetSize( self.WindowX, self.WindowY )
	self.Background:SetSize( self.ContentX, self.ContentY )
end



/**
	Creates a button for use with this panel, and places it on the panel.
	Args;
		pic	String
			texture path to use on the button. nominal size is 32x32
		tooltip	String
			what text should appear when the button is hovered over?
		func	Function
			what function should execute when the button is pressed?
	Return:	DCenteredImageButton
		the created button.
 */
function PANEL:addButton(pic, tooltip, func)

	local icon = vgui.Create( "DCentredImageButton", self.Background )
	icon:SetSize( 48, 48 )
	icon:SetText("")
	icon:SetImage(pic)
	icon:SetTooltip( tooltip )
	icon.OnMousePressed = func
	icon:SetDrawBorder( true )
    icon:SetDrawBackground( true )

	self:placeButton(icon)
	return icon
end



/**
	Places a button onto the panel, Sets position only.
	Args;
		button	DCenteredImageButton
			the button to place on the panel.
 */
function PANEL:placeButton(button)
	button:SetPos(1 + self.LastButtonX, 1)
	self.LastButtonX = self.LastButtonX + 49
end



/**
	Places a blank space onto the panel.
 */
function PANEL:placeSpacer()
	self.LastButtonX = self.LastButtonX + 25
end



/**
	Return: Holopad.Model
		the Model in use by this Holopad instance.
 */
function PANEL:getModel()
	return self.ModelObj
end
function PANEL:GetModelObj()
	return self.ModelObj
end



function PANEL:GetViewPanel()
	return self.ViewPanel
end

derma.DefineControl( "DHolopad", "Root frame for Holopad", PANEL, "DFrame" )



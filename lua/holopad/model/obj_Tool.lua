/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Tool object
	splambob@gmail.com	 |_| 09/09/2012               

	The base Tool class.
	
//*/


Holopad.Tool, Holopad.ToolMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.Tool, Holopad.ToolMeta

Holopad.Tools = Holopad.Tools or {}

this.icon = "holopad/tools/tool"
this.name = "Generic Tool"
this.author = "Bubbus"
this.gui = "DTool_Holopad"
this.isTool = true


/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = 
	{
		// this is a dictionary, not an array!
		utils = {},	
		
		// resources for use in the tool (from the active scene)
		modelObj, viewport, glasspane	
	}
	
	setmetatable(new, meta)
	// copy this line into your subclass - sorry :(
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	
	return new

end



/**
	Function for receiving model updates.  There is no default functionality.
 */
function this:modelUpdateListener(update)
end



/**
	Set the Model in use by this Tool.
	Args;
		model	Holopad.Model
			the model to be used.
 */
function this:SetModelObj(mdl)
	if self.modelObj then
		self.modelObj:endTool()
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.modelObj), tostring(self.modelUpdateListener))
	end
	self.modelObj = mdl
	self.modelObj:startTool(self)
	hook.Add(Holopad.MODEL_UPDATE .. tostring(self.modelObj), tostring(self.modelUpdateListener), self.modelUpdateListener)
end

function this:GetModelObj()
	return self.modelObj
end



/**
	Set the Tool's viewport
	Args;
		view	DViewport_Holopad
			the viewport to use
 */
function this:SetViewport(view)
	self.viewport = view
end

function this:GetViewport()
	return self.viewport
end



/**
	Set the Tool's glasspane
	Args;
		pane	DGlassPane_Holopad
			the glasspane to use
 */
function this:SetGlassPane(pane)
	self.glasspane = pane
end

function this:GetGlassPane()
	return self.glasspane
end



/**
	Adds a Utility to the Tool.
	Args;
		util	Holopad.Utility
			the Utility to add
 */
function this:AddUtility(util)
	self.utils[util] = true
	if self.modelObj then self.modelObj:addEntity(util) end
	return true
end



/**
	Removes a Utility from the Tool.
	Args;
		util	Holopad.Utility
			the Utility to remove
		frommodel	Boolean
			if true, do not try to remove the utility from the model too.
 */
function this:RemoveUtility(util, frommodel)
	if !self.utils[util] then ErrorNoHalt("WARNING: Tried removing a Utility from a Tool which does not own it!  Continuing...") return true end
	self.utils[util] = nil
	if !frommodel and self.modelObj then self.modelObj:removeEntity(util) end
	return true
end



/**
	Return: Boolean
		true if this Tool has the Utility else false
 */
function this:HasUtility(util)
	return self.utils[util] or false
end



/**
	Returns a list of all Utilities assigned to this Tool, or the internal Utility map
	Args;
		returnref	Boolean
			true to return internal util map, else return copied list
	Return:	Table
		table of Utilities assigned to this Tool
 */
function this:GetUtilities(returnref)
	if returnref then return self.utils end
	
	local ret = {}
	for v, _ in pairs(self.utils) do
		ret[#ret+1] = v
	end
	return ret
end



/**
	Applies the effects of the Tool, where applicable.
 */
function this:Apply()
end



/**
	Exit the Tool safely.
	After this function is called, the tool should have been deactivated in a safe manner and the model should no longer be running the tool.
 */
function this:Quit()
	if self.modelObj then
		self.modelObj:endTool()
	end
end



/**
	If the GUI for this Tool is created, this function should then be invoked to properly configure the GUI and bind the Tool to it.
	Args;
		gooey	DFrame
			the Tool's GUI
 */
function this:OnCreatedGUI(gooey)
	if !gooey then Error("Tool was passed a nil GUI") return end
	gooey:SetTool(self)
end




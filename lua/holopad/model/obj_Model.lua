/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Model object
	splambob@gmail.com	 |_| 10/07/2012               

	Representation of a scene, containing Entities.
	
//*/


// should load all supers
include("holopad/model/obj_ClipPlane.lua")
include("holopad/model/obj_Utility.lua")

Holopad.Model, Holopad.ModelMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.Model, Holopad.ModelMeta


/**
	Constructor for the Holopad Model "object".
	Return:	Table (instance of Hologram.Model)
 */
function this:New()

	local new = 
	{
		entities  = {},
		Selected  = {},
		tool = nil
	}
	
	setmetatable(new, meta)
	new:setupParentUpdates()
	
	return new

end



/**
	Creates the entity-modification callbacks for this Model.
	Required because hook library doesn't support OOP (afaik)
 */
function this:setupParentUpdates()
	
	self.recieveUpdate = function(ent, update)
		if !update.ent then update.ent = ent end
		hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
	end

end



/**
	Add a Holopad.Entity to the Model.
	Args;
		ent	Table (inherits Holopad.Entity)
			entity to add
 */
function this:addEntity(ent)
	if !ent:instanceof(Holopad.Entity) then Error("Attempted to add a non-Entity to the Model!") return end
	if table.HasValue(self.entities, ent) then Error("Attempted to add an Entity to the Model twice!") return end
	self.entities[#self.entities+1] = ent
	
	hook.Add(Holopad.ENT_UPDATEHOOK	.. tostring(ent), tostring(self), self.recieveUpdate)
	
	local update = {
		ent = ent,
		added = true
	}
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
end



/**
	Remove a Holopad.Entity from the Model.
	Args;
		ent	Table (inherits Holopad.Entity)
			entity to remove
		force	Boolean
			for if you reealllyyy want to remove the ent.
 */
function this:removeEntity(ent, force)

	if !ent:instanceof(Holopad.Entity) then Error("Attempted to remove a non-Entity from the Model!") return end
	if !table.HasValue(self.entities, ent) then Error("Attempted to remove a non-member from the Model!") return end
	if !force and self.tool and ent:instanceof(Holopad.Utility) then Error("Cannot remove Utilities without breaking the active Tool!") return end

	local kent = table.KeyFromValue(self.entities, ent)
	local kids = ent:getChildren()
	local parent = ent:getParent()
	
	for _, v in pairs(kids) do
		self:removeEntity(v)
	end
	
	self:deselectEnt(ent)
	ent:deparent()
	ent:deparentAllChildren()
	
	hook.Remove(Holopad.ENT_UPDATEHOOK	.. tostring(ent), tostring(self))
				
	local update = {
		ent = ent,
		removed = true,
		parentbefore = parent
	}
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
	
	self.entities[kent] = nil

end



/**
	Return a list of all added Entities (contiguity not guaranteed if returning reference)
	Args;
		returnref Boolean
			return a reference of the entity table iff true, else a copy
	Return: Table
		list of all added Entities (contiguity not guaranteed if returning reference)
 */
// TODO: optimize; find places where returnref can be used
function this:getAll(returnref)
	if returnref then return self.entities end

	local ret = {}
	
	for _, v in pairs(self.entities) do
		ret[#ret+1] = v
	end
	
	return ret
end



/**
	Return a contiguous list of all instances of the passed class, optionally subclasses too.
	Args;
		class	Table
			class to search for
		inherits Boolean
			should subclasses of class be included?
	Return:	Table
		contiguous array of results
 */
function this:getType(class, inherits)
	local ret = {}
	
	if inherits then
		for k, v in pairs(self.entities) do
			if v:instanceof(class) then
				ret[#ret+1] = v
			end
		end
		
		return ret
	else	
		for k, v in pairs(self.entities) do
			if v:class() == class then
				ret[#ret+1] = v
			end
		end
		
		return ret
	end
end



/**
	Select an Entity
	Args;
		ent	Table (instance of Holopad.Entity)
			the Entity to select
		replace	Boolean
			false/nil for additive selection, true to replace entire selection
 */
function this:selectEnt(ent, replace)
	if !table.HasValue(self.entities, ent) then Error("Tried to select an Entity not contained in the Model!") return end
	
	if replace then 
		self:deselectAll()
		self.Selected = {ent} 
	elseif !table.HasValue(self.Selected, ent) then
		self.Selected[#self.Selected+1] = ent
	end
	
	local update = {
		ent = ent,
		selected = true
	}
	
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
end



/**
	Deselect an Entity
	Args;
		ent	Table (instance of Holopad.Entity)
			the Entity to deselect
 */
function this:deselectEnt(ent)	
	local idx = table.KeyFromValue(self.Selected, ent)
	if !idx then return end
	self.Selected[idx] = nil
	
	local update = {
		ent = ent,
		deselected = true
	}
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
end



/**
	Deselect all Entities
 */
function this:deselectAll()
	local oldselected = self.Selected
	self.Selected = {}
	
	local update
	for _, v in pairs(oldselected) do
		update = {
			ent = v,
			deselected = true
		}
		hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
	end
end



/**
	Returns an array of selected entities (not guaranteed to be contiguous if returnref)
	Args;
		returnref	Boolean
			true to return reference to selection table else return a copy.
	Return: Table
		array of selected ents.
 */
function this:getSelectedEnts(returnref)
	if returnref then return self.Selected end
	
	local ret = {}
	
	for k, v in pairs(self.Selected) do
		ret[#ret+1] = v
	end
	
	return ret
end



/**
	Is the passed ent selected?
	Args;
		ent	Table (instance of Holopad.Entity)
			the Entity to test
	Return: Boolean
		true iff ent is selected
 */
function this:isEntSelected(ent)
	return table.HasValue(self.Selected, ent)
end



/**
	Clear the current selection, add the tool's utilities then select them.
	Args;
		tool	Holopad.Tool
			the Tool to add to the model
 */
function this:startTool(tool)
	if self.tool then Error("A tool is already in use within this Model.  Finish using that tool before starting a new one.") return end
	self:deselectAll()

	for k, v in pairs(tool:GetUtilities()) do
		//if !v:instanceof(Holopad.Utility) then Error("Tried to pass a non-Utility to a Model as a Utility!") return end
		self:addEntity(v)
	end

	local update = {
		tool = tool
	}
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
end



/**
	If a Utility is active in this Model, end it
 */
function this:endTool()
	if !self.tool then Error("Tried to end a Tool, but no Tool is currently in use!") return end
	
	for k, v in pairs(tool:GetUtilities()) do
		self:removeEntity(v)
	end

	local update = {
		tool = false
	}
	hook.Call(Holopad.MODEL_UPDATE .. tostring(self), nil, update)
end



/**
	Return: Holopad.Tool
		the tool currently in use by this Model, or nil if no Tool is in use
 */
function this:getTool()
	return self.tool
end

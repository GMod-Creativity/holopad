/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | DynamicEnt object
	splambob@gmail.com	 |_| 09/07/2012               

	Dynamic model object with material, colour and post-creation modification facilities
	Inherits from Holopad.StaticEnt
	
//*/

include("holopad/model/obj_StaticEnt.lua")

Holopad.DynamicEnt, Holopad.DynamicEntMeta = Holopad.inheritsFrom(Holopad.StaticEnt)
local this, meta = Holopad.DynamicEnt, Holopad.DynamicEntMeta


/**
	Constructor for the Holopad DynamicEnt "object".  Undefined paramaters assume default values.
	Args;
		pos	Vector
			Position of the entity
		ang	Angle
			Angles of the entity
		name	String
			Name of the entity
		model	String
			Path-name of the model
		colour	Color
			Colour of the model
		material	String
			Material override for the model
	Return:	Table (inherits Holopad.StaticEnt)
 */
function this:New(pos, ang, name, model, colour, material)

	local new = this:super():New(pos, ang, name, model, colour, material)
	
	setmetatable(new, meta)
	
	new.children = {}
	new:setupParentUpdates()
	
	return new

end



/**
	Sets the position of the dynamic ent to the parameter by reference
	Invokes movement callback for children
	Args;
		pos	Vector
			position vector to assign to this ent
 */
function this:setPos(pos)
	if pos then
		local delta = pos - self.pos
		self.pos = pos
		//hook.Call(Holopad.ENT_MOVEHOOK .. tostring(self), nil, self, delta)
		hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, pos = self.pos, posdelta = delta})
	end
end



/**
	Sets the angles of the dynamic ent to the parameter by reference
	Invokes rotation callback for children
	Args;
		ang	Angle
			angles to assign to this ent
 */
function this:setAng(ang)
	if ang then
		local before = self.ang
		self.ang = ang
		//hook.Call(Holopad.ENT_ROTATEHOOK .. tostring(self), nil, self, before)
		hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, ang = self.ang, angbefore = before})
	end
end



/**
	Sets the model of the dynamic ent to the parameter
	Args;
		model	String
			model path to assign to this ent
 */
function this:setModel(model)
	self.model = model or Holopad.ERROR_MODEL
	hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, model = self.model})
end



/**
	Sets the colour of the dynamic ent to the parameter by reference
	Args;
		colour Color
			colour to assign to this ent
 */
function this:setColour(colour)
	self.colour = colour or Holopad.COLOUR_DEFAULT()
	hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, colour = self.colour})
end



/**
	Sets the material override of the dynamic ent to the parameter
	Args;
		material	String
			material override to assign to this ent
 */
function this:setMaterial(material)
	self.material = material
	hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, material = self.material})
end



/**
	If this ent has a parent this function removes the relationship, including callbacks.
 */
function this:deparent()

	if !self.parent then return false end
	
	local parent = self.parent
	if !parent:deparentingChild(self) then
		ErrorNoHalt("WARNING: Tried to deparent " .. self .. " from " .. ent .. " but " .. ent .. "rejected the attempt!")
		return false
	end
	
	hook.Remove(Holopad.ENT_UPDATEHOOK .. tostring(parent), tostring(self))
	self.parent = nil
	hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, parent = nil})
	
	return true

end



/**
	internal - do not call
 */
function this:deparentingChild(kid)
	self.children[kid] = nil
	return true
end



/**
	If this ent has any children, this causes them to remove this relationship
 */
function this:deparentAllChildren()
	for v, _ in pairs(self.children) do
		v:deparent()
	end
	//hook.Call(Holopad.ENT_DEPARENTALLHOOK .. tostring(self), nil, self)
end



/**
	Sets the parent of the dynamic ent to the parameter IFF paremeter inherits from Holopad.Entity
	Args;
		ent	Table (inherits Holopad.Entity)
			desired parent of the dynamic ent
	Return:	Boolean
		success of the setParent operation
 */
function this:setParent(ent)

	if !(ent and ent:instanceof(Holopad.DynamicEnt)) then return false end
	if self == ent then Error("Can't parent to self!") return false end
	if self:hasChild(ent, true) then Error("Parent loop detected - cannot parent!") return false end
	
	if !ent:parentingChild(self) then
		ErrorNoHalt("WARNING: Tried to parent " .. self .. " to " .. ent .. " but " .. ent .. "rejected the attempt!")
		return false
	end
	
	self:deparent()
	self.parent = ent

	hook.Add(Holopad.ENT_UPDATEHOOK .. tostring(ent),	tostring(self), self.parentUpdate)
	
	return true
end



/**
	internal - do not call
 */
function this:parentingChild(kid)
	self.children[kid] = true
	return true
end



/**
	Return true iff kid is a child of self, or extended descendant of self if recursive is true
	Args;
		kid	Holopad.DynamicEnt
			the ent to test for
		recursive
			if false, only check self's children.  else check self, self's children, grandchildren ad infinitum.
	Return: Boolean
		false iff kid is not descended from self
 */
function this:hasChild(kid, recursive)
	for v, _ in pairs(self.children) do
		if v == kid then return true end
		if recursive then return v:hasChild(kid, recursive) end
	end
	return false
end



/**
	Returns the parent of this dynamic ent, or nil if no parent exists.
	Return:	Table (inherits Holopad.Entity) or nil
		parent of the dynamic ent
 */
function this:getParent()
	return self.parent
end



/**
	Return: Table
		a list of self's children.
 */
function this:getChildren()
	local ret = {}
	for v, _ in pairs(self.children) do
		ret[#ret+1] = v
	end
	return ret
end



/**
	Creates the parent-modification callbacks for this ent.
	Required because hook library doesn't support OOP (afaik)
 */
function this:setupParentUpdates()
	// TODO: convert to function table
	self.parentUpdate = function(ent, update)
		if update.pos then
			self:setPos(self.pos + update.posdelta)
			return
		end
		
		if update.ang then
			local entpos = ent:getPos()
			local localVec, localAng	= WorldToLocal(self.pos, self.ang, entpos, update.angbefore)
			local newVec, newAng		= LocalToWorld(localVec, localAng, entpos, update.ang)
			self:setPos(newVec)
			self:setAng(newAng)
			return
		end
		
		if update.scale then
			local entang, entpos = ent:getAng(), ent:getPos()
			local localpos, lang = WorldToLocal(self.pos, self.ang, entpos, entang)
			
			//TODO: Y U NO WORK?
			//localpos = (localpos / update.scalebefore) * update.scale
			local lp, sb, sa = localpos, update.scalebefore, update.scale
			localpos = Vector((lp.x / sb.x) * sa.x, (lp.y / sb.y) * sa.y, (lp.z / sb.z) * sa.z)
			
			self:setPos(LocalToWorld(localpos, self.ang, entpos, entang))
		end
	end
	
	/*
	self.parentDeparentAll = function(ent, parent)
		self:deparent()
	end
	//*/

end



/**
	Clone the DynamicEnt.
	Args;
		parentoverride	Holopad.Entity
			parent to this ent if not nil.
		nokids	Boolean
			should we omit children in the clone process?
	Return: Holopad.DynamicEnt
		a copy of this Entity
 */
function this:clone(parentoverride, nokids)
	local clone = this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial())
	clone:setParent(parentoverride or self:getParent())
	
	if !nokids then
		local kids  = self:getChildren()		
		for _, v in pairs(kids) do
			v:clone(clone)
		end
	end
	
	return clone
end



/**
	Clone the DynamicEnt into the provided Model.
	Args;
		parentoverride	Holopad.Entity
			parent to this ent if not nil.
		model	Holopad.Model
			the model to clone into.
		nokids	Boolean
			should we omit children in the clone process?
	Return: Holopad.DynamicEnt
		a copy of this Entity
 */
function this:cloneToModel(parentoverride, model, nokids)
	local clone = this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial())
	clone:setParent(parentoverride or self:getParent())
	model:addEntity(clone)
	
	if !nokids then
		local kids  = self:getChildren()		
		for _, v in pairs(kids) do
			v:cloneToModel(clone, model)
		end
	end
	
	return clone
end



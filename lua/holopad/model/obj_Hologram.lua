/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Hologram object
	splambob@gmail.com	 |_| 10/07/2012               

	Hologram representation, with most common features.
	Inherits from Holopad.DynamicEnt
	
//*/


include("holopad/model/obj_DynamicEnt.lua")

Holopad.Hologram, Holopad.HologramMeta = Holopad.inheritsFrom(Holopad.DynamicEnt)
local this, meta = Holopad.Hologram, Holopad.HologramMeta


/**
	Constructor for the Holopad Hologram "object".  Undefined paramaters assume default values.
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
		scale	Vector
			Scale of the hologram (model-relative)
	Return:	Table (inherits Holopad.DynamicEnt)
 */
function this:New(pos, ang, name, model, colour, material, scale)

	local new = this:super():New(pos, ang, name, model, colour, material)
	
	setmetatable(new, meta)
	
	new:setupParentUpdates()
	new.scale = scale or Vector(1, 1, 1)
	new.exportable = true
	
	return new

end



/**
	Return the scale of the hologram
	Args;
		returnref	Boolean
			true for scale vector by reference else copy of vector
	Return:	Vector
 */
function this:getScale(returnref)
	return returnref and self.scale or Vector(self.scale.x, self.scale.y, self.scale.z)
end



/**
	Set the scale of the hologram to the parameter, by reference.
	Args;
		scale	Vector
			desired scale of the hologram
 */
function this:setScale(scale)
	local lastscale = self.scale
	if scale then
		self.scale = scale
	else
		self.scale = Vector(1, 1, 1)
	end
	hook.Call(Holopad.ENT_UPDATEHOOK .. tostring(self), nil, self, {ent = self, scale = self.scale, scalebefore = lastscale})
end



/**
	Clone the Hologram.
	Args;
		parentoverride	Holopad.Entity
			parent to this ent if not nil.
		nokids	Boolean
			should we omit children in the clone process?
		noclips	Boolean
			should we omit clips in the clone process?
	Return: Holopad.DynamicEnt
		a copy of this Entity
 */
function this:clone(parentoverride, nokids, noclips)
	local clone = this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial(), self:getScale())
	clone:setParent(parentoverride or self:getParent())
	
	local kids  = self:getChildren(true)
	
	if noclips and nokids then return clone end
	
	if nokids then
		for _, v in pairs(kids) do
			if v:class() == Holopad.ClipPlane then
				v:clone(clone, true)
			end
		end
	elseif noclips then
		for _, v in pairs(kids) do
			if v:class() != Holopad.ClipPlane then
				v:clone(clone, nil, true)
			end
		end
	end
	
	return clone
end



/**
	Clone the Hologram into the provided Model.
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
function this:cloneToModel(parentoverride, model, nokids, noclips)
	print("holo ctm")
	local clone = this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial(), self:getScale())
	clone:setParent(parentoverride or self:getParent())
	model:addEntity(clone)
	
	if noclips and nokids then return clone end
	
	local kids  = self:getChildren(true)
	
	if !(noclips and nokids) then
		for _, v in pairs(kids) do
			v:cloneToModel(clone, model, true)
		end
	elseif nokids then
		for _, v in pairs(kids) do
			if v:class() == Holopad.ClipPlane then
				v:cloneToModel(clone, model, true)
			end
		end
	elseif noclips then
		for _, v in pairs(kids) do
			if v:class() != Holopad.ClipPlane then
				v:cloneToModel(clone, model, nil, true)
			end
		end
	end
	
	return clone
end



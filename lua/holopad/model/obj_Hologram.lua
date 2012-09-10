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
	Creates the parent-modification callbacks for this ent.
	Required because hook library doesn't support OOP (afaik)
 */
function this:setupParentUpdates()
	this:super().setupParentUpdates(self)
	
	/*
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
			// TODO: verify this
			local entang, entpos = ent:getAng(), ent:getPos()
			local localpos, lang = WorldToLocal(self.pos, self.ang, entpos, entang)
			local scaledelta = update.scale - update.scalebefore
			local div = Vector(scaledelta.x/update.scale.x, scaledelta.y/update.scale.y, scaledelta.z/update.scale.z) // WTF?
			localpos = localpos + localpos * div
			self:setPos(LocalToWorld(localpos, self.ang, entpos, entang))
			// TODO: this is not perfect.  keep it?
			if Holopad.ScaleParentedHolos then
				local scale = self:getScale()
				self:setScale(scale + scale * div)
			end
		end
	end
	//*/
end



/**
	Return: Holopad.Entity
		a copy of this Entity
 */
function this:clone(parentoverride)
	local clone = this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial(), self:getScale())
	
	if parentoverride then
		clone:setParent(parentoverride)
	else
		clone:setParent(self:getParent())
	end
	
	local kids  = self:getChildren(true)
	
	for _, v in pairs(kids) do
		v:clone(clone)
	end
	
	return clone
end



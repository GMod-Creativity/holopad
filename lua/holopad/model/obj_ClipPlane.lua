/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | ClipPlane object
	splambob@gmail.com	 |_| 10/07/2012               

	Clipping plane representation.
	Inherits from Holopad.Hologram
	
//*/


include("holopad/model/obj_Hologram.lua")

Holopad.ClipPlane, Holopad.ClipPlaneMeta = Holopad.inheritsFrom(Holopad.Hologram)
local this, meta = Holopad.ClipPlane, Holopad.ClipPlaneMeta


/**
	Constructor for the Holopad Hologram "object".  Undefined paramaters assume default values.
	Places the ClipPlane at holo's center, aligns it to normal, scales it proportional to holo and associates it with holo.
	Args;
		holo	Table (instance of Holopad.Hologram)
			Hologram that this ClipPlane affects
		normal	Vector
			Clipping plane normal vector
		name	String
			Name of the entity
	Return:	Table (inherits Holopad.Hologram)
 */
function this:New(holo, normal, name)
	
	if !holo or holo:class() ~= Holopad.Hologram then Error("Tried to instantiate a ClipPlane with a non-Hologram object;", holo, "\n") return nil end
	
	normal	= normal or holo:getAng():Up()
	local scale = holo:getScale()
	local max = math.max(scale.x, scale.y, scale.z) * 1.2
	scale = Vector(max, max, max)
	local new = this:super():New(holo:getPos(), normal:Angle(), name or "", Holopad.CLIP_MODEL, Holopad.COLOUR_DEFAULT(), Holopad.CLIP_MATERIAL, scale)
	
	new:setParent(holo)
	
	setmetatable(new, meta)
	
	return new

end




function this:New2(pos, ang, name, model, colour, material, scale, parent)

	local new = this:super():New(pos, ang, name, Holopad.CLIP_MODEL, Holopad.COLOUR_DEFAULT(), Holopad.CLIP_MATERIAL, scale)
	
	if parent then new:setParent(parent) end
	
	setmetatable(new, meta)
	
	return new
	
end



/**
	ClipPlanes should not be parented to anything other than their associated Hologram.
	Return: Boolean (false)
 */
function this:setParent(ent)
	ErrorNoHalt("WARNING: Parenting ClipPlane to a new Hologram;", self, "(if you did NOT just spawn or load a ClipPlane, this is an ERROR!)\n")
	this:super().setParent(self, ent)
end



/**
	ClipPlanes should not deparented from their associated Hologram.
	Return: Boolean (false)
 */
function this:deparent()
	if !self:getParent() then return end
	ErrorNoHalt("WARNING: Deparenting ClipPlane from Hologram;", self, "(if you did NOT just delete a ClipPlane, this is an ERROR!)\n")
	this:super().deparent(self)
end
 

/**
	Return: Vector
		the clip plane normal vector associated with this ClipPlane
 */
function this:getNormal()
	return self:getAng():Up()
end



/**
	Return: Holopad.Entity
		a copy of this Entity
 */
function this:clone(parentoverride)
	local clone = this:New(parentoverride or self:getParent(), self:getNormal(), self:getName())
	clone:setPos(self:getPos())
	clone:setAng(self:getAng())
	clone:setScale(self:getScale())
	
	//(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial(), self:getScale())
	
	/* clip planes shouldn't have kids
	local kids  = self:getChildren(true)
	
	for _, v in pairs(kids) do
		v:clone(clone)
	end
	//*/
	
	return clone
end



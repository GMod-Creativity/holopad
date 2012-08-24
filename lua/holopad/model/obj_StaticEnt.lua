/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | StaticEnt object
	splambob@gmail.com	 |_| 09/07/2012               

	Static model object with material and colour facilities
	Inherits from Holopad.Entity
	
//*/

include("holopad/model/obj_Entity.lua")

Holopad.StaticEnt, Holopad.StaticEntMeta = Holopad.inheritsFrom(Holopad.Entity)
local this, meta = Holopad.StaticEnt, Holopad.StaticEntMeta


/**
	Constructor for the Holopad StaticEnt "object".  Undefined paramaters assume default values.
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
	Return:	Table (inherits Holopad.Entity)
 */
function this:New(pos, ang, name, model, colour, material)

	local new = this:super():New(pos, ang, name)
	
	setmetatable(new, meta)
	
	new.model		= model or Holopad.ERROR_MODEL
	new.colour		= colour or Holopad.COLOUR_DEFAULT()
	new.material	= material 	// nil is desirable
	
	return new

end



/**
	Return the static ent's model path, or nil if undefined.
	Return:	String or nil
 */
function this:getModel()
	return self.model
end



/**
	Return the colour of the static ent
	Args;
		returnref	Boolean
			true for colour by reference else copy of colour
	Return:	Color
 */
function this:getColour(returnref)
	return returnref and self.colour or Color(self.colour.r, self.colour.g, self.colour.b, self.colour.a)
end



/**
	Return the static ent's material override, or nil if undefined.
	Return:	String or nil
 */
function this:getMaterial()
	return self.material
end



/**
	Return: Holopad.StaticEnt
		a copy of this Entity
 */
function this:clone()
	return this:New(self:getPos(), self:getAng(), self:getName(), self:getModel(), self:getColour(), self:getMaterial())
end
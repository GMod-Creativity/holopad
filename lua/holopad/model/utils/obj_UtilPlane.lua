/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | UtilPlane object
	splambob@gmail.com	 |_| 09/09/2012               

	It is a plane.
	Inherits from Holopad.Utility
	
//*/


include("holopad/model/obj_Utility.lua")

Holopad.Utils.UtilPlane, Holopad.Utils.UtilPlaneMeta = Holopad.inheritsFrom(Holopad.Utility)
local this, meta = Holopad.Utils.UtilPlane, Holopad.Utils.UtilPlaneMeta


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
function this:New(pos, normal, scale, name)
	
	normal	= normal or Vector(0,0,1)
	local scale = scale or Vector(1,1,1)
	local max = math.max(scale.x, scale.y, scale.z) * 1.2
	scale = Vector(max, max, max)
	local new = this:super():New(pos, (normal:Angle():Up() * -1):Angle(), name or "", Holopad.CLIP_MODEL, Holopad.COLOUR_DEFAULT(), Holopad.CLIP_MATERIAL, scale)
	
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



// utilplanes must hold no relationships
function this:setParent()
end



/**
	Return: Vector
		the clip plane normal vector associated with this ClipPlane
 */
function this:getNormal()
	return self:getAng():Up()
end



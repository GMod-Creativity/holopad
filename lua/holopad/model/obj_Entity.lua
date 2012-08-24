/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Entity object
	splambob@gmail.com	 |_| 09/07/2012               

	Simple point-entity object with name
	
//*/



Holopad.Entity, Holopad.EntityMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.Entity, Holopad.EntityMeta


/**
	Constructor for the Holopad Entity "object".  Undefined paramaters assume default values.
	Args;
		pos	Vector
			Position of the entity
		ang	Angle
			Angles of the entity
		name	String
			Name of the entity
	Return:	Table (inherits Holopad.Entity)
 */
function this:New(pos, ang, name)

	local new =
	{ 
		pos 		= pos or Vector(0,0,0),
		ang 		= ang or Angle(0,0,0),
		name 		= name or ""
	}
	
	setmetatable(new, meta)
	return new

end



/**
	Return the position of the entity
	Args;
		returnref	Boolean
			true for pos vector by reference else copy of pos vector
	Return:	Vector
 */
function this:getPos(returnref)
	return returnref and self.pos or Vector(self.pos.x, self.pos.y, self.pos.z)
end



/**
	Return the angles of the entity
	Args;
		returnref	Boolean
			true for angle by reference else copy of angle
	Return:	Angle
 */
function this:getAng(returnref)
	return returnref and self.ang or Angle(self.ang.p, self.ang.y, self.ang.r)
end



/**
	Return the name of the entity.
	Return:	String
 */
function this:getName()
	return self.name
end



/**
	Sets the name of the entity to the parameter
	Args;
		name	String
 */
function this:setName(name)
	self.name = name
end



/**
	Return: Holopad.Entity
		a copy of this Entity
 */
function this:clone()
	return this:New(self:getPos(), self:getAng(), self:getName())
end



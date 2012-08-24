/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Utility object
	splambob@gmail.com	 |_| 09/07/2012               

	Simple point-utility object with name
	
//*/



Holopad.Utility, Holopad.UtilityMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.Utility, Holopad.UtilityMeta


/**
	Constructor for the Holopad Utility "object".  Undefined paramaters assume default values.
	Args;
		pos	Vector
			Position of the utility
		ang	Angle
			Angles of the utility
		name	String
			Name of the utility
	Return:	Table (inherits Holopad.Utility)
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
	Return the position of the utility
	Args;
		returnref	Boolean
			true for pos vector by reference else copy of pos vector
	Return:	Vector
 */
function this:getPos(returnref)
	return returnref and self.pos or Vector(self.pos.x, self.pos.y, self.pos.z)
end



/**
	Return the angles of the utility
	Args;
		returnref	Boolean
			true for angle by reference else copy of angle
	Return:	Angle
 */
function this:getAng(returnref)
	return returnref and self.ang or Angle(self.ang.p, self.ang.y, self.ang.r)
end



/**
	Return the name of the utility.
	Return:	String
 */
function this:getName()
	return self.name
end



/**
	Sets the name of the utility to the parameter
	Args;
		name	String
 */
function this:setName(name)
	self.name = name
end



/**
	Return: Holopad.Utility
		a copy of this Utility
 */
function this:clone()
	return this:New(self:getPos(), self:getAng(), self:getName())
end



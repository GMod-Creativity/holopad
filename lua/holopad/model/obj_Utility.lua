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



Holopad.Utility, Holopad.UtilityMeta = Holopad.inheritsFrom(Holopad.Hologram)
local this, meta = Holopad.Utility, Holopad.UtilityMeta

Holopad.Utils = Holopad.Utils or {}

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
function this:New(pos, ang, name, model, colour, material)

	local new = this:super():New(pos, ang, name, model, colour, material)
	
	setmetatable(new, meta)
	new.exportable = false
	new.transient = true
	
	return new

end


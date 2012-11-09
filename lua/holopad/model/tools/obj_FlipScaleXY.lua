/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Mirror Tool object
	splambob@gmail.com	 |_| 10/09/2012               

	The FlipScaleXY class.
	
	Used to convert 'old' (GM12) holo models to 'new' (GM13) ones
	
//*/

include("holopad/model/utils/obj_UtilPlane.lua")


Holopad.Tools.FlipScaleXY, Holopad.Tools.FlipScaleXYMeta = Holopad.inheritsFrom(Holopad.Tool)
local this, meta = Holopad.Tools.FlipScaleXY, Holopad.Tools.FlipScaleXYMeta

this.icon = "holopad/tools/squashface"
this.name = "Fix old holo scales"
this.author = "Bubbus"
this.gui = "DFlipScaleXY_Holopad"

/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	
	return new

end


/**
	Mirror all selected ents across the mirror plane
	This function is derived from the mirror function in Wenli's Precision Alignment tool.
 */
function this:Apply()
// TODO: make this work on static ents if statics are ever used.
	
	if !self:GetModelObj() then Error("No model registered with the mirror tool!") return end
	
	local scale = nil
	local tempx = 0
	for k, ent in pairs(self:GetModelObj():getAll(Holopad.Hologram)) do
		scale = ent:getScale()
		tempx = scale.x
		scale.x = scale.y
		scale.y = tempx
		ent:setScale(scale)
	end
	
	return true
	
end




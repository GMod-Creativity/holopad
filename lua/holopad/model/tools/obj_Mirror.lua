/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Tool object
	splambob@gmail.com	 |_| 09/09/2012               

	The base Tool class.
	
//*/

include("holopad/model/utils/obj_UtilPlane.lua")


Holopad.Tools.Mirror, Holopad.Tools.MirrorMeta = Holopad.inheritsFrom(Holopad.Tool)
local this, meta = Holopad.Tools.Mirror, Holopad.Tools.MirrorMeta


/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = this:super():New()
	new.pos = Vector(0,0,0)
	new.norm = Vector(1,0,0)
	
	setmetatable(new, meta)
	
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	new.plane = Holopad.Utils.UtilPlane:New()
	new.utils[#new.utils+1] = new.plane
	
	return new

end



function this:SetModelObj(mdl)
	local oldmdl = self:GetModelObj()
	if oldmdl then
		oldmdl:removeEntity(self.plane, true)
	end
	this:super().SetModelObj(self, mdl)
	mdl:addEntity(self.plane)
end



/**
	Removes a Utility from the Tool.
	Args;
		util	Holopad.Utility
			the Utility to remove
 */
function this:RemoveUtility(util)
	if util == self.plane then Error("Tried removing the mirror plane from the Mirror Tool!") return end
	if !self.utils[util] then Error("Tried removing a Utility from a Tool which does not own it!") return end
	self.utils[util] = nil
end



/**
	Set the stored mirror plane to match the pos and norm of the mirror plane Utility.
 */
function this:modelUpdateListener(update)
	if update.ent != self.plane then return end
	if update.pos then self.pos = update.pos end
	if update.ang then self.norm = self.plane:getNormal()
end



/**
	Set the centre position and normal of the mirror plane to the args, then modify the mirror plane Utility to match.
	Args;
		pos	Vector
			centre position of the mirror plane
		norm	Vector
			plane normal vector
 */
function this:SetMirrorPlane(pos, norm)
	self.pos = pos
	self.norm = norm
end



/**
	Mirror all selected ents across the mirror plane
 */
function this:Apply()
	// TODO: this
end



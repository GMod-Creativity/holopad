/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Mirror Tool object
	splambob@gmail.com	 |_| 10/09/2012               

	The Mirror-Tool class.
	
	Portions of this code are replicated from the Precision Alignment tool, by Wenli (Published under the GNU GPLv3 license);
	http://sourceforge.net/projects/wenlistools/
	Such code is attributed by comment.
	
//*/
// TODO: ghost previews

include("holopad/model/utils/obj_UtilPlane.lua")


Holopad.Tools.Measure, Holopad.Tools.MeasureMeta = Holopad.inheritsFrom(Holopad.Tool)
local this, meta = Holopad.Tools.Measure, Holopad.Tools.MeasureMeta

this.icon = "holopad/tools/measure"
this.name = "Measuring Stick"
this.author = "Bubbus"
this.gui = "DMeasureTool_Holopad"

/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	new.point1 = Holopad.Utility:New(Vector(10, 0, 0), nil, "Measure Tool - Point 1", "models/props_lab/huladoll.mdl", Color(255, 0, 0))
	new.point2 = Holopad.Utility:New(Vector(-10, 0, 0), nil, "Measure Tool - Point 2", "models/props_lab/huladoll.mdl", Color(0, 255, 0))
	new.utils[new.point1] = true
	new.utils[new.point2] = true
	
	return new

end



/**
	Removes a Utility from the Tool.
	Args;
		util	Holopad.Utility
			the Utility to remove
 */
function this:RemoveUtility(util)
	if util == self.point1 or util == self.point2 then ErrorNoHalt("WARNING: Tried removing an endpoint from the Measure Tool!  Blocked.") return false end
	this:super().RemoveUtility(self, util)
end



/**
	Set the stored mirror plane to match the pos and norm of the mirror plane Utility.
 */
function this:modelUpdateListener(update)
	if !(update.ent == self.point1 or update.ent == self.point2) then return end
	self.gooey:SetDistLabelValue(self.point1:getPos():Distance(self.point2:getPos()))
end



/**
	Return: Number
		The distance between the measure points.
 */
function this:GetDistance()
	return self.point1:getPos():Distance(self.point2:getPos())
end



/**
	If the GUI for this Tool is created, this function should then be invoked to properly configure the GUI and bind the Tool to it.
	Args;
		gooey	DFrame
			the Tool's GUI
 */
function this:OnCreatedGUI(gooey)
	this:super().OnCreatedGUI(self, gooey)
	self.gooey = gooey
end
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

include("holopad/model/utils/obj_Utility.lua")


Holopad.Tools.LinearArray, Holopad.Tools.LinearArrayMeta = Holopad.inheritsFrom(Holopad.Tool)
local this, meta = Holopad.Tools.LinearArray, Holopad.Tools.LinearArrayMeta

this.icon = "holopad/tools/larray"
this.name = "Linear Array"
this.author = "Bubbus"
this.gui = "DLinearArrayTool_Holopad"

local cellmdl  = "models/Holograms/cube.mdl"
local celldims = Vector(6,6,6)

/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	new.dims    = Vector()
	new.offsets = Vector(0,0,0)	
	new.orient  = Angle()
	new.doparentchain = false

	new.arrayCell = Holopad.Utility:New(nil, nil, "Linear Array - Cell Bounds", cellmdl, Color(255, 255, 255, 100))
	new.utils[new.arrayCell] = true

	new.monitorEnt = nil

	return new

end



/**
	Set the amount of array cells per axis.
	Args;
		vec	Vector
			represents cells per axis (rounded down)
			there will be (x-1, y-1, z-1) copies on the corresponding axes
 */
function this:SetArrayDimensions(vec)
	this.dims = vec or Vector()
end



/**
	Set the distance between each element in each direction
	Args;
		vec	Vector
			XYZ size of each array cell
 */
function this:SetArrayOffsets(vec)
	this.offsets = vec or Vector(0,0,0)
end



/**
	Set the global rotation of the array
	Args;
		ang	Angle
			orientation of the array in global space
 */
function this:SetArrayOrientation(ang)
	this.orient = ang or Angle()
end



/**
	Should each array element be parented to its preceding element?
	Args;
		bool	Boolean
			true for array element parent-chaining else false for unmodified parents
 */
function this:DoParentChain(bool)
	this.doparentchain = bool
end



/**
	Should the children of the copied ent be copied too?
	Args;
		bool	Boolean
			true for fully recursive cloning else false
 */
function this:DoArrayChildren(bool)
	this.doarraykids = bool
end



/**
	Removes a Utility from the Tool.
	Args;
		util	Holopad.Utility
			the Utility to remove
		frommodel	Boolean
			if true, do not try to remove the utility from the model too.
 */
function this:RemoveUtility(util, frommodel)
	if util == self.arrayCell then ErrorNoHalt("WARNING: Tried removing the cell-marker from the Linear Array Tool!  Blocked.") return false end
	this:super().RemoveUtility(self, util)
end



/**
	Set the Model in use by this Tool.
	Args;
		model	Holopad.Model
			the model to be used.
 */
function this:SetModelObj(mdl)
	this:super().SetModelObj(self, mdl)
	local sel = mdl:getSelectedEnts()
	self.monitorEnt = #sel > 0 and sel[1] or nil
end



local function repositionCell()
	if !self.monitorEnt then return end
	local curdims = update.scale * celldims
	local entpos = LocalToWorld(curdims, Angle(), self.monitorEnt:getPos(), self.arrayCell:getAng())
	self.arrayCell:setPos(entpos)
end



/**
	Attempt to position the cell-marker appropriately;
	When marker is scaled, we need to update the cell offsets and move it
	When marker is rotated, we need to update the array orientation and move it
	When marker is moved, we need to replace it.
	When selected ent is moved, we need to move the marker
	If just selected an ent, move the marker to it.
 */
function this:modelUpdateListener(update)
	if update.ent == self.arrayCell then
		if !self.monitorEnt then return end
		if update.scale then
			self:SetArrayOffsets(update.scale * celldims)
		elseif update.ang then
			self:SetArrayOrientation(update.ang)
		elseif update.pos then	// just reposition
		else return end
		repositionCell()
	elseif (!self.monitorEnt and update.selected) or update.ent == self.monitorEnt then
		self.monitorEnt = update.ent
		repositionCell()
	else return end
end



/**
	Clones the ent and moves it in the direction dir by the distance dist
	Args;
		ent	Holopad.Entity
			the ent to clone
		dir	Vector
			the direction to clone in
		dist
			the distance to move the clone
	Return:	Holopad.Entity
		the resulting clone
 */
local function cloneInDir(ent, dir, dist)
	clone = ent:cloneToModel(this.doparentchain and ent or nil, this:GetModelObj(), this.doarraykids)
	clone:setPos(clone:getPos() + dir*dist)
	return clone
end



/**
	Applies the linear array operation.
 */
function this:Apply()

	local mdl = this:GetModelObj()
	local sel, cur, xcur, ycur, zcur = mdl:getSelectedEnts(), nil, nil, nil, nil
	local dims, seps, angs, dir = this.dims, this.offsets, this.orient, nil

	for i=1, #sel do
		cur = sel[i]
		dir = angs:Forward()
		zcur = cur
		for z=1, dims.z do
			ycur = zcur
			for y=1, dims.y do
				xcur = ycur
				dir = angs:Forward()
				for x=1, dims.x do
					if x <= dims.x-1 then
						xcur = cloneInDir(xcur, dir, seps.x)
					end
				end
				if y <= dims.y-1 then
					ycur = cloneInDir(ycur, angs:Right(), seps.y)
				end
			end
			if z <= dims.z-1 then
				zcur = cloneInDir(zcur, angs:Up(), seps.z)
			end
		end
		cur = orig
	end

end




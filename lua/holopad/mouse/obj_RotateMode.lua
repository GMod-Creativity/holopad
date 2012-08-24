/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Rotate MouseMode
	splambob@gmail.com	 |_| 25/07/2012               

	Definition of rotate-mode mouse event behaviours
	
//*/

include("holopad/mouse/obj_MoveMode.lua")

Holopad.RotateMode, Holopad.RotateModeMeta = Holopad.inheritsFrom(Holopad.MoveMode)
local this, meta = Holopad.RotateMode, Holopad.RotateModeMeta


local DRAGDIR_NONE, DRAGDIR_UP, DRAGDIR_FOR, DRAGDIR_RT = 0, 1, 2, 3


/**
	Constructor for the RotateMode object.
	Return:	Table (instance of Holopad.RotateMode)
 */
function this:New()
	
	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.name = "rotate"
	new.Dongles = true
	new.DongleGridOrient = false
	new.DongleTextureID = surface.GetTextureID("holopad/circle_hollow")
	
	return new

end




local function roundWith(num, round)
	return math.Round(num/round)*round
end

local function roundToSnap(ang, snap)
	local ret = Angle()
	ret.p = roundWith(ang.p, snap)
	ret.y = roundWith(ang.y, snap)
	ret.r = roundWith(ang.r, snap)
	return ret
end

/**
	If snapping should occur, performs the snap.
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:doSnap(pass, lpos)
	if (input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) and self.DragEnt then
		// TODO: world orientation
		// TODO: snap local to dongles
		local grid	 = pass:GetViewport():GetGrid()
		local ang	 = self.DragEnt:getAng()
		//local rotang = grid:GetAngles()
		local _, diff	// TODO: specialize roundWith for this usage.
		local snap = Holopad.AngleSnap
		
		if		self.DragDir == DRAGDIR_FOR then
			_, diff = roundWith(ang.r, snap)
			ang:RotateAroundAxis(ang:Forward(), diff)
		elseif	self.DragDir == DRAGDIR_RT  then
			_, diff = roundWith(ang.p, snap)
			ang:RotateAroundAxis(ang:Right(), diff)
		elseif	self.DragDir == DRAGDIR_UP  then
			_, diff = roundWith(ang.y, snap)
			ang:RotateAroundAxis(ang:Up(), diff)
		end
		
		self.DragEnt:setAng(ang)
	end
end



/**
	Handle a left mouse button drag event
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:leftDragged(pass, lpos, delta)

	self.lastClickDragged = true

	if self.DragDir == DRAGDIR_NONE then this:super().leftDragged(self, pass, lpos, delta) return end

	local model		= pass:GetModelObj()
	local viewport	= pass:GetViewport()
	local glasspane	= pass:GetGlassPane()
	
	local w, h = glasspane:GetSize()
	
	local dx = delta.x
	local dy = delta.y
	local dragent, dragdir = self.DragEnt, self.DragDir
	local angs = dragent:getAng()	// TODO: world orientation
	local dongledir = (dragdir == DRAGDIR_UP and angs:Up() or (dragdir == DRAGDIR_RT and angs:Right() or angs:Forward()))
	
	local svent = viewport:GetScreenVec(dragent:getPos())
	local svdng = viewport:GetScreenVec(dragent:getPos() + dongledir)
	
	if !(svent && svdng) then Error("Tried to rotate an Entity but " .. (!svent and "Entity's screen position" or "Dongle's screen position") .." was undefined!") end
	
	local svdir = svdng - svent
	local dir = math.Rad2Deg( math.acos( svdir:GetNormalized():Dot( Vector(dx, dy, 0):Normalize() ))) >= 90 and 1 or -1
	
	local newang = dragent:getAng()
	newang:RotateAroundAxis(dongledir, (Vector(dx, dy, 0):Length()*dir)/4)
	dragent:setAng(newang)
	
end



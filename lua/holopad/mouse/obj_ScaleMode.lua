/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Scale MouseMode
	splambob@gmail.com	 |_| 25/07/2012               

	Definition of scale-mode mouse event behaviours
	
//*/

include("holopad/mouse/obj_MoveMode.lua")

Holopad.ScaleMode, Holopad.ScaleModeMeta = Holopad.inheritsFrom(Holopad.MoveMode)
local this, meta = Holopad.ScaleMode, Holopad.ScaleModeMeta


local DRAGDIR_NONE, DRAGDIR_UP, DRAGDIR_FOR, DRAGDIR_RT = 0, 1, 2, 3
local MAXSCALE = ConVarExists("wire_holograms_size_max") and GetConVar("wire_holograms_size_max"):GetInt() or math.huge


/**
	Constructor for the RotateMode object.
	Return:	Table (instance of Holopad.RotateMode)
 */
function this:New()
	
	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.name = "scale"
	new.Dongles = true
	new.DongleGridOrient = false
	new.DongleTextureID = surface.GetTextureID("holopad/square_hollow")
	
	return new

end




local function getSnapValue(num)
	// TODO: rounding instead of flooring
	if num > 20  then return math.Clamp(num - (num % 5),    20,   50  ) end
	if num > 10  then return math.Clamp(num - (num % 1),    10,   20  ) end
	if num > 1   then return math.Clamp(num - (num % 0.5),  1,    20  ) end
	if num > 0   then return math.Clamp(num - (num % 0.1),  0.1,  1   ) end
	Error("Tried to invoke roundToSnap on a negative number!")
end

local function roundWith(num, round)
	local abs = math.abs(num)
	local mod = abs % round
	if mod < round/2 then return (abs - mod)*(num/abs), -mod*(num/abs) end
	return (abs + (round - mod))*(num/abs), (round - mod)*(num/abs)
end

local function roundToSnap(vec, snap)
	local ret = Vector()
	ret.x = roundWith(vec.x, snap)
	ret.y = roundWith(vec.y, snap)
	ret.z = roundWith(vec.z, snap)
	return ret
end

function this:doSnap(pass, lpos)
	// TODO: snap local to dongles
	
	if (input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) and self.DragEnt then
		if !self.DragEnt:instanceof(Holopad.Hologram) then Error("Tried to scale a non-hologram.  Only Holograms may be scaled.") end
		
		local pos = self.DragEnt:getScale()
		//local ang = self.DragEnt:getAng()
		local dist = Holopad.ScaleSnap//pass:GetViewport():GetCamDist(self.DragEnt)
		//pos = WorldToLocal( pos, Angle(), Vector(), ang )
		//dist = getSnapValue(dist/800)	//TODO: snap grid value based on context control panel
		
		if		self.DragDir == DRAGDIR_FOR then
			pos.x = roundWith(pos.x, dist)
		elseif	self.DragDir == DRAGDIR_RT  then
			pos.y = roundWith(pos.y, dist)
		elseif	self.DragDir == DRAGDIR_UP  then
			pos.z = roundWith(pos.z, dist)
		end
		
		//pos = roundToSnap(pos, dist)
		//pos = LocalToWorld( pos, Angle(), Vector(), ang )
		self.DragEnt:setScale(pos)
	end
end




local function vectorClamp(self, clampval)
	local ret = Vector(self.x, self.y, self.z)
	ret.x = math.Clamp(ret.x, -clampval, clampval)
	ret.y = math.Clamp(ret.y, -clampval, clampval)
	ret.z = math.Clamp(ret.z, -clampval, clampval)
	return ret
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
	if !self.DragEnt:instanceof(Holopad.Hologram) then Error("Tried to scale a non-hologram.  Only Holograms may be scaled.") end

	local model		= pass:GetModelObj()
	local viewport	= pass:GetViewport()
	local glasspane	= pass:GetGlassPane()
	
	local w, h = glasspane:GetSize()
	
	local dx = delta.x
	local dy = delta.y
	local dragent, dragdir = self.DragEnt, self.DragDir
	local angs = dragent:getAng()	// TODO: world orientation
	local dongledir = (dragdir == DRAGDIR_UP and angs:Up() or (dragdir == DRAGDIR_RT and angs:Right() or angs:Forward()))
	local uniscale  = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)
	local dirlocal  = uniscale and Vector(1, 1, 1) or (dragdir == DRAGDIR_UP and Vector(0, 0, 1) or (dragdir == DRAGDIR_RT and Vector(0, 1, 0) or Vector(1, 0, 0)))
	
	local svent = viewport:GetScreenVec(dragent:getPos())
	local svdng = viewport:GetScreenVec(dragent:getPos() + dongledir)
	
	if !(svent && svdng) then Error("Tried to scale an Entity but " .. (!svent and "Entity's screen position" or "Dongle's screen position") .." was undefined!") end
	
	local svdir = svdng - svent
	local dir = (math.Rad2Deg(math.acos(svdir:GetNormalized():Dot(Vector(dx, dy, 0):Normalize()))) >= 90 and 1 or -1)
	
	local scale = dragent:getScale()
	local scalerel = scale / math.min(scale.x, scale.y, scale.z)	// required to retain proportions during uniform scale
	
	local dragscale = (dragdir == DRAGDIR_UP and scale.z or (dragdir == DRAGDIR_RT and scale.y or scale.x))
	dragscale = math.Clamp( dragscale*(dragscale < 0 and -1 or 1) + 0.05, -1, 1 )
	local sensitivity = viewport:GetCamDist(dragent) / 6400
	
	dragent:setScale( vectorClamp( scale + ( dirlocal * Vector(dx, dy, 0):Length() * dir * dragscale ) * sensitivity * scalerel, MAXSCALE) )
	
end



/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Move MouseMode
	splambob@gmail.com	 |_| 24/07/2012               

	Definition of move-mode mouse event behaviours
	
//*/

include("holopad/mouse/obj_SelectMode.lua")

Holopad.MoveMode, Holopad.MoveModeMeta = Holopad.inheritsFrom(Holopad.SelectMode)
local this, meta = Holopad.MoveMode, Holopad.MoveModeMeta


local DRAGDIR_NONE, DRAGDIR_UP, DRAGDIR_FOR, DRAGDIR_RT = 0, 1, 2, 3


/**
	Constructor for the MoveMode object.
	Return:	Table (instance of Holopad.MoveMode)
 */
function this:New()
	
	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.name = "move"
	new.Dongles = true
	new.DongleGridOrient = true
	new.DongleTextureID = surface.GetTextureID("holopad/arrowup_solid")
	
	return new

end



/**
	Handle a left mouse button press
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:leftClick(pass, lpos)
	//print("MoveMode leftClick", self, pass, lpos)
	self.lastClickDragged = false
	
	local model		= pass:GetModelObj()
	local viewport	= pass:GetViewport()
	local glasspane	= pass:GetGlassPane()
	
	local visible = viewport:GetVisibleEnts()
	table.sort(visible, function(a, b) return viewport:GetCamDist(a) < viewport:GetCamDist(b) end)
	
	local ent, dir = self:getDongle(model, viewport, glasspane, visible, lpos)
	//print(ent, dir)
	self:setDragDirEnt(dir, ent)
	
	if !ent or dir == DRAGDIR_NONE then
		this:super().leftClick(self, pass, lpos)
	end	
	
end




local function roundToSnap(vec, snap)
	local ret = Vector()
	ret.x = roundWith(vec.x, snap)
	ret.y = roundWith(vec.y, snap)
	ret.z = roundWith(vec.z, snap)
	return ret
end

/**
	Handle a left mouse button release
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:leftReleased(pass, lpos)
	self:doSnap(pass, lpos)
	
	self.DragDir = DRAGDIR_NONE
	self.DragEnt = nil
	
	this:super().leftReleased(self, pass, lpos) 
end




function this:doSnap(pass, lpos)
	// TODO: snap local to dongles
	if (input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) and self.DragEnt then
		local grid	= pass:GetViewport():GetGrid()
		local pos	= self.DragEnt:getPos()
		local ang	= grid:GetAngles()//self.DragEnt:getAng()
		local dist	= Holopad.GridSize
		pos = WorldToLocal( pos, Angle(), grid:GetPos(), ang )
		
		if		self.DragDir == DRAGDIR_FOR then
			pos.x = math.Round(pos.x/dist)*dist
		elseif	self.DragDir == DRAGDIR_RT  then
			pos.y = math.Round(pos.y/dist)*dist
		elseif	self.DragDir == DRAGDIR_UP  then
			pos.z = math.Round(pos.z/dist)*dist
		end
		
		pos = LocalToWorld( pos, Angle(), grid:GetPos(), ang )
		self.DragEnt:setPos(pos)
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
	//print("MoveMode leftDragged", self, pass, lpos, delta)
	self.lastClickDragged = true
	
	if self.DragDir == DRAGDIR_NONE then this:super().leftDragged(self, pass, lpos, delta) return end

	local model		= pass:GetModelObj()
	local viewport	= pass:GetViewport()
	local glasspane	= pass:GetGlassPane()
	local grid		= pass:GetViewport():GetGrid()
	
	local w, h = glasspane:GetSize()
	
	local dx = delta.x
	local dy = delta.y
	local dragent, dragdir = self.DragEnt, self.DragDir
	local angs = grid:GetAngles()
	local dongledir = (dragdir == DRAGDIR_UP and angs:Up() or (dragdir == DRAGDIR_RT and angs:Right() or angs:Forward()))
	
	local svent = viewport:GetScreenVec(dragent:getPos())
	local svdng = viewport:GetScreenVec(dragent:getPos() + dongledir)
	
	if !(svent && svdng) then Error("Tried to move an Entity but " .. (!svent and "Entity's screen position" or "Dongle's screen position") .." was undefined!") end
	
	local svdir = svdng - svent
	local dir = math.Rad2Deg( math.acos( svdir:GetNormalized():Dot( Vector(dx, dy, 0):Normalize() ))) >= 90 and 1 or -1
	local sensitivity = viewport:GetCamDist(dragent) / 400
	
	dragent:setPos( dragent:getPos() + ( dongledir * Vector(dx, dy, 0):Length() * dir ) * sensitivity )	
end




function this:getDongle(model, viewport, glasspane, visible, mvec)

	local view = viewport:GetDirVec()
	local donglength, dongrad = Holopad.DONGLE_LENGTH, Holopad.DONGLE_RADIUS

	local cenpos, centrepos, angs, dir, screenvecup, screenvecrt, screenvecfor
	for _, v in ipairs(visible) do
		if model:isEntSelected(v) then	
			cenpos = v:getPos()
			dongs = glasspane:GetDongleInfo(v, true)
			
			if dongs then
				if		dongs.DongUpVis and mvec:Distance(dongs.DongUpPos) <= dongrad	then
					return v, DRAGDIR_UP
				elseif	dongs.DongRtVis and mvec:Distance(dongs.DongRtPos) <= dongrad	then
					return v, DRAGDIR_RT
				elseif	dongs.DongFwVis and mvec:Distance(dongs.DongFwPos) <= dongrad	then
					return v, DRAGDIR_FOR
				end
			end
		end
	end
	
	return nil, DRAGDIR_NONE
end




function this:setDragDirEnt(dir, ent)
	this.Switch_SetDragDirEnt[dir](self, ent)
end
	
	
this.Switch_SetDragDirEnt = {}
this.Switch_SetDragDirEnt[DRAGDIR_NONE] =
	function(self, v)
		self.DragDir = DRAGDIR_NONE
		self.DragEnt = nil
	end

this.Switch_SetDragDirEnt[DRAGDIR_UP]   =
	function(self, v)
		self.DragDir = DRAGDIR_UP
		self.DragEnt = v
	end
	
this.Switch_SetDragDirEnt[DRAGDIR_RT]   =
	function(self, v)
		self.DragDir = DRAGDIR_RT
		self.DragEnt = v
	end
	
this.Switch_SetDragDirEnt[DRAGDIR_FOR]  =
	function(self, v)
		self.DragDir = DRAGDIR_FOR
		self.DragEnt = v
	end



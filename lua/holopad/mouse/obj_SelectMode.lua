/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Select MouseMode
	splambob@gmail.com	 |_| 19/07/2012               

	Definition of default mouse event behaviours
	
//*/

include("holopad/mouse/obj_CameraMode.lua")

Holopad.SelectMode, Holopad.SelectModeMeta = Holopad.inheritsFrom(Holopad.CameraMode)
local this, meta = Holopad.SelectMode, Holopad.SelectModeMeta


/**
	Constructor for the SelectMode object.
	Return:	Table (instance of Holopad.SelectMode)
 */
function this:New()
	
	local new = self:super():New()
	
	setmetatable(new, meta)
	
	new.name = "select"
	new.lastClicked = RealTime()
	new.lastClickSelected = false
	new.deselectClickTime = 0.1
	
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
	//print("SelectMode leftClick", self, pass, lpos)
	
	self.lastClickDragged = false
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
	//print("SelectMode leftReleased", self, pass, lpos)
	
	if self.lastClickDragged then return end
	
	local model		= pass:GetModelObj()
	local viewport	= pass:GetViewport()
	local glasspane	= pass:GetGlassPane()
	
	local visible = viewport:GetVisibleEnts()
	
	table.sort(visible, function(a, b) return viewport:GetCamDist(a) < viewport:GetCamDist(b) end)
	
	self.lastClickSelected = false
	local screenvec
	for _, v in ipairs(visible) do
		screenvec = viewport:GetScreenVec(v:getPos())
		if screenvec && lpos:Distance(screenvec) <= glasspane:GetMarkerSize(v)/2 then
			if		(input.IsKeyDown(KEY_LCONTROL) || input.IsKeyDown(KEY_RCONTROL)) then
				model:selectEnt(v)
			elseif	(input.IsKeyDown(KEY_LALT) || input.IsKeyDown(KEY_RALT)) then
				model:deselectEnt(v)
			else
				model:selectEnt(v, true)
			end
			
			self.lastClickSelected = true
			break
		end
	end
	
	if !self.lastClickSelected then
		pass:GetModelObj():deselectAll()
	end
end



/**
	Handle a left mouse button drag event
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:leftDragged(pass, lpos, delta)
	self.lastClickDragged = true
	this:super():leftDragged(pass, lpos, delta)
end



/**
	Return the selection candidate given a glasspane (and therefore viewport) and a mouse position.
	Args;
		glasspane	DGlassPane_Holopad
			the glasspane (must contain an initialized viewport)
		lpos	Vector
			position of the mouse cursor local to the glasspane
	Return: Table (inherits Holopad.Entity)
		the selection candidate
 */
function this:getSelectionCandidate(glasspane, lpos)

	local viewport	= glasspane:GetViewport()
	local model		= viewport:GetModelObj()
	
	local visible = viewport:GetVisibleEnts()
	
	table.sort(visible, function(a, b) return viewport:GetCamDist(a) < viewport:GetCamDist(b) end)
	
	local found = nil
	local screenvec
	for _, v in ipairs(visible) do
		screenvec = viewport:GetScreenVec(v:getPos())
		if screenvec && lpos:Distance(screenvec) <= glasspane:GetMarkerSize(v)/2 then
			return v
		end
	end
	return nil
end



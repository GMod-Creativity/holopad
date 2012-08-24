/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Camera MouseMode
	splambob@gmail.com	 |_| 19/07/2012               

	Definition of camera-mode mouse event behaviours
	
//*/


include("holopad/mouse/obj_MouseMode.lua")

Holopad.CameraMode, Holopad.CameraModeMeta = Holopad.inheritsFrom(Holopad.MouseMode)
local this, meta = Holopad.CameraMode, Holopad.CameraModeMeta


/**
	Constructor for the CameraMode object.
	Return:	Table (instance of Holopad.CameraMode)
 */
function this:New()
	
	local new = self:super():New()
	
	setmetatable(new, meta)
	
	new.name = "camera"
	
	return new

end



/**
	Handle a left mouse button drag event
	Args;
		pass	DViewPanel_Holopad
			passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:leftDragged(pass, lpos, delta)
	//print("CameraMode leftDragged", self, pass, lpos, delta)
	self.lastClickDragged = true
	
	local viewport = pass:GetViewport()
	local camAng = viewport:GetCamAng()
	
	camAng = camAng + Angle(delta.y*Holopad.InvertCameraY, -delta.x*Holopad.InvertCameraX, 0)
	viewport:SetCamAng(camAng)
end



/**
	Handle a right mouse button drag event
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:rightDragged(pass, lpos, delta)
	//print("CameraMode rightDragged", self, pass, lpos, delta)
	local viewport = pass:GetViewport()
	local camAng = viewport:GetCamAng()
	
	local sensitivity = viewport:GetCamDist() / 400
	viewport:SetLookAt(viewport:GetLookAt() + ((camAng:Right()*delta.x*Holopad.InvertPanningX) + (camAng:Up()*-delta.y*Holopad.InvertPanningY))*sensitivity)
	viewport:SetCamAng(camAng)
end



/**
	Handle a middle mouse button drag event
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:middleDragged(pass, lpos, delta)
	//print("CameraMode middleDragged", self, pass, lpos, delta)
	local viewport = pass:GetViewport()
	local camAng = viewport:GetCamAng()
	
	local sensitivity = viewport:GetCamDist() / 400
	viewport:SetLookAt(viewport:GetLookAt() + ((camAng:Right()*delta.x*Holopad.InvertPanningX) + (camAng:Forward()*delta.y*Holopad.InvertPanningY*2))*sensitivity)
	viewport:SetCamAng(camAng)
end



/**
	Handle a mouse wheeling event
	Args;
		pass	DViewPanel_Holopad
			data passed from the MouseHandler
		delta	Number
			magnitude and sense of the mouse wheeling
*/
function this:mouseWheeled(pass, delta)
	//print("CameraMode mouseWheeled", self, pass, delta)
	local viewport = pass:GetViewport()
	local dist = viewport:GetCamDist()
	
	viewport:SetCamAng(viewport:GetCamAng(), math.Clamp(dist - delta*dist*0.15, 1, 99999))
end



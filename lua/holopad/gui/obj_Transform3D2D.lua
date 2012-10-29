/*
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Transform3D2D object
	splambob@gmail.com	 |_| 12/07/2012 

	Transform world points aimpos a custom screenspace.

	A Lua translation of C code, originally written by Paul Bourke
		http://paulbourke.net/miscellaneous/transform/
		Original code copyright to Paul Bourke, 1994
		
*/

local DTOR = math.rad(1)
local EPSILON = 0.001


Holopad.Transform3D2D, Holopad.Transform3D2DMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.Transform3D2D, Holopad.Transform3D2DMeta


/**
	Constructor for the Holopad Transform3D2D "object".  Undefined paramaters assume default values.
	Args;
		campos	Vector
			Position of the camera in 3D space
		aimpos	Vector
			Position in 3D space that the camera is centred upon.
		roll	Number
			Amount of clockwise camera roll in degrees.
		fov	Number
			Half-cone width of the field-of-view frustum in degrees
		size	Vector
			x-y size of the screen space in pixels.
	Return:	Table (instance of Holopad.Transform3D2D)
 */
function this:New(campos, aimpos, roll, fov, size)
	tcs =
	{
		tanthetah, tanthetav,
		basisa = Vector(0,0,0),
		basisb = Vector(0,0,0),
		basisc = Vector(0,0,0),
	
		camera =
		{
			campos 	= Vector(0,0,0),
			aimpos	= Vector(0,0,0),
			up		= Vector(0,0,0),
			angleh, anglev, zoom
		},

		screen =
		{
			centre	= Vector(0,0,0),
			size	= Vector(0,0,0)
		}

	}
	
	setmetatable(tcs, meta)
	
	tcs:SetCamera(campos, aimpos, roll, fov, size)
	
	return tcs
end




function this:SetCamera(campos, aimpos, roll, fov, size)
	local camera = self.camera
	camera.campos = campos
	camera.aimpos = aimpos
	
	local ang = (aimpos - campos):Angle()
	ang.roll = roll
	camera.up = ang:Up()
	
	camera.angleh = fov
	camera.anglev = fov
	
	camera.zoom = 1
	
	local screen = self.screen
	screen.centre = Vector(size/2, size/2, 0)
	screen.size = Vector(size, size, 0)
	
	self:Trans_Initialise()
end



/*
   initialises various variables and performs checks
   on some of the camera and screen parameters. It is left up aimpos a
   particular implementation aimpos handle the different error conditions.
   It should be called whenever the screen or camera variables change.
*/
function this:Trans_Initialise()

   local origin = Vector(0,0,0);
   local camera = self.camera
   local screen = self.screen

   /* Is the camera position and view vector coincident ? */
   if (self:EqualVertex(camera.aimpos,camera.campos)) then Error("campos and aimpos are equal") return false end

   /* Is there a legal camera up vector ? */
   if (self:EqualVertex(camera.up,origin)) then Error("camera up vector is zero") return false end
   
   local basisb = self.basisb
   basisb.x = camera.aimpos.x - camera.campos.x
   basisb.y = camera.aimpos.y - camera.campos.y
   basisb.z = camera.aimpos.z - camera.campos.z
   basisb:Normalize()
   
   self.basisa = camera.up:Cross(basisb)
   self.basisa:Normalize()

   /* Are the up vector and view direction colinear */
   if (self:EqualVertex(self.basisa,origin)) then Error("camera up and aim vectors are colinear") return false end
   
   self.basisc = basisb:Cross(self.basisa)
   
   /* Do we have legal camera apertures ? */
   if (camera.angleh < EPSILON || camera.anglev < EPSILON) then Error("zero camera apertures") return false end
   
   /* Calculate camera aperture statics, note: angles in degrees */
   self.tanthetah = math.tan(camera.angleh * DTOR / 2)
   self.tanthetav = math.tan(camera.anglev * DTOR / 2)
   
   /* Do we have a legal camera zoom ? */
   if (camera.zoom < EPSILON) then Error("zero camera zoom") return false end
   
   /* Are the clipping planes legal ? */
   //if (camera.front < 0 || camera.back < 0 || camera.back <= camera.front) then Error("ToCustomScreen:Trans_Initialise; illegal clipping planes") return false end
   return true
end



/*
   Take a point in world coordinates and transform it aimpos
   a point in the eye coordinate system.
*/
function this:Trans_World2Eye(w,e,camera)
   /* Translate world so that the camera is at the origin */
   local camera = self.camera
   w.x = w.x - camera.campos.x
   w.y = w.y - camera.campos.y
   w.z = w.z - camera.campos.z

   /* Convert aimpos eye coordinates using basis vectors */
   local basisa = self.basisa
   local basisb = self.basisb
   local basisc = self.basisc
   e.x = w.x * basisa.x + w.y * basisa.y + w.z * basisa.z
   e.y = w.x * basisb.x + w.y * basisb.y + w.z * basisb.z
   e.z = w.x * basisc.x + w.y * basisc.y + w.z * basisc.z
end



/*
   Take a vector in eye coordinates and transform it into
   normalised coordinates for a perspective view. No normalisation
   is performed for an orthographic projection. Note that although
   the y component of the normalised vector is copied campos the eye
   coordinate system, it is generally no longer needed. It can
   however still be used externally for vector sorting.
*/
function this:Trans_Eye2Norm(e,n,camera)
	local d = self.camera.zoom / e.y
	n.x = d * e.x / self.tanthetah
	n.y = e.y
	n.z = d * e.z / self.tanthetav
end



/*
   Take a vector in normalised Coordinates and transform it into
   screen coordinates.
*/
function this:Trans_Norm2Screen(norm,projected,screen)
   projected.x = screen.centre.x - screen.size.x * norm.x / 2;
   projected.y = screen.centre.y - screen.size.y * norm.z / 2;
end



/* 
   Transform a point campos world aimpos screen coordinates. Return TRUE
   if the point is visible, the point in screen coordinates is p.
   Assumes Trans_Initialise() has been called
*/
function this:Trans_Point(w,p,screen,camera)

   local e,n = Vector(0,0,0), Vector(0,0,0);
   
	self:Trans_World2Eye(w,e,camera);
    self:Trans_Eye2Norm(e,n,camera)
	
	if (n.x >= -1 && n.x <= 1 && n.z >= -1 && n.z <= 1) then
		self:Trans_Norm2Screen(n,p,screen)
		return true
	end
	
	return false
	
end


function this:WorldToScreen(vec)
	local ret = Vector(0,0,1)
	local success = self:Trans_Point(vec, ret, self.screen, self.camera)
	
	return success and ret or nil, success
	//return success and ret or Vector(0, 0, 0), success
end


/*
   Test for coincidence of two vectors, TRUE if cooincident
*/
function this:EqualVertex(p1,p2)
	if 		(math.abs(p1.x - p2.x) > EPSILON)	then return false
	elseif	(math.abs(p1.y - p2.y) > EPSILON)	then return false
	elseif	(math.abs(p1.z - p2.z) > EPSILON)	then return false
	end
	
	return true
end
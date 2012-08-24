/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Base MouseMode
	splambob@gmail.com	 |_| 18/07/2012               

	Definition of default mouse event behaviours
	
//*/


Holopad.MouseMode, Holopad.MouseModeMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.MouseMode, Holopad.MouseModeMeta


/**
	Constructor for the MouseMode object.
	Return:	Table (instance of Holopad.CameraMode)
 */
function this:New()
	
	local new =
	{
		name = "mouse"
	}
	
	setmetatable(new, meta)
	
	return new

end



/**
	Handle a left mouse button press
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:leftClick(pass, lpos)
	//print("MouseMode leftClick", self, pass, lpos)
end



/**
	Handle a left mouse button release
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:leftReleased(pass, lpos)
	//print("MouseMode leftReleased", self, pass, lpos)
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
	//print("MouseMode leftDragged", self, pass, lpos, delta)
end



/**
	Handle a right mouse button press
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:rightClick(pass, lpos)
	//print("MouseMode rightClick", self, pass, lpos)
end



/**
	Handle a right mouse button release
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:rightReleased(pass, lpos)
	//print("MouseMode rightReleased", self, pass, lpos)
end



/**
	Handle a right mouse button drag event
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:rightDragged(pass, lpos, delta)
	//print("MouseMode rightDragged", self, pass, lpos, delta)
end



/**
	Handle a middle mouse button press
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:middleClick(pass, lpos)
	//print("MouseMode middleClick", self, pass, lpos)
end



/**
	Handle a middle mouse button release
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:middleReleased(pass, lpos)
	//print("MouseMode middleReleased", self, pass, lpos)
end



/**
	Handle a middle mouse button drag event
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse dragging
 */
function this:middleDragged(pass, lpos, delta)
	//print("MouseMode middleDragged", self, pass, lpos, delta)
end



/**
	Handle a mouse wheeling event
	Args;
		pass	Anything
			data passed from the MouseHandler
		delta	Number
			magnitude and sense of the mouse wheeling
*/
function this:mouseWheeled(pass, delta)
	//print("MouseMode mouseWheeled", self, pass, delta)
end



/**
	Handle a mouse movement event (no buttons pressed)
	Args;
		pass	Anything
			data passed from the MouseHandler
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse movement
 */
function this:mouseMoved(pass, lpos, delta)
	//print("MouseMode mouseMoved", self, pass, lpos, delta)
end



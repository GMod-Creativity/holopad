/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Mouse Handler
	splambob@gmail.com	 |_| 18/07/2012               

	Stores mouse modes and dispatches events to them.
	
//*/


Holopad.MouseHandler, Holopad.MouseHandlerMeta = Holopad.inheritsFrom(nil)
local this, meta = Holopad.MouseHandler, Holopad.MouseHandlerMeta


/**
	Constructor for the MouseHandler object.
	Return:	Table (inherits Holopad.MouseHandler)
 */
function this:New(pass)
	
	local new =
	{
		Active = nil,
		PassToMode = pass,
		Modes = {},
		
		PressedLeft		= false,
		PressedMid		= false,
		PressedRight	= false
	}
	
	setmetatable(new, meta)
	
	return new

end



/**
	Set the active MouseMode by its name field.
	Args;
		mode	String
			desired MouseMode's name
 */
function this:setActiveMode(mode)
	local lmode = self.Modes[mode]
	self.Active = lmode and lmode or Error("Tried to sed unregistered/invalid mode; " .. mode)
end



/**
	Get the active MouseMode.
	Return: Table (inherits Holopad.MouseMode)
		the active mousemode
 */
function this:getActiveMode()
	return self.Active
end



/**
	Set the data to pass to the active MouseMode upon calling
	Args;
		pass	Anything
			data to pass to the active MouseMode
 */
function this:setPassToMode(pass)
	self.PassToMode = pass
end



/**
	Register a MouseMode instance with this MouseHandler
	Args;
		mode	Table (inherits Holopad.MouseMode)
			MouseMode to assign to this
 */
function this:registerMode(mode)
	self.Modes[mode.name] = mode
end



/**
	Handle a mouse press (dispatch an appropriate call to the active MouseMode)
	Args;
		mcode	Number (enum MOUSE_*)
			mouse code of the mouse button pressed
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:mousePressed(mcode, lpos)
	local mode = self.Active
	
	if mcode == MOUSE_LEFT then
		self.PressedLeft = true
		mode:leftClick(self.PassToMode, lpos)
	elseif mcode == MOUSE_MIDDLE then
		self.PressedMid = true
		mode:middleClick(self.PassToMode, lpos)
	elseif mcode == MOUSE_RIGHT then
		self.PressedRight = true
		mode:rightClick(self.PassToMode, lpos)
	end
end



/**
	Handle a mouse release (dispatch an appropriate call to the active MouseMode)
	Args;
		mcode	Number (enum MOUSE_*)
			mouse code of the mouse button released
		lpos	Vector
			position of the mouse cursor local to the caller
 */
function this:mouseReleased(mcode, lpos)
	local mode = self.Active
	
	if mcode == MOUSE_LEFT then
		self.PressedLeft = false
		mode:leftReleased(self.PassToMode, lpos)
	elseif mcode == MOUSE_MIDDLE then
		self.PressedMid = false
		mode:middleReleased(self.PassToMode, lpos)
	elseif mcode == MOUSE_RIGHT then
		self.PressedRight = false
		mode:rightReleased(self.PassToMode, lpos)
	end
end



/**
	Handle a mouse movement (dispatch an appropriate call to the active MouseMode)
	Args;
		lpos	Vector
			position of the mouse cursor local to the caller
		delta	Vector
			representation of the mouse movement
 */
function this:mouseMoved(lpos, delta)
	local mode = self.Active
	local dispatched = false
	
	if self.PressedLeft then
		dispatched = true
		mode:leftDragged(self.PassToMode, lpos, delta)
	end
	if self.PressedMid then
		dispatched = true
		mode:middleDragged(self.PassToMode, lpos, delta)
	end
	if self.PressedRight then
		dispatched = true
		mode:rightDragged(self.PassToMode, lpos, delta)
	end
	if !dispatched then
		mode:mouseMoved(self.PassToMode, lpos, delta)
	end
end



/**
	Handle a mouse wheeling event (dispatch an appropriate call to the active MouseMode)
	Args;
		delta	Number
			magnitude and sense of the mouse wheeling
*/
function this:mouseWheeled(delta)
	self.Active:mouseWheeled(self.PassToMode, delta)
end



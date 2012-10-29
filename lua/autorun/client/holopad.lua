/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Init file
	splambob@gmail.com	 |_| 09/07/2012               

//*/


Holopad = {}
Holopad.Running = false
Holopad.Window = nil
local window, success

local function Cmds(ply,command,args)

	if Holopad.Running then Error("Holopad is already running!") return end
	Holopad.Running = true
	
	Holopad.Persist.Retrieve()
	
	//success, window = pcall(vgui.Create, "DHolopad")
	//if !success then window:Close() Error("window creation fail!") end
	window = vgui.Create("DHolopad")
	Holopad.Window = window
	
	local oldclose = window.Close
	window.Close = 	function(self)
						Holopad.Running = false
						Holopad.Persist.Persist()
						oldclose(self)
						Holopad.Window = nil
					end
	//*
	ErrorNoHalt("THIS IS A BETA BUILD OF HOLOPAD 2!\n")
	ErrorNoHalt("Please try to abuse the system to cause errors.\n")
	ErrorNoHalt("If you find any, please email me at splambob@googlemail.com or post in the thread.\n")
	ErrorNoHalt("Describe what you were doing to cause the error, along with the error message.  I'll love you forever (0.1% homo)\n")
	//*/
end

concommand.Add("Holopad", Cmds)




/**
	Base of the inheritance system for this project.
	adapted from	http://lua-users.org/wiki/InheritanceTutorial	, creds to those guys.
	Args;
		baseClass	Table
			the table which a new class should be derived from.
 */
function Holopad.inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class, __call = new_class.New }

    function new_class:New()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

	
    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
	else
		new_class.__index = new_class
    end


    function new_class:class()
        return new_class
    end

	
    function new_class:super()
        return baseClass
    end
	
	
	function new_class:instanceof(class)
		if new_class == class then return true end
		if baseClass == nil then return false end
		return baseClass:instanceof(class)
	end
	
	/*
	function new_class:printITree()
		print(new_class)
		if baseClass then baseClass:printITree() end
	end
	//*/

    return new_class, class_mt
end



function Holopad.VectorClamp(self, clampval)
	local ret = Vector(self.x, self.y, self.z)
	ret.x = math.Clamp(ret.x, -clampval, clampval)
	ret.y = math.Clamp(ret.y, -clampval, clampval)
	ret.z = math.Clamp(ret.z, -clampval, clampval)
	return ret
end


include("holopad/folder.lua")

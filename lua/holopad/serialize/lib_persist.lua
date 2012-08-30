/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Persistence library
	splambob@gmail.com	 |_| 20/08/2012       

	Library for inter-session persistence
	
//*/

include("holopad/serialize/vonGMOD.lua")

Holopad.Persist = {}
local lib = Holopad.Persist
lib.registered = {}


// init setup



/**
	Register a piece of data by its name in the global namespace.
	Args;
		name	String
			the data's name in the global namespace.
			example; Holopad.Hi.There
			this is a workaround because debug.getlocal only works on integers
	Return:	Boolean
		success
 */
function lib.RegisterGlobal(name)
	lib.registered[name] = true
	return true
end



/**
	Remove a piece of data from the persist list using its 
	Args;
		name	String
			the data's name in the global namespace.
			example; Holopad.Hi.There
			this is a workaround because debug.getlocal only works on integers
	Return:	Boolean
		success
 */
function lib.UnregisterGlobal(name)
	lib.registered[name] = nil
	return true
end



/**
	Return: Boolean
		true if the name is registered, else false
 */
function lib.IsRegistered(name)
	return lib.registered[name] and true or false
end



/**
	Save all data in the persistence list to file.
 */
function lib.Persist()
	local vals = {}
	
	Msg("Persisting vars...\n")
	
	local exp, cur, failed
	for name, _ in pairs(lib.registered) do
		exp = string.Explode(".", name)
		cur = _G
		failed = false
		
		for i=1, #exp do
			if type(cur) != "table" then
				Msg("Error adding " .. name .. " to Persistence file (encountered non-table).  Skipping...")
				failed = true
				break
			elseif cur[exp[i]] != nil then
				cur = cur[exp[i]]
			else
				Msg("Error adding " .. name .. " to Persistence file (could not find).  Skipping...")
				failed = true
				break
			end
		end
		
		if !failed then
			vals[name] = cur
		end
	end
	
	local ser = von.serialize(vals)
	file.Write(Holopad.PERSIST_FILE or "HolopadData/persist.txt", ser)
end



/**
	Retrieve all persisted vars from the persistence file and restore them.
	A value may only be restored if the table which holds it already exists.
	This function may overwrite existing values.
 */
function lib.Retrieve()
	local ser = file.Read(Holopad.PERSIST_FILE or "HolopadData/persist.txt")
	if !ser then Msg("Holopad; No persistence file to retrieve!\n") return end
	vals = von.deserialize(ser)
	
	Msg("Reviving persisted vars...\n")
	//PrintTable(vals)
	
	for name, val in pairs(vals) do
		exp = string.Explode(".", name)
		cur = _G
		failed = false
		
		for i=1, #exp-1 do
			if cur[exp[i]] then
				cur = cur[exp[i]]
			else
				Msg("Error reviving " .. name .. " from Persistence file (tables not initialized).  Skipping...")
				failed = true
				break
			end
		end
		
		if !failed then
			cur[exp[#exp]] = val
			lib.registered[name] = true
		end
	end
end
/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Keyboard object
	splambob@gmail.com	 |_| 20/09/2012               

	Ok fine this isn't a mouse object!
	Holds and executes keyboard binds.
	
//*/



Holopad.Keyboard = {binds = {}, binddata = {}, pressed = {}}
local this = Holopad.Keyboard


// bitwise, without the bitwise! ( :( )
local function keydataToKey(keydata)
	local idx = keydata.key
	if keydata.ctrl  then idx = idx + 256 end
	if keydata.shift then idx = idx + 512 end
	if keydata.alt   then idx = idx + 1024 end
	//if keydata.onrelease then idx = idx + 2048 end
	return "" .. idx
end



local function keyToKeydata(key)
	local num = tonumber(key) or Error("Could not convert Keyboard table key " .. key .. " to a number!")
	local ret = {}
	
	/*
	if num > 2048 then
		ret.onrelease = true
		num = num - 2048
	end
	//*/
	
	if num > 1024 then
		ret.alt = true
		num = num - 1024
	end
	
	if num > 512 then
		ret.shift = true
		num = num - 512
	end
	
	if num > 256 then
		ret.ctrl = true
		num = num - 256
	end
	
	ret.key = num
	
	return ret
end



/**
	Add a key bind to the Keyboard
	Args;
		keydata	Table (key, [ctrl, shift, alt])
			table of key data.
			example: CTRL+A -> {key=KEY_A, ctrl=true}
		func	Function
			function to bind to the key
	Return:	Function
		the passed function
 */
function this.AddBind(keydata, func)
	local idx = keydataToKey(keydata)
	local tbl = this.binds[idx]
	
	if !tbl then
		tbl = {}
		this.binds[idx] = tbl
		this.binddata[tbl] = table.Copy(keydata)
	end
	
	tbl[func] = true
	
	return func
end



/**
	Gets all binds for a certain key combo.
	Args;
		keydata	Table (key, [ctrl, shift, alt])
			table of key data.
			example: CTRL+A -> {key=KEY_A, ctrl=true}
		returnref	Boolean
			true to return internal function map, else return array of functions
	Return: Table
		table of bind functions as lookup table (if returnref) or array (otherwise)
 */
function this.GetBinds(keydata, returnref)
	local idx = keydataToKey(keydata)
	local ret = this.binds[idx]
	
	if returnref or !ret then return ret end
	
	local ret2 = {}
	for k, _ in pairs(ret) do
		ret2[#ret2+1] = k
	end
	
	return ret2
end



/**
	Remove a key bind from the Keyboard, or all binds to a key combo.
	Args;
		keydata	Table (key, [ctrl, shift, alt])
			table of key data.
			example: CTRL+A -> {key=KEY_A, ctrl=true}
		func	Function
			function to bind to the key, or nil to remove all binds
	Return:	Function OR Table
		if no binds exist then nil is returned
		if removing a single function, returns that function if found otherwise nil
		if removing all binds to a key, returns the table of funcs (as a lookup table)
 */
function this.RemoveBind(keydata, func)
	local idx = keydataToKey(keydata)
	local tbl = this.binds[idx]
	
	if !tbl then return nil end
	if func then
		if tbl[func] then
			tbl[func] = nil
			if #tbl == 0 then
				this.binds[idx] = nil
				this.binddata[tbl] = nil
			end
			return func
		end
		return nil
	else
		this.binds[idx] = nil
		this.binddata[tbl] = nil
		return tbl
	end
end



/**
	Checks if key combo was pressed or released this frame.  if so, calls binds
	Required because KEY_* enums are only compatible with input.IsKeyDown
 */
function this.DoThink()
	local keydata, matched
	local ctrl, alt, shift = input.IsKeyDown(KEY_LCONTROL) or nil, input.IsKeyDown(KEY_LALT) or nil, input.IsKeyDown(KEY_LSHIFT) or nil
	
	for k, bind in pairs(this.binds) do
		matched = true
		keydata = this.binddata[bind]
		if !keydata then /*PrintTable(this.binds) Msg("\n") PrintTable(this.binddata)*/ Error("Keyboard binds without associated bind data! " .. k .. "\n") end
		
		if     keydata.ctrl != ctrl          then matched = false 
		elseif keydata.alt != alt            then matched = false 
		elseif keydata.shift != shift        then matched = false 
		elseif !input.IsKeyDown(keydata.key) then matched = false end
		
		if matched then
			if !this.pressed[k] then // no spam tyvm
				this.pressed[k] = true
				for func, _ in pairs(bind) do
					func()
				end
			end			
		else
			this.pressed[k] = nil
		end
		
	end
	
end
hook.Add("Think", "holopad keyboard thinktime", this.DoThink)




/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Savefile Library
	splambob@gmail.com	 |_| 07/08/2012               

	Library of functions for saving to and loading from Holopad Project v2 files.
	
//*/


include("holopad/serialize/PRJ/folder.lua")


Holopad.PRJ = {}
local lib = Holopad.PRJ
local PRJVERSION = 3


/**
	Save a Model to file in the Holopad PRJ format
	Args;
		modelobj	Holopad.Model
			the model to save
		filename	String
			the filepath to save to
		overwrite	Boolean
			true for permission to overwrite existing files, else false
 */
function lib.Save( modelobj, path, overwrite )

	if (!overwrite && file.Exists(path, "DATA")) then Error("Unable to save to PRJ; \"" .. path .. "\" already exists!") return false end

	local sublib = Holopad["PRJ"..PRJVERSION]	// save as latest
	if !sublib then Error("No serializer for PRJ version " .. PRJVERSION .. "!") return false end
	Msg("Saving as PRJ"..PRJVERSION.."...\n")
	return sublib.Save(modelobj, path, overwrite)
	
end






local function parseversion(header)
	local vers = string.match(header, "^HOLOPAD PRJ (%d+)$")
	if !vers or vers == "" then return nil end
	return vers
end


local function badfile(projfile)
	ErrorNoHalt(projfile.." is not a valid Holopad project file!  It might be corrupted (or very old)!  Send this file to Bubbus!\n")
	return false
end


local function badversion(projfile, version)
	ErrorNoHalt(projfile.." is version \""..version.."\" but this loader is for version "..PRJVERSION.."!\n")
	ErrorNoHalt("Tell Bubbus to add backwards-compatibility for PRJ files!\n")
	return false
end

/**
	Load a PRJ file into a new or provided Model.
	Args;
		projfile	String
			the filepath to load from
		addto	Holopad.Model
			the Model to load into, or nil for a new model
	Return: Boolean
		the model containing the loaded scene
 */
function lib.Load(projfile, addto)
	
	//local projfile = file.Open("holopad/"..projfile..".txt", "r", "DATA")
	if !projfile then return false end
	
	//local content = projfile:Read(projfile:Size())
	local content = file.Read(projfile, "DATA")
	if !content then Error(projfile.." does not exist!") return end
	
	local conttable = string.Explode("\n", content)
	if #conttable <= 1 then return badfile(projfile) end
	
	local vers = parseversion(conttable[1])
	
	if !vers then return badfile(projfile) end
	
	local sublib = Holopad["PRJ"..vers]
	if !sublib then return badfile(projfile) end
	
	Msg("Loading as PRJ"..vers.."...\n")
	return sublib.Load(projfile, addto)
	
end




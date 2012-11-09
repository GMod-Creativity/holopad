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

include("holopad/serialize/vonGMOD.lua")
include("holopad/serialize/lib_common.lua")

Holopad.PRJ3 = {}
local lib = Holopad.PRJ3
local commons = Holopad.Serialize

local PRJVERSION = 3


/**
	Save a Model to file in the Holopad PRJ3 format
	Args;
		modelobj	Holopad.Model
			the model to save
		filename	String
			the filepath to save to
		overwrite	Boolean
			true for permission to overwrite existing files, else false
 */
function lib.Save( modelobj, path, overwrite )

	local ordered = commons.modelToList(modelobj)
	local formatted = commons.listToTables(ordered)

	//local savefile = file.Open("holopad/"..filename..".txt", "w", "DATA")
	//print("savefile is "..tostring(savefile))
	//if !savefile then return false end
	//*
	savefile = {Write = function(self, txt) self[#self+1] = txt end}
	local status = pcall( 	function()
								savefile:Write( "HOLOPAD PRJ "..PRJVERSION.."\n" )
								savefile:Write( von.serialize(formatted) )
							end )
					
	if !status then
		Error("Unable to save the Holopad project; error encoding the Model!")
		return false
	end
	
	//savefile:Close()
	savefile.Write = nil
	file.CreateDir(string.match(path, "^(.*/)[^/]*$"))
	file.Write(path, table.concat(savefile))

	return true
	//*/
end




local function badfile(projfile)
	ErrorNoHalt(projfile.." is not a valid Holopad project file!  It might be corrupted (or very old)!\n")
	return false
end



local function badversion(projfile, version)
	ErrorNoHalt(projfile.." is version \""..version.."\" but this loader is for version "..PRJVERSION.."!\n")
	ErrorNoHalt("Tell Bubbus to add backwards-compatibility for PRJ files!\n")
	return false
end



local create = {}
create.Entity		= function(ent)
	local pos	= ent.pos or Vector(0,0,0)
	local ang	= ent.ang or Angle(0,0,0)
	local name	= ent.name or ""
	return Holopad.Entity:New(pos, ang, name)
end
create.StaticEnt	= function(ent)
	local pos		= ent.pos or Vector(0,0,0)
	local ang		= ent.ang or Angle(0,0,0)
	local name		= ent.name or ""
	local model		= ent.model or Holopad.ERROR_MODEL
	local colour	= ent.colour or Holopad.COLOUR_DEFAULT()
	local material 	= ent.material
	return Holopad.StaticEnt:New(pos, ang, name, model, colour, material)
end
create.DynamicEnt	= function(ent)
	local pos		= ent.pos or Vector(0,0,0)
	local ang		= ent.ang or Angle(0,0,0)
	local name		= ent.name or ""
	local model		= ent.model or Holopad.ERROR_MODEL
	local colour	= ent.colour or Holopad.COLOUR_DEFAULT()
	local material 	= ent.material
	return Holopad.DynamicEnt:New(pos, ang, name, model, colour, material)
end
create.Hologram		= function(ent)
	local pos		= ent.pos or Vector(0,0,0)
	local ang		= ent.ang or Angle(0,0,0)
	local name		= ent.name or ""
	local model		= ent.model or Holopad.ERROR_MODEL
	local colour	= ent.colour or Holopad.COLOUR_DEFAULT()
	local material 	= ent.material
	local scale		= ent.scale or Vector(1,1,1)
	return Holopad.Hologram:New(pos, ang, name, model, colour, material, scale)
end
create.ClipPlane	= function(ent)
	local pos		= ent.pos or Vector(0,0,0)
	local ang		= ent.ang or Angle(0,0,0)
	local name		= ent.name or ""
	local model		= ent.model or Holopad.ERROR_MODEL
	local colour	= ent.colour or Holopad.COLOUR_DEFAULT()
	local material 	= ent.material
	local scale		= ent.scale or Vector(1,1,1)
	return Holopad.ClipPlane:New2(pos, ang, name, model, colour, material, scale)
end

local dynamics =
{
	DynamicEnt = true,
	Hologram = true,
	ClipPlane = true
}
/**
	Load a PRJ3 into a new or provided Model.
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
	//print("savefile is "..tostring(savefile))
	local content = file.Read(projfile, "DATA")
	local conttable = string.Explode("\n", content)
	
	local enttables = von.deserialize(table.concat(conttable, "\n", 2))
	
	local mdlobj = addto or Holopad.Model:New()
	
	local dyns = {}
	local cur, newent
	local entids = {}
	for i=1, #enttables do	// add all ents, store all dyns for further processing
		cur = enttables[i]
		
		if cur.type then
			//Msg(i, "\t", cur.type, "\t", cur.model, "\n")
			
			if dynamics[cur.type] then
				dyns[#dyns+1] = cur
			end
			
			newent = create[cur.type](cur)
			entids[cur.uid] = newent
			mdlobj:addEntity(newent)
		end
	end
	
	
	for i=1, #dyns do
		cur = dyns[i]
		if cur.parent then
			entids[cur.uid]:setParent(entids[cur.parent])
		end
	end
	
	return mdlobj
	
end




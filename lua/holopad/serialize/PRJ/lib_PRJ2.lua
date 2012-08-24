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

require "glon"

Holopad.PRJ2 = {}
local lib = Holopad.PRJ2
local PRJVERSION = 2


/**
	Save a Model to file in the Holopad PRJ2 format
	Args;
		modelobj	Holopad.Model
			the model to save
		filename	String
			the filepath to save to
		overwrite	Boolean
			true for permission to overwrite existing files, else false
 */
function lib.Save( modelobj, path, overwrite )

	local ordered = lib.modelToList(modelobj)
	local formatted = lib.listToTables(ordered)

	//local savefile = file.Open("holopad/"..filename..".txt", "w", "DATA")
	//print("savefile is "..tostring(savefile))
	//if !savefile then return false end
	//*
	savefile = {Write = function(self, txt) self[#self+1] = txt end}
	local status = pcall( 	function()
								savefile:Write( "HOLOPAD PRJ "..PRJVERSION.."\n" )
								savefile:Write( glon.encode(formatted) )
							end )
					
	if !status then
		Error("Unable to save the Holopad project; error encoding the Model!")
		return false
	end
	
	//savefile:Close()
	savefile.Write = nil
	file.Write(path, table.concat(savefile))

	return true
	//*/
end




local entToTable = {}
entToTable[Holopad.Entity]		= function(ent)
	local ret = {
		type	= "Entity",
		uid		= string.sub(tostring(ent), 8),
		name	= ent:getName(),
		pos		= ent:getPos(),
		ang		= ent:getAng()
	}
	return ret
end
entToTable[Holopad.StaticEnt]	= function(ent)
	local ret	= entToTable[Holopad.Entity](ent)
	ret.type	= "StaticEnt"
	ret.model	= ent:getModel()
	ret.colour	= ent:getColour()
	ret.material = ent:getMaterial()
	return ret
end
entToTable[Holopad.DynamicEnt]	= function(ent)
	local ret	= entToTable[Holopad.StaticEnt](ent)
	ret.type	= "DynamicEnt"
	ret.parent	= ent:getParent() and string.sub(tostring(ent:getParent()), 8)
	return ret
end
entToTable[Holopad.Hologram]	= function(ent)
	local ret	= entToTable[Holopad.DynamicEnt](ent)
	ret.type	= "Hologram"
	ret.scale	= ent:getScale()
	return ret
end
entToTable[Holopad.ClipPlane]	= function(ent)
	local ret	= entToTable[Holopad.DynamicEnt](ent)
	ret.type	= "ClipPlane"
	return ret
end
/**
	Returns a list of serialization-ready Entity representations, maintaining list order.
	Args;
		entlist	Table
			the list of Entities to convert into key-value tables
	Return: Table
		a list of key-value tables, representing Entities.
 */
function lib.listToTables(entlist)
	local ret = {}
	
	local cur
	for i=1, #entlist do
		cur = entlist[i]
		//Msg(i, "\t", cur:getModel(), "\n")
		ret[#ret+1] = entToTable[cur:class()](cur)
	end
	
	return ret
end




local function addToTree(parenttree, v)
	if !v:getParent() then
		parenttree[v] = {}
		return
	end
	
	local heirlist = {}
	local cur = v
	while cur != nil do
		heirlist[#heirlist+1] = cur
		cur = cur:getParent()
	end
	
	local curnode = parenttree
	for i=#heirlist, 1, -1 do
		cur = heirlist[i]
		if curnode[cur] then
			curnode = curnode[cur]
		else
			curnode[cur] = {}
			curnode = curnode[cur]
		end
	end
end
/**
	Returns a list of all Entities contained within modelobj, ordered such that a child never appears before its ancestors.
	Args;
		modelobj	Holopad.Model
			the Model to inspect
	Return: Boolean
		a list of all Entities contained within modelobj, ordered such that a child never appears before its ancestors.
 */
function lib.modelToList(modelobj)
	// TODO: optimise.  this is a naive approach (i think?)
	local parenttree = {}
	local all = modelobj:getAll()

	for k, v in pairs(all) do	// generate parent tree
		addToTree(parenttree, v)
	end
	
	local ret, agenda = {}, {}
	for k, v in pairs(parenttree) do	// prime the agenda (breadth-first traversal)
		agenda[#agenda+1] = {k, v}
	end
	
	local curind = 1, curval
	while agenda[curind] != nil do	// add all ents to ret.  breadth first ensures correct ordering
		curval = agenda[curind]
		for k, v in pairs(curval[2]) do
			agenda[#agenda+1] = {k, v}
		end
		ret[#ret+1] = curval[1]
		curind = curind+1
	end
	
	return ret

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
	Load a PRJ2 into a new or provided Model.
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
	local content = file.Read(projfile)
	local conttable = string.Explode("\n", content)

	local entities = conttable[2]
	local enttables = glon.decode(entities)
	
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




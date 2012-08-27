/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Serialization Commons
	splambob@gmail.com	 |_| 26/08/2012               

	Library of common serialization tasks.
	
//*/


Holopad.Serialize = {}
local lib = Holopad.Serialize



/**
	Takes an Entity and returns a table of kevalues describing it.
	Args;
		ent	Holopad.Entity
			the entity to describe
	Returns:	Table
		a table of kevalues describing the entity.
 */
lib.entToTable = {}
lib.entToTable[Holopad.Entity]		= function(ent)
	local ret = {
		type	= "Entity",
		uid		= string.sub(tostring(ent), 8),
		name	= ent:getName(),
		pos		= ent:getPos(),
		ang		= ent:getAng()
	}
	return ret
end
lib.entToTable[Holopad.StaticEnt]	= function(ent)
	local ret	= lib.entToTable[Holopad.Entity](ent)
	ret.type	= "StaticEnt"
	ret.model	= ent:getModel()
	ret.colour	= ent:getColour()
	ret.material = ent:getMaterial()
	return ret
end
lib.entToTable[Holopad.DynamicEnt]	= function(ent)
	local ret	= lib.entToTable[Holopad.StaticEnt](ent)
	ret.type	= "DynamicEnt"
	ret.parent	= ent:getParent() and string.sub(tostring(ent:getParent()), 8)
	return ret
end
lib.entToTable[Holopad.Hologram]	= function(ent)
	local ret	= lib.entToTable[Holopad.DynamicEnt](ent)
	ret.type	= "Hologram"
	ret.scale	= ent:getScale()
	return ret
end
lib.entToTable[Holopad.ClipPlane]	= function(ent)
	local ret	= lib.entToTable[Holopad.DynamicEnt](ent)
	ret.type	= "ClipPlane"
	ret.normal	= ent:getNormal()
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
		ret[#ret+1] = lib.entToTable[cur:class()](cur)
	end
	
	return ret
end




/**
	Used to build a parent tree using Entities.
	Tree takes the form of {Parent = {Children = {...}, ...}, ...}
	Args;
		parenttree	Table
			The tree so far
		v	Holopad.Entity
			The Entity to add to the table
 */
function lib.addToTree(parenttree, v)
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
	local parenttree = {}
	local all = modelobj:getAll()

	for k, v in pairs(all) do	// generate parent tree
		lib.addToTree(parenttree, v)
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





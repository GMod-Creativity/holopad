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
	Tree takes the form of {Parent = {Child	= {...}, ...}, ...}
	Args;
		parenttree	Table
			The tree so far
		v	Holopad.Entity
			The Entity to add to the tree
 */
function lib.addToTree(parenttree, v)
	//Msg("Adding " .. tostring(v) .. " to tree with parent " .. (v:getParent() and (tostring(v:getParent()) .. " (" .. v:getParent():getName() .. ")") or "nil") .. "\n")
	if !v:getParent() then
		if !parenttree[v] then
			parenttree[v] = {}
		end
		return
	end
	
	local heirlist = {}
	//local debug = {}
	local cur = v
	while cur != nil do
		heirlist[#heirlist+1] = cur
		//debug[#debug+1] = tostring(cur)
		cur = cur:getParent()
	end
	//Msg("\tHeirlist: " .. table.concat(debug, ", ") .. "\n")
	
	local curnode = parenttree
	for i=#heirlist, 1, -1 do
		cur = heirlist[i]
		//Msg("\t\tElement " .. i .. ": " .. tostring(cur) .. " (" .. cur:getName() .. ") in curnode " .. tostring(curnode) .. "\n")
		if curnode[cur] then
			curnode = curnode[cur]
			//Msg("\t\t\tAssigned " .. tostring(cur) .. " to " .. tostring(curnode) .. "\n")
		else
			curnode[cur] = {}
			//Msg("\t\t\tCreated " .. tostring(cur) .. " within " .. tostring(curnode) .. "\n")
			curnode = curnode[cur]
			//Msg("\t\t\tAssigned " .. tostring(cur) .. " to " .. tostring(curnode) .. "\n")
		end
		//Msg("\n")
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
	local exportables = #all

	for k, v in pairs(all) do	// generate parent tree
		if v.exportable then	// TODO: guarantee that non-exportables don't get exported due to exportable child
			lib.addToTree(parenttree, v)
		else
			print("Skipping non-exportable ent " .. v)
			exportables = exportables - 1
		end
	end
	
	//PrintTable(parenttree)
	
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
	
	if #ret != exportables then Error("SAVE ERROR: Input count does not match output count! (" .. #all .. " vs " .. #ret .. ")  Aborting...\n") end
	print(#all .. " vs " .. #ret)
	
	return ret
end





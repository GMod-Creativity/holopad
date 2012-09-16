/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | E2 I/O Library
	splambob@gmail.com	 |_| 26/08/2012               

	Library of functions for saving to and loading from E2 code.
	
//*/


include("holopad/serialize/lib_common.lua")


Holopad.E2 = {}
local lib = Holopad.E2
local commons = Holopad.Serialize


local ModelList = {
	["models/holograms/hq_tube_thick.mdl"]		= "hq_tube_thick",
	["models/holograms/hq_icosphere.mdl"]		= "hq_icosphere",
	["models/holograms/torus3.mdl"]				= "torus3",
	["models/holograms/prism.mdl"]				= "prism",
	["models/holograms/hexagon.mdl"]			= "hexagon",
	["models/holograms/hq_dome.mdl"]			= "hq_dome",
	["models/holograms/torus.mdl"]				= "torus",
	["models/holograms/cylinder.mdl"]			= "cylinder",
	["models/holograms/hq_torus_thick.mdl"]		= "hq_torus_thick",
	["models/holograms/cube.mdl"]				= "cube",
	["models/holograms/hq_hdome_thick.mdl"]		= "hq_hdome_thick",
	["models/holograms/hq_rcylinder_thin.mdl"]	= "hq_rcylinder_thin",
	["models/holograms/hq_stube_thick.mdl"]		= "hq_stube_thick",
	["models/holograms/hq_sphere.mdl"]			= "hq_sphere",
	["models/holograms/hq_stube_thin.mdl"]		= "hq_stube_thin",
	["models/holograms/cone.mdl"]				= "cone",
	["models/holograms/plane.mdl"]				= "plane",
	["models/holograms/icosphere3.mdl"]			= "icosphere3",
	["models/holograms/sphere.mdl"]				= "sphere",
	["models/holograms/hq_torus_oldsize.mdl"]	= "hq_torus_oldsize",
	["models/holograms/hq_hdome.mdl"]			= "hq_hdome",
	["models/holograms/right_prism.mdl"]		= "right_prism",
	["models/holograms/hq_tube_thin.mdl"]		= "hq_tube_thin",
	["models/holograms/hq_torus.mdl"]			= "hq_torus",
	["models/holograms/hq_rcube_thin.mdl"]		= "hq_rcube_thin",
	["models/holograms/hq_cubinder.mdl"]		= "hq_cubinder",
	["models/holograms/hq_hdome_thin.mdl"]		= "hq_hdome_thin",
	["models/holograms/hq_rcylinder_thick.mdl"] = "hq_rcylinder_thick",
	["models/holograms/hq_rcylinder.mdl"]		= "hq_rcylinder",
	["models/holograms/octagon.mdl"]			= "octagon",
	["models/holograms/hq_rcube_thick.mdl"]		= "hq_rcube_thick",
	["models/holograms/hq_torus_thin.mdl"]		= "hq_torus_thin",
	["models/holograms/hq_rcube.mdl"]			= "hq_rcube",
	["models/holograms/pyramid.mdl"]			= "pyramid",
	["models/holograms/hq_stube.mdl"]			= "hq_stube",
	["models/holograms/tetra.mdl"]				= "tetra",
	["models/holograms/sphere2.mdl"]			= "sphere2",
	["models/holograms/sphere3.mdl"]			= "sphere3",
	["models/holograms/torus2.mdl"]				= "torus2",
	["models/holograms/icosphere2.mdl"]			= "icosphere2",
	["models/holograms/hq_cylinder.mdl"]		= "hq_cylinder",
	["models/holograms/hq_cone.mdl"]			= "hq_cone",
	["models/holograms/icosphere.mdl"]			= "icosphere",
	["models/holograms/hq_tube.mdl"]			= "hq_tube"
}


local tab = "    "	// a tab in the E2 file.  E2 files are soft tabbed IIRC.

local header = 
[[@name %s

#####
# Holograms authored by %s on %s
# Exported from Holopad %s by Bubbus
# Thanks to Vercas for the original E2 export template!
#
# FOR AN EXPLANATION OF THE CODE BELOW, VISIT http://code.google.com/p/holopad/wiki/NewE2ExportFormatHOWTO
##### 

#####
# Hologram spawning data
@persist [Holos Clips]:table HolosSpawned HolosStep LastHolo TotalHolos
@persist E:entity
#####

]]

local part1 = 
[[if (first() | duped())
{
    E = entity()

    function number addHolo(Pos:vector, Scale:vector, Colour:vector4, Angles:angle, Model:string, Material:string, Parent:number)
    {
        if (holoRemainingSpawns() < 1) {error("This model has too many holos to spawn! (" + TotalHolos + " holos!)"), return 0}
        
        holoCreate(LastHolo, E:toWorld(Pos), Scale, E:toWorld(Angles))
        holoModel(LastHolo, Model)
        holoMaterial(LastHolo, Material)
        holoColor(LastHolo, vec(Colour), Colour:w())

        if (Parent > 0) {holoParent(LastHolo, Parent)}
        else {holoParent(LastHolo, E)}

        local Key = LastHolo + "_"
        local I=1
        while (Clips:exists(Key + I))
        {
            holoClipEnabled(LastHolo, 1)
            local ClipArr = Clips[Key+I, array]
            holoClip(LastHolo, I, holoEntity(LastHolo):toLocal(E:toWorld(ClipArr[1, vector])), holoEntity(LastHolo):toLocalAxis(E:toWorldAxis(ClipArr[2, vector])), 0)
            I++
        }
        
        return LastHolo
    }

    ##########
    # HOLOGRAMS
    
]]
	
	
local part2 = "    # Clip definitions"


local part3 = 
[[    
    ##########
    
    TotalHolos = Holos:count()
    if (%i > holoClipsAvailable()) {error("A holo has too many clips to spawn on this server! (Max is " + holoClipsAvailable() + ")")}
}


#You may place code here if it doesn't require all of the holograms to be spawned.


if (HolosSpawned)
{
    #Your code goes here if it needs all of the holograms to be spawned!
}
else
{
    while (LastHolo <= Holos:count() & holoCanCreate() & perf())
    {
        local Ar = Holos[LastHolo, array]
        addHolo(Ar[1, vector], Ar[2, vector], Ar[3, vector4], Ar[4, angle], Ar[5, string], Ar[6, string], Ar[7, number])
        LastHolo++
    }
    
    if (LastHolo > Holos:count())
    {
        Holos:clear()
        Clips:clear()
        HolosSpawned = 1
        E:setAlpha(0)
    }

    interval(1000)
}
]]



local function vecdef(vec)
	return string.format("vec(%.4f, %.4f, %.4f)", vec.x, vec.y, vec.z)
end

local function coldef(col)
	return string.format("vec4(%i, %i, %i, %i)", col.r, col.g, col.b, col.a)
end

local function angdef(ang)
	return string.format("ang(%.4f, %.4f, %.4f)", ang.p, ang.y, ang.r)
end

local function holodef(num, pos, scale, col, ang, model, mat, parentno, name)
	return string.format([[    #[ %s ]#    Holos[%i, array] = array(%s, %s, %s, %s, "%s", "%s", %s)]],
			(name and name != "") and name or " ",
			num,
			vecdef(pos),
			vecdef(scale or Vector(1, 1, 1)),
			coldef(col),
			angdef(ang),
			ModelList[string.lower(model)] or model,
			mat or "",
			parentno or 0)
end

local function clipdef(parentno, num, pos, norm)
	if !parentno or parentno < 1 then Error("Encountered orphaned ClipPlane during E2 generation!  Halting.\n") return end
	return string.format([[        Clips["%i_%i", array] = array(%s, %s)]],
			parentno,
			num,
			vecdef(pos),
			vecdef(norm))
end



/**
	Serialize a Model in executable E2 format.
	Args;
		modelobj	Holopad.Model
			the Model to convert
		filename	String
			the file name to save to, NOT the file PATH
		overwrite	Boolean
			false to fail if file already exists, true to overwrite any existing file
		options	Table
			list of option keyvalues which may affect the processng of the E2 code
			current flags are scale:number, name:string, author:string, date:string, version:string
 */
function lib.Save( modelobj, filename, overwrite, options )
	
	local path = filename//"Expression2/" .. filename .. ".txt"
	
	if (!overwrite && file.Exists(path)) then Error("Unable to export to E2; \"" .. path .. "\" already exists!\n") return false end

	print("Saving to " .. path.. " in the DATA directory")
	
	local ordered	= commons.modelToList(modelobj)
	local formatted	= commons.listToTables(ordered)

	local e2 = lib.tablesToE2(formatted, options)
	
	if !e2 then
		Error("Unable to export to E2; error writing to file!")
		return false
	end
	
	//savefile:Close()
	
	file.Write(path, e2)

	return true
	
end




/**
	Takes a list of tables representing Entities and creates E2 code which represents those Entities.
	Assumes that tables are ordered such that a child never appears before its parent.
	// TODO: spawn non-holos as holos.
	Args;
		tables	Table
			list of tables representing Entities
		options	Table
			keyvalues which may affect the processng of the E2 code
	Return; String
		the resulting E2 code
 */
function lib.tablesToE2(tables, options)
	options = options or {}
	
	local uidmap, holoclipmap, hololist = lib.generateHoloMaps(tables)
	
	local ret = {}
	ret.add = function(str) ret[#ret+1] = str end
	
	ret.add(string.format(header,
							options.name or "Holopad Export",
							options.author or "Unnamed",
							options.date or os.date("%d/%m/%Y"),
							options.version or Holopad.LAST_UPDATED))
							
	ret.add(part1)
	
	local scale = options.scale or 1
	local maxclips = 0
	local listmap = {}
	local cur, clips, clip, clipno
	for i=1, #hololist do
		cur = hololist[i]
		listmap[cur] = i
		ret.add(holodef(i, cur.pos*scale, cur.scale*scale, cur.colour, cur.ang, cur.model, cur.material, listmap[uidmap[cur.parent]], cur.name))
		
		clips = holoclipmap[cur]
		if clips then
			clipno = #clips
			if clipno > maxclips then maxclips = clipno end
			for j=1, clipno do
				clip = clips[j]
				ret.add(clipdef(listmap[uidmap[clip.parent]], j, clip.pos*scale, clip.normal))
			end
		end
	end

	ret.add(string.format(part3, maxclips))
	
	ret.add = nil
	return table.concat(ret, "\n")
end




/**
	Given a list of Entity representations in which no child is indexed lower than its parent, generate maps for use in generating E2 code for those Entities.
	Args;
		tables	Table
			the list to use in map generation.
	Returns;
		uidmap	Table
			maps uid -> enttable
		holoclipmap	Table
			maps Hologram -> ClipPlanes
		hololist	Table
			ordered list of Holograms only
 */
function lib.generateHoloMaps(tables)
	local uidmap = {}
	local holoclipmap = {}
	local hololist = {}

	local cur, parmap
	for i=1, #tables do
		cur = tables[i]
		uidmap[cur.uid] = cur
		
		if cur.type == "ClipPlane" then
			if !cur.parent then ErrorNoHalt("Encountered ClipPlane without parent Hologram!  Ignoring...")
			else
				parmap = holoclipmap[uidmap[cur.parent]]
				if !parmap then
					parmap = {}
					holoclipmap[uidmap[cur.parent]] = parmap
				end
				parmap[#parmap+1] = cur
			end
		elseif cur.type == "Hologram" then
			hololist[#hololist+1] = cur
		else
			ErrorNoHalt("Encountered a(n) " .. cur.type or "unknown" .. "!  Ignoring...")
		end
	end

	return uidmap, holoclipmap, hololist
end




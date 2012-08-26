/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | E2 I/O Library
	splambob@gmail.com	 |_| 27/07/2012               

	Library of functions for saving to and loading from E2 code.
	
//*/


Holopad.E2 = {}
local lib = Holopad.E2

local SCALE = 1

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


local maxHolos = ConVarExists("wire_holograms_burst_amount") and GetConVar("wire_holograms_burst_amount"):GetInt() or 0
local tab = "    "	// a tab in the E2 file.  E2 files are soft tabbed IIRC.



/**
	Serialize a Model in executable E2 format.
	Args;
		modelobj	Holopad.Model
			the Model to convert
		filename	String
			the file name to save to, NOT the file PATH
		overwrite	Boolean
			false to fail if file already exists, true to overwrite any existing file
 */
function lib.Save( modelobj, filename, overwrite )
	
	local path = filename//"Expression2/" .. filename .. ".txt"
	
	if (!overwrite && file.Exists(path)) then Error("Unable to export to E2; \"" .. path .. "\" already exists!") return false end

	print("saving to " .. path.. " in the DATA directory")
	/*
	local savefile = file.Open(path, "w", "DATA")
	print("savefile is "..tostring(savefile))
	if !savefile then return false end
	//*/
	
	local struct = lib.GetStructure(modelobj)
	local towrite = lib.GetWriteToE2(struct)
	
	if !towrite then
		Error("Unable to export to E2; error writing to file!")
		return false
	end
	
	//savefile:Close()
	
	file.Write(path, towrite)

	return true
	
end



/**
	Convert a Model into a table of Holograms, ClipPlanes, and Hologram-to-ClipPlane dependencies.
	Args;
		modelobj	Hologram.Model
			the Model to convert
	Return: Table {holos, clips, clipparents}
		the converted Model
 */
function lib.GetStructure(modelobj)		//TODO: check for clip limit!

	local ret = {holos = {}, clips = {}, clipparents = {}}
	
	for _, v in pairs(modelobj:getAll()) do
		if 		v:class() == Holopad.Hologram 	then
			ret.holos[#ret.holos+1] = v
		elseif 	v:class() == Holopad.ClipPlane then
			ret.clips[#ret.clips+1] = v
			local parent = v:getParent()
			if parent then
				if !ret.clipparents[parent] then
					ret.clipparents[parent] = {}
				end
				table.insert(ret.clipparents[parent], v)
			else
				Error("Unable to export to E2; encountered clip plane without a holo parent!")
			end
		end
	end
	
	return ret

end



local header =
"@name TEST\n\n## Modelled by %s, on %s\n## Exported from Holopad %s"

local beginfirst =
"\n\nif (first())\n{\n"..tab.."I=1\n"

local endfirst =
tab.."entity():setAlpha(0)\n}"

local incholo = 
"\n\n"..tab.."I++\n"

local clipcomment =
"\n\n"..tab..tab.."## Clips for %s\n\n"

local clipsbegin =
tab.."holoClipEnabled(I, 1)"

local clipsbegin2 =
tab..tab.."J=1\n"

local nextclip =
"\n\n"..tab..tab.."J++\n"



/**
	Given a table of holos, clips and holo-clip dependencies, write an E2 which describes them.
	Args;
		struct	Table {holos, clips, clipparents}
			a table of holos, clips and holo-clip dependencies
	Return: String
		the resulting E2 code
 */
function lib.GetWriteToE2(struct)

	local holos = struct.holos
	local clips = struct.clips
	local ret = {}
	ret.add = function(str) ret[#ret+1] = str end
	
	if maxHolos > 0 && #holos > maxHolos then
		Error("Unable to export to E2; hologram-count > wire_holograms_burst_amount is not yet supported!")
		return false
	end
	
	print("holos "..#holos)
	print("clips "..#clips)

	ret.add(header)	// TODO: string.format this

	ret.add(beginfirst)
	
	for _, v in pairs(holos) do
		lib.WriteHolo(ret, v)
		
		if struct.clipparents[v] then
			ret.add(clipsbegin)
			ret.add(string.format(clipcomment, v:getName()))
			ret.add(clipsbegin2)
			for _, w in pairs(struct.clipparents[v]) do
				lib.WriteClip(ret, w)
				ret.add(nextclip)
			end
			ret.add("\n")
		end
		
		ret.add(incholo)
	end
	
	ret.add(endfirst)

	ret.add = nil
	return table.concat(ret)
end



/**
	Given a clipping plane, write E2 code which describes it.
	Args;
		ret	Table
			the return-table to write partial code to.  must contain an add(String) function.
		clip	Holopad.ClipPlane
			the clipping plane to describe
	Return: ret
		the ret argument, which now has the clip serialization appended.
 */
// holoClip(N,N,V,V,N) 		Holo Index, Clip Index, Position, Direction, isGlobal.
// holoEntity(I):toLocal(...), isglobal = 0
// TODO: odd defects in clip: clip normal wrong?
function lib.WriteClip(ret, clip)

	local nam = clip:getName()
	//local mdl = string.lower(clip:getModel()) or Error("Unable to export to E2; a holo has an unsupported model!")
	local pos = clip:getPos()*SCALE
	local nrm = clip:getNormal()
	print(nam.."\t"..tostring(nrm).."\t"..tostring(clip:getAng()))

	ret.add(tab..tab.."## "..nam.."\n")
	//savefile:Write(tab..tab..string.format("holoClip(I, J, holoEntity(I):toLocal(entity():toWorld(vec(%.3f, %.3f, %.3f))), holoEntity(I):toLocal(entity():toWorld(vec(%.3f, %.3f, %.3f))), 0)", 
	ret.add(tab..tab..string.format("holoClip(I, J, holoEntity(I):toLocal(entity():toWorld(vec(%.6f, %.6f, %.6f))), holoEntity(I):toLocalAxis(entity():toWorldAxis(vec(%.6f, %.6f, %.6f))), 0)", 
					pos.x, pos.y, pos.z,	// position
					nrm.x, nrm.y, nrm.z))	// normal
					
	return ret

end



/**
	Given a hologram, write E2 code which describes it.
	Args;
		ret	Table
			the return-table to write partial code to.  must contain an add(String) function.
		clip	Holopad.Hologram
			the clipping plane to describe
	Return: ret
		the ret argument, which now has the hologram serialization appended.
 */
function lib.WriteHolo(ret, holo)

	local nam = holo:getName()
	local mdl = ModelList[string.lower(holo:getModel())] or string.lower(holo:getModel()) // standard or holomodelany?
	local pos = holo:getPos()*SCALE
	local ang = holo:getAng()
	local scl = holo:getScale()*SCALE
	local col = holo:getColour()	
	local mat = holo:getMaterial()
	
	ret.add(tab.."## "..nam.."\n")
	ret.add(tab.."holoCreate(I)\n")
	ret.add(tab.."holoModel(I, \""..mdl.."\")\n")
	ret.add(tab..string.format("holoPos(I, entity():toWorld(vec(%.6f, %.6f, %.6f)))\n", pos.x, pos.y, pos.z))
	ret.add(tab..string.format("holoAng(I, entity():toWorld(ang(%.6f, %.6f, %.6f)))\n", ang.p, ang.y, ang.r))
	ret.add(tab..string.format("holoScale(I, vec(%.6f, %.6f, %.6f))\n", scl.x, scl.y, scl.z))
	ret.add(tab..string.format("holoColor(I, vec(%i, %i, %i), %i)\n", col.r, col.g, col.b, col.a))
	if mat && mat != "" then
		ret.add(tab.."holoMaterial(I, \""..mat.."\")\n")
	end
	// TODO: parent heirarchy
	ret.add(tab.."holoParent(I, entity())\n")

	
	return ret
end



function lib.Load(filepath)
	
	// TODO: this
	Error("E2 importing is not supported yet!")
	return false
	
end
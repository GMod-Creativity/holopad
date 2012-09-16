/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Mirror Tool object
	splambob@gmail.com	 |_| 10/09/2012               

	The Mirror-Tool class.
	
	Portions of this code are replicated from the Precision Alignment tool, by Wenli (Published under the GNU GPLv3 license);
	http://sourceforge.net/projects/wenlistools/
	Such code is attributed by comment.
	
//*/
// TODO: ghost previews

include("holopad/model/utils/obj_UtilPlane.lua")


Holopad.Tools.Mirror, Holopad.Tools.MirrorMeta = Holopad.inheritsFrom(Holopad.Tool)
local this, meta = Holopad.Tools.Mirror, Holopad.Tools.MirrorMeta

this.icon = "holopad/tools/mirror"
this.name = "Mirror by Plane"
this.author = "Bubbus"
this.gui = "DMirrorTool_Holopad"

/**
	Constructor for the Holopad Tool object.
	Return:	Table (instance of Hologram.Tool)
 */
function this:New()

	local new = this:super():New()
	
	setmetatable(new, meta)
	
	new.modelUpdateListener = function(update) this.modelUpdateListener(new, update) end
	new.plane = Holopad.Utils.UtilPlane:New(nil, nil, Vector(4, 4, 4), "Mirror Plane")
	new.utils[new.plane] = true
	
	return new

end



/**
	Removes a Utility from the Tool.
	Args;
		util	Holopad.Utility
			the Utility to remove
		frommodel	Boolean
			if true, do not try to remove the utility from the model too.
 */
function this:RemoveUtility(util, frommodel)
	if util == self.plane then ErrorNoHalt("WARNING: Tried removing the mirror plane from the Mirror Tool!  Blocked.") return false end
	this:super().RemoveUtility(self, util)
end



/**
	Set the Model in use by this Tool.
	Args;
		model	Holopad.Model
			the model to be used.
 */
/*
function this:SetModelObj(mdl)
	this:super().SetModelObj(self, mdl)
	mdl:selectEnt(self.plane)
end
//*/



/**
	Set the centre position and normal of the mirror plane to the args, then modify the mirror plane Utility to match.
	Args;
		pos	Vector
			centre position of the mirror plane
		norm	Vector
			plane normal vector
 */
function this:SetPlaneData(pos, norm)
	self.plane:SetPos(pos)
	self.plane:SetAngles((norm:Angle():Up() * -1):Angle())	// thanks FPtje
end



function this:GetPlaneData()
	return self.pos, self.norm
end



function this:GetMirrorPlane()
	return self.plane
end



/**
	Clone the mirrored ents?
	Args;
		bool	Boolean
			true for clone else false
 */
function this:SetCloneEnts(bool)
	self.doclone = bool
end



// Mirror exception list - models which don't mirror correctly
// This array courtesy of Wenli, from the Precision Alignment tool
local PA_mirror_exceptions_specific = {
	// General
	["models/props_phx/construct/metal_plate1x2_tri.mdl"] = Angle(180,0,180),
	["models/props_phx/construct/metal_plate1_tri.mdl"] = Angle(180,0,180),
	["models/props_phx/construct/metal_plate2x2_tri.mdl"] = Angle(180,0,180),
	["models/props_phx/construct/metal_plate2x4_tri.mdl"] = Angle(180,0,180),
	["models/props_phx/construct/metal_plate4x4_tri.mdl"] = Angle(180,0,180),
	["models/props_phx/construct/plastic/plastic_angle_90.mdl"] = Angle(180,0,180),
	
	// Misc
	["models/hunter/misc/stair1x1inside.mdl"] = Angle(180,90,0),
	["models/hunter/misc/stair1x1outside.mdl"] = Angle(180,90,0),
	["models/props_phx/gibs/wooden_wheel1_gib2.mdl"] = Angle(0,180,0),
	["models/props_phx/gibs/wooden_wheel1_gib3.mdl"] = Angle(0,180,0),
	["models/props_phx/gibs/wooden_wheel2_gib1.mdl"] = Angle(0,180,0),
	["models/props_phx/gibs/wooden_wheel2_gib2.mdl"] = Angle(0,180,0),
	
	// Robotics
	// Most of these are (180,0,0) since it's easier to set the whole of robotics as (0,180,0) in exceptions 2
	["models/mechanics/robotics/foot.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/j1.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/j2.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/j3.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/j4.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/stand.mdl"] = Angle(180,0,0),
	["models/mechanics/robotics/xfoot.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/xfoot.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/j1.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/j2.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/j3.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/j4.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/claw2l.mdl"] = Angle(0,180,0),
	["models/mechanics/roboticslarge/clawl.mdl"] = Angle(0,180,0),
	["models/mechanics/robotics/claw.mdl"] = Angle(0,180,0),
	["models/mechanics/robotics/claw2.mdl"] = Angle(0,180,0),
	["models/mechanics/roboticslarge/claw_hub_8.mdl"] = Angle(180,0,0),
	["models/mechanics/roboticslarge/claw_hub_8l.mdl"] = Angle(180,0,0),
	
	// Solid Steel
	["models/mechanics/solid_steel/sheetmetal_90_4.mdl"] = Angle(0,-90,180),
	["models/mechanics/solid_steel/sheetmetal_box90_4.mdl"] = Angle(0,0,180),
	["models/mechanics/solid_steel/sheetmetal_h90_4.mdl"] = Angle(180,0,90),
	["models/mechanics/solid_steel/sheetmetal_t_4.mdl"] = Angle(0,0,180),
	
	// Specialized
	["models/props_phx/construct/metal_angle90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/metal_dome90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/metal_plate_curve.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/metal_plate_curve2x2.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/metal_wire_angle90x1.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/metal_wire_angle90x2.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/glass/glass_angle90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/glass/glass_curve90x1.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/glass/glass_curve90x2.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/glass/glass_dome90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/windows/window_angle90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/windows/window_curve90x1.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/windows/window_curve90x2.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/windows/window_dome90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_angle90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_curve90x1.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_curve90x2.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_dome90.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_wire_angle90x1.mdl"] = Angle(180,90,0),
	["models/props_phx/construct/wood/wood_wire_angle90x2.mdl"] = Angle(180,90,0),
	["models/hunter/misc/platehole1x1b.mdl"] = Angle(180,90,0),
	["models/hunter/misc/platehole1x1d.mdl"] = Angle(180,90,0),
	
	["models/hunter/tubes/tube1x1x1b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x1d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x2b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x2d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x3b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x3d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x4b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x4d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x5b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x5d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x6b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x6d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x8b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube1x1x8d.mdl"] = Angle(180,90,0),
	
	["models/hunter/tubes/circle2x2b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/circle2x2d.mdl"] = Angle(180,90,0),
	["models/hunter/plates/platehole1x1.mdl"] = Angle(180,90,0),
	["models/hunter/plates/platehole3.mdl"] = Angle(0,-90,0),
	
	["models/hunter/misc/shell2x2b.mdl"] = Angle(180,90,0),
	["models/hunter/misc/shell2x2d.mdl"] = Angle(180,90,0),
	["models/hunter/misc/shell2x2e.mdl"] = Angle(180,135,0),
	["models/hunter/misc/shell2x2x45.mdl"] = Angle(180,135,0),
	
	["models/hunter/tubes/tube2x2x025b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x025d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x05b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x05d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x1b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x1d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x2b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x2d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x4b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x4d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x8b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x8d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2x16d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube2x2xtb.mdl"] = Angle(0,0,180),
	
	
	["models/hunter/tubes/tubebend1x2x90b.mdl"] = Angle(90,180,0),
	["models/hunter/tubes/tubebendinsidesquare.mdl"] = Angle(-90,180,0),
	["models/hunter/tubes/circle4x4b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/circle4x4d.mdl"] = Angle(180,90,0),
	["models/hunter/misc/platehole4x4b.mdl"] = Angle(180,90,0),
	["models/hunter/misc/platehole4x4d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x025b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x025d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x05b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x05d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x1b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x1d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x2b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x2d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x3b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x3d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x4b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x4d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x5b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x5d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x6b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x6d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x8b.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x8d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tube4x4x16d.mdl"] = Angle(180,90,0),
	["models/hunter/tubes/tubebend4x4x90.mdl"] = Angle(0,0,180),
	
	["models/hunter/triangles/025x025.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/05x05.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/075x075.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x2.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/3x3.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/4x4.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/5x5.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/6x6.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/7x7.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/8x8.mdl"] = Angle(180,-90,0),
	
	["models/hunter/plates/tri2x1.mdl"] = Angle(0,180,0),
	["models/hunter/plates/tri3x1.mdl"] = Angle(0,180,0),
	
	["models/hunter/triangles/05x05x05.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x05x05.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x05x1.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x1x1.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x1x2.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x1x3.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x1x4.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/1x1x5.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/2x1x1.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/2x2x1.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/2x2x2.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/3x2x2.mdl"] = Angle(0,0,180),
	["models/hunter/triangles/3x3x2.mdl"] = Angle(0,0,180),
	
	["models/hunter/triangles/1x1x1carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x1x1carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x2x1carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1x2carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x1x2carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x2x2carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1x4carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/2x2x4carved.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1x1carved025.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1x2carved025.mdl"] = Angle(180,-90,0),
	["models/hunter/triangles/1x1x4carved025.mdl"] = Angle(180,-90,0),
		
	["models/xqm/panel45.mdl"] = Angle(0,180,0),
	["models/xqm/panel90.mdl"] = Angle(180,0,90),
	
	["models/xqm/box2s.mdl"] = Angle(0,0,180),
	["models/xqm/box3s.mdl"] = Angle(0,0,180),
	["models/xqm/box4s.mdl"] = Angle(0,90,180),
	["models/xqm/boxtri.mdl"] = Angle(180,-90,0),
	
	["models/xqm/deg45.mdl"] = Angle(0,180,-45),
	["models/xqm/deg45single.mdl"] = Angle(0,180,-45),
	["models/xqm/deg90.mdl"] = Angle(0,180,-90),
	["models/xqm/deg90single.mdl"] = Angle(0,180,-90),
	
	// Transportation
	["models/props_phx/misc/propeller3x_small.mdl"] = Angle(0,120,180),
	["models/props_phx/huge/road_curve.mdl"] = Angle(0,180,0),
	["models/props_phx/trains/tracks/track_turn45.mdl"] = Angle(180,135,0),
	["models/props_phx/trains/tracks/track_turn90.mdl"] = Angle(180,90,0),
	
	// Geometric
	["models/hunter/geometric/hex025x1.mdl"] = Angle(0,0,180),
	["models/hunter/geometric/hex1x05.mdl"] = Angle(0,0,180),
	["models/hunter/geometric/para1x1.mdl"] = Angle(0,180,0),
	["models/hunter/geometric/pent1x1.mdl"] = Angle(0,0,180),
	
	// Vehicles
	["models/nova/airboat_seat.mdl"] = Angle(0,0,180),
	["models/nova/chair_office01.mdl"] = Angle(0,0,180),
	["models/nova/chair_office02.mdl"] = Angle(0,0,180),
	["models/nova/jeep_seat.mdl"] = Angle(0,0,180)
}

// This array courtesy of Wenli, 
local PA_mirror_exceptions = {
	["models/hunter/tubes/tubebend"] = Angle(180,0,-90),
	["models/hunter/plates/tri"] = Angle(0,0,180),
	["models/xqm/quad"] = Angle(0,180,0),
	["models/xqm/rhombus"] = Angle(0,180,0),
	["models/xqm/triangle"] = Angle(0,180,0),
	["models/phxtended/tri"] = Angle(180,90,0),
	["models/mechanics/robotics"] = Angle(0,180,0),
	["models/mechanics/solid_steel/steel_beam45"] = Angle(0,90,180),
	["models/mechanics/solid_steel/type_c_"] = Angle(0,90,180),
	["models/mechanics/solid_steel/type_d_"] = Angle(0,135,180),
	["models/mechanics/solid_steel/type_e_"] = Angle(0,180,0),
	["models/squad/sf_tris/sf_tri"] = Angle(180,90,0),
	["models/xqm/jettailpiece1"] = Angle(0,0,180),
	["models/xqm/jetwing2"] = Angle(0,180,0),
	["models/xqm/wing"] = Angle(0,0,180),
	["models/xeon133/racewheel/"] = Angle(0,0,180),
	["models/xeon133/racewheelskinny/"] = Angle(0,0,180)
}



local permitted = {}
permitted[Holopad.Hologram] = true
//permitted[Holopad.ClipPlane] = true
permitted[Holopad.DynamicEnt] = true

/**
	Mirror all selected ents across the mirror plane
	This function is derived from the mirror function in Wenli's Precision Alignment tool.
 */
function this:Apply()
// TODO: make this work on static ents if statics are ever used.
	
	if !self:GetModelObj() then Error("No model registered with the mirror tool!") return end
	
	print("Applying Mirror" .. (self.doclone and " with Cloning!" or "!"))
	
	local vec0, ang0, _ = Vector(0,0,0), Angle(), nil
	
	for k, ent in pairs(self:GetModelObj():getSelectedEnts()) do
		if permitted[ent:class()] then
		
			if self.doclone then
				ent = ent:cloneToModel(nil, self:GetModelObj(), true) or Error("Mirror-Clone failed on ent " .. ent)
			end
	
			local origin = self.plane:getPos()
			local normal = self.plane:getNormal()
			
			local pos = ent:getPos()
			local ang = ent:getAng()
			local model = string.lower(ent:getModel())
			local v = pos	// TODO: find a way of getting model centre - use viewport
			
			// Mirror angle
			// Filter through exceptions for ents that need to be rotated differently
			local exceptionang = PA_mirror_exceptions_specific[model]
			
			// Match left part of string
			// TODO: optimise common case (hologram check)
			if !exceptionang then
				for k, v in pairs( PA_mirror_exceptions ) do
					if string.match( model, "^" .. k ) then
						exceptionang = v
						break
					end
				end
			end
			
			local newang
			if exceptionang then
				_, newang = LocalToWorld( vec0, exceptionang, vec0, ang )
			else
				_, newang = LocalToWorld( vec0, Angle(180,0,0), vec0, ang )
			end
			
			newang:RotateAroundAxis( normal, 180 )
			
			// Rotate around v, same method as rotation function
			local localv
			if v == pos then
				ent:setAng(newang)
			else
				localv = WorldToLocal(v, ang0, pos, ang)
				ent:setAng(newang)
				pos = pos + ( v - LocalToWorld(localv, ang0, pos, newang) )
			end
			
			// Mirror position
			local length = normal:Dot(origin - v)
			local vec = normal * length * 2
			ent:setPos(pos + vec)
			
		end
	end
	
	return true
	
end




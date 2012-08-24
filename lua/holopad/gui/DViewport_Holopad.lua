/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Viewport Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Viewport which renders 3D models.
	
//*/

include("holopad/gui/obj_Transform3D2D.lua")
include("holopad/gui/DViewportStatLabel_Holopad.lua")

local PANEL = {}

AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )
AccessorFunc( PANEL, "overrideMat",		"OverrideMaterial")



/**
	Take all the updates which have occurred within the update event, and update this Viewport using them.
 */
Holopad.ViewportUpdates =
{
	added		=	function(self, ent)	self:AddViewModel(ent) end,
	
	removed		=	function(self, ent, model, update)	
						self:UnhideEnt(ent)
						self:RemoveViewModel(ent)
						if ent:instanceof(Holopad.ClipPlane) then
							self.EntModels[update.parentbefore].holoClips[ent] = nil
						end
					end,
					
	selected	=	function(self, ent, model, update)
						for _, v in pairs(self.ModelObj:getType(Holopad.ClipPlane)) do
							self:doClipVisibility(v)
						end

						local lvec = self.vCamPos - ent:getPos()
						local dir = self:GetDirVec()
						local distProjLvec = (lvec:Dot(dir)*dir):Length()
						
						self.vLookatPos = self.vCamPos + dir*distProjLvec
						self.camDist = distProjLvec
						
						//self:refreshGrid()
					end,
					
	deselected	=	function(self, ent, model, update)
						for _, v in pairs(self.ModelObj:getType(Holopad.ClipPlane)) do
							self:doClipVisibility(v)
						end
						
						//self:refreshGrid()
					end,
					
	pos			=	function(self, ent, model, update)	model:SetPos(update.pos) end,
	ang			=	function(self, ent, model, update)	model:SetAngles(update.ang) /*self:refreshGrid()*/ end,
	scale		=	function(self, ent, model, update)	self:SetScaleOf(model, update.scale) end,
	colour		=	function(self, ent, model, update)	model:SetColor(update.colour) end,
	material	=	function(self, ent, model, update)	model:SetMaterial(update.material) end,
	model		=	function(self, ent, model, update)	model:SetModel(update.model) end
}
local vpupdates = Holopad.ViewportUpdates


/*---------------------------------------------------------
	Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	if !ClientsideModel then Error("Can't create CSModels!") return end

	self.camDist = 100
	self.vCamPos = Vector(0, 0, 0)
	self.vLookatPos = Vector(0, 0, 10)
    self.DirectionalLight = {}
	self.overrideMat = nil
	self.showStats = false
	self.EntModels = {}
	self.HiddenLookup = {}
	self.FOVmod = 0.79	// TODO: remove the need for this.  required due to oddness.
	self.lastWide = self:GetWide()
	
    self:SetLookAt( Vector(0,0,0) )
    self:SetFOV( 70 )
	self:SetCamAng( Angle(30,210,0) )
    
    self:SetText( "" )
    
	//coloured lights
    self:SetAmbientLight( Color( 128, 128, 128 ) )
	self:SetDirectionalLight( BOX_FRONT,	Color( 255, 0, 0 ) )
	self:SetDirectionalLight( BOX_BACK,		Color( 0, 255, 255 ) )
	self:SetDirectionalLight( BOX_RIGHT,	Color( 0, 255, 0 ) )
	self:SetDirectionalLight( BOX_LEFT,		Color( 255, 0, 255 ) )
	self:SetDirectionalLight( BOX_TOP,		Color( 0, 0, 255 ) )
	self:SetDirectionalLight( BOX_BOTTOM,	Color( 255, 255, 0 ) )
	
	self.StatLabel = vgui.Create( "DViewportStatLabel_Holopad", self )
	self.StatLabel:SetViewport(self)
	self.StatLabel:SetPos(10, 27)
		
	self.modelUpdates = function(update)
		model = self.EntModels[update.ent]
		//print("an update!!!", update.ent, model)
		for a, b in pairs(update) do
			//print("", a, b)
			if vpupdates[a] then
				vpupdates[a](self, update.ent, model, update)
			//else
				//print("\t\tskipping "..a)
			end
		end
	end	
	
	self.grid = ClientsideModel( "models/hunter/plates/plate4x4.mdl", RENDERGROUP_BOTH )
	self.grid:SetNoDraw(true)
	self.grid:SetMaterial(Holopad.GridMaterial)
	self.grid.units = 16
	self.grid.unitsize = 11.864	// a phx unit is not exactly 12 units?!?!
	self:SetScaleOf(self.grid, Vector(1, 1, 0))
	self.griddisplay = true
	self:SetGridSize(Holopad.GridSize)
end



/**
	Set the Model in use by this Viewport instance.
	Args;
		model	Table (instance of Holopad.Model)
			the model to be used.
 */
function PANEL:SetModelObj(model)
	if self.ModelObj then
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(model), tostring(self))
	end
	self.ModelObj = model
	self.EntModels = {}
	self.StatLabel:SetModelObj(model)
	
	for k, v in pairs(model:getAll()) do
		self:AddViewModel(v)
	end
	
	hook.Add(Holopad.MODEL_UPDATE .. tostring(model), tostring(self), self.modelUpdates)
end




function PANEL:GetModelObj()
	return self.ModelObj
end



/**
	Adds a ClientsideModel to the Viewport which represents the passed StaticModel.
	Args;
		entity	Table (instance of Holopad.StaticModel)
			the Entity to represent
 */
function PANEL:AddViewModel(entity)
	
	if !entity:instanceof(Holopad.StaticEnt) then Error("Tried to add a non-model to this Viewport!") return end
	local model = ClientsideModel( entity:getModel(), RENDERGROUP_BOTH )
	if !model then model = ClientsideModel( "models/error.mdl", RENDERGROUP_BOTH ) end
	
	model:SetNoDraw(true)
	model:SetPos(entity:getPos())
	model:SetAngles(entity:getAng())
	model.origRenderBounds = model:GetRenderBounds()
	
	if entity:instanceof(Holopad.StaticEnt) then
		model:SetColor(entity:getColour())
		model:SetMaterial(entity:getMaterial())
		
		if entity:instanceof(Holopad.Hologram) then
			model.holoClips = {}
			self:SetScaleOf(model, entity:getScale())
			
			if entity:instanceof(Holopad.ClipPlane) then
				self.EntModels[entity:getParent()].holoClips[entity] = true	// invariant: clips cannot exist without parents => parent must exist
				if !self:getClipVisibility(entity) then self:HideEnt(entity) end
			end
		end
	end
	
	self.EntModels[entity] = model
	
end



/**
	Determines if the passed ClipPlane should be visible.
	Args;
		clip	Holopad.ClipPlane
			the clipPlane to check
	Return: Boolean
		true iff the ClipPlane should be displayed
 */
function PANEL:getClipVisibility(clip)
	local holo = clip:getParent()
	if self.HiddenLookup[holo] then /*print("parent hidden lookup is true")*/ return false end
	if self.ModelObj:isEntSelected(holo) or self.ModelObj:isEntSelected(clip) then /*print("selection holo clip", self.ModelObj:isEntSelected(holo), self.ModelObj:isEntSelected(clip))*/ return true end
	/*print("all false")*/
	return false
end



/**
	Unhides the passed ClipPlane if it should be visible, else hides it.
	Args;
		clip	Holopad.ClipPlane
			the clipPlane to hide/unhide
 */
function PANEL:doClipVisibility(clip)
	if self:getClipVisibility(clip) then
		self:UnhideEnt(clip)
	else
		self:HideEnt(clip)
	end
end



/**
	Removes from this viewport any ClientsideModel which represents the passed Entity.
	Args;
		entity	Table (instance of Holopad.Entity)
			the represented Entity
 */
function PANEL:RemoveViewModel(entity)
	local model = self.EntModels[entity]
	if model then
		model:Remove()
		self.EntModels[entity] = nil
	end
end



/**
	Set the scale of a ClientsideModel to the specified scale.
	Args;
		model	ClientsideModel
			the model to be scaled.
		scale	Vector
			the scale to apply, or nil to reset.
 */
function PANEL:SetScaleOf(model, scale)
	if !model then Error("Attempted to set scale of nil") return end
	if !scale or scale.x + scale.y + scale.z == 0 then
		scale = Vector(1, 1, 1)
	end
	
	model:SetModelScale(scale)	
	model.curModelScale = scale
	//model:SetRenderBounds(scale * model:OBBMaxs(), scale * model:OBBMins())

end



/**
	Get the size of the ClientsideModel associated with ent.
	Args;
		ent	Table (inherits Holopad.Entity)
			the ent associated to the tested CSModel
 */
function PANEL:GetSizeOf(ent)
	/*
	local mdl = self.EntModels[ent]
	if !mdl then Error("Tried getting the size of an ent which is not in this Viewport") return nil end
	
	local scale = mdl:GetModelScale()
	local min, max = mdl:WorldSpaceAABB()
	local size = max - min
	print(scale, size)
	return (scale * size)
	//*/
	local mdl = self.EntModels[ent]
	if !mdl then Error("Tried getting the size of an ent which is not in this Viewport") return nil end
	return mdl.origRenderBounds * mdl.curModelScale * 2//Vector(16, 16, 16)
end



/**
	Treats the argument as a point in 3D space, and returns the 2D projection of the point onto the Viewport.
	Args;
		vec	Vector
			the 3D point to project onto the Viewport screen.
	Return: Vector
		the 2D projection of vec onto the screen, relative to this Viewport.
 */
function PANEL:GetScreenVec(vec)
	local x, y = self:GetPos()
	local pos = Vector(x, y, 0)
	
	self.Transformer = self.Transformer or Holopad.Transform3D2D:New(self:GetCamPos(), self:GetLookAt(), 0, self:GetFOV()*self.FOVmod, self:GetWide())
	return self.Transformer:WorldToScreen( Vector(vec.x, vec.y, vec.z) )
end



/**
	Determines if the centre of ent is visible within this Viewport
	Args;
		ent	Table (inherits Holopad.Entity)
			the Entity to test
	Return;
		Boolean	true if ent is visible else false
		Vector	viewport screen position
 */
function PANEL:IsEntVisible(ent)
	if self.HiddenLookup[ent] then return false end
	
	local pos, success = self:GetScreenVec(ent:getPos())
	return success, pos
end



/**
	Prevent an ent from rendering in the viewport.
	Args;
		ent	Table (instance of Holopad.Entity)
			the Entity to hide
 */
function PANEL:HideEnt(ent)
	if self.HiddenLookup[ent] then return end
	if !table.HasValue(self.ModelObj:getAll(), ent) then Error("Tried to hide an ent which isn't in the Viewport") return end
	self.HiddenLookup[ent] = true
end



/**
	Re-enables an ent rendering in the viewport.
	Args;
		ent	Table (instance of Holopad.Entity)
			the Entity to unhide
 */
function PANEL:UnhideEnt(ent)
	self.HiddenLookup[ent] = nil
end



/**
	Re-enables all ent rendering in the viewport.
 */
function PANEL:UnhideAllEnts()
	self.HiddenLookup = {}
end



/**
	Return:	Table
		list of all unhidden ents in the viewport
 */
// TODO: optimise; cache return value until something changes
function PANEL:GetVisibleEnts()
	local all = self.ModelObj:getAll()
	local ret = {}
	
	for k, v in pairs(all) do
		if self:IsEntVisible(v) then 
			ret[#ret+1] = v
		end
	end
	
	return ret
end



/**
	Resets directional lighting, ambient lighting and material override to their default settings.
 */
function PANEL:resetRenderSettings()

	for i=0, 6 do
		self.DirectionalLight[ i ] = nil
	end
	
	self:SetAmbientLight( Color( 50, 50, 50 ) )
	self:SetOverrideMaterial(nil)

end



/**
	Set the colour of a unidirectional light in the Viewport.
	Args;
		box	Number (enum BOX_*)
			the light's id
		color	Color
			the colour to use, or nil to remove
 */
function PANEL:SetDirectionalLight(box, colour)
	// cut down on divisions in the paint function by doing them here.
    self.DirectionalLight[box] = colour and Color(colour.r/255, colour.g/255, colour.b/255) or nil
end



/**
	Set the FOV of this Viewport in degrees, clamped to reasonable values.
	Args;
		fov	Number
			the desired FOV
 */
function PANEL:SetFOV(fov)
	self.Transformer = nil
	self.fFOV = math.Clamp(fov, 1, 180)
end



/**
	Return:	Number
		the Viewport's current FOV
 */
function PANEL:GetFOV(withmod)
	return withmod and self.fFOV*self.FOVmod or self.fFOV
end



/**
	Set the world vector that the camera should look towards.
	Args;
		vec	Vector
			the desired look position
 */
function PANEL:SetLookAt(vec)
	self.Transformer = nil
	self.vLookatPos = vec
end



/**
	Return:	Vector
		the Viewport's look position
 */
function PANEL:GetLookAt()
	return self.vLookatPos
end



/**
	Set the world vector that the camera should be positioned at.
	Args;
		vec	Vector
			the desired position
 */
function PANEL:SetCamPos(vec)
	self.Transformer = nil
	self.vCamPos = vec
end



/**
	Return:	Vector
		the Viewport camera's position
 */
function PANEL:GetCamPos()
	return self.vCamPos
end



/**
	Return:	Boolean
		true if viewport stats are enables else false
 */
function PANEL:GetShowStats()
	return self.showStats
end



/**
	Toggles the viewport statistics display
 */
function PANEL:ToggleShowStats()
	self.showStats = !self.showStats
	self.StatLabel:Display(self.showStats)
end



/**   
	Sets camera angle and distance from the camera look position.
	Args;
		angle	Angle
			the desired camera angle
		dist	Number
			the desired camera distance from the look position.
 */
function PANEL:SetCamAng(angle, dist)
	
	dist = dist or self.camDist
	self.Transformer = nil
	self.reject = Angle(0, angle.y, angle.r)
	
	// if pitching > +-89.99... degrees, don't do that please.  wizardry because angles make me sad
	if math.acos(self.reject:Forward():Dot(angle:Forward())) > 1.57 then 
		return
	end
	
	if dist then self.camDist = dist end
	
	self.vCamPos = self.vLookatPos - angle:Forward()*self.camDist
	
end



/**
	Return: Angle
		the angle of the camera
 */
function PANEL:GetCamAng()
	return self:GetDirVec():Angle()
end



/**
	Return:	Vector
		the Viewport camera's direction vector
 */
function PANEL:GetDirVec()
	return (self.vLookatPos - self.vCamPos):Normalize()
end



/**
	Returns the Viewport camera's distance from its look position, or from an Entity
	Args;
		ent	Table (inherits Holopad.Entity)
			the Entity to measure distance from, or nil for look position distance
	Return:	Number
		the Viewport camera's distance from its look position or the Entity
 */
function PANEL:GetCamDist(ent)
	if !ent then return self.camDist end
	return (self:GetCamPos() - ent:getPos()):Length()
end



/**
	Should the grid be displayed?
	Args;
		bool	Boolean
			true to display grid, else hide grid
 */
function PANEL:ShowGrid(bool)
	self.griddisplay = bool
end



/**
	Return: CSModel
		the grid csmodel
 */
function PANEL:GetGrid()
	return self.grid
end



/**
	Set the grid separation in GLU
	Args;
		units	Number
			the distance between each successive grid point
 */
function PANEL:SetGridSize(units)
	Holopad.GridSize = units	// todo: proper OOP
	self.grid.cursize = units
	local scale = units / self.grid.unitsize
	self:SetScaleOf(self.grid, Vector(scale, scale, 0))
	
	//self:refreshGrid()
end



function PANEL:refreshGrid()  // TODO: more of this
	if !self.ModelObj or #self.ModelObj:getSelectedEnts(true) != 1 then
		self.grid:SetAngles(Angle(0,0,0))
		self.grid:SetPos(Vector(0,0,0))
	else
		local selent = self.ModelObj:getSelectedEnts()[1]
		self.grid:SetAngles(selent:getAng())
		//self.grid:SetPos(selent:getPos())
	end
end



/**
	Return: Number
		the current grid separation in GLU 
 */
function PANEL:GetGridSize()
	return self.grid.cursize
end





function PANEL:Think()
	local x = self:GetWide()
	if self.lastWide ~= x then self.Transformer = nil end
	self.lastWide = x
end



/*---------------------------------------------------------
	Name: Paint
---------------------------------------------------------*/
function PANEL:Paint(w, h)
    
    local x, y = self:LocalToScreen( 0, 0 )
	
    cam.Start3D(self.vCamPos, (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, self:GetSize())
    cam.IgnoreZ(true)
    
    render.SuppressEngineLighting(true)
    render.SetLightingOrigin(Vector())
    render.ResetModelLighting(self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255)
	
	local col, overmat
	
	if self.griddisplay then
		col = Holopad.GridColour()
		render.SetColorModulation(col.r/255, col.g/255, col.b/255)
		render.SetBlend(Holopad.GridAlpha/255)
		self.grid:DrawModel()
	end
	
	for k, v in pairs(self.EntModels) do
		if !self.HiddenLookup[k] then
			for i=0, 6 do
				col = self.DirectionalLight[i]
				if (col) then
					render.SetModelLighting(i, col.r, col.g, col.b)
				end
			end
		
			col = k:instanceof(Holopad.StaticEnt) and k:getColour() or Holopad.COLOUR_DEFAULT()
			render.SetColorModulation(col.r/255, col.g/255, col.b/255)
			render.SetBlend(col.a/255)
			
			self:doDrawModel(v)
		end
	end
    
    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()
    
end



function PANEL:doDrawModel(model)
	
	if model.holoClips then self:setupClipping(model) end
	
	if self.overrideMat then
		local overmat = model:GetMaterial()
		model:SetMaterial(self.overrideMat)
		model:DrawModel()
		model:SetMaterial(overmat)
	else
		model:DrawModel()
	end
	
	if model.holoClips then self:finishClipping(model) end
	
end


function PANEL:setupClipping(model)
	if table.Count( model.holoClips ) > 0 then
		render.EnableClipping( true )
		
		for clip, _ in pairs( model.holoClips ) do
			local origin = clip:getPos()
			local norm = clip:getNormal()
			
			/* // TODO: this
			if !clip:GetGlobal() then
				norm = self.mdl:LocalToWorld( norm ) - self.mdl:GetPos()
				origin = self.mdl:LocalToWorld( origin )
			end
			//*/
			
			render.PushCustomClipPlane( norm, norm:Dot( origin ) )
		end
	end
end



function PANEL:finishClipping(model)

	local nclips = table.Count( model.holoClips )
	
	if nclips > 0 then
		for i = 1, nclips do
			render.PopCustomClipPlane()
		end
		
		render.EnableClipping( false )
	end
end



derma.DefineControl( "DViewport_Holopad", "Displays 3D models", PANEL, "DButton" )



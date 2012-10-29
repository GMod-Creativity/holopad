/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | GlassPane Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Trnasparent panel which renders 2D overlays and captures mouse input.
	
//*/

include("holopad/gui/obj_Transform3D2D.lua")
include("holopad/gui/DViewportStatLabel_Holopad.lua")
include("holopad/mouse/obj_MouseHandler.lua")

local PANEL = {}

AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )
AccessorFunc( PANEL, "overrideMat",		"OverrideMaterial")



/*---------------------------------------------------------
	Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self.Viewport = nil
	self.Markers = {}
	self.LastMousePos = Vector()
	self.shouldDraw = true
	
	self:SetText("")
	
	self.MouseModeListener = function(newmode)
		self.MouseHandler:setActiveMode(newmode)
	end
end



/**
	Should the GlassPane draw things like markers and dongles?
	Args;
		bool	Boolean
			true to draw, else false
 */
function PANEL:ShouldDraw(bool)
	self.shouldDraw = bool
end



/**
	Return: Boolean
		true if the GlassPane is drawing, else false
 */
function PANEL:GetShouldDraw()
	return self.shouldDraw
end



/**
	Set the GlassPane's associated Viewport to the argument.
	Args;
		view	DViewport_Holopad
			Viewport to assign to this
 */
function PANEL:SetViewport(view)
	self.Viewport = view
end



/**
	Return: DViewport_Holopad
		the Viewport contained within this ViewPanel.
 */
function PANEL:GetViewport()
	return self.Viewport
end



/**
	Set the GlassPane's associated ViewPanel to the argument.
	Args;
		view	DViewPanel_Holopad
			Viewport to assign to this
 */
function PANEL:SetViewPanel(view)
	self.ViewPanel = view
end



/**
	Set the GlassPane's associated MouseHandler to the argument.
	Args;
		mouse	Table (instance of Holopad.MouseHandler)
			MouseHandler to assign to this
 */
function PANEL:SetMouseHandler(mouse)
	self.MouseHandler = mouse
end



/*---------------------------------------------------------
	Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	local x, y = self:CursorPos()
	local vec = Vector(x, y, 0)
    //self:DrawMarker(vec, 32, Color(255, 255, 255))
	self.MouseHandler:mousePressed(mcode, vec)
	self.LastMousePos = vec
	self:MouseCapture(true)
	
end



/*---------------------------------------------------------
	Name: OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnMouseReleased( mcode )

	local x, y = self:CursorPos()
	local vec = Vector(x, y, 0)
	self.MouseHandler:mouseReleased(mcode, vec)
	self.LastMousePos = vec
	self:MouseCapture(false)
	
end



/*---------------------------------------------------------
	Name: OnCursorMoved
---------------------------------------------------------*/
function PANEL:OnCursorMoved( x, y )

	local pos = Vector(x, y, 0)
	local delta = self.LastMousePos - pos
	self.MouseHandler:mouseMoved(pos, delta)
	self.LastMousePos = pos

end



/*---------------------------------------------------------
	Name: OnMouseWheeled
---------------------------------------------------------*/
function PANEL:OnMouseWheeled(delta)
	self.MouseHandler:mouseWheeled(delta)
end



/**
	Returns the size of the marker applied to ent by this GlassPane
	Args;
		ent	Table (instance of Holopad.Entity)
			Entity to determine marker size for
	Return: Number
		marker size
 */
function PANEL:GetMarkerSize(ent)
	local sizes		= self.Viewport:GetSizeOf(ent)
	local minobb	= math.min(math.abs(sizes.x), math.abs(sizes.y), math.abs(sizes.z))
	local dist		= self.Viewport:GetCamDist(ent)
	local size		= math.deg(math.atan(minobb / dist)) / self.Viewport:GetFOV()
	size = math.Clamp(size*self:GetWide()*0.8, 16, 128)
	return size
end



/**
	Returns the colour of the marker applied to ent by this GlassPane
	Args;
		ent	Table (instance of Holopad.Entity)
			Entity to determine marker colour for
	Return: Color
		marker colour
 */
function PANEL:GetMarkerColour(ent)
	if self.Viewport:GetModelObj():isEntSelected(ent) then return Color(255, 0, 0) end
	return Color(255, 255, 255)
end



function PANEL:Think()
	
end



/*---------------------------------------------------------
	Name: Paint
---------------------------------------------------------*/
function PANEL:Paint(w, h)

	if !self.shouldDraw then return end

	local visible, pos, size, size2, colour
	local objs = self.Viewport:GetModelObj():getAll()
	local x, y = self:CursorPos()
	local selectCand = Holopad.SelectMode:getSelectionCandidate(self, Vector(x, y, 0))
	local activemode = self.MouseHandler:getActiveMode()
	local model = self.Viewport:GetModelObj()
	if self.Viewport:GetModelObj():isEntSelected(selectCand) then selectCand = nil end
	
	table.sort(objs, function(a, b) return self.Viewport:GetCamDist(a) > self.Viewport:GetCamDist(b) end)
	
	for _, ent in ipairs(objs) do
		visible, pos = self.Viewport:IsEntVisible(ent)
		if visible then
			size = self:GetMarkerSize(ent)
			size2 = size/2
			colour = ent == selectCand and Color(255, 128, 0) or self:GetMarkerColour(ent)
			
			if activemode.Dongles and model:isEntSelected(ent) then
				colour.a = 128
				surface.SetDrawColor(colour)
				surface.SetTexture(Holopad.MODEL_MARKER_TEXTURE)
				surface.DrawTexturedRect(pos.x - size2, pos.y - size2, size, size)
				self:drawDongles(ent, activemode)
			else
				surface.SetDrawColor(colour)
				surface.SetTexture(Holopad.MODEL_MARKER_TEXTURE)
				surface.DrawTexturedRect(pos.x - size2, pos.y - size2, size, size)
			end
		end
	end
	
end




local function dongpos(view, dir, centrepos, dirpos)
	if !(centrepos && dirpos) then ErrorNoHalt("tried getting dongpos using a nil " .. (!centrepos and "centrepos" or "dirpos") .. " screenvector") return Vector(0, 0, 0) end
	local antidot = math.sin(math.acos(view:Dot(dir)))
	local posdiff = (dirpos - centrepos):GetNormalized()
	local pos = centrepos + posdiff*Holopad.DONGLE_LENGTH*antidot
	
	return pos
end


local function boundscheck(glasspane, pos)
	if pos.x < 0 or pos.y < 0 then return false end
	local bx, by = glasspane:GetSize()
	if pos.x > bx or pos.y > by then return false end
	return true
end
/**
	Returns the visibility and screen positions of an entity and its grabby dongles.
	Args;
		ent	Table (instance of Holopad.Entity)
			Entity to determine vis/poses for
		quickfail	Boolean
			if true, returns false if ent is not visible.  an optimization.
	Return: Table or Boolean
		table of vis/poses for dongles and ent, or boolean false if quickfailing and ent is not visible
 */
function PANEL:GetDongleInfo(ent, quickfail)
	local viewport = self.Viewport
	local view = viewport:GetDirVec()
	local pos = ent:getPos()
	local ang = self.MouseHandler:getActiveMode().DongleGridOrient and viewport:GetGrid():GetAngles() or ent:getAng()	// TODO: world orientation
	
	local ret = {}
	
	ret.EntPos, 	ret.EntVis		= viewport:GetScreenVec(pos)
	if quickfail and !ret.EntVis then return false end
	
	ret.DongUpPos,	ret.DongUpVis	= viewport:GetScreenVec(pos + ang:Up())
	if ret.DongUpVis then 
		ret.DongUpPos	= dongpos(view, ang:Up(), ret.EntPos, ret.DongUpPos)
		ret.DongUpVis	= boundscheck(self, ret.DongUpPos)
	end
	
	ret.DongRtPos,	ret.DongRtVis	= viewport:GetScreenVec(pos + ang:Right())
	if ret.DongRtVis then 
		ret.DongRtPos	= dongpos(view, ang:Right(), ret.EntPos, ret.DongRtPos)
		ret.DongRtVis	= boundscheck(self, ret.DongRtPos)
	end
	
	ret.DongFwPos,	ret.DongFwVis	= viewport:GetScreenVec(pos + ang:Forward())
	if ret.DongFwVis then 
		ret.DongFwPos	= dongpos(view, ang:Forward(), ret.EntPos, ret.DongFwPos)
		ret.DongFwVis	= boundscheck(self, ret.DongFwPos)
	end
	
	return ret, pos, ang
end
	
	
	
	
function PANEL:drawDongles(ent, mousemode)

	local texture = mousemode.DongleTextureID
	local dongs, cenpos, angs = self:GetDongleInfo(ent, true)	// TODO: world orientation
	
	if !dongs then return end
	
	//TODO: order by distance from camera
	if dongs.DongUpVis then
		self:drawDongleSingle(cenpos, angs:Up(),  Color(0,0,255), texture, dongs.EntPos, dongs.DongUpPos)
	end
	if dongs.DongRtVis then
		self:drawDongleSingle(cenpos, angs:Right(), Color(0,255,0), texture, dongs.EntPos, dongs.DongRtPos)
	end
	if dongs.DongFwVis then
		self:drawDongleSingle(cenpos, angs:Forward(), Color(255,0,0), texture, dongs.EntPos, dongs.DongFwPos)
	end
	
end




function PANEL:drawDongleSingle(cenpos, dir, colour, texture, screencen, screendong)
	
	dir = dir:GetNormalized()
	
	local x, y = self:CursorPos()
	local mvec = Vector(x,  y, 0)
	
	local centrepos = screencen
	local pos = screendong
	local donglen, dongrad = Holopad.DONGLE_LENGTH, Holopad.DONGLE_RADIUS
	
	local ang = 360 - (pos - centrepos):Angle().y - 90
	
	// debuggin'
	//surface.DrawCircle( centrepos.x, centrepos.y, 5, Color(255,255,255,255) ) 
	//surface.DrawCircle( dirpos.x, dirpos.y, 5, Color(255,0,255,255) ) 
	
	if mvec:Distance(pos) <= dongrad then
		// TODO: 
		//dongrad = dongrad*2
		//*
		surface.SetDrawColor(Color(0,0,0))
		surface.SetTexture(texture)

		surface.DrawTexturedRectRotated(pos.x+2, pos.y+2, 16, 16, ang)
		surface.DrawLine(centrepos.x+1, centrepos.y+1, pos.x+1, pos.y+1)
		//*/
		surface.SetDrawColor(colour)
		
		surface.DrawLine(centrepos.x, centrepos.y, pos.x, pos.y)
		surface.DrawTexturedRectRotated(pos.x, pos.y, 16, 16, ang)
	else
		//dongrad = dongrad*2
		//*
		surface.SetDrawColor(Color(0,0,0))
		surface.SetTexture(texture)
		
		surface.DrawTexturedRectRotated(pos.x+2, pos.y+2, 12, 12, ang)
		surface.DrawLine(centrepos.x+1, centrepos.y+1, pos.x+1, pos.y+1)
		//*/
		surface.SetDrawColor(colour)
		
		surface.DrawLine(centrepos.x, centrepos.y, pos.x, pos.y)
		surface.DrawTexturedRectRotated(pos.x+1, pos.y+1, 12, 12, ang)
	end	
end


derma.DefineControl( "DGlassPane_Holopad", "Takes mouse input and displays 2D overlays", PANEL, "DButton" )



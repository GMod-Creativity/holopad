/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | ViewPanel Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Viewport which renders 3D models and 2D overlays.
	
//*/

include("holopad/gui/DViewport_Holopad.lua")
include("holopad/gui/DBackground_Holopad.lua")
include("holopad/gui/DViewCornerButton_Holopad.lua")
include("holopad/gui/DGlassPane_Holopad.lua")

local PANEL = {}

AccessorFunc( PANEL, "showStats",		"ShowStats" )



/*---------------------------------------------------------
	Name: Init
---------------------------------------------------------*/
function PANEL:Init()	
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	local sx, sy = ScrW(), ScrH()
	sx = math.min(sx, sy)
	self.ContentX = 600 > sx and sx or 600
	self.ContentY = self.ContentX
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	//window init//
	self:SetTitle("Holopad 2; Viewport")
    self:SetSizable(true)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(false)
    
    self:SetMinWidth( 100 );
    self:SetMinHeight( 100 );
	self:SetSize( self.WindowX, self.WindowY )
	
    self:SetPaintBackgroundEnabled( false )
    self:SetPaintBorderEnabled( false )
    self:DockPadding( 5, 26, 5, 5 )
	
	self.MouseHandler = Holopad.MouseHandler:New(self)
	//self.MouseHandler:registerMode(Holopad.MouseMode:New(self))
	self.MouseHandler:registerMode(Holopad.CameraMode:New(self))
	self.MouseHandler:registerMode(Holopad.SelectMode:New(self))
	self.MouseHandler:registerMode(Holopad.MoveMode:New(self))
	self.MouseHandler:registerMode(Holopad.RotateMode:New(self))
	self.MouseHandler:registerMode(Holopad.ScaleMode:New(self))
	self.MouseHandler:setActiveMode("select")
	
	self.Background = vgui.Create( "DBackground_Holopad", self )
	self.Background:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.Background:SetSize( self.ContentX, self.ContentY )

	self.Viewport = vgui.Create("DViewport_Holopad", self.Background)
	self.Viewport:SetSize( self.Background:GetWide(), self.Background:GetTall() )
	self.Viewport:SetViewPanel(self)
	
	self.GlassPane = vgui.Create("DGlassPane_Holopad", self.Viewport)
	self.GlassPane:SetSize(self.Viewport:GetWide(), self.Viewport:GetTall())
	self.GlassPane:SetViewPanel(self)
	self.GlassPane:SetViewport(self.Viewport)
	self.GlassPane:SetMouseHandler(self.MouseHandler)
	
	self.CornerButton = vgui.Create("DViewCornerButton_Holopad" , self.GlassPane)
    self.CornerButton:SetViewPanel(self)
	
	self:MakePopup()
	
	self.OldThink = self.Think
	self.Think = function(self) self:OldThink() self:Think2() end
	
	self.ModelUpdateListener = function(upd)
		if upd.removed then
			self.ModelObj:deselectEnt(upd.ent)
		end
	end
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end



/**
	Return: DViewport_Holopad
		the Viewport contained within this ViewPanel.
 */
function PANEL:GetViewport()
	return self.Viewport
end



/**
	Return: DGlassPane_Holopad
		the GlassPane contained within this ViewPanel.
 */
function PANEL:GetGlassPane()
	return self.GlassPane
end



/**
	Return: Table (instance of Holopad.MouseHandler)
		the MouseHandler contained within this ViewPanel.
 */
function PANEL:GetMouseHandler()
	return self.MouseHandler
end



/**
	Set the Model in use by this ViewPanel instance.
	Args;
		model	Table (instance of Holopad.Model)
			the model to be used.
 */
function PANEL:SetModelObj(model)
	if self.ModelObj then
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.ModelObj), tostring(self.ModelUpdateListener))
	end
	self.ModelObj = model
	hook.Add(Holopad.MODEL_UPDATE .. tostring(self.ModelObj), tostring(self.ModelUpdateListener), self.ModelUpdateListener)
	self.Viewport:SetModelObj(model)
end



/**
	Return: Table (instance of Holopad.Model)
		the Model used by this ViewPanel.
 */
function PANEL:GetModelObj()
	return self.ModelObj
end




/**
	Resize the frame to fit within a rect of width x and height y.
	A resulting window size of x by y is not guaranteed.
	Args;
		x	Number
			the maximum horizontal width
		y	Number
			the maximum vertical height
 */
function PANEL:resizeFrame(x, y)

	x = x - self.PaddingX*2
	y = y - self.PaddingX*2 - self.TopBarHeight
	
	local minx, miny = self:GetMinWidth(), self:GetMinHeight()
	x = x < minx and minx or x
	y = y < miny and miny or y
	
	local min = x < y and x or y

	self.ContentX = min
	self.ContentY = min
	
	self.WindowX = min + self.PaddingX*2
	self.WindowY = min + self.PaddingY*2 + self.TopBarHeight
	
	self:SetSize(self.WindowX, self.WindowY)
	self.Background:SetSize(min, min)
	self.GlassPane:SetSize(min, min)
	self.Viewport:SetSize(min, min)
	
end



/**
	Called after the panel's think function.  DO NOT INVOKE.
 */
function PANEL:Think2()
	local x, y = self:GetWide(), self:GetTall()
	if self.WindowX == x && self.WindowY == y then return end
	
	self:resizeFrame(x, y)
end


derma.DefineControl( "DViewPanel_Holopad", "Contains DViewport, DGlassPane and a menu button.", PANEL, "DFrame" )



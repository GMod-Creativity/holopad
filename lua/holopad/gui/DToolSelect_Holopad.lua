/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Material Selection Panel
	splambob@gmail.com	 |_| 24/08/2012               

	Panel for selecting and returning material paths.
	Original code by Garry, modified lightly.
	
//*/


local PANEL = {}

AccessorFunc( PANEL, "ItemWidth",			"ItemWidth", 	FORCE_NUMBER )
AccessorFunc( PANEL, "ItemHeight",			"ItemHeight", 	FORCE_NUMBER )
AccessorFunc( PANEL, "Height",				"NumRows", 		FORCE_NUMBER )
AccessorFunc( PANEL, "m_bSizeToContent",	"AutoHeight", 	FORCE_BOOL )

/*---------------------------------------------------------
   Name: This function is used as the paint function for 
		   selected buttons.
---------------------------------------------------------*/
local function HighlightedButtonPaint( self )

	surface.SetDrawColor( 255, 200, 0, 255 )
	
	for i=2, 3 do
		surface.DrawOutlinedRect( i, i, self:GetWide()-i*2, self:GetTall()-i*2 )
	end

end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)

	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 158, 235
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight

	self:SetSize(self.WindowX, self.WindowY)
	
	// A panellist is a panel that you shove other panels
	// into and it makes a nice organised frame.
	self.List = vgui.Create( "DPanelList", self )
		self.List:EnableHorizontal( true )
		self.List:EnableVerticalScrollbar()
		self.List:SetSpacing( 5 )
		self.List:SetPadding( 5 )
		self.List:SetSize(self.ContentX, 158)
		self.List:SetPos(self.PaddingX, self.PaddingY + self.TopBarHeight)
	
	self.Controls 	= {}
	self.Height		= 2
	
	self:SetItemWidth( 32 )
	self:SetItemHeight( 32 )
	
	self:ControlValues()
	
	
	self.toolicon = vgui.Create("DImage", self)
	self.toolicon:SetSize(32, 32)
	self.toolicon:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 168)
	self.toolicon:SetImage( Holopad.Tool.icon )
	
	self.toolname = vgui.Create("DLabel", self)
	self.toolname:SetPos(self.PaddingX + 45, self.PaddingY + self.TopBarHeight + 168)
	self.toolname:SetText("Tool: ")
	self.toolname:SizeToContents()
	
	self.toolauthor = vgui.Create("DLabel", self)
	self.toolauthor:SetPos(self.PaddingX + 45, self.PaddingY + self.TopBarHeight + 183)
	self.toolauthor:SetText("Author: ")
	self.toolauthor:SizeToContents()
	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 208)
	
	
	self:SetTitle("Holopad 2; Tool Dialogue")
	self:Center()
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	
	self.Close = 	function(self)
						local callback, status, tool, gooey, success = self.callback, self.exitStatus, self.exitTool, nil, false
						oldclose(self)
						
						if status then
							success, gooey = pcall(function() return vgui.Create( tool.gui, self:GetParent() ) end)
							if !success then
								ErrorNoHalt("Was not able to create the GUI for " .. tool.name .. "! (" .. tool.gui .. ")")
								status = false
								gooey = nil
								tool = nil
							else
								tool = tool:New()
							end
						end
						
						if callback then
							callback(status, gooey, tool)
						end
					end
					
	self.exitStatus = false
	self.exitTool = nil
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	

end


function PANEL:SetCallback(func)
	self.callback = func
end



function PANEL:doneButtonClicked()
	local sel = self.exitTool
	
	if !sel or sel == "" then
		self.doneButton:SetText("No tool selected!")
		timer.Simple(3, function() self.doneButton:SetText("Done!") end)
		return
	end
	
	if self.callback then
		self.exitStatus = true
		self:Close()
	end
end


/*---------------------------------------------------------
   Name: SetAutoHeight
---------------------------------------------------------*/
function PANEL:SetAutoHeight( bAutoHeight )

	self.m_bSizeToContent = bAutoHeight
	self.List:SetAutoSize( bAutoHeight )
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: SetItemSize
---------------------------------------------------------*/
function PANEL:SetItemSize( pnl )

	local w = self.ItemWidth
	if ( w < 1 ) then w = ( self:GetWide() - self.List:GetPadding()*2 ) * w end
	
	local h = self.ItemHeight
	if ( h < 1 ) then h = ( self:GetWide() - self.List:GetPadding()*2 ) * h end
	
	pnl:SetSize( w, h )

end

/*---------------------------------------------------------
   Name: AddMaterialEx
---------------------------------------------------------*/
function PANEL:AddTool( key, tool )

	// Creeate a spawnicon and set the model
	local Mat = vgui.Create( "DImageButton", self )
	Mat:SetOnViewMaterial( tool.icon, "models/wireframe" )
	Mat.AutoSize = false
	Mat.Value = tool
	self:SetItemSize( Mat )
	Mat:SetToolTip( tool.name .. " by " .. tool.author )
	
	// Run a console command when the Icon is clicked
	Mat.DoClick = 	function(button)
						self.exitTool = tool
						self.toolname:SetText("Tool: " .. tool.name)
						self.toolname:SizeToContents()
						self.toolauthor:SetText("Author: " .. tool.author)
						self.toolauthor:SizeToContents()
						self.toolicon:SetImage(tool.icon)
					end

	// Add the Icon us
	self.List:AddItem( Mat )
	table.insert( self.Controls, Mat )
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: ControlValues
---------------------------------------------------------*/
function PANEL:ControlValues()
	
	for k, v in pairs( Holopad.Tools ) do
		if v.isTool then
			self:AddTool( k, v )
		end
	end
	
	for k, v in pairs( self.Controls ) do
		v:SetSize( self.ItemWidth, self.ItemHeight )
	end
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
/*
function PANEL:PerformLayout()

end
//*/


/*---------------------------------------------------------
   Name: FindAndSelectMaterial
---------------------------------------------------------*/
function PANEL:FindAndSelectMaterial( Value )

	self.CurrentValue = Value

	for k, Mat in pairs( self.Controls ) do
	
		if ( Mat.Value == Value ) then
		
			// Remove the old overlay
			if ( self.SelectedMaterial ) then
				self.SelectedMaterial.PaintOver = nil
			end
			
			// Add the overlay to this button
			Mat.PaintOver = HighlightedButtonPaint;
			self.SelectedMaterial = Mat

		end
	
	end

end

/*---------------------------------------------------------
   Name: TestForChanges
---------------------------------------------------------*/
function PANEL:TestForChanges()
	
	if ( Value == self.CurrentValue ) then return end
	
	self:FindAndSelectMaterial( Value )

end



function PANEL:Think()

	if ( self.NextPoll && self.NextPoll > CurTime() ) then return end
	
	self.NextPoll = CurTime() + 0.1
	
	self:TestForChanges()

end


derma.DefineControl( "DToolSelect_Holopad", "A Tool Dialogue", PANEL, "DFrame" )
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
	self.ContentX, self.ContentY	= 296, 480
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight

	self:SetSize(self.WindowX, self.WindowY)
	
	// A panellist is a panel that you shove other panels
	// into and it makes a nice organised frame.
	self.List = vgui.Create( "DPanelList", self )
		self.List:EnableHorizontal( true )
		self.List:EnableVerticalScrollbar()
		self.List:SetSpacing( 8 )
		self.List:SetPadding( 8 )
		self.List:SetSize(self.ContentX, 415)
		self.List:SetPos(self.PaddingX, self.PaddingY + self.TopBarHeight)
	
	self.Controls 	= {}
	self.Height		= 2
	
	self:SetItemWidth( 128 )
	self:SetItemHeight( 128 )
	
	self:ControlValues()
	
	
	self.text = vgui.Create("DTextEntry", self)
	self.text:SetWidth(self.ContentX - 10)
	self.text:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 425)
	self.text:SetEditable(false)
	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 450)
	
	
	self:SetTitle("Holopad 2; Material Dialogue")
	/*
	local parent	 = self:GetParent()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	self:SetPos(parx + pwidth/2 - self:GetWide()/2, pary)
	self:MoveBelow(parent, 1)
	//*/
	self:Center()
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	
	self.Close = 	function(self)
						local callback, status, path = self.callback, self.exitStatus, self.exitEntity
						oldclose(self)
						if callback then
							callback(status, path)
						end
					end
					
	self.exitStatus = false
	self.exitEntity = nil
	
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
	local sel = self.exitEntity
	
	if !sel or sel == "" then
		self.doneButton:SetText("No material selected!")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
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
function PANEL:AddMaterialEx( label, material )

	// Creeate a spawnicon and set the model
	local Mat = vgui.Create( "DImageButton", self )
	Mat:SetOnViewMaterial( material, "models/wireframe" )
	Mat.AutoSize = false
	Mat.Value = material
	self:SetItemSize( Mat )
	Mat:SetToolTip( material )
	
	// Run a console command when the Icon is clicked
	Mat.DoClick = 	function(button)
						self.exitEntity = material
						self.text:SetText(material)
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
	
	for k, v in pairs( list.Get( "OverrideMaterials" ) ) do
		self:AddMaterialEx( k, v )
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


derma.DefineControl( "DMatSelect_Holopad", "A Material Dialogue", PANEL, "DFrame" )
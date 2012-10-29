/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | File Dialogue Derma
	splambob@gmail.com	 |_| 30/08/2012               

	Dialogue for modifying savefile options.
	
//*/


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 250, 120
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	
	
	self:SetSize(self.WindowX, self.WindowY)
	
	local panel = vgui.Create("DPanel")
	panel.Paint = function() end
	panel:SetSize(self.ContentX, self.ContentY-22)
	
	local categoryList = vgui.Create( "DPanelList" )
	categoryList:SetAutoSize( true )
	categoryList:SetSpacing( 5 )
	categoryList:EnableHorizontal( false )
	categoryList:EnableVerticalScrollbar( false )
	
	local category = vgui.Create("DCollapsibleCategory", self)
	category:SetSize( self.ContentX, self.ContentY )
	category:SetPos(self.PaddingX, self.PaddingY + self.TopBarHeight)
	category:SetExpanded( 1 )
	category:SetLabel( "Savefile Options" )
	category.Header:SetMouseInputEnabled(false)
	category:SetContents(categoryList)
	category:SetTall(self.ContentY)
	
	
	local ypos = 5
	
	
	local toplabel = vgui.Create("DLabel", panel)
	toplabel:SetText("Timed Autosave:")
	toplabel:SizeToContents()
	toplabel:SetPos(5, ypos)
	
	
	ypos = ypos + toplabel:GetTall() + 5
	
	
	local timewang = vgui.Create("DNumberWang", panel)
	timewang:SetValue(Holopad.AutosaveWait or 180)
	local oldendtimewang = timewang.EndWang
	timewang.EndWang	=	function(self)
								Holopad.AutosaveWait = self:GetValue()
								timer.Destroy(Holopad.AUTOSAVE_TIMER)
								timer.Create(Holopad.AUTOSAVE_TIMER, Holopad.AutosaveWait, 0, function() autosave(self) end)
								oldendtimewang(self)
							end
	timewang:SetMax(600)
	timewang:SetMin(10)
	timewang:SetPos(5, ypos)
	timewang:SetDecimals(0)
	
	local timelabel = vgui.Create("DLabel", panel)
	timelabel:SetText("Time Between Autosaves")
	timelabel:SizeToContents()
	timelabel:SetPos(10 + timewang:GetWide(), ypos + 2)
	
	
	ypos = ypos + timewang:GetTall() + 5
	
	
	local fileswang = vgui.Create("DNumberWang", panel)
	fileswang:SetValue(Holopad.AutosaveMax or 6)
	local oldendfileswang = fileswang.EndWang
	fileswang.EndWang	= function(self)	Holopad.AutosaveMax = self:GetValue()	oldendfileswang(self)	end
	fileswang:SetMax(50)
	fileswang:SetMin(1)
	fileswang:SetPos(5, ypos)
	fileswang:SetDecimals(0)
	
	local fileslabel = vgui.Create("DLabel", panel)
	fileslabel:SetText("Number of Autosave Files")
	fileslabel:SizeToContents()
	fileslabel:SetPos(10 + fileswang:GetWide(), ypos + 2)
	
	
	ypos = ypos + fileswang:GetTall() + 10
	
	
	onclosecheck = vgui.Create( "DCheckBoxLabel", panel )
	onclosecheck:SetPos( 5, ypos )
	onclosecheck:SetText( "Autosave on Close" )
	onclosecheck.OnChange = function(check) Holopad.AutosaveOnClose = onclosecheck:GetChecked() end
	onclosecheck:SetValue( Holopad.AutosaveOnClose == nil and true or Holopad.AutosaveOnClose )
	onclosecheck:SizeToContents()

	
	categoryList:AddItem(panel)
	
	
	self:SetTitle("Holopad 2; Savefile Options")
	local parent	 = self:GetParent()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	self:SetPos(parx + pwidth/2 - self.WindowX/2, pary)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end



derma.DefineControl( "DSaveOptionsDialogue_Holopad", "A save-options dialogue", PANEL, "DFrame" )



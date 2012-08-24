/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Entity Dialogue Derma
	splambob@gmail.com	 |_| 01/08/2012               

	Dialogue for text entry.
	
//*/


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 300, 300
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	
	self:SetSize(self.WindowX, self.WindowY)
	
	local posy = self.PaddingY + self.TopBarHeight + 5

	self.fileLabel = vgui.Create("DLabel", self)
	self.fileLabel:SetText("Enter Text:")
	self.fileLabel:SizeToContents()
	self.fileLabel:SetPos(self.PaddingX + 5, posy)
	
	posy = posy + self.fileLabel:GetTall() + 5

	self.entry = vgui.Create("DTextEntry", self)
	self.entry:SetWidth(self.ContentX - 10)
	self.entry:SetPos(self.PaddingX + 5, posy)

	posy = posy + self.entry:GetTall() + 10
	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, posy)
	
	posy = posy + 30
	self:SetTall(posy)
	
	self:SetTitle("Holopad 2; Text Dialogue")
	local parent	 = self:GetParent()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	self:SetPos(parx + pwidth/2 - self.WindowX/2, pary)
	self:MoveBelow(parent, 1)
	
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
	
	self.validator = nil
end




function PANEL:doneButtonClicked()
	local sel = self.entry:GetText()
	
	if !sel or sel == "" then
		self.doneButton:SetText("No text entered!")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
		return
	end
	
	
	if self.validator then
		local err = self.validator(sel)
		if err then
			self.doneButton:SetText(err)
			timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
			return
		end
	end
	
	
	if self.callback then
		self.exitStatus = true
		self.exitEntity = sel
		self:Close()
		return
	end
	
	self.doneButton:SetText("ERROR: No callback, tell Bubbus!")
	timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
	return
end



/**
	Set the instruction text of the window.
	Args;
		txt	String
			the text to use
 */
function PANEL:SetLabel(txt)
	self.fileLabel:SetText(txt)
	self.fileLabel:SizeToContents()
end



/**
	Set the instruction text of the window.
	Args;
		txt	String
			the text to use
 */
function PANEL:SetText(txt)
	self.entry:SetText(txt)
end



/**
	Set a validator to run on the entered text upon button press
	Function should take a string as an arg, and return false on success or error message string on failure.
	(i know false for success sounds weird, just do it plz k thx <3)
	Args;
		func	Function
			the custom validator function
 */
function PANEL:SetValidator(func)
	self.validator = func
end



/**
	Set the function to call upon exit.  argument 1 is boolean success of text entry, arg 2 is the text entered.
	Args;
		func	Function
			the function to call
 */
function PANEL:SetCallback(func)
	self.callback = func
end



derma.DefineControl( "DTextDialogue_Holopad", "A text dialogue", PANEL, "DFrame" )



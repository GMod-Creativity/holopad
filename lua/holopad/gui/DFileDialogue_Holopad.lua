/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | File Dialogue Derma
	splambob@gmail.com	 |_| 01/08/2012               

	Dialogue for filepath selection.
	
//*/


local PANEL = {}


function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	self:ShowCloseButton(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX, self.ContentY	= 300, 302
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	//self.ControlType = "camera"
	
	self:SetSize(self.WindowX, self.WindowY)
	
	
	self.tree = vgui.Create( "DTree", self )
	 
	self.tree:SetPos( self.PaddingX, self.PaddingY + self.TopBarHeight )
	self.tree:SetPadding( 5 )
	self.tree:SetSize( 300, 200 )
	
	self.fileLabel = vgui.Create("DLabel", self)
	self.fileLabel:SetText("File name (Partial filepath):")
	self.fileLabel:SizeToContents()
	self.fileLabel:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 210)
	
	self.fileEntry = vgui.Create("DTextEntry", self)
	self.fileEntry:SetWidth(self.ContentX - 10)
	self.fileEntry:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 215 + self.fileLabel:GetTall())
	
	self.checkOverwrite = vgui.Create( "DCheckBoxLabel", self )
	self.checkOverwrite:SetPos( self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 240 + self.fileLabel:GetTall() )
	self.checkOverwrite:SetText( "Overwrite existing files?" )
	self.checkOverwrite:SetValue( 0 )
	self.checkOverwrite:SizeToContents()
	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 250 + self.fileLabel:GetTall() + self.checkOverwrite:GetTall())
	
	self:SetTitle("Holopad 2; File Dialogue")
	local parent	 = self:GetParent()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	self:SetPos(parx + pwidth/2 - self.WindowX/2, pary)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	
	self.Close = 	function(self)
						timer.Destroy(tostring(self.doneButton))
						local callback, status, path = self.callback, self.exitStatus, self.exitFilepath
						oldclose(self)
						if callback then
							callback(status, path)
						end
					end
					
	self.exitStatus = false
	self.exitFilepath = nil
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end




function PANEL:doneButtonClicked()
	local curfile, fentry = self:GetCurrentFile()
	if !curfile or curfile == "" or !fentry or fentry == "" then
		self.doneButton:SetText("No file name entered!")
		timer.Create(tostring(self.doneButton), 3, 1, function() self.doneButton:SetText("Done!") end)
		return
	end
	
	if !self.loading and !string.match(fentry, "^([%a%s%d%.-_]+)$") then
		self.doneButton:SetText("File name is invalid! (a-Z, 0-9, _-)")
		timer.Create(tostring(self.doneButton), 3, 1, function() self.doneButton:SetText("Done!") end)
		return
	end

	local files = file.Find(curfile, "DATA")
	if files and table.Count(files) != 0 then 
		if !self.loading and !self.checkOverwrite:GetChecked() then
			self.doneButton:SetText("File exists and overwrite is disabled!")
			timer.Create(tostring(self.doneButton), 3, 1, function() self.doneButton:SetText("Done!") end)
			return
		end
	elseif self.loading then
		self.doneButton:SetText("The selected file does not exist!")
		timer.Create(tostring(self.doneButton), 3, 1, function() self.doneButton:SetText("Done!") end)
		return
	end
	
	if self.callback then
		self.exitStatus = true
		self.exitFilepath = curfile
		self:Close()
	end
end




local function rPopulateTree(path, node, foldername, dofiles)

	local newnode = node:AddNode(foldername)
	newnode.RepresentedDir = path
	
	local _, dirs = file.Find(path.."/*", "DATA")
	for _, dir in pairs(dirs) do
		rPopulateTree(path.."/"..dir, newnode, dir or "Unnamed?!?!", dofiles)
	end
	
	if dofiles then
		local files = file.Find(path.."/*.txt", "DATA")
		local filenode
		for _, file in pairs(files) do
			filenode = newnode:AddNode(file)
			filenode.isFile = true
			filenode.filename = file
			filenode.RepresentedDir = path.."/"..file
			filenode.Icon:SetImage( "gui/silkicons/palette" )
		end
	end
	
end




// relative to data
function PANEL:SetRootFolder(path, dofiles)
	local foldername = string.match(path, "(/.$)") or path or "Unnamed?!?!"
	self.tree.rootPath = path
	rPopulateTree(path, self.tree, foldername, dofiles)
end




function PANEL:SetCallback(func)
	self.callback = func
end




function PANEL:SetLoading()
	self.loading = true
	self:EnableTextEntry(false)
	self.checkOverwrite:SetVisible(false)
	self.checkOverwrite:SetChecked(true)
	self.checkOverwrite.OnChange = function(this) this:SetChecked(true) end
end




function PANEL:EnableTextEntry(enabled)
	self.fileEntry:SetEditable(enabled)
	//self.fileEntry:SetDrawBackground(enabled)
	self.fileEntry:SetVisible(enabled)
	self.fileLabel:SetVisible(enabled)
end




function PANEL:GetCurrentFile()
	local selected = self.tree:GetSelectedItem()
	
	if !selected then 
		local file = self.fileEntry:GetText()
		if !file or file == "" then return false end
		file = file .. ".txt"
		return (self.tree.rootPath .. "/" .. file), file
	end
	
	if selected.isFile then return selected.RepresentedDir, selected.filename end
	
	local file = self.fileEntry:GetText()
	if !file or file == "" then return false end
	file = file .. ".txt"
	
	return selected.RepresentedDir .. "/" .. file, file
end



derma.DefineControl( "DFileDialogue_Holopad", "A file dialogue", PANEL, "DFrame" )



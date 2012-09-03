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
	self.ContentX, self.ContentY	= 300, 335
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
	
	local ypos = self.PaddingY + self.TopBarHeight + 250 + self.fileLabel:GetTall() + self.checkOverwrite:GetTall()
	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, ypos)
	
	
	local categoryList = vgui.Create( "DPanelList" )
	categoryList:SetAutoSize( true )
	categoryList:SetSpacing( 5 )
	categoryList:EnableHorizontal( false )
	categoryList:EnableVerticalScrollbar( false )
	
	local category = vgui.Create("DCollapsibleCategory", self)
	category:SetSize( self.ContentX, self.ContentY )
	category:SetPos(self.PaddingX, ypos + 30)
	category:SetExpanded( 0 )
	category:SetLabel( "Additional Options" )
	//category.Header:SetMouseInputEnabled(false)
	category:SetContents(categoryList)
	category:SetTall(self.ContentY)
	self.category = category
	
	
	local addpanel = vgui.Create("DPanel")
	addpanel.Paint = function() end
	
	local ypos2 = 5
	
	local exporterlabel = vgui.Create("DLabel", addpanel)
	exporterlabel:SetText("Choose an Exporter:")
	exporterlabel:SizeToContents()
	exporterlabel:SetPos(5, ypos2)
	
	ypos2 = ypos2 + exporterlabel:GetTall() + 5
	
	local exporterlist= vgui.Create( "DMultiChoice", addpanel)
	exporterlist:SetPos(5, ypos2)
	exporterlist:SetSize( 270, 20 )
	exporterlist:AddChoice("Export 2 (Spawn by loop, arrays, unlimited)", "E2")
	exporterlist:AddChoice("Old Export (Basic spawn code, limited)", "E2old")
	exporterlist.OnSelect = function(self, i, str, val) self.SelectedExporter = val end
	self.exporterlist = exporterlist
	
	ypos2 = ypos2 + 30
	
	local scalelabel = vgui.Create("DLabel", addpanel)
	scalelabel:SetText("Scale Modifier: ")
	scalelabel:SizeToContents()
	scalelabel:SetPos(5, ypos2+3)
	
	local scalewang = vgui.Create("DNumberWang", addpanel)
	scalewang:SetValue(1)
	scalewang:SetMax(100)
	scalewang:SetMin(0.1)
	scalewang:SetPos(5 + scalelabel:GetWide(), ypos2)
	scalewang:SetDecimals(2)
	self.scalewang = scalewang
	
	ypos2 = ypos2 + scalewang:GetTall() + 5
	/*
	fileEntry = vgui.Create("DTextEntry", addpanel)
	self.fileEntry:SetWidth(self.ContentX - 10)
	self.fileEntry:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + 215 + self.fileLabel:GetTall())
	//*/
	
	addpanel:SizeToContents()
	addpanel:SetTall(ypos2)
	
	categoryList:AddItem(addpanel)
	
	
	self:SetTitle("Holopad 2; Export to E2")
	local parent	 = self:GetParent()
	local pwidth	 = parent:GetWide()
	local parx, pary = parent:GetPos()
	self:SetPos(parx + pwidth/2 - self.WindowX/2, pary)
	self:MoveBelow(parent, 1)
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	
	local closefunc =	function(success, filepath)
							if success then
								exporter = Holopad[self.exporterlist.SelectedExporter or "E2"]
								local options = {author = LocalPlayer():Nick(), scale = self.scalewang:GetValue()}
								exporter.Save( self.mdlobj, filepath, true, options )
							end
						end
	
	self.Close = 	function(self)
						local callback, status, path = self.callback, self.exitStatus, self.exitFilepath
						closefunc(status, path)
						oldclose(self)
						if callback then
							callback(status, path)
						end
					end
					
	self.exitStatus = false
	self.exitFilepath = nil
	
	self.btnClose:SetPos(self.WindowX - self.btnClose:GetWide() + 19, 1)
	self.lblTitle:SizeToContents()
	self.lblTitle:SetPos(8, 5)
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
end




function PANEL:SetModelObj(mdl)
	self.mdlobj = mdl
end




function PANEL:PerformLayout()
	self:SetTall(self.ContentY + self.category:GetTall())
end




function PANEL:doneButtonClicked()
	local curfile, fentry = self:GetCurrentFile()
	print(curfile, fentry)
	if !curfile or curfile == "" or !fentry or fentry == "" then
		self.doneButton:SetText("No file name entered!")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
		return
	end
	
	if !self.loading and !string.match(fentry, "^([%a%s%d%.-_]+)$") then
		self.doneButton:SetText("File name is invalid! (a-Z, 0-9, _-)")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
		return
	end

	local files = file.Find(curfile)
	if files and table.Count(files) != 0 then 
		if !self.loading and !self.checkOverwrite:GetChecked() then
			self.doneButton:SetText("File exists and overwrite is disabled!")
			timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
			return
		end
	elseif self.loading then
		self.doneButton:SetText("The selected file does not exist!")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
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
	
	local dirs = file.FindDir(path.."/*")
	for _, dir in pairs(dirs) do
		rPopulateTree(path.."/"..dir, newnode, dir or "Unnamed?!?!", dofiles)
	end
	
	if dofiles then
		local files = file.Find(path.."/*.txt")
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



derma.DefineControl( "DE2ExportDialogue_Holopad", "A file dialogue", PANEL, "DFrame" )



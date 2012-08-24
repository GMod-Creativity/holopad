/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Entity Dialogue Derma
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
	self.ContentX, self.ContentY	= 300, 430
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self.ContentY + self.PaddingY*2 + self.TopBarHeight
	
	
	self:SetSize(self.WindowX, self.WindowY)
	
	
	self.list = vgui.Create("DListView", self)
	self.list:SetSize(300, 400)
	self.list:SetPos(self.PaddingX, self.PaddingY + self.TopBarHeight)
	self.list:AddColumn("Name")
	self.list:AddColumn("Model")
	self.list:AddColumn("Entity")
	self.list:SetMultiSelect(false)

	
	self.doneButton = vgui.Create("DButton", self)
	self.doneButton:SetText( "Done!" )
	self.doneButton.DoClick = function() self:doneButtonClicked() end
	self.doneButton:SetSize(self.ContentX - 10, 20)
	self.doneButton:SetPos(self.PaddingX + 5, self.PaddingY + self.TopBarHeight + self.list:GetTall() + 10)
	
	
	self:SetTitle("Holopad 2; Entity Dialogue")
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
	
end




function PANEL:doneButtonClicked()
	local sel = self.list:GetSelectedLine()
	
	if !sel then
		self.doneButton:SetText("No entity selected!")
		timer.Simple(3, self.doneButton.SetText, self.doneButton, "Done!")
		return
	end
	
	sel = self.list:GetLine(sel)
	
	if self.callback then
		self.exitStatus = true
		self.exitEntity = sel:GetValue(3)
		self:Close()
	end
end




function PANEL:SetModelObj(mdl)
	if !mdl then Error("Tried to set the ModelObj to nil! Naughty!") end
	self.list:Clear()
	self.modelobj = model
	
	local name, model
	for _, v in ipairs(mdl:getAll()) do
		if v:class() != Holopad.ClipPlane then
			name = v:getName() or ""
			model = v:getModel() or "<Unknown?>"
			self.list:AddLine(name != "" and name or "<Unnamed>", model:match("/([%a%d_]-)%.mdl$") or model, v)
		end
	end
end




function PANEL:SetOnClickLine(func)
	self.list.OnClickLine = func
end




function PANEL:SetCallback(func)
	self.callback = func
end



derma.DefineControl( "DEntityDialogue_Holopad", "An entity dialogue", PANEL, "DFrame" )



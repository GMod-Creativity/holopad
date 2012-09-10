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
	self:Center()
	
	self:MakePopup()
	
	
	local oldclose = self.Close
	
	self.Close = 	function(self)
						local callback, status, path = self.callback, self.exitStatus, self.exitEntity
						hook.Remove(Holopad.MODEL_UPDATE .. tostring(mdl))
						oldclose(self)
						if callback then
							callback(status, path)
						end
					end
					
	self.exitStatus = false
	self.exitEntity = nil
	
	self.modelhook = function(update)
		if !self.list then ErrorNoHalt("List does not exist? what.") return end
		if update.added then
			local name	= update.ent:getName() or ""
			local model	= update.ent:getModel() or "<Unknown?>"
			local line	= self.list:AddLine(name != "" and name or "<Unnamed>", model:match("/([%a%d_]-)%.mdl$") or model, update.ent)
			line.ent = update.ent
		end
		if update.removed then
			for k, v in pairs(self.list:GetLines()) do
				if v.ent == update.ent then
					self.list:RemoveLine(k)
					break
				end
			end
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
	
	if self.modelobj then
		hook.Remove(Holopad.MODEL_UPDATE .. tostring(self.mdlobj), tostring(self))
	end
	
	self.modelobj = model
	
	local name, model, line
	for _, v in ipairs(mdl:getAll()) do
		if v:class() != Holopad.ClipPlane then
			name	= v:getName() or ""
			model	= v:getModel() or "<Unknown?>"
			line	= self.list:AddLine(name != "" and name or "<Unnamed>", model:match("/([%a%d_]-)%.mdl$") or model, v)
			line.ent = v
		end
	end
	
	hook.Add(Holopad.MODEL_UPDATE .. tostring(mdl), tostring(self), self.modelhook)
end




function PANEL:SetOnClickLine(func)
	self.list.OnClickLine = func
end




function PANEL:SetCallback(func)
	self.callback = func
end



derma.DefineControl( "DEntityDialogue_Holopad", "An entity dialogue", PANEL, "DFrame" )



/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Viewport Stats
	splambob@gmail.com	 |_| 17/07/2012               

	Label which reports scene statistics for the Viewport.
	
//*/

local PANEL = {}


function PANEL:Init()
	self.bDisplay = false
	self.Empty = ""
	self.LastModels = 0
	self.LastClips = 0
	self.LastUpdateID = 0
	self.UpdateRate = 0.25
	self.NextUpdate = RealTime() + self.UpdateRate
	self.MaxHolos = ConVarExists("wire_holograms_burst_amount") and GetConVar("wire_holograms_burst_amount"):GetInt()-1 or nil
	
	self:SetText(self.Empty)
end



function PANEL:Think()
	// TODO: string builder object to cut down concatenation slowness.
	if RealTime() >= self.NextUpdate then
		if self.bDisplay && self.ModelObj then
			
			local stats = {}
			// TODO: string.format
				local holos = #self.ModelObj:getType(Holopad.Hologram)
				stats[#stats+1] = "Current Holos: "
				stats[#stats+1] = holos
				if self.MaxHolos then
					stats[#stats+1] = " / "
					stats[#stats+1] = self.MaxHolos
					if holos >= self.MaxHolos then stats[#stats+1] = " !!!" end
				end
				stats[#stats+1] = "\nCurrent Clips: "
				stats[#stats+1] = #self.ModelObj:getType(Holopad.ClipPlane)
				stats[#stats+1] = "\n\nCamera:\n[" 
				stats[#stats+1] = tostring(self.Viewport:GetDirVec():Angle()) 
				stats[#stats+1] = "] @ " 
				stats[#stats+1] = math.Round(self.Viewport:GetCamDist(), 1)
				stats[#stats+1] = " glu"
				stats[#stats+1] = "\nCurrent Grid Size: "
				stats[#stats+1] = self.Viewport:GetGridSize()
				stats[#stats+1] = " glu ("
				stats[#stats+1] = math.Round((self.Viewport:GetGridSize() / Holopad.DEFAULT_GRIDSIZE)*100, 2)
				stats[#stats+1] = "%)"
				
				self:SetText(table.concat(stats))
				self:SizeToContents()
				
				//self.LastUpdateID = lastid
			//end
		end
		
		self.NextUpdate = RealTime() + self.UpdateRate
	end
end



/**
	Toggle label display
	Args;
		bool	Boolean
			true to display else false
 */
function PANEL:Display(bool)
	self.bDisplay = bool
	if !bool then self:SetText(self.Empty) end
end



/**
	Set the Model to enquire for statistics
	Args;
		model	Table (instance of Holopad.Model)
			the Model to use
 */
function PANEL:SetModelObj(model)
	self.ModelObj = model
end



/**
	Set the Viewport to enquire for statistics
	Args;
		model	DViewport_Holopad
			the Viewport to use
 */
function PANEL:SetViewport(viewport)
	self.Viewport = viewport
end


derma.DefineControl( "DViewportStatLabel_Holopad", "Displays statistics for DViewport_Holopad", PANEL, "DLabel" )



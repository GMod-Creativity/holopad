/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Create Holo Derma
	splambob@gmail.com	 |_| 12/07/2012               

	Menu for hologram creation.
	
//*/


include("holopad/gui/DHoloSelect_Holopad.lua")
include("holopad/gui/DTextDialogue_Holopad.lua")


local HOLOLIST = 
{
	{ ModelPath	=	"models/Holograms/cone.mdl",
	  Tooltip	=	"Spawn cone"	},
	{ ModelPath	=	"models/Holograms/cube.mdl",
	  Tooltip	=	"Spawn cube"	},
	{ ModelPath	=	"models/Holograms/cylinder.mdl",
	  Tooltip	=	"Spawn cylinder"	},
	{ ModelPath	=	"models/Holograms/hexagon.mdl",
	  Tooltip	=	"Spawn hexagon"	},
	{ ModelPath	=	"models/Holograms/hq_cone.mdl",
	  Tooltip	=	"Spawn hq_cone"	},
	{ ModelPath	=	"models/Holograms/hq_cubinder.mdl",
	  Tooltip	=	"Spawn hq_cubinder"	},
	{ ModelPath	=	"models/Holograms/hq_cylinder.mdl",
	  Tooltip	=	"Spawn hq_cylinder"	},
	{ ModelPath	=	"models/Holograms/hq_dome.mdl",
	  Tooltip	=	"Spawn hq_dome"	},
	{ ModelPath	=	"models/Holograms/hq_hdome.mdl",
	  Tooltip	=	"Spawn hq_hdome"	},
	{ ModelPath	=	"models/Holograms/hq_hdome_thick.mdl",
	  Tooltip	=	"Spawn hq_hdome_thick"	},
	{ ModelPath	=	"models/Holograms/hq_hdome_thin.mdl",
	  Tooltip	=	"Spawn hq_hdome_thin"	},
	{ ModelPath	=	"models/Holograms/hq_icosphere.mdl",
	  Tooltip	=	"Spawn hq_icosphere"	},
	{ ModelPath	=	"models/Holograms/hq_rcube.mdl",
	  Tooltip	=	"Spawn hq_rcube"	},
	{ ModelPath	=	"models/Holograms/hq_rcube_thick.mdl",
	  Tooltip	=	"Spawn hq_rcube_thick"	},
	{ ModelPath	=	"models/Holograms/hq_rcube_thin.mdl",
	  Tooltip	=	"Spawn hq_rcube_thin"	},
	{ ModelPath	=	"models/Holograms/hq_rcylinder.mdl",
	  Tooltip	=	"Spawn hq_rcylinder"	},
	{ ModelPath	=	"models/Holograms/hq_rcylinder_thick.mdl",
	  Tooltip	=	"Spawn hq_rcylinder_thick"	},
	{ ModelPath	=	"models/Holograms/hq_rcylinder_thin.mdl",
	  Tooltip	=	"Spawn hq_rcylinder_thin"	},
	{ ModelPath	=	"models/Holograms/hq_sphere.mdl",
	  Tooltip	=	"Spawn hq_sphere"	},
	{ ModelPath	=	"models/Holograms/hq_stube.mdl",
	  Tooltip	=	"Spawn hq_stube"	},
	{ ModelPath	=	"models/Holograms/hq_stube_thick.mdl",
	  Tooltip	=	"Spawn hq_stube_thick"	},
	{ ModelPath	=	"models/Holograms/hq_stube_thin.mdl",
	  Tooltip	=	"Spawn hq_stube_thin"	},
	{ ModelPath	=	"models/Holograms/hq_torus.mdl",
	  Tooltip	=	"Spawn hq_torus"	},
	{ ModelPath	=	"models/Holograms/hq_torus_oldsize.mdl",
	  Tooltip	=	"Spawn hq_torus_oldsize"	},
	{ ModelPath	=	"models/Holograms/hq_torus_thick.mdl",
	  Tooltip	=	"Spawn hq_torus_thick"	},
	{ ModelPath	=	"models/Holograms/hq_torus_thin.mdl",
	  Tooltip	=	"Spawn hq_torus_thin"	},
	{ ModelPath	=	"models/Holograms/hq_tube.mdl",
	  Tooltip	=	"Spawn hq_tube"	},
	{ ModelPath	=	"models/Holograms/hq_tube_thick.mdl",
	  Tooltip	=	"Spawn hq_tube_thick"	},
	{ ModelPath	=	"models/Holograms/hq_tube_thin.mdl",
	  Tooltip	=	"Spawn hq_tube_thin"	},
	{ ModelPath	=	"models/Holograms/icosphere.mdl",
	  Tooltip	=	"Spawn icosphere"	},
	{ ModelPath	=	"models/Holograms/icosphere2.mdl",
	  Tooltip	=	"Spawn icosphere2"	},
	{ ModelPath	=	"models/Holograms/icosphere3.mdl",
	  Tooltip	=	"Spawn icosphere3"	},
	{ ModelPath	=	"models/Holograms/octagon.mdl",
	  Tooltip	=	"Spawn octagon"	},
	{ ModelPath	=	"models/Holograms/plane.mdl",
	  Tooltip	=	"Spawn plane"	},
	{ ModelPath	=	"models/Holograms/prism.mdl",
	  Tooltip	=	"Spawn prism"	},
	{ ModelPath	=	"models/Holograms/pyramid.mdl",
	  Tooltip	=	"Spawn pyramid"	},
	{ ModelPath	=	"models/Holograms/right_prism.mdl",
	  Tooltip	=	"Spawn right_prism"	},
	{ ModelPath	=	"models/Holograms/sphere.mdl",
	  Tooltip	=	"Spawn sphere"	},
	{ ModelPath	=	"models/Holograms/sphere2.mdl",
	  Tooltip	=	"Spawn sphere2"	},
	{ ModelPath	=	"models/Holograms/sphere3.mdl",
	  Tooltip	=	"Spawn sphere3"	},
	{ ModelPath	=	"models/Holograms/tetra.mdl",
	  Tooltip	=	"Spawn tetra"	},
	{ ModelPath	=	"models/Holograms/torus.mdl",
	  Tooltip	=	"Spawn torus"	},
	{ ModelPath	=	"models/Holograms/torus2.mdl",
	  Tooltip	=	"Spawn torus2"	},
	{ ModelPath	=	"models/Holograms/torus3.mdl",
	  Tooltip	=	"Spawn torus3"	}
}



local PANEL = {}
local customholo, spawncustom



function PANEL:Init()
	
	self:SetSizable(false)
    self:SetScreenLock(true)
    self:SetDeleteOnClose(true)
	
	self.PaddingX, self.PaddingY, self.TopBarHeight = 4, 4, 19
	self.ContentX	= 216
	self.WindowX,  self.WindowY 	= self.ContentX + self.PaddingX*2, self:GetParent():GetViewPanel():GetTall()
	self.ContentY	= self.WindowY - self.PaddingY*2 - self.TopBarHeight
	
	self:SetSize(self.WindowX, self.WindowY)
	
	self.HoloSelect = vgui.Create("DHoloSelect_Holopad", self)
	self.HoloSelect:SetModelList( HOLOLIST, self:GetParent():GetModelObj(), self )
	self.HoloSelect:SetSize(self.ContentX, self.ContentY)
	self.HoloSelect:SetPos(self.PaddingX, self.PaddingY + self.TopBarHeight)

	spawncustom = function(success, path)
		if success then self:SpawnWithModel(path) end
	end
	
	customholo = function(but)
		local entry = vgui.Create("DTextDialogue_Holopad", self)
		entry:SetLabel("Enter a model path; (ex. \"" .. Holopad.ERROR_MODEL .. "\")")
		entry:SetCallback(spawncustom)
	end
	
	local icon = vgui.Create( "SpawnIcon" )
        icon:SetModel( Holopad.CUSTOM_MODEL_PATH )
        icon:SetSize( 64, 64 )
        icon:SetTooltip( "Spawn a model by filepath" )
        icon.Model = Holopad.CUSTOM_MODEL_PATH
        icon.OnMousePressed = customholo
	self.HoloSelect:AddPanel(icon)	

	self:SizeToContents()
	
	self:SetTitle("Holopad 2; Create a New Entity")
	self:MoveBelow(self:GetParent(), 1)
	self:MoveLeftOf(self:GetParent(), 1)
	
	self:MakePopup()
	self:SetFocusTopLevel(true)
	self:MoveToFront()
	
	local x, y = self:GetPos()
	local sx, sy = ScrW(), ScrH()
	if y < 0 then y = 0 end
	if y > sy - self.WindowY then y = sx - self.WindowX end
	if x < 0 then x = 0 end
	if x > sx - self.WindowX then x = sx - self.WindowX end
	self:SetPos(x, y)
	
	local oldclose = self.Close
	self.Close = 	function(self)
						local callback = self.callback
						oldclose(self)
						if callback then
							callback()
						end
					end
	
end



function PANEL:SetCallback(func)
	self.callback = func
end



function PANEL:SpawnWithModel(modelpath)
	self:GetParent():GetModelObj():addEntity(Holopad.Hologram:New(nil, nil, nil, modelpath, nil, nil, nil))
end



derma.DefineControl( "DCreateHoloMenu_Holopad", "Menu for hologram creation", PANEL, "DFrame" )



/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Constant definitions
	splambob@gmail.com	 |_| 09/07/2012               

	I like constants.
	
//*/

// Hopefully I remember to update this, cba to automate.
Holopad.LAST_UPDATED	= "03/09/2012 (BETA 5.6)"
Holopad.LODSA_HURRS		=
{
	"if a holo gotta attitude",
	"clip it like it's haaawt",
	"holos with attitude",
	"scale holos erryday",
	"holo 4 lyf",
	"holo holo get dollo",
	"i ain't no holoback gurl",
	"100% more holo than the leading brand!",
	"L33T MLG TACTICAL",
	"shift is cruise control for OCD",
	"cool kids don't use snap",
	"banned in 16 states",
	"now with errors!",
	"hi gluttony!",
	"programming is fun!",
	"hologram notepad",
	"type quit for godmode",
	"don't make a dong",
	"warnings are not errors",
	"bubbus is a lazy dev",
	"tanks are awesome",
	"in development!",
	"internet drama",
	"a machine for breens",
	"tank cops",
	"tank justice!",
	"noobstorm",
	"what happens if i remove this code OH GOD",
	"10k lines and counting"
}

// Change this if the error model is annoying.
Holopad.ERROR_MODEL 	= "models/error.mdl"
// The icon modelpath for the Custom Model spawn button
Holopad.CUSTOM_MODEL_PATH = "models/props_combine/breenbust.mdl"

// clip planes!
Holopad.CLIP_MODEL		= "models/Holograms/plane.mdl"
// material for clip planes
Holopad.CLIP_MATERIAL	= "holopad/wireframenocull"
//material for model markers
Holopad.MODEL_MARKER_TEXTURE = surface.GetTextureID("holopad/circlemarker")

// you don't want the default entity colour to be opaque white?!?!?!?!
// this is a function because Color is mutable.
Holopad.COLOUR_DEFAULT	= function() return Color(255, 255, 255, 255) end

// prefix for entity modification callbacks
Holopad.ENT_UPDATEHOOK	= "Holopad_Ent_Modified "
// prefix for "deparent all children" hooks
Holopad.ENT_DEPARENTALLHOOK	= "Holopad_Ent_DeparentAll "
// prefix for model update hooks
Holopad.MODEL_UPDATE	= "Holopad_Model_Update "

// default background colour for the holopad gui.
Holopad.BACKGROUND_COLOUR	= function() return Color(50, 50, 50, 255) end

// lolol (grabby dongle settings)
Holopad.DONGLE_LENGTH = 50
Holopad.DONGLE_RADIUS = 9

// autosave config
// the folder to save autosaves in
Holopad.AUTOSAVE_DIR = "Holopad/Autosave"
// the name to give the autosave timer
Holopad.AUTOSAVE_TIMER = "Holopad_AutosaveTimer"

// the file to save persistence data in
Holopad.PERSIST_FILE = "HolopadData/persist.txt"

// the default grid size
Holopad.DEFAULT_GRIDSIZE = 12	// ~ 1 phx unit (11.864)


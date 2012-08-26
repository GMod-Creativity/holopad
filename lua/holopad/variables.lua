/**
   	 _    _       _                       _ 
	| |  | |     | |                     | |
	| |__| | ___ | | ___  _ __   __ _  __| |
	|  __  |/ _ \| |/ _ \| '_ \ / _` |/ _` |
	| |  | | (_) | | (_) | |_) | (_| | (_| |
	|_|  |_|\___/|_|\___/| .__/ \__,_|\__,_|
	By Bubbus			 | | Variable definitions
	splambob@gmail.com	 |_| 09/07/2012               

	Variables are cool also.
	
//*/

// Camera inversions
Holopad.InvertCameraX = 1
Holopad.InvertCameraY = 1

Holopad.InvertPanningX = 1
Holopad.InvertPanningY = 1

// Should child holos scale with the parent?
Holopad.ScaleParentedHolos = false

// Autosave config
// How many autosaves should be created before overwriting the first one?  THIS RESETS EVERY SESSION.
Holopad.AutosaveMax = 6
// What number should the autosaves start at?
Holopad.AutosaveCurrent = 1 
// How long should Holopad wait between autosaves?  Time in seconds.
Holopad.AutosaveWait = 180	// 3 minutes

// Grid settings
Holopad.GridSize = Holopad.DEFAULT_GRIDSIZE or 12
Holopad.GridColour = function() return Color(255, 255, 255) end
Holopad.GridMaterial = "holopad/gridbw"
Holopad.GridAutoOrient = 1
Holopad.GridAutoCenter = 1
Holopad.GridAlpha = 100
// Scale snap units
Holopad.ScaleSnap = 0.1
// Angular snap units
Holopad.AngleSnap = 15

// Viewport lighting
Holopad.ViewportLighting = "white"
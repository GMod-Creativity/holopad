--[[ _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_)

    DModelSelect
TAD2020

With extra Bub!
splambob@googlemail.com
]]
local PANEL = {}


--[[-------------------------------------------------------
   Name: Init
---------------------------------------------------------]]
function PANEL:Init()

    self:EnableVerticalScrollbar()
    self:SetTall( 66 * 2 + 2 )
    
end



--[[-------------------------------------------------------
   Name: SetHeight
---------------------------------------------------------]]
function PANEL:SetHeight( height )

    self:SetTall( math.floor((height or 2)/66)*66 + 2 )
    
end



--[[-------------------------------------------------------
   Name: SetModelList
---------------------------------------------------------]]
function PANEL:SetModelList( ModelList, modelobj, holomenu )
    
    for mdlID, v in pairs( ModelList ) do
    
        local icon = vgui.Create( "SpawnIcon" )
        icon:SetModel( v.ModelPath )
        icon:SetSize( 64, 64 )
        icon:SetTooltip( v.Tooltip )
        icon.Model = v.Tooltip
        icon.OnMousePressed = function() holomenu:SpawnWithModel(v.ModelPath) end
        
        //local convars = {}
        
        self:AddPanel( icon )
        
    end
	
	self:SortByMember( "Model", true )
    
end


derma.DefineControl( "DHoloSelect_Holopad", "A panel full of spawn icons", PANEL, "DPanelSelect" )

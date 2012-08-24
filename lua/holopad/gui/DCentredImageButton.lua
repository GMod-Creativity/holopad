/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_)

    DImageButton

*/

PANEL = {}
AccessorFunc( PANEL, "m_bStretchToFit",             "StretchToFit" )

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()
	self:SetDrawBackground( true )
    self:SetDrawBorder( true )
    self:SetStretchToFit( false )

    self:SetCursor( "hand" )
    self.m_Image = vgui.Create( "DImage", self )
    
    self:SetText( "" )
    
    self:SetColor( Color( 255, 255, 255, 255 ) )

end

/*---------------------------------------------------------
    SetImage
---------------------------------------------------------*/
function PANEL:SetImage( img )

    if ( !img ) then
    
        if ( IsValid( self.m_Image ) ) then
            self.m_Image:Remove()
        end
    
        return
    end

    if ( !IsValid( self.m_Image ) ) then
        self.m_Image = vgui.Create( "DImage", self )
    end
	
	//self.m_Image = vgui.Create( "DImage", self )
	self.m_Image:SetImage( img )
    self.m_Image:SizeToContents()
	w, h = self.m_Image:GetWide(), self.m_Image:GetTall()
	self.m_Image:SetPos(self:GetWide()/2-w, self:GetTall()/2-h)

end

/*---------------------------------------------------------
    SetColor
---------------------------------------------------------*/
function PANEL:SetColor( col )

    self.m_Image:SetImageColor( col )
    self.ImageColor = col

end

/*---------------------------------------------------------
    GetImage
---------------------------------------------------------*/
function PANEL:GetImage()

    return self.m_Image:GetImage()

end

/*---------------------------------------------------------
    SetKeepAspect
---------------------------------------------------------*/
function PANEL:SetKeepAspect( bKeep )

    self.m_Image:SetKeepAspect( bKeep )

end

// This makes it compatible with the older ImageButton
PANEL.SetMaterial = PANEL.SetImage


/*---------------------------------------------------------
    SizeToContents
---------------------------------------------------------*/
function PANEL:SizeToContents( )

    self.m_Image:SizeToContents()
    self:SetSize( self.m_Image:GetWide(), self.m_Image:GetTall() )

end

/*---------------------------------------------------------
    OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mousecode )

    DButton.OnMousePressed( self, mousecode )

    
    if ( self.m_bStretchToFit ) then
            
        self.m_Image:SetPos( 2, 2 )
        self.m_Image:SetSize( self:GetWide() - 4, self:GetTall() - 4 )
        
    else
    
        self.m_Image:SizeToContents()
        self.m_Image:SetSize( self.m_Image:GetWide() * 0.8, self.m_Image:GetTall() * 0.8 )
        self.m_Image:Center()
        
    end

end

/*---------------------------------------------------------
    OnMouseReleased
---------------------------------------------------------*/
function PANEL:OnMouseReleased( mousecode )

    DButton.OnMouseReleased( self, mousecode )

    if ( self.m_bStretchToFit ) then
            
        self.m_Image:SetPos( 0, 0 )
        self.m_Image:SetSize( self:GetSize() )
        
    else
    
        self.m_Image:SizeToContents()
        self.m_Image:Center()
        
    end

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Paint(w, h)

    derma.SkinHook( "Paint", "ImageButton", self, w, h )
    return true

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PaintOver(w, h)

    derma.SkinHook( "PaintOver", "ImageButton", self, w, h)
    return true

end


/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:PerformLayout()

    if ( self.m_bStretchToFit ) then
            
        self.m_Image:SetPos( 0, 0 )
        self.m_Image:SetSize( self:GetSize() )
        
    else
    
        self.m_Image:SizeToContents()
        self.m_Image:Center()
        
    end

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetDisabled( bDisabled )

    DButton.SetDisabled( self, bDisabled )

    if ( bDisabled ) then
        self.m_Image:SetAlpha( self.ImageColor.a * 0.4 )
    else
        self.m_Image:SetAlpha( self.ImageColor.a )
    end

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:SetOnViewMaterial( MatName, Backup )

    self.m_Image:SetOnViewMaterial( MatName, Backup )

end


derma.DefineControl( "DCentredImageButton", "awesome", PANEL, "DButton" )
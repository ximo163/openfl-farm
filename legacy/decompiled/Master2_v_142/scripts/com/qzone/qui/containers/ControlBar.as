package com.qzone.qui.containers
{
   import com.qzone.qui.containers.boxClasses.Box;
   import com.qzone.qui.skins.PanelDefaultSkin;
   import com.qzone.qui.styles.Style;
   
   public class ControlBar extends Box
   {
      
      public function ControlBar()
      {
         super();
         _height = Style.panelControlBarHeight;
         paddingV = 0;
         gapV = 0;
         defaultSkin = PanelDefaultSkin.controlBarSkin;
         backgroundAlpha = 0;
      }
   }
}


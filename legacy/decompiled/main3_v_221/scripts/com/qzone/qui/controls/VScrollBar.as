package com.qzone.qui.controls
{
   import com.qzone.qui.controls.scrollClasses.ScrollBar;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.skins.VScrollBarDefaultSkin;
   import com.qzone.qui.styles.Style;
   
   public class VScrollBar extends ScrollBar
   {
      
      public function VScrollBar()
      {
         super();
         _width = Style.vScrollBarWidth;
         _height = 100;
         _direction = Direction.VERTICAL;
         upArrowSkin = VScrollBarDefaultSkin.upArrowSkin;
         downArrowSkin = VScrollBarDefaultSkin.downArrowSkin;
         trackSkin = VScrollBarDefaultSkin.trackSkin;
         thumbSkin = VScrollBarDefaultSkin.thumbSkin;
         thumbIconSkin = VScrollBarDefaultSkin.thumbIconSkin;
      }
   }
}


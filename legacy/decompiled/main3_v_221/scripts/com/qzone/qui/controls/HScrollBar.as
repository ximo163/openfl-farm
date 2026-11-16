package com.qzone.qui.controls
{
   import com.qzone.qui.controls.scrollClasses.ScrollBar;
   import com.qzone.qui.core.Direction;
   import com.qzone.qui.skins.HScrollBarDefaultSkin;
   import com.qzone.qui.styles.Style;
   
   public class HScrollBar extends ScrollBar
   {
      
      public function HScrollBar()
      {
         super();
         _height = Style.hScrollBarHeight;
         _width = 100;
         _direction = Direction.HORIZONTAL;
         upArrowSkin = HScrollBarDefaultSkin.upArrowSkin;
         downArrowSkin = HScrollBarDefaultSkin.downArrowSkin;
         trackSkin = HScrollBarDefaultSkin.trackSkin;
         thumbSkin = HScrollBarDefaultSkin.thumbSkin;
         thumbIconSkin = HScrollBarDefaultSkin.thumbIconSkin;
      }
   }
}


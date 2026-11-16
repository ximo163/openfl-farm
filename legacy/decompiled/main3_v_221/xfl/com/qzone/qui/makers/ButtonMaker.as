package com.qzone.qui.makers
{
   import com.qzone.qui.styles.Style;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class ButtonMaker
   {
      
      public function ButtonMaker()
      {
         super();
      }
      
      private static function onRollOver(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         _loc2_.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,onPress);
         _loc2_.addEventListener(MouseEvent.MOUSE_UP,onRelease);
         _loc2_.filters = Style.getRollOverFilter();
      }
      
      public static function addTarget(param1:Sprite, param2:Boolean = true, param3:Boolean = false) : void
      {
         setSelected(param1,param3);
         setEnabled(param1,param2);
         param1.buttonMode = true;
         param1.mouseChildren = false;
      }
      
      private static function onPress(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         _loc2_.filters = Style.getHitFilter();
      }
      
      public static function removeTarget(param1:Sprite) : void
      {
         setSelected(param1,false);
         removeEvent(param1);
         param1.filters = Style.getRollOutFilter();
         param1.buttonMode = false;
         param1.mouseChildren = true;
      }
      
      private static function removeEvent(param1:Sprite) : void
      {
         param1.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
         param1.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,onPress);
         param1.removeEventListener(MouseEvent.MOUSE_UP,onRelease);
      }
      
      private static function onRelease(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         _loc2_.filters = Style.getRollOverFilter();
      }
      
      private static function addEvent(param1:Sprite) : void
      {
         param1.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
      }
      
      private static function onRollOut(param1:MouseEvent) : void
      {
         var _loc2_:Sprite = param1.target as Sprite;
         _loc2_.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
         _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,onPress);
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,onRelease);
         _loc2_.filters = Style.getRollOutFilter();
      }
      
      public static function setSelected(param1:Sprite, param2:Boolean = true) : void
      {
         if(param1 is MovieClip)
         {
            MovieClip(param1).gotoAndStop(param2 ? 2 : 1);
         }
      }
      
      public static function setEnabled(param1:Sprite, param2:Boolean = false) : void
      {
         if(param1.mouseEnabled != param2)
         {
            if(false == param2)
            {
               removeEvent(param1);
               param1.filters = Style.getDisableFilter();
            }
            else if(true == param2)
            {
               addEvent(param1);
               param1.filters = Style.getRollOutFilter();
            }
            param1.mouseEnabled = param2;
            param1.tabEnabled = param2;
         }
      }
   }
}


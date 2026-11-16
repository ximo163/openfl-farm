package com.qzone.qui.effects
{
   import com.qzone.utils.DisplayUtil;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   
   public class TweenEffect extends EventDispatcher
   {
      
      public static var duration:Number = 300;
      
      public function TweenEffect()
      {
         super();
      }
      
      protected static function setSnap(param1:DisplayObjectContainer, param2:DisplayObject, param3:DisplayObject) : void
      {
         param3.visible = true;
         param2.visible = false;
      }
      
      protected static function setPosition(param1:DisplayObject, param2:DisplayObject) : void
      {
         DisplayUtil.copyProperties(param1,param2,["x","y"]);
      }
      
      protected static function getSnap(param1:DisplayObjectContainer, param2:DisplayObject) : BitmapData
      {
         var _loc3_:Rectangle = param2.getRect(param1);
         var _loc4_:BitmapData = new BitmapData(_loc3_.width + 8,_loc3_.height + 8,true,0);
         _loc4_.draw(param2);
         return _loc4_;
      }
   }
}


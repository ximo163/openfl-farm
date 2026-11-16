package com.qzone.utils
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.geom.Rectangle;
   
   public final class GraphicsUtil
   {
      
      public function GraphicsUtil()
      {
         super();
      }
      
      public static function hLine(param1:DisplayObject, param2:uint = 0, param3:Number = 1, param4:Rectangle = null, param5:int = 0) : void
      {
         var _loc6_:Graphics = null;
         if(param1.hasOwnProperty("graphics"))
         {
            _loc6_ = param1["graphics"];
            _loc6_.lineStyle(param5,param2,param3);
            if(param4)
            {
               _loc6_.moveTo(param4.x,param4.y);
               _loc6_.lineTo(param4.width,param4.y);
            }
            else
            {
               _loc6_.moveTo(param1.x,param1.y);
               _loc6_.lineTo(param1.width,param1.y);
            }
            _loc6_.endFill();
         }
      }
      
      public static function draw(param1:DisplayObject, param2:uint = 0, param3:Number = 1, param4:Rectangle = null, param5:Boolean = false, param6:Boolean = true) : void
      {
         var _loc7_:Graphics = null;
         if(param1.hasOwnProperty("graphics"))
         {
            _loc7_ = param1["graphics"];
            if(param6)
            {
               _loc7_.clear();
            }
            if(param5)
            {
               _loc7_.beginFill(param2,param3);
            }
            else
            {
               _loc7_.lineStyle(1,param2,param3);
            }
            if(param4)
            {
               _loc7_.drawRect(param4.x,param4.y,param4.width,param4.height);
            }
            else
            {
               _loc7_.drawRect(0,0,param1.width,param1.height);
            }
            _loc7_.endFill();
         }
      }
   }
}


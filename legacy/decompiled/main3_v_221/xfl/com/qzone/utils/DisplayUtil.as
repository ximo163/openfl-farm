package com.qzone.utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   
   public class DisplayUtil
   {
      
      public function DisplayUtil()
      {
         super();
      }
      
      public static function setEnabled(param1:Object, param2:Boolean, param3:Array) : void
      {
         if(param1)
         {
            param1.mouseEnabled = param2;
            if(param1.hasOwnProperty("mouseChildren"))
            {
               param1.mouseChildren = param2;
            }
            if(param1.hasOwnProperty("buttonMode"))
            {
               param1.buttonMode = param2;
            }
            if(param1.hasOwnProperty("enabled"))
            {
               param1.enabled = param2;
            }
            if(param2)
            {
               param1.filters = [];
            }
            else
            {
               param1.filters = param3;
            }
         }
      }
      
      public static function copyXYWH(param1:DisplayObject, param2:DisplayObject) : void
      {
         copyProperties(param1,param2,["x","y","width","height"]);
      }
      
      public static function removeChild(param1:DisplayObjectContainer, param2:DisplayObject) : DisplayObject
      {
         if(param2)
         {
            if(param2.parent == param1)
            {
               return param1.removeChild(param2);
            }
            return null;
         }
         return null;
      }
      
      public static function removeChildByName(param1:DisplayObjectContainer, param2:String) : DisplayObject
      {
         var _loc3_:DisplayObject = param1.getChildByName(param2);
         return DisplayUtil.removeChild(param1,_loc3_);
      }
      
      public static function removeChildAt(param1:DisplayObjectContainer, param2:int) : DisplayObject
      {
         var _loc3_:DisplayObject = param1.getChildAt(param2);
         return DisplayUtil.removeChild(param1,_loc3_);
      }
      
      public static function disableMouse(param1:InteractiveObject) : void
      {
         if(param1 is InteractiveObject)
         {
            param1.mouseEnabled = false;
         }
         if(param1 is DisplayObjectContainer)
         {
            param1["mouseChildren"] = false;
         }
      }
      
      public static function copyProperties(param1:Object, param2:Object, param3:Array) : void
      {
         var _loc4_:String = null;
         if(Boolean(param1) && Boolean(param2))
         {
            for each(_loc4_ in param3)
            {
               if(param1.hasOwnProperty(_loc4_))
               {
                  param2[_loc4_] = param1[_loc4_];
               }
            }
         }
      }
   }
}


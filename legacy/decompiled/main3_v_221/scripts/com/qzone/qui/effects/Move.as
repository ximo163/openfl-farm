package com.qzone.qui.effects
{
   import com.qzone.qui.managers.EffectManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public class Move extends TweenEffect
   {
      
      public static var distance:int = 30;
      
      public function Move()
      {
         super();
      }
      
      public static function In(param1:DisplayObjectContainer, param2:DisplayObject, param3:Function, param4:Array = null) : Object
      {
         var tweener:Object;
         var bitmap:Bitmap = null;
         var parent:DisplayObjectContainer = param1;
         var target:DisplayObject = param2;
         var callBack:Function = param3;
         var parameters:Array = param4;
         var bitmapData:BitmapData = getSnap(parent,target);
         bitmap = new Bitmap(bitmapData);
         parent.addChild(bitmap);
         setSnap(parent,target,bitmap);
         setPosition(target,bitmap);
         tweener = EffectManager.tweenerClass.from(bitmap,duration / 1000,{
            "alpha":0,
            "y":bitmap.y + distance,
            "onComplete":function():void
            {
               setSnap(parent,bitmap,target);
               setPosition(bitmap,target);
               parent.removeChild(bitmap);
               bitmap.bitmapData = null;
               bitmap = null;
               delete EffectManager.effectInstances[target];
               callBack.apply(null,parameters);
            }
         });
         EffectManager.effectInstances[target] = tweener;
         return tweener;
      }
      
      public static function Out(param1:DisplayObjectContainer, param2:DisplayObject, param3:Function, param4:Array = null) : Object
      {
         var tweener:Object;
         var bitmap:Bitmap = null;
         var parent:DisplayObjectContainer = param1;
         var target:DisplayObject = param2;
         var callBack:Function = param3;
         var parameters:Array = param4;
         parent = target.parent;
         var bitmapData:BitmapData = getSnap(parent,target);
         bitmap = new Bitmap(bitmapData);
         parent.addChild(bitmap);
         setSnap(parent,target,bitmap);
         setPosition(target,bitmap);
         tweener = EffectManager.tweenerClass.to(bitmap,duration / 1000,{
            "alpha":0,
            "y":bitmap.y - distance,
            "onComplete":function():void
            {
               setSnap(parent,bitmap,target);
               setPosition(bitmap,target);
               parent.removeChild(bitmap);
               bitmap.bitmapData = null;
               bitmap = null;
               delete EffectManager.effectInstances[target];
               callBack.apply(null,parameters);
            }
         });
         EffectManager.effectInstances[target] = tweener;
         return tweener;
      }
   }
}


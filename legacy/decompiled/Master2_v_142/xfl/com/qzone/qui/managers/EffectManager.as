package com.qzone.qui.managers
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class EffectManager extends EventDispatcher
   {
      
      public static var tweenerClass:Object;
      
      public static var comboBaseEffect:Object;
      
      public static var toolTipEffect:Object;
      
      public static var popUpEffect:Object;
      
      public static var effectInstances:Dictionary = new Dictionary(true);
      
      public function EffectManager()
      {
         super();
      }
      
      public static function In(param1:DisplayObjectContainer, param2:DisplayObject, param3:Function = null, ... rest) : void
      {
         playEffect("In",param1,param2,param3,rest);
      }
      
      public static function playEffect(param1:String, param2:DisplayObjectContainer, param3:DisplayObject, param4:Function, param5:Array = null) : void
      {
         if(Boolean(param3.hasOwnProperty("effect")) && Boolean(param3["effect"]) && EffectManager.effectInstances[param3] == null)
         {
            param3["effect"][param1](param2,param3,param4,param5);
         }
         else
         {
            EffectManager.effectInstances[param3] && EffectManager.effectInstances[param3].complete();
            param4.apply(null,param5);
         }
      }
      
      public static function Out(param1:DisplayObjectContainer, param2:DisplayObject, param3:Function, ... rest) : void
      {
         playEffect("Out",param1,param2,param3,rest);
      }
   }
}


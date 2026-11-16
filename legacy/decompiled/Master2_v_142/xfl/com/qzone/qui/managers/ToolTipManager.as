package com.qzone.qui.managers
{
   import com.qzone.qui.controls.ToolTip;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   
   public class ToolTipManager extends EventDispatcher
   {
      
      private static var instance:ToolTipLayer;
      
      public static var flowMouse:Boolean;
      
      private static var _stage:DisplayObjectContainer;
      
      public static var toolTipClass:Class = ToolTip;
      
      public function ToolTipManager()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错 - ToolTipManager");
         }
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _stage = param1;
         getInstance();
      }
      
      public static function hide() : void
      {
         getInstance().hideToolTip();
      }
      
      public static function getInstance() : ToolTipLayer
      {
         if(instance == null)
         {
            instance = new ToolTipLayer();
            if(Boolean(_stage) && Boolean(_stage.stage))
            {
               _stage.stage.addChild(instance);
            }
         }
         return instance;
      }
   }
}


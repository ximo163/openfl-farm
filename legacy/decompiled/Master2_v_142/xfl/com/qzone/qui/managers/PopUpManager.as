package com.qzone.qui.managers
{
   import com.qzone.qui.containers.TitleWindow;
   import com.qzone.utils.AlignUtil;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   
   public class PopUpManager extends EventDispatcher
   {
      
      private static var _stage:DisplayObjectContainer;
      
      private static var instance:PopUpLayer;
      
      public function PopUpManager()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错 - PopUpManager");
         }
      }
      
      public static function get items() : Array
      {
         return instance.items;
      }
      
      public static function removePopUp(param1:DisplayObjectContainer) : DisplayObject
      {
         var _loc2_:TitleWindow = null;
         if(param1 is TitleWindow)
         {
            _loc2_ = param1 as TitleWindow;
            DragManager.removeTarget(_loc2_,_loc2_.headArea);
         }
         getInstance().removePopUp(param1);
         return param1;
      }
      
      public static function addPopUp(param1:DisplayObject, param2:Boolean = false, param3:Boolean = true, param4:DisplayObjectContainer = null) : DisplayObject
      {
         var _loc5_:TitleWindow = null;
         if(param4)
         {
            _stage = param4;
         }
         if(param3)
         {
            centerPopUp(param1);
         }
         getInstance().addPopUp(param1,param4,param2);
         if(param2)
         {
            _stage["root"].tabChildren = false;
         }
         if(param1 is TitleWindow)
         {
            _loc5_ = param1 as TitleWindow;
            DragManager.addTarget(_loc5_,null,_loc5_.headArea);
         }
         return param1;
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _stage = param1.stage;
         getInstance();
      }
      
      public static function getInstance() : PopUpLayer
      {
         if(instance == null)
         {
            instance = new PopUpLayer();
            _stage.addChild(instance);
         }
         return instance;
      }
      
      public static function centerPopUp(param1:DisplayObject) : void
      {
         var _loc2_:int = AlignUtil.middle(_stage.stage.stageWidth,param1.width);
         var _loc3_:int = AlignUtil.middle(_stage.stage.stageHeight,param1.height);
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         param1.x = _loc2_;
         param1.y = _loc3_;
      }
      
      public static function bringToFront(param1:DisplayObjectContainer) : void
      {
         if(instance.numChildren)
         {
            instance.setChildIndex(param1,instance.numChildren - 1);
         }
      }
      
      public static function createPopUp(param1:Class, param2:Boolean = false, param3:Boolean = true, param4:DisplayObjectContainer = null) : DisplayObject
      {
         if(param4)
         {
            _stage = param4;
         }
         var _loc5_:DisplayObjectContainer = new param1();
         addPopUp(_loc5_,param2,param3,param4);
         return _loc5_;
      }
   }
}


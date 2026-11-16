package com.qzone.qui.managers
{
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class DragManager
   {
      
      private static var _hitArea:InteractiveObject;
      
      private static var _rect:Rectangle;
      
      public static var updateAfterEvent:Boolean;
      
      private static var _parent:DisplayObjectContainer;
      
      private static var _draging:Boolean;
      
      private static var _target:Sprite;
      
      public static var autoToFront:Boolean;
      
      private static var _targets:Object = {};
      
      public function DragManager()
      {
         super();
      }
      
      private static function loader_MOUSE_MOVE(param1:MouseEvent) : void
      {
         if(!_draging)
         {
            _draging = true;
            _target.startDrag(false,_rect);
         }
         if(updateAfterEvent)
         {
            param1.updateAfterEvent();
         }
         else
         {
            _parent.removeEventListener(MouseEvent.MOUSE_MOVE,loader_MOUSE_MOVE);
         }
      }
      
      private static function addEvent() : void
      {
         _parent.addEventListener(MouseEvent.MOUSE_MOVE,loader_MOUSE_MOVE);
         _parent.addEventListener(MouseEvent.MOUSE_UP,loader_MOUSE_UP);
      }
      
      public static function removeTarget(param1:Sprite, param2:InteractiveObject = null) : void
      {
         var _loc3_:InteractiveObject = param2 || param1;
         var _loc4_:String = _loc3_.name;
         if(_targets.hasOwnProperty(_loc4_))
         {
            _loc3_.removeEventListener(MouseEvent.MOUSE_DOWN,loader_MOUSE_DOWN);
            delete _targets[_loc4_];
         }
      }
      
      private static function removeEvent() : void
      {
         _parent.removeEventListener(MouseEvent.MOUSE_UP,loader_MOUSE_UP);
         _parent.removeEventListener(MouseEvent.MOUSE_MOVE,loader_MOUSE_MOVE);
      }
      
      private static function loader_MOUSE_DOWN(param1:MouseEvent) : void
      {
         _target = _targets[param1.currentTarget.name].target;
         _rect = _targets[param1.currentTarget.name].rect;
         _parent = _targets[param1.currentTarget.name].parent || _target.stage;
         if(autoToFront)
         {
            PopUpManager.bringToFront(_target);
         }
         addEvent();
      }
      
      public static function addTarget(param1:Sprite, param2:Rectangle = null, param3:InteractiveObject = null, param4:DisplayObjectContainer = null) : void
      {
         _target = param1;
         _parent = param4;
         _rect = param2;
         _hitArea = param3 || param1;
         _targets[_hitArea.name] = {
            "rect":_rect,
            "parent":_parent,
            "target":_target
         };
         _hitArea.addEventListener(MouseEvent.MOUSE_DOWN,loader_MOUSE_DOWN);
      }
      
      private static function loader_MOUSE_UP(param1:MouseEvent) : void
      {
         removeEvent();
         _target.stopDrag();
         if(_draging)
         {
            _target.dispatchEvent(new Event("LOCATION_CHANGE"));
         }
         _draging = false;
      }
   }
}


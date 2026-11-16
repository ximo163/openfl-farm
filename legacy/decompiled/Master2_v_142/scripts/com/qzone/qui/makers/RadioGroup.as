package com.qzone.qui.makers
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class RadioGroup extends EventDispatcher
   {
      
      private var _targets:Array;
      
      private var _target:DisplayObject;
      
      public function RadioGroup()
      {
         super();
         this._targets = [];
      }
      
      public function getTargetIndex(param1:DisplayObject) : int
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._targets.length)
         {
            _loc3_ = this._targets[_loc2_] as DisplayObject;
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getTargets() : Array
      {
         return this._targets;
      }
      
      private function _CHANGE(param1:Event) : void
      {
         this.selectedTarget = param1.currentTarget as DisplayObject;
         this.dispatchEvent(param1);
      }
      
      public function addTarget(param1:DisplayObject) : void
      {
         this._targets.push(param1);
         if(param1.hasOwnProperty("inGroup"))
         {
            param1["inGroup"] = true;
         }
         this.addEvent(param1);
      }
      
      public function removeTarget(param1:DisplayObject) : void
      {
         var _loc2_:int = this.getTargetIndex(param1);
         if(param1.hasOwnProperty("inGroup"))
         {
            param1["inGroup"] = false;
         }
         if(_loc2_ != -1)
         {
            this._targets.splice(_loc2_,1);
         }
         this.removeEvent(param1);
      }
      
      private function removeEvent(param1:DisplayObject) : void
      {
         param1.removeEventListener(Event.CHANGE,this._CHANGE);
      }
      
      public function set selectedTarget(param1:DisplayObject) : void
      {
         var _loc2_:* = undefined;
         this._target = param1;
         for each(_loc2_ in this._targets)
         {
            if(param1 != _loc2_)
            {
               _loc2_.selected = false;
            }
         }
      }
      
      private function addEvent(param1:DisplayObject) : void
      {
         param1.addEventListener(Event.CHANGE,this._CHANGE);
      }
      
      public function getTargetAt(param1:int) : DisplayObject
      {
         return this._targets[param1];
      }
      
      public function get selectedTarget() : DisplayObject
      {
         return this._target;
      }
   }
}


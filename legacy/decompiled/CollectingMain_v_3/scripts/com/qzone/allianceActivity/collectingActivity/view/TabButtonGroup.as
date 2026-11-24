package com.qzone.allianceActivity.collectingActivity.view
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   public class TabButtonGroup extends EventDispatcher
   {
      
      public static var history:Array = [0,0,0];
      
      private var _mode:int;
      
      private var _index:int;
      
      private var _tabs:Array;
      
      public function TabButtonGroup(param1:Array, param2:int, param3:int)
      {
         var _loc4_:MovieClip = null;
         super(null);
         this._tabs = param1;
         this._mode = param3;
         for each(_loc4_ in this._tabs)
         {
            if(_loc4_ != null)
            {
               _loc4_.buttonMode = true;
               _loc4_.mouseChildren = false;
               _loc4_.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
            }
         }
         this._index = -1;
         this.select(param2);
         this.remember();
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = this._tabs.indexOf(param1.target);
         if(this.select(_loc2_) == true)
         {
            dispatchEvent(new Event(Event.CHANGE));
            this.remember();
         }
      }
      
      private function remember() : void
      {
         history[this._mode] = this._index;
      }
      
      public function rebind(param1:Array, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         this._tabs = param1;
         this._mode = param2;
         for each(_loc3_ in this._tabs)
         {
            if(_loc3_ != null)
            {
               _loc3_.buttonMode = true;
               _loc3_.mouseChildren = false;
               _loc3_.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
            }
         }
         _loc4_ = int(history[param2]);
         this._index = -1;
         this.select(_loc4_);
      }
      
      public function get currentSelected() : int
      {
         return this._index;
      }
      
      public function destroy() : void
      {
         this._tabs = null;
         this._index = -1;
         this._mode = 0;
      }
      
      public function select(param1:int) : Boolean
      {
         var _loc2_:MovieClip = null;
         if(this._index == param1)
         {
            return false;
         }
         if(param1 >= this._tabs.length || param1 < 0)
         {
            return false;
         }
         for each(_loc2_ in this._tabs)
         {
            if(_loc2_ != null)
            {
               _loc2_.gotoAndStop(1);
            }
         }
         this._tabs[param1]["gotoAndStop"](2);
         this._index = param1;
         return true;
      }
   }
}


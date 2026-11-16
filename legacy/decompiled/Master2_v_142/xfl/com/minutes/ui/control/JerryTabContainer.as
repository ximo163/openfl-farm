package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiUIComponent;
   import flash.display.DisplayObject;
   
   public class JerryTabContainer extends LipiUIComponent
   {
      
      private var indexChange:Boolean = false;
      
      private var _index:int = 0;
      
      private var _list:Array = [];
      
      public function JerryTabContainer()
      {
         super();
         this.bgAlpha = 0;
      }
      
      public function getDisplayObject(param1:int) : DisplayObject
      {
         if(param1 >= 0 && this._list.length > 0 && param1 < this._list.length)
         {
            return this._list[param1];
         }
         return null;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 >= 0 && this._list.length > 0 && param1 < this._list.length)
         {
            if(this.contains(this._list[this._index]))
            {
               this.removeChild(this._list[this._index]);
            }
            this._index = param1;
            this.indexChange = true;
            invalidateDisplayList();
         }
      }
      
      public function addItem(param1:DisplayObject) : void
      {
         this._list.push(param1);
      }
      
      private function refurbishDisplay() : void
      {
         this.addChild(this._list[this.selectedIndex]);
      }
      
      public function get selectedIndex() : int
      {
         return this._index;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.indexChange)
         {
            this.refurbishDisplay();
            this.indexChange = false;
         }
      }
   }
}


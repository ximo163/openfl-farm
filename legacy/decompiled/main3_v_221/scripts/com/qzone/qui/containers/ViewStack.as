package com.qzone.qui.containers
{
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   
   public class ViewStack extends Container
   {
      
      private var _currentChild:DisplayObject;
      
      private var _childObject:Dictionary;
      
      private var _currentIndex:int = -1;
      
      private var _childArray:Array = [];
      
      public function ViewStack()
      {
         super();
         this._childObject = new Dictionary();
      }
      
      public function addView(param1:DisplayObject) : DisplayObject
      {
         if(!this._childObject[param1.name])
         {
            this._childArray.push(param1);
            this._childObject[param1] = true;
            if(this._childArray.length == 1)
            {
               this._currentChild = content.addChild(param1);
               this._currentIndex = 0;
            }
         }
         return param1;
      }
      
      public function removeView(param1:DisplayObject) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.content.contains(param1))
         {
            _loc2_ = int(this._childArray.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(this._childArray[_loc3_] == param1)
               {
                  this._childArray.splice(_loc3_,1);
                  delete this._childObject[param1];
                  this.content.removeChild(param1);
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      public function set selectedItem(param1:DisplayObject) : void
      {
         this.unselect(this._currentChild);
         this.select(param1);
      }
      
      private function unselect(param1:DisplayObject) : void
      {
         if(Boolean(param1) && Boolean(param1.parent))
         {
            param1.parent.removeChild(param1);
         }
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this.unselect(this._currentChild);
         this._currentChild = this._childArray[param1];
         this.select(this._currentChild);
         this._currentIndex = param1;
      }
      
      private function select(param1:DisplayObject) : void
      {
         if(param1)
         {
            content.addChild(param1);
            this._currentChild = param1;
         }
      }
      
      public function get selectedItem() : DisplayObject
      {
         return this._currentChild;
      }
      
      public function get selectedIndex() : int
      {
         return this._currentIndex;
      }
   }
}


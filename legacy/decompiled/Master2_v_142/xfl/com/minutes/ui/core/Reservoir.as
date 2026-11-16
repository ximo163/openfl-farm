package com.minutes.ui.core
{
   public class Reservoir
   {
      
      private var useArray:Array;
      
      private var ClassObject:Class;
      
      private var unusedArray:Array;
      
      public function Reservoir(param1:Class)
      {
         super();
         this.ClassObject = param1;
         this.useArray = new Array();
         this.unusedArray = new Array();
      }
      
      public function delInstance(param1:Object) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.useArray.length)
         {
            if(this.useArray[_loc2_] == param1)
            {
               this.unusedArray.push(this.useArray.splice(_loc2_,1)[0]);
               break;
            }
            _loc2_++;
         }
      }
      
      public function getInstance() : Object
      {
         var _loc1_:Object = null;
         if(this.unusedArray.length > 0)
         {
            _loc1_ = this.unusedArray.pop();
         }
         else
         {
            _loc1_ = new this.ClassObject();
         }
         this.useArray.push(_loc1_);
         return _loc1_;
      }
   }
}


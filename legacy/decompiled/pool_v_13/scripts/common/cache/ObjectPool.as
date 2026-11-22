package common.cache
{
   public class ObjectPool
   {
      
      private var _factory:IObjectPoolFactory;
      
      private var _usageCount:int;
      
      private var _initSize:int;
      
      private var _allocNode:ObjNode;
      
      private var _tail:ObjNode;
      
      private var _currSize:int;
      
      private var _emptyNode:ObjNode;
      
      private var _grow:Boolean = true;
      
      private var _head:ObjNode;
      
      public function ObjectPool(param1:Boolean = false)
      {
         super();
         this._grow = param1;
      }
      
      public function get size() : int
      {
         return this._currSize;
      }
      
      public function purge() : void
      {
         var _loc1_:* = 0;
         var _loc2_:ObjNode = null;
         var _loc3_:Array = null;
         var _loc4_:ObjNode = null;
         var _loc5_:ObjNode = null;
         var _loc6_:int = 0;
         if(this._usageCount == 0)
         {
            if(this._currSize == this._initSize)
            {
               return;
            }
            if(this._currSize > this._initSize)
            {
               _loc1_ = 0;
               _loc2_ = this._head;
               while(++_loc1_ < this._initSize)
               {
                  _loc2_ = _loc2_.next;
               }
               this._allocNode = this._emptyNode = this._head;
               this._tail = _loc2_;
               this._tail.next = this._head;
               this._currSize = this._initSize;
               return;
            }
         }
         else
         {
            _loc3_ = [];
            _loc2_ = this._head;
            while(_loc2_)
            {
               if(!_loc2_.data)
               {
                  _loc3_[int(_loc1_++)] = _loc2_;
               }
               if(_loc2_ == this._tail)
               {
                  break;
               }
               _loc2_ = _loc2_.next;
            }
            this._currSize = _loc3_.length;
            this._usageCount = this._currSize;
            this._head = this._tail = _loc3_[0];
            _loc1_ = 1;
            while(_loc1_ < this._currSize)
            {
               _loc2_ = _loc3_[_loc1_];
               _loc2_.next = this._head;
               this._head = _loc2_;
               _loc1_++;
            }
            this._allocNode = this._emptyNode = this._head;
            this._tail.next = this._head;
            if(this._usageCount < this._initSize)
            {
               this._currSize = this._initSize;
               _loc4_ = this._tail;
               _loc5_ = this._tail;
               _loc6_ = this._initSize - this._usageCount;
               _loc1_ = 0;
               while(_loc1_ < _loc6_)
               {
                  _loc2_ = new ObjNode();
                  _loc2_.data = this.createObject();
                  _loc5_.next = _loc2_;
                  _loc5_ = _loc2_;
                  _loc1_++;
               }
               this._tail = _loc5_;
               this._tail.next = this._emptyNode = this._head;
               this._allocNode = _loc4_.next;
            }
         }
      }
      
      public function setFactory(param1:IObjectPoolFactory) : void
      {
         this._factory = param1;
      }
      
      public function restore(param1:*) : void
      {
         if(this._usageCount > 0)
         {
            --this._usageCount;
            this._emptyNode.data = param1;
            this._emptyNode = this._emptyNode.next;
         }
      }
      
      public function get wasteCount() : int
      {
         return this._currSize - this._usageCount;
      }
      
      private function createObject() : *
      {
         if(this._factory == null)
         {
            return null;
         }
         return this._factory.create();
      }
      
      public function get usageCount() : int
      {
         return this._usageCount;
      }
      
      public function borrow() : *
      {
         var _loc2_:ObjNode = null;
         var _loc3_:ObjNode = null;
         var _loc4_:ObjNode = null;
         var _loc5_:int = 0;
         if(this._usageCount == this._currSize)
         {
            if(!(this._grow == true && this._initSize > 0))
            {
               throw new Error("object pool exhausted.");
            }
            this._currSize += this._initSize;
            _loc2_ = this._tail;
            _loc3_ = this._tail;
            _loc5_ = 0;
            while(_loc5_ < this._initSize)
            {
               _loc4_ = new ObjNode();
               _loc4_.data = this.createObject();
               _loc3_.next = _loc4_;
               _loc3_ = _loc4_;
               _loc5_++;
            }
            this._tail = _loc3_;
            this._tail.next = this._head;
            this._emptyNode = this._head;
            this._allocNode = _loc2_.next;
         }
         var _loc1_:* = this._allocNode.data;
         this._allocNode.data = null;
         this._allocNode = this._allocNode.next;
         ++this._usageCount;
         return _loc1_;
      }
      
      public function initialze(param1:String, param2:Array) : void
      {
         var _loc3_:ObjNode = this._head;
         while(_loc3_)
         {
            _loc3_.data[param1].apply(_loc3_.data,param2);
            if(_loc3_ == this._tail)
            {
               break;
            }
            _loc3_ = _loc3_.next;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:ObjNode = null;
         var _loc1_:ObjNode = this._head;
         while(_loc1_)
         {
            _loc2_ = _loc1_.next;
            _loc1_.next = null;
            _loc1_.data = null;
            _loc1_ = _loc2_;
         }
         this._head = this._tail = this._emptyNode = this._allocNode = null;
      }
      
      public function allocate(param1:uint, param2:Class = null) : void
      {
         var _loc3_:ObjNode = null;
         this.destroy();
         if(param2)
         {
            this._factory = new SimpleFactory(param2);
         }
         else if(!this._factory)
         {
            throw new Error("nothing to instantiate.");
         }
         this._initSize = this._currSize = param1;
         this._head = this._tail = new ObjNode();
         this._head.data = this.createObject();
         var _loc4_:int = 1;
         while(_loc4_ < this._initSize)
         {
            _loc3_ = new ObjNode();
            _loc3_.data = this.createObject();
            _loc3_.next = this._head;
            this._head = _loc3_;
            _loc4_++;
         }
         this._emptyNode = this._allocNode = this._head;
         this._tail.next = this._head;
      }
   }
}

class ObjNode
{
   
   public var data:*;
   
   public var next:ObjNode;
   
   public function ObjNode()
   {
      super();
   }
}

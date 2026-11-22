package module.water
{
   import common.cache.ObjectPool;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   
   public class FishMCPoolObjectMgr
   {
      
      private static const POOL_GROW_SIZE:uint = 2;
      
      private var _linkageClasses:Dictionary;
      
      private var _map:Dictionary;
      
      public function FishMCPoolObjectMgr()
      {
         super();
         this._linkageClasses = new Dictionary();
         this._map = new Dictionary();
      }
      
      public function destroy() : void
      {
         var _loc3_:String = null;
         var _loc1_:ObjectPool = null;
         var _loc2_:Class = null;
         for(_loc3_ in this._linkageClasses)
         {
            _loc2_ = this._linkageClasses[_loc3_] as Class;
            delete this._linkageClasses[_loc3_];
            if(_loc2_ != null)
            {
               _loc1_ = this._map[_loc2_] as ObjectPool;
               if(_loc1_ != null)
               {
                  _loc1_.destroy();
               }
               delete this._map[_loc2_];
            }
         }
      }
      
      public function register(param1:String) : ObjectPool
      {
         var _loc3_:ObjectPool = null;
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(ApplicationDomain.currentDomain.hasDefinition(param1) == false)
         {
            return null;
         }
         var _loc2_:Class = this._linkageClasses[param1] as Class;
         if(_loc2_ != null)
         {
            if(this._map[_loc2_] != null)
            {
               return this._map[_loc2_] as ObjectPool;
            }
         }
         _loc2_ = ApplicationDomain.currentDomain.getDefinition(param1) as Class;
         if(_loc2_ != null)
         {
            _loc3_ = new ObjectPool(true);
            this._linkageClasses[param1] = _loc2_;
            this._map[_loc2_] = _loc3_;
            return _loc3_;
         }
         return null;
      }
      
      public function getObject(param1:String) : Object
      {
         if(param1 == null || param1 == "")
         {
            return null;
         }
         var _loc2_:Class = this._linkageClasses[param1] as Class;
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc3_:ObjectPool = this._map[_loc2_] as ObjectPool;
         if(_loc3_ == null)
         {
            return null;
         }
         if(_loc3_.size == 0)
         {
            _loc3_.allocate(POOL_GROW_SIZE,_loc2_);
         }
         return _loc3_.borrow();
      }
      
      public function returnObject(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc2_:ObjectPool = null;
         var _loc3_:Class = null;
         for(_loc4_ in this._linkageClasses)
         {
            _loc3_ = this._linkageClasses[_loc4_] as Class;
            if(_loc3_ != null)
            {
               if(param1 is _loc3_)
               {
                  _loc2_ = this._map[_loc3_] as ObjectPool;
                  if(_loc2_ != null)
                  {
                     _loc2_.restore(param1);
                  }
                  break;
               }
            }
         }
      }
      
      public function gc() : void
      {
         var _loc3_:String = null;
         var _loc1_:ObjectPool = null;
         var _loc2_:Class = null;
         for(_loc3_ in this._linkageClasses)
         {
            _loc2_ = this._linkageClasses[_loc3_] as Class;
            if(_loc2_ != null)
            {
               _loc1_ = this._map[_loc2_] as ObjectPool;
               if(_loc1_ != null)
               {
                  _loc1_.purge();
               }
            }
         }
      }
      
      public function unregister(param1:String) : ObjectPool
      {
         var _loc3_:ObjectPool = null;
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(ApplicationDomain.currentDomain.hasDefinition(param1) == false)
         {
            return null;
         }
         var _loc2_:Class = this._linkageClasses[param1] as Class;
         if(_loc2_ != null)
         {
            _loc3_ = this._map[param1] as ObjectPool;
            delete this._linkageClasses[param1];
            delete this._map[_loc2_];
            return _loc3_;
         }
         return null;
      }
      
      public function contains(param1:String) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            return false;
         }
         if(this._linkageClasses[param1] == null)
         {
            return false;
         }
         return true;
      }
   }
}


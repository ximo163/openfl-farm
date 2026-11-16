package com.qzone.qfa.model
{
   import com.qzone.qfa.interfaces.IModel;
   import com.qzone.qfa.interfaces.INotifier;
   import flash.utils.Dictionary;
   
   public class AppData implements IModel, INotifier
   {
      
      private static var _instance:AppData;
      
      private var dataList:Dictionary;
      
      private var notifierMap:Dictionary;
      
      public function AppData(param1:SingletonEnforcer)
      {
         super();
         this.dataList = new Dictionary();
         this.notifierMap = new Dictionary();
      }
      
      public static function gi() : AppData
      {
         return _instance = _instance || new AppData(new SingletonEnforcer());
      }
      
      public static function get instance() : AppData
      {
         return gi();
      }
      
      public function getData(param1:String) : Object
      {
         return this.dataList[param1];
      }
      
      public function flush() : void
      {
         this.dataList = new Dictionary();
         this.notifierMap = new Dictionary();
      }
      
      public function removeNotifier(param1:String, param2:Function) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(!this.hasData(param1))
         {
            return;
         }
         var _loc3_:Array = this.notifierMap[param1] as Array;
         if(_loc3_)
         {
            _loc5_ = 0;
            _loc4_ = int(_loc3_.length);
            while(_loc5_ < _loc4_)
            {
               if(_loc3_[_loc5_] == param2)
               {
                  _loc3_.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
         }
      }
      
      public function hasData(param1:String) : Boolean
      {
         return param1 in this.dataList;
      }
      
      public function setData(param1:String, param2:Object) : Boolean
      {
         if(param1)
         {
            this.dataList[param1] = param2;
            this.notify(param1);
            return true;
         }
         return false;
      }
      
      public function notify(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this.hasData(param1))
         {
            return;
         }
         var _loc2_:Array = this.notifierMap[param1] as Array;
         if(_loc2_)
         {
            _loc4_ = 0;
            _loc3_ = int(_loc2_.length);
            while(_loc4_ < _loc3_)
            {
               if(_loc2_[_loc4_] is Function)
               {
                  _loc2_[_loc4_](this.dataList[param1]);
               }
               _loc4_++;
            }
         }
      }
      
      public function toString() : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc1_:String = "";
         for(_loc2_ in this.dataList)
         {
            _loc1_ += _loc2_ + ":" + this.dataList[_loc2_] + "\n";
            for(_loc3_ in this.dataList[_loc2_])
            {
               _loc1_ += "|-" + _loc3_ + ":" + this.dataList[_loc2_][_loc3_] + "\n";
            }
         }
         return _loc1_;
      }
      
      public function addNotifier(param1:String, param2:Function) : void
      {
         if(!this.notifierMap[param1])
         {
            this.notifierMap[param1] = [];
         }
         param2(this.dataList[param1]);
         var _loc3_:Array = this.notifierMap[param1] as Array;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            if(_loc3_[_loc4_] == param2)
            {
               return;
            }
            _loc4_++;
         }
         _loc3_.push(param2);
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}

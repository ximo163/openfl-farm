package common
{
   import flash.display.BitmapData;
   import flash.system.ApplicationDomain;
   
   public class MaterialLib
   {
      
      private static var instance:MaterialLib;
      
      private var _cachedBitmapData:Object = {};
      
      private var _materialArray:Array = [];
      
      private var _materialUrlArr:Array = [];
      
      public function MaterialLib()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错-MaterialLib");
         }
      }
      
      public static function getInstance() : MaterialLib
      {
         if(instance == null)
         {
            instance = new MaterialLib();
         }
         return instance;
      }
      
      public function getClass(param1:String) : Class
      {
         return this.searchClass(param1);
      }
      
      public function getCachedBitmapData(param1:String, param2:int, param3:int) : BitmapData
      {
         var _loc5_:BitmapData = null;
         if(this._cachedBitmapData.hasOwnProperty(param1))
         {
            return this._cachedBitmapData[param1];
         }
         var _loc4_:Class = this.getClass(param1);
         if(_loc4_)
         {
            _loc5_ = new _loc4_(param2,param3) as BitmapData;
            if(_loc5_ is BitmapData)
            {
               this._cachedBitmapData[param1] = _loc5_;
            }
            return _loc5_;
         }
         return null;
      }
      
      public function hasUrl(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:int = int(this._materialUrlArr.length);
         while(_loc3_ < _loc4_)
         {
            if(this._materialUrlArr[_loc3_] == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function searchClass(param1:String) : Class
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(this._materialArray.length);
         while(_loc2_ < _loc3_)
         {
            if((this._materialArray[_loc2_] as ApplicationDomain).hasDefinition(param1))
            {
               return (this._materialArray[_loc2_] as ApplicationDomain).getDefinition(param1) as Class;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function push(param1:ApplicationDomain, param2:String = "") : void
      {
         if(param2 != "")
         {
            this._materialUrlArr.push(param2);
         }
         this._materialArray.push(param1);
      }
      
      public function getMaterial(param1:String) : Object
      {
         var _loc2_:Class = this.getClass(param1);
         if(_loc2_ != null)
         {
            return new _loc2_();
         }
         return null;
      }
   }
}


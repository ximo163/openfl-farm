package entities
{
   import common.misc.Utils;
   
   public final class ShopFish
   {
      
      public var _lock_crystal:String;
      
      public var _pool_size:int;
      
      public var _lock:int;
      
      public var _type:int;
      
      public var _exp:int;
      
      public var _output:int;
      
      public var _price:int;
      
      public var _sale:int;
      
      public var _mature:int;
      
      public var _name:String;
      
      public var _lock_gold:int;
      
      public var _id:int;
      
      public function ShopFish(param1:Object)
      {
         super();
         this._lock = -1;
         this._lock_gold = 0;
         this._lock_crystal = "";
         this._name = "";
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"fid");
         this._lock = Utils.getIntAttribute(param1,"lock");
         this._type = Utils.getIntAttribute(param1,"type");
      }
   }
}


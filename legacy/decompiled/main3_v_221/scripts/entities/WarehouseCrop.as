package entities
{
   import common.misc.Utils;
   
   public final class WarehouseCrop
   {
      
      public var _isFood:int;
      
      public var _price:int;
      
      public var _isFlower:int;
      
      public var _high_price:int;
      
      public var _type:int;
      
      public var _isVip:int;
      
      public var _ext:*;
      
      public var _lvl:int;
      
      public var _name:String;
      
      public var _isLock:int;
      
      public var _amount:int;
      
      public var _id:int;
      
      public var _sort:int;
      
      public function WarehouseCrop(param1:Object)
      {
         super();
         this._isLock = -1;
         this._isFlower = -1;
         this._isFood = -1;
         this._sort = 0;
         this._high_price = -1;
         this._type = -1;
         this._isVip = -1;
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"cId");
         this._name = Utils.getStrAttribute(param1,"cName");
         this._ext = param1["ext"];
         this._lvl = Utils.getIntAttribute(param1,"level");
         this._price = Utils.getIntAttribute(param1,"price");
         this._amount = Utils.getIntAttribute(param1,"amount");
         this._type = Utils.getIntAttribute(param1,"type");
         if(param1["isLock"] != undefined)
         {
            this._isLock = Utils.getIntAttribute(param1,"isLock");
         }
         if(param1["isFlower"] != undefined)
         {
            this._isFlower = param1["isFlower"] == "1" ? 1 : 0;
         }
         if(param1["isFood"] != undefined)
         {
            this._isFood = param1["isFood"] == "1" ? 1 : 0;
         }
         if(param1["high_price"] != undefined)
         {
            this._high_price = Utils.getIntAttribute(param1,"high_price");
         }
         if(param1["isVIP"] != undefined)
         {
            this._isVip = Utils.getIntAttribute(param1,"isVIP");
         }
      }
   }
}


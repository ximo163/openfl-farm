package entities
{
   import common.misc.Utils;
   
   public final class WarehouseSeed
   {
      
      public var _isVip:int;
      
      public var _ext:*;
      
      public var _lvl:int;
      
      public var _price:int;
      
      public var _lifecycle:int;
      
      public var _name:String;
      
      public var _amount:int;
      
      public var _type:int;
      
      public var _id:int;
      
      public function WarehouseSeed(param1:Object)
      {
         super();
         this._isVip = -1;
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1["cId"] != undefined)
         {
            this._id = Utils.getIntAttribute(param1,"cId");
         }
         else if(param1["tId"] != undefined)
         {
            this._id = Utils.getIntAttribute(param1,"tId");
         }
         this._name = Utils.getStrAttribute(param1,"cName");
         this._lifecycle = Utils.getIntAttribute(param1,"lifecycle");
         this._lvl = Utils.getIntAttribute(param1,"level");
         this._price = Utils.getIntAttribute(param1,"price");
         this._amount = Utils.getIntAttribute(param1,"amount");
         this._type = Utils.getIntAttribute(param1,"type");
         this._ext = param1["ext"];
         if(param1["isVIP"] != undefined)
         {
            this._isVip = Utils.getIntAttribute(param1,"isVIP");
         }
      }
   }
}


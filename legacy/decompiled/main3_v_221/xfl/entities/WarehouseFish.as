package entities
{
   import common.misc.Utils;
   
   public final class WarehouseFish
   {
      
      public var _sale:int;
      
      public var _name:String;
      
      public var _isLock:int;
      
      public var _amount:int;
      
      public var _type:int;
      
      public var _id:int;
      
      public function WarehouseFish(param1:Object)
      {
         super();
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
         this._type = Utils.getIntAttribute(param1,"type");
         this._amount = Utils.getIntAttribute(param1,"num");
         if(param1["lock"] != undefined)
         {
            this._isLock = Utils.getIntAttribute(param1,"lock");
         }
      }
   }
}


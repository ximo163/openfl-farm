package entities
{
   import common.misc.Utils;
   
   public class DecorateItem
   {
      
      public var _created:int;
      
      public var _name:String;
      
      public var _validTime:int;
      
      public var _itemId:int;
      
      public var _price:int;
      
      public var _status:int;
      
      public var _type:int;
      
      public var _id:int;
      
      public var _exp:int;
      
      public function DecorateItem(param1:Object)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"id");
         this._itemId = Utils.getIntAttribute(param1,"itemId");
         this._name = Utils.getStrAttribute(param1,"itemName");
         this._type = Utils.getIntAttribute(param1,"itemType");
         this._price = Utils.getIntAttribute(param1,"price");
         this._exp = Utils.getIntAttribute(param1,"exp");
         this._status = Utils.getIntAttribute(param1,"status");
         this._validTime = Utils.getIntAttribute(param1,"validTime");
         this._created = Utils.getIntAttribute(param1,"created");
      }
   }
}


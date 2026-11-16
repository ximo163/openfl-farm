package entities
{
   import common.misc.Utils;
   
   public final class DIYDecor
   {
      
      public var _yfb:int;
      
      public var _price:int;
      
      public var _isNew:int;
      
      public var _type:int;
      
      public var _exp:int;
      
      public var _fb:int;
      
      public var _lvl:int;
      
      public var _validTime:int;
      
      public var _alreadyOwn:Boolean = false;
      
      public var _desc:String;
      
      public var _name:String;
      
      public var _id:int;
      
      public function DIYDecor(param1:Object)
      {
         super();
         this._isNew = -1;
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"itemId");
         this._name = Utils.getStrAttribute(param1,"itemName");
         this._type = Utils.getIntAttribute(param1,"itemType");
         this._desc = Utils.getStrAttribute(param1,"itemDesc");
         this._fb = Utils.getIntAttribute(param1,"FBPrice");
         this._yfb = Utils.getIntAttribute(param1,"YFBPrice");
         this._price = Utils.getIntAttribute(param1,"price");
         this._exp = Utils.getIntAttribute(param1,"exp");
         this._validTime = Utils.getIntAttribute(param1,"itemValidTime");
         this._lvl = Utils.getIntAttribute(param1,"level");
         if(param1["isNew"] != undefined)
         {
            this._isNew = Utils.getIntAttribute(param1,"isNew");
         }
      }
      
      public function importFromCache(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = param1._id;
         this._name = param1._name;
         this._type = param1._type;
         this._desc = param1._desc;
         this._fb = param1._fb;
         this._yfb = param1._yfb;
         this._price = param1._price;
         this._exp = param1._exp;
         this._validTime = param1._validTime;
         this._lvl = param1._lvl;
         this._isNew = param1._isNew;
      }
   }
}


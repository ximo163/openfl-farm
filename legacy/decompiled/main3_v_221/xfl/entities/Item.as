package entities
{
   import common.misc.Utils;
   
   public final class Item
   {
      
      public var _isQDDog:Boolean;
      
      public var _saleOut:Boolean;
      
      public var _price:int;
      
      public var _Ybuy_12:int;
      
      public var _renew:Boolean;
      
      public var _type:int;
      
      public var _vip:int;
      
      public var _shortage:Boolean;
      
      public var _Ybuy_6:int;
      
      public var _buy_12:int;
      
      public var _name:String;
      
      public var _Ybuy_1:int;
      
      public var _timeLimit:int;
      
      public var _desc:String;
      
      public var _fb:int;
      
      public var _effect:*;
      
      public var _buy_1:int;
      
      public var _id:int;
      
      public var _yfb:int;
      
      public var _buy_6:int;
      
      public function Item(param1:Object)
      {
         super();
         this._saleOut = false;
         this._isQDDog = false;
         this._renew = false;
         this._buy_1 = this._buy_6 = this._buy_12 = this._Ybuy_1 = this._Ybuy_6 = this._Ybuy_12 = 0;
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"tId");
         this._name = Utils.getStrAttribute(param1,"tName");
         this._type = Utils.getIntAttribute(param1,"type");
         this._fb = Utils.getIntAttribute(param1,"FBPrice");
         this._yfb = Utils.getIntAttribute(param1,"YFBPrice");
         this._price = Utils.getIntAttribute(param1,"price");
         this._desc = Utils.getStrAttribute(param1,"depict");
         this._effect = Utils.getStrAttribute(param1,"effect");
         this._timeLimit = Utils.getIntAttribute(param1,"timeLimit");
         this._vip = Utils.getIntAttribute(param1,"is_vip");
         if(param1["saleOut"] != undefined)
         {
            this._saleOut = param1["saleOut"] as Boolean;
         }
         this._shortage = param1["saleOut"] == 1;
         if(param1["isQd"] != undefined)
         {
            this._isQDDog = Boolean(param1["isQd"]);
         }
         if(param1["buy_1"] != undefined)
         {
            this._buy_1 = Utils.getIntAttribute(param1,"buy_1");
         }
         if(param1["buy_6"] != undefined)
         {
            this._buy_6 = Utils.getIntAttribute(param1,"buy_6");
         }
         if(param1["buy_12"] != undefined)
         {
            this._buy_12 = Utils.getIntAttribute(param1,"buy_12");
         }
         if(param1["Ybuy_1"] != undefined)
         {
            this._Ybuy_1 = Utils.getIntAttribute(param1,"Ybuy_1");
         }
         if(param1["Ybuy_6"] != undefined)
         {
            this._Ybuy_6 = Utils.getIntAttribute(param1,"Ybuy_6");
         }
         if(param1["Ybuy_12"] != undefined)
         {
            this._Ybuy_12 = Utils.getIntAttribute(param1,"Ybuy_12");
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
         this._fb = param1._fb;
         this._yfb = param1._yfb;
         this._price = param1._price;
         this._desc = param1._desc;
         this._effect = param1._effect;
         this._timeLimit = param1._timeLimit;
         this._saleOut = param1._saleOut;
         this._shortage = param1._shortage;
         this._vip = param1._vip;
      }
   }
}


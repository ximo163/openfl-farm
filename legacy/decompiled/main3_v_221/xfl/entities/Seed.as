package entities
{
   import common.misc.Utils;
   
   public final class Seed
   {
      
      public var _isMill:int;
      
      public var _isRed:Boolean;
      
      public var _vipDesc:String;
      
      public var _isVip:int;
      
      public var _isNew:int;
      
      public var _type:int;
      
      public var _sellTime:String;
      
      public var _output:int;
      
      public var _sellLimit:String;
      
      public var _growCycle:int;
      
      public var _sale:int;
      
      public var _matureTime:int;
      
      public var _isBlack:Boolean;
      
      public var _isGreen:Boolean;
      
      public var _sellLimitDaily:String;
      
      public var _high_sale:int;
      
      public var _isFood:int;
      
      public var _id:int;
      
      public var _price:int;
      
      public var _rl:String;
      
      public var _isAdSeed:int;
      
      public var _exp:int;
      
      public var _lvl:int;
      
      public var _isRestaurant:int;
      
      public var _name:String;
      
      public var _expect:int;
      
      public var _sort:int;
      
      public var _isActivity:int;
      
      public function Seed(param1:Object)
      {
         super();
         this._isFood = this._isRestaurant = this._isActivity = -1;
         this._sort = 0;
         this._isRed = false;
         this._isBlack = false;
         this._isGreen = false;
         this._high_sale = -1;
         this._isMill = -1;
         this._isVip = -1;
         this._isNew = -1;
         this._isAdSeed = -1;
         this._rl = "";
         this._sellTime = "";
         this._sellLimit = "";
         this._sellLimitDaily = "";
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = Utils.getIntAttribute(param1,"cId");
         this._lvl = Utils.getIntAttribute(param1,"cLevel");
         this._name = Utils.getStrAttribute(param1,"cName");
         this._type = Utils.getIntAttribute(param1,"cType");
         this._exp = Utils.getIntAttribute(param1,"cropExp");
         this._expect = Utils.getIntAttribute(param1,"expect");
         this._growCycle = Utils.getIntAttribute(param1,"growthCycle");
         this._matureTime = Utils.getIntAttribute(param1,"maturingTime");
         this._output = Utils.getIntAttribute(param1,"output");
         this._price = Utils.getIntAttribute(param1,"price");
         this._sale = Utils.getIntAttribute(param1,"sale");
         if(param1["isFood"] != undefined)
         {
            this._isFood = Utils.getIntAttribute(param1,"isFood");
         }
         if(param1["isRestaurant"] != undefined)
         {
            this._isRestaurant = Utils.getIntAttribute(param1,"isRestaurant");
         }
         if(param1["isActivity"] != undefined)
         {
            this._isActivity = Utils.getIntAttribute(param1,"isActivity");
         }
         if(param1["high_sale"] != undefined)
         {
            this._high_sale = Utils.getIntAttribute(param1,"high_sale");
         }
         if(param1["isMill"] != undefined)
         {
            this._isMill = Utils.getIntAttribute(param1,"isMill");
         }
         if(param1["isNew"] != undefined)
         {
            this._isNew = Utils.getIntAttribute(param1,"isNew");
         }
         if(param1["isVIP"] != undefined)
         {
            this._isVip = Utils.getIntAttribute(param1,"isVIP");
         }
         if(param1["vipDesc"] != undefined)
         {
            this._vipDesc = Utils.getStrAttribute(param1,"vipDesc");
         }
         if(param1["actPeroid"] != undefined)
         {
            this._sellTime = Utils.getStrAttribute(param1,"actPeroid");
         }
         if(param1["actProvideAmt"] != undefined)
         {
            this._sellLimitDaily = Utils.getStrAttribute(param1,"actProvideAmt");
         }
         if(param1["actTotalAmt"] != undefined)
         {
            this._sellLimit = Utils.getStrAttribute(param1,"actTotalAmt");
         }
      }
      
      public function importFromCache(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = param1._id;
         this._lvl = param1._lvl;
         this._name = param1._name;
         this._type = param1._type;
         this._exp = param1._exp;
         this._expect = param1._expect;
         this._growCycle = param1._growCycle;
         this._matureTime = param1._matureTime;
         this._output = param1._output;
         this._price = param1._price;
         this._sale = param1._sale;
         this._isFood = param1._isFood;
         this._isRestaurant = param1._isRestaurant;
         this._isActivity = param1._isActivity;
         this._isMill = param1._isMill;
         this._sort = param1._sort;
         this._isRed = param1._isRed;
         this._isBlack = param1._isBlack;
         this._isVip = param1._isVip;
         this._high_sale = param1._high_sale;
         this._vipDesc = param1._vipDesc;
      }
   }
}


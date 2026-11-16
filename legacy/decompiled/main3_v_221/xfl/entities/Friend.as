package entities
{
   import common.Settings;
   import common.misc.Utils;
   
   public final class Friend
   {
      
      public var _money:Number;
      
      public var _yellowstatus:int;
      
      public var _pastureExp:int;
      
      public var _moralExp:int;
      
      public var _headPic:String;
      
      public var _userName:String;
      
      public var _yellowlevel:int;
      
      public var _uin:uint;
      
      public var _pf:int;
      
      public var _exp:int;
      
      public var me:Boolean;
      
      public var _userId:uint;
      
      public var sort:int;
      
      public var _uId:uint;
      
      public var status:Object;
      
      public function Friend(param1:*)
      {
         super();
         this._userId = 0;
         this.status = null;
         this.me = false;
         this.sort = 0;
         this.importObject(param1);
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._uId = Utils.getIntAttribute(param1,"uId");
         this._uin = Utils.getIntAttribute(param1,"uin");
         this._exp = Utils.getIntAttribute(param1,"exp");
         this._money = Utils.getIntAttribute(param1,"money");
         this._pf = Utils.getIntAttribute(param1,"pf");
         this._userName = Utils.getStrAttribute(param1,"userName");
         this._headPic = Utils.getStrAttribute(param1,"headPic");
         this._yellowlevel = Utils.getIntAttribute(param1,"yellowlevel");
         this._yellowstatus = Utils.getIntAttribute(param1,"yellowstatus");
         this._pastureExp = Utils.getIntAttribute(param1,"pastrueExp");
         this._moralExp = Utils.getIntAttribute(param1,"moralexp");
         if(param1["userId"] != undefined)
         {
            this._userId = Utils.getIntAttribute(param1,"userId");
            if(this._uId != this._userId)
            {
               this._uId = this._userId;
            }
         }
      }
      
      public function exportObject() : Object
      {
         return {
            "uId":this._uId,
            "uin":this._uin,
            "exp":this._exp,
            "money":this._money,
            "pf":this._pf,
            "me":this.me,
            "userName":this._userName,
            "headPic":this._headPic,
            "yellowlevel":this._yellowlevel,
            "yellowstatus":this._yellowstatus
         };
      }
      
      public function importFromCache(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._uId = param1._uId;
         this._uin = param1._uin;
         this._exp = param1._exp;
         this._money = param1._money;
         this._pf = param1._pf;
         this._userName = param1._userName;
         this._headPic = param1._headPic;
         this._yellowlevel = param1._yellowlevel;
         this._yellowstatus = param1._yellowstatus;
         this._userId = param1._userId;
         this._moralExp = param1._moralExp;
         this.status = null;
         this.me = param1.me;
         this.sort = param1.sort;
      }
      
      public function get _fid() : uint
      {
         if(Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus")
         {
            return this._uin;
         }
         return this._uId;
      }
      
      public function importFromPlayer(param1:Player) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._uId = param1._uId;
         this._uin = param1._uinLogin;
         this._userId = param1._userId;
         this._userName = param1._userName;
         this._exp = param1._exp;
         this._money = param1._money;
         this._pf = param1._pf;
         this._headPic = param1._headPic;
         this._yellowlevel = param1._yellowlevel;
         this._yellowstatus = param1._yellowstatus;
         this._moralExp = param1._moralExp;
         this._pastureExp = 0;
         this._userId = param1._userId;
         this.status = null;
         this.me = param1.me;
         this.sort = 0;
      }
   }
}


package entities
{
   import com.qzone.utils.ObjectUtil;
   import common.Settings;
   import common.misc.Utils;
   
   public class Player
   {
      
      public var pf2:Boolean;
      
      public var _uinLogin:uint;
      
      public var xystr:String;
      
      public var _pf:int;
      
      public var me:Boolean;
      
      public var sort:int;
      
      public var _uId:uint;
      
      public var _rawData:*;
      
      public var _healthMode:HealthMode;
      
      public var _money:Number;
      
      public var _yellowstatus:int;
      
      public var _moralExp:int;
      
      public var _missionTime:int;
      
      public var _headPic:String;
      
      public var _yellowlevel:int;
      
      public var _canbad:int;
      
      public var _userName:String;
      
      public var uin:uint;
      
      public var _fb:int;
      
      public var _exp:int;
      
      public var _levelup:Array;
      
      public var _userId:uint;
      
      public function Player(param1:*)
      {
         super();
         this._userId = 0;
         this.me = true;
         this.sort = 0;
         this.uin = 0;
         this.pf2 = true;
         this.importObject(param1);
         this._rawData = param1;
      }
      
      public function get fid() : String
      {
         if(Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus")
         {
            return this.uin.toString();
         }
         return this._uId.toString();
      }
      
      public function get level() : int
      {
         return this.expToGrade(this._exp);
      }
      
      public function exportObject() : Object
      {
         return {
            "uId":this._uId,
            "uin":this.uin,
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
      
      private function expToGrade(param1:uint) : int
      {
         return Math.sqrt((param1 + 25) / 100) - 0.5;
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._canbad = Utils.getIntAttribute(param1,"canbad");
         this._exp = Utils.getIntAttribute(param1,"exp");
         this._missionTime = Utils.getIntAttribute(param1,"missionTime");
         this._money = parseFloat(param1["money"]);
         this._fb = Utils.getIntAttribute(param1,"FB");
         this._pf = Utils.getIntAttribute(param1,"pf");
         this._uId = Utils.getIntAttribute(param1,"uId");
         this._uinLogin = Utils.getIntAttribute(param1,"uinLogin");
         this._yellowlevel = Utils.getIntAttribute(param1,"yellowlevel");
         this._yellowstatus = Utils.getIntAttribute(param1,"yellowstatus");
         this._moralExp = Utils.getIntAttribute(param1,"moralexp");
         if(param1["userId"] != undefined)
         {
            this._userId = Utils.getIntAttribute(param1,"userId");
         }
         this._headPic = Utils.getStrAttribute(param1,"headPic");
         this._userName = Utils.getStrAttribute(param1,"userName");
         if(param1["healthMode"] != undefined)
         {
            this._healthMode = new HealthMode(param1["healthMode"]);
         }
         else
         {
            this._healthMode = null;
         }
         if(param1["lvup"] != undefined)
         {
            this._levelup = param1["lvup"] as Array;
         }
         else
         {
            this._levelup = null;
         }
         this.uin = this._uinLogin;
      }
      
      public function clone() : Player
      {
         var _loc1_:Player = new Player(null);
         _loc1_._canbad = this._canbad;
         _loc1_._exp = this._exp;
         _loc1_._missionTime = this._missionTime;
         _loc1_._money = this._money;
         _loc1_._pf = this._pf;
         _loc1_._uId = this._uId;
         _loc1_._uinLogin = this._uinLogin;
         _loc1_._yellowlevel = this._yellowlevel;
         _loc1_._yellowstatus = this._yellowstatus;
         _loc1_._headPic = this._headPic;
         _loc1_._userName = this._userName;
         _loc1_._healthMode = ObjectUtil.clone(this._healthMode) as HealthMode;
         _loc1_._userId = this._userId;
         _loc1_._moralExp = this._moralExp;
         _loc1_.me = this.me;
         _loc1_.sort = this.sort;
         _loc1_.uin = this.uin;
         _loc1_.pf2 = this.pf2;
         return _loc1_;
      }
   }
}


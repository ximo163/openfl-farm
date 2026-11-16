package common
{
   import common.misc.Cookies;
   import entities.Dog;
   import entities.Player;
   import events.CommonEvent;
   import module.FarmApplication;
   
   public class Session
   {
      
      private static var _instance:Session;
      
      private var m_currentUser:Player;
      
      public var upGoldLandTime:int;
      
      public var m_millOpen:Boolean;
      
      private var m_friendsMap:Object;
      
      public var m_buildVersion:String;
      
      public var healthModeValid:Boolean = false;
      
      public var healthModeTimeOut:Boolean = false;
      
      public var isInWildStage:Boolean = false;
      
      public var isVipReturn:Boolean = false;
      
      public var isNewGuideTask:Boolean = false;
      
      public var isPopupNPCWindow:Boolean = false;
      
      private var m_friendsKey:Object;
      
      public var dog:Dog;
      
      private var m_harvestAnimationPlaying:Boolean;
      
      private var m_host:Player;
      
      public var isFromMail:Boolean = false;
      
      public var m_isDogHungry:Boolean;
      
      private var m_app:FarmApplication;
      
      public var m_welcomeMode:Boolean;
      
      public var currentFarmHealthModeValid:Boolean = false;
      
      private var m_expFullToday:Boolean = false;
      
      public var m_waterPoolOpen:Boolean;
      
      public var m_lockFishMouse:Boolean;
      
      public var isExpLocked:Boolean = false;
      
      private var m_nameMap:Object;
      
      public function Session()
      {
         super();
         this.m_app = null;
         this.m_host = null;
         this.m_nameMap = null;
         this.m_harvestAnimationPlaying = false;
         this.m_friendsMap = null;
         this.m_friendsKey = {};
         this.m_isDogHungry = false;
         this.m_welcomeMode = false;
         this.m_millOpen = false;
         this.m_waterPoolOpen = false;
      }
      
      public static function getInstance() : Session
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new Session();
         return _instance;
      }
      
      public function get friendsMap() : Object
      {
         return this.m_friendsMap;
      }
      
      public function get myFairy() : Object
      {
         return this.m_app.model.getData(Consts.MY_FAIRY_OBJECT);
      }
      
      public function transType(param1:String) : String
      {
         if(Consts.ITEM_TYPE_MAP.hasOwnProperty(param1))
         {
            return Consts.ITEM_TYPE_MAP[param1];
         }
         return param1;
      }
      
      public function get me() : Boolean
      {
         if(this.m_currentUser != null && this.m_host != null)
         {
            if(this.m_currentUser._uId == this.m_host._uId)
            {
               return true;
            }
         }
         return false;
      }
      
      public function updateCurrentFriendsKeys(param1:*) : void
      {
         var _loc2_:Player = this.currentUser;
         if(_loc2_ == null)
         {
            return;
         }
         this.m_friendsKey[_loc2_._uId.toString()] = param1;
      }
      
      public function get hostUin() : String
      {
         if(this.m_host != null && this.m_host._uinLogin != 0)
         {
            return this.m_host._uinLogin.toString();
         }
         return "";
      }
      
      public function get host() : Player
      {
         return this.m_host;
      }
      
      public function initFriendMap() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         if(this.m_friendsMap != null)
         {
            return;
         }
         var _loc1_:Array = Cookies.getObject(Settings.getInstance().mode + this.hostId,1) as Array;
         if(_loc1_ != null && _loc1_.length > 0)
         {
            this.m_friendsMap = {};
            _loc2_ = 0;
            _loc3_ = Boolean(Settings.isQZoneUinMode);
            for each(_loc4_ in _loc1_)
            {
               _loc2_ = int(int(_loc4_["_uId"]) || int(_loc4_["_userId"]));
               if(_loc3_ == true)
               {
                  _loc2_ = int(_loc4_["_uin"]);
               }
               this.m_friendsMap[_loc2_] = _loc4_;
            }
         }
      }
      
      public function set expFullToday(param1:Boolean) : void
      {
         if(this.m_expFullToday != param1)
         {
            Cookies.setObject("expFullToday",{"full":param1},0,false);
         }
         this.m_expFullToday = param1;
      }
      
      public function set harvestAnimationPlaying(param1:Boolean) : void
      {
         this.m_harvestAnimationPlaying = param1;
      }
      
      public function addReward(param1:Array) : void
      {
         var _loc9_:Dog = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:String = "";
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         for(; _loc8_ < param1.length; _loc8_++)
         {
            if(param1[_loc8_]["eType"] == undefined && param1[_loc8_]["type"] == undefined)
            {
               continue;
            }
            _loc6_ = param1[_loc8_]["eType"] || param1[_loc8_]["type"];
            if(param1[_loc8_]["eNum"] != undefined)
            {
               _loc7_ = param1[_loc8_]["eNum"] as int;
            }
            else if(param1[_loc8_]["num"] != undefined)
            {
               _loc7_ = param1[_loc8_]["num"] as int;
            }
            switch(_loc6_)
            {
               case Consts.ITEM_TYPE_EXP:
                  this.updateHostAccount(0,_loc7_,0);
                  break;
               case Consts.ITEM_TYPE_MONEY:
                  this.updateHostAccount(_loc7_,0,0);
                  break;
               case Consts.ITEM_TYPE_DOG:
                  this.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
                  this.app.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG,null));
                  break;
               case Consts.ITEM_TYPE_DOGFOOD:
                  _loc9_ = new Dog(null);
                  _loc9_._dogId = -1;
                  _loc9_._isHungry = 0;
                  this.m_isDogHungry = false;
                  this.m_app.dispatchEvent(new CommonEvent(Consts.DATA_DOG_CHANGED,_loc9_));
                  this.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
                  this.app.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG,null));
                  break;
               case Consts.ITEM_TYPE_TOOL:
               case Consts.ITEM_TYPE_FISHFEED:
               case Consts.ITEM_TYPE_FISH:
               case Consts.ITEM_TYPE_WEAPON:
                  _loc2_ = true;
                  break;
               case Consts.ITEM_TYPE_DECORATE:
                  _loc3_ = true;
                  break;
               case Consts.ITEM_TYPE_SEED:
                  _loc4_ = true;
                  break;
               case Consts.ITEM_TYPE_CARD:
                  _loc5_ = true;
            }
         }
         if(_loc2_ == true || _loc4_ == true || _loc5_ == true)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
         }
         if(_loc3_ == true)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG,null));
         }
         if(_loc4_ == true || _loc5_ == true)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
         }
      }
      
      public function get app() : FarmApplication
      {
         return this.m_app;
      }
      
      public function set sceneDecorates(param1:Object) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("Invalid scene decorates data");
         }
         this.m_app.model.setData(Consts.USER_DECORATE_OBJECT,param1);
      }
      
      public function get harvestAnimationPlaying() : Boolean
      {
         return this.m_harvestAnimationPlaying;
      }
      
      public function set app(param1:FarmApplication) : void
      {
         this.m_app = param1;
      }
      
      public function updateOwnerInfo(param1:String, param2:String) : void
      {
         if(this.m_host == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         var _loc4_:Player = this.currentUser;
         if(_loc4_ != null && _loc4_._uId == this.m_host._uId)
         {
            _loc3_ = true;
         }
         var _loc5_:Boolean = false;
         if(param2 != null && param2.length > 0)
         {
            this.m_host._userName = param2;
            if(_loc3_ == true)
            {
               _loc4_._userName = param2;
            }
            _loc5_ = true;
         }
         if(param1 != null && param1.length > 0)
         {
            this.m_host._headPic = param1;
            if(_loc3_ == true)
            {
               _loc4_._headPic = param1;
            }
            _loc5_ = true;
         }
         if(_loc5_ == true && this.m_app != null)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED,this.m_host));
         }
      }
      
      public function set currentUser(param1:Player) : void
      {
         this.m_currentUser = param1;
         this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_CURRENT_USER_CHANGED,this.m_currentUser));
      }
      
      public function set host(param1:Player) : void
      {
         this.m_host = param1;
         this.m_host.me = true;
         this.m_host.sort = 1;
         this.m_host.uin = param1._uinLogin;
         this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED,this.m_host));
      }
      
      public function get friendKeys() : Object
      {
         return this.m_friendsKey;
      }
      
      public function get sceneDecorates() : Object
      {
         return this.m_app.model.getData(Consts.USER_DECORATE_OBJECT);
      }
      
      public function get isMeVIP() : Boolean
      {
         if(this.m_host != null && this.m_host._yellowstatus > 0)
         {
            return true;
         }
         return false;
      }
      
      public function updateHostAccount(param1:int = 0, param2:int = 0, param3:int = 0, param4:int = 0) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:Boolean = false;
         if(param1 != 0)
         {
            this.m_host._money += param1;
            if(this.m_host._money < 0)
            {
               this.m_host._money = 0;
            }
            _loc5_ = true;
         }
         if(param2 > 0)
         {
            _loc6_ = this.m_host.level;
            this.m_host._exp += param2;
            _loc7_ = this.m_host.level;
            if(_loc7_ - _loc6_ > 0)
            {
               this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_USER_LEVEL_UP,{
                  "preLevel":_loc6_,
                  "nowLevel":_loc7_
               }));
            }
            if(this.m_host._exp < 0)
            {
               this.m_host._exp = 0;
            }
            _loc5_ = true;
         }
         if(param3 != 0)
         {
            this.m_host._fb += param3;
            if(this.m_host._fb < 0)
            {
               this.m_host._fb = 0;
            }
            _loc5_ = true;
         }
         if(param4 != 0)
         {
            this.m_host._moralExp += param4;
            if(this.m_host._moralExp < 0)
            {
               this.m_host._moralExp = 0;
            }
            _loc5_ = true;
         }
         if(_loc5_ == true)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_HOST_CHANGED,this.m_host));
         }
      }
      
      public function checkHealthMode() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.me == true)
         {
            if(this.healthModeValid == true)
            {
               _loc1_ = true;
            }
         }
         else if(this.healthModeValid == true)
         {
            _loc1_ = true;
         }
         else if(this.currentFarmHealthModeValid == true)
         {
            _loc1_ = true;
         }
         if(_loc1_ == true)
         {
            this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_HEALTHMODE,{"sync":false}));
         }
         return _loc1_;
      }
      
      public function get hostId() : String
      {
         if(this.m_host != null)
         {
            return this.m_host._uId.toString();
         }
         return "";
      }
      
      public function get currentUser() : Player
      {
         return this.m_currentUser;
      }
      
      public function get expFullToday() : Boolean
      {
         if(this.m_expFullToday)
         {
            return this.m_expFullToday;
         }
         var _loc1_:Object = Cookies.getObject("expFullToday");
         if(_loc1_ != null && _loc1_["full"] as Boolean == true)
         {
            this.m_expFullToday = true;
         }
         else
         {
            this.m_expFullToday = false;
         }
         return this.m_expFullToday;
      }
      
      public function get currentUserIdByUinMode() : uint
      {
         var _loc1_:uint = 0;
         var _loc2_:Player = this.currentUser;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         _loc1_ = this.currentUser._uId;
         var _loc3_:Boolean = Boolean(Settings.isQZoneUinMode);
         if(_loc3_ == true)
         {
            _loc1_ = uint(_loc2_["uin"]);
         }
         return _loc1_;
      }
      
      public function getNameById(param1:uint) : String
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         if(this.m_nameMap == null)
         {
            this.m_nameMap = Cookies.getObject("nameMap",1);
         }
         if(this.m_nameMap != null && this.m_nameMap[param1] != undefined)
         {
            _loc2_ = this.m_nameMap[param1]["qz"];
            _loc3_ = this.m_nameMap[param1]["xy"];
            if(Settings.getInstance().mode == "qzone")
            {
               if(_loc2_)
               {
                  return _loc2_;
               }
               return _loc3_;
            }
            if(_loc3_)
            {
               return _loc3_;
            }
            return _loc2_;
         }
         return null;
      }
   }
}


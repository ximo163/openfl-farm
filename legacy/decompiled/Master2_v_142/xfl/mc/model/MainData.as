package mc.model
{
   import com.adobe.crypto.SHA1;
   import common.CommonData;
   import common.LocalData;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import mc.control.Version;
   import mc.view.farm.GetCropID;
   import mc.view.farm.MPScene;
   
   public class MainData extends EventDispatcher
   {
      
      public static var MarkList:Object;
      
      public static var commonUrlNc:String;
      
      public static var isNewUser:String;
      
      public static var commonUrlFarm:String;
      
      public static const NO_REG:String = "no_reg";
      
      public static const ANIMAL_CHANGE:String = "animalChange";
      
      public static const ANIMAL_SHOUHUO:String = "animalShouhuo";
      
      public static const ANIMAL_ADD:String = "animalAdd";
      
      public static const ANIMAL_SHENGCHAN:String = "animalShengChan";
      
      public static const ANIMAL_NEXTSTATUS:String = "animalnextstatus";
      
      public static const MODULE_CHANGE:String = "moduleChange";
      
      public static const RUN_COMP:String = "runComp";
      
      public static const CURRENT_USER_CHANGE:String = "currentUserChange";
      
      public static const HOST_CHANGE:String = "hostChange";
      
      public static const WEATHER:String = "weather";
      
      public static const FRIEND_CHANGE:String = "friendChange";
      
      public static const USER_ITEMS:String = "userItems";
      
      public static const USER_HUNTERS:String = "userhunters";
      
      public static const USER_CROP:String = "userCrop";
      
      public static const USER_CROP_LOADING:String = "userCropLoading";
      
      public static const USER_MATERIAL:String = "userMaterial";
      
      public static const USER_MATERIAL_RELOAD:String = "userMaterialReload";
      
      public static const USER_MATERIAL_LOADING:String = "userMaterialLoading";
      
      public static const USER_ITEM_LOADING:String = "userItemLoading";
      
      public static const SEED_INFO:String = "seedInfo";
      
      public static const TOOL_INFO:String = "toolInfo";
      
      public static const DIY_INFO:String = "diyInfo";
      
      public static const SHOP_SEED_LOADING:String = "shopSeedLoading";
      
      public static const SHOP_TOOL_LOADING:String = "shopToolLoading";
      
      public static const SHOP_DIY_LOADING:String = "shopDiyLoading";
      
      public static const PROFILE:String = "profile";
      
      public static const PROFILE_LOADING:String = "profileLoading";
      
      public static const ITEMS:String = "items";
      
      public static const ADD_EXP:String = "addExp";
      
      public static const ADD_MONEY:String = "addMoney";
      
      public static const ADD_FB:String = "addFB";
      
      public static const GET_FRIEND_LIST_LOADING:String = "getFriendListLoading";
      
      public static const UNREAD_DATA:String = "unreadData";
      
      public static const WELCOME:String = "welcome";
      
      public static const GIFT_PACKAGE:String = "giftPackage";
      
      public static const VIPRETURN_GIFT_PACKAGE:String = "vipReturnGiftPackage";
      
      public static const USER_CHANGING:String = "userChanging";
      
      public static const LEVEL_REWARD:String = "levelReward";
      
      public static const UPDATE_ANIMAL_MATERIAL:String = "update_animal_material";
      
      public static const USER_LEVEL_UP:String = "userLevelUp";
      
      public static const SESSION_TIMEOUT:String = "sessionTimeout";
      
      public static const RUN_ERROR:String = "runError";
      
      public static const SET_USER_ERROR:String = "setUserError";
      
      public static const USER_CROP_ERR:String = "userCropErr";
      
      public static const USER_MATERIAL_ERR:String = "userMaterialErr";
      
      public static const USER_ITEM_ERR:String = "userItemErr";
      
      public static const USER_HUNTER_ERR:String = "userhunterErr";
      
      public static const SHOP_SEED_ERR:String = "shopSeedErr";
      
      public static const SHOP_TOOL_ERR:String = "shopToolErr";
      
      public static const SHOP_DIY_ERR:String = "shopDiyErr";
      
      public static const PROFILE_ERR:String = "profileErr";
      
      public static const GET_FRIEND_LIST_ERR:String = "getFriendListErr";
      
      public static const HOUSE_DATA_CHANGE:String = "house_data_change";
      
      public static const MAX_FOOD:Number = 1000;
      
      public static const MAX_SEEDS:Number = 100;
      
      public static const HEAD_UPDATE:String = "head_update";
      
      public static const MARK_UPDATE:String = "mark_update";
      
      public static const UNLOCK_LOCK_CROP:String = "unlock_lock_crop";
      
      public static const LOGIN_FLOP_WINDOW:String = "loginFlopWindow";
      
      public static const UPDATADEN_WINDOW:String = "updatadenWindow";
      
      public static const USER_CUB_LOADING:String = "userCubLoading";
      
      public static const USER_CUB_ERR:String = "userCubErr";
      
      public static const USER_CUB:String = "UserCub";
      
      public static const FLOP_ICON_COMPLETE:String = "fopIconComplete";
      
      public static const LOAD_DIY_CONFIG_COMPLETE:String = "diy_config";
      
      public static var loadedProfile:Boolean = false;
      
      public static var loadedMsg:Boolean = false;
      
      public static var loadedLog:Boolean = false;
      
      public static var loadedSystemMsg:Boolean = false;
      
      public static var autoCursor:Boolean = true;
      
      public static var sPrice:Boolean = true;
      
      public static var addPackAnimal:Boolean = false;
      
      public static var gift:Boolean = false;
      
      public static var vipReturnGift:Boolean = false;
      
      public static var inGameBuyType:String = "";
      
      public static var inGameBuyObject:Object = {};
      
      public static var Stage:String = "farm";
      
      public static const HUNTER_CHANGE:String = "hunter_change";
      
      private var _friendList:Array;
      
      private var _upDateHead:Object;
      
      private var _sessionTimeout:String = "";
      
      private var _userMaterialLoading:Boolean = false;
      
      private var _friendStatus:Object;
      
      private var _noReg:Boolean = false;
      
      private var _levelReward:Object;
      
      private var _getFriendListErr:String;
      
      private var _welcome:Boolean = false;
      
      private var _seedInfo:Array;
      
      private var _diyInfo:Array;
      
      private var _searchFriendValue:String = "";
      
      private var _addFB:int = 0;
      
      private var _userMCBg:int;
      
      private var _vipBtn:Bitmap;
      
      private var _friendStatusRelate:Object = {};
      
      private var _animalShengChanData:Object;
      
      private var _userCrop:Array;
      
      private var _userCubErr:String = "";
      
      private var _shopDiyErr:String = "";
      
      private var _profile:Object;
      
      private var _animalAddArray:Array;
      
      private var _shopSeedLoading:Boolean = false;
      
      private var _houseChangeData:Object;
      
      private var _sortField:String = "exp";
      
      private var _lockCropData:Object;
      
      private var _host:Object;
      
      private var _setUserError:String = "";
      
      private var _profileErr:String = "";
      
      private var _seedType:String = "";
      
      private var _userCropErr:String = "";
      
      private var _moduleName:String = "farm";
      
      private var _items:Object;
      
      private var _weather:String = "";
      
      private var _grassMp:String;
      
      private var _unread:Object;
      
      private var _hunter:Object = {};
      
      private var _addExp:int = 0;
      
      private var _grassSkin:String;
      
      private var _userHunters:Array;
      
      private var _reloadUserMaterial:Boolean = true;
      
      private var _mpdata:Object;
      
      private var _upDateMark:Object;
      
      private var _vipIcon:Bitmap;
      
      private var _runComp:Boolean = false;
      
      private var _shopToolErr:String = "";
      
      public var reloadUserItems:Boolean = true;
      
      private var _currentUser:Object;
      
      private var _userCub:Array;
      
      private var _userCrystal:Array;
      
      private var _userItems:Array;
      
      private var _userChanging:Boolean = false;
      
      private var _userCubLoading:Boolean = false;
      
      private var _hostLevel:Number;
      
      private var _giftPackage:Object;
      
      private var _userItemErr:String = "";
      
      private var _showFriendPage:int = 1;
      
      private var _updateAnimalMaterial:Boolean;
      
      private var _showFriendList:Array;
      
      private var _animalData:Array;
      
      private var _getFriendListLoading:Boolean = false;
      
      private var _profileLoading:Boolean = false;
      
      private var _shopToolLoading:Boolean = false;
      
      private var _nextStatusAnimal:Object;
      
      private var _userCropLoading:Boolean = false;
      
      private var _userItemLoading:Boolean = false;
      
      private var _runError:String = "";
      
      public var millOpened:Boolean = false;
      
      private var _shopSeedErr:String = "";
      
      private var _toolsInfo:Array;
      
      private var _userMaterialErr:String = "";
      
      public var reloadUserCrop:Boolean = true;
      
      private var _shopDiyLoading:Boolean = false;
      
      private var _animalShouHuoIndex:int;
      
      private var _userFarmData:Object;
      
      private var _userMaterial:Array;
      
      private var _addMoney:int = 0;
      
      public function MainData()
      {
         super();
      }
      
      public static function getKey2() : String
      {
         return SHA1.hash(String(CommonData.serverTime));
      }
      
      public static function get lockFilter() : Array
      {
         return [new ColorMatrixFilter([0.3,0.7,0.11,0,0,0.3,0.7,0.11,0,0,0.3,0.7,0.11,0,0,0,0,0,1,0])];
      }
      
      public static function get rollOverFilter() : Array
      {
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([1.1,0,0,0,0]);
         _loc1_ = _loc1_.concat([0,1.1,0,0,0]);
         _loc1_ = _loc1_.concat([0,0,1.1,0,0]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         return [new GlowFilter(13434624,1,10,10),new ColorMatrixFilter(_loc1_)];
      }
      
      public function get unreadData() : Object
      {
         return this._unread;
      }
      
      public function set VipReturnPackage(param1:Object) : void
      {
         this._giftPackage = param1;
         dispatchEvent(new ModelEvent(MainData.VIPRETURN_GIFT_PACKAGE));
      }
      
      public function set vipBtn(param1:Bitmap) : void
      {
         this._vipBtn = param1;
      }
      
      public function set userItemErr(param1:String) : void
      {
         this._userItemErr = param1;
         dispatchEvent(new ModelEvent(MainData.USER_ITEM_ERR));
      }
      
      public function get grassMp() : String
      {
         return this._grassMp;
      }
      
      public function set animalShengChanData(param1:Object) : void
      {
         this._animalShengChanData = param1;
         dispatchEvent(new Event(MainData.ANIMAL_SHENGCHAN));
      }
      
      public function get userMaterial() : Array
      {
         return this._userMaterial;
      }
      
      public function gradeToExp(param1:int) : uint
      {
         return 100 * param1 * (param1 + 1);
      }
      
      public function set grassMp(param1:String) : void
      {
         this._grassMp = param1;
      }
      
      public function set updateMaterial(param1:Boolean) : void
      {
         this._updateAnimalMaterial = param1;
         dispatchEvent(new Event(MainData.UPDATE_ANIMAL_MATERIAL));
      }
      
      public function set userMaterial(param1:Array) : void
      {
         this._userMaterial = param1;
         dispatchEvent(new ModelEvent(MainData.USER_MATERIAL));
      }
      
      public function set noReg(param1:Boolean) : void
      {
         this._noReg = param1;
         if(this._noReg)
         {
         }
      }
      
      public function set moduleName(param1:String) : void
      {
         this._moduleName = param1;
         dispatchEvent(new ModelEvent(MainData.MODULE_CHANGE));
      }
      
      public function get friendStatus() : Object
      {
         return this._friendStatus;
      }
      
      public function set userCubLoading(param1:Boolean) : void
      {
         this._userCubLoading = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CUB_LOADING));
      }
      
      public function get runComp() : Boolean
      {
         return this._runComp;
      }
      
      public function get runError() : String
      {
         return this._runError;
      }
      
      public function set addFB(param1:int) : void
      {
         this._addFB = param1;
         dispatchEvent(new ModelEvent(MainData.ADD_FB));
      }
      
      public function set nextStatusAnimal(param1:Object) : void
      {
         this._nextStatusAnimal = param1;
         dispatchEvent(new ModelEvent(MainData.ANIMAL_NEXTSTATUS));
      }
      
      public function get vipIcon() : Bitmap
      {
         return this._vipIcon;
      }
      
      public function get updateHead() : Object
      {
         return this._upDateHead;
      }
      
      public function get reloadUserMaterial() : Boolean
      {
         return this._reloadUserMaterial;
      }
      
      public function set animalShouHuoIndex(param1:int) : void
      {
         this._animalShouHuoIndex = param1;
         dispatchEvent(new ModelEvent(MainData.ANIMAL_SHOUHUO));
      }
      
      public function get showFriendSum() : int
      {
         var _loc1_:int = 1;
         if(this.friendList != null)
         {
            if(this.searchFriendValue == "")
            {
               _loc1_ = Math.ceil(this.friendList.length / this.friendPageNum);
            }
            else
            {
               _loc1_ = Math.ceil(this.filterFriendList.length / this.friendPageNum);
            }
         }
         return _loc1_ == 0 ? 1 : _loc1_;
      }
      
      public function set toolsInfo(param1:Array) : void
      {
         this._toolsInfo = param1;
         dispatchEvent(new ModelEvent(MainData.TOOL_INFO));
      }
      
      public function get grassSkin() : String
      {
         return this._grassSkin;
      }
      
      public function get animalAddArray() : Array
      {
         return this._animalAddArray;
      }
      
      public function set showFriendPage(param1:int) : void
      {
         this._showFriendPage = param1;
      }
      
      public function get friendList() : Array
      {
         return this._friendList;
      }
      
      public function set friendStatus(param1:Object) : void
      {
         this._friendStatus = param1;
      }
      
      public function get userCub() : Array
      {
         return this._userCub;
      }
      
      public function get userCropErr() : String
      {
         return this._userCropErr;
      }
      
      private function friendFilterByUin(param1:*, param2:int, param3:Array) : Boolean
      {
         var _loc4_:String = param1["uin"];
         return new RegExp(".*?" + this.searchFriendValue + ".*","i").test(_loc4_);
      }
      
      public function set showFriendList(param1:Array) : void
      {
         this._showFriendList = param1;
         dispatchEvent(new ModelEvent(MainData.FRIEND_CHANGE));
      }
      
      public function set runComp(param1:Boolean) : void
      {
         this._runComp = param1;
         dispatchEvent(new ModelEvent(MainData.RUN_COMP));
      }
      
      public function set runError(param1:String) : void
      {
         this._runError = param1;
         dispatchEvent(new ModelEvent(MainData.RUN_ERROR));
      }
      
      public function get getFriendListLoading() : Boolean
      {
         return this._getFriendListLoading;
      }
      
      public function set reloadUserMaterial(param1:Boolean) : void
      {
         if(param1 == true)
         {
            dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_RELOAD));
         }
         this._reloadUserMaterial = param1;
      }
      
      public function set updateHead(param1:Object) : void
      {
         this._upDateHead = param1;
         dispatchEvent(new Event(MainData.HEAD_UPDATE));
      }
      
      public function set seedType(param1:String) : void
      {
         this._seedType = param1;
      }
      
      public function get addMoney() : int
      {
         return this._addMoney;
      }
      
      public function get lockCropData() : Object
      {
         return this._lockCropData;
      }
      
      public function set profileLoading(param1:Boolean) : void
      {
         this._profileLoading = param1;
         dispatchEvent(new ModelEvent(MainData.PROFILE_LOADING));
      }
      
      public function set animalAddArray(param1:Array) : void
      {
         this._animalAddArray = param1;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this._animalData[param1[_loc2_]["serial"]] = param1[_loc2_];
            _loc2_++;
         }
         dispatchEvent(new ModelEvent(MainData.ANIMAL_ADD));
      }
      
      public function get searchFriendValue() : String
      {
         return this._searchFriendValue;
      }
      
      public function set grassSkin(param1:String) : void
      {
         this._grassSkin = param1;
      }
      
      public function get userHunters() : Array
      {
         return this._userHunters;
      }
      
      public function set userChanging(param1:Boolean) : void
      {
         this._userChanging = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CHANGING));
      }
      
      public function get shopSeedLoading() : Boolean
      {
         return this._shopSeedLoading;
      }
      
      public function set friendList(param1:Array) : void
      {
         this._friendList = param1;
      }
      
      public function get houseChangeData() : Object
      {
         return this._houseChangeData;
      }
      
      public function get setUserError() : String
      {
         return this._setUserError;
      }
      
      public function set shopSeedErr(param1:String) : void
      {
         this._shopSeedErr = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_SEED_ERR));
      }
      
      public function get seedInfo() : Array
      {
         return this._seedInfo;
      }
      
      public function get userCubErr() : String
      {
         return this._userCubErr;
      }
      
      public function get hostLevel() : int
      {
         this._hostLevel = this.expToGrade(int(this.host["exp"]));
         return this._hostLevel;
      }
      
      public function get userMCBg() : int
      {
         return this._userMCBg;
      }
      
      public function get shopDiyErr() : String
      {
         return this._shopDiyErr;
      }
      
      public function set welcome(param1:Boolean) : void
      {
         this._welcome = param1;
         dispatchEvent(new ModelEvent(MainData.WELCOME));
      }
      
      public function get userItems() : Array
      {
         return this._userItems;
      }
      
      public function set updateMark(param1:Object) : void
      {
         this._upDateMark = param1;
         dispatchEvent(new Event(MainData.MARK_UPDATE));
      }
      
      public function get userMaterialLoading() : Boolean
      {
         return this._userMaterialLoading;
      }
      
      public function get UserCrystal() : Array
      {
         return this._userCrystal;
      }
      
      public function set diyInfo(param1:Array) : void
      {
         this._diyInfo = param1;
         dispatchEvent(new ModelEvent(MainData.DIY_INFO));
      }
      
      public function set userCropErr(param1:String) : void
      {
         this._userCropErr = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CROP_ERR));
      }
      
      public function get currentUserUin() : String
      {
         if(this.currentUser != null)
         {
            return this.currentUser["uin"];
         }
         return "";
      }
      
      public function get shopToolErr() : String
      {
         return this._shopToolErr;
      }
      
      public function set userCub(param1:Array) : void
      {
         this._userCub = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CUB));
      }
      
      public function set vipIcon(param1:Bitmap) : void
      {
         this._vipIcon = param1;
      }
      
      public function get currentUser() : Object
      {
         return this._currentUser;
      }
      
      public function get profileErr() : String
      {
         return this._profileErr;
      }
      
      public function get giftPackage() : Object
      {
         return this._giftPackage;
      }
      
      public function get vipBtn() : Bitmap
      {
         return this._vipBtn;
      }
      
      public function get userCrop() : Array
      {
         return this._userCrop;
      }
      
      public function get userItemErr() : String
      {
         return this._userItemErr;
      }
      
      public function get animalShengChanData() : Object
      {
         return this._animalShengChanData;
      }
      
      public function set hunter(param1:Object) : void
      {
         this._hunter = param1;
         this.dispatchEvent(new Event(MainData.HUNTER_CHANGE));
      }
      
      public function set getFriendListLoading(param1:Boolean) : void
      {
         this._getFriendListLoading = param1;
         dispatchEvent(new ModelEvent(MainData.GET_FRIEND_LIST_LOADING));
      }
      
      public function get moduleName() : String
      {
         return this._moduleName;
      }
      
      public function get addFB() : int
      {
         return this._addFB;
      }
      
      public function get userCubLoading() : Boolean
      {
         return this._userCubLoading;
      }
      
      public function get currentUserId() : String
      {
         if(this.currentUser != null)
         {
            return this.currentUser["uId"];
         }
         return "";
      }
      
      public function get nextStatusAnimal() : Object
      {
         return this._nextStatusAnimal;
      }
      
      public function get animalShouHuoIndex() : int
      {
         return this._animalShouHuoIndex;
      }
      
      public function get toolsInfo() : Array
      {
         return this._toolsInfo;
      }
      
      public function get showFriendPage() : int
      {
         return this._showFriendPage;
      }
      
      public function get showFriendList() : Array
      {
         return this._showFriendList;
      }
      
      public function getAnimalNum(param1:Number, param2:String) : Number
      {
         if(param1 >= 8)
         {
            return 10;
         }
         if(param2 == "窝")
         {
            if(param1 == 1)
            {
               return 2;
            }
            if(param1 == 2)
            {
               return 3;
            }
            if(param1 >= 3)
            {
               return param1 + 2;
            }
         }
         if(param2 == "棚" && param1 != 0)
         {
            return param1 + 2;
         }
         return 0;
      }
      
      public function set shopDiyLoading(param1:Boolean) : void
      {
         this._shopDiyLoading = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_DIY_LOADING));
      }
      
      public function expToGrade(param1:uint) : int
      {
         return Math.sqrt((param1 + 25) / 100) - 0.5;
      }
      
      public function get hostFid() : String
      {
         if(Version.value == "qzone")
         {
            return this.host["uin"];
         }
         return this.host["uId"];
      }
      
      public function get seedType() : String
      {
         return this._seedType;
      }
      
      public function set addMoney(param1:int) : void
      {
         this._addMoney = param1;
         dispatchEvent(new ModelEvent(MainData.ADD_MONEY));
      }
      
      public function set host(param1:Object) : void
      {
         this._host = param1;
         dispatchEvent(new ModelEvent(MainData.HOST_CHANGE));
      }
      
      public function set lockCropData(param1:Object) : void
      {
         this._lockCropData = param1;
         dispatchEvent(new Event(MainData.UNLOCK_LOCK_CROP));
      }
      
      public function set friendStatusRelate(param1:Object) : void
      {
         this._friendStatusRelate = param1;
      }
      
      public function get profileLoading() : Boolean
      {
         return this._profileLoading;
      }
      
      public function set searchFriendValue(param1:String) : void
      {
         this._searchFriendValue = param1;
      }
      
      public function set userHunters(param1:Array) : void
      {
         this._userHunters = param1;
         dispatchEvent(new ModelEvent(MainData.USER_HUNTERS));
      }
      
      public function get userChanging() : Boolean
      {
         return this._userChanging;
      }
      
      public function set profile(param1:Object) : void
      {
         this._profile = param1;
         dispatchEvent(new ModelEvent(MainData.PROFILE));
      }
      
      public function set shopToolLoading(param1:Boolean) : void
      {
         this._shopToolLoading = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_TOOL_LOADING));
      }
      
      public function get shopSeedErr() : String
      {
         return this._shopSeedErr;
      }
      
      public function get millLimitYDLevel() : Number
      {
         return LocalData.parameters.millLimitYDLevel;
      }
      
      public function get welcome() : Boolean
      {
         return this._welcome;
      }
      
      public function get updateMark() : Object
      {
         return this._upDateMark;
      }
      
      public function set getFriendListErr(param1:String) : void
      {
         this._getFriendListErr = param1;
         dispatchEvent(new ModelEvent(MainData.GET_FRIEND_LIST_ERR));
      }
      
      public function get diyInfo() : Array
      {
         return this._diyInfo;
      }
      
      public function set userItems(param1:Array) : void
      {
         this._userItems = param1;
         dispatchEvent(new ModelEvent(MainData.USER_ITEMS));
      }
      
      public function set houseChangeData(param1:Object) : void
      {
         this._houseChangeData = param1;
         if(Boolean(this._houseChangeData) && this._houseChangeData.f == 1)
         {
            dispatchEvent(new Event(MainData.HOUSE_DATA_CHANGE));
         }
      }
      
      public function set addExp(param1:int) : void
      {
         var _loc5_:ModelEvent = null;
         this._addExp = param1;
         dispatchEvent(new ModelEvent(MainData.ADD_EXP));
         var _loc2_:int = this.host["exp"] - this._addExp;
         var _loc3_:int = this.expToGrade(_loc2_);
         var _loc4_:int = this.expToGrade(this.host["exp"]);
         if(_loc4_ - _loc3_ > 0)
         {
            _loc5_ = new ModelEvent(MainData.USER_LEVEL_UP);
            _loc5_.data = {
               "preLevel":_loc3_,
               "nowLevel":_loc4_
            };
            dispatchEvent(_loc5_);
         }
      }
      
      public function set shopSeedLoading(param1:Boolean) : void
      {
         this._shopSeedLoading = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_SEED_LOADING));
      }
      
      public function set setUserError(param1:String) : void
      {
         this._setUserError = param1;
         dispatchEvent(new ModelEvent(MainData.SET_USER_ERROR));
      }
      
      public function set seedInfo(param1:Array) : void
      {
         this._seedInfo = param1;
         dispatchEvent(new ModelEvent(MainData.SEED_INFO));
      }
      
      private function uniq(param1:Array) : Array
      {
         var _loc2_:Object = {};
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         var _loc5_:int = int(param1.length);
         while(_loc4_ < _loc5_)
         {
            if(!_loc2_[param1[_loc4_]["uId"]])
            {
               _loc2_[param1[_loc4_]["uId"]] = 1;
               _loc3_.push(param1[_loc4_]);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function set userCubErr(param1:String) : void
      {
         this._userCubErr = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CUB_ERR));
      }
      
      public function set userCropLoading(param1:Boolean) : void
      {
         this._userCropLoading = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CROP_LOADING));
      }
      
      public function set shopDiyErr(param1:String) : void
      {
         this._shopDiyErr = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_DIY_ERR));
      }
      
      public function set items(param1:Object) : void
      {
         this._items = param1;
         dispatchEvent(new ModelEvent(MainData.ITEMS));
      }
      
      public function set animalData(param1:Array) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Array = new Array(40);
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_]["buyTime"] != 0)
            {
               _loc2_[param1[_loc3_]["serial"]] = param1[_loc3_];
            }
            _loc3_++;
         }
         if(this.me)
         {
            _loc4_ = 0;
            _loc5_ = 0;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_])
               {
                  if(GetCropID.getHouse(_loc2_[_loc3_]["cId"]) == "窝")
                  {
                     _loc4_++;
                  }
                  else
                  {
                     _loc5_++;
                  }
               }
               _loc3_++;
            }
            this.host["animal1"] = _loc4_;
            this.host["animal2"] = _loc5_;
         }
         this._animalData = _loc2_;
         dispatchEvent(new ModelEvent(MainData.ANIMAL_CHANGE));
      }
      
      public function set UserCrystal(param1:Array) : void
      {
         this._userCrystal = param1;
      }
      
      public function get me() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.currentUser != null && this.host != null)
         {
            if(this.currentUser["uId"] != this.host["uId"])
            {
               _loc1_ = false;
            }
         }
         return _loc1_;
      }
      
      public function set userMaterialLoading(param1:Boolean) : void
      {
         this._userMaterialLoading = param1;
         dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_LOADING));
      }
      
      public function get shopDiyLoading() : Boolean
      {
         return this._shopDiyLoading;
      }
      
      public function get hunter() : Object
      {
         return this._hunter;
      }
      
      public function set userMCBg(param1:int) : void
      {
         this._userMCBg = param1;
      }
      
      public function get host() : Object
      {
         return this._host;
      }
      
      public function get friendStatusRelate() : Object
      {
         return this._friendStatusRelate;
      }
      
      public function set levelReward(param1:Object) : void
      {
         this._levelReward = param1;
         dispatchEvent(new ModelEvent(MainData.LEVEL_REWARD));
      }
      
      public function get shopToolLoading() : Boolean
      {
         return this._shopToolLoading;
      }
      
      public function get profile() : Object
      {
         return this._profile;
      }
      
      public function get getFriendListErr() : String
      {
         return this._getFriendListErr;
      }
      
      public function set shopToolErr(param1:String) : void
      {
         this._shopToolErr = param1;
         dispatchEvent(new ModelEvent(MainData.SHOP_TOOL_ERR));
      }
      
      private function friendFilter(param1:*, param2:int, param3:Array) : Boolean
      {
         var _loc4_:String = param1["userName"];
         return new RegExp(".*?" + this.searchFriendValue + ".*","i").test(_loc4_);
      }
      
      public function set userItemLoading(param1:Boolean) : void
      {
         this._userItemLoading = param1;
         dispatchEvent(new ModelEvent(MainData.USER_ITEM_LOADING));
      }
      
      public function get items() : Object
      {
         return this._items;
      }
      
      public function get userCropLoading() : Boolean
      {
         return this._userCropLoading;
      }
      
      public function get addExp() : int
      {
         return this._addExp;
      }
      
      public function set currentUser(param1:Object) : void
      {
         this._currentUser = param1;
         dispatchEvent(new ModelEvent(MainData.CURRENT_USER_CHANGE));
      }
      
      public function get animalData() : Array
      {
         return this._animalData;
      }
      
      public function get currentFid() : String
      {
         if(Version.value == "qzone")
         {
            return this.currentUserUin;
         }
         return this.currentUserId;
      }
      
      public function get levelReward() : Object
      {
         return this._levelReward;
      }
      
      public function set userFarmData(param1:Object) : void
      {
         this._userFarmData = param1;
      }
      
      public function get getHostId() : String
      {
         if(this.host != null)
         {
            return this.host["uId"];
         }
         return "";
      }
      
      public function set mpData(param1:Object) : void
      {
         this._mpdata = param1;
         dispatchEvent(new Event(MPScene.OPEN_MAOPAO));
      }
      
      public function set sessionTimeout(param1:String) : void
      {
         this._sessionTimeout = param1;
         dispatchEvent(new ModelEvent(MainData.SESSION_TIMEOUT));
      }
      
      public function get userItemLoading() : Boolean
      {
         return this._userItemLoading;
      }
      
      public function set userMaterialErr(param1:String) : void
      {
         this._userMaterialErr = param1;
         dispatchEvent(new ModelEvent(MainData.USER_MATERIAL_ERR));
      }
      
      public function set weather(param1:String) : void
      {
         this._weather = param1;
         dispatchEvent(new ModelEvent(MainData.WEATHER));
      }
      
      public function get userFarmData() : Object
      {
         return this._userFarmData;
      }
      
      public function set giftPackage(param1:Object) : void
      {
         this._giftPackage = param1;
         dispatchEvent(new ModelEvent(MainData.GIFT_PACKAGE));
      }
      
      public function get mpData() : Object
      {
         return this._mpdata;
      }
      
      public function set unreadData(param1:Object) : void
      {
         this._unread = param1;
         dispatchEvent(new ModelEvent(MainData.UNREAD_DATA));
      }
      
      public function get userMaterialErr() : String
      {
         return this._userMaterialErr;
      }
      
      public function get filterFriendList() : Array
      {
         var _loc1_:Array = this.friendList.filter(this.friendFilter);
         if(Version.value == Version.QZONE)
         {
            _loc1_ = _loc1_.concat(this.friendList.filter(this.friendFilterByUin));
         }
         return this.uniq(_loc1_);
      }
      
      public function set userCrop(param1:Array) : void
      {
         this._userCrop = param1;
         dispatchEvent(new ModelEvent(MainData.USER_CROP));
      }
      
      public function set sortField(param1:String) : void
      {
         this._sortField = param1;
      }
      
      public function get friendPageNum() : int
      {
         return 10;
      }
      
      public function get sessionTimeout() : String
      {
         return this._sessionTimeout;
      }
      
      public function get weather() : String
      {
         return this._weather;
      }
      
      public function get sortField() : String
      {
         return this._sortField;
      }
      
      public function set profileErr(param1:String) : void
      {
         this._profileErr = param1;
         dispatchEvent(new ModelEvent(MainData.PROFILE_ERR));
      }
   }
}


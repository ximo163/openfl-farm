package framework.api.beast
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.managers.PopUpManager;
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.window.ContentWindow;
   import entities.Friend;
   import events.CommonEvent;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import framework.api.beast.cmd.CmdBeastDefs;
   import framework.net.NetHelper;
   import framework.net.ServerServices;
   import framework.net.vo.ServiceResultVOHelper;
   import module.FarmApplication;
   import module.friend.FriendsModel;
   
   public class BeastAPI extends EventDispatcher implements IBeastAPI
   {
      
      public static var app:FarmApplication;
      
      private static var instance:BeastAPI;
      
      public static const FARM_STAGE:String = "wild_show_farmstage";
      
      public static const WILD_STAGE:String = "wild_show_wildstage";
      
      private var _wildStageContainer:DisplayObjectContainer;
      
      private var _wildToolBarContainer:DisplayObjectContainer;
      
      private var _beastConfigUrl:String;
      
      private var _cursorArgument:Object;
      
      private var _session:Session;
      
      private var _iniData:XML;
      
      private var _settings:Settings;
      
      private var _beastBaseData:Object;
      
      private var _animalContainer:DisplayObjectContainer;
      
      private var _wildCmd:WildCommand;
      
      private var _cmdBeastDefs:CmdBeastDefs;
      
      private var _beastPackContainer:DisplayObjectContainer;
      
      private var _wildData:WildData;
      
      private var _ss:ServerServices;
      
      public function BeastAPI()
      {
         super();
         this._settings = Settings.getInstance();
         this._session = Session.getInstance();
         this._cmdBeastDefs = CmdBeastDefs.getInstance();
         this._ss = ServerServices.getInstance();
         this._ss.registerCmdMap(this._cmdBeastDefs.defMaps);
         this._wildData = WildData.getInstance();
         this._wildCmd = WildCommand.getInstance();
         this._wildCmd.api = this;
      }
      
      public static function getInstance() : BeastAPI
      {
         if(instance == null)
         {
            instance = new BeastAPI();
         }
         return instance;
      }
      
      public function hideTip() : void
      {
         app.hideTip();
      }
      
      public function get cursorName() : String
      {
         return app.farmView.cursorCtrl.name;
      }
      
      public function openControlisOpen(param1:String) : Boolean
      {
         var _loc2_:String = this._settings.getStringAttribute("wildOpenCtrl");
         if(_loc2_ == "true")
         {
            return true;
         }
         return false;
      }
      
      public function get beastBase() : Object
      {
         return this._beastBaseData;
      }
      
      public function useSystemCurosr(param1:Boolean) : void
      {
         app.useSystemCursor(true);
      }
      
      public function updateWildStatus(param1:Number) : void
      {
         app.dispatchEvent(new CommonEvent(Consts.MSG_WILD_UPDATE_STATUS,{
            "t":param1,
            "uId":Session.getInstance().currentUserIdByUinMode
         }));
      }
      
      public function getOpenYellowLv(param1:String) : int
      {
         return int(this._settings.getStringAttribute("wildOpenlv"));
      }
      
      public function jsonDecode(param1:String) : Object
      {
         return com.adobe.serialization.json.JSON.decode(param1);
      }
      
      public function hideBeastPack() : void
      {
         dispatchEvent(new EvtAPI(EvtAPI.HIDE_BEAST_PACK));
      }
      
      public function close(param1:Sprite) : void
      {
         PopUpManager.removePopUp(param1.parent as ContentWindow);
      }
      
      public function get canUserHunter() : Boolean
      {
         var _loc1_:int = this._session.dog._dogId;
         var _loc2_:int = this._session.dog._isHungry;
         if(_loc1_ != 0 && _loc2_ == 0)
         {
            return true;
         }
         return false;
      }
      
      public function set wildStageContainer(param1:DisplayObjectContainer) : void
      {
         this._wildStageContainer = param1;
      }
      
      public function getAnimalURL(param1:String, param2:int) : String
      {
         return "";
      }
      
      public function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void
      {
         RSLManager.getInstance().requestClass(param1,param2,param3,param4);
      }
      
      public function getShopIconUrl(param1:Number, param2:Boolean = false) : String
      {
         return "";
      }
      
      public function get beastConfigUrl() : String
      {
         return this._beastConfigUrl;
      }
      
      public function get cursorArgument() : Object
      {
         return this._cursorArgument;
      }
      
      public function getURL(param1:String, param2:Object = null) : String
      {
         var _loc3_:String = null;
         if(param1 == "wildanimal")
         {
            _loc3_ = this._settings.getStringAttribute("wildanimal") + "wildanimal_" + param2["id"] + ".swf";
         }
         else if(param1 == "wildaction")
         {
            _loc3_ = this._settings.getStringAttribute("wildaction");
         }
         else if(param1 == "wildaweapon")
         {
            _loc3_ = this._settings.getStringAttribute("wildaweapon") + "weapon" + param2["id"] + ".swf";
         }
         else if(param1 == "drop9")
         {
            _loc3_ = this._settings.getStringAttribute("drop9");
         }
         return _loc3_;
      }
      
      public function registerEventListeners() : void
      {
         app.addEventListener(Consts.MSG_HOST_CHANGED,function():void
         {
            dispatchEvent(new Event(EvtAPI.HOST_CHANGE));
         },false,0,true);
         app.addEventListener(Consts.DATA_DOG_CHANGED,function():void
         {
            dispatchEvent(new Event(EvtAPI.HUNTER_CHANGE));
         });
         app.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,function():void
         {
            dispatchEvent(new Event(EvtAPI.CURRENT_USER_CHANGE));
         },false,0,true);
      }
      
      public function set wildToolBarContainer(param1:DisplayObjectContainer) : void
      {
         this._wildToolBarContainer = param1;
      }
      
      public function openForName(param1:String, param2:Object = null) : void
      {
         app.openWindowByName(param1,param2);
      }
      
      public function steal(param1:Object) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.farmIdx = param1.serial;
         _loc2_.num = 1;
         app.dispatchEvent(new CommonEvent(Consts.MSG_WILD_BEAST_STEAL,_loc2_));
      }
      
      public function get wildToolBarContainer() : DisplayObjectContainer
      {
         return this._wildToolBarContainer;
      }
      
      public function open(param1:Sprite, param2:String, param3:String = "野生动物", param4:Function = null, param5:Function = null) : void
      {
         var _loc6_:ContentWindow = new ContentWindow(app,param2,param1,27,true);
         _loc6_.data = {
            "width":param1.width,
            "height":param1.height,
            "title":param3,
            "yellowTip":param1["yellowTip"]
         };
         app.openWindow(_loc6_);
      }
      
      public function setUser(param1:Object) : void
      {
         var _loc2_:Friend = new Friend(param1);
         app.switchUser(_loc2_);
      }
      
      public function get hostFid() : String
      {
         return this._session.host.fid;
      }
      
      public function setCursor(param1:String, param2:Object = null, param3:String = null) : void
      {
         if(!param3)
         {
            app.farmView.cursorCtrl.setCursor(param1);
         }
         else
         {
            app.farmView.cursorCtrl.setCursor(param1,param3);
         }
         this._cursorArgument = param2;
         if(param3 != null)
         {
            if(this._cursorArgument == null)
            {
               this._cursorArgument = {"material":param3};
            }
            else
            {
               this._cursorArgument["material"] = param3;
            }
         }
      }
      
      public function get beastPackContainer() : DisplayObjectContainer
      {
         return this._beastPackContainer;
      }
      
      public function isMe() : Boolean
      {
         return this._session.me;
      }
      
      public function set beastConfigUrl(param1:String) : void
      {
         this._beastConfigUrl = param1;
      }
      
      public function showTip(param1:String, param2:Object) : void
      {
         app.showTip(param1,param2);
      }
      
      public function openShop(param1:int) : void
      {
         app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP,{"tabIndex":1}));
      }
      
      public function set reloadUserCrop(param1:Boolean) : void
      {
         app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
      }
      
      public function pushToMaterialLib(param1:ApplicationDomain) : void
      {
      }
      
      public function alertWindow(param1:String, param2:String, param3:Boolean = false) : void
      {
         var _loc4_:Object = {
            "type":Consts.ALERT_TYPE_TIP,
            "text":param2,
            "target":"_top"
         };
         app.openWindowByName(Consts.WINDOW_NAME_ALERT,_loc4_);
      }
      
      public function set iniData(param1:XML) : void
      {
         this._iniData = param1;
      }
      
      public function get ISFARM() : int
      {
         return 1;
      }
      
      public function set reloadUserSeed(param1:Boolean) : void
      {
         app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
      }
      
      public function get friendFid() : String
      {
         return this._session.currentUser.fid;
      }
      
      public function floatWindow(param1:String, param2:String = "info") : void
      {
         var _loc3_:String = null;
         if(param2 == "Exclamation")
         {
            _loc3_ = "TipIcon";
         }
         else
         {
            _loc3_ = "SuccessIcon";
         }
         var _loc4_:Object = {
            "text":param1,
            "parent":app.farmView.getLayerByName(Consts.LAYER_TOPMOST),
            "icon":_loc3_
         };
         app.openFloat(Consts.FLOAT_TYPE_TEXTTIP,0,_loc4_);
      }
      
      public function showReward(param1:String) : void
      {
         var _loc2_:EvtAPI = new EvtAPI(EvtAPI.REWARD_CHANGE);
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      public function set beastPackContainer(param1:DisplayObjectContainer) : void
      {
         this._beastPackContainer = param1;
      }
      
      public function get swfUrl() : String
      {
         return CommonData.swfUrl;
      }
      
      public function setExpressUser(param1:Object) : void
      {
         app.setExpressUser(param1,0);
      }
      
      public function getMaterial(param1:String) : DisplayObject
      {
         return Utils.getMaterial(param1) as DisplayObject;
      }
      
      public function addMoney(param1:Object) : void
      {
         this._session.updateHostAccount(int(param1["money"]));
      }
      
      public function get wildStageContainer() : DisplayObjectContainer
      {
         return this._wildStageContainer;
      }
      
      public function getOpenExpLv(param1:String) : int
      {
         return int(this._settings.getStringAttribute("wildOpenexp"));
      }
      
      public function get host() : Object
      {
         return this._session.host.exportObject();
      }
      
      public function showBeastPack() : void
      {
         dispatchEvent(new EvtAPI(EvtAPI.SHOW_BEAST_PACK));
      }
      
      public function openConfirmWindow(param1:Object, param2:Function, param3:Function, param4:Boolean = true) : void
      {
         var _loc5_:Object = {
            "width":380,
            "height":230,
            "title":"温馨提示",
            "confirmFn":param2,
            "text":param1["text"],
            "confirmEnable":param4
         };
         app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc5_);
      }
      
      public function get serverTime() : Number
      {
         return CommonData.serverTime;
      }
      
      public function set beastBase(param1:Object) : void
      {
         this._beastBaseData = param1;
         dispatchEvent(new Event(EvtAPI.BEAST_DATA_CHANGE));
      }
      
      public function set reloadCrystal(param1:Boolean) : void
      {
         WildData.reloadCrystal = param1;
      }
      
      public function get hunterId() : int
      {
         return this._session.dog._dogId;
      }
      
      public function get hostLevel() : int
      {
         return this._session.host.level;
      }
      
      public function get iniData() : XML
      {
         return this._iniData;
      }
      
      public function addPrefix(param1:String) : String
      {
         return Utils.addPrefix(param1);
      }
      
      public function addMoralexp(param1:int) : void
      {
         this._session.updateHostAccount(0,0,0,param1);
      }
      
      public function tipString(param1:String) : String
      {
         switch(param1)
         {
            case "hunterName":
               return "狗";
            case "hunterError":
               return "没有狗或者没有狗粮";
            default:
               return "";
         }
      }
      
      public function getProductName2(param1:Object) : String
      {
         return GetCropID.getNameByIDType(Consts.ITEM_TYPE_SEED,param1.toString());
      }
      
      public function postRequest(param1:String, param2:Object, param3:Function, param4:String = null, param5:String = "farm") : void
      {
         var farmToAnimalFun:Function = null;
         var url:String = param1;
         var arg:Object = param2;
         var handlerFun:Function = param3;
         var act:String = param4;
         var common:String = param5;
         farmToAnimalFun = function(param1:CommandEvent):void
         {
            var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
            var _loc3_:Object = param1.body["__body"];
            _loc2_["post_data"] = _loc3_;
            handlerFun(_loc2_);
         };
         var cmdId:int = CmdBeastDefs.getIdByCgi(url);
         NetHelper.sendRequest(cmdId,arg,farmToAnimalFun,farmToAnimalFun);
      }
      
      public function showWildStage() : void
      {
         dispatchEvent(new Event(EvtAPI.SHOW_WILD_STAGE));
      }
      
      public function get version() : String
      {
         if(QzoneJSAPI.WB == true)
         {
            return "";
         }
         return this._settings.mode;
      }
      
      public function set animalContainer(param1:DisplayObjectContainer) : void
      {
         this._animalContainer = param1;
      }
      
      public function closeForName(param1:String, param2:Object = null) : void
      {
         app.closeWindowByName(param1);
      }
      
      public function getMaterialClass(param1:String) : Class
      {
         return Utils.getClass(param1);
      }
      
      public function get currentUser() : Object
      {
         return this._session.currentUser.exportObject();
      }
      
      public function get animalContainer() : DisplayObjectContainer
      {
         return this._animalContainer;
      }
      
      public function showFarmStage() : void
      {
         dispatchEvent(new Event(EvtAPI.SHOW_FARM_STAGE));
      }
      
      public function refreshFriendsList(param1:Boolean) : void
      {
         var _loc2_:FriendsModel = FriendsModel.getInstance();
         _loc2_.loadFriendsData(true,true);
      }
      
      public function getMaterialMC(param1:String) : MovieClip
      {
         return Utils.getMaterial(param1) as MovieClip;
      }
      
      public function openRecall(param1:int) : void
      {
         app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_RECALL,{"tabIndex":1}));
      }
      
      public function get appCurrentDomain() : ApplicationDomain
      {
         return CommonData.applicationDomain;
      }
      
      public function getFriendByFid(param1:int) : Object
      {
         var _loc2_:Friend = null;
         var _loc3_:FriendsModel = FriendsModel.getInstance();
         if(!_loc3_.friendListLocal)
         {
            _loc3_.loadFriendsData();
         }
         _loc2_ = _loc3_.getFriendByFiD(param1);
         if(!_loc2_)
         {
            this.alertWindow("","被放养的人不是您的好友");
            return null;
         }
         return _loc2_.exportObject();
      }
   }
}


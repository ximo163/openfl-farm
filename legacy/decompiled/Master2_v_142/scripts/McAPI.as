package
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.corelib.net.RSLManager;
   import common.CommonData;
   import common.INI;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import mc.FBridge.FRequest;
   import mc.api.EmptyWindow;
   import mc.api.WildCommand;
   import mc.api.WildData;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.control.Version;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.ProductData;
   import mc.view.common.BaseWindow;
   import mc.view.common.ConfirmWindow;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   
   public class McAPI extends EventDispatcher implements IGameAPI
   {
      
      private static var instance:McAPI;
      
      protected var _wildData:WildData;
      
      private var _commonMc:String;
      
      protected var _farmData:FarmData;
      
      private var _commonNc:String;
      
      private var _fr:FRequest;
      
      private var _iniData:XML;
      
      protected var _productData:ProductData;
      
      protected var _mainData:MainData;
      
      protected var _mainCommand:MainCommand;
      
      private var _commurl:String;
      
      private var fr:FRequest;
      
      protected var _wildCmd:WildCommand;
      
      public function McAPI()
      {
         this.fr = FRequest.getInstance();
         this._commurl = INI.getInstance().data.postUrl.@commonFarm;
         this._commonNc = INI.getInstance().data.postUrl.@commonNc;
         this._commonMc = INI.getInstance().data.postUrl.@url;
         super();
         this._fr = FRequest.getInstance();
         this._farmData = MData.getInstance().farmData;
         this._mainData = MData.getInstance().mainData;
         this._productData = MData.getInstance().productData;
         this._mainCommand = Command.getInstance().mainCommand;
         this._wildData = WildData.getInstance();
         this._wildCmd = WildCommand.getInstance();
         this._mainData.addEventListener(MainData.HOST_CHANGE,function():void
         {
            dispatchEvent(new Event(EvtAPI.HOST_CHANGE));
         });
         this._mainData.addEventListener(MainData.HUNTER_CHANGE,function():void
         {
            dispatchEvent(new Event(EvtAPI.HUNTER_CHANGE));
         });
         this._mainData.addEventListener(MainData.CURRENT_USER_CHANGE,function():void
         {
            dispatchEvent(new Event(EvtAPI.CURRENT_USER_CHANGE));
         });
      }
      
      public static function getInstance() : McAPI
      {
         if(instance == null)
         {
            instance = new McAPI();
         }
         return instance;
      }
      
      public function hideTip() : void
      {
         TipControl.hide();
      }
      
      public function get cursorName() : String
      {
         return Cursor.name;
      }
      
      public function useSystemCurosr(param1:Boolean) : void
      {
         Cursor.useSystem(param1);
      }
      
      public function getFriendByFid(param1:int) : Object
      {
         return this._mainCommand.getFriendByFid(param1);
      }
      
      public function close(param1:Sprite) : void
      {
         WControl.close(param1.parent.parent as BaseWindow);
      }
      
      public function jsonDecode(param1:String) : Object
      {
         return com.adobe.serialization.json.JSON.decode(param1);
      }
      
      public function set reloadUserSeed(param1:Boolean) : void
      {
         this._farmData.reloadUserSeed = true;
      }
      
      public function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void
      {
         RSLManager.getInstance().requestClass(param1,param2,param3,param4);
      }
      
      public function get hostFid() : String
      {
         return this._mainData.hostFid;
      }
      
      public function get cursorArgument() : Object
      {
         return Cursor.cursorArgument;
      }
      
      public function getURL(param1:String, param2:Object = null) : String
      {
         var _loc3_:String = null;
         if(param1 == "wildanimal")
         {
            _loc3_ = MainCommand.getModule2Url("wildanimal")["url"] + "wildanimal_" + param2["id"] + ".swf";
         }
         else if(param1 == "wildaction")
         {
            _loc3_ = MainCommand.getModule2Url("wildaction")["url"];
         }
         else if(param1 == "wildaweapon")
         {
            _loc3_ = MainCommand.getModule2Url("wildaweapon")["url"] + "weapon" + param2["id"] + ".swf";
         }
         else if(param1 == "drop9")
         {
            _loc3_ = MainCommand.getModule2Url("drop9")["url"];
         }
         return _loc3_;
      }
      
      public function openForName(param1:String, param2:Object = null) : void
      {
         WControl.openForName(param1,param2);
      }
      
      public function setUser(param1:Object) : void
      {
         this._mainCommand.setUser(param1);
      }
      
      public function setCursor(param1:String, param2:Object = null, param3:String = null) : void
      {
         Cursor.setAPICurosr(param1,param2,param3);
      }
      
      public function set iniData(param1:XML) : void
      {
         this._iniData = param1;
      }
      
      public function showTip(param1:String, param2:Object) : void
      {
         TipControl.show(param1,param2);
      }
      
      public function open(param1:Sprite, param2:String, param3:String = "", param4:Function = null, param5:Function = null) : void
      {
         var _loc6_:EmptyWindow = new EmptyWindow(param2,param1.width,param1.height);
         _loc6_.setContent(param1);
         WControl.open(_loc6_);
      }
      
      public function openShop(param1:int) : void
      {
         WControl.openForName("shop",{"tabSelected":param1});
      }
      
      public function set reloadUserCrop(param1:Boolean) : void
      {
         this._mainData.reloadUserCrop = param1;
      }
      
      public function pushToMaterialLib(param1:ApplicationDomain) : void
      {
         MaterialLib.getInstance().push(param1);
      }
      
      public function isMe() : Boolean
      {
         return this._mainData.me;
      }
      
      public function alertWindow(param1:String, param2:String, param3:Boolean = false) : void
      {
         this._mainCommand.alertWindow(param1,param2,param3);
      }
      
      public function get friendFid() : String
      {
         return this._mainData.currentFid;
      }
      
      public function get swfUrl() : String
      {
         return GetCropID.getSwfUrl();
      }
      
      public function floatWindow(param1:String, param2:String = "info") : void
      {
         this._mainCommand.floatWindow(param1,param2);
      }
      
      public function setExpressUser(param1:Object) : void
      {
         this._mainCommand.setExpressUser(param1);
      }
      
      public function addPrefix(param1:String) : String
      {
         return GetCropID.addPrefix(param1);
      }
      
      public function getMaterial(param1:String) : DisplayObject
      {
         return MaterialLib.getInstance().getMaterial(param1) as DisplayObject;
      }
      
      public function addMoney(param1:Object) : void
      {
         this._mainCommand.addMoney(param1);
      }
      
      public function openConfirmWindow(param1:Object, param2:Function, param3:Function, param4:Boolean = true) : void
      {
         var _loc5_:ConfirmWindow = new ConfirmWindow();
         _loc5_.data = param1;
         _loc5_.confirmFn = param2;
         _loc5_.confirmEnable = param4;
         WControl.open(_loc5_);
      }
      
      public function get iniData() : XML
      {
         return this._iniData;
      }
      
      public function get host() : Object
      {
         return this._mainData.host;
      }
      
      public function get serverTime() : Number
      {
         return CommonData.serverTime;
      }
      
      public function get hostLevel() : int
      {
         return this._mainData.hostLevel;
      }
      
      public function postRequest(param1:String, param2:Object, param3:Function, param4:String = null, param5:String = "farm") : void
      {
         if(param5 == "nc")
         {
            this.fr.postRequest(this._commonNc + param1,param2,param3,param4);
         }
         else if(param5 == "mc")
         {
            this.fr.postRequest(this._commonMc + param1,param2,param3,param4);
         }
         else
         {
            this.fr.postRequest(this._commurl + param1,param2,param3,param4);
         }
      }
      
      public function userSystemCursor(param1:Boolean) : void
      {
         Cursor.useSystem(param1);
      }
      
      public function getMaterialClass(param1:String) : Class
      {
         return MaterialLib.getInstance().getClass(param1);
      }
      
      public function get version() : String
      {
         return Version.value;
      }
      
      public function closeForName(param1:String, param2:Object = null) : void
      {
         WControl.closeForName(param1,param2);
      }
      
      public function get currentUser() : Object
      {
         return this._mainData.currentUser;
      }
      
      public function getMaterialMC(param1:String) : MovieClip
      {
         return MaterialLib.getInstance().getMaterial(param1) as MovieClip;
      }
      
      public function refreshFriendsList(param1:Boolean) : void
      {
         this._mainCommand.getFriendList(param1);
      }
      
      public function get appCurrentDomain() : ApplicationDomain
      {
         return CommonData.applicationDomain;
      }
   }
}


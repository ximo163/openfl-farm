package app4.activities.common
{
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.qui.managers.PopUpManager;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Dictionary;
   import framework.base.BaseLayer;
   import framework.net.CommandDefs;
   import module.Main;
   
   public class FarmAppHelper implements IAllianceAppHelper
   {
      
      private var _mask:Sprite;
      
      protected var _api:IFarmAPI;
      
      private var _maskDict:Dictionary;
      
      private var _popUpContainer:Sprite;
      
      public function FarmAppHelper(param1:IFarmAPI)
      {
         super();
         this._api = param1;
         var _loc2_:BaseLayer = Main.theApp.farmView.getLayerByName(Consts.LAYER_WINDOW);
         if(_loc2_ != null)
         {
            this._popUpContainer = new Sprite();
            _loc2_.addChildAt(this._popUpContainer,0);
            this._maskDict = new Dictionary();
         }
      }
      
      public function get loginUin() : String
      {
         return Session.getInstance().hostUin;
      }
      
      public function execute(param1:String, param2:Object = null) : Object
      {
         return null;
      }
      
      public function removePopup(param1:DisplayObject) : Boolean
      {
         PopUpManager.removePopUp(param1 as DisplayObjectContainer);
         return true;
      }
      
      public function addIconEntrance(param1:DisplayObject) : void
      {
         this._api.messageCenter.dispatchEvent(new CommonEvent(Consts.ADD_ENTRANCE_ICON,param1));
      }
      
      public function showLoadingState() : void
      {
      }
      
      public function popupWindow(param1:DisplayObject) : Boolean
      {
         PopUpManager.addPopUp(param1,true);
         return true;
      }
      
      public function showTips(param1:DisplayObject, param2:String) : void
      {
         this._api.popMouseTip(param2);
      }
      
      public function hideLoadingState() : void
      {
      }
      
      public function hideTips(param1:DisplayObject) : void
      {
         this._api.hideMouseTip();
      }
      
      public function alert(param1:String) : void
      {
         this._api.alert(3,"QQ农场",param1,0,0,null);
      }
      
      public function addNpcEntrance(param1:String, param2:String, param3:int, param4:int, param5:String, param6:String) : Sprite
      {
         var loader:Loader;
         var npc:Sprite = null;
         var loadComplete:Function = null;
         var errorHandler:Function = null;
         var actId:String = param1;
         var url:String = param2;
         var x:int = param3;
         var y:int = param4;
         var tip:String = param5;
         var bubble:String = param6;
         loadComplete = function(param1:Event):void
         {
            if((param1.target as LoaderInfo).content is DisplayObject == false)
            {
               return;
            }
            npc.addChild((param1.target as LoaderInfo).content as Sprite);
            var _loc2_:* = {
               "x":x,
               "y":y,
               "tip":tip,
               "bubble":bubble,
               "role":npc,
               "actId":actId
            };
            _api.messageCenter.dispatchEvent(new CommonEvent(Consts.MSG_INSTALL_NPC,_loc2_));
         };
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         if(actId == "" || actId == null)
         {
            return null;
         }
         if(url == "" || url == null)
         {
            return null;
         }
         url = Settings.getInstance().replaceAppImg(url);
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         loader.load(new URLRequest(url),new LoaderContext(false,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
         npc = new Sprite();
         npc.name = actId;
         npc.mouseChildren = false;
         return npc;
      }
      
      public function getItemIcon(param1:int, param2:int) : DisplayObject
      {
         var _loc4_:String = null;
         var _loc3_:MaterialProxy = null;
         if(param1 == 6 && param2 == 0)
         {
            return Utils.getMaterial("GoldCardsGame") as DisplayObject;
         }
         if(param1 == 7 && param2 == 0)
         {
            return Utils.getMaterial("ExpIcon") as DisplayObject;
         }
         if(param1 == 1)
         {
            _loc3_ = new MaterialProxy();
            _loc3_.setContent(Consts.ITEM_TYPE_SEED,param2);
            return _loc3_;
         }
         if(param1 == 2)
         {
            _loc3_ = new MaterialProxy();
            _loc3_.setContent(Consts.ITEM_TYPE_DECORATE,param2);
            return _loc3_;
         }
         _loc4_ = GetCropID.idToToolName(param2.toString());
         if(_loc4_ == "")
         {
            return null;
         }
         return _loc3_;
      }
      
      public function showBubbleMessage(param1:String) : void
      {
         this._api.popFloatTip(2,param1);
      }
      
      public function payActivityByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         var onSuccess:Function = null;
         var appid:int = param1;
         var id:int = param2;
         var num:int = param3;
         var payType:int = param4;
         var callback:Function = param5;
         onSuccess = function(param1:int, param2:*):void
         {
            if(param2 != null && param2["ret"] == "0")
            {
               QzoneJSAPI.getInGamePay(param2["url"],callback);
            }
            else
            {
               alert("支付失败");
            }
         };
         var postValue:Object = {
            "appid":appid,
            "id":id,
            "num":num,
            "paytype":payType,
            "serviceid":1,
            "type":1,
            "name":"",
            "v":3
         };
         this._api.sendRequest(CommandDefs.CMD_ALLIANCE_PRICE,postValue,onSuccess,null);
      }
      
      public function debugLog(param1:String) : void
      {
      }
      
      public function acceptRewards(param1:Array) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         Session.getInstance().addReward(param1);
      }
   }
}


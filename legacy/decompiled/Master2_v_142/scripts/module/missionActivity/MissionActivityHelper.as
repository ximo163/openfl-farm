package module.missionActivity
{
   import cn.snowkit.containers.Pane;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.interfaces.missionActivity.IMissionActivityAppHelper;
   import com.qzone.allianceActivity.missionActivity.model.MissionActivityConsts;
   import com.qzone.allianceActivity.missionActivity.model.MissionActivityDataModel;
   import com.qzone.corelib.js.JSProxy;
   import common.INI;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import mc.FBridge.FRequest;
   import mc.api.AllianceAppHelper;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.NewIconTip.NewIconTipController;
   import mc.view.main.WindowControl.WindowClassLib;
   import mc.view.main.window.shop.ShopSeedWindow;
   
   public class MissionActivityHelper extends AllianceAppHelper implements IMissionActivityAppHelper
   {
      
      public static var LEFT_PANE:Pane;
      
      private static var instance:MissionActivityHelper;
      
      private var mainData:MainData;
      
      private var callBack:Function;
      
      public function MissionActivityHelper()
      {
         this.mainData = MData.getInstance().mainData;
         super();
      }
      
      public static function gi() : MissionActivityHelper
      {
         if(!instance)
         {
            instance = new MissionActivityHelper();
         }
         return instance;
      }
      
      public function addToPane(param1:DisplayObject) : void
      {
         if(Boolean(param1) && Boolean(LEFT_PANE))
         {
            LEFT_PANE.appendChild(param1);
         }
      }
      
      public function exchangeForGiftHydra(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         var _loc7_:Object = null;
         var _loc6_:String = "";
         _loc6_ = "exchange_gift";
         _loc7_ = {
            "appid":param1,
            "actid":param2,
            "packid":param3,
            "input":param4
         };
         FRequest.getInstance().postRequest2(_loc6_,_loc7_,param5);
      }
      
      public function showBuyAnimalSeedWindow(param1:int) : void
      {
         var doOpen:Function = null;
         var seedID:int = param1;
         doOpen = function(param1:Event = null):void
         {
            var _loc2_:Object = null;
            var _loc3_:* = undefined;
            var _loc4_:WindowEvent = null;
            if(param1)
            {
               mainData.removeEventListener(param1.type,doOpen);
            }
            for each(_loc3_ in mainData.seedInfo)
            {
               if(_loc3_.cId == seedID)
               {
                  _loc2_ = _loc3_;
                  break;
               }
            }
            if(_loc2_)
            {
               WindowClassLib.register("ShopSeedWindow",ShopSeedWindow);
               _loc4_ = new WindowEvent(WindowEvent.OPEN);
               _loc4_.windowName = "ShopSeedWindow";
               _loc4_.windowArgument = _loc2_;
               ViewControl.getInstance().dispatchEvent(_loc4_);
            }
         };
         if(this.mainData.seedInfo)
         {
            doOpen();
         }
         else
         {
            this.mainData.addEventListener(MainData.SEED_INFO,doOpen,false,0,false);
            Command.getInstance().mainCommand.getSeedInfo();
         }
      }
      
      private function diyBuyVerifyFnHydra(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1["ret"] == "0")
         {
            JSProxy.addCallBackProxy("setBoughtRes",this.onInGameBuySuccess);
            _loc2_ = int(INI.getInstance().data.sanbox);
            ExternalInterface.call("SwfAppLib.pay.showBuy",param1["url"],_loc2_ == 1 ? true : false);
         }
         else
         {
            alert(param1["购买批价失败！"]);
         }
      }
      
      public function reloadActivityItems() : void
      {
         MData.getInstance().farmData.reloadActivityItems = true;
      }
      
      public function getPic(param1:int, param2:int) : DisplayObject
      {
         if(param1 == pt_deco && param2 == 0)
         {
            return getMoneyIcon();
         }
         if(param1 == pt_exp)
         {
            return getExpIcon();
         }
         if(param1 == pt_deco)
         {
            return getDecorIcon(param2);
         }
         if(param1 == pt_cub)
         {
            return getSeedIcon(param2);
         }
         return null;
      }
      
      public function removeFromPane(param1:DisplayObject) : void
      {
         if(Boolean(param1) && Boolean(LEFT_PANE))
         {
            LEFT_PANE.removeChild(param1);
         }
      }
      
      public function postRequest(param1:String, param2:Object, param3:Function) : void
      {
         FRequest.getInstance().postRequest(param1,param2,param3);
      }
      
      public function getItemName(param1:int, param2:int) : String
      {
         var _loc3_:Object = null;
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         if(param1 == pt_deco)
         {
            if(param2 == 0)
            {
               return "金币";
            }
            _loc3_ = MVCFacade.getInstance().getObj(MissionActivityConsts.MODEL);
            return (_loc3_ as MissionActivityDataModel).getItemName(param1,param2);
         }
         if(param1 == pt_exp)
         {
            return "经验";
         }
         if(param1 == pt_cub)
         {
            _loc4_ = XML(INI.getInstance().data.animals);
            for each(_loc5_ in _loc4_.animal)
            {
               if(_loc5_.@id == param2)
               {
                  return _loc5_.@name + "幼崽";
               }
            }
         }
         return null;
      }
      
      public function getScoreHydra(param1:int, param2:int, param3:Function) : void
      {
         var _loc5_:Object = null;
         var _loc4_:String = "";
         _loc4_ = "get_score";
         _loc5_ = {
            "appid":param1,
            "actid":param2
         };
         FRequest.getInstance().postRequest2(_loc4_,_loc5_,param3);
      }
      
      public function buyActivityItemHydra(param1:int, param2:int, param3:int, param4:int, param5:Function = null) : void
      {
         var _loc7_:Object = null;
         this.callBack = param5;
         var _loc6_:String = "";
         _loc6_ = "price_goods";
         _loc7_ = {
            "appid":param1,
            "id":param2,
            "num":param3,
            "paytype":param4,
            "serviceid":1,
            "type":1,
            "name":"",
            "v":2
         };
         FRequest.getInstance().postRequest2(_loc6_,_loc7_,this.diyBuyVerifyFnHydra);
      }
      
      private function onInGameBuySuccess(param1:*) : void
      {
         MData.getInstance().farmData.reloadActivityItems = true;
         MData.getInstance().farmData.reloadUserSeed = true;
         if(this.callBack != null)
         {
            this.callBack();
         }
      }
      
      public function loadActivityItemsHydra() : void
      {
         Command.getInstance().farmCommand.getActivityItems();
      }
      
      public function getActivityItemsDataCenter() : EventDispatcher
      {
         return MData.getInstance().farmData;
      }
      
      public function getActivityItems() : Array
      {
         return MData.getInstance().farmData.activityItems;
      }
      
      public function showNewIconTip(param1:Point, param2:String, param3:String = null) : void
      {
         NewIconTipController.show(param1,param2,param3);
      }
   }
}


package mc.api
{
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.qui.managers.PopUpManager;
   import common.INI;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.external.ExternalInterface;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.WindowsManager;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.main.cursor.Cursor;
   
   public class AllianceAppHelper implements IAllianceAppHelper
   {
      
      public static var _type:int;
      
      public static var _id:int;
      
      public static var _num:int;
      
      public static const pt_all:int = 0;
      
      public static const pt_cub:int = 1;
      
      public static const pt_product:int = 2;
      
      public static const pt_harvest:int = 3;
      
      public static const pt_hunter:int = 4;
      
      public static const pt_hunterwage:int = 5;
      
      public static const pt_deco:int = 6;
      
      public static const pt_tin:int = 7;
      
      public static const pt_stool:int = 8;
      
      public static const pt_pack_cub:int = 9;
      
      public static const pt_package:int = 10;
      
      public static const pt_month:int = 11;
      
      public static const pt_hourglass:int = 12;
      
      public static const pt_upden:int = 13;
      
      public static const pt_upshed:int = 14;
      
      public static const pt_rentden:int = 15;
      
      public static const pt_rentshed:int = 16;
      
      public static const pt_exp:int = 20;
      
      public static const pt_red_onemonth:int = 21;
      
      public static const pt_red_oneyear:int = 22;
      
      public static const pt_fool_day:int = 23;
      
      public static const pt_research_exp:int = 24;
      
      public static const pt_research_icon:int = 25;
      
      public static const pt_risk_system:int = 31;
      
      public var desc:String = "-劳动节活动挖宝道具";
      
      public var buyType:String = "alliance";
      
      private var _postValue:Object;
      
      public function AllianceAppHelper()
      {
         super();
         this._postValue = null;
      }
      
      public function execute(param1:String, param2:Object = null) : Object
      {
         return null;
      }
      
      public function getExpIcon() : DisplayObject
      {
         return MaterialLib.getInstance().getMaterial("ExpIcon") as DisplayObject;
      }
      
      public function removePopup(param1:DisplayObject) : Boolean
      {
         PopUpManager.removePopUp(param1 as DisplayObjectContainer);
         return true;
      }
      
      public function get loginUin() : String
      {
         return MData.getInstance().mainData.host["uin"];
      }
      
      public function popupWindow(param1:DisplayObject) : Boolean
      {
         PopUpManager.addPopUp(param1,true);
         return true;
      }
      
      public function getDecorIcon(param1:int) : DisplayObject
      {
         var _loc2_:MaterialLoaderProxy = new MaterialLoaderProxy();
         _loc2_.smallBg = true;
         _loc2_.setContent("3",param1);
         return _loc2_;
      }
      
      public function addIconEntrance(param1:DisplayObject) : void
      {
         WindowsManager.gi().leftPane.appendChild(param1);
      }
      
      public function showLoadingState() : void
      {
      }
      
      public function acceptRewards(param1:Array) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         if(param1 == null || param1.legth == 0)
         {
            return;
         }
         var _loc2_:MainData = MData.getInstance().mainData;
         var _loc3_:MainCommand = Command.getInstance().mainCommand;
         if(param1.length == 1)
         {
            MData.getInstance().farmData.reloadUserSeed = true;
            return;
         }
         for each(_loc4_ in param1)
         {
            if(_loc4_["type"] == 6 && _loc4_["id"] == 0)
            {
               _loc3_.addMoney({"money":_loc4_["cnt"]});
            }
            else if(_loc4_["type"] == 6)
            {
               _loc2_.reloadUserItems = true;
            }
            else if(_loc4_["type"] == 7 || _loc4_["type"] == 12)
            {
               MData.getInstance().farmData.reloadUserSeed = true;
            }
            else if(_loc4_["type"] == 20)
            {
               _loc2_.host["exp"] += _loc4_["cnt"] as int;
               _loc2_.addExp = _loc4_["cnt"] as int;
            }
            else if(_loc4_["type"] == 5)
            {
               _loc5_ = _loc2_.userFarmData;
               if(_loc5_["guard"])
               {
                  _loc5_["guard"]["striketime"] = int(_loc5_["guard"]["striketime"]) + 3600 * 24 * _loc4_["cnt"];
                  _loc2_.hunter = {
                     "id":_loc5_["guard"]["id"],
                     "name":_loc5_["guard"]["name"],
                     "t":_loc5_["guard"]["striketime"],
                     "used":1
                  };
               }
               else
               {
                  _loc6_ = 3600 * 24 * _loc4_["cnt"];
                  if(_loc2_.hunter.hasOwnProperty("t"))
                  {
                     if(int(_loc2_.hunter["t"] <= 0))
                     {
                        _loc2_.hunter["t"] = 0;
                     }
                     _loc2_.hunter = {
                        "id":_loc2_.hunter["id"],
                        "name":_loc2_.hunter["name"],
                        "t":_loc2_.hunter["t"] + _loc6_,
                        "used":1
                     };
                  }
                  else
                  {
                     _loc2_.hunter = {
                        "id":1,
                        "name":"",
                        "t":_loc6_,
                        "used":1
                     };
                  }
               }
            }
         }
      }
      
      public function showTips(param1:DisplayObject, param2:String) : void
      {
      }
      
      public function addNpcEntrance(param1:String, param2:String, param3:int, param4:int, param5:String, param6:String) : Sprite
      {
         return null;
      }
      
      public function getSeedIcon(param1:int) : DisplayObject
      {
         var _loc2_:MaterialLoaderProxy = new MaterialLoaderProxy();
         _loc2_.setContent("9",param1);
         return _loc2_;
      }
      
      public function hideTips(param1:DisplayObject) : void
      {
      }
      
      public function showBubbleMessage(param1:String) : void
      {
         Command.getInstance().mainCommand.floatWindow(param1);
      }
      
      private function returnFn(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(param1["open"] == "1")
         {
            _loc2_ = new Object();
            _loc2_["payitem"] = _type * 10000 + _id + "-" + _num + this.desc;
            _loc2_["payType"] = 1;
            FRequest.getInstance().postRequest2("cgi_pasture_shop_pay",_loc2_,Command.getInstance().mainCommand.onInGamePreCheckSuccess);
            MainData.inGameBuyType = this.buyType;
            MainData.inGameBuyObject["itemType"] = param1["postValue"]["type"];
            return;
         }
         if(param1["errorType"] == "logic" || param1["errorType"] == "system")
         {
            Command.getInstance().mainCommand.alertWindow("error",param1["direction"]);
         }
      }
      
      public function getMoneyIcon() : DisplayObject
      {
         return MaterialLib.getInstance().getMaterial("GoldBigIcon") as DisplayObject;
      }
      
      public function switchSystemCusror(param1:Boolean) : void
      {
         Cursor.useSystem(param1);
      }
      
      public function buyActivityItem(param1:int, param2:int, param3:int) : void
      {
         MainData.inGameBuyType = this.buyType;
         _id = param1;
         _type = param2;
         _num = param3;
         var _loc4_:String = "";
         _loc4_ = INI.getInstance().data.postUrl.@verifyRequest;
         this._postValue = {};
         this._postValue["payitem"] = param2 * 10000 + param1 + "-" + param3 + this.desc;
         FRequest.getInstance().postRequest2(_loc4_,this._postValue,this.diyBuyVerifyFn);
      }
      
      public function ctDig(param1:Object, param2:Function, param3:Function) : void
      {
      }
      
      public function getCtActivityInfo(param1:Function, param2:Function) : void
      {
      }
      
      public function hideLoadingState() : void
      {
      }
      
      public function payActivityByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         var requestURL:String;
         var postValue:Object;
         var checkSuccess:Function = null;
         var buySuccess:Function = null;
         var appid:int = param1;
         var id:int = param2;
         var num:int = param3;
         var payType:int = param4;
         var callback:Function = param5;
         checkSuccess = function(param1:Object):void
         {
            var _loc2_:int = 0;
            if(param1["ret"] == "0")
            {
               JSProxy.addCallBackProxy("setBoughtRes",buySuccess);
               _loc2_ = int(INI.getInstance().data.sanbox);
               ExternalInterface.call("SwfAppLib.pay.showBuy",param1["url"],_loc2_ == 1 ? true : false);
            }
            else
            {
               alert("支付失败");
            }
         };
         buySuccess = function(param1:Object):void
         {
            if(MainData.inGameBuyType == "alliance")
            {
               callback(param1);
            }
         };
         MainData.inGameBuyType = "alliance";
         MainData.inGameBuyObject["itemType"] = id;
         MainData.inGameBuyObject["itemNum"] = num;
         requestURL = "price_goods";
         postValue = {
            "appid":appid,
            "id":id,
            "num":num,
            "paytype":payType,
            "serviceid":1,
            "type":1,
            "name":"",
            "v":3
         };
         FRequest.getInstance().postRequest2(requestURL,postValue,checkSuccess);
      }
      
      public function debugLog(param1:String) : void
      {
      }
      
      public function alert(param1:String) : void
      {
         Command.getInstance().mainCommand.alertWindow("error",param1);
      }
      
      private function diyBuyVerifyFn(param1:Object) : void
      {
         var _loc2_:Object = {};
         if(param1.hasOwnProperty("code"))
         {
            _loc2_["code"] = 1;
            _loc2_["postValue"] = this._postValue;
            if(param1.hasOwnProperty("open") && param1["open"] == "1")
            {
               _loc2_["open"] = param1["open"];
            }
         }
         else if(param1.hasOwnProperty("errorType"))
         {
            _loc2_["code"] = 0;
            _loc2_["errorType"] = param1["errorType"];
            _loc2_["direction"] = param1["errorContent"];
         }
         this.returnFn(_loc2_);
      }
      
      public function getItemIcon(param1:int, param2:int) : DisplayObject
      {
         return null;
      }
   }
}


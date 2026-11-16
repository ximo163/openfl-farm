package app4.activities
{
   import app4.activities.common.FarmAppHelper;
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.sns.QQPay;
   import com.qzone.sns.entities.Payment;
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.display.Sprite;
   import framework.net.protocol.Protocol;
   
   public class CollectingActivity extends FarmAppHelper
   {
      
      private var _activity:IAllianceActivityContext;
      
      public function CollectingActivity(param1:String, param2:IFarmAPI)
      {
         super(param2);
         this._activity = AllianceActivityManager.getInstance().getActivityContext(param1);
      }
      
      override public function execute(param1:String, param2:Object = null) : Object
      {
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc3_:Settings = Settings.getInstance();
         var _loc4_:Session = Session.getInstance();
         switch(param1)
         {
            case "addCustomizeEntrance":
               _loc5_ = param2 as String;
               if(_loc5_ != null && _loc5_ != "")
               {
                  _api.messageCenter.dispatchEvent(new CommonEvent(Consts.MSG_ADD_COLLECTING_ICON,{
                     "url":_loc5_,
                     "tip":"查看收获的果实情况"
                  }));
               }
               break;
            case "10001":
               if(_loc3_.mode == "qzone")
               {
                  return "qzone.qq";
               }
               return _loc3_.xymode;
               break;
            case "10002":
               _api.useSystemCursor(param2 as Boolean);
               break;
            case "10003":
               return _loc4_.hostId;
            case "10004":
               return _loc4_.host.level;
            case "10005":
               return _loc3_.collectCropBySerials();
            case "10006":
               if(param2 != null && param2 is int)
               {
                  return GetCropID.getSeedUrl(param2 as int);
               }
               return "";
               break;
            case "10007":
               return _loc4_.host._headPic;
            case "10008":
               _api.messageCenter.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_BUY_SEED,{"id":param2}));
               break;
            case "10009":
               if(param2 != null)
               {
                  return _loc3_.getCropByID(param2.toString());
               }
               break;
            case "10010":
               return this.loadFriendsDataFromCache();
            case "10011":
               return this.getCommonPostParams();
            case "10012":
               return CommonData.serverTime;
            case "10013":
               if(QzoneJSAPI.WB == true)
               {
                  return "wb";
               }
               return _loc3_.mode;
               break;
            case "10014":
               return _loc4_.host;
            case "10015":
               return Settings.isQZoneUinMode;
            case "10016":
               if(param2 == null)
               {
                  break;
               }
               _loc6_ = param2["uins"] as Array;
               if(_loc6_ != null && _loc6_.length > 0)
               {
                  QzoneJSAPI.getHeadList(_loc6_,25,param2["callback"]);
               }
               break;
            case "10017":
               if(param2 == null)
               {
                  break;
               }
               QQPay.getInstance().payByPlatform(param2["id"],parseInt(Consts.ITEM_TYPE_SEED),param2["num"],25,this.onBuySeedCallback);
               break;
            case "10018":
               if(param2 == null)
               {
                  break;
               }
               return QzoneJSAPI.getHead(param2.toString(),25);
               break;
            case "10019":
               if(param2 == null)
               {
                  break;
               }
               Session.getInstance().updateHostAccount(param2["money"] as int,param2["exp"] as int);
         }
         return null;
      }
      
      private function getCommonPostParams() : Array
      {
         var _loc1_:Array = ["",CommonData.serverTime,"","","",1];
         if(CommonData.getKey != null)
         {
            _loc1_[0] = CommonData.getKey();
         }
         _loc1_[2] = Session.getInstance().hostId;
         _loc1_[3] = Protocol._userUin;
         _loc1_[4] = Session.getInstance().hostUin;
         if(QzoneJSAPI.WB == true)
         {
            _loc1_[5] = 3;
         }
         return _loc1_;
      }
      
      private function onBuySeedCallback(param1:int, param2:Boolean, param3:Payment, param4:*) : void
      {
         var _loc5_:Sprite = null;
         if(param1 == QQPay.PAY_STEP_PAY && param2 == true)
         {
            _api.messageCenter.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
            _api.messageCenter.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
            if(this._activity != null)
            {
               _loc5_ = this._activity.execute("10000",null) as Sprite;
               _api.popFloatTip(0,"支付成功，种子已经放入您的背包里。",_loc5_);
            }
         }
      }
      
      private function loadFriendsDataFromCache() : Array
      {
         var _loc4_:* = undefined;
         if(QzoneJSAPI.WB == true)
         {
            return null;
         }
         var _loc1_:Array = null;
         var _loc2_:String = Session.getInstance().hostId;
         var _loc3_:String = Settings.getInstance().mode;
         _loc1_ = Cookies.getObject(_loc3_ + _loc2_,CommonData.serverTime) as Array;
         for each(_loc4_ in _loc1_)
         {
            if(_loc4_["me"] == true)
            {
               _loc4_["_userName"] = Session.getInstance().host._userName;
            }
         }
         return _loc1_;
      }
   }
}


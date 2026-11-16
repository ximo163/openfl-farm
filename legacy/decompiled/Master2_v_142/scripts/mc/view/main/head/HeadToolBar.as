package mc.view.main.head
{
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.qui.makers.ButtonMaker;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.NewIconTip.NewIconTipController;
   import mc.view.NewIconTip.NewIconTipLayer;
   import mc.view.ViewEvent;
   import mc.view.main.tip.TipControl;
   
   public class HeadToolBar extends Sprite
   {
      
      private var tipsArray:Object = {
         "MC":"我的牧场",
         "farm":"我的农场",
         "warehouse":"仓库（动物产品、未放养幼仔在这）",
         "shop":"牧场商店（来这里领养幼仔）",
         "decorate":"装饰牧场",
         "mill":"加工坊（可加工化肥、罐头等）",
         "restaurant":"我的餐厅"
      };
      
      private var buttonDial:MovieClip;
      
      private var mainData:MainData;
      
      private var buttonMC:MovieClip;
      
      private var restaurantPopUpTip:String;
      
      private var buttonFarm:MovieClip;
      
      private var buttonRestaurant:MovieClip;
      
      private var buttonShop:MovieClip;
      
      private var restaurantAppId:int;
      
      private var buttonDecorate:Sprite;
      
      private var buttonMill:MovieClip;
      
      private var buttonWarehouse:MovieClip;
      
      private var restaurantFarmLevel:int;
      
      private var newIcon:Sprite;
      
      private var bShowNewIcon:Boolean;
      
      public function HeadToolBar()
      {
         super();
         this.mainData = MData.getInstance().mainData;
         this.mainData.addEventListener(MainData.HOST_CHANGE,this.checkForceOpen);
         this.buttonFarm = MaterialLib.getInstance().getMaterial("ButtonFarm") as MovieClip;
         this.buttonFarm.name = "farm";
         this.buttonFarm.cacheAsBitmap = true;
         this.buttonFarm.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonFarm.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonFarm.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.buttonFarm);
         ButtonMaker.addTarget(this.buttonFarm);
         this.buttonMC = MaterialLib.getInstance().getMaterial("ButtonMC") as MovieClip;
         this.buttonMC.name = "MC";
         this.buttonMC.cacheAsBitmap = true;
         this.buttonMC.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonMC.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonMC.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.buttonMC);
         ButtonMaker.addTarget(this.buttonMC);
         if(INI.getInstance().data.logic.restaurantEnterCfg.@open)
         {
            this.buttonRestaurant = MaterialLib.getInstance().getMaterial("ButtonRestaurant") as MovieClip;
            ButtonMaker.addTarget(this.buttonRestaurant);
            this.buttonRestaurant.name = "restaurant";
            this.buttonRestaurant.cacheAsBitmap = true;
            this.buttonRestaurant.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
            this.buttonRestaurant.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
            this.buttonRestaurant.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
            this.buttonRestaurant.iconNO.visible = true;
            addChild(this.buttonRestaurant);
            this.restaurantAppId = 372;
            this.refreshRestaurantIcon(372,true);
         }
         this.buttonMill = MaterialLib.getInstance().getMaterial("ButtonMill") as MovieClip;
         ButtonMaker.addTarget(this.buttonMill);
         this.buttonMill.name = "mill";
         this.buttonMill.cacheAsBitmap = true;
         this.buttonMill.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonMill.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonMill.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         this.mainData.addEventListener("refreshMillIcon",this.refreshMillIcon);
         if(LocalData.parameters["mill"])
         {
            addChild(this.buttonMill);
            this.refreshMillIcon(null);
            Command.getInstance().mainCommand.enforceMill();
         }
         this.buttonWarehouse = MaterialLib.getInstance().getMaterial("ButtonWarehouse") as MovieClip;
         this.buttonWarehouse.name = "warehouse";
         this.buttonWarehouse.cacheAsBitmap = true;
         this.buttonWarehouse.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonWarehouse.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonWarehouse.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.buttonWarehouse);
         ButtonMaker.addTarget(this.buttonWarehouse);
         this.buttonShop = MaterialLib.getInstance().getMaterial("ButtonShop") as MovieClip;
         this.buttonShop.name = "shop";
         this.buttonShop.cacheAsBitmap = true;
         this.buttonShop.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonShop.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonShop.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.buttonShop);
         ButtonMaker.addTarget(this.buttonShop);
         this.buttonDecorate = MaterialLib.getInstance().getMaterial("ButtonDecorate2") as Sprite;
         this.buttonDecorate.name = "decorate";
         this.buttonDecorate.cacheAsBitmap = true;
         this.buttonDecorate.addEventListener(MouseEvent.CLICK,this.buttonClickHandler);
         this.buttonDecorate.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.buttonDecorate.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.buttonDecorate);
         ButtonMaker.addTarget(this.buttonDecorate);
         this.newIcon = MaterialLib.getInstance().getMaterial("NewIcon") as Sprite;
         addChild(this.newIcon);
      }
      
      private function toolRollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",this.tipsArray[param1.currentTarget.name]);
      }
      
      public function setPosition(param1:int = 0) : void
      {
         var _loc3_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc2_:int = 15;
         _loc3_ = param1;
         var _loc4_:int = 0;
         var _loc5_:int = this.numChildren;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = this.getChildAt(_loc6_);
            _loc7_.x = _loc4_;
            _loc7_.y = _loc2_;
            _loc4_ = _loc4_ + _loc7_.width + _loc3_;
            _loc6_++;
         }
         this.newIcon.x = this.buttonDecorate.x + 35;
         this.newIcon.y = this.buttonDecorate.y + 2;
         this.newIcon.mouseChildren = false;
         this.newIcon.mouseEnabled = false;
      }
      
      private function refreshRestaurantIcon(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = this.restaurantFarmLevel;
         if(param2)
         {
            this.buttonRestaurant.iconNO.visible = false;
         }
         else if(this.mainData.host["yellowstatus"] > 0)
         {
            this.buttonRestaurant.iconNO.visible = false;
         }
         else if(_loc3_ == -1)
         {
            this.buttonRestaurant.iconNO.visible = true;
         }
         else
         {
            this.buttonRestaurant.iconNO.visible = this.mainData.hostLevel >= _loc3_ ? false : true;
         }
      }
      
      private function refreshButtonIcon(param1:Boolean, param2:MovieClip, param3:int) : void
      {
         if(param1)
         {
            param2.iconNO.visible = false;
         }
         else if(this.mainData.host["yellowstatus"] >= 1 || param3 == 0)
         {
            if(param3 == 1 && (this.mainData.host["yellowlevel"] == 0 || this.mainData.host["yellowlevel"] == 1))
            {
               param2.iconNO.visible = false;
            }
            else if(this.mainData.host["yellowlevel"] >= param3)
            {
               param2.iconNO.visible = false;
            }
            else
            {
               param2.iconNO.visible = true;
            }
         }
         else
         {
            param2.iconNO.visible = true;
         }
      }
      
      private function toolRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function callJS() : void
      {
         JSProxy.isAppInstall(372,this.refreshRestaurantIcon);
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var _loc2_:URLLoader = param1.currentTarget as URLLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         var _loc3_:XML = XML(_loc2_.data);
         this.restaurantAppId = int(_loc3_.restaurantAppId);
         if(_loc3_.hasOwnProperty("restaurantFarmLevel") == true)
         {
            this.restaurantFarmLevel = int(_loc3_.restaurantFarmLevel);
         }
         this.restaurantPopUpTip = _loc3_.restaurantTip;
         this.bShowNewIcon = Boolean(int(_loc3_.restaurantNewIcon));
         this.buttonRestaurant.iconNEW.visible = this.bShowNewIcon;
         this.callJS();
      }
      
      private function checkForceOpen(param1:Event = null) : void
      {
         var config:XML = null;
         var tipEndTime:Number = NaN;
         var nowTime:Number = NaN;
         var position:Point = null;
         var e:Event = param1;
         this.mainData.removeEventListener(MainData.HOST_CHANGE,this.checkForceOpen);
         if(INI.getInstance().data.limitSales)
         {
            config = INI.getInstance().data.limitSales[0];
            if(config == null)
            {
               return;
            }
            tipEndTime = new Date(String(config.@end)).time;
            nowTime = CommonData.serverTime * 1000;
            if(nowTime < tipEndTime)
            {
               position = new Point(826,58);
               NewIconTipController.show(position,config.@tip,NewIconTipLayer.NEW_ACTIVITY_TIP);
            }
            FRequest.getInstance().postRequest("cgi_fetch_strategy_rules",{"bitpos":int(config.@id)},function(param1:Object):void
            {
               var _loc2_:WindowEvent = null;
               if(param1["bit_flag"] != null && param1["bit_flag"] == true)
               {
                  _loc2_ = new WindowEvent(WindowEvent.OPEN);
                  _loc2_.windowName = "shop";
                  ViewControl.getInstance().dispatchEvent(_loc2_);
               }
            });
         }
      }
      
      private function showRestaurantInfo(param1:int) : void
      {
         var _loc2_:String = "<br/><p align=\'center\'>" + this.restaurantPopUpTip + "</p>";
         if(param1 >= 0)
         {
            _loc2_ = _loc2_.replace(/@level/,param1);
         }
         Command.getInstance().mainCommand.alertWindow("error",_loc2_);
      }
      
      private function refreshMillIcon(param1:Event = null) : void
      {
         var _loc2_:Number = this.mainData.millLimitYDLevel;
         if(this.mainData.millOpened)
         {
            this.buttonMill.iconNO.visible = false;
         }
         else
         {
            this.buttonMill.iconNO.visible = true;
         }
      }
      
      private function enterRestaurant() : void
      {
         var _loc1_:int = this.restaurantAppId;
         JSProxy.toApp(_loc1_,"");
      }
      
      private function buttonClickHandler(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         if(param1.currentTarget.name == "restaurant")
         {
            _loc3_ = this.restaurantFarmLevel;
            if(this.buttonRestaurant != null && this.buttonRestaurant.iconNO != null && this.buttonRestaurant.iconNO.visible == false)
            {
               this.enterRestaurant();
            }
            else
            {
               this.showRestaurantInfo(_loc3_);
            }
            return;
         }
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK);
         _loc2_.data = {
            "target":param1.currentTarget,
            "name":param1.currentTarget.name
         };
         dispatchEvent(_loc2_);
      }
   }
}


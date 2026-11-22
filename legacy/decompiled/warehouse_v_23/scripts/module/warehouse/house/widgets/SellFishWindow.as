package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.makers.StepperMaker;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MaterialProxyBig;
   import common.view.window.BaseWindow;
   import entities.WarehouseFish;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   import module.warehouse.house.WarehouseView;
   
   public class SellFishWindow extends BaseWindow
   {
      
      private var _directionText:TextField;
      
      private var confirmButton:Button;
      
      private var _parentWin:BaseWindow;
      
      private var _material:MaterialProxyBig;
      
      private var _extraText:TextField;
      
      private var _form:MovieClip;
      
      private var _numbericStepper:StepperMaker;
      
      private var _rate:Number;
      
      public function SellFishWindow(param1:BaseWindow)
      {
         this._parentWin = param1;
         var _loc2_:WarehouseView = param1 as WarehouseView;
         super(_loc2_.controller.module.app as IMsgCenter);
         width = 380;
         height = 280;
         title = "卖出成鱼";
         windowName = Consts.WINDOW_NAME_SELLFISH;
         mode = true;
         var _loc3_:Object = Session.getInstance().myFairy;
         if(_loc3_ != null && (_loc3_["itemId"] == Consts.FAIRY_MONEY || _loc3_["itemId"] == Consts.FAIRY_GOD))
         {
            this._rate = _loc3_["rate"] / 100 + 1;
         }
         else
         {
            this._rate = 1;
         }
      }
      
      override protected function init() : void
      {
         this._form = new WarehouseForm();
         this._form.x = 190;
         this._form.y = 32;
         addChild(this._form);
         this._material = new MaterialProxyBig();
         this._material.x = 20;
         this._material.y = 40;
         addChild(this._material);
         this._numbericStepper = new StepperMaker();
         this._numbericStepper.addEventListener(Event.CHANGE,this.onNumChange);
         var _loc1_:SteperSkin = new SteperSkin();
         _loc1_.x = 40;
         _loc1_.y = 170;
         addChild(_loc1_);
         this._numbericStepper.setSkin(_loc1_);
         this._directionText = new TextField();
         this._directionText.mouseEnabled = false;
         this._directionText.selectable = false;
         this._directionText.x = 25;
         this._directionText.y = 195;
         this._directionText.autoSize = TextFieldAutoSize.LEFT;
         this._directionText.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this._directionText.text = Language.replaceText("sellNum",{
            "minNum":1,
            "maxNum":99
         });
         addChild(this._directionText);
         this.confirmButton = new Button();
         this.confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 50;
         this.confirmButton.text = Language.L["卖出"];
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.onSell);
         this.confirmButton.name = "confirm_btn";
         addChild(this.confirmButton);
         var _loc2_:Button = new Button();
         _loc2_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc2_.width = 64;
         _loc2_.height = 25;
         _loc2_.x = width / 2 + 10;
         _loc2_.y = height - 50;
         _loc2_.text = Language.L["关闭"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.onCancel);
         addChild(_loc2_);
         if(this._form.lock_mc != undefined)
         {
            this._form.lock_mc.addEventListener(MouseEvent.CLICK,this.onLock);
            ButtonMaker.addTarget(this._form.lock_mc.lock_btn);
            this._form.lock_mc.lock_btn.useHandCursor = false;
            this._form.lock_mc.y += 40;
         }
         this._extraText = new TextField();
         this._extraText.x = this._form.income.x - 93;
         this._extraText.y = this._form.income.y + 43;
         this._extraText.width = 150;
         this._extraText.selectable = false;
         this._extraText.mouseEnabled = false;
         this._form.addChild(this._extraText);
      }
      
      private function onSell(param1:MouseEvent) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:WarehouseView = null;
         var _loc2_:int = int(QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
         var _loc3_:String = "";
         if(_loc2_ > 5 * 3600)
         {
            _loc3_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
         }
         else if(_loc2_ > 3 * 3600)
         {
            _loc3_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
         }
         else
         {
            this.onOK(param1);
         }
         if(_loc3_ != "")
         {
            _loc4_ = {
               "width":327,
               "height":270,
               "title":"确定",
               "text":_loc3_,
               "confirmFn":this.onOK
            };
            _loc5_ = this._parentWin as WarehouseView;
            _loc5_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc4_);
         }
      }
      
      public function updateLock() : void
      {
         this.updateLockStatus();
      }
      
      private function onLock(param1:MouseEvent) : void
      {
         var _loc2_:WarehouseFish = null;
         var _loc3_:int = 0;
         var _loc4_:WarehouseView = null;
         if(param1.target.name == "lock_btn")
         {
            _loc2_ = super.data as WarehouseFish;
            if(_loc2_ == null)
            {
               return;
            }
            _loc3_ = int(_loc2_._isLock);
            _loc2_._isLock = _loc2_._isLock > 0 ? 0 : 1;
            _loc4_ = this._parentWin as WarehouseView;
            if(_loc4_ != null)
            {
               _loc4_.refreshFishLockStatus(super.data as WarehouseFish,_loc2_._isLock > 0);
            }
            _loc2_._isLock = _loc3_;
         }
      }
      
      private function onNavigateToURL(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text;
         if(_loc2_ == "" || ExternalInterface.available == false)
         {
            return;
         }
         ExternalInterface.call("window.open",_loc2_);
      }
      
      override protected function setData() : void
      {
         var _loc2_:TextFormat = null;
         this.graphics.clear();
         var _loc1_:WarehouseFish = super.data as WarehouseFish;
         if(_loc1_ == null)
         {
            return;
         }
         if(this._material != null)
         {
            this._material.setContent(_loc1_._type.toString(),_loc1_._id);
         }
         if(this._form != null)
         {
            this._numbericStepper.maximum = _loc1_._amount;
            this._numbericStepper.value = _loc1_._amount;
            _loc2_ = new TextFormat("Verdana",26,3381555,true);
            _loc2_.align = TextFormatAlign.CENTER;
            (this._form.cropName as TextField).setTextFormat(_loc2_);
            this._form.cropName.width = 238;
            this._form.cropName.x = -50;
            this._form.cropName.text = _loc1_._name;
            this._form.price.width = 150;
            this._form.price.text = _loc1_._sale;
            this._form.income.width = 150;
            this._form.income.text = _loc1_._sale * this._numbericStepper.value;
            if(this._rate > 1 && this._extraText != null)
            {
               this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>" + Math.ceil(_loc1_._sale * this._numbericStepper.value * (this._rate - 1)) + "</font>";
            }
            this._directionText.text = Language.replaceText("sellNum",{
               "minNum":1,
               "maxNum":_loc1_._amount
            });
            this.updateLockStatus();
         }
      }
      
      private function updateLockStatus() : void
      {
         var _loc1_:WarehouseFish = super.data as WarehouseFish;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_._isLock > 0)
         {
            this._form.lock_mc.visible = true;
            this._form.lock_mc.gotoAndStop("lock");
            this.confirmButton.enabled = false;
         }
         else
         {
            this._form.lock_mc.visible = true;
            this._form.lock_mc.gotoAndStop("unlock");
            this.confirmButton.enabled = true;
         }
      }
      
      private function onNumChange(param1:Event) : void
      {
         var _loc2_:WarehouseFish = super.data as WarehouseFish;
         if(_loc2_ == null)
         {
            return;
         }
         this._form.income.text = _loc2_._sale * this._numbericStepper.value;
         if(this._rate > 1)
         {
            this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>" + Math.ceil(_loc2_._sale * this._numbericStepper.value * (this._rate - 1)) + "</font>";
         }
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         super.onClose(param1);
      }
      
      private function onOK(param1:MouseEvent = null) : void
      {
         var _loc2_:WarehouseFish = super.data as WarehouseFish;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:WarehouseView = this._parentWin as WarehouseView;
         if(_loc3_ != null)
         {
            _loc3_.controller.model.sellFish(_loc2_._id,this._numbericStepper.value);
         }
         super.onClose(param1);
      }
   }
}


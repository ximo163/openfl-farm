package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.makers.StepperMaker;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MaterialProxyBig;
   import common.view.window.BaseWindow;
   import entities.WarehouseCrop;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   import module.warehouse.house.WarehouseView;
   
   public class SellPlantWindow extends BaseWindow
   {
      
      private var _directionText:TextField;
      
      private var _adText:Label;
      
      private var _isMaterial:Boolean;
      
      private var _parentWin:BaseWindow;
      
      private var _material:MaterialProxyBig;
      
      private var _confirmBtn:Button;
      
      private var _form:MovieClip;
      
      private var _extraText:TextField;
      
      private var _numbericStepper:StepperMaker;
      
      private var label:Label;
      
      private var _vipIcon:MovieClip;
      
      private var _rate:Number;
      
      public function SellPlantWindow(param1:BaseWindow, param2:Boolean = false)
      {
         this._isMaterial = param2;
         this._parentWin = param1;
         var _loc3_:WarehouseView = param1 as WarehouseView;
         super(_loc3_.controller.module.app as IMsgCenter);
         width = 380;
         height = 280;
         if(!param2)
         {
            title = Language.L["sellCropWindow"];
         }
         else
         {
            title = Language.L["sellMaterialWindow"];
         }
         windowName = Consts.WINDOW_NAME_SELLPLANT;
         mode = true;
         var _loc4_:Object = Session.getInstance().myFairy;
         if(_loc4_ != null && (_loc4_["itemId"] == Consts.FAIRY_MONEY || _loc4_["itemId"] == Consts.FAIRY_GOD))
         {
            this._rate = _loc4_["rate"] / 100 + 1;
         }
         else
         {
            this._rate = 1;
         }
      }
      
      private function onSell(param1:MouseEvent = null) : void
      {
         var _loc2_:WarehouseView = null;
         var _loc5_:* = undefined;
         var _loc3_:int = int(QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
         var _loc4_:String = "";
         if(_loc3_ > 5 * 3600)
         {
            _loc4_ = "您现在处于长时间游戏的不健康时间段，适当休息一下吧。本次卖出将无法获得任何收益，您确定要卖出吗？";
         }
         else if(_loc3_ > 3 * 3600)
         {
            _loc4_ = "您现在处于疲劳时间段，适当休息一下吧。本次卖出将只能获得正常收益的一半，您确定要卖出吗？";
         }
         else
         {
            this.onOK(param1);
         }
         if(_loc4_ != "")
         {
            _loc5_ = {
               "width":327,
               "height":270,
               "title":"确定",
               "text":_loc4_,
               "confirmFn":this.onOK
            };
            _loc2_ = this._parentWin as WarehouseView;
            _loc2_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc5_);
         }
      }
      
      public function updateLock() : void
      {
         this.updateLockStatus();
      }
      
      private function onNumChange(param1:Event) : void
      {
         var _loc2_:WarehouseCrop = super.data as WarehouseCrop;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Number = 0;
         if(_loc2_._high_price > 0)
         {
            _loc3_ = _loc2_._high_price * this._numbericStepper.value;
            this._form.income.text = _loc3_;
         }
         else
         {
            _loc3_ = _loc2_._price * this._numbericStepper.value;
            this._form.income.text = _loc3_;
         }
         if(this._rate > 1 && this._extraText.htmlText != null && this._extraText.htmlText.indexOf("收入加成") != -1)
         {
            this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\'>" + int(_loc3_ * (this._rate - 1)) + "</font>";
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
      
      private function onLock(param1:MouseEvent) : void
      {
         var _loc2_:WarehouseCrop = null;
         var _loc3_:int = 0;
         var _loc4_:WarehouseView = null;
         if(param1.target.name == "lock_btn")
         {
            _loc2_ = super.data as WarehouseCrop;
            if(_loc2_ == null)
            {
               return;
            }
            _loc3_ = int(_loc2_._isLock);
            _loc2_._isLock = _loc2_._isLock > 0 ? 0 : 1;
            _loc4_ = this._parentWin as WarehouseView;
            if(_loc4_ != null)
            {
               _loc4_.refreshItemLockStatus(super.data as WarehouseCrop,_loc2_._isLock > 0);
            }
            _loc2_._isLock = _loc3_;
         }
      }
      
      override protected function setData() : void
      {
         var _loc2_:TextFormat = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         this.graphics.clear();
         var _loc1_:WarehouseCrop = super.data as WarehouseCrop;
         if(_loc1_ == null)
         {
            return;
         }
         if(this._material != null)
         {
            if(!this._isMaterial)
            {
               this._material.setContent(Consts.ITEM_TYPE_SEED,_loc1_._id);
            }
            else
            {
               this._material.setContent(_loc1_._type.toString(),_loc1_._id);
               if(_loc1_._type.toString() == Consts.ITEM_TYPE_CARD)
               {
                  this._material.scaleX = this._material.scaleY = 0.5;
                  this._material.x = 52;
                  this._material.y = 70;
               }
               else
               {
                  this._material.scaleX = this._material.scaleY = 1;
                  this._material.x = 20;
                  this._material.y = 40;
               }
            }
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
            this._form.price.text = _loc1_._price;
            _loc3_ = 0;
            if(_loc1_._high_price > 0)
            {
               this._form.price.text = _loc1_._high_price;
               this._form.sprice.text = "（原价：金币 " + _loc1_._price.toString() + "）";
               _loc3_ = _loc1_._high_price * this._numbericStepper.value;
               this._form.income.text = _loc3_;
            }
            else
            {
               this._form.price.text = _loc1_._price;
               this._form.sprice.text = "";
               _loc3_ = _loc1_._price * this._numbericStepper.value;
               this._form.income.text = _loc3_;
            }
            if(this._rate > 1 && this._extraText != null)
            {
               _loc4_ = Settings.getInstance().getStringAttribute("exclude_seeds");
               _loc5_ = _loc4_.split(",");
               if(_loc5_ != null && _loc5_.indexOf(_loc1_._id.toString()) == -1)
               {
                  this._extraText.htmlText = "<font color=\'#333333\'>收入加成：</font>" + "<font color=\'#CC3300\'>金币&nbsp;&nbsp;</font><font color=\'#FF6600\' size=\'16\'>" + int(_loc3_ * (this._rate - 1)) + "</font>";
               }
            }
            this._directionText.text = Language.replaceText("sellNum",{
               "minNum":1,
               "maxNum":_loc1_._amount
            });
            if(_loc1_._ext != null)
            {
               if(this._adText == null)
               {
                  this._adText = new Label();
                  this._adText.mouseChildren = true;
                  this._adText.y = 220;
                  this._adText.textField.addEventListener(TextEvent.LINK,this.onNavigateToURL);
                  this._adText.textDefaultFormat = new TextFormat();
               }
               this._adText.text = unescape(_loc1_._ext.toString() || "");
               this._adText.x = 18;
               this.addChild(this._adText);
            }
            else
            {
               DisplayUtil.removeChild(this,this._adText);
            }
            this.updateLockStatus();
            this._material.y = 40;
         }
         if(_loc1_._isVip == 1)
         {
            addChild(this._vipIcon);
         }
      }
      
      private function updateLockStatus() : void
      {
         var _loc1_:WarehouseCrop = super.data as WarehouseCrop;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_._type.toString() == Consts.ITEM_TYPE_CRYSTAL)
         {
            this._form.lock_mc.visible = false;
            this._form.lock_mc.gotoAndStop("unlock");
            this._confirmBtn.enabled = true;
            return;
         }
         if(_loc1_._isLock > 0)
         {
            this._form.lock_mc.visible = true;
            this._form.lock_mc.gotoAndStop("lock");
            this._confirmBtn.enabled = false;
         }
         else
         {
            this._form.lock_mc.visible = true;
            this._form.lock_mc.gotoAndStop("unlock");
            this._confirmBtn.enabled = true;
         }
      }
      
      override public function keyEnter(param1:KeyboardEvent) : void
      {
         var _loc2_:WarehouseCrop = super.data as WarehouseCrop;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_._isLock == 1)
         {
            return;
         }
         this.onOK();
      }
      
      private function onOK(param1:MouseEvent = null) : void
      {
         var _loc2_:WarehouseCrop = super.data as WarehouseCrop;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:WarehouseView = this._parentWin as WarehouseView;
         if(_loc3_ != null)
         {
            if(_loc2_._type.toString() == Consts.ITEM_TYPE_CRYSTAL)
            {
               _loc3_.controller.model.sellCrystal(_loc2_._id,this._numbericStepper.value);
            }
            else
            {
               _loc3_.controller.model.sellPlant(_loc2_._id,this._numbericStepper.value);
            }
         }
         super.onClose(param1);
      }
      
      override protected function addedToLayer() : void
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
         this._confirmBtn = new Button();
         this._confirmBtn.defaultSkin = Utils.getClass("ButtonOrange");
         this._confirmBtn.width = 64;
         this._confirmBtn.height = 25;
         this._confirmBtn.x = width / 2 - this._confirmBtn.width - 10;
         this._confirmBtn.y = height - 40;
         this._confirmBtn.text = Language.L["卖出"];
         this._confirmBtn.addEventListener(MouseEvent.CLICK,this.onSell);
         this._confirmBtn.name = "confirm_btn";
         addChild(this._confirmBtn);
         var _loc2_:Button = new Button();
         _loc2_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc2_.width = 64;
         _loc2_.height = 25;
         _loc2_.x = width / 2 + 10;
         _loc2_.y = height - 40;
         _loc2_.text = Language.L["关闭"];
         _loc2_.addEventListener(MouseEvent.CLICK,super.onClose);
         addChild(_loc2_);
         if(this._form.lock_mc != undefined)
         {
            this._form.lock_mc.addEventListener(MouseEvent.CLICK,this.onLock);
            ButtonMaker.addTarget(this._form.lock_mc.lock_btn);
            this._form.lock_mc.lock_btn.useHandCursor = false;
            this._form.lock_mc.y += 40;
         }
         this._vipIcon = Utils.getMaterial("VipSeedIcon") as MovieClip;
         this._vipIcon.x = this._material.x + 2;
         this._vipIcon.y = this._material.y + 1;
         this._extraText = new TextField();
         this._extraText.x = this._form.income.x - 93;
         this._extraText.y = this._form.income.y + 43;
         this._extraText.width = 150;
         this._extraText.selectable = false;
         this._extraText.mouseEnabled = false;
         this._form.addChild(this._extraText);
      }
   }
}


package module.shop.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.makers.StepperMaker;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.GetCropID;
   import common.Language;
   import common.Session;
   import common.misc.Utils;
   import common.view.MaterialProxyBig;
   import common.view.MoneyIcon;
   import common.view.window.BaseWindow;
   import entities.Player;
   import entities.ShopFish;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   import module.shop.ShopView;
   
   public class BuyFishWindow extends BaseWindow
   {
      
      private var money:MoneyIcon;
      
      private var _material:MaterialProxyBig;
      
      private var _parent:ShopView;
      
      private var _shopSeedForm:Object;
      
      private var cancelButton:Button;
      
      private var _directionText:TextField;
      
      private var _errorText:TextField;
      
      private var _cropPrice:TextField;
      
      private var _confirmButton:Button;
      
      private var stepperSkin:DisplayObject;
      
      private var _numbericStepper:StepperMaker;
      
      private var _userMoney:Number;
      
      public function BuyFishWindow(param1:ShopView)
      {
         super(param1.controller.module.app as IMsgCenter);
         width = 400;
         height = 390;
         title = "购买鱼苗";
         windowName = Consts.WINDOW_NAME_BUYFISH;
         mode = true;
         this._parent = param1;
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         var _loc2_:ShopFish = null;
         if(this._confirmButton.enabled == true)
         {
            _loc2_ = data as ShopFish;
            if(_loc2_ == null)
            {
               return;
            }
            this._parent.controller.model.buyFishs(_loc2_._id,this._numbericStepper.value);
            super.onClose(param1);
         }
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      override protected function setData() : void
      {
         if(super.isInit == false)
         {
            return;
         }
         var _loc1_:ShopFish = super.data as ShopFish;
         if(_loc1_ == null)
         {
            return;
         }
         this.graphics.clear();
         var _loc2_:Player = Session.getInstance().host;
         if(_loc2_ != null)
         {
            this._userMoney = _loc2_._money;
         }
         if(this._shopSeedForm == null)
         {
            this._shopSeedForm = Utils.getMaterial("ShopSeedForm");
            if(this._shopSeedForm == null)
            {
               return;
            }
            this._shopSeedForm.x = 190;
            this._shopSeedForm.y = 40;
            addChild(this._shopSeedForm as DisplayObject);
            this._shopSeedForm.cropTip.addEventListener(TextEvent.LINK,this.onNavigateToURL);
         }
         if(this._cropPrice != null)
         {
            this._cropPrice.text = _loc1_._price.toString();
         }
         if(this._material != null)
         {
            this._material.setContent(Consts.ITEM_TYPE_FISH,_loc1_._id);
         }
         this._numbericStepper.value = 1;
         if(this._shopSeedForm.cropName != undefined)
         {
            this._shopSeedForm.cropName.text = _loc1_._name;
            if(this._shopSeedForm.cropName.width < this._shopSeedForm.cropName.textWidth)
            {
               this._shopSeedForm.cropName.width = this._shopSeedForm.cropName.textWidth + 10;
            }
         }
         if(this._shopSeedForm.cropDetail != undefined)
         {
            this._shopSeedForm.cropDetail.width += 10;
            this._shopSeedForm.cropDetail.htmlText = this.buildContent();
         }
         if(this._shopSeedForm.cropTip != undefined)
         {
            this._shopSeedForm.cropTip.htmlText = GetCropID.fishTip(_loc1_._id.toString());
         }
         var _loc3_:int = int(_loc1_._price);
         var _loc4_:int = _loc3_ > 0 ? int(Math.floor(this._userMoney / _loc3_)) : 1;
         if(_loc4_ >= 100)
         {
            this._directionText.text = Language.replaceText("buyNum",{
               "minNum":1,
               "maxNum":99
            });
            this._numbericStepper.maximum = 99;
         }
         else if(_loc4_ < 100 && _loc4_ >= 1)
         {
            this._directionText.text = Language.replaceText("buyNum",{
               "minNum":1,
               "maxNum":_loc4_
            });
            this._numbericStepper.maximum = _loc4_;
         }
         else if(_loc4_ <= 1)
         {
            this._directionText.text = Language.replaceText("buyNum",{
               "minNum":1,
               "maxNum":1
            });
            this._numbericStepper.maximum = 1;
         }
         if(this._userMoney < _loc3_)
         {
            this._confirmButton.enabled = false;
            this._errorText.text = Language.L["对不起，您的金币不足。"];
         }
         else
         {
            this._errorText.text = "";
            this._confirmButton.enabled = true;
         }
         GameGuide.instance().showStep(GameGuide.WATER_BUY_FISH);
         GameGuide.instance().autoHide(5);
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
      
      private function onNumChanged(param1:Event) : void
      {
         var _loc2_:ShopFish = super.data as ShopFish;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = _loc2_._price * this._numbericStepper.value;
         if(this._userMoney < _loc3_)
         {
            this._errorText.text = Language.L["对不起，您的金币不足。"];
            this._confirmButton.enabled = false;
         }
         else
         {
            this._errorText.text = "";
            this._confirmButton.enabled = true;
         }
         this._cropPrice.text = _loc3_.toString();
      }
      
      private function buildContent() : String
      {
         var _loc1_:String = "";
         var _loc2_:ShopFish = data as ShopFish;
         if(_loc2_ == null)
         {
            return _loc1_;
         }
         _loc1_ += "占用容量：<font color=\"#FF6600\">" + _loc2_._pool_size + "</font>";
         _loc1_ += "<br>成熟时间：<font color=\"#0099FF\">" + _loc2_._mature + "</font> 小时";
         _loc1_ += "<br>预计产量：<font color=\"#0099FF\">" + _loc2_._output + "</font> 条";
         _loc1_ += "<br>成鱼售价：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">" + _loc2_._sale + "</font>";
         _loc1_ += "<br>预计收入：<font color=\"#CC3300\">金币</font><font color=\"#FF6600\">" + (_loc2_._sale * _loc2_._output).toString() + "</font>";
         _loc1_ += "<br>收获经验：<font color=\"#0099FF\">" + _loc2_._exp + "</font>";
         return _loc1_ + "<br>特殊用途：观赏<br>";
      }
      
      override protected function close() : void
      {
         super.close();
         GameGuide.instance().hide();
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         super.onClose(param1);
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         this._material = new MaterialProxyBig();
         this._material.x = 25;
         this._material.y = 40;
         addChild(this._material);
         this.money = new MoneyIcon();
         addChild(this.money);
         this.money.x = 40;
         this.money.y = 170;
         this._cropPrice = new TextField();
         this._cropPrice.selectable = false;
         this._cropPrice.defaultTextFormat = new TextFormat("Verdana",11,16737792,true);
         this._cropPrice.text = "0";
         this._cropPrice.width = 100;
         this._cropPrice.height = 22;
         addChild(this._cropPrice);
         this._cropPrice.x = 70;
         this._cropPrice.y = 170;
         this._numbericStepper = new StepperMaker();
         this._numbericStepper.maximum = 99;
         this._numbericStepper.minimum = 1;
         this._numbericStepper.value = 1;
         this._numbericStepper.addEventListener(Event.CHANGE,this.onNumChanged);
         this.stepperSkin = Utils.getMaterial("SteperSkin") as DisplayObject;
         if(this.stepperSkin != null)
         {
            this.stepperSkin.x = 30;
            this.stepperSkin.y = 200;
            this._numbericStepper.setSkin(this.stepperSkin as Sprite);
            addChild(this.stepperSkin);
         }
         this._directionText = new TextField();
         this._directionText.mouseEnabled = false;
         this._directionText.selectable = false;
         this._directionText.x = 25;
         this._directionText.y = 225;
         this._directionText.autoSize = TextFieldAutoSize.LEFT;
         this._directionText.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this._directionText.text = Language.replaceText("buyNum",{
            "minNum":1,
            "maxNum":99
         });
         addChild(this._directionText);
         this._errorText = new TextField();
         this._errorText.mouseEnabled = false;
         this._errorText.selectable = false;
         this._errorText.x = 0;
         this._errorText.y = this.height - 65;
         this._errorText.width = 400;
         this._errorText.height = 21;
         this._errorText.defaultTextFormat = new TextFormat("Verdana",12,13369344,null,null,null,null,null,TextFormatAlign.CENTER);
         this._errorText.text = "";
         addChild(this._errorText);
         this._confirmButton = new Button();
         this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this._confirmButton.width = 64;
         this._confirmButton.height = 25;
         this._confirmButton.x = width / 2 - this._confirmButton.width - 10;
         this._confirmButton.y = height - 40;
         this._confirmButton.text = Language.L["确定"];
         this._confirmButton.addEventListener(MouseEvent.CLICK,this.onOK);
         addChild(this._confirmButton);
         this.cancelButton = new Button();
         this.cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         this.cancelButton.width = 64;
         this.cancelButton.height = 25;
         this.cancelButton.x = width / 2 + 10;
         this.cancelButton.y = height - 40;
         this.cancelButton.text = Language.L["取消"];
         this.cancelButton.addEventListener(MouseEvent.CLICK,this.onCancel);
         addChild(this.cancelButton);
      }
   }
}


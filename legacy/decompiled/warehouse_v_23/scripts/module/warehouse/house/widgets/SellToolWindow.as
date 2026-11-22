package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.makers.StepperMaker;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Language;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MaterialProxyBig;
   import common.view.window.BaseWindow;
   import entities.WarehouseSeed;
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
   
   public class SellToolWindow extends BaseWindow
   {
      
      private var _form:MovieClip;
      
      private var _material:MaterialProxyBig;
      
      private var _directionText:TextField;
      
      private var _numbericStepper:StepperMaker;
      
      private var _parentWin:BaseWindow;
      
      private var _adText:Label;
      
      private var _vipIcon:MovieClip;
      
      public function SellToolWindow(param1:BaseWindow)
      {
         this._parentWin = param1;
         var _loc2_:WarehouseView = param1 as WarehouseView;
         super(_loc2_.controller.module.app as IMsgCenter);
         width = 380;
         height = 280;
         title = "种子管理";
         windowName = Consts.WINDOW_NAME_SELLSEED;
         mode = true;
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         super.onClose(param1);
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
      
      private function onOK(param1:MouseEvent = null) : void
      {
         var _loc2_:String = "当前回收种子的总价值：<br/><font color=\'#FF6600\'>" + this._form.income.text + "</font> 金币<br/><font color=\'#FF0000\'>您确定要低价出售来之不易的种子？</font>";
         var _loc3_:* = {
            "width":327,
            "height":270,
            "title":"确定",
            "text":_loc2_,
            "confirmFn":this.sellSeed
         };
         var _loc4_:WarehouseView = this._parentWin as WarehouseView;
         _loc4_.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc3_);
      }
      
      override protected function init() : void
      {
         var _loc1_:SteperSkin = null;
         var _loc2_:Button = null;
         this._form = new WarehouseForm();
         this._form.x = 190;
         this._form.y = 45;
         addChild(this._form);
         this._material = new MaterialProxyBig();
         this._material.x = 20;
         this._material.y = 40;
         addChild(this._material);
         this._numbericStepper = new StepperMaker();
         this._numbericStepper.addEventListener(Event.CHANGE,this.onNumChange);
         _loc1_ = new SteperSkin();
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
         _loc2_ = new Button();
         _loc2_.defaultSkin = Utils.getClass("ButtonOrange");
         _loc2_.width = 64;
         _loc2_.height = 25;
         _loc2_.x = width / 2 - _loc2_.width - 10;
         _loc2_.y = height - 50;
         _loc2_.text = Language.L["卖出"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.onSell);
         _loc2_.name = "confirm_btn";
         addChild(_loc2_);
         var _loc3_:Button = new Button();
         _loc3_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc3_.width = 64;
         _loc3_.height = 25;
         _loc3_.x = width / 2 + 10;
         _loc3_.y = height - 50;
         _loc3_.text = Language.L["关闭"];
         _loc3_.addEventListener(MouseEvent.CLICK,this.onCancel);
         addChild(_loc3_);
         this._form.lock_mc.visible = false;
         this._vipIcon = Utils.getMaterial("VipSeedIcon") as MovieClip;
         this._vipIcon.x = this._material.x + 2;
         this._vipIcon.y = this._material.y + 1;
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
      
      private function sellSeed(param1:MouseEvent = null) : void
      {
         var _loc2_:WarehouseSeed = super.data as WarehouseSeed;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:WarehouseView = this._parentWin as WarehouseView;
         if(_loc3_ != null)
         {
            _loc3_.controller.model.sellSeed(_loc2_._id,this._numbericStepper.value);
         }
         super.onClose(param1);
      }
      
      private function onNumChange(param1:Event) : void
      {
         var _loc2_:WarehouseSeed = super.data as WarehouseSeed;
         if(_loc2_ == null)
         {
            return;
         }
         this._form.income.text = _loc2_._price * this._numbericStepper.value;
      }
      
      override protected function setData() : void
      {
         var _loc2_:TextFormat = null;
         this.graphics.clear();
         var _loc1_:WarehouseSeed = super.data as WarehouseSeed;
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
            this._form.price.text = _loc1_._price;
            this._form.income.width = 150;
            this._form.income.text = _loc1_._price * this._numbericStepper.value;
            this._directionText.text = Language.replaceText("sellNum",{
               "minNum":1,
               "maxNum":_loc1_._amount
            });
            if(_loc1_._id == 28)
            {
               if(this._adText == null)
               {
                  this._adText = new Label();
                  this._adText.y = 205;
                  this._adText.textField.addEventListener(TextEvent.LINK,this.onNavigateToURL);
                  this._adText.textDefaultFormat = new TextFormat();
               }
               this._adText.text = unescape(_loc1_._ext || "");
               this._adText.x = AlignUtil.right(380,this._adText.width) - 10;
               this.addChild(this._adText);
            }
            else
            {
               DisplayUtil.removeChild(this,this._adText);
            }
         }
         if(_loc1_._isVip == 1)
         {
            addChild(this._vipIcon);
         }
      }
   }
}


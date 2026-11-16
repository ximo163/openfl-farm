package mc.view.farm.packBar
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.control.NumbericStepper;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.UIEvent;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.Command;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.BaseWindow;
   import mc.view.common.DataLoading;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.window.shop.ErrorText;
   
   public class BuyFoodWindow extends BaseWindow
   {
      
      private var farmData:FarmData;
      
      private var price:TextField = new TextField();
      
      private var cancelButton:LipiButton = new LipiButton();
      
      private var buyMucaoPic:Sprite;
      
      private var price2:TextField = new TextField();
      
      private var errorText:ErrorText;
      
      private var buyButton:LipiButton;
      
      private var halfMoneyText:TextField = new TextField();
      
      private var mucaoPic:Sprite;
      
      private var infoTxt:TextField = new TextField();
      
      private var alertText:TextField;
      
      private var numbericStepper:NumbericStepper;
      
      private var dataLoading:DataLoading = new DataLoading();
      
      private var _confirmFn:Function;
      
      private var _confirmEnable:Boolean = true;
      
      private var confirmButton:LipiButton;
      
      public function BuyFoodWindow()
      {
         super();
         width = 376;
         height = 358;
         titleIMG = MaterialLib.getInstance().getClass("BuyFoodWindowTitle");
         windowName = "selectWindow";
         mode = true;
      }
      
      public function set confirmEnable(param1:Boolean) : void
      {
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = param1;
         }
         this._confirmEnable = param1;
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function numChange(param1:UIEvent = null) : void
      {
         var _loc2_:Number = Number(MData.getInstance().mainData.host["money"]);
         this.price2.htmlText = "<font color=\'#cc3300\'>购买共需:</font><font color=\'#047d20\'><b>金币" + this.numbericStepper.get_num * 60 + "</b></font>";
         if(this.numbericStepper.get_num * 60 > _loc2_)
         {
            this.errorText.text = "对不起，您的金币不足";
         }
         else
         {
            this.errorText.text = "";
         }
         if(this.errorText.visible)
         {
            this.errorText.x = (this.width - this.errorText.width) / 2;
            this.confirmButton.enable = false;
         }
         this.setHalfMoney();
      }
      
      override public function init() : void
      {
         this.alertText = new TextField();
         this.alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width - 50;
         this.alertText.height = 80;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 50;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.htmlText = "";
         addChild(this.alertText);
         this.errorText = new ErrorText();
         this.errorText.visible = false;
         this.errorText.y = 248;
         addChild(this.errorText);
         this.mucaoPic = MaterialLib.getInstance().getMaterial("MucaoGoumai") as Sprite;
         this.mucaoPic.x = (width - this.mucaoPic.width) / 2;
         this.mucaoPic.y = 75;
         addChild(this.mucaoPic);
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 44;
         this.confirmButton.label = "购买";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.cancelButton.bgAlpha = 0;
         this.cancelButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.cancelButton.width = 64;
         this.cancelButton.height = 25;
         this.cancelButton.x = width / 2 + 10;
         this.cancelButton.y = height - 44;
         this.cancelButton.label = "关闭";
         this.cancelButton.textColor = 16777215;
         this.cancelButton.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(this.cancelButton);
         this.halfMoneyText.selectable = false;
         this.halfMoneyText.defaultTextFormat = new TextFormat("Verdana",12);
         this.halfMoneyText.x = 90;
         this.halfMoneyText.y = 200;
         this.halfMoneyText.autoSize = TextFieldAutoSize.LEFT;
         addChild(this.halfMoneyText);
         this.numbericStepper = new NumbericStepper();
         this.numbericStepper.addEventListener(UIEvent.TEXT_CHANGE,this.numChange);
         this.numbericStepper.x = 140;
         this.numbericStepper.y = 210 + 12;
         this.numbericStepper.min_num = 0;
         this.numbericStepper.get_num = 10;
         addChild(this.numbericStepper);
         addChild(this.dataLoading);
         this.dataLoading.x = 110;
         this.dataLoading.y = 100;
         this.price.defaultTextFormat = new TextFormat("Verdana",12);
         this.price.htmlText = "<font color=\'#cc3300\'>单棵售价: </font><font color=\'#047d20\'><b>金币60</b></font>";
         this.price.autoSize = TextFieldAutoSize.LEFT;
         this.price.x = 90;
         this.price.y = 180;
         addChild(this.price);
         this.price2.defaultTextFormat = new TextFormat("Verdana",12);
         this.price2.htmlText = "<font color=\'#cc3300\'>购买共需: </font><font color=\'#047d20\'><b>金币" + this.numbericStepper.get_num * 60 + "</b></font>";
         this.price2.autoSize = TextFieldAutoSize.LEFT;
         this.price2.x = 190 + 10;
         this.price2.y = 180;
         addChild(this.price2);
         var _loc2_:Sprite = MaterialLib.getInstance().getMaterial("WindowLine") as Sprite;
         _loc2_.x = Math.floor((this.width - _loc2_.width) / 2);
         _loc2_.y = 266 + 12;
         addChild(_loc2_);
         this.infoTxt.htmlText = "<font color=\'#666666\'>购买成功后自动放入好友的饲料机中生产饲料(最多" + MainData.MAX_FOOD + "棵)</font>";
         this.infoTxt.autoSize = TextFieldAutoSize.LEFT;
         this.infoTxt.x = (this.width - this.infoTxt.width) / 2;
         this.infoTxt.selectable = false;
         this.infoTxt.y = 273 + 12;
         addChild(this.infoTxt);
         this.setData();
         this.numChange();
      }
      
      public function get confirmEnable() : Boolean
      {
         return this._confirmEnable;
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         if(this.confirmButton.enable == true)
         {
            WControl.close(this);
            Command.getInstance().farmCommand.addFood(this.numbericStepper.get_num,2);
         }
      }
      
      private function buyButtonClick(param1:MouseEvent = null) : void
      {
         if(this.buyButton.enable == true)
         {
            WControl.close(this);
         }
      }
      
      private function setData() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:MainData = MData.getInstance().mainData;
         if(this.alertText != null)
         {
            _loc2_ = Number(MData.getInstance().mainData.host["money"]);
            _loc3_ = Math.floor(_loc2_ / 60) > 1 ? Math.floor(_loc2_ / 60) : 1;
            this.numbericStepper.max_num = MainData.MAX_FOOD < _loc3_ ? int(MainData.MAX_FOOD) : int(_loc3_);
            this.numbericStepper.get_num = 10 < _loc3_ ? 10 : _loc3_;
            this.numbericStepper.min_num = 1;
            this.alertText.htmlText = GetCropID.formatString("请选择给【" + _loc1_.currentUser.userName + "】购买牧草的数量");
            this.setHalfMoney();
         }
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = this.confirmEnable;
         }
      }
      
      private function setHalfMoney() : void
      {
         this.halfMoneyText.htmlText = "<font color=\'#cc3300\'>VIP半价特惠 </font><font color=\'#047d20\'><b>金币" + this.numbericStepper.get_num * 60 / 2 + "  </b></font>" + "";
      }
      
      public function get confirmFn() : Function
      {
         return this._confirmFn;
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      public function set confirmFn(param1:Function) : void
      {
         this._confirmFn = param1;
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         WControl.close(this);
      }
   }
}


package mc.view.main.window.tool
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import com.qzone.qui.controls.TextArea;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DateTimeUtils;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.BlurFilter;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.utils.Timer;
   import mc.FBridge.EventRecorder;
   import mc.control.Command;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.main.window.shop.ErrorText;
   
   public class QuickShootWindow extends BaseWindow
   {
      
      public static const UPLOADING:int = 1;
      
      public static const SUCCESS:int = 2;
      
      public static const ERROR:int = 3;
      
      private var num1Txt:TextField;
      
      private var errorTxt:ErrorText;
      
      public var currentStatus:int = 0;
      
      private var cancelButton:LipiButton;
      
      private var confirmButton:LipiButton;
      
      private var _txtInput:TextField;
      
      private var picInfo:TextArea;
      
      public var confirmFn:Function;
      
      private var num2Txt:TextField;
      
      private var defaultName:String;
      
      public function QuickShootWindow()
      {
         var _loc1_:MovieClip = null;
         super();
         width = 465;
         height = 537;
         titleIMG = MaterialLib.getInstance().getClass("SnapShotWindowTitle");
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 45;
         this.confirmButton.label = "保存";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.cancelButton = new LipiButton();
         this.cancelButton.bgAlpha = 0;
         this.cancelButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.cancelButton.width = 64;
         this.cancelButton.height = 25;
         this.cancelButton.x = width / 2 + 10;
         this.cancelButton.y = height - 45;
         this.cancelButton.label = "取消";
         this.cancelButton.textColor = 16777215;
         this.cancelButton.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(this.cancelButton);
         mode = true;
         _loc1_ = MaterialLib.getInstance().getMaterial("QuickShootBg") as MovieClip;
         addChild(_loc1_);
         _loc1_.x = Math.floor((this.width - _loc1_.width) / 2);
         _loc1_.y = 40;
         var _loc2_:Timer = new Timer(200,1);
         _loc2_.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTime);
         _loc2_.start();
         Style.color = 0;
         this.picInfo = new TextArea();
         this.picInfo.width = 310;
         this.picInfo.height = 50;
         this.picInfo.x = 89;
         this.picInfo.y = 405;
         addChild(this.picInfo);
         this.picInfo.textField.maxChars = 200;
         this.picInfo.textField.addEventListener(Event.CHANGE,this.onNameTxtChange);
         this._txtInput = new TextField();
         this._txtInput.type = TextFieldType.INPUT;
         this._txtInput.width = 310;
         this._txtInput.height = 20;
         var _loc3_:Object = MData.getInstance().mainData.currentUser;
         var _loc4_:String = _loc3_.me ? "我" : "好友";
         var _loc5_:Array = DateTimeUtils.getDate().substr(2).split("-");
         var _loc6_:String = String(_loc5_[1]).length > 1 ? String(_loc5_[1]) : "0" + String(_loc5_[1]);
         var _loc7_:String = String(_loc5_[2]).length > 1 ? String(_loc5_[2]) : "0" + String(_loc5_[2]);
         this.defaultName = _loc4_ + "的牧场" + String(_loc5_[0]) + _loc6_ + _loc7_;
         this._txtInput.text = this.defaultName;
         this._txtInput.maxChars = 30;
         this._txtInput.x = 89;
         this._txtInput.y = 380;
         this._txtInput.addEventListener(Event.CHANGE,this.onNameTxtChange);
         addChild(this._txtInput);
         this._txtInput.filters = [new BlurFilter(0,0,1)];
         this.num1Txt = new TextField();
         this.num1Txt.type = TextFieldType.DYNAMIC;
         this.num1Txt.x = 403;
         this.num1Txt.y = 380;
         this.num1Txt.selectable = false;
         this.num1Txt.htmlText = "<font color=\'#707070\'><b>0</b>/30</font>";
         addChild(this.num1Txt);
         this.num2Txt = new TextField();
         this.num2Txt.type = TextFieldType.DYNAMIC;
         this.num2Txt.x = 403;
         this.num2Txt.y = 405;
         this.num2Txt.selectable = false;
         this.num2Txt.htmlText = "<font color=\'#707070\'><b>0</b>/200</font>";
         addChild(this.num2Txt);
         this.errorTxt = new ErrorText();
         addChild(this.errorTxt);
         this.errorTxt.y = 460;
         this.errorTxt.text = "每天最多拥有5次拍照留念机会";
         this.errorTxt.x = AlignUtil.middle(this.width,this.errorTxt.width);
         this.errorTxt.visible = false;
         this.onNameTxtChange();
         this.checkNum();
      }
      
      public function getStringLength(param1:String) : Number
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.charCodeAt(_loc3_);
            if(_loc4_ >= 255)
            {
               _loc2_ += 2;
            }
            else
            {
               _loc2_ += 1;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function onTime(param1:TimerEvent) : void
      {
         var _loc2_:Sprite = Command.getInstance().toolCommand.drawPic();
         _loc2_.width = 400;
         _loc2_.height = 300;
         _loc2_.y = 55;
         _loc2_.x = Math.floor((this.width - _loc2_.width) / 2);
         this.errorTxt.visible = true;
         addChild(_loc2_);
      }
      
      private function onNameTxtChange(param1:Event = null) : void
      {
         this.num1Txt.htmlText = "<font color=\'#707070\'><b>" + this.getStringLength(this._txtInput.text) + "</b>/30</font>";
         this.num2Txt.htmlText = "<font color=\'#707070\'><b>" + this.getStringLength(this.picInfo.textField.text) + "</b>/200</font>";
         this.checkNum();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         this.closeHandler();
      }
      
      private function checkNum() : void
      {
         if(this.getStringLength(this._txtInput.text) > 30)
         {
            this.errorTxt.text = "照片名最多30个字符。";
            this.errorTxt.x = AlignUtil.middle(this.width,this.errorTxt.width);
            this.confirmButton.enable = false;
            return;
         }
         if(this.getStringLength(this.picInfo.textField.text) > 200)
         {
            this.errorTxt.text = "照片描述最多200个字符。";
            this.errorTxt.x = AlignUtil.middle(this.width,this.errorTxt.width);
            this.confirmButton.enable = false;
            return;
         }
         if(this.errorTxt.text == "每天最多拥有5次拍照留念机会")
         {
            return;
         }
         this.confirmButton.enable = true;
         this.errorTxt.text = "";
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         if(this.confirmButton.enable)
         {
            this.confirmFn(true);
            EventRecorder.recordSueecssEvent(EventRecorder.QUICK_SHOOT,0);
         }
      }
      
      public function setStatus(param1:int) : void
      {
         this.currentStatus = param1;
         switch(param1)
         {
            case UPLOADING:
               this.errorTxt.text = "正在保存图片，请耐心等等...";
               this.confirmButton.enable = false;
               break;
            case SUCCESS:
               this.confirmButton.label = "查看";
               this.cancelButton.label = "关闭";
               this.errorTxt.text = "拍照成功，保存在您的相册中！";
               this._txtInput.type = TextFieldType.DYNAMIC;
               this._txtInput.removeEventListener(Event.CHANGE,this.onNameTxtChange);
               this.picInfo.textField.type = TextFieldType.DYNAMIC;
               this.picInfo.textField.removeEventListener(Event.CHANGE,this.onNameTxtChange);
               this.confirmButton.enable = true;
               break;
            case ERROR:
               this.errorTxt.text = "保存图片失败了，请检查您的网络连接...";
               this.confirmButton.enable = true;
            default:
               this.confirmButton.enable = true;
         }
         if(this.errorTxt.text != "")
         {
            this.errorTxt.visible = true;
            this.errorTxt.x = AlignUtil.middle(this.width,this.errorTxt.width);
         }
      }
      
      public function get picName() : String
      {
         if(this._txtInput.text != "")
         {
            return this._txtInput.text;
         }
         return this.defaultName;
      }
      
      override protected function closeHandler() : void
      {
         super.closeHandler();
         this.confirmFn(false);
      }
      
      public function get picDesc() : String
      {
         return this.picInfo.textField.text;
      }
      
      public function setTxtInfo(param1:String) : void
      {
         this.errorTxt.text = param1;
         this.errorTxt.x = AlignUtil.middle(this.width,this.errorTxt.width);
      }
   }
}


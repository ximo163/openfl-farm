package mc.view.main.window.warehouse
{
   import com.adobe.utils.StringUtil;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.main.WindowControl.WControl;
   
   public class SellAllCubWin extends BaseWindow
   {
      
      private var _confirmFn:Function;
      
      private var alertText:TextField;
      
      protected var cancelButton:LipiButton = new LipiButton();
      
      protected var confirmButton:LipiButton;
      
      private var _tipTxt:MovieClip;
      
      public function SellAllCubWin(param1:Number = 360)
      {
         super();
         this.width = param1;
         height = 210;
         titleIMG = MaterialLib.getInstance().getClass("SellCubWindowTitle");
         windowName = "SellCubSureWin";
         mode = true;
         this.init();
      }
      
      private function saleComplete(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:MainCommand = Command.getInstance().mainCommand;
         if(param1.hasOwnProperty("errorType"))
         {
            EventRecorder.recordErrorEvent("160958",0,14);
            _loc4_ = param1["errorType"];
            if(_loc4_ == "validateCode")
            {
               return;
            }
            if(param1.hasOwnProperty("errorContent") && StringUtil.trim(param1["errorContent"]) != "")
            {
               _loc2_.alertWindow("error",param1["errorContent"]);
               return;
            }
            if(_loc4_ == "IOError" || _loc4_ == "httpStatus" || _loc4_ == "timeOut")
            {
               _loc2_.alertWindow("error","请求超时，稍后再试");
               return;
            }
            return;
         }
         EventRecorder.recordSueecssEvent("160958",0);
         _loc2_.addMoney(param1);
         MData.getInstance().farmData.reloadUserSeed = true;
         _loc2_.getUserCub();
         if(param1.hasOwnProperty("direction") && StringUtil.trim(param1["direction"]) != "")
         {
            _loc3_ = param1["direction"];
         }
         else
         {
            _loc3_ = "成功卖出所有幼仔，获得金币<font color=\'#D18160\'>" + param1["money"] + "</font>";
         }
         _loc2_.floatWindow(_loc3_);
         WControl.close(this);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function setData() : void
      {
         this.alertText = new TextField();
         this.alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Arial",14,8999699,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width - 40;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 50;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.autoSize = TextFieldAutoSize.CENTER;
         this.alertText.htmlText = "<p>当前幼仔回收总价：</p><p><font color=\'#ff6600\'><b>" + data["income"] + "</b></font>金币</p>";
         addChild(this.alertText);
         this._tipTxt = MaterialLib.getInstance().getMaterial("ErrorTips") as MovieClip;
         this._tipTxt.errorTxt.selectable = false;
         (this._tipTxt.errorTxt as TextField).autoSize = TextFieldAutoSize.LEFT;
         this._tipTxt.errorTxt.defaultTextFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,TextFormatAlign.LEFT);
         this._tipTxt.errorTxt.text = "您确定要以原价的一半卖出全部幼仔？";
         this._tipTxt.bg.width = 260;
         this._tipTxt.x = (width - this._tipTxt.width) / 2;
         this._tipTxt.y = this.height - 80;
         addChild(this._tipTxt);
      }
      
      public function get confirmFn() : Function
      {
         return this._confirmFn;
      }
      
      override public function init() : void
      {
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 45;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
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
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:Object = null;
         var _loc3_:FRequest = null;
         if(this.confirmButton.enable == true)
         {
            _loc2_ = {"type":0};
            _loc3_ = FRequest.getInstance();
            _loc3_.postRequest("cgi_sale_cub",_loc2_,this.saleComplete);
         }
      }
      
      public function set confirmFn(param1:Function) : void
      {
         this._confirmFn = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         if(this.alertText)
         {
            this.alertText.width = param1 - 60;
         }
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         WControl.close(this);
      }
   }
}


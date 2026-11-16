package mc.view.farm
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import com.qzone.qui.controls.RadioButton;
   import com.qzone.qui.makers.RadioGroup;
   import common.INI;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.FBridge.EventRecorder;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.common.ConfirmWindow;
   import mc.view.farm.Research.ResearchModel;
   import mc.view.main.WindowControl.WControl;
   
   public class UpdataDen extends BaseWindow
   {
      
      public static const GOLD_BUY:String = "gold_buy";
      
      public static const QD_BUY:String = "qd_buy";
      
      private var _upPic1:Loader;
      
      private var _upPic3:Bitmap;
      
      private var radioGroup:RadioGroup;
      
      private var _upPic2:Loader;
      
      private var confirmButton:LipiButton;
      
      private var errorText:TextField;
      
      private var rbtnQd:RadioButton;
      
      private var alertText:TextField;
      
      private var _confirmEnable:Boolean = true;
      
      private var alertText2:TextField;
      
      private var rbtnGold:RadioButton;
      
      private var textDefaultFormat:TextFormat;
      
      private var _confirmFn:Function;
      
      public function UpdataDen()
      {
         super();
         width = 390;
         height = 330;
         titleIMG = MaterialLib.getInstance().getClass("UpdataDenTile");
         windowName = "ConfirmWindow";
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
      
      private function setRaidoStyle(param1:RadioButton) : void
      {
         param1.textDefaultFormat = this.getTextDefaultFormat();
         param1.textDisabledFormat = this.getTextDisabledFormat();
         param1.textSelectedFormat = this.getTextDefaultFormat();
      }
      
      override public function init() : void
      {
         var _loc1_:TextFormat = null;
         this.alertText = new TextField();
         this.alertText.selectable = false;
         _loc1_ = new TextFormat("Verdana",14,6505509,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 2;
         this.alertText.defaultTextFormat = _loc1_;
         this.alertText.width = width;
         this.alertText.height = 80;
         this.alertText.x = (width - this.alertText.width) / 2;
         this.alertText.y = 220;
         this.alertText.wordWrap = true;
         this.alertText.multiline = true;
         this.alertText.htmlText = "";
         addChild(this.alertText);
         this.alertText2 = new TextField();
         this.alertText2.selectable = false;
         _loc1_ = new TextFormat("Verdana",12,6505509,null,null,null,null,null,TextFormatAlign.LEFT);
         _loc1_.leading = 2;
         this.alertText2.defaultTextFormat = _loc1_;
         this.alertText2.width = width;
         this.alertText2.height = 80;
         this.alertText2.x = (width - this.alertText2.width) / 2;
         this.alertText2.y = 165;
         this.alertText2.wordWrap = true;
         this.alertText2.multiline = true;
         this.alertText2.htmlText = "";
         addChild(this.alertText2);
         this.errorText = new TextField();
         this.errorText.autoSize = TextFieldAutoSize.LEFT;
         this.errorText.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,15214632,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc2_.leading = 8;
         this.errorText.defaultTextFormat = _loc2_;
         this.errorText.height = 80;
         this.errorText.x = (width - this.errorText.width) / 2;
         this.errorText.y = 260;
         this.errorText.htmlText = "";
         addChild(this.errorText);
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
         var _loc3_:LipiButton = new LipiButton();
         _loc3_.bgAlpha = 0;
         _loc3_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc3_.width = 64;
         _loc3_.height = 25;
         _loc3_.x = width / 2 + 10;
         _loc3_.y = height - 45;
         _loc3_.label = "取消";
         _loc3_.textColor = 16777215;
         _loc3_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc3_);
         var _loc4_:TextField = new TextField();
         _loc4_.selectable = false;
         _loc1_ = new TextFormat("Verdana",12,9791031,null,null,true,null,null,TextFormatAlign.LEFT);
         _loc1_.leading = 8;
         _loc4_.defaultTextFormat = _loc1_;
         _loc4_.width = 100;
         _loc4_.height = 80;
         _loc4_.x = 300;
         _loc4_.y = 285;
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.wordWrap = true;
         _loc4_.multiline = true;
         _loc4_.htmlText = "<a href=\'http://user.qzone.qq.com/1006666001/blog/1323777819\' target=\'_blank\'>查看升级帮助</a>";
         addChild(_loc4_);
         this.radioGroup = new RadioGroup();
         this.rbtnGold = new RadioButton();
         this.setRaidoStyle(this.rbtnGold);
         this.rbtnGold.x = 100;
         this.rbtnGold.y = this.alertText.y + 20;
         addChild(this.rbtnGold);
         this.rbtnQd = new RadioButton();
         this.setRaidoStyle(this.rbtnQd);
         this.rbtnQd.x = 210;
         this.rbtnQd.y = this.alertText.y + 20;
         addChild(this.rbtnQd);
         this.rbtnGold.selected = false;
         this.rbtnQd.selected = true;
         this.radioGroup.addTarget(this.rbtnGold);
         this.radioGroup.addTarget(this.rbtnQd);
         this.setData();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:ConfirmWindow = null;
         if(this.confirmButton.enable == true)
         {
            if(data["iscold"] == 1)
            {
               EventRecorder.pgvSendClick(EventRecorder.PGVID_DOUBLE_IN_PRICE);
               EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_DOUBLEINPRICE,0);
               _loc2_ = new ConfirmWindow();
               _loc2_.title = "";
               _loc2_.width = 360;
               _loc2_.data = {"text":"您现在若连续升级，价格将翻倍（24小时后价格恢复）！是否确定？"};
               _loc2_.confirmFn = this.buyDenOrShed;
               WControl.open(_loc2_);
            }
            else
            {
               this.buyDenOrShed();
            }
         }
      }
      
      public function set confirmFn(param1:Function) : void
      {
         this._confirmFn = param1;
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         WControl.close(this);
      }
      
      public function get confirmEnable() : Boolean
      {
         return this._confirmEnable;
      }
      
      public function get confirmFn() : Function
      {
         return this._confirmFn;
      }
      
      private function setData() : void
      {
         var _loc1_:int = 0;
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Class = null;
         if(this.alertText != null && data != null)
         {
            if(data.hasOwnProperty("text"))
            {
               this.alertText.htmlText = data["text"];
               this.alertText2.htmlText = data["text2"];
            }
            if(data.hasOwnProperty("error"))
            {
               this.errorText.text = data["error"];
               this.errorText.x = (width - this.errorText.width) / 2;
               this.alertText2.htmlText = data["text2"];
            }
            if(Boolean(this._upPic1) && contains(this._upPic1))
            {
               removeChild(this._upPic1);
               this._upPic1.unload();
               this._upPic1 = null;
            }
            if(Boolean(this._upPic2) && contains(this._upPic2))
            {
               removeChild(this._upPic2);
               this._upPic2.unload();
               this._upPic2 = null;
            }
            if(Boolean(this._upPic3) && contains(this._upPic3))
            {
               removeChild(this._upPic3);
               this._upPic3 = null;
            }
            _loc1_ = int(data["gold"]);
            this.rbtnGold.text = Math.floor(data["gold"] / 10000) + "万金币";
            this.rbtnQd.text = data["qd"] + "元宝";
            if(MData.getInstance().mainData.host["money"] >= _loc1_)
            {
               this.rbtnGold.enabled = true;
               this.rbtnGold.selected = true;
               this.rbtnQd.selected = false;
            }
            else
            {
               this.rbtnGold.enabled = false;
               if(this.errorText.text == "")
               {
                  this.errorText.text = "您的金币不足，可以用元宝支付。";
                  this.errorText.x = (width - this.errorText.width) / 2;
               }
            }
            if(ResearchModel.gi().denshedType["isIn"])
            {
               if(ResearchModel.gi().denshedType["useGold"])
               {
                  this.rbtnGold.selected = true;
                  this.rbtnQd.selected = false;
               }
               else
               {
                  this.rbtnGold.selected = false;
                  this.rbtnQd.selected = true;
               }
            }
            if(data["iscold"] == 1)
            {
               if(this.errorText.text != "对不起，您的等级不足。")
               {
                  this.errorText.text = "现在若连续升级，价格翻倍（24小时后价格恢复）";
                  this.errorText.x = (width - this.errorText.width) / 2;
               }
            }
            _loc2_ = INI.getInstance().data;
            _loc3_ = data["pic1"];
            trace(_loc3_.substr(_loc3_.indexOf("_") + 2,_loc3_.length));
            if(Number(_loc3_.substr(_loc3_.indexOf("_") + 2,_loc3_.length)) <= 8)
            {
               _loc4_ = GetCropID.getSwfUrl() + "farm/diy/" + data["pic1"] + ".jpg";
            }
            else
            {
               _loc4_ = GetCropID.getSwfUrl() + "farm/diy/" + data["pic1"] + ".png";
            }
            _loc5_ = GetCropID.getSwfUrl() + "farm/diy/" + data["pic2"] + ".png";
            if(data["pic1"] != null)
            {
               _loc6_ = MaterialLib.getInstance().getClass("up_jiantou") as Class;
               this._upPic1 = new Loader();
               this._upPic1.load(new URLRequest(_loc4_));
               addChild(this._upPic1);
               this._upPic1.x = 40;
               this._upPic1.y = 40;
               this._upPic2 = new Loader();
               this._upPic2.load(new URLRequest(_loc5_));
               addChild(this._upPic2);
               this._upPic2.x = 230;
               this._upPic2.y = 40;
               this._upPic3 = new Bitmap(new _loc6_(144,14));
               addChild(this._upPic3);
               this._upPic3.x = 125;
               this._upPic3.y = 150;
            }
            else
            {
               this._upPic2 = new Loader();
               this._upPic2.load(new URLRequest(_loc5_));
               addChild(this._upPic2);
               this._upPic2.x = 125;
               this._upPic2.y = 40;
            }
         }
         if(this.confirmButton != null)
         {
            this.confirmButton.enable = this.confirmEnable;
         }
      }
      
      private function getTextDisabledFormat() : TextFormat
      {
         if(!this.textDefaultFormat)
         {
            this.textDefaultFormat = new TextFormat("Verdana",12,8947848,null,null,null,null,null,"left");
         }
         return this.textDefaultFormat;
      }
      
      private function getTextDefaultFormat() : TextFormat
      {
         if(!this.textDefaultFormat)
         {
            this.textDefaultFormat = new TextFormat("Verdana",12,0,null,null,null,null,null,"left");
         }
         return this.textDefaultFormat;
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      private function buyDenOrShed() : void
      {
         EventRecorder.pgvSendClick(EventRecorder.PGVID_DOUBLE_IN_PRICE_SURE);
         EventRecorder.recordSueecssEvent(EventRecorder.DENSHED_DOUBLEINPRICE_SURE,0);
         if(this.rbtnQd.selected)
         {
            this.confirmFn(UpdataDen.QD_BUY);
         }
         else
         {
            this.confirmFn(UpdataDen.GOLD_BUY);
         }
         WControl.close(this);
      }
   }
}


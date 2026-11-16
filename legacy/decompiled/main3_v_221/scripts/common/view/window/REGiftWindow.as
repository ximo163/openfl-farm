package common.view.window
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.core.Align;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.GetCropID;
   import common.Language;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   
   public class REGiftWindow extends BaseWindow
   {
      
      private var _giftData:Object;
      
      private var _confirmHandler:Function;
      
      private var directionTextField:TextField;
      
      private var vipTextField:TextField;
      
      private var giftNameTextField:TextField;
      
      private var giftSprite:MaterialProxy;
      
      private var confirmButton:Button;
      
      public function REGiftWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 440;
         height = 320;
         mode = true;
         title = Language.L["礼包"];
         windowName = Consts.WINDOW_NAME_REGIFT_CARD;
         this._confirmHandler = null;
         this._giftData = null;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 40;
         if(titleAlign == Align.CENTER)
         {
            panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
         }
         else
         {
            panelTitle.x = 4;
         }
      }
      
      override protected function setData() : void
      {
         var _loc3_:String = null;
         this.graphics.clear();
         var _loc1_:Object = super.data;
         if(_loc1_ == null)
         {
            this.directionText = "";
            this.vipText = "";
            this.confirmHandler = null;
            return;
         }
         var _loc2_:TextFormat = this.directionTextField.defaultTextFormat;
         if(_loc1_.hasOwnProperty("big") == true && _loc1_["big"] == true)
         {
            _loc2_.size = 12;
            this.directionTextField.defaultTextFormat = _loc2_;
         }
         else
         {
            _loc2_.size = 14;
            this.directionTextField.defaultTextFormat = _loc2_;
         }
         if(_loc1_.hasOwnProperty("title") && _loc1_["title"] != undefined && _loc1_["title"] != "")
         {
            super.title = _loc1_["title"];
         }
         else
         {
            super.title = "获得卡片";
         }
         if(_loc1_ is Array)
         {
            _loc3_ = GetCropID.getNameByIDType(Consts.ITEM_TYPE_SEED,_loc1_[0]["eParam"]);
            if(_loc3_ == "未知物品")
            {
               _loc3_ = "活动卡片";
            }
            this.directionText = "恭喜您获得：<font color = \'#ff0000\'>1张" + _loc3_ + "</font>！";
            this.vipText = "小贴士：请在农场“仓库—材料”中查看活动卡片，活动期间卡片可用于兑换礼包，或在加工坊进行加工。";
            this.giftNameTextField.htmlText = _loc3_;
            this.giftSprite.setContent(_loc1_[0]["eType"],_loc1_[0]["eParam"]);
         }
         else
         {
            this.directionText = "恭喜您获得：<font color = \'#ff0000\'>1张" + "活动卡片" + "</font>！";
            this.vipText = "小贴士：请在农场“仓库—材料”中查看活动卡片，活动期间卡片可用于兑换礼包，或在加工坊进行加工。";
            this.giftNameTextField.htmlText = "";
         }
         if(_loc1_.hasOwnProperty("confirmHandler"))
         {
            this.confirmHandler = _loc1_["confirmHandler"] as Function;
         }
         else
         {
            this.confirmHandler = null;
         }
         this.adjustLayout();
      }
      
      public function set vipText(param1:String) : void
      {
         if(this.vipTextField != null)
         {
            this.vipTextField.htmlText = "<font size=\"12\">" + param1 + "</font>";
         }
      }
      
      private function adjustLayout() : void
      {
         var _loc1_:Object = super.data;
         if(_loc1_ != null)
         {
            if(_loc1_.hasOwnProperty("big") == true && _loc1_["big"] == true)
            {
               this.vipTextField.width = 380;
               this.directionTextField.width = 380;
               width = 440;
               height = 320;
            }
            else
            {
               this.vipTextField.width = 340;
               this.directionTextField.width = 340;
               width = 385;
               height = 320;
            }
         }
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         close();
         if(this._confirmHandler != null)
         {
            this._confirmHandler();
         }
         this._confirmHandler = null;
      }
      
      override protected function init() : void
      {
         this.directionTextField = new TextField();
         this.directionTextField.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,3355443);
         _loc1_.leading = 8;
         this.directionTextField.defaultTextFormat = _loc1_;
         this.directionTextField.width = 380;
         this.directionTextField.height = 90;
         this.directionTextField.wordWrap = true;
         this.directionTextField.multiline = true;
         this.directionTextField.x = 20;
         this.directionTextField.y = 30;
         addChild(this.directionTextField);
         this.giftNameTextField = new TextField();
         this.giftNameTextField.selectable = false;
         var _loc2_:TextFormat = new TextFormat("Verdana",12,16711680);
         _loc2_.leading = 8;
         _loc2_.align = TextFormatAlign.CENTER;
         this.giftNameTextField.defaultTextFormat = _loc2_;
         this.giftNameTextField.width = 380;
         this.giftNameTextField.height = 90;
         this.giftNameTextField.wordWrap = true;
         this.giftNameTextField.multiline = true;
         this.giftNameTextField.x = (width - this.giftNameTextField.width) / 2;
         this.giftNameTextField.y = 194;
         addChild(this.giftNameTextField);
         this.vipTextField = new TextField();
         this.vipTextField.selectable = false;
         this.vipTextField.y = 218;
         this.vipTextField.width = 380;
         this.vipTextField.height = 53;
         this.vipTextField.x = 20;
         var _loc3_:TextFormat = new TextFormat("Verdana",12,10027008);
         _loc3_.leading = 5;
         this.vipTextField.defaultTextFormat = _loc3_;
         this.vipTextField.wordWrap = true;
         this.vipTextField.multiline = true;
         addChild(this.vipTextField);
         this.confirmButton = new Button();
         this.confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this.confirmButton.width = 65;
         this.confirmButton.height = 25;
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 40;
         this.confirmButton.text = Language.L["确定"];
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         this.giftSprite = new MaterialProxy();
         this.giftSprite.x = 187;
         this.giftSprite.y = 105;
         addChild(this.giftSprite);
      }
      
      public function set directionText(param1:String) : void
      {
         if(this.directionTextField != null)
         {
            this.directionTextField.htmlText = param1;
         }
      }
      
      override public function onEffectEnd() : void
      {
         _recenter = true;
         super.onEffectEnd();
      }
      
      public function set confirmHandler(param1:Function) : void
      {
         this._confirmHandler = param1;
      }
   }
}


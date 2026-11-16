package common.view.window
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.core.Align;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import entities.Player;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   
   public class GiftWindow extends BaseWindow
   {
      
      private var _giftItemList:Array;
      
      private var _confirmHandler:Function;
      
      private var directionTextField:TextField;
      
      private var _giftData:Object;
      
      private var vipIconSprite:Sprite;
      
      private var renewalSprite:SimpleButton;
      
      private var _vipGiftItemList:Array;
      
      private var confirmButton:Button;
      
      private var _tip:String;
      
      private var vipGiftList:HBox;
      
      private var giftList:HBox;
      
      private var vipTextField:TextField;
      
      private var isVipYear:Boolean;
      
      private var txt:TextField;
      
      public function GiftWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 440;
         height = 330;
         mode = true;
         title = Language.L["礼包"];
         windowName = Consts.WINDOW_NAME_GIFT;
         this._confirmHandler = null;
         this._giftData = null;
      }
      
      public function set vipText(param1:String) : void
      {
         if(this.vipTextField != null)
         {
            this.vipTextField.htmlText = "<font size=\"12\">" + param1 + "</font>";
         }
      }
      
      public function set giftItemList(param1:Array) : void
      {
         var _loc4_:GiftItem = null;
         var _loc5_:* = undefined;
         var _loc2_:Object = super.data;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(_loc2_.hasOwnProperty("big") == true && _loc2_["big"] == true)
         {
            _loc3_ = true;
         }
         this._giftItemList = param1;
         if(this.giftList != null)
         {
            this.giftList.removeAllElements();
            this.giftList.height = _loc3_ ? 150 : 100;
            _loc4_ = null;
            for each(_loc5_ in param1)
            {
               _loc4_ = new GiftItem(_loc3_);
               _loc4_.data = _loc5_;
               this.giftList.addElement(_loc4_);
            }
         }
      }
      
      override public function onEffectEnd() : void
      {
         _recenter = true;
         super.onEffectEnd();
      }
      
      private function setYellowInfo(param1:String) : void
      {
         DisplayUtil.removeChild(this,this.renewalSprite);
         DisplayUtil.removeChild(this,this.vipIconSprite);
         if(parseInt(param1) > 0 && parseInt(param1) <= 7)
         {
            addChild(this.renewalSprite);
            addChild(this.vipIconSprite);
         }
         else
         {
            DisplayUtil.removeChild(this,this.renewalSprite);
            DisplayUtil.removeChild(this,this.vipIconSprite);
         }
         this.setSize();
      }
      
      private function addMouseEventTip(param1:String) : void
      {
         var _loc3_:String = null;
         if(this.txt)
         {
            DisplayUtil.removeChild(this,this.txt);
            this.txt.removeEventListener(MouseEvent.ROLL_OVER,this.tipTxtRollOver);
            this.txt.removeEventListener(MouseEvent.ROLL_OUT,this.tipTxtRollOut);
         }
         this.txt = new TextField();
         this.txt.selectable = false;
         this.txt.width = 100;
         this.txt.height = 100;
         this.txt.addEventListener(MouseEvent.ROLL_OVER,this.tipTxtRollOver);
         this.txt.addEventListener(MouseEvent.ROLL_OUT,this.tipTxtRollOut);
         addChild(this.txt);
         this._tip = "作物类型：@harvestTimes季作物<br/>成熟时间：<font color=\'#339933\'> <b>@growTime</b> </font>小时<br/>预计产量：<font color=\'#339933\'> <b>@output</b> </font>个<br/>果实售价：金币<font color=\'#FF6600\'> <b>@sale</b> </font><br/>预计收入：金币<font color=\'#FF6600\'> <b>@outputMoney</b> </font><br/>收获经验：<font color=\'#FF6600\'> <b>@exp</b> </font>/季<br/>种植等级：<font color=\'#339933\'> <b>@level</b> </font> 级";
         var _loc2_:Object = Settings.getInstance().getCardsGameReward(param1);
         if(_loc2_["growTime"] > 1000)
         {
            _loc2_["growTime"] = (parseInt(_loc2_["growTime"]) / 3600).toString();
         }
         for(_loc3_ in _loc2_)
         {
            this._tip = this._tip.replace("@" + _loc3_,_loc2_[_loc3_]);
         }
         this._tip = this._tip.replace(/@outputMoney/,_loc2_["harvestTimes"] * _loc2_["output"] * _loc2_["sale"]);
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         this.directionTextField.y = 30;
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 40;
         this.giftList.x = AlignUtil.middle(width,this.giftList.width);
         this.giftList.y = this.directionTextField.y + this.directionTextField.textHeight;
         this.vipTextField.y = this.giftList.y + this.giftList.height;
         if(this.vipGiftList.visible == true)
         {
            this.vipGiftList.x = AlignUtil.middle(width,this.vipGiftList.width);
            this.vipGiftList.y = this.vipTextField.y + this.vipTextField.textHeight;
            height = this.vipGiftList.y + this.vipGiftList.height + 50;
         }
         else
         {
            height = this.vipTextField.y + this.vipTextField.textHeight + 50;
         }
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
      
      private function tipTxtRollOut(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = this.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.hideTip();
         }
      }
      
      override protected function init() : void
      {
         this.renewalSprite = Utils.getMaterial("Renewal") as SimpleButton;
         this.renewalSprite.x = 299;
         this.renewalSprite.y = 27;
         this.renewalSprite.addEventListener(MouseEvent.CLICK,this.onNavigateToURL);
         this.vipIconSprite = new Sprite();
         var _loc1_:Class = Utils.getClass("VipIcon") as Class;
         var _loc2_:BitmapData = new _loc1_(13,10);
         this.vipIconSprite.addChild(new Bitmap(_loc2_));
         this.vipIconSprite.x = 14;
         this.vipIconSprite.y = 31;
         this.directionTextField = new TextField();
         this.directionTextField.selectable = false;
         var _loc3_:TextFormat = new TextFormat("Verdana",14,3355443);
         _loc3_.leading = 8;
         this.directionTextField.defaultTextFormat = _loc3_;
         this.directionTextField.width = 390;
         this.directionTextField.height = 90;
         this.directionTextField.wordWrap = true;
         this.directionTextField.multiline = true;
         this.directionTextField.x = AlignUtil.middle(width,this.directionTextField.width);
         this.directionTextField.y = 30;
         addChild(this.directionTextField);
         this.giftList = new HBox(390,150);
         this.giftList.alignH = Align.CENTER;
         this.giftList.alignV = Align.TOP;
         this.giftList.gapH = 35;
         this.giftList.mouseChildren = false;
         this.giftList.mouseEnabled = false;
         this.giftList.horizontalScrollPolicy = "off";
         this.giftList.verticalScrollPolicy = "off";
         this.giftList.defaultSkin = null;
         addChild(this.giftList);
         this.vipTextField = new TextField();
         this.vipTextField.selectable = false;
         this.vipTextField.y = 215;
         this.vipTextField.width = 390;
         this.vipTextField.height = 53;
         this.vipTextField.x = 20;
         var _loc4_:TextFormat = new TextFormat("Verdana",12,10027008);
         _loc4_.leading = 5;
         this.vipTextField.defaultTextFormat = _loc4_;
         this.vipTextField.wordWrap = true;
         this.vipTextField.multiline = true;
         addChild(this.vipTextField);
         this.vipGiftList = new HBox(390,150);
         this.vipGiftList.alignH = Align.CENTER;
         this.vipGiftList.alignV = Align.TOP;
         this.vipGiftList.gapH = 35;
         this.vipGiftList.mouseChildren = false;
         this.vipGiftList.mouseEnabled = false;
         this.vipGiftList.horizontalScrollPolicy = "off";
         this.vipGiftList.verticalScrollPolicy = "off";
         this.vipGiftList.defaultSkin = null;
         this.vipGiftList.visible = false;
         addChild(this.vipGiftList);
         this.confirmButton = new Button();
         this.confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this.confirmButton.width = 65;
         this.confirmButton.height = 25;
         this.confirmButton.x = (width - this.confirmButton.width) / 2;
         this.confirmButton.y = height - 40;
         this.confirmButton.text = Language.L["确定"];
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
      }
      
      public function set confirmHandler(param1:Function) : void
      {
         this._confirmHandler = param1;
      }
      
      public function set directionText(param1:String) : void
      {
         if(this.directionTextField != null && param1 != null)
         {
            this.directionTextField.htmlText = param1;
         }
      }
      
      public function set vipGiftItemList(param1:Array) : void
      {
         var _loc4_:GiftItem = null;
         var _loc5_:* = undefined;
         this._vipGiftItemList = param1;
         if(this.vipGiftList == null)
         {
            return;
         }
         var _loc2_:Object = super.data;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(_loc2_.hasOwnProperty("big") == true && _loc2_["big"] == true)
         {
            _loc3_ = true;
         }
         if(param1 != null && param1.length > 0)
         {
            this.vipGiftList.removeAllElements();
            this.vipGiftList.height = _loc3_ ? 150 : 100;
            _loc4_ = null;
            for each(_loc5_ in param1)
            {
               _loc4_ = new GiftItem(_loc3_);
               _loc4_.data = _loc5_;
               this.vipGiftList.addElement(_loc4_);
            }
            this.vipGiftList.visible = true;
         }
         else
         {
            this.vipGiftList.removeAllElements();
            this.vipGiftList.visible = false;
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
      
      private function tipTxtRollOver(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = this.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.showTip(Consts.TIP_NAME_CROPINFO_MOUSE,this._tip);
         }
      }
      
      private function adjustLayout() : void
      {
         var _loc2_:Player = null;
         var _loc1_:Object = super.data;
         if(_loc1_ != null)
         {
            if(!(_loc1_.hasOwnProperty("everyDayGift") && _loc1_["everyDayGift"] == true))
            {
               DisplayUtil.removeChild(this,this.renewalSprite);
               DisplayUtil.removeChild(this,this.vipIconSprite);
            }
            else
            {
               _loc2_ = Session.getInstance().host;
               if(_loc2_._yellowstatus != 0)
               {
                  QzoneJSAPI.getVipInfo(true,_loc2_._yellowlevel,false,this.setYellowInfo);
               }
            }
            if(_loc1_.hasOwnProperty("cardsGameGift") && Boolean(_loc1_["cardsGameGift"]))
            {
               this.addMouseEventTip(_loc1_["giftID"]);
            }
            else
            {
               DisplayUtil.removeChild(this,this.txt);
            }
            if(_loc1_.hasOwnProperty("big") == true && _loc1_["big"] == true)
            {
               this.vipTextField.width = 390;
               this.directionTextField.width = 390;
               width = 440;
               height = 330;
               if(this.directionTextField.numLines <= 2)
               {
                  this.directionTextField.y += 20;
               }
            }
            else
            {
               this.vipTextField.width = 340;
               this.directionTextField.width = 340;
               width = 385;
            }
         }
         this.setSize();
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         var _loc1_:Object = super.data;
         if(_loc1_ == null)
         {
            this.directionText = "";
            this.vipText = "";
            this.giftItemList = null;
            this.vipGiftItemList = null;
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
         if(_loc1_["title"] != undefined && _loc1_["title"] != "")
         {
            super.title = _loc1_["title"];
         }
         this.directionText = _loc1_["direction"];
         if(_loc1_["levelup"] == true)
         {
            this.confirmButton.text = "领取";
         }
         if(_loc1_["item"] is Array)
         {
            this.giftItemList = _loc1_["item"];
         }
         else
         {
            this.giftItemList = null;
         }
         if(_loc1_.hasOwnProperty("vipText"))
         {
            this.vipText = _loc1_["vipText"];
         }
         else
         {
            this.vipText = "";
         }
         if(_loc1_.hasOwnProperty("vipItem") && _loc1_["vipItem"] != undefined && _loc1_["vipItem"] is Array)
         {
            this.vipGiftItemList = _loc1_["vipItem"];
         }
         else
         {
            this.vipGiftItemList = null;
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
      
      private function onNavigateToURL(param1:MouseEvent) : void
      {
         var _loc2_:String = Settings.getInstance().getStringAttribute("vipRenewal");
         ExternalInterface.call("window.open",_loc2_);
      }
   }
}


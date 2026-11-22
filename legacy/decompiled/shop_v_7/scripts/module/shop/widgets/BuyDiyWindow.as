package module.shop.widgets
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.RadioButton;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import common.view.window.AddButtonWindow;
   import common.view.window.WindowLabelMaker;
   import entities.DIYDecor;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import interfaces.IMsgCenter;
   import module.shop.ShopView;
   
   public class BuyDiyWindow extends AddButtonWindow
   {
      
      private var _postCache:Object;
      
      private var radioGroup:RadioGroup;
      
      private var linkText:TextField;
      
      private var _parent:ShopView;
      
      private var rbtnDiy:RadioButton;
      
      private var _material:MaterialProxy;
      
      private var _directionText:TextField;
      
      private var rbtnJB:RadioButton;
      
      private var _form:Object;
      
      private var rbtnCFT:RadioButton;
      
      private var _btnConfirm:Button;
      
      private var textDefaultFormat:TextFormat;
      
      private var _label:Label;
      
      private var rbtnQB:RadioButton;
      
      public function BuyDiyWindow(param1:ShopView)
      {
         super(param1.controller.module.app as IMsgCenter);
         width = 430;
         height = 340;
         title = Language.L["购买装饰"];
         windowName = Consts.WINDOW_NAME_BUYDIY;
         mode = true;
         this._form = null;
         this._directionText = null;
         this._material = null;
         this._parent = param1;
         this._postCache = null;
         this._btnConfirm = null;
      }
      
      private function createView() : void
      {
         var _loc6_:Sprite = null;
         var _loc7_:Sprite = null;
         removeAllButton();
         var _loc1_:String = Settings.getInstance().getDynamicTip("shopVipDIYTip") || "稀有装扮限时购买";
         this._label = new Label(_loc1_);
         this._label.width = width - 5;
         this._label.x = 1;
         this._label.y = 27;
         this._label.mouseChildren = true;
         WindowLabelMaker.addTarget(this._label);
         var _loc2_:TextFormat = new TextFormat("Verdana",null,null,null,null,null,null,null,"center");
         this._label.textDefaultFormat = _loc2_;
         addChild(this._label);
         var _loc3_:Button = new Button();
         _loc3_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc3_.text = "预览";
         _loc3_.width = 60;
         _loc3_.height = 25;
         _loc3_.x = 50;
         _loc3_.y = 182;
         this.addChild(_loc3_);
         _loc3_.addEventListener(MouseEvent.CLICK,this.onPreview);
         this._form = Utils.getMaterial("ShopDiyForm") as Object;
         if(this._form != null)
         {
            this._form.x = 190;
            this._form.y = 40;
            addChild(this._form as Sprite);
         }
         this._directionText = new TextField();
         this._directionText.defaultTextFormat = new TextFormat("Verdana",12,13369344,false,null,null,null,null,TextFormatAlign.CENTER);
         this._directionText.width = 400;
         this._directionText.height = 21;
         this._directionText.x = 0;
         this._directionText.y = this.height - 65;
         this._directionText.selectable = false;
         addWindowChild(this._directionText);
         var _loc4_:Class = Utils.getClass("ItemBorder");
         if(_loc4_ != null)
         {
            _loc6_ = new _loc4_() as Sprite;
            _loc7_ = new _loc4_() as Sprite;
            _loc7_.width = _loc6_.width = 120;
            _loc7_.height = _loc6_.height = 120;
            this._material = new MaterialProxy(MaterialProxy.BIG);
            this._material.x = _loc7_.x = _loc6_.x = 20;
            this._material.y = _loc7_.y = _loc6_.y = 50;
            this._material.mask = _loc6_;
            addWindowChild(this._material);
            addWindowChild(_loc6_);
            addWindowChild(_loc7_);
         }
         this._btnConfirm = addButton(Language.L["确定"],"ButtonOrange",60,25,this.onOK);
         addButton(Language.L["取消"],"ButtonBlue",60,25,super.close);
         var _loc5_:int = 4;
         this.rbtnDiy = new RadioButton("VIP LV" + _loc5_ + "及以上免费装扮（无期限，不获得经验值）");
         this.setRaidoStyle(this.rbtnDiy);
         this.rbtnDiy.x = 68;
         this.rbtnDiy.y = this.height - 115;
         this.rbtnJB = new RadioButton("金币买");
         this.setRaidoStyle(this.rbtnJB);
         this.rbtnJB.x = 68;
         this.rbtnJB.y = this.height - 90;
         this.rbtnQB = new RadioButton("元宝买");
         this.setRaidoStyle(this.rbtnQB);
         this.rbtnQB.x = 148;
         this.rbtnQB.y = this.height - 90;
         this.rbtnCFT = new RadioButton("暂时无用");
         this.setRaidoStyle(this.rbtnCFT);
         this.rbtnCFT.x = 228;
         this.rbtnCFT.y = this.height - 90;
      }
      
      private function onOK() : void
      {
         if(this.radioGroup.selectedTarget == this.rbtnDiy)
         {
            this.diyByYellowLvl();
         }
         else if(this.radioGroup.selectedTarget == this.rbtnJB)
         {
            this.useGoldBuy();
         }
         else if(this.radioGroup.selectedTarget == this.rbtnQB)
         {
            this.useQDBuy();
         }
         else if(this.radioGroup.selectedTarget == this.rbtnCFT)
         {
            this.useCFTBuy();
         }
      }
      
      private function onPreCheckedError(param1:CommandEvent) : void
      {
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.hasOwnProperty("direction") == true)
         {
            this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc3_["direction"]
            });
         }
         this._postCache = null;
      }
      
      private function useCFTBuy() : void
      {
         var _loc1_:DIYDecor = super.data as DIYDecor;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:int = parseInt(Consts.ITEM_TYPE_DECORATE);
         var _loc3_:int = int(_loc1_._type);
         var _loc4_:int = int(_loc1_._id);
         var _loc5_:int = 1;
         NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK,{
            "shopType":_loc2_,
            "itemType":_loc3_,
            "itemId":_loc4_,
            "itemNum":_loc5_
         },this.qqBuyCFTPreChecked,this.onPreCheckedError);
         super.close();
      }
      
      private function onLinkUpgradeClicked(param1:TextEvent) : void
      {
         QzoneJSAPI.openWindow("");
      }
      
      private function setRaidoStyle(param1:RadioButton) : void
      {
         param1.textDefaultFormat = this.getTextDefaultFormat();
         param1.textDisabledFormat = this.getTextDisabledFormat();
         param1.textSelectedFormat = this.getTextDefaultFormat();
      }
      
      private function useQDBuy() : void
      {
         var _loc1_:DIYDecor = super.data as DIYDecor;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:int = 2;
         var _loc3_:int = int(_loc1_._type);
         NetHelper.sendRequest(CommandDefs.CMD_BUY_PRECHECK,{
            "shopType":_loc2_,
            "itemType":_loc3_,
            "itemId":_loc1_._id,
            "itemNum":1
         },this.qqBuyPreChecked,this.onPreCheckedError);
         super.close();
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      private function yellowLvlDiyFn(param1:CommandEvent) : void
      {
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_["code"] == "1")
         {
            this._parent.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
            this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_SUCCESS,
               "text":"免费装饰成功！"
            });
         }
         else if(_loc3_.hasOwnProperty("direction") == true)
         {
            this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc3_["direction"]
            });
         }
      }
      
      private function onPreview(param1:Event) : void
      {
         m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_ENTER_PREVIEW,super.data));
      }
      
      override protected function setData() : void
      {
         var _loc3_:TextField = null;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         this.graphics.clear();
         if(super.isInit == false)
         {
            return;
         }
         super.init();
         var _loc1_:Player = Session.getInstance().host;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:DIYDecor = super.data as DIYDecor;
         if(_loc2_ == null)
         {
            return;
         }
         _loc3_ = new TextField();
         _loc3_.text = "请选择：";
         _loc3_.selectable = false;
         _loc3_.x = 20;
         _loc3_.y = this.height - 115;
         _loc3_.width = 50;
         addChild(_loc3_);
         this.radioGroup = new RadioGroup();
         _loc4_ = 4;
         this.radioGroup.removeTarget(this.rbtnDiy);
         this.radioGroup.removeTarget(this.rbtnJB);
         this.radioGroup.removeTarget(this.rbtnQB);
         this.radioGroup.removeTarget(this.rbtnCFT);
         this.rbtnDiy.selected = false;
         this.rbtnJB.selected = false;
         this.rbtnQB.selected = false;
         this.rbtnCFT.selected = false;
         if(this.rbtnDiy.parent == null)
         {
            addChild(this.rbtnDiy);
         }
         if(this.rbtnJB.parent == null)
         {
            addChild(this.rbtnJB);
         }
         this.radioGroup.addTarget(this.rbtnDiy);
         this.radioGroup.addTarget(this.rbtnJB);
         this.linkText = new TextField();
         this.linkText.htmlText = "";
         this.linkText.addEventListener(TextEvent.LINK,this.onLinkUpgradeClicked);
         this.linkText.x = _loc3_.width + this.rbtnDiy.width + 20;
         this.linkText.y = this.height - 115;
         addChild(this.linkText);
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         if(_loc1_._yellowstatus >= 1 && _loc1_._yellowlevel >= _loc4_)
         {
            this.rbtnDiy.enabled = true;
            this.radioGroup.selectedTarget = this.rbtnDiy;
            this.rbtnDiy.selected = true;
         }
         else
         {
            this.rbtnDiy.enabled = false;
         }
         if(_loc1_._money < _loc2_._price)
         {
            _loc5_ = true;
            this.rbtnJB.enabled = false;
         }
         else
         {
            this.rbtnJB.enabled = true;
            this.radioGroup.selectedTarget = this.rbtnJB;
            this.rbtnJB.selected = true;
         }
         if(_loc2_._fb != 0)
         {
            _loc7_ = int(_loc2_._fb);
            if(_loc1_._yellowstatus >= 1)
            {
               _loc7_ = int(_loc2_._yfb);
            }
            if(this.rbtnQB.parent == null)
            {
               addChild(this.rbtnQB);
            }
            this.radioGroup.addTarget(this.rbtnQB);
            this.radioGroup.selectedTarget = this.rbtnQB;
            this.rbtnQB.selected = true;
            _loc8_ = _loc2_._fb * 0.88 * 0.1;
            if(_loc1_._yellowstatus >= 1)
            {
               _loc8_ = _loc2_._yfb * 0.88 * 0.1;
            }
            if(this.rbtnCFT.parent == null)
            {
               addChild(this.rbtnCFT);
            }
            this.radioGroup.addTarget(this.rbtnCFT);
            if(!this.rbtnDiy.selected && !this.rbtnJB.selected && !this.rbtnQB.selected)
            {
               this.radioGroup.selectedTarget = this.rbtnCFT;
               this.rbtnCFT.selected = true;
            }
         }
         else
         {
            if(this.rbtnQB.parent != null)
            {
               this.rbtnQB.parent.removeChild(this.rbtnQB);
            }
            if(this.rbtnCFT.parent != null)
            {
               this.rbtnCFT.parent.removeChild(this.rbtnCFT);
            }
         }
         if(_loc2_._price <= 0)
         {
            this.rbtnJB.parent.removeChild(this.rbtnJB);
            this.radioGroup.removeTarget(this.rbtnJB);
            this.rbtnDiy.parent.removeChild(this.rbtnDiy);
            this.radioGroup.removeTarget(this.rbtnDiy);
            this.rbtnQB.x = 68;
            this.rbtnCFT.x = 148;
            this.rbtnCFT.y = this.rbtnQB.y = this.height - 115;
            this._label.visible = true;
            this._form.y = 48;
         }
         else
         {
            this.rbtnQB.x = 148;
            this.rbtnCFT.x = 228;
            this.rbtnCFT.y = this.rbtnQB.y = this.height - 90;
            this._label.visible = false;
            this._form.y = 40;
         }
         if(_loc1_._yellowlevel < _loc4_ && _loc2_._fb == 0 && _loc5_)
         {
            this._btnConfirm.enabled = false;
         }
         else
         {
            this._btnConfirm.enabled = true;
         }
         this._directionText.text = "";
         if(_loc5_ && !_loc6_)
         {
            this._directionText.text = Language.L["您的金币不足。"];
         }
         else if(!_loc5_ && _loc6_)
         {
            this._directionText.text = Language.L["您的元宝不足。"];
         }
         else if(_loc5_ && _loc6_)
         {
            this._directionText.text = Language.L["您的元宝和金币都不足。"];
         }
         if(this._form != null)
         {
            (this._form.diyName as TextField).defaultTextFormat = new TextFormat("Verdana",26,3381555,true);
            this._form.diyName.text = _loc2_._name;
            if(this._form.diyDetail != null)
            {
               this._form.diyDetail.htmlText = this.buildContent();
            }
         }
         if(this._material != null)
         {
            this._material.setContent("2",_loc2_._id,true);
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
      
      private function qqBuyCFTPreChecked(param1:CommandEvent) : void
      {
         var _loc4_:DIYDecor = null;
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_["code"] == "1")
         {
            _loc4_ = super.data as DIYDecor;
            this._parent.controller.model.buyInGame(param1.body["__body"],2,"DIY",_loc4_._exp);
         }
      }
      
      private function diyByYellowLvl() : void
      {
         var _loc1_:DIYDecor = super.data as DIYDecor;
         var _loc2_:int = int(_loc1_._id);
         NetHelper.sendRequest(CommandDefs.CMD_ITEM_VIP,{"itemId":_loc2_},this.yellowLvlDiyFn,this.onPreCheckedError);
         super.close();
      }
      
      private function buildContent() : String
      {
         var _loc1_:DIYDecor = super.data as DIYDecor;
         if(_loc1_ == null)
         {
            return "";
         }
         var _loc2_:String = "";
         if(_loc1_._price > 0)
         {
            _loc2_ += "金币价：<font size=\"11\" color=\"#FF6600\"><b>" + _loc1_._price + "</b></font> <font color=\"#CC3300\">金币</font><br>";
         }
         var _loc3_:int = -60;
         if(_loc1_._fb != 0)
         {
            _loc2_ += "<textformat indent=\"2\">元宝价</textformat>：普通 <font size=\"11\" color=\"#0099FF\"><b>" + _loc1_._fb + "</b></font> <font color=\"#003366\">元宝</font><br>";
            _loc2_ += "特惠价：VIP <font size=\"11\" color=\"#FF6600\"><b>" + _loc1_._yfb + "</b></font> <font color=\"#003366\">元宝</font> (节省 <font size=\"11\" color=\"#FF6600\"><b>";
            _loc2_ += _loc1_._fb - _loc1_._yfb + "</b></font> <font color=\"#003366\">元宝</font>)<br />";
            _loc2_ += "<p align=\"right\"><font size=\"12\" color=\"#666666\"></font></p>";
         }
         return _loc2_ + ("有效期：" + _loc1_._validTime / 86400 + " 天，可获得经验值：" + _loc1_._exp + "<br />");
      }
      
      private function qqBuyPreChecked(param1:CommandEvent) : void
      {
         var _loc4_:DIYDecor = null;
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_["code"] == "1")
         {
            _loc4_ = super.data as DIYDecor;
            this._parent.controller.model.buyInGame(param1.body["__body"],1,"DIY",_loc4_._exp);
         }
      }
      
      private function getTextDefaultFormat() : TextFormat
      {
         if(!this.textDefaultFormat)
         {
            this.textDefaultFormat = new TextFormat("Verdana",12,0,null,null,null,null,null,"left");
         }
         return this.textDefaultFormat;
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         this.createView();
      }
      
      private function useGoldBuy() : void
      {
         var _loc1_:DIYDecor = super.data as DIYDecor;
         if(_loc1_ == null)
         {
            return;
         }
         this._parent.controller.model.buyDiy(_loc1_._id);
         super.close();
      }
   }
}


package module.warehouse.house.widgets
{
   import com.qzone.qui.containers.Canvas;
   import com.qzone.qui.containers.TileList;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.Line;
   import common.view.window.WindowLabelMaker;
   import entities.Player;
   import entities.WarehouseCrop;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import module.uitools.widgets.profile.PropertyText;
   import module.warehouse.house.WarehouseController;
   import module.warehouse.house.WarehouseView;
   
   public class PlantsPage extends BasePage
   {
      
      private var _tfEmpty:TextField;
      
      private var _tfPrice:TextField;
      
      private var _sum:Number;
      
      private var _yellowTip:Label;
      
      private var _sendFlowerBtn:Button;
      
      private var _sumPrice:PropertyText;
      
      private var _warehouseType:int;
      
      private var _gotoShopBtn:Button;
      
      private var _sellBtn:Button;
      
      private var _canvas:Canvas;
      
      private var _isFlowerPage:Boolean;
      
      private var _sendFlowerContainer:Sprite;
      
      public function PlantsPage(param1:WarehouseView, param2:int, param3:int, param4:Boolean)
      {
         super(param1,param2,param3);
         this._isFlowerPage = param4;
         if(this._isFlowerPage)
         {
            this._warehouseType = Consts.WAREHOUSE_FLOWER;
         }
         else
         {
            this._warehouseType = Consts.WAREHOUSE_CROP;
         }
         this.createSendFlower();
         this._sendFlowerContainer.visible = false;
         this._yellowTip = new Label();
         this._yellowTip.text = Language.L["warehouseDirection"];
         this._yellowTip.x = 2;
         this._yellowTip.width = param2 - 3;
         WindowLabelMaker.addTarget(this._yellowTip);
         this._sellBtn = new Button();
         this._sellBtn.width = 85;
         this._sellBtn.height = 25;
         this._sellBtn.defaultSkin = Utils.getClass("ButtonGreen");
         this._sellBtn.x = param2 - this._sellBtn.width - 15;
         this._sellBtn.y = param3 - this._sellBtn.height - 4;
         this._sellBtn.text = Language.L["sellSome"];
         this._sellBtn.addEventListener(MouseEvent.ROLL_OVER,this.onSellBtnOver);
         this._sellBtn.addEventListener(MouseEvent.ROLL_OUT,this.onSellBtnOut);
         this._sellBtn.addEventListener(MouseEvent.CLICK,this.onSellBtnClicked);
         addChild(this._sellBtn);
         if(this._isFlowerPage == true && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            this._sendFlowerBtn = new Button();
            this._sendFlowerBtn.width = 85;
            this._sendFlowerBtn.height = 25;
            this._sendFlowerBtn.defaultSkin = Utils.getClass("ButtonBlue");
            this._sendFlowerBtn.x = this._sellBtn.x - this._sendFlowerBtn.width - 15;
            this._sendFlowerBtn.y = param3 - this._sendFlowerBtn.height - 4;
            this._sendFlowerBtn.cacheAsBitmap = true;
            this._sendFlowerBtn.text = "送给好友花束";
            this._sendFlowerBtn.clickFn = this.onSendFlowerBtn;
            addChild(this._sendFlowerBtn);
         }
         this._tfPrice = new TextField();
         this._tfPrice.selectable = false;
         this._tfPrice.defaultTextFormat = new TextFormat("Verdana",12,39423,true);
         this._tfPrice.autoSize = TextFieldAutoSize.LEFT;
         this._tfPrice.text = Language.L["sumGold"];
         this._tfPrice.x = 8;
         this._tfPrice.y = param3 - this._tfPrice.height - 4;
         addChild(this._tfPrice);
         var _loc5_:Object = Session.getInstance().myFairy;
         if(_loc5_ != null && (_loc5_["itemId"] == Consts.FAIRY_MONEY || _loc5_["itemId"] == Consts.FAIRY_GOD))
         {
            this._sumPrice = new PropertyText("gold",180,false);
            this._sumPrice.x = this._tfPrice.width + this._tfPrice.x - 7;
         }
         else
         {
            this._sumPrice = new PropertyText("gold",180,true);
            this._sumPrice.x = this._tfPrice.width + this._tfPrice.x;
         }
         this._sumPrice.y = param3 - this._sumPrice.height;
         addChild(this._sumPrice);
      }
      
      private function onOK() : void
      {
         this.controller.model.sellAll(this._warehouseType);
      }
      
      private function onNotEnough(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.controller.openWindow(Consts.WINDOW_NAME_SENDFLOWER,param1.data);
      }
      
      private function sumUp() : void
      {
         var _loc6_:WarehouseCrop = null;
         var _loc7_:Object = null;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         var _loc3_:Array = this.dataList;
         var _loc4_:Array = null;
         var _loc5_:String = Settings.getInstance().getStringAttribute("exclude_seeds");
         if(_loc5_ != null && _loc5_ != "")
         {
            _loc4_ = _loc5_.split(",");
         }
         for each(_loc6_ in _loc3_)
         {
            if(_loc6_._isLock != 1)
            {
               if(_loc6_._high_price > 0)
               {
                  _loc1_ += _loc6_._high_price * _loc6_._amount;
               }
               else
               {
                  _loc1_ += _loc6_._price * _loc6_._amount;
               }
               if(_loc4_ != null && _loc4_.indexOf(_loc6_._id.toString()) != -1)
               {
                  _loc2_ += _loc6_._price * _loc6_._amount;
               }
            }
         }
         this._sum = _loc1_;
         _loc7_ = Session.getInstance().myFairy;
         if(_loc7_ != null && (_loc7_["itemId"] == Consts.FAIRY_MONEY || _loc7_["itemId"] == Consts.FAIRY_GOD))
         {
            this._sum -= _loc2_;
            this._sum *= 1 + _loc7_["rate"] / 100;
            this._sum += _loc2_;
            this._sum = Math.floor(this._sum);
            this._sumPrice.text = this._sum.toString() + (_loc7_["itemId"] == Consts.FAIRY_MONEY ? " 财神爷加成" : " 仙皇加成") + _loc7_["rate"] + "%";
         }
         else
         {
            this._sumPrice.text = this._sum.toString();
         }
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 30;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 90;
            _tile.tileHeight = 90;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = PlantRenderItem;
            _tile.y = 20;
            _tile.width = _preferedWidth - 2;
            _tile.height = 260;
         }
      }
      
      private function onSellBtnOut(param1:MouseEvent) : void
      {
         var _loc2_:WarehouseController = this.controller;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.hideTip();
      }
      
      private function onSellBtnOver(param1:MouseEvent) : void
      {
         var _loc2_:WarehouseController = this.controller;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.showTip(Consts.TIP_NAME_MOUSE,Language.L["sellSomeTip"]);
      }
      
      private function onPreviewFlower(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null || param1.data["fId"] == undefined)
         {
            return;
         }
         FlowerPlayer.play(this.controller.module.app.farmView,this.controller.model.flowerPath,param1.data["fId"]);
      }
      
      private function onSendFlowerBtn(param1:MouseEvent) : void
      {
         this.switchSendFlowerView(true);
      }
      
      private function get controller() : WarehouseController
      {
         var _loc1_:WarehouseView = this._view as WarehouseView;
         if(_loc1_ == null)
         {
            return null;
         }
         return _loc1_.controller;
      }
      
      public function switchSendFlowerView(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         if(this._isFlowerPage == false)
         {
            return;
         }
         this._sumPrice.visible = !param1;
         this._tfPrice.visible = !param1;
         this._sendFlowerBtn.visible = !param1;
         this._sellBtn.visible = !param1;
         if(_tile != null)
         {
            _tile.visible = !param1;
         }
         if(this._tfEmpty != null)
         {
            this._tfEmpty.visible = !param1;
         }
         if(this._gotoShopBtn != null)
         {
            this._gotoShopBtn.visible = !param1;
         }
         this.showAllFlowers();
         this._canvas.validateNow();
         this._sendFlowerContainer.visible = param1;
         if(param1 == true)
         {
            this._yellowTip.text = Settings.getInstance().getStringAttribute("flowerDayTips");
         }
         else
         {
            this._yellowTip.text = Language.L["warehouseDirection"];
            _loc2_ = super.dataList;
            if(_loc2_ == null || _loc2_.length == 0)
            {
               if(this._tfEmpty != null)
               {
                  this._tfEmpty.visible = true;
               }
               if(this._gotoShopBtn != null)
               {
                  this._gotoShopBtn.visible = true;
               }
            }
         }
      }
      
      private function createSendFlower() : void
      {
         if(this._sendFlowerContainer == null)
         {
            this._sendFlowerContainer = new Sprite();
            addChild(this._sendFlowerContainer);
         }
         var _loc1_:TextField = new TextField();
         _loc1_.mouseEnabled = _loc1_.selectable = false;
         _loc1_.width = 130;
         _loc1_.defaultTextFormat = new TextFormat("黑体",18,6397281,true);
         _loc1_.text = "包装花束赠送";
         _loc1_.x = 185;
         _loc1_.y = 22;
         this._sendFlowerContainer.addChild(_loc1_);
         var _loc2_:TextField = new TextField();
         _loc2_.selectable = false;
         _loc2_.defaultTextFormat = new TextFormat("Verdana",12,5145255);
         _loc2_.filters = [new GlowFilter(12451839,0.5,3,3)];
         _loc2_.width = 100;
         _loc2_.htmlText = "<a href=\"event:back\">&lt;&lt; 返回鲜花列表</a>";
         _loc2_.y = 22;
         _loc2_.x = 394;
         this._sendFlowerContainer.addChild(_loc2_);
         addEventListener(TextEvent.LINK,this.onReturnLink);
         this._canvas = new Canvas();
         this._canvas.horizontalScrollPolicy = ScrollPolicy.OFF;
         this._canvas.x = 15;
         this._canvas.y = 46;
         this._canvas.width = _preferedWidth - 25;
         this._canvas.height = 282;
         this._canvas.defaultSkin = null;
         this._sendFlowerContainer.addChild(this._canvas);
         addEventListener(FlowerRenderItem.PREVIEW,this.onPreviewFlower,false,0,true);
         addEventListener(FlowerRenderItem.NOT_ENOUGH,this.onNotEnough,false,0,true);
         addEventListener(FlowerRenderItem.SEND_FLOWER,this.onSendFlower,false,0,true);
      }
      
      private function onReturnLink(param1:TextEvent) : void
      {
         this.switchSendFlowerView(false);
      }
      
      private function onSellBtnClicked(param1:MouseEvent) : void
      {
         var _loc4_:* = undefined;
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
            this.sellAll();
         }
         if(_loc3_ != "")
         {
            _loc4_ = {
               "width":327,
               "height":270,
               "title":"温馨提示",
               "text":_loc3_,
               "confirmFn":this.sellAll
            };
            this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc4_);
         }
      }
      
      private function onGotoShop(param1:MouseEvent) : void
      {
         this.controller.module.app.closeWindowByName(Consts.WINDOW_NAME_WAREHOUSE);
         this.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_SHOP,null));
      }
      
      override protected function setData() : void
      {
         var _loc1_:Array = super.dataList;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            this.createEmptyView();
            _tile.visible = false;
            this._sellBtn.enabled = false;
            if(this._sendFlowerContainer == null || this._sendFlowerContainer.visible == false)
            {
               this._tfEmpty.visible = true;
               this._gotoShopBtn.visible = true;
            }
         }
         else
         {
            if(this._tfEmpty != null)
            {
               this._tfEmpty.visible = false;
            }
            if(this._gotoShopBtn != null)
            {
               this._gotoShopBtn.visible = false;
            }
            if(this._sendFlowerContainer == null || this._sendFlowerContainer.visible == false)
            {
               _tile.visible = true;
               this._sellBtn.enabled = true;
            }
         }
         this.sumUp();
      }
      
      public function refreshLock(param1:WarehouseCrop) : void
      {
         var _loc2_:PlantRenderItem = null;
         if(param1 == null)
         {
            return;
         }
         if(_tile == null || _tile.items == null)
         {
            return;
         }
         for each(_loc2_ in _tile.items)
         {
            if(_loc2_.data == param1)
            {
               _loc2_.refreshLock();
               this.sumUp();
               break;
            }
         }
      }
      
      private function sellAll() : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:* = undefined;
         var _loc1_:Array = this.controller.model.collectNotLockedIDs(this._warehouseType);
         if(_loc1_ != null && _loc1_.length > 0)
         {
            _loc3_ = int(QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
            _loc4_ = this._sum;
            if(_loc3_ > 5 * 3600)
            {
               _loc4_ = 0;
            }
            else if(_loc3_ > 3 * 3600)
            {
               _loc4_ = Math.ceil(_loc4_ / 2);
            }
            _loc2_ = Language.replaceText("allSellText",{"goldValue":_loc4_});
            _loc5_ = {
               "width":336,
               "height":270,
               "title":"确认",
               "text":_loc2_,
               "confirmFn":this.onOK,
               "confirmEnable":true
            };
         }
         else
         {
            _loc2_ = Language.L["allSellText2"];
            _loc5_ = {
               "width":336,
               "height":270,
               "title":"确认",
               "text":_loc2_,
               "confirmEnable":false
            };
         }
         this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc5_);
      }
      
      private function onSendFlower(param1:ViewEvent) : void
      {
         var _loc4_:Player = null;
         var _loc5_:String = null;
         var _loc6_:* = undefined;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = parseInt(Settings.getInstance().getStringAttribute("flowerYDLevel"));
         if(_loc2_ == 0)
         {
            _loc2_ = 3;
         }
         var _loc3_:int = parseInt(Settings.getInstance().getStringAttribute("flowerLevel"));
         if(_loc3_ == 0)
         {
            _loc3_ = 15;
         }
         if(_loc2_ > 0)
         {
            _loc4_ = Session.getInstance().host;
            if((_loc4_._yellowlevel < _loc2_ || _loc4_._yellowstatus == 0) && _loc4_.level < _loc3_)
            {
               _loc5_ = "<p align=\"left\"><font size=\"12\">" + Settings.getInstance().getStringAttribute("flowerDayTips") + "</font></p>";
               _loc6_ = {
                  "title":"温馨提示",
                  "type":Consts.ALERT_TYPE_TEXT,
                  "text":_loc5_
               };
               this.controller.openWindow(Consts.WINDOW_NAME_ALERT,_loc6_);
               return;
            }
         }
         this.controller.openWindow(Consts.WINDOW_NAME_SENDFLOWER,param1.data);
      }
      
      private function createEmptyView() : void
      {
         var _loc1_:TextFormat = null;
         if(this._tfEmpty == null)
         {
            this._tfEmpty = new TextField();
            this._tfEmpty.selectable = false;
            this._tfEmpty.visible = false;
            _loc1_ = new TextFormat("Verdana",16,3355443);
            _loc1_.leading = 8;
            this._tfEmpty.defaultTextFormat = _loc1_;
            this._tfEmpty.width = 350;
            this._tfEmpty.height = 76;
            this._tfEmpty.text = Language.L["仓库里空空"];
            this._tfEmpty.wordWrap = true;
            this._tfEmpty.x = (_preferedWidth - this._tfEmpty.width) / 2;
            this._tfEmpty.y = (_preferedHeight - this._tfEmpty.height) / 2;
            addChild(this._tfEmpty);
         }
         if(this._gotoShopBtn == null)
         {
            this._gotoShopBtn = new Button();
            this._gotoShopBtn.visible = false;
            this._gotoShopBtn.addEventListener(MouseEvent.CLICK,this.onGotoShop);
            this._gotoShopBtn.defaultSkin = Utils.getClass("ButtonBlue");
            this._gotoShopBtn.text = Language.L["去商店"];
            this._gotoShopBtn.x = 270;
            this._gotoShopBtn.y = 150;
            this._gotoShopBtn.width = 60;
            this._gotoShopBtn.height = 24;
            addChild(this._gotoShopBtn);
         }
      }
      
      public function showAllFlowers() : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc9_:Line = null;
         if(this._canvas != null && this._canvas.content != null)
         {
            while(this._canvas.content.numChildren > 0)
            {
               this._canvas.content.removeChildAt(0);
            }
         }
         var _loc1_:Array = [];
         var _loc2_:Array = [];
         var _loc3_:Array = this.controller.model.allFlower;
         for each(_loc4_ in _loc3_)
         {
            _loc4_["mode"] = 0;
            if(_loc4_["canMake"] == true)
            {
               _loc1_.push(_loc4_);
            }
            else
            {
               _loc2_.push(_loc4_);
            }
         }
         _loc5_ = "<b>我目前可以包装的花束</b>";
         if(_loc1_.length <= 0)
         {
            _loc5_ += "<br/><br/>鲜花不够，暂时无法包装花束哦！<br/>自己种的美丽鲜花送给好友，好友一定会很高兴，快点想想办法吧！";
         }
         var _loc6_:TextField = null;
         var _loc7_:TextFormat = new TextFormat("Verdana",12,6514536);
         _loc6_ = new TextField();
         _loc7_.leading = 4;
         _loc6_.defaultTextFormat = _loc7_;
         _loc6_.autoSize = "left";
         _loc6_.multiline = true;
         _loc6_.htmlText = _loc5_;
         _loc6_.selectable = false;
         this._canvas.content.addChild(_loc6_);
         var _loc8_:TileList = null;
         if(_loc1_.length > 0)
         {
            _loc8_ = new TileList();
            _loc8_.paddingH = 2;
            _loc8_.paddingV = 0;
            _loc8_.gapH = 12;
            _loc8_.gapV = 10;
            _loc8_.tileWidth = 94;
            _loc8_.tileHeight = 134;
            _loc8_.defaultSkin = null;
            _loc8_.horizontalScrollPolicy = ScrollPolicy.OFF;
            _loc8_.itemRenderer = FlowerRenderItem;
            _loc8_.y = _loc6_.y + _loc6_.height;
            _loc8_.width = this._canvas.width;
            _loc8_.height = Math.ceil(_loc1_.length / 4) * (134 + 10);
            this._canvas.content.addChild(_loc8_);
            _loc8_.dataProvider = _loc1_;
         }
         if(_loc2_.length > 0)
         {
            _loc9_ = new Line(450,3,3852787);
            if(_loc8_ != null)
            {
               _loc9_.y = _loc8_.y + _loc8_.height + 5;
            }
            else
            {
               _loc9_.y = _loc6_.y + _loc6_.height + 5;
            }
            this._canvas.content.addChild(_loc9_);
            _loc6_ = new TextField();
            _loc6_.defaultTextFormat = _loc7_;
            _loc6_.autoSize = "left";
            _loc6_.multiline = true;
            _loc6_.htmlText = "<b>以下花束因仓库鲜花材料不足，无法包装赠送</b>";
            _loc6_.selectable = false;
            _loc6_.y = _loc9_.y + _loc9_.height + 5;
            this._canvas.content.addChild(_loc6_);
            _loc8_ = new TileList();
            _loc8_.paddingH = 2;
            _loc8_.paddingV = 0;
            _loc8_.gapH = 10;
            _loc8_.gapV = 5;
            _loc8_.tileWidth = 94;
            _loc8_.tileHeight = 134;
            _loc8_.defaultSkin = null;
            _loc8_.horizontalScrollPolicy = ScrollPolicy.OFF;
            _loc8_.itemRenderer = FlowerRenderItem;
            _loc8_.y = _loc6_.y + _loc6_.height;
            _loc8_.width = this._canvas.width;
            _loc8_.height = Math.ceil(_loc2_.length / 4) * (5 + 134);
            this._canvas.content.addChild(_loc8_);
            _loc8_.dataProvider = _loc2_;
         }
      }
   }
}


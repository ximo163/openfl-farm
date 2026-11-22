package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.window.WindowLabelMaker;
   import entities.WarehouseFish;
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import module.uitools.widgets.profile.PropertyText;
   import module.warehouse.house.WarehouseController;
   import module.warehouse.house.WarehouseView;
   
   public class WarehouseFishPage extends BasePage
   {
      
      private var _sellBtn:Button;
      
      private var _sum:int;
      
      private var _sumPrice:PropertyText;
      
      public function WarehouseFishPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label();
         _loc4_.text = "卖成鱼";
         _loc4_.x = 2;
         _loc4_.width = param2 - 3;
         WindowLabelMaker.addTarget(_loc4_);
         addChild(_loc4_);
         this._sellBtn = new Button();
         this._sellBtn.width = 85;
         this._sellBtn.height = 25;
         this._sellBtn.defaultSkin = Utils.getClass("ButtonGreen");
         this._sellBtn.x = param2 - this._sellBtn.width - 15;
         this._sellBtn.y = param3 - this._sellBtn.height - 4;
         this._sellBtn.text = "卖出成鱼";
         this._sellBtn.addEventListener(MouseEvent.CLICK,this.onSellBtnClicked);
         addChild(this._sellBtn);
         var _loc5_:TextField = new TextField();
         _loc5_.selectable = false;
         _loc5_.defaultTextFormat = new TextFormat("Verdana",12,39423,true);
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.text = "当前成鱼总价值：";
         _loc5_.x = 15;
         _loc5_.y = param3 - _loc5_.height - 4;
         addChild(_loc5_);
         var _loc6_:Object = Session.getInstance().myFairy;
         if(_loc6_ != null && (_loc6_["itemId"] == Consts.FAIRY_MONEY || _loc6_["itemId"] == Consts.FAIRY_GOD))
         {
            this._sumPrice = new PropertyText("gold",180,false);
            this._sumPrice.x = _loc5_.width + _loc5_.x - 7;
         }
         else
         {
            this._sumPrice = new PropertyText("gold",180,true);
            this._sumPrice.x = _loc5_.width + _loc5_.x;
         }
         this._sumPrice.y = param3 - this._sumPrice.height;
         addChild(this._sumPrice);
      }
      
      private function sellAllSeeds() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Array = this.controller.model.collectNotLockedIDs(Consts.WAREHOUSE_FISH);
         var _loc2_:String = "";
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
            _loc2_ = Language.replaceText("allFishSellText",{"goldValue":_loc4_});
            this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM,{
               "width":336,
               "height":270,
               "title":"确认",
               "text":_loc2_,
               "confirmEnable":true,
               "confirmFn":this.sellAllConfirmed
            });
         }
         else
         {
            _loc2_ = Language.L["allFishSellText2"];
            this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM,{
               "width":336,
               "height":270,
               "title":"确认",
               "text":_loc2_,
               "confirmEnable":false
            });
         }
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
      
      public function refreshLock(param1:WarehouseFish) : void
      {
         var _loc2_:FishRenderItem = null;
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
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 23;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 90;
            _tile.tileHeight = 98;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = FishRenderItem;
            _tile.y = 22;
            _tile.width = _preferedWidth - 2;
            _tile.height = 260;
         }
      }
      
      override protected function setData() : void
      {
         this.sumUp();
         var _loc1_:Array = this.dataList;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            this._sellBtn.enabled = false;
         }
         else
         {
            this._sellBtn.enabled = true;
         }
      }
      
      private function sumUp() : void
      {
         var _loc3_:WarehouseFish = null;
         var _loc4_:Object = null;
         var _loc1_:Number = 0;
         var _loc2_:Array = this.dataList;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_._isLock <= 0)
            {
               _loc1_ += _loc3_._sale * _loc3_._amount;
            }
         }
         this._sum = _loc1_;
         _loc4_ = Session.getInstance().myFairy;
         if(_loc4_ != null && (_loc4_["itemId"] == Consts.FAIRY_MONEY || _loc4_["itemId"] == Consts.FAIRY_GOD))
         {
            this._sum *= 1 + _loc4_["rate"] / 100;
            this._sumPrice.text = this._sum.toString() + (_loc4_["itemId"] == Consts.FAIRY_MONEY ? "  财神爷加成" : " 仙皇加成") + _loc4_["rate"] + "%";
         }
         else
         {
            this._sumPrice.text = this._sum.toString();
         }
      }
      
      private function sellAllConfirmed() : void
      {
         this.controller.model.sellAllFish(Consts.WAREHOUSE_FISH);
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
            this.sellAllSeeds();
         }
         if(_loc3_ != "")
         {
            _loc4_ = {
               "width":327,
               "height":270,
               "title":"温馨提示",
               "text":_loc3_,
               "confirmFn":this.sellAllSeeds
            };
            this.controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc4_);
         }
      }
   }
}


package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Consts;
   import common.Language;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.window.WindowLabelMaker;
   import entities.WarehouseSeed;
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import module.uitools.widgets.profile.PropertyText;
   import module.warehouse.house.WarehouseController;
   import module.warehouse.house.WarehouseView;
   
   public class WarehouseSeedsPage extends BasePage
   {
      
      private var _sellBtn:Button;
      
      private var _sumPrice:PropertyText;
      
      public function WarehouseSeedsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label();
         _loc4_.text = "当前种子回收价低于原售价，请慎重选择";
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
         this._sellBtn.text = Language.L["sellSomeSeeds"];
         this._sellBtn.addEventListener(MouseEvent.CLICK,this.onSellBtnClicked);
         addChild(this._sellBtn);
         var _loc5_:TextField = new TextField();
         _loc5_.selectable = false;
         _loc5_.defaultTextFormat = new TextFormat("Verdana",12,39423,true);
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.text = "当前种子总价值：";
         _loc5_.x = 15;
         _loc5_.y = param3 - _loc5_.height - 4;
         addChild(_loc5_);
         this._sumPrice = new PropertyText();
         this._sumPrice.x = _loc5_.width + _loc5_.x + 10;
         this._sumPrice.y = param3 - this._sumPrice.height;
         addChild(this._sumPrice);
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
      
      private function sumUp() : void
      {
         var _loc3_:WarehouseSeed = null;
         var _loc1_:Number = 0;
         var _loc2_:Array = this.dataList;
         for each(_loc3_ in _loc2_)
         {
            _loc1_ += _loc3_._price * _loc3_._amount;
         }
         this._sumPrice.goldValue = _loc1_;
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
            _tile.itemRenderer = PlantRenderItem;
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
      
      private function sellAllConfirmed() : void
      {
         this.controller.model.sellAllSeeds();
      }
      
      private function sellAllSeeds() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc1_:Array = this.dataList;
         if(_loc1_ != null && _loc1_.length > 0)
         {
            _loc2_ = int(QzoneJSAPI.getOnlineTime(Settings.getInstance().mode));
            _loc3_ = int(this._sumPrice.goldValue);
            if(_loc2_ > 5 * 3600)
            {
               _loc3_ = 0;
            }
            else if(_loc2_ > 3 * 3600)
            {
               _loc3_ = Math.ceil(_loc3_ / 2);
            }
            _loc4_ = Language.replaceText("allSellSeedsText",{"goldValue":_loc3_});
            this.controller.openWindow(Consts.WINDOW_NAME_CONFIRM,{
               "text":_loc4_,
               "confirmEnable":true,
               "confirmFn":this.sellAllConfirmed
            });
         }
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


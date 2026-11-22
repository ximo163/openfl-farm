package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Settings;
   import common.view.window.WindowLabelMaker;
   import entities.WarehouseCrop;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import module.uitools.widgets.profile.PropertyText;
   import module.warehouse.house.WarehouseController;
   import module.warehouse.house.WarehouseView;
   
   public class CardsPage extends BasePage
   {
      
      private var _tfEmpty:TextField;
      
      private var _sumPrice:PropertyText;
      
      public function CardsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         var _loc4_:Label = null;
         super(param1,param2,param3);
         _loc4_ = new Label();
         _loc4_.text = "农场和牧场的材料统一存放在材料专区，卡片可用于兑换礼包或在加工坊加工";
         _loc4_.x = 2;
         _loc4_.width = param2 - 3;
         WindowLabelMaker.addTarget(_loc4_);
         addChild(_loc4_);
         var _loc5_:TextField = new TextField();
         _loc5_.selectable = false;
         _loc5_.defaultTextFormat = new TextFormat("Verdana",12,39423,true);
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.text = "当前材料总价值：";
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
         var _loc3_:WarehouseCrop = null;
         var _loc1_:Number = 0;
         var _loc2_:Array = this.dataList;
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_._isLock != 1)
            {
               if(_loc3_._high_price > 0)
               {
                  _loc1_ += _loc3_._high_price * _loc3_._amount;
               }
               else
               {
                  _loc1_ += _loc3_._price * _loc3_._amount;
               }
            }
         }
         this._sumPrice.goldValue = _loc1_;
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
         var _loc1_:Array = super.dataList;
         if(_loc1_ == null || _loc1_.length == 0)
         {
            this.createEmptyView();
            _tile.visible = false;
            this._tfEmpty.visible = true;
         }
         else
         {
            if(this._tfEmpty != null)
            {
               this._tfEmpty.visible = false;
            }
            _tile.visible = true;
         }
         this.sumUp();
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
            this._tfEmpty.text = Settings.getInstance().getStringAttribute("WarehouseEmpty");
            this._tfEmpty.wordWrap = true;
            this._tfEmpty.x = (_preferedWidth - this._tfEmpty.width) / 2;
            this._tfEmpty.y = (_preferedHeight - this._tfEmpty.height) / 2;
            addChild(this._tfEmpty);
         }
      }
   }
}


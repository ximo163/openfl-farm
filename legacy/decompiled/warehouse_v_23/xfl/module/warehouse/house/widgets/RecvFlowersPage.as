package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Consts;
   import common.misc.Utils;
   import events.ViewEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   import module.warehouse.house.WarehouseController;
   import module.warehouse.house.WarehouseView;
   
   public class RecvFlowersPage extends BasePage
   {
      
      private var _infoTxt:Label;
      
      private var _emptyText:TextField;
      
      public function RecvFlowersPage(param1:WarehouseView, param2:int, param3:int)
      {
         var _loc5_:Button = null;
         super(param1,param2,param3);
         this._emptyText = new TextField();
         this._emptyText.selectable = false;
         this._emptyText.visible = false;
         var _loc4_:TextFormat = new TextFormat("Verdana",16,3355443);
         _loc4_.leading = 8;
         this._emptyText.defaultTextFormat = _loc4_;
         this._emptyText.width = 230;
         this._emptyText.height = 80;
         this._emptyText.text = "当前还没有收到好友的花束哦！";
         this._emptyText.wordWrap = true;
         this._emptyText.x = (param2 - this._emptyText.width) / 2;
         this._emptyText.y = (param3 - this._emptyText.height) / 2;
         addChild(this._emptyText);
         this._infoTxt = new Label();
         this._infoTxt.y = 295;
         addChild(this._infoTxt);
         _loc5_ = new Button();
         _loc5_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc5_.cacheAsBitmap = true;
         _loc5_.text = "送给好友花束";
         _loc5_.width = 85;
         _loc5_.height = 25;
         _loc5_.x = 335;
         _loc5_.y = 295;
         addChild(_loc5_);
         _loc5_.clickFn = this.onSendFlowerBtn;
         addEventListener(FlowerRenderItem.SEND_FLOWER,this.onShowFlowerCard,false,0,true);
         addEventListener(FlowerRenderItem.PREVIEW,this.onPreviewFlower,false,0,true);
         addEventListener("preview",this.onPreviewFlower,false,0,true);
      }
      
      private function onSendFlowerBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:WarehouseView = this._view as WarehouseView;
         if(_loc2_ != null)
         {
            _loc2_.gotoSendFlower();
         }
      }
      
      private function onPreviewFlower(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null || param1.data["fId"] == undefined)
         {
            return;
         }
         FlowerPlayer.play(this.controller.module.app.farmView,this.controller.model.flowerPath,param1.data["fId"] as int);
      }
      
      private function onShowFlowerCard(param1:ViewEvent) : void
      {
         var _loc2_:Object = param1.data;
         if(_loc2_ == null)
         {
            return;
         }
         this.controller.openWindow(Consts.WINDOW_NAME_FLOWER_CARD,{
            "parent":this,
            "flower":_loc2_
         });
         FlowerPlayer.play(this.controller.module.app.farmView,this.controller.model.flowerPath,_loc2_["fId"] as int);
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.paddingH = 23;
            _tile.paddingV = 10;
            _tile.gapH = 0;
            _tile.gapV = 0;
            _tile.tileWidth = 115;
            _tile.tileHeight = 112;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
            _tile.itemRenderer = FlowerRenderItem;
            _tile.y = 2;
            _tile.width = _preferedWidth - 2;
            _tile.height = 260;
         }
      }
      
      override protected function setData() : void
      {
         if(super.dataList == null || super.dataList.length == 0)
         {
            this._emptyText.visible = true;
            this._infoTxt.text = "您是否想送给好友一份祝福呢?";
            this._infoTxt.x = 85;
         }
         else
         {
            this._emptyText.visible = false;
            this._infoTxt.text = "收到好友的花束高兴吗?您是否也想回送一份祝福呢?";
            this._infoTxt.x = 25;
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
   }
}


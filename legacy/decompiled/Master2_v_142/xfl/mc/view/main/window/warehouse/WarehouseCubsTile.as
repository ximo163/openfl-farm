package mc.view.main.window.warehouse
{
   import com.minutes.ui.collections.LipiTile2;
   import com.minutes.ui.constant.ScrollPolicy;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.head.PropertyText;
   import mc.view.main.tip.TipControl;
   
   public class WarehouseCubsTile extends Sprite
   {
      
      private var _propertyText:PropertyText;
      
      private var mainData:MainData;
      
      private var lipiTile:LipiTile2;
      
      private var _vscrollPosition:Number = 0;
      
      private var _button:LipiButton;
      
      private var emptyText:TextField;
      
      private var dataLoading:DataLoading;
      
      private var gotoButton:LipiButton;
      
      private var _tValue:TextField;
      
      public function WarehouseCubsTile()
      {
         super();
         this.mainData = MData.getInstance().mainData;
         this.lipiTile = new LipiTile2(CubItem,5,90,98,23,10);
         this.lipiTile.horizontalScrollPolicy = ScrollPolicy.OFF;
         this.lipiTile.bgAlpha = 0;
         this.lipiTile.x = 0;
         this.lipiTile.y = 18;
         this.lipiTile.width = 480;
         this.lipiTile.height = 235;
         this.lipiTile.addEventListener(ViewEvent.CHILD_OVER,this.childOver);
         this.lipiTile.addEventListener(ViewEvent.CHILD_OUT,this.childOut);
         this.lipiTile.addEventListener(ViewEvent.CHILD_CLICK,this.childClick);
         addChild(this.lipiTile);
         this.addText();
         this.addAllSellButton();
         this.addSumText();
         this.addEmptyText();
         this.addDataLoading();
      }
      
      private function allSellFn() : void
      {
         Command.getInstance().mainCommand.saleAll();
      }
      
      private function addAllSellButton() : void
      {
         this._button = new LipiButton();
         this._button.width = 100;
         this._button.height = 25;
         this._button.bgAlpha = 0;
         this._button.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
         this._button.x = width - this._button.width - 18;
         this._button.y = this.lipiTile.y + this.lipiTile.height + 7;
         this._button.label = "全部卖出/捐赠";
         this._button.textColor = 16777215;
         this._button.addEventListener(MouseEvent.CLICK,this.allSell);
         addChild(this._button);
      }
      
      private function childClick(param1:ViewEvent) : void
      {
         var _loc2_:SellCubWindow = new SellCubWindow();
         _loc2_.data = param1.data;
         WControl.open(_loc2_);
         this._vscrollPosition = this.lipiTile.vScrollPosition;
      }
      
      private function coutCropSumGoldValue() : void
      {
         var _loc1_:Array = this.mainData.userCrop;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            _loc2_ += Number(_loc1_[_loc3_]["price"]) * Number(_loc1_[_loc3_]["amount"]);
            _loc3_++;
         }
         this._propertyText.goldValue = int(_loc2_ / 2);
      }
      
      private function childOut(param1:ViewEvent) : void
      {
         TipControl.hide();
      }
      
      private function allSell(param1:MouseEvent) : void
      {
         var _loc2_:SellAllCubWin = null;
         if(this._button.enable)
         {
            _loc2_ = new SellAllCubWin();
            _loc2_.data = {"income":this._propertyText.goldValue};
            WControl.open(_loc2_);
         }
      }
      
      private function nullTextClick(param1:Event) : void
      {
         ViewControl.getInstance().dispatchEvent(new Event("closeWareHouseWindow"));
         WControl.openForName("shop");
      }
      
      private function childOver(param1:ViewEvent) : void
      {
         TipControl.show("MouseTip",param1.data["cName"]);
      }
      
      private function addDataLoading() : void
      {
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = width / 2;
         this.dataLoading.y = height / 2;
         addChild(this.dataLoading);
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc2_:Array = new Array();
         for(_loc3_ in param1)
         {
            if(param1[_loc3_].hasOwnProperty("tId"))
            {
               param1[_loc3_]["cId"] = param1[_loc3_]["tId"];
            }
            if(param1[_loc3_].hasOwnProperty("tName"))
            {
               param1[_loc3_]["cName"] = param1[_loc3_]["tName"];
            }
            if(param1[_loc3_]["type"] == 9)
            {
               _loc2_.push(param1[_loc3_]);
            }
         }
         this.userCrop(_loc2_);
         setTimeout(this.lipiTile.resetSize,200);
         _loc4_ = 0;
         if(this.lipiTile.verticalScrollBar != null)
         {
            _loc4_ = this.lipiTile.verticalScrollBar.maxScrollPosition;
         }
         this.lipiTile.vScrollPosition = this._vscrollPosition > _loc4_ ? _loc4_ : this._vscrollPosition;
      }
      
      private function whenLockStatusChange(param1:Event = null) : void
      {
         this.coutCropSumGoldValue();
      }
      
      public function get dataList() : Array
      {
         return this.lipiTile.dataList;
      }
      
      public function set errText(param1:String) : void
      {
         this.dataLoading.errorText = param1;
      }
      
      public function set loadingVisible(param1:Boolean) : void
      {
         this.dataLoading.visible = param1;
         this.lipiTile.visible = !param1;
      }
      
      private function addText() : void
      {
         var _loc1_:TextFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         var _loc2_:TextField = new TextField();
         _loc2_.backgroundColor = 16777176;
         _loc2_.background = true;
         _loc2_.width = 482;
         _loc2_.height = 18;
         _loc2_.x = 0;
         _loc2_.y = 0;
         _loc2_.selectable = false;
         addChild(_loc2_);
         _loc2_.defaultTextFormat = _loc1_;
         addChild(_loc2_);
         _loc2_.htmlText = "此处回收您物品包中不想养的幼仔，但回收价为原售价一半，请慎重。";
      }
      
      private function addSumText() : void
      {
         this._tValue = new TextField();
         this._tValue.selectable = false;
         this._tValue.defaultTextFormat = new TextFormat("Verdana",12,8999699,false);
         this._tValue.autoSize = TextFieldAutoSize.LEFT;
         this._tValue.text = "当前幼仔总回收价值";
         this._tValue.x = 20;
         this._tValue.y = this.lipiTile.y + this.lipiTile.height + 10;
         addChild(this._tValue);
         this._propertyText = new PropertyText();
         this._propertyText.x = this._tValue.width + this._tValue.x;
         this._propertyText.y = this._tValue.y - 3;
         addChild(this._propertyText);
      }
      
      private function addEmptyText() : void
      {
         this.emptyText = new TextField();
         this.emptyText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",16,8999699);
         this.emptyText.visible = false;
         _loc1_.leading = 8;
         this.emptyText.defaultTextFormat = _loc1_;
         this.emptyText.width = 350;
         this.emptyText.height = 80;
         this.emptyText.text = "仓库里空空的，连黄鼠狼都不来光顾，一分耕耘一分收获，赶紧饲养去吧！";
         this.emptyText.wordWrap = true;
         this.emptyText.x = (width - this.emptyText.width) / 2;
         this.emptyText.y = (height - this.emptyText.height) / 2;
         addChild(this.emptyText);
         this.gotoButton = new LipiButton();
         this.gotoButton.visible = false;
         this.gotoButton.addEventListener(MouseEvent.CLICK,this.nullTextClick);
         this.gotoButton.bgAlpha = 0;
         this.gotoButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         this.gotoButton.label = "去商店";
         this.gotoButton.textColor = 16777215;
         this.gotoButton.x = 270;
         this.gotoButton.y = this.emptyText.y + 26;
         this.gotoButton.width = 60;
         this.gotoButton.height = 24;
         addChild(this.gotoButton);
         MData.getInstance().mainData.addEventListener(MainData.UNLOCK_LOCK_CROP,this.whenLockStatusChange);
      }
      
      private function userCrop(param1:Array) : void
      {
         this.lipiTile.dataList = param1;
         var _loc2_:Array = param1;
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ += Number(_loc2_[_loc4_]["price"]) * Number(_loc2_[_loc4_]["amount"]);
            _loc4_++;
         }
         this._propertyText.goldValue = int(_loc3_ / 2);
         if(param1.length == 0)
         {
            this.emptyText.visible = true;
            this._button.visible = false;
            this._tValue.visible = false;
            this._propertyText.visible = false;
            this.gotoButton.visible = true;
            this.lipiTile.visible = false;
         }
         else
         {
            this.emptyText.visible = false;
            this._button.visible = true;
            this._tValue.visible = true;
            this._propertyText.visible = true;
            this.gotoButton.visible = false;
            this.lipiTile.visible = true;
         }
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
   }
}


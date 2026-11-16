package mc.view.main.window.warehouse
{
   import com.minutes.ui.collections.LipiTile2;
   import com.minutes.ui.constant.ScrollPolicy;
   import com.minutes.ui.control.LipiButton;
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
   import mc.view.common.BaseWindow;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.head.PropertyText;
   import mc.view.main.tip.TipControl;
   import mc.view.proxy.GameProxy;
   
   public class WarehouseMaterialTile extends Sprite
   {
      
      private var _propertyText:PropertyText;
      
      private var mainData:MainData;
      
      private var lipiTile:LipiTile2;
      
      private var _button:LipiButton;
      
      private var emptyText:TextField;
      
      private var _iniData:Object = GameProxy.iniData;
      
      private var dataLoading:DataLoading;
      
      private var gotoButton:LipiButton;
      
      public function WarehouseMaterialTile()
      {
         super();
         this.mainData = MData.getInstance().mainData;
         this.lipiTile = new LipiTile2(FruitItem,5,90,98,23,10);
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
      
      public function updateMaterialItemNum(param1:int, param2:int) : void
      {
         var _loc4_:FruitItem = null;
         var _loc5_:Object = null;
         var _loc3_:int = this.lipiTile.numChildren;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc4_ = this.lipiTile.getChildAt(_loc6_) as FruitItem;
            if(_loc4_.data["cId"] == param1)
            {
               _loc5_ = _loc4_.data;
               if(_loc5_["amount"] <= 0)
               {
                  Command.getInstance().mainCommand.getUserMaterial();
                  return;
               }
               _loc4_.data = _loc5_;
               break;
            }
            _loc6_++;
         }
      }
      
      private function addAllSellButton() : void
      {
      }
      
      private function childClick(param1:ViewEvent) : void
      {
         var _loc2_:BaseWindow = null;
         if(param1.data["type"] == 9)
         {
            _loc2_ = new SellCrystalWindow();
         }
         else
         {
            _loc2_ = new SellCropWindow();
         }
         _loc2_.data = param1.data;
         WControl.open(_loc2_);
      }
      
      private function childOver(param1:ViewEvent) : void
      {
         TipControl.show("MouseTip",param1.data["cName"]);
      }
      
      private function childOut(param1:ViewEvent) : void
      {
         TipControl.hide();
      }
      
      private function allSell(param1:MouseEvent) : void
      {
      }
      
      private function nullTextClick(param1:Event) : void
      {
         ViewControl.getInstance().dispatchEvent(new Event("closeWareHouseWindow"));
         WControl.openForName("shop");
      }
      
      public function set dataList(param1:Array) : void
      {
         this.userMaterial(param1);
         setTimeout(this.lipiTile.resetSize,200);
      }
      
      private function coutMaterialSumGoldValue() : void
      {
         var _loc1_:Array = this.mainData.userMaterial;
         var _loc2_:Number = 0;
         if(this._button)
         {
            this._button.enable = false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_.length)
         {
            if(!_loc1_[_loc3_]["isLock"])
            {
               if(MainData.sPrice)
               {
                  _loc2_ += Number(_loc1_[_loc3_]["sprice"] || _loc1_[_loc3_]["price"]) * Number(_loc1_[_loc3_]["amount"]);
               }
               else
               {
                  _loc2_ += Number(_loc1_[_loc3_]["price"]) * Number(_loc1_[_loc3_]["amount"]);
               }
               if(this._button)
               {
                  this._button.enable = true;
               }
            }
            _loc3_++;
         }
         if(this._propertyText)
         {
            this._propertyText.goldValue = _loc2_;
         }
      }
      
      private function userMaterial(param1:Array) : void
      {
         this.lipiTile.dataList = param1;
         var _loc2_:Array = param1;
         var _loc3_:Number = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(!_loc2_[_loc4_]["isLock"])
            {
               if(MainData.sPrice)
               {
                  _loc3_ += Number(_loc2_[_loc4_]["sprice"] || _loc2_[_loc4_]["price"]) * Number(_loc2_[_loc4_]["amount"]);
               }
               else
               {
                  _loc3_ += Number(_loc2_[_loc4_]["price"]) * Number(_loc2_[_loc4_]["amount"]);
               }
            }
            _loc4_++;
         }
         this._propertyText.goldValue = _loc3_;
         if(param1.length == 0)
         {
            this.emptyText.visible = true;
            this.lipiTile.visible = false;
         }
         else
         {
            this.emptyText.visible = false;
            this.lipiTile.visible = true;
         }
      }
      
      private function addDataLoading() : void
      {
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = width / 2;
         this.dataLoading.y = height / 2;
         addChild(this.dataLoading);
      }
      
      private function whenLockStatusChange(param1:Event = null) : void
      {
         this.coutMaterialSumGoldValue();
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
         _loc2_.htmlText = "材料专区专门储存野生动物掉落的水晶和农牧场活动卡片。";
      }
      
      private function addSumText() : void
      {
         var _loc1_:TextField = null;
         _loc1_ = new TextField();
         _loc1_.selectable = false;
         _loc1_.defaultTextFormat = new TextFormat("Verdana",12,8999699,false);
         _loc1_.autoSize = TextFieldAutoSize.LEFT;
         _loc1_.text = "当前材料总价值";
         _loc1_.x = 20;
         _loc1_.y = this.lipiTile.y + this.lipiTile.height + 10;
         addChild(_loc1_);
         this._propertyText = new PropertyText();
         this._propertyText.x = _loc1_.width + _loc1_.x;
         this._propertyText.y = _loc1_.y - 3;
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
         this.emptyText.text = "材料专区里空空的，赶紧去好友家PK野生动物获取水晶吧！";
         this.emptyText.wordWrap = true;
         this.emptyText.x = (width - this.emptyText.width) / 2;
         this.emptyText.y = (height - this.emptyText.height) / 2;
         addChild(this.emptyText);
      }
      
      private function allSellFn() : void
      {
         var _loc1_:Array = [];
         var _loc2_:Array = this.mainData.userMaterial;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(!_loc2_[_loc3_]["isLock"])
            {
               _loc1_.push(_loc2_[_loc3_]["cId"]);
            }
            _loc3_++;
         }
         Command.getInstance().mainCommand.saleAllMaterial(_loc1_);
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
   }
}


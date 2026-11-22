package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.FrameTimer;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DisplayUtil;
   import common.Consts;
   import common.Session;
   import entities.Seed;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import framework.base.BaseTileItem;
   
   public class CropItem extends BaseTileItem
   {
      
      private var _timerID:int;
      
      private var _loaded:Boolean;
      
      private var _levelLabel:Label;
      
      private var _priceText:TextField;
      
      private var _icon:Sprite;
      
      private var _noIcon:Boolean = false;
      
      public function CropItem()
      {
         super();
         this._timerID = -1;
         this._loaded = false;
         this._priceText = new TextField();
         this._priceText.selectable = false;
         this._priceText.width = 70;
         this._priceText.height = 20;
         addChild(this._priceText);
         this._priceText.x = -5;
         this._priceText.y = 60 + 2;
         this._levelLabel = new Label("");
         this.addChild(this._levelLabel);
         this._levelLabel.textDefaultFormat = new TextFormat("Verdana",12,9211020);
         this._levelLabel.textField.filters = Style.getTextGlowFilter();
         this._levelLabel.y = AlignUtil.right(60,this._levelLabel.height) + 2;
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(16711680,0);
         _loc1_.graphics.drawRect(0,0,10,1);
         _loc1_.graphics.endFill();
         _loc1_.y = 100;
         addChild(_loc1_);
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null || param1 == _item && this._loaded == true)
         {
            this.clearTimer();
            return;
         }
         super.data = param1;
         var _loc2_:Seed = _item as Seed;
         if(_loc2_ == null)
         {
            this.clearTimer();
            return;
         }
         this.clearTimer();
         this._timerID = FrameTimer.setTimeout(this.delaySetCrop,1000);
         if(_loc2_._isFood > 0)
         {
            this._icon = new ShopFoodMarkIcon();
            addChild(this._icon);
         }
         else if(_loc2_._isRestaurant == 1)
         {
            this._icon = new RestaurantMarkIcon();
            addChild(this._icon);
         }
         else if(_loc2_._isRestaurant == 2)
         {
            this._icon = new ShopSuperMarketIcon();
            addChild(this._icon);
         }
         else if(_loc2_._isActivity > 0)
         {
            this._icon = new ActivityMarkIcon();
            addChild(this._icon);
         }
         else
         {
            this._noIcon = true;
         }
         if(_loc2_._isGreen == true)
         {
            this.addGreenIcon();
            this._noIcon = false;
         }
         if(this._noIcon)
         {
            DisplayUtil.removeChild(this,this._icon);
         }
         if(_loc2_._isMill > 0)
         {
            DisplayUtil.removeChild(this,this._priceText);
         }
         else
         {
            this._priceText.htmlText = "<p align=\"center\"><font color=\"#CC3300\">金币<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><b>" + _loc2_._price + "</b><font/></p>";
         }
         var _loc3_:TextFormat = this._levelLabel.textDefaultFormat;
         var _loc4_:int = 0;
         var _loc5_:Session = Session.getInstance();
         if(_loc5_ != null && _loc5_.host != null)
         {
            _loc4_ = int(_loc5_.host.level);
         }
         if(_loc2_._lvl <= _loc4_)
         {
            _loc3_.color = 233195;
         }
         if(_loc2_._isRed == true)
         {
            _loc3_.color = 16737792;
            createBackground("ItemBgRed");
         }
         else if(_loc2_._isBlack == true)
         {
            _loc3_.color = 0;
            createBackground("ItemBgBlack");
         }
         else
         {
            createBackground("ItemBg");
         }
         this._levelLabel.textDefaultFormat = _loc3_;
         this._levelLabel.text = _loc2_._lvl.toString() + "级";
         registerListeners();
      }
      
      private function delaySetCrop() : void
      {
         if(_item == null)
         {
            return;
         }
         _material.setContent(Consts.ITEM_TYPE_SEED,_item._id);
         this._loaded = true;
      }
      
      private function addGreenIcon() : void
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(52224,1);
         _loc1_.graphics.drawRect(0,0,27,16);
         _loc1_.graphics.endFill();
         _loc1_.x = this.width - 36;
         _loc1_.y = 0;
         addChild(_loc1_);
         var _loc2_:TextField = new TextField();
         _loc2_.defaultTextFormat = new TextFormat("Verdana",12,16777215);
         _loc2_.text = "有机";
         _loc2_.selectable = false;
         _loc1_.addChild(_loc2_);
         this._icon = _loc1_;
         this._icon.mouseEnabled = false;
      }
      
      private function clearTimer() : void
      {
         if(this._timerID > 0)
         {
            FrameTimer.clearTimeout(this._timerID);
         }
         this._timerID = -1;
      }
   }
}


package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.FrameTimer;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.Settings;
   import common.misc.Utils;
   import entities.WarehouseCrop;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class PlantRenderItem extends BaseTileItem
   {
      
      public static const LOCK_ICON_CLICKED:String = "LockIconClicked";
      
      private var _setCropTime:int;
      
      private var _lockIcon:MovieClip;
      
      private var _amountText:TextField;
      
      private var _levelLabel:Label;
      
      private var _vipIcon:MovieClip;
      
      public function PlantRenderItem()
      {
         super();
         createBackground("ItemBg");
         this._amountText = new TextField();
         this._amountText.defaultTextFormat = new TextFormat("embedFontA",14,39423,true,null,null,null,null,TextFormatAlign.CENTER);
         this._amountText.embedFonts = true;
         this._amountText.selectable = false;
         this._amountText.mouseEnabled = false;
         this._amountText.width = _bg.width;
         this._amountText.height = 23;
         this._amountText.x = 0;
         this._amountText.y = _bg.height;
         this._amountText.text = "20";
         addChild(this._amountText);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(0,0);
         _loc1_.graphics.drawRect(0,0,10,1);
         _loc1_.graphics.endFill();
         _loc1_.y = 90;
         addChild(_loc1_);
         this._lockIcon = Utils.getMaterial("SellLockIcon") as MovieClip;
         if(this._lockIcon != null)
         {
            this.mouseChildren = true;
            this._lockIcon.addEventListener(MouseEvent.CLICK,this.onLockClicked,false,0,true);
            addChild(this._lockIcon);
         }
         this._levelLabel = new Label("");
         addChild(this._levelLabel);
         this._levelLabel.textField.defaultTextFormat = new TextFormat("Verdana",12,233195);
         this._levelLabel.textField.filters = Style.getTextGlowFilter();
         this._levelLabel.x = 1;
         this._levelLabel.y = AlignUtil.right(_bg.height,this._levelLabel.height) + 1;
         this._setCropTime = -1;
         this._vipIcon = Utils.getMaterial("VipSeedIcon") as MovieClip;
         this._vipIcon.x = 1;
         this._vipIcon.y = 1;
         this._vipIcon.scaleX = 0.6;
         this._vipIcon.scaleY = 0.6;
      }
      
      private function onTimeout() : void
      {
         var _loc1_:WarehouseCrop = null;
         this.stopFrameTimer();
         if(_item != null && _item._id != undefined)
         {
            if(_item is WarehouseCrop)
            {
               _loc1_ = _item as WarehouseCrop;
               if(_loc1_._type.toString() == Consts.ITEM_TYPE_CARD)
               {
                  _material.setContent(Consts.ITEM_TYPE_CARD,_item._id);
                  _material.scaleX = _material.scaleY = 0.51;
                  _material.x = 15;
                  _material.y = 15;
               }
               else if(_loc1_._type.toString() == Consts.ITEM_TYPE_CRYSTAL)
               {
                  _material.setContent(Consts.ITEM_TYPE_CRYSTAL,_item._id);
               }
               else
               {
                  _material.setContent(Consts.ITEM_TYPE_SEED,_item._id);
               }
               return;
            }
            _material.setContent(Consts.ITEM_TYPE_SEED,_item._id);
         }
      }
      
      public function refreshLock() : void
      {
         if(this._lockIcon == null || _item == null)
         {
            return;
         }
         if(_item._isLock > 0)
         {
            this._lockIcon.gotoAndStop("lock");
         }
         else
         {
            this._lockIcon.gotoAndStop("unlock");
         }
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1 == null || param1 == super._item)
         {
            this.stopFrameTimer();
            return;
         }
         super.data = param1;
         this.stopFrameTimer();
         if(param1._id != undefined)
         {
            _loc2_ = Settings.getInstance().getStringAttribute("setIconDelay");
            _loc3_ = 1000;
            if(_loc2_ != "")
            {
               _loc3_ = parseInt(_loc2_);
            }
            this._setCropTime = FrameTimer.setTimeout(this.onTimeout,_loc3_);
         }
         if(this._amountText != null && param1.hasOwnProperty("_amount") == true)
         {
            this._amountText.text = param1._amount.toString();
         }
         else
         {
            this._amountText.text = "0";
         }
         if(this._lockIcon != null && param1.hasOwnProperty("_isLock") == true)
         {
            this._lockIcon.gotoAndStop(param1._isLock > 0 ? "lock" : "unlock");
         }
         else
         {
            this._lockIcon.gotoAndStop("unlock");
         }
         if(this._levelLabel != null && param1.hasOwnProperty("_lvl") == true && param1._type.toString() != Consts.ITEM_TYPE_CARD)
         {
            this._levelLabel.text = param1._lvl + "级";
         }
         else if(param1._type.toString() != Consts.ITEM_TYPE_CARD)
         {
            this._levelLabel.text = "0级";
         }
         else
         {
            this._levelLabel.text = "";
         }
         if(param1._isVip == 1)
         {
            addChild(this._vipIcon);
         }
         registerListeners();
      }
      
      private function stopFrameTimer() : void
      {
         if(this._setCropTime != -1)
         {
            FrameTimer.clearTimeout(this._setCropTime);
         }
         this._setCropTime = -1;
      }
      
      private function onLockClicked(param1:MouseEvent) : void
      {
         if(this._lockIcon == null)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(this._lockIcon.currentLabel == "lock")
         {
            _loc2_ = false;
         }
         else if(this._lockIcon.currentLabel == "unlock")
         {
            _loc2_ = true;
         }
         dispatchEvent(new CommonEvent(LOCK_ICON_CLICKED,{
            "item":super._item,
            "lock":_loc2_
         }));
         param1.stopImmediatePropagation();
      }
   }
}


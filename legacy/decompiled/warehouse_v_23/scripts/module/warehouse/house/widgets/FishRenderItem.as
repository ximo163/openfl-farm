package module.warehouse.house.widgets
{
   import com.qzone.qui.utils.FrameTimer;
   import common.Consts;
   import common.Settings;
   import common.misc.Utils;
   import entities.WarehouseFish;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class FishRenderItem extends BaseTileItem
   {
      
      public static const LOCK_ICON_CLICKED:String = "LockIconClicked";
      
      private var _lockIcon:MovieClip;
      
      private var _amountText:TextField;
      
      private var _setCropTime:int;
      
      public function FishRenderItem()
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
         this._setCropTime = -1;
      }
      
      private function stopFrameTimer() : void
      {
         if(this._setCropTime != -1)
         {
            FrameTimer.clearTimeout(this._setCropTime);
         }
         this._setCropTime = -1;
      }
      
      private function onTimeout() : void
      {
         var _loc1_:WarehouseFish = null;
         this.stopFrameTimer();
         if(_item != null && _item._id != undefined)
         {
            _loc1_ = _item as WarehouseFish;
            _material.setContent(Consts.ITEM_TYPE_FISH,_item._id);
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
         registerListeners();
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
   }
}


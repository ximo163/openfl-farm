package module.shop.widgets
{
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.FrameTimer;
   import common.Consts;
   import common.misc.Utils;
   import entities.ShopFish;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import framework.base.BaseTileItem;
   
   public class FishItem extends BaseTileItem
   {
      
      private var _timerID:int;
      
      private var _lockIcon:MovieClip;
      
      private var _loaded:Boolean;
      
      private var _nameText:TextField;
      
      public function FishItem()
      {
         super();
         this._timerID = -1;
         this._loaded = false;
         this._nameText = new TextField();
         this._nameText.selectable = false;
         this._nameText.width = 70;
         this._nameText.height = 20;
         addChild(this._nameText);
         this._nameText.x = -5;
         this._nameText.y = 60 + 2;
         createBackground("ItemBg");
      }
      
      private function delaySetCrop() : void
      {
         if(_item == null)
         {
            return;
         }
         _material.setContent(Consts.ITEM_TYPE_FISH,_item._id);
         this._loaded = true;
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null || param1 == _item && this._loaded == true)
         {
            this.clearTimer();
            return;
         }
         super.data = param1;
         var _loc2_:ShopFish = _item as ShopFish;
         if(_loc2_ == null)
         {
            this.clearTimer();
            return;
         }
         this.clearTimer();
         this._timerID = FrameTimer.setTimeout(this.delaySetCrop,1000);
         switch(_loc2_._lock)
         {
            case 0:
               _material.filters = Style.getDisableFilter();
               this._lockIcon = Utils.getMaterial("FishLocked") as MovieClip;
               if(this._lockIcon != null)
               {
                  addChild(this._lockIcon);
               }
               break;
            case 1:
               _material.filters = null;
               break;
            case 2:
               _material.filters = Style.getDisableFilter();
               this._lockIcon = Utils.getMaterial("FishUnlock") as MovieClip;
               if(this._lockIcon != null)
               {
                  addChild(this._lockIcon);
               }
         }
         this._nameText.htmlText = "<p align=\"center\"><font color=\"#FF6600\"><b>" + _loc2_._name + "</b><font/></p>";
         registerListeners();
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


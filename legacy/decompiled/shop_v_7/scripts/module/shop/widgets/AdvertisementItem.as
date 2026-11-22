package module.shop.widgets
{
   import com.qzone.corelib.controls.ExtLoader;
   import com.qzone.qui.controls.Button;
   import common.misc.Utils;
   import entities.AdItem;
   import flash.text.TextField;
   import framework.base.BaseTileItem;
   
   public class AdvertisementItem extends BaseTileItem
   {
      
      private var _priceText:TextField;
      
      private var _gotoBtn:Button;
      
      public function AdvertisementItem()
      {
         super();
         createBackground("ItemBg",147,140);
         super._material.x = (super._bg.width - super._material.width) / 2;
         super._material.y = 90 - super._material.height;
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:AdItem = null;
         if(param1 == null || param1 == super._item)
         {
            return;
         }
         super.data = param1;
         _loc2_ = new AdItem(super._item);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:ExtLoader = new ExtLoader();
         _loc3_.y = 3;
         _loc3_.x = 3.5;
         var _loc4_:String = _loc2_._img;
         _loc3_.load(_loc4_);
         addChild(_loc3_);
         this._gotoBtn = new Button();
         this._gotoBtn.defaultSkin = Utils.getClass("ButtonOrange");
         this._gotoBtn.width = 54;
         this._gotoBtn.height = 25;
         this._gotoBtn.x = (super._bg.width - this._gotoBtn.width) / 2;
         this._gotoBtn.y = 102;
         this._gotoBtn.text = "现在去";
         addChild(this._gotoBtn);
         registerListeners();
      }
   }
}


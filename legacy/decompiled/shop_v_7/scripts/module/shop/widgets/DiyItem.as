package module.shop.widgets
{
   import entities.DIYDecor;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import framework.base.BaseTileItem;
   
   public class DiyItem extends BaseTileItem
   {
      
      private var _divMask:Sprite;
      
      private var _newMarkIcon:MovieClip;
      
      private var _priceText:TextField;
      
      private var _fbText:TextField;
      
      public function DiyItem()
      {
         super();
         createBackground("ItemBorder");
         this._priceText = new TextField();
         this._priceText.selectable = false;
         this._priceText.width = this.width + 19;
         this._priceText.height = 65;
         this._priceText.multiline = true;
         this._priceText.y = 60;
         addChild(this._priceText);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc3_:String = null;
         if(param1 == null || param1 == _item)
         {
            return;
         }
         super.data = param1;
         var _loc2_:DIYDecor = _item as DIYDecor;
         if(_loc2_ == null)
         {
            return;
         }
         super._material.setContent("2",_loc2_._id,true);
         _loc3_ = "";
         if(_loc2_._price > 0)
         {
            _loc3_ += "<p align=\"left\"><font face=\"Verdana\" color=\"#CC3300\">金币<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><b>" + _loc2_._price + "</b><font/></p>";
         }
         if(_loc2_._fb != 0)
         {
            _loc3_ += "<textformat indent=\"2\"><p align=\"left\"><font face=\"Verdana\" color=\"#003366\">元宝<font/> <font color=\"#0099FF\" face=\"Verdana\" size=\"11\"><b>" + _loc2_._fb + "</b><font/></p></textformat>";
            _loc3_ += "<p align=\"left\">(<font face=\"Verdana\">VIP价</font> <font size=\"11\" color=\"#FF6600\" face=\"Verdana\"><b>" + _loc2_._yfb + "</b></font>)</p>";
         }
         if(_loc2_._alreadyOwn == true)
         {
            _loc3_ += "<p align=\"left\"><font face=\"Verdana\" color=\"#CC3300\">已购买<font/> <font color=\"#FF6600\" face=\"Verdana\" size=\"11\"><font/></p>";
         }
         this._priceText.htmlText = _loc3_;
         createMask("ItemBorder",60,60);
         if(_mask != null)
         {
            _mask.x = 1;
            _mask.y = 1;
         }
         registerListeners();
      }
   }
}


package module.uitools.widgets.profile
{
   import com.qzone.utils.StringUtil;
   import common.misc.Utils;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class NameText extends Sprite
   {
      
      private var _textField:TextField;
      
      private var _vipBitmap:Bitmap;
      
      private var _vipDiamond:Sprite;
      
      private var _vip:String;
      
      public function NameText()
      {
         super();
         this._vip = "";
         this._textField = null;
         this._vipBitmap = null;
         this._vipDiamond = null;
      }
      
      private function setVipPosition() : void
      {
         if(this._vipBitmap != null && this._textField != null)
         {
            this._vipBitmap.x = this._textField.width + 5;
            this._vipBitmap.y = 3;
         }
      }
      
      public function set vip(param1:String) : void
      {
         var _loc2_:BitmapData = null;
         if(param1 == "" || param1 == null)
         {
            if(this._vipBitmap != null)
            {
               this._vipDiamond.removeChild(this._vipBitmap);
               this._vipBitmap = null;
            }
         }
         else if(param1 != this._vip)
         {
            if(this._vipBitmap != null)
            {
               this._vipDiamond.removeChild(this._vipBitmap);
               this._vipBitmap = null;
            }
            this._vipDiamond = new Sprite();
            this._vipDiamond.name = "__vip__";
            this._vipDiamond.buttonMode = true;
            _loc2_ = Utils.getCachedBitmapData(param1,16,13);
            this._vipBitmap = new Bitmap(_loc2_);
            this._vipDiamond.addChild(this._vipBitmap);
            addChild(this._vipDiamond);
            this.setVipPosition();
         }
         else if(this._vipBitmap != null)
         {
            this.setVipPosition();
         }
         this._vip = param1;
      }
      
      public function get text() : String
      {
         if(this._textField == null)
         {
            return "";
         }
         return this._textField.text;
      }
      
      public function set text(param1:String) : void
      {
         if(this._textField == null)
         {
            this._textField = new TextField();
            this._textField.filters = Utils.textGlowFilter;
            this._textField.selectable = false;
            this._textField.multiline = false;
            this._textField.autoSize = TextFieldAutoSize.LEFT;
            this._textField.defaultTextFormat = new TextFormat("Verdana",12,3355443);
            addChild(this._textField);
         }
         this._textField.htmlText = StringUtil.htmlEscape(param1);
         this.setVipPosition();
      }
      
      public function get vip() : String
      {
         return this._vip;
      }
   }
}


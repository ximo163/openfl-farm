package mc.view.main.head
{
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.common.MoneyIcon;
   
   public class PropertyText extends Sprite
   {
      
      private var _goldText:TextField;
      
      public function PropertyText(param1:String = "gold")
      {
         super();
         var _loc2_:MoneyIcon = new MoneyIcon(param1);
         _loc2_.y = 4;
         addChild(_loc2_);
         var _loc3_:uint = 16737792;
         if(param1 == "rp")
         {
            _loc3_ = 4160774;
         }
         this._goldText = new TextField();
         this._goldText.selectable = false;
         this._goldText.height = 25;
         this._goldText.defaultTextFormat = new TextFormat("embedFontA",14,_loc3_,true,null,null,null,null,TextFormatAlign.LEFT);
         this._goldText.embedFonts = true;
         this._goldText.x = 40;
         this._goldText.y = 0;
         this._goldText.text = "0";
         this._goldText.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._goldText);
         this._goldText.x = 30;
         this._goldText.y = 2;
      }
      
      public function get goldValue() : Number
      {
         return Number(this._goldText.text);
      }
      
      public function set goldValue(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._goldText.text = param1.toString();
      }
   }
}


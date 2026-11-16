package module.uitools.widgets.profile
{
   import common.misc.Utils;
   import common.view.MoneyIcon;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class PropertyText extends Sprite
   {
      
      private var _goldText:TextField;
      
      public function PropertyText(param1:String = "gold", param2:int = 80, param3:Boolean = true)
      {
         super();
         var _loc4_:MoneyIcon = new MoneyIcon(param1);
         _loc4_.y = 4;
         _loc4_.filters = Utils.textGlowFilter;
         addChild(_loc4_);
         var _loc5_:uint = 16737792;
         if(param1 == "rp")
         {
            _loc5_ = 4160774;
         }
         this._goldText = new TextField();
         this._goldText.selectable = false;
         this._goldText.width = param2;
         this._goldText.height = 25;
         if(param3 == true)
         {
            this._goldText.defaultTextFormat = new TextFormat("embedFontA",14,_loc5_,null,null,null,null,null,TextFormatAlign.LEFT);
            this._goldText.embedFonts = true;
         }
         else
         {
            this._goldText.defaultTextFormat = new TextFormat("",14,_loc5_,null,null,null,null,null,TextFormatAlign.LEFT);
            this._goldText.embedFonts = false;
         }
         this._goldText.filters = Utils.textGlowFilter;
         this._goldText.x = 40;
         this._goldText.y = 2;
         this._goldText.text = "0";
         addChild(this._goldText);
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
      
      public function set text(param1:String) : void
      {
         this._goldText.htmlText = param1;
      }
   }
}


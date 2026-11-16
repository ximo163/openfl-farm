package module.uitools.widgets.profile
{
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class Level extends Sprite
   {
      
      public static const BLUE:String = "blue";
      
      public static const YELLOW:String = "yellow";
      
      private var _color:String = "blue";
      
      private var _level:int = 0;
      
      private var _levelTextField:TextField;
      
      private var _yellowBg:Sprite;
      
      private var _blueBg:Sprite;
      
      public function Level(param1:String = "")
      {
         super();
         this._levelTextField = new TextField();
         this._levelTextField.selectable = false;
         this._levelTextField.mouseEnabled = false;
         this._levelTextField.width = 40;
         this._levelTextField.height = 30;
         this._levelTextField.defaultTextFormat = new TextFormat("embedFontA",18,39423,null,null,null,null,null,TextFormatAlign.CENTER);
         this._levelTextField.embedFonts = true;
         this._levelTextField.text = "0";
         addChild(this._levelTextField);
         if(param1 != "")
         {
            this.color = param1;
         }
      }
      
      public function set level(param1:int) : void
      {
         this._level = param1;
         this._levelTextField.text = String(param1);
      }
      
      public function get color() : String
      {
         return this._color;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
         this.addBg();
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      private function addBg() : void
      {
         if(this.color == BLUE)
         {
            if(this._yellowBg != null)
            {
               removeChild(this._yellowBg);
               this._yellowBg = null;
            }
            if(this._blueBg == null)
            {
               this._blueBg = Utils.getMaterial("LevelBlue") as Sprite;
               this._blueBg.mouseEnabled = false;
               this._blueBg.scaleX = this._blueBg.scaleY = 1.3;
               this._blueBg.x = 1;
               this._blueBg.y = -9;
            }
            addChildAt(this._blueBg,0);
            this._levelTextField.textColor = 39423;
         }
         else
         {
            if(this._blueBg != null)
            {
               removeChild(this._blueBg);
               this._blueBg = null;
            }
            if(this._yellowBg == null)
            {
               this._yellowBg = Utils.getMaterial("LevelYellow") as Sprite;
               this._yellowBg.mouseEnabled = false;
               this._yellowBg.scaleX = this._yellowBg.scaleY = 1.3;
               this._yellowBg.x = 1;
               this._yellowBg.y = -9;
            }
            addChildAt(this._yellowBg,0);
            this._levelTextField.textColor = 13408512;
         }
      }
   }
}


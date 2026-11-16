package mc.view.main.head
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class Level extends Sprite
   {
      
      public static const YELLOW:String = "yellow";
      
      public static const BLUE:String = "blue";
      
      private var _bg:Sprite;
      
      private var lib:MaterialLib;
      
      private var levelTextField:TextField;
      
      private var _level:int = 0;
      
      private var _color:String = "blue";
      
      public function Level(param1:String = "")
      {
         super();
         this.lib = MaterialLib.getInstance();
         if(param1 != "")
         {
            this.color = param1;
         }
      }
      
      public function get color() : String
      {
         return this._color;
      }
      
      private function addBg() : void
      {
         if(this._bg != null)
         {
            removeChild(this._bg);
            this._bg = null;
         }
         if(this._bg == null)
         {
            this._bg = this.lib.getMaterial("LevelBlue") as Sprite;
         }
         addChildAt(this._bg,0);
         this.levelTextField = this._bg.getChildByName("level_txt") as TextField;
         this.levelTextField.defaultTextFormat = new TextFormat("embedFontA");
         this.levelTextField.embedFonts = true;
         this.levelTextField.text = String(this._level);
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
         this.addBg();
      }
      
      public function set level(param1:int) : void
      {
         this._level = param1;
         if(this.levelTextField)
         {
            this.levelTextField.text = String(param1);
         }
      }
   }
}


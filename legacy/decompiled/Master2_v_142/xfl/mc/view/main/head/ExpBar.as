package mc.view.main.head
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ExpBar extends Sprite
   {
      
      public static const YELLOW:String = "yellow";
      
      public static const BLUE:String = "blue";
      
      private var lib:MaterialLib;
      
      private var _percent:int = 0;
      
      private var blueBar:Sprite;
      
      private var _exp:int = 0;
      
      private var yellowBarBg:Sprite;
      
      private var _nextExp:int;
      
      private var expText:TextField;
      
      private var _color:String = "blue";
      
      private var blueBarBg:Sprite;
      
      private var yellowBar:Sprite;
      
      public function ExpBar(param1:String = "")
      {
         super();
         this.lib = MaterialLib.getInstance();
         if(param1 != "")
         {
            this.color = param1;
         }
      }
      
      public function set percent(param1:int) : void
      {
         this._percent = param1;
         this.setPC();
      }
      
      private function setPC() : void
      {
         if(this.yellowBar != null)
         {
            this.yellowBar.width = 112 * (this.percent * 0.01);
         }
         else if(this.blueBar != null)
         {
            this.blueBar.width = 112 * (this.percent * 0.01);
         }
      }
      
      public function set nextExp(param1:int) : void
      {
         this._nextExp = param1;
         this.expText.text = this.nextExp + " / " + this.exp;
      }
      
      public function get exp() : int
      {
         return this._exp;
      }
      
      public function get color() : String
      {
         return this._color;
      }
      
      public function get percent() : int
      {
         return this._percent;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
         this.addBar();
         this.setPC();
      }
      
      public function get nextExp() : int
      {
         return this._nextExp;
      }
      
      private function addBar() : void
      {
         if(true || this.color == BLUE)
         {
            if(this.yellowBarBg != null)
            {
               removeChild(this.yellowBarBg);
               this.yellowBarBg = null;
            }
            if(this.yellowBar != null)
            {
               removeChild(this.yellowBar);
               this.yellowBar = null;
            }
            if(this.blueBarBg == null)
            {
               this.blueBarBg = this.lib.getMaterial("ExpBlueBg") as Sprite;
            }
            addChild(this.blueBarBg);
            if(this.blueBar == null)
            {
               this.blueBar = this.lib.getMaterial("ExpBlue") as Sprite;
            }
            this.blueBar.x = 2;
            this.blueBar.y = 2;
            addChild(this.blueBar);
         }
         else
         {
            if(this.blueBarBg != null)
            {
               removeChild(this.blueBarBg);
               this.blueBarBg = null;
            }
            if(this.blueBar != null)
            {
               removeChild(this.blueBar);
               this.blueBar = null;
            }
            if(this.yellowBarBg == null)
            {
               this.yellowBarBg = this.lib.getMaterial("ExpYellowBg") as Sprite;
            }
            addChild(this.yellowBarBg);
            if(this.yellowBar == null)
            {
               this.yellowBar = this.lib.getMaterial("ExpYellow") as Sprite;
            }
            this.yellowBar.x = 2;
            this.yellowBar.y = 2;
            addChild(this.yellowBar);
         }
         this.expText = new TextField();
         this.expText.selectable = false;
         this.expText.mouseEnabled = false;
         this.expText.defaultTextFormat = new TextFormat("Verdana",10,null,null,null,null,null,null,TextFormatAlign.CENTER);
         this.expText.y = -3;
         this.expText.width = 120;
         this.expText.height = 18;
         this.expText.text = this.nextExp + " / " + this.exp;
         addChild(this.expText);
      }
      
      public function set exp(param1:int) : void
      {
         this._exp = param1;
         this.expText.text = this.nextExp + " / " + this.exp;
      }
   }
}


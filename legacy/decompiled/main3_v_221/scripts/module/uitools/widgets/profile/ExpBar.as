package module.uitools.widgets.profile
{
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class ExpBar extends Sprite
   {
      
      public static const BLUE:String = "blue";
      
      public static const YELLOW:String = "yellow";
      
      private var _yellowBar:Sprite;
      
      private var _percent:int;
      
      private var _blueBar:Sprite;
      
      private var _exp:int;
      
      private var _color:String;
      
      private var _nextExp:int;
      
      private var _yellowBarBg:Sprite;
      
      private var _expText:TextField;
      
      private var _blueBarBg:Sprite;
      
      public function ExpBar(param1:String = "")
      {
         super();
         this._exp = 0;
         this._nextExp = 0;
         this._percent = 0;
         if(param1 != "")
         {
            this.color = param1;
         }
         else
         {
            this.color = BLUE;
         }
      }
      
      private function createView() : void
      {
         if(this.color == BLUE)
         {
            if(this._yellowBarBg != null)
            {
               removeChild(this._yellowBarBg);
               this._yellowBarBg = null;
            }
            if(this._yellowBar != null)
            {
               removeChild(this._yellowBar);
               this._yellowBar = null;
            }
            if(this._blueBarBg == null)
            {
               this._blueBarBg = Utils.getMaterial("ExpBlueBg") as Sprite;
               this._blueBarBg.mouseEnabled = false;
            }
            addChild(this._blueBarBg);
            if(this._blueBar == null)
            {
               this._blueBar = Utils.getMaterial("ExpBlue") as Sprite;
               this._blueBar.mouseEnabled = false;
            }
            this._blueBar.x = 1;
            addChild(this._blueBar);
         }
         else
         {
            if(this._blueBarBg != null)
            {
               removeChild(this._blueBarBg);
               this._blueBarBg = null;
            }
            if(this._blueBar != null)
            {
               removeChild(this._blueBar);
               this._blueBar = null;
            }
            if(this._yellowBarBg == null)
            {
               this._yellowBarBg = Utils.getMaterial("ExpYellowBg") as Sprite;
               this._yellowBarBg.mouseEnabled = false;
            }
            addChild(this._yellowBarBg);
            if(this._yellowBar == null)
            {
               this._yellowBar = Utils.getMaterial("ExpYellow") as Sprite;
               this._yellowBar.mouseEnabled = false;
            }
            this._yellowBar.x = 1;
            addChild(this._yellowBar);
         }
         this._expText = new TextField();
         this._expText.selectable = false;
         this._expText.mouseEnabled = false;
         this._expText.defaultTextFormat = new TextFormat("Verdana",10,null,null,null,null,null,null,TextFormatAlign.CENTER);
         this._expText.y = -3;
         this._expText.width = 120;
         this._expText.height = 18;
         this._expText.text = this.nextExp + " / " + this.exp;
         addChild(this._expText);
      }
      
      public function set color(param1:String) : void
      {
         if(this._color == param1)
         {
            return;
         }
         this._color = param1;
         this.createView();
         this.drawPercentage();
      }
      
      public function set percent(param1:int) : void
      {
         this._percent = param1;
         this.drawPercentage();
      }
      
      public function set nextExp(param1:int) : void
      {
         this._nextExp = param1;
         this._expText.text = this.nextExp + " / " + this.exp;
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
      
      public function get nextExp() : int
      {
         return this._nextExp;
      }
      
      public function set exp(param1:int) : void
      {
         this._exp = param1;
         this._expText.text = this.nextExp + " / " + this.exp;
      }
      
      private function drawPercentage() : void
      {
         if(this._yellowBar != null)
         {
            this._yellowBar.width = 119 * (this.percent * 0.01);
         }
         else if(this._blueBar != null)
         {
            this._blueBar.width = 119 * (this.percent * 0.01);
         }
      }
   }
}


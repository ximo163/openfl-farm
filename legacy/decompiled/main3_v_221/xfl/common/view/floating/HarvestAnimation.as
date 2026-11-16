package common.view.floating
{
   import common.Consts;
   import common.view.MaterialProxy;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class HarvestAnimation extends FloatingBase
   {
      
      private var _materialProxy:MaterialProxy;
      
      private const easingY:Number = 0.2;
      
      private var _numText:TextField;
      
      private var _currentValue:Number;
      
      public function HarvestAnimation(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_HA;
         this._materialProxy = new MaterialProxy();
         addChild(this._materialProxy);
         this._numText = new TextField();
         this._numText.defaultTextFormat = new TextFormat("Verdana",16,16737792,true);
         this._numText.filters = [new GlowFilter(16777215,1,3,3,7)];
         this._numText.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._numText);
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         if(param1 != null && param1["text"] != "")
         {
            this.text = param1["text"];
            if(param1["type"] != undefined)
            {
               this.setContent(param1["type"],param1["cId"]);
            }
            else
            {
               this.setContent("1",param1["cId"]);
            }
         }
         this.addEventListener(Event.ENTER_FRAME,this.onTimer);
         this._currentValue = 59;
      }
      
      private function onTimer(param1:Event) : void
      {
         this._currentValue -= (60 - this._currentValue) * this.easingY;
         this.y -= 60 - this._currentValue;
         if(this._currentValue < 0)
         {
            this.removeEventListener(Event.ENTER_FRAME,this.onTimer);
            super.close();
         }
      }
      
      public function setContent(param1:String, param2:int) : void
      {
         if(param1 == "")
         {
            return;
         }
         this._materialProxy.setContent(param1,param2);
         this.cacheAsBitmap = true;
      }
      
      public function set text(param1:String) : void
      {
         if(param1.charAt(0) != "-" && param1.charAt(0) != "+" && isNaN(parseFloat(param1)) == false)
         {
            param1 = "+ " + param1;
         }
         this._numText.text = param1;
         this._numText.x = 65;
         this._numText.y = (60 - this._numText.height) / 2;
      }
      
      override public function end() : void
      {
         super.end();
         this.removeEventListener(Event.ENTER_FRAME,this.onTimer);
         this._materialProxy = null;
         this._numText = null;
      }
   }
}


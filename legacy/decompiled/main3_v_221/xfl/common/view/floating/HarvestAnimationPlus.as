package common.view.floating
{
   import common.Consts;
   import common.Session;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class HarvestAnimationPlus extends FloatingBase
   {
      
      private var _isEven:Boolean;
      
      private var _materialProxy:MaterialProxy;
      
      private var _lock:Boolean;
      
      private const easingY:Number = 0.2;
      
      private var _currentValue:Number;
      
      private var _numText1:TextField;
      
      private var _numText2:TextField;
      
      private var _numText:TextField;
      
      private var _materialProxy1:MaterialProxy;
      
      private var _mc:Sprite;
      
      public function HarvestAnimationPlus(param1:IMsgCenter)
      {
         var _loc2_:String = null;
         var _loc3_:Sprite = null;
         var _loc4_:Array = null;
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_HAP;
         this._lock = true;
         this._isEven = false;
         this._materialProxy = new MaterialProxy();
         addChild(this._materialProxy);
         if(Session.getInstance().me == true)
         {
            _loc2_ = "HarvestPlusB";
            _loc3_ = Utils.getMaterial(_loc2_) as Sprite;
            if(_loc3_ != null)
            {
               this._mc = _loc3_;
               this._numText = _loc3_["txt"] as TextField;
               addChild(_loc3_);
            }
         }
         else
         {
            this._numText1 = new TextField();
            this._numText2 = new TextField();
            _loc4_ = [new GlowFilter(16777215,1,3,3,7)];
            this._numText1.defaultTextFormat = new TextFormat("Times New Roman",28,16737792,true);
            this._numText1.filters = _loc4_;
            this._numText1.autoSize = TextFieldAutoSize.LEFT;
            addChild(this._numText1);
            this._numText2.defaultTextFormat = new TextFormat("Times New Roman",28,16737792,true);
            this._numText2.filters = _loc4_;
            this._numText2.autoSize = TextFieldAutoSize.LEFT;
            this._materialProxy1 = new MaterialProxy();
         }
      }
      
      public function set text(param1:String) : void
      {
         var _loc2_:int = 0;
         if(Session.getInstance().me == true)
         {
            if(this._numText != null)
            {
               this._numText.text = param1;
            }
            if(this._mc != null)
            {
               this._mc.x = 60;
               this._mc.y = (60 - this._numText.height) / 2;
            }
         }
         else
         {
            _loc2_ = parseInt(param1);
            this._numText1.text = param1;
            this._numText1.x = 60;
            this._numText1.y = (60 - this._numText1.height) / 2;
            if(_loc2_ % 2 == 0)
            {
               this._materialProxy1.y = this._numText1.y + this._numText1.height;
               this._numText2.x = 60;
               this._numText2.y = this._materialProxy1.y + 10;
               _loc2_ /= 2;
               this._numText1.text = "+" + _loc2_.toString();
               this._numText2.text = "+" + _loc2_.toString();
               this._isEven = true;
            }
            else
            {
               this._isEven = false;
            }
         }
      }
      
      override public function end() : void
      {
         super.end();
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._mc = null;
         this._numText = null;
         this._numText1 = this._numText2 = null;
         this._materialProxy = this._materialProxy1 = null;
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         if(param1 != null)
         {
            this.text = param1["text"];
            this.setContent(param1["type"],param1["cId"]);
         }
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._currentValue = 59;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this._currentValue -= (60 - this._currentValue) * this.easingY;
         this.y -= 60 - this._currentValue;
         if(this._lock && this._isEven && this._currentValue < 58)
         {
            addChild(this._numText2);
            addChild(this._materialProxy1);
            this._lock = false;
         }
         if(this._currentValue < 0)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            super.close();
         }
      }
      
      public function setContent(param1:String, param2:int) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(this._materialProxy != null)
         {
            this._materialProxy.setContent(param1,param2);
         }
         if(this._isEven == true && this._materialProxy1 != null)
         {
            this._materialProxy1.setContent(param1,param2);
         }
         this.cacheAsBitmap = true;
      }
   }
}


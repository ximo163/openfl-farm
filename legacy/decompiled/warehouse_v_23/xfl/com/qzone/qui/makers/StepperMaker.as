package com.qzone.qui.makers
{
   import com.qzone.qui.utils.FrameTimer;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   
   public class StepperMaker extends EventDispatcher
   {
      
      public var repeatInterval:int = 40;
      
      private var downArrow:Sprite;
      
      public var target:DisplayObject;
      
      private var stepArrow:InteractiveObject;
      
      public var repeatDelay:int = 500;
      
      private var upArrow:Sprite;
      
      public var buttonPrevName:String = "prev_btn";
      
      private var _textField:TextField;
      
      private var _minimum:Number;
      
      public var textName:String = "num_txt";
      
      public var maxChars:int = 5;
      
      private var _skin:Sprite;
      
      private var _maximum:Number;
      
      private var stepTimer:FrameTimer;
      
      public var stepSize:Number;
      
      public var buttonNextName:String = "next_btn";
      
      private var _value:Number = 1;
      
      public function StepperMaker(param1:Number = 10, param2:Number = 1, param3:Number = 1)
      {
         super();
         this._maximum = param1;
         this._minimum = param2;
         this.stepSize = param3;
      }
      
      protected function eventHandle(param1:Boolean = false) : void
      {
         var fnName:String = null;
         var fnName2:String = null;
         var isRemove:Boolean = param1;
         var setArrow:Function = function(param1:Sprite):void
         {
            if(param1)
            {
               ButtonMaker[fnName2](param1);
               param1.useHandCursor = false;
               param1[fnName](MouseEvent.CLICK,_CLICK);
               param1[fnName](MouseEvent.MOUSE_DOWN,_MOUSE_DOWN);
            }
         };
         fnName = "addEventListener";
         fnName2 = "addTarget";
         if(isRemove)
         {
            fnName = "removeEventListener";
            fnName2 = "removeTarget";
         }
         setArrow(this.upArrow);
         setArrow(this.downArrow);
         if(this._textField)
         {
            this._textField[fnName](Event.CHANGE,this._CHANGE);
            this._textField[fnName](FocusEvent.FOCUS_OUT,this._FOCUS_OUT);
            this._textField.restrict = "0-9";
            this._textField.maxChars = this.maxChars;
            this.stepNumber(this._value);
         }
      }
      
      public function get minimum() : Number
      {
         return this._minimum;
      }
      
      private function changeNumber(param1:InteractiveObject) : void
      {
         if(param1 == this.upArrow)
         {
            this.stepNumber(this._value + this.stepSize);
         }
         else if(param1 == this.downArrow)
         {
            this.stepNumber(this._value - this.stepSize);
         }
         this.dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get maximum() : Number
      {
         return this._maximum;
      }
      
      public function set minimum(param1:Number) : void
      {
         this._minimum = param1;
         this.stepNumber(this._value);
      }
      
      private function _TIMER(param1:Event) : void
      {
         this.changeNumber(this.stepArrow);
         param1.currentTarget.delay = this.repeatInterval;
      }
      
      protected function _FOCUS_OUT(param1:Event) : void
      {
         var _loc2_:Number = Number(Number(this._textField.text) || this.minimum);
         this.stepNumber(_loc2_);
      }
      
      private function stepNumber(param1:Number) : void
      {
         if(param1 >= this.maximum)
         {
            param1 = this.maximum;
            this.setArrowEnabled(this.upArrow,false);
         }
         else
         {
            this.setArrowEnabled(this.upArrow,true);
         }
         if(param1 <= this.minimum)
         {
            param1 = this.minimum;
            this.setArrowEnabled(this.downArrow,false);
         }
         else
         {
            this.setArrowEnabled(this.downArrow,true);
         }
         this._value = Math.floor(param1 * 100) / 100;
         if(this._textField)
         {
            this._textField.text = this._value.toString();
         }
      }
      
      private function _MOUSE_DOWN(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.addEventListener(MouseEvent.MOUSE_UP,this._MOUSE_UP);
         _loc2_.addEventListener(MouseEvent.ROLL_OUT,this._MOUSE_UP);
         if(this.stepTimer == null)
         {
            FrameTimer.init(this._skin);
            this.stepTimer = new FrameTimer(this.repeatDelay);
            this.stepTimer.addEventListener(TimerEvent.TIMER,this._TIMER);
         }
         this.stepArrow = _loc2_;
         this.stepTimer.start();
      }
      
      public function set maximum(param1:Number) : void
      {
         this._maximum = param1;
         this.stepNumber(this._value);
      }
      
      protected function _CHANGE(param1:Event) : void
      {
         if(this._textField.text.indexOf(".") == this._textField.text.length - 1)
         {
            return;
         }
         var _loc2_:Number = Number(Number(this._textField.text) || this.minimum);
         this.stepNumber(_loc2_);
         this.dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function set value(param1:Number) : void
      {
         this.stepNumber(param1);
      }
      
      private function _CLICK(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         this.changeNumber(_loc2_);
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      private function _MOUSE_UP(param1:Event) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         _loc2_.removeEventListener(MouseEvent.MOUSE_UP,this._MOUSE_UP);
         _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this._MOUSE_UP);
         this.stepTimer.stop();
         this.stepTimer.removeEventListener(TimerEvent.TIMER,this._TIMER);
         this.stepTimer = null;
         this.stepArrow = null;
      }
      
      private function setArrowEnabled(param1:Sprite, param2:Boolean) : void
      {
         if(param1)
         {
            ButtonMaker.setEnabled(param1,param2);
         }
      }
      
      public function setSkin(param1:Sprite) : void
      {
         this.eventHandle(true);
         this._skin = param1;
         if(this._skin)
         {
            this.upArrow = this._skin.getChildByName(this.buttonNextName) as Sprite;
            this.downArrow = this._skin.getChildByName(this.buttonPrevName) as Sprite;
            this._textField = this._skin.getChildByName(this.textName) as TextField;
            this.eventHandle();
         }
         else
         {
            this.upArrow = null;
            this.downArrow = null;
            this._textField = null;
         }
      }
   }
}


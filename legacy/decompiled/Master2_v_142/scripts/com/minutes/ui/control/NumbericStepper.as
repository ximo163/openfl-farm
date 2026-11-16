package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.LipiUIComponent;
   import com.minutes.ui.core.UIEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class NumbericStepper extends Sprite
   {
      
      private var timer:Timer;
      
      private var bg:LipiUIComponent;
      
      private var downTime:int = 0;
      
      private var _disable_type:uint;
      
      private var numText:TextField;
      
      public var leftButton:LipiUIComponent;
      
      private var _min_num:int = 1;
      
      private var addValue:int = 0;
      
      private var _max_num:int = 99;
      
      public var rightButton:LipiUIComponent;
      
      public function NumbericStepper()
      {
         super();
         this.init();
         this._disable_type = 0;
      }
      
      public function set get_num(param1:*) : void
      {
         if(isNaN(param1))
         {
            this.numText.text = this.min_num.toString();
         }
         else if(param1 < this.min_num)
         {
            this.numText.text = this.min_num.toString();
            this.numText.setSelection(0,this.numText.text.length);
         }
         else if(param1 > this.max_num)
         {
            this.numText.text = this.max_num.toString();
         }
         else
         {
            this.numText.text = param1.toString();
         }
         dispatchEvent(new UIEvent(UIEvent.TEXT_CHANGE));
         this.updateSpinBtns();
      }
      
      public function get max_num() : int
      {
         return this._max_num;
      }
      
      private function leftButtonUp(param1:MouseEvent) : void
      {
         this.downTime = 0;
         this.addValue = 0;
         this.timer.stop();
      }
      
      private function focusOut(param1:FocusEvent) : void
      {
         if(this.get_num < this.min_num)
         {
            this.get_num = this.min_num;
         }
      }
      
      private function init() : void
      {
         this.leftButton = new LipiUIComponent();
         this.rightButton = new LipiUIComponent();
         this.bg = new LipiUIComponent();
         if(NUmbericStepperSkin.DecSkin != null)
         {
            this.leftButton.bgSkin = new LipiSkin(NUmbericStepperSkin.DecSkin);
            this.leftButton.addEventListener(MouseEvent.CLICK,this.leftButtonClick);
            this.leftButton.addEventListener(MouseEvent.MOUSE_DOWN,this.leftButtonDown);
            this.leftButton.addEventListener(MouseEvent.MOUSE_UP,this.leftButtonUp);
            this.leftButton.addEventListener(MouseEvent.ROLL_OUT,this.leftButtonUp);
            this.leftButton.bgAlpha = 0;
            this.leftButton.width = 20;
            this.leftButton.height = 20;
            this.leftButton.y = 1;
         }
         if(NUmbericStepperSkin.IncSkin != null)
         {
            this.rightButton.bgSkin = new LipiSkin(NUmbericStepperSkin.IncSkin);
            this.rightButton.addEventListener(MouseEvent.CLICK,this.rightButtonClick);
            this.rightButton.addEventListener(MouseEvent.MOUSE_DOWN,this.rightButtonDown);
            this.rightButton.addEventListener(MouseEvent.MOUSE_UP,this.rightButtonUp);
            this.rightButton.addEventListener(MouseEvent.ROLL_OUT,this.rightButtonUp);
            this.rightButton.bgAlpha = 0;
            this.rightButton.width = 20;
            this.rightButton.height = 20;
            this.rightButton.y = 1;
         }
         if(NUmbericStepperSkin.BgSkin != null)
         {
            this.bg.bgSkin = new LipiSkin(NUmbericStepperSkin.BgSkin);
            this.bg.bgAlpha = 0;
            this.bg.width = 50;
            this.bg.height = 22;
         }
         addChild(this.leftButton);
         addChild(this.rightButton);
         addChild(this.bg);
         this.leftButton.x = 0;
         this.bg.x = 20;
         this.rightButton.x = 70;
         this.numText = new TextField();
         this.numText.restrict = "0-9";
         this.numText.type = TextFieldType.INPUT;
         this.numText.defaultTextFormat = new TextFormat("Verdana",12,3355443,null,null,null,null,null,TextFormatAlign.CENTER);
         this.numText.text = "1";
         this.numText.width = this.bg.width;
         this.numText.height = this.bg.width;
         this.numText.x = this.bg.x;
         this.numText.y = 2;
         this.numText.addEventListener(Event.CHANGE,this.numTextChange);
         this.numText.addEventListener(MouseEvent.MOUSE_WHEEL,this.textWheel);
         this.numText.addEventListener(FocusEvent.FOCUS_OUT,this.focusOut);
         this.numText.addEventListener(FocusEvent.FOCUS_IN,this.foncusIn);
         addChild(this.numText);
         this.timer = new Timer(60);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      private function leftButtonDown(param1:MouseEvent) : void
      {
         this.addValue = -1;
         this.downTime = getTimer();
         this.timer.start();
      }
      
      public function get get_num() : int
      {
         return int(this.numText.text);
      }
      
      private function foncusIn(param1:FocusEvent) : void
      {
         var _loc2_:Timer = new Timer(10,1);
         _loc2_.addEventListener(TimerEvent.TIMER,this.allSelection);
         _loc2_.start();
      }
      
      private function updateSpinBtns() : void
      {
         if(this.get_num > this._min_num)
         {
            this.disable(false,0);
         }
         else
         {
            this.disable(true,0);
         }
         if(this.get_num < this._max_num)
         {
            this.disable(false,1);
         }
         else
         {
            this.disable(true,1);
         }
      }
      
      private function numTextChange(param1:Event) : void
      {
         this.get_num = this.numText.text;
         dispatchEvent(new UIEvent(UIEvent.TEXT_CHANGE));
      }
      
      public function set max_num(param1:int) : void
      {
         this._max_num = param1;
      }
      
      public function disable(param1:Boolean, param2:int) : void
      {
         if(param2 == 0)
         {
            this.grayMc(this.leftButton,param1);
            this.leftButton.mouseEnabled = param1 == false;
            this.leftButton.mouseChildren = param1 == false;
            if(param1)
            {
               this._disable_type |= 1;
            }
            else
            {
               this._disable_type &= ~1;
            }
         }
         else if(param2 == 1)
         {
            this.grayMc(this.rightButton,param1);
            this.rightButton.mouseEnabled = param1 == false;
            this.rightButton.mouseChildren = param1 == false;
            if(param1)
            {
               this._disable_type |= 2;
            }
            else
            {
               this._disable_type &= ~2;
            }
         }
         else
         {
            this.grayMc(this.leftButton,param1);
            this.leftButton.mouseEnabled = param1 == false;
            this.leftButton.mouseChildren = param1 == false;
            this.grayMc(this.rightButton,param1);
            this.rightButton.mouseEnabled = param1 == false;
            this.rightButton.mouseChildren = param1 == false;
            this.grayMc(this.bg,param1);
            this.numText.type = param1 == true ? TextFieldType.DYNAMIC : TextFieldType.INPUT;
            this.numText.mouseEnabled = param1 == false;
            this.numText.mouseWheelEnabled = param1 == false;
            if(param1 == true)
            {
               this.numText.backgroundColor = 6710886;
            }
            else
            {
               this.numText.backgroundColor = 16777215;
            }
         }
      }
      
      private function rightButtonUp(param1:MouseEvent) : void
      {
         this.downTime = 0;
         this.addValue = 0;
         this.timer.stop();
      }
      
      private function allSelection(param1:Event) : void
      {
         if(stage != null)
         {
            stage.focus = this.numText;
         }
         this.numText.setSelection(0,this.numText.text.length);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this.downTime == 0)
         {
            return;
         }
         if(getTimer() - 500 > this.downTime)
         {
            this.get_num += this.addValue;
         }
         if(this.get_num < this._min_num)
         {
            this.get_num = this._min_num;
         }
         if(this.get_num > this._max_num)
         {
            this.get_num = this._max_num;
         }
         this.updateSpinBtns();
      }
      
      private function leftButtonClick(param1:MouseEvent) : void
      {
         --this.get_num;
         this.updateSpinBtns();
      }
      
      private function rightButtonDown(param1:MouseEvent) : void
      {
         this.addValue = 1;
         this.downTime = getTimer();
         this.timer.start();
      }
      
      private function grayMc(param1:Sprite, param2:Boolean) : void
      {
         var mat:Array = null;
         var colorMat:ColorMatrixFilter = null;
         var mc:Sprite = param1;
         var flag:Boolean = param2;
         if(mc == null)
         {
            return;
         }
         try
         {
            if(flag)
            {
               mat = [0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0,0,0,1,0];
               colorMat = new ColorMatrixFilter(mat);
               mc.filters = [colorMat];
            }
            else
            {
               mc.filters = [];
            }
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
      
      private function textWheel(param1:MouseEvent) : void
      {
         if(param1.delta > 0)
         {
            this.get_num += 1;
         }
         else
         {
            --this.get_num;
         }
      }
      
      public function set min_num(param1:int) : void
      {
         this._min_num = param1;
      }
      
      private function rightButtonClick(param1:MouseEvent) : void
      {
         this.get_num += 1;
         this.updateSpinBtns();
      }
      
      public function get min_num() : int
      {
         return this._min_num;
      }
   }
}


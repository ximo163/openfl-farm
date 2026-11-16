package com.qzone.qui.controls
{
   import com.qzone.qui.skins.ButtonDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class Button extends Label
   {
      
      protected var _selected:Boolean;
      
      public var textSelectedFormat:TextFormat;
      
      public var selectedSkin:Class;
      
      private var _currentFormat:TextFormat;
      
      public var inGroup:Boolean = false;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public var textOverFormat:TextFormat;
      
      protected var _toggle:Boolean;
      
      public function Button(param1:String = "Button", param2:Function = null)
      {
         super(param1,param2);
         this.defaultSkin = ButtonDefaultSkin.skin;
         this.selectedSkin = ButtonDefaultSkin.selectedSkin;
         paddingH = Style.buttonPaddingH;
         paddingV = 3;
         textDefaultFormat = Style.getButtonFormat();
         this.textOverFormat = Style.getButtonOverFormat();
         this.textSelectedFormat = Style.getButtonSelectedFormat();
         this.buttonMode = true;
         this.useHandCursor = false;
         this.mouseChildren = false;
      }
      
      private function addEvent() : void
      {
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         this.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
      }
      
      private function onRollOver(param1:Event) : void
      {
         this._textField.setTextFormat(this.textOverFormat);
         this.filters = Style.getRollOverFilter();
      }
      
      protected function setSelectedSkin() : void
      {
         this._currentFormat = this.textSelectedFormat;
         DisplayUtil.removeChild(this,this._skin);
         if(this.selectedSkin)
         {
            this._skin = new this.selectedSkin();
            this.fixSkin(this._skin);
            this.addChildAt(this._skin,0);
         }
      }
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this.removeEvent();
            _textField.setTextFormat(textDisabledFormat);
            this.filters = Style.getDisableFilter();
         }
         else
         {
            this.addEvent();
            _textField.setTextFormat(this._currentFormat);
            this.filters = Style.getRollOutFilter();
         }
         this.tabEnabled = _enabled;
         this.mouseEnabled = _enabled;
      }
      
      public function get toggle() : Boolean
      {
         return this._toggle;
      }
      
      override protected function setSkin() : void
      {
         if(this._selected)
         {
            this.setSelectedSkin();
         }
         else
         {
            this.setDefaultSkin();
         }
         this._textField.setTextFormat(this._currentFormat);
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      protected function setDefaultSkin() : void
      {
         this._currentFormat = this.textDefaultFormat;
         DisplayUtil.removeChild(this,this._skin);
         if(this.defaultSkin)
         {
            this._skin = new this.defaultSkin();
            this.fixSkin(this._skin);
            this.addChildAt(this._skin,0);
         }
      }
      
      private function onPress(param1:Event) : void
      {
         this.filters = Style.getHitFilter();
      }
      
      public function set toggle(param1:Boolean) : void
      {
         this._toggle = param1;
      }
      
      protected function onClick(param1:MouseEvent) : void
      {
         if(this._toggle)
         {
            if(this.inGroup && this._selected)
            {
               return;
            }
            this.selected = !this._selected;
            this.dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      private function onRelease(param1:Event) : void
      {
         this.filters = Style.getRollOverFilter();
      }
      
      private function fixSkin(param1:DisplayObject) : void
      {
         if(param1 is MovieClip)
         {
            (param1 as MovieClip).gotoAndStop(1);
         }
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(this._selected != param1)
         {
            this._selected = param1;
            if(_added)
            {
               this.setSkin();
               this.setSize();
            }
         }
      }
      
      private function onRollOut(param1:Event) : void
      {
         this._textField.setTextFormat(this._currentFormat);
         this.filters = Style.getRollOutFilter();
      }
      
      private function removeEvent() : void
      {
         this.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }
   }
}


package com.qzone.qui.controls
{
   import com.qzone.qui.skins.TextInputDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   
   public class TextInput extends UIComponent
   {
      
      private var _readOnly:Boolean;
      
      protected var _text:String;
      
      protected var _textField:TextField;
      
      protected var paddingH:int;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public var textDisabledFormat:TextFormat;
      
      protected var paddingV:int;
      
      public var textDefaultFormat:TextFormat;
      
      public var selectedSkin:Class;
      
      private var _selected:Boolean;
      
      public function TextInput()
      {
         super();
         _width = 100;
         _height = 20;
         this.paddingH = Style.textInputPaddingH;
         this.paddingV = Style.textInputPaddingV;
         this.textDefaultFormat = Style.getTextInputFormat();
         this.textDisabledFormat = Style.getDisabledFormat();
         this._textField = new TextField();
         this._textField.type = TextFieldType.INPUT;
         this._textField.multiline = false;
         this._textField.autoSize = TextFieldAutoSize.NONE;
         this.defaultSkin = TextInputDefaultSkin.skin;
         this.selectedSkin = TextInputDefaultSkin.selectedSkin;
      }
      
      private function setSelectedSkin() : void
      {
         DisplayUtil.removeChild(this,this._skin);
         if(this.selectedSkin)
         {
            this._skin = new this.selectedSkin();
            this.addChildAt(this._skin,0);
         }
      }
      
      override protected function setSize() : void
      {
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
         this._textField.x = this.paddingH;
         this._textField.y = this.paddingV;
         this._textField.width = _width - this.paddingH * 2;
         this._textField.height = _height - this.paddingV * 2;
      }
      
      public function set readOnly(param1:Boolean) : void
      {
         this._readOnly = param1;
         this.setReadOnly();
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
      }
      
      public function get htmlText() : String
      {
         return this._textField.htmlText;
      }
      
      public function get textField() : TextField
      {
         return this._textField;
      }
      
      protected function _CHANGE(param1:Event) : void
      {
      }
      
      override protected function init() : void
      {
         this._textField.defaultTextFormat = this.textDefaultFormat;
         this._textField.mouseWheelEnabled = false;
         this.text = this._text;
         this.addChild(this._textField);
         super.init();
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1 || "";
         this._textField.text = this._text;
      }
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this.removeEvent();
            this._textField.setTextFormat(this.textDisabledFormat);
            this.filters = Style.getDisableFilter();
         }
         else
         {
            this.addEvent();
            this._textField.setTextFormat(this.textDefaultFormat);
            this.filters = Style.getRollOutFilter();
         }
         this.mouseEnabled = _enabled;
         this.setReadOnly();
      }
      
      public function get readOnly() : Boolean
      {
         return this._readOnly;
      }
      
      private function setReadOnly() : void
      {
         if(this._readOnly)
         {
            this._textField.type = TextFieldType.DYNAMIC;
         }
         else if(_enabled)
         {
            this._textField.type = TextFieldType.INPUT;
         }
         else
         {
            this._textField.type = TextFieldType.DYNAMIC;
         }
      }
      
      protected function _FOCUS_OUT(param1:Event) : void
      {
         this.removeEvent();
         this._selected = false;
         this.setSkin();
         this.setSize();
      }
      
      public function get text() : String
      {
         return this._textField.text;
      }
      
      protected function _FOCUS_IN(param1:Event) : void
      {
         this._textField.addEventListener(FocusEvent.FOCUS_OUT,this._FOCUS_OUT);
         this._textField.addEventListener(Event.CHANGE,this._CHANGE);
         this._selected = true;
         this.setSkin();
         this.setSize();
      }
      
      protected function removeEvent() : void
      {
         this._textField.removeEventListener(Event.CHANGE,this._CHANGE);
         this._textField.removeEventListener(FocusEvent.FOCUS_OUT,this._FOCUS_OUT);
      }
      
      public function set htmlText(param1:String) : void
      {
         this._text = param1 || "";
         this._textField.htmlText = this._text;
      }
      
      protected function addEvent() : void
      {
         this._textField.addEventListener(FocusEvent.FOCUS_IN,this._FOCUS_IN);
      }
      
      private function setDefaultSkin() : void
      {
         DisplayUtil.removeChild(this,this._skin);
         if(this.defaultSkin)
         {
            this._skin = new this.defaultSkin();
            this.addChildAt(this._skin,0);
         }
      }
   }
}


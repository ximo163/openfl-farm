package com.qzone.qui.controls
{
   import com.qzone.qui.managers.EffectManager;
   import com.qzone.qui.skins.ToolTipSkin;
   import com.qzone.qui.styles.Style;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class ToolTip extends UIComponent
   {
      
      private var _skin:Sprite;
      
      private var paddingV:int;
      
      protected var _textField:TextField;
      
      public var effect:Object;
      
      public var offset:Point;
      
      private var paddingH:int;
      
      public function ToolTip()
      {
         super();
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.paddingH = Style.toolTipPaddingH;
         this.paddingV = Style.toolTipPaddingV;
         this._textField = new TextField();
         this._textField.defaultTextFormat = Style.getToolTipFormat();
         this._textField.selectable = false;
         this._textField.autoSize = TextFieldAutoSize.LEFT;
         this._textField.multiline = true;
         this.offset = Style.toolTipOffset;
         this.effect = EffectManager.toolTipEffect;
      }
      
      public function set text(param1:String) : void
      {
         this._textField.htmlText = param1 || "";
         this.setSize();
      }
      
      public function get text() : String
      {
         return this._textField.text;
      }
      
      override protected function init() : void
      {
         super.init();
         this.addChild(this._textField);
      }
      
      override protected function setSize() : void
      {
         this._textField.x = this.paddingH;
         this._textField.y = this.paddingV - 1;
         _width = this._textField.width + this.paddingH * 2;
         _height = this._textField.height + this.paddingV * 2;
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
      }
      
      override protected function setSkin() : void
      {
         this._skin = new ToolTipSkin();
         this.addChildAt(this._skin,0);
         this.filters = Style.getShadowFilter();
      }
   }
}


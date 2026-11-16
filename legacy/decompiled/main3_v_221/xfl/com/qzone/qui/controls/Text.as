package com.qzone.qui.controls
{
   import com.qzone.qui.styles.Style;
   import flash.text.TextFieldAutoSize;
   
   public class Text extends Label
   {
      
      public function Text(param1:Number = 100, param2:String = "Text")
      {
         super(param2);
         _width = param1;
         _height = 20;
         textDefaultFormat = Style.getTextFormat();
         _textField.multiline = true;
         _textField.wordWrap = true;
         _textField.autoSize = TextFieldAutoSize.NONE;
      }
      
      override protected function init() : void
      {
         _textField.defaultTextFormat = textDefaultFormat;
         super.init();
      }
      
      override protected function setSize() : void
      {
         _textField.width = _width;
         _textField.height = Math.max(20,_textField.textHeight + 5);
         _height = _textField.height;
      }
   }
}


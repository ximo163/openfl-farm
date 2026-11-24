package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.corelib.controls.interfaces.IRenderer;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class RecordListItemRenderer extends Sprite implements IRenderer
   {
      
      private var _data:Object;
      
      private var _valueTf:TextField;
      
      private var _textFormat:TextFormat;
      
      public function RecordListItemRenderer()
      {
         super();
         this._valueTf = new TextField();
         this._textFormat = new TextFormat();
         addChild(this._valueTf);
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         if(Boolean(this._valueTf) && Boolean(this._data))
         {
            this._valueTf.selectable = false;
            this._valueTf.mouseEnabled = false;
            this._valueTf.multiline = false;
            this._valueTf.autoSize = TextFieldAutoSize.LEFT;
            this._valueTf.htmlText = "<font size=\"13\" face=\"微软雅黑\"><b>" + String(this._data) + "</b></font>";
         }
      }
      
      override public function get width() : Number
      {
         return 250;
      }
      
      override public function get height() : Number
      {
         return 20;
      }
   }
}


package com.qzone.qui.containers
{
   import com.qzone.qui.skins.ListDefaultSkin;
   import com.qzone.qui.styles.Style;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class Canvas extends Container
   {
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public function Canvas(param1:Number = 200, param2:Number = 200)
      {
         super();
         _width = param1;
         _height = param2;
         this.defaultSkin = ListDefaultSkin.skin;
         borderSizeH = Style.canvasBorderSizeH;
         borderSizeV = Style.canvasBorderSizeV;
         backgroundColor = Style.canvasBackgroundColor;
         backgroundAlpha = Style.canvasBackgroundAlpha;
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      public function get nativeHeight() : int
      {
         return _height - paddingH * 2 - borderSizeV * 2;
      }
      
      override protected function setSkin() : void
      {
         if(this.defaultSkin)
         {
            this._skin = new this.defaultSkin();
            this.addChildAt(this._skin,0);
         }
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
      
      private function contentResize(param1:Event) : void
      {
         updateScrollBar();
      }
      
      public function get nativeWidth() : int
      {
         return _width - paddingH * 2 - borderSizeH * 2;
      }
   }
}


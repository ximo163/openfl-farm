package com.qzone.qui.containers
{
   import com.qzone.qui.controls.scrollClasses.ScrollBase;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Sprite;
   
   public class Container extends ScrollBase
   {
      
      private var m_enableValidate:Boolean;
      
      public var backgroundAlpha:Number;
      
      public var autoLayout:Boolean;
      
      public var backgroundColor:uint;
      
      public function Container()
      {
         super();
         _width = 200;
         _height = 200;
         this.backgroundColor = Style.canvasBackgroundColor;
         this.backgroundAlpha = Style.canvasBackgroundAlpha;
         this.m_enableValidate = true;
      }
      
      public function set enableValidate(param1:Boolean) : void
      {
         this.m_enableValidate = param1;
      }
      
      protected function removeSkin(param1:Sprite) : DisplayObject
      {
         return super.removeChild(param1);
      }
      
      protected function updateBackGround() : void
      {
         var _loc1_:int = Math.max(this.content.width + paddingH * 2 - borderSizeH * 2,_width - _scrollW);
         var _loc2_:int = Math.max(this.content.height + paddingV * 2 - borderSizeV * 2,_height - _scrollH);
         this.drawBackGround(_loc1_,_loc2_);
      }
      
      public function validateNow() : void
      {
         if(this.m_enableValidate == false)
         {
            return;
         }
         checkScrollBar();
         this.updateBackGround();
         updateScrollBar();
         setSize();
      }
      
      override public function get content() : DisplayObjectContainer
      {
         if(_content == null)
         {
            _content = new Sprite();
            this.setContent();
            this.addChild(_content);
         }
         return _content;
      }
      
      private function setContent() : void
      {
         _content.scrollRect = _scrollRect;
         _content.y = borderSizeV;
         _content.x = borderSizeH;
      }
      
      public function set content(param1:DisplayObjectContainer) : void
      {
         DisplayUtil.removeChild(this,_content);
         _content = param1;
         this.setContent();
         this.addChild(_content);
         if(this.autoLayout)
         {
            _width = param1.width + Style.panelPaddingH * 2;
            _height = param1.height + Style.panelHeadHeight + Style.panelPaddingV;
         }
         if(_added)
         {
            this.validateNow();
         }
      }
      
      protected function drawBackGround(param1:int, param2:int) : void
      {
         if(this.backgroundAlpha == 0)
         {
            return;
         }
         var _loc3_:Graphics = this.content["graphics"];
         _loc3_.clear();
         _loc3_.beginFill(this.backgroundColor,this.backgroundAlpha);
         _loc3_.drawRect(0,0,param1,param2);
         _loc3_.endFill();
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      public function get enableValidate() : Boolean
      {
         return this.m_enableValidate;
      }
      
      protected function addSkin(param1:Sprite) : DisplayObject
      {
         return super.addChild(param1);
      }
   }
}


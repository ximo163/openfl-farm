package com.qzone.qui.containers
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.UIComponent;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.skins.PanelDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class Panel extends UIComponent
   {
      
      public var titleAlign:String = "left";
      
      public var controlBarSkin:Class;
      
      private var _title:String;
      
      protected var marginB:int;
      
      protected var _skin:Sprite;
      
      public var showControlBar:Boolean;
      
      protected var marginR:int;
      
      protected var marginL:int;
      
      public var titleDefautFormat:TextFormat;
      
      protected var marginT:int;
      
      protected var _autoSize:Boolean;
      
      public var defaultSkin:Class;
      
      public var autoLayout:Boolean;
      
      protected var _content:DisplayObjectContainer;
      
      protected var panelTitle:Label;
      
      public var controlBar:ControlBar;
      
      public function Panel(param1:String = "Panel", param2:int = 300, param3:int = 200)
      {
         super();
         this._title = param1;
         _height = param3;
         _width = param2;
         this.marginT = Style.panelHeadHeight;
         this.marginB = Style.panelControlBarHeight;
         this.marginR = Style.panelPaddingH;
         this.marginL = Style.panelPaddingH;
         this.defaultSkin = PanelDefaultSkin.skin;
         this.controlBarSkin = PanelDefaultSkin.controlBarSkin;
         this.titleDefautFormat = Style.getLabelFormat();
      }
      
      public function get nativeHeight() : int
      {
         return _height - this.marginT - this.marginB;
      }
      
      private function setContent() : void
      {
         this._content.y = this.marginT;
         this._content.x = this.marginL;
         if(this.autoLayout)
         {
            _width = this._content.width + this.marginL + this.marginR;
            _height = this._content.height + this.marginT + this.marginB;
            this._content.addEventListener(Event.RESIZE,this.contentResize);
            this.setSize();
         }
         else
         {
            this._content.height = _height - this.marginT - this.marginB;
            this._content.width = _width - this.marginL - this.marginR;
         }
      }
      
      public function set content(param1:DisplayObjectContainer) : void
      {
         DisplayUtil.removeChild(this,this._content);
         this._content = param1;
         this.setContent();
         this.addChild(this._content);
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      public function get content() : DisplayObjectContainer
      {
         if(this._content == null)
         {
            this._content = new Sprite();
            this.setContent();
            this.addChild(this._content);
         }
         return this._content;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
         if(this.controlBar)
         {
            this.controlBar.width = _width;
            this.controlBar.y = _height - this.controlBar.height;
         }
         if(this.panelTitle)
         {
            this.panelTitle.width = _width;
         }
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      private function contentResize(param1:Event) : void
      {
         _width = this._content.width + this.marginL + this.marginR;
         _height = this._content.height + this.marginT + this.marginB;
         this.setSize();
      }
      
      public function set title(param1:String) : void
      {
         this._title = param1;
         if(this.panelTitle)
         {
            this.panelTitle.text = this._title;
         }
      }
      
      public function get nativeWidth() : int
      {
         return _width - this.marginL - this.marginR;
      }
      
      override protected function setSkin() : void
      {
         this._skin = new this.defaultSkin();
         this.addChildAt(this._skin,0);
         if(this.showControlBar)
         {
            this.controlBar = new ControlBar();
            this.addChild(this.controlBar);
         }
         this.panelTitle = new Label();
         this.panelTitle.textDefaultFormat = this.titleDefautFormat;
         this.panelTitle.text = this._title;
         this.panelTitle.x = 4;
         this.panelTitle.y = 1;
         this.panelTitle.mouseEnabled = false;
         this.addChild(this.panelTitle);
         if(this.titleAlign == Align.CENTER)
         {
            this.panelTitle.x = AlignUtil.middle(_width,this.panelTitle.width);
         }
      }
   }
}


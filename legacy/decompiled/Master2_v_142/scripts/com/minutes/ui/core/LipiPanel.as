package com.minutes.ui.core
{
   import com.minutes.ui.control.LipiDefaultSkin;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class LipiPanel extends LipiUIComponent
   {
      
      private var _dragBar:Sprite;
      
      private var _closeButton:LipiUIComponent;
      
      private var _closeHeight:int = 18;
      
      private var _closeSkin:LipiSkin;
      
      private var _closeTop:int = 5;
      
      private var _closeRight:int = 7;
      
      private var _headHeightChange:Boolean = false;
      
      private var _titleText:TextField;
      
      private var _titleIMG:DisplayObject;
      
      private var _sizeChange:Boolean = false;
      
      private var _closeVisible:Boolean = true;
      
      private var _contentPane:Sprite = null;
      
      private var _closeWidth:int = 18;
      
      private var closePositionChange:Boolean = false;
      
      private var _headHeight:int = 25;
      
      private var _title:String = "";
      
      private var _titleChange:Boolean = false;
      
      private var childChange:Boolean = false;
      
      public function LipiPanel(param1:Rectangle = null)
      {
         super();
         this.init(param1);
      }
      
      public function set closeRight(param1:int) : void
      {
         this._closeRight = param1;
         this.closePositionChange = true;
         invalidateDisplayList();
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.addChildAt(param1,param2);
         return param1;
      }
      
      private function init(param1:Rectangle = null) : void
      {
         this._contentPane = new Sprite();
         this._contentPane.x = 0;
         this._contentPane.y = 0;
         super.addChild(this._contentPane);
         this._dragBar = new Sprite();
         this._dragBar.graphics.beginFill(0,0);
         this._dragBar.graphics.drawRect(0,0,10,10);
         this._dragBar.graphics.endFill();
         this._dragBar.width = width;
         this._dragBar.height = this.headHeight;
         this._dragBar.addEventListener(MouseEvent.MOUSE_DOWN,this.dragDown);
         super.addChild(this._dragBar);
         this._closeButton = new LipiUIComponent();
         this._closeButton.addEventListener(MouseEvent.CLICK,this._closeButtonClick);
         this._closeButton.width = this.closeWidth;
         this._closeButton.height = this.closeHeight;
         this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
         this._closeButton.y = this.closeTop;
         this._closeButton.buttonMode = true;
         this._closeButton.useHandCursor = true;
         super.addChild(this._closeButton);
         addEventListener(UIEvent.RESIZE,this.onResize);
         if(LipiDefaultSkin.WindowBg != null)
         {
            bgSkin = new LipiSkin(LipiDefaultSkin.WindowBg,param1);
         }
         if(LipiDefaultSkin.WindowCloseBg != null)
         {
            this.closeSkin = new LipiSkin(LipiDefaultSkin.WindowCloseBg);
         }
      }
      
      public function get titleFormat() : TextFormat
      {
         return this._titleText.defaultTextFormat;
      }
      
      public function get closeRight() : int
      {
         return this._closeRight;
      }
      
      public function get closeSkin() : LipiSkin
      {
         return this._closeSkin;
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         return this._contentPane.getChildByName(param1);
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         if(this._contentPane == null)
         {
            return -1;
         }
         return this._contentPane.getChildIndex(param1);
      }
      
      public function get headHeight() : int
      {
         return this._headHeight;
      }
      
      public function get closeWidth() : int
      {
         return this._closeWidth;
      }
      
      public function set closeSkin(param1:LipiSkin) : void
      {
         this._closeSkin = param1;
         this._closeButton.bgSkin = param1;
      }
      
      public function set closeVisible(param1:Boolean) : void
      {
         this._closeVisible = param1;
         this._closeButton.visible = false;
         this._closeButton.mouseEnabled = false;
         this._closeButton.mouseChildren = false;
      }
      
      public function set title(param1:String) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         this._title = param1;
         if(param1 == "" && this._titleText != null)
         {
            this.removeChild(this._titleText);
            this._titleText = null;
         }
         if(this._titleText == null && param1 != "")
         {
            this._titleText = new TextField();
            this._titleText.defaultTextFormat = new TextFormat("Verdana",16,16777215,true);
            this._titleText.mouseEnabled = false;
            this._titleText.autoSize = TextFieldAutoSize.LEFT;
            this.addChild(this._titleText);
         }
         if(this._titleText != null)
         {
            this._titleText.text = param1;
         }
         this._titleChange = true;
         invalidateDisplayList();
      }
      
      public function get closeTop() : int
      {
         return this._closeTop;
      }
      
      public function get closeHeight() : int
      {
         return this._closeHeight;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         return this._contentPane.getChildAt(param1);
      }
      
      public function set titleIMG(param1:Class) : void
      {
         if(!param1)
         {
            return;
         }
         if(Boolean(this._titleIMG) && contains(this._titleIMG))
         {
            this.removeChild(this._titleIMG);
         }
         this._titleIMG = new param1();
         this.addChild(this._titleIMG);
         this._titleChange = true;
         invalidateDisplayList();
      }
      
      private function _closeButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:UIEvent = new UIEvent(UIEvent.CLOSE);
         dispatchEvent(_loc2_);
      }
      
      public function addChildToSuper(param1:DisplayObject) : void
      {
         super.addChild(param1);
      }
      
      override public function get numChildren() : int
      {
         return this._contentPane.numChildren;
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         return this._contentPane.removeChildAt(param1);
      }
      
      public function set headHeight(param1:int) : void
      {
         this._headHeight = param1;
         this._headHeightChange = true;
         invalidateDisplayList();
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function get closeVisible() : Boolean
      {
         return this._closeVisible;
      }
      
      public function set closeWidth(param1:int) : void
      {
         this._closeWidth = param1;
         this.closePositionChange = true;
         invalidateDisplayList();
      }
      
      public function set titleFormat(param1:TextFormat) : void
      {
         this._titleText.defaultTextFormat = param1;
         this.title = this._title;
      }
      
      private function dragUp(param1:MouseEvent) : void
      {
         stopDrag();
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.dragUp);
      }
      
      private function onResize(param1:UIEvent) : void
      {
         this._sizeChange = true;
         invalidateDisplayList();
      }
      
      private function dragDown(param1:MouseEvent) : void
      {
         if(parent != null)
         {
            parent.addChild(this);
         }
         startDrag(false,new Rectangle(this.mouseX * -1,this.mouseY * -1,stage.stageWidth - this.mouseY,stage.stageHeight - this.mouseY));
         if(stage != null)
         {
            stage.addEventListener(MouseEvent.MOUSE_UP,this.dragUp,false,0,true);
         }
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this._headHeightChange || this._titleChange)
         {
            if(this._titleText != null)
            {
               this._titleText.x = (param1 - this._titleText.width) / 2;
               this._titleText.y = (this._headHeight - this._titleText.height) / 2;
            }
            if(this._titleIMG != null)
            {
               this._titleIMG.x = (param1 - this._titleIMG.width) / 2;
               this._titleIMG.y = (this._headHeight - this._titleIMG.height) / 2;
            }
            if(this._headHeightChange)
            {
               this._contentPane.y = this._headHeight;
               this._dragBar.width = width;
               this._dragBar.height = this._headHeight;
            }
            this._titleChange = false;
            this._headHeightChange = false;
         }
         if(this._sizeChange)
         {
            this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
            this._closeButton.y = this.closeTop;
            this._dragBar.width = width;
            this._sizeChange = false;
         }
         if(this.closePositionChange)
         {
            this._closeButton.width = this.closeWidth;
            this._closeButton.height = this.closeHeight;
            this._closeButton.x = this.width - this._closeButton.width - this.closeRight;
            this._closeButton.y = this.closeTop;
            this.closePositionChange = false;
         }
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.removeChild(param1);
         return param1;
      }
      
      public function set closeTop(param1:int) : void
      {
         this._closeTop = param1;
         this.closePositionChange = true;
         invalidateDisplayList();
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         if(this._contentPane == null)
         {
            return null;
         }
         this._contentPane.addChild(param1);
         return param1;
      }
      
      public function set closeHeight(param1:int) : void
      {
         this._closeHeight = param1;
         this.closePositionChange = true;
         invalidateDisplayList();
      }
   }
}


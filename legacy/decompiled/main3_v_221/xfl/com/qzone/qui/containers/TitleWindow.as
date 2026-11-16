package com.qzone.qui.containers
{
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.qui.managers.EffectManager;
   import com.qzone.qui.skins.PanelDefaultSkin;
   import com.qzone.utils.GraphicsUtil;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class TitleWindow extends Panel
   {
      
      public var closeFn:Function;
      
      public var closeButtonSkin:Class;
      
      protected var closeButton:Sprite;
      
      private var _headArea:Sprite;
      
      protected var _showCloseButton:Boolean;
      
      public var effect:Object;
      
      public function TitleWindow(param1:String = "Window", param2:int = 300, param3:int = 200, param4:Function = null)
      {
         super(param1,param2,param3);
         this.closeFn = param4;
         this.closeButtonSkin = PanelDefaultSkin.closeButtonSkin;
         this.effect = EffectManager.popUpEffect;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(this._headArea)
         {
            GraphicsUtil.draw(this._headArea,0,0,new Rectangle(0,0,_width,22),true);
         }
         if(this.closeButton)
         {
            this.closeButton.x = _width - this.closeButton.width - 3;
            this.closeButton.y = 2;
         }
      }
      
      public function get showCloseButton() : Boolean
      {
         return this._showCloseButton;
      }
      
      override protected function setSkin() : void
      {
         super.setSkin();
         if(this._headArea == null)
         {
            this._headArea = new Sprite();
            this.addChild(this._headArea);
         }
         if(this.closeButton == null)
         {
            this.closeButton = new this.closeButtonSkin();
            ButtonMaker.addTarget(this.closeButton);
            this.closeButton.useHandCursor = false;
            this.closeButton["toolTip"] = "关闭";
            this.closeButton.visible = this._showCloseButton;
            this.addChild(this.closeButton);
            this.closeButton.addEventListener(MouseEvent.CLICK,this.onClose);
         }
      }
      
      protected function onClose(param1:Event) : void
      {
         this.close();
      }
      
      public function get headArea() : Sprite
      {
         return this._headArea;
      }
      
      public function keyEnter(param1:KeyboardEvent) : void
      {
      }
      
      public function set showCloseButton(param1:Boolean) : void
      {
         this._showCloseButton = param1;
         if(this.closeButton)
         {
            this.closeButton.visible = this._showCloseButton;
         }
      }
      
      protected function close() : void
      {
         var _loc1_:Event = new Event(Event.CLOSE);
         this.dispatchEvent(_loc1_);
         this.closeFn && this.closeFn(_loc1_);
      }
   }
}


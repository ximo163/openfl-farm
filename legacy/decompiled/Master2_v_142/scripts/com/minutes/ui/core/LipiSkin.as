package com.minutes.ui.core
{
   import comm.S9bmp;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class LipiSkin extends Sprite
   {
      
      private var _enableMouse:Boolean = true;
      
      private var _rect:Rectangle;
      
      private var _backgroundImage:Class;
      
      private var _bgImage:DisplayObject;
      
      public function LipiSkin(param1:Class, param2:Rectangle = null)
      {
         super();
         this._rect = param2;
         if(param1 != null)
         {
            this.backgroundImage = param1;
         }
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeFormStage);
      }
      
      public function get backgroundDisplayObject() : DisplayObject
      {
         return this._bgImage;
      }
      
      public function get enableMouse() : Boolean
      {
         return this._enableMouse;
      }
      
      public function set enableMouse(param1:Boolean) : void
      {
         this._enableMouse = param1;
      }
      
      private function removeFormStage(param1:Event) : void
      {
         if(this._bgImage is MovieClip)
         {
            (this._bgImage as MovieClip).gotoAndStop(1);
         }
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.stageUpHandler);
      }
      
      private function downHandler(param1:MouseEvent) : void
      {
         if(!this.enableMouse)
         {
            return;
         }
         if((param1.currentTarget as MovieClip).totalFrames >= 3)
         {
            (param1.currentTarget as MovieClip).gotoAndStop(3);
            this.stage.addEventListener(MouseEvent.MOUSE_UP,this.stageUpHandler);
         }
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         if(!this.enableMouse)
         {
            return;
         }
         if(param1.buttonDown == true)
         {
            return;
         }
         if((param1.currentTarget as MovieClip).totalFrames >= 3)
         {
            (param1.currentTarget as MovieClip).gotoAndStop(1);
         }
      }
      
      override public function set width(param1:Number) : void
      {
         if(this._bgImage == null)
         {
            return;
         }
         this._bgImage.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         if(this._bgImage == null)
         {
            return;
         }
         this._bgImage.height = param1;
      }
      
      private function stageUpHandler(param1:MouseEvent) : void
      {
         if(!this.enableMouse)
         {
            return;
         }
         if(this._bgImage is MovieClip)
         {
            if((this._bgImage as MovieClip).totalFrames >= 3)
            {
               if(param1.target == this._bgImage)
               {
                  (this._bgImage as MovieClip).gotoAndStop(2);
               }
               else
               {
                  (this._bgImage as MovieClip).gotoAndStop(1);
               }
            }
         }
         this.stage.removeEventListener(MouseEvent.MOUSE_UP,this.stageUpHandler);
      }
      
      public function get backgroundImage() : Class
      {
         return this._backgroundImage;
      }
      
      public function get bgImage() : DisplayObject
      {
         return this._bgImage;
      }
      
      public function set backgroundImage(param1:Class) : void
      {
         this._backgroundImage = param1;
         if(this._rect)
         {
            this._bgImage = new S9bmp(param1,this._rect);
         }
         else
         {
            this._bgImage = new param1() as DisplayObject;
         }
         this._bgImage.x = 0;
         this._bgImage.y = 0;
         addChild(this._bgImage);
         if(this._bgImage is MovieClip)
         {
            (this._bgImage as MovieClip).gotoAndStop(1);
            (this._bgImage as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.overHandler);
            (this._bgImage as MovieClip).addEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
            (this._bgImage as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.outHandler);
         }
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         if(!this.enableMouse)
         {
            return;
         }
         if(param1.buttonDown == false)
         {
            if((param1.currentTarget as MovieClip).totalFrames >= 3)
            {
               (param1.currentTarget as MovieClip).gotoAndStop(2);
            }
         }
      }
      
      public function set backgroundDisplayObject(param1:DisplayObject) : void
      {
         this._bgImage = param1;
      }
   }
}


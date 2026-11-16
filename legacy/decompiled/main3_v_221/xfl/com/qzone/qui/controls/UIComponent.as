package com.qzone.qui.controls
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class UIComponent extends Sprite
   {
      
      public static var isRenderCalling:Boolean;
      
      protected var _added:Boolean;
      
      protected var _height:Number;
      
      protected var _width:Number;
      
      protected var _enabled:Boolean;
      
      protected var _inited:Boolean;
      
      protected var _toolTip:String;
      
      protected var renderCalls:Dictionary = new Dictionary();
      
      protected var _resized:Boolean;
      
      public function UIComponent()
      {
         super();
         this._added = false;
         this._enabled = true;
         this._inited = false;
         this._resized = false;
         this._toolTip = "";
         this.addEventListener(Event.ADDED,this.addedFn);
      }
      
      protected function setSize() : void
      {
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      protected function delayCall(param1:Function, ... rest) : void
      {
         if(isRenderCalling)
         {
            trace("isRenderCalling");
            param1.apply(param1,rest);
            return;
         }
         this.renderCalls[param1] = rest;
         if(stage)
         {
            stage.addEventListener(Event.RENDER,this.delayCallFn,false,0,true);
            stage.invalidate();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.delayCallFn,false,0,true);
         }
      }
      
      public function move(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      override public function set width(param1:Number) : void
      {
         if(this._width == param1)
         {
            return;
         }
         this._width = param1;
         this.delayCall(this.setSize);
         this._resized = true;
      }
      
      protected function setSkin() : void
      {
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         this.delayCall(this.setEnabled);
      }
      
      override public function set height(param1:Number) : void
      {
         if(this._height == param1)
         {
            return;
         }
         this._height = param1;
         this.delayCall(this.setSize);
         this._resized = true;
      }
      
      public function set toolTip(param1:String) : void
      {
         this._toolTip = param1;
      }
      
      protected function init() : void
      {
         this.setSkin();
         this.setSize();
         this.setEnabled();
         this._inited = true;
      }
      
      public function get toolTip() : String
      {
         return this._toolTip;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      private function addedFn(param1:Event) : void
      {
         if(param1.target == this)
         {
            this.removeEventListener(Event.ADDED,this.addedFn);
            this._added = true;
            this.init();
         }
      }
      
      private function delayCallFn(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(param1.type == Event.ADDED_TO_STAGE)
         {
            removeEventListener(Event.ADDED_TO_STAGE,this.delayCallFn);
            stage.addEventListener(Event.RENDER,this.delayCallFn);
            stage.invalidate();
            return;
         }
         param1.currentTarget.removeEventListener(Event.RENDER,this.delayCallFn);
         isRenderCalling = true;
         for(_loc2_ in this.renderCalls)
         {
            _loc2_.apply(null,this.renderCalls[_loc2_]);
            delete this.renderCalls[_loc2_];
         }
         isRenderCalling = false;
      }
      
      protected function setEnabled() : void
      {
      }
   }
}


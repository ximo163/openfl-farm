package com.qzone.allianceActivity.arborDayActivity.view
{
   import com.qzone.allianceActivity.framewrok.utils.TextFieldUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class MovieClipButtonInteraction extends EventDispatcher
   {
      
      private var _enable:Boolean = true;
      
      private var _view:MovieClip;
      
      private var _labelTf:TextField;
      
      public function MovieClipButtonInteraction(param1:MovieClip)
      {
         super(null);
         this._view = param1;
         if(this._view)
         {
            this._labelTf = this._view.labelTf;
            this._labelTf.mouseEnabled = false;
            this._view.buttonMode = true;
            this._view.stop();
            this._view.addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
            this._view.addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            this._view.addEventListener(MouseEvent.CLICK,this.clickHandler);
         }
      }
      
      public function get view() : MovieClip
      {
         return this._view;
      }
      
      private function rollOverHandler(param1:Event) : void
      {
         this._view.gotoAndStop(2);
      }
      
      private function rollOutHandler(param1:Event) : void
      {
         this._view.gotoAndStop(1);
      }
      
      private function clickHandler(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function get label() : String
      {
         if(this._labelTf)
         {
            return this._labelTf.text;
         }
         return "";
      }
      
      public function set label(param1:String) : void
      {
         TextFieldUtil.refreshText(this._labelTf,param1);
      }
      
      public function get enable() : Boolean
      {
         return this._enable;
      }
      
      public function set enable(param1:Boolean) : void
      {
         this._enable = param1;
         this._view.mouseChildren = param1;
         this._view.mouseEnabled = param1;
      }
   }
}


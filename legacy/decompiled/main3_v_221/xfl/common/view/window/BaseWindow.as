package common.view.window
{
   import com.qzone.qui.containers.TitleWindow;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.effects.Move;
   import flash.events.Event;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class BaseWindow extends TitleWindow
   {
      
      private var _mode:Boolean;
      
      protected var m_msgCenter:IMsgCenter;
      
      protected var _recenter:Boolean;
      
      private var _data:Object;
      
      private var _isInit:Boolean;
      
      private var _windowName:String;
      
      public function BaseWindow(param1:IMsgCenter = null)
      {
         super();
         this.m_msgCenter = param1;
         defaultSkin = WindowBg;
         closeButtonSkin = CloseButton;
         showCloseButton = true;
         titleAlign = Align.CENTER;
         titleDefautFormat = new TextFormat("Verdana",16,16777215,true);
         effect = Move;
         this._data = null;
         this._isInit = false;
         this._mode = false;
         this._recenter = false;
         addEventListener(Event.ADDED_TO_STAGE,this.initalize,false,0,true);
      }
      
      public function initalize(param1:Event) : void
      {
         param1.target.removeEventListener(Event.ADDED_TO_STAGE,this.initalize);
         if(super._inited == false)
         {
            super.init();
         }
         if(closeButton != null)
         {
            closeButton.useHandCursor = true;
         }
         if(panelTitle != null)
         {
            panelTitle.y = 3;
         }
         this.addedToLayer();
      }
      
      public function onEffectEnd() : void
      {
         if(this._recenter == true && parent != null)
         {
            x = (parent.width - this.width) * 0.5;
            y = (parent.height - this.height) * 0.5;
            this._recenter = false;
         }
      }
      
      public function get mode() : Boolean
      {
         return this._mode;
      }
      
      public function set mode(param1:Boolean) : void
      {
         this._mode = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      protected function setData() : void
      {
      }
      
      protected function addedToLayer() : void
      {
         this._isInit = true;
      }
      
      public function set windowName(param1:String) : void
      {
         this._windowName = param1;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         this._recenter = false;
         if(this._data != null)
         {
            if(this._data.hasOwnProperty("width") == true || this._data.hasOwnProperty("height") == true)
            {
               this._recenter = true;
            }
         }
         this.setData();
      }
      
      public function get isInit() : Boolean
      {
         return this._isInit;
      }
      
      public function get windowName() : String
      {
         return this._windowName;
      }
   }
}


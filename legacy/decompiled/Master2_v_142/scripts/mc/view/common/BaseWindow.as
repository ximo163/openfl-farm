package mc.view.common
{
   import com.minutes.ui.core.LipiPanel;
   import com.minutes.ui.core.UIEvent;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   
   public class BaseWindow extends LipiPanel
   {
      
      private var _mode:Boolean = false;
      
      private var _data:Object;
      
      private var _windowMode:Sprite;
      
      private var childList:Array;
      
      private var _isInit:Boolean = false;
      
      private var _windowName:String = "";
      
      public function BaseWindow()
      {
         super(new Rectangle(50,50,100,25));
         addEventListener(UIEvent.CLOSE,this._closeButtonClick);
         this.tabChildren = false;
      }
      
      public function addAll() : void
      {
         if(this.childList != null)
         {
            while(this.childList.length > 0)
            {
               addChild(this.childList.shift());
            }
         }
      }
      
      protected function closeHandler() : void
      {
         var _loc1_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc1_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc1_);
      }
      
      public function set isInit(param1:Boolean) : void
      {
         this._isInit = param1;
      }
      
      public function addedToLayer() : void
      {
      }
      
      public function set mode(param1:Boolean) : void
      {
         this._mode = param1;
      }
      
      public function removedFromLayer() : void
      {
      }
      
      public function keyEnter() : void
      {
      }
      
      public function get windowMode() : Sprite
      {
         return this._windowMode;
      }
      
      public function removeAll() : void
      {
         if(this.childList == null)
         {
            this.childList = [];
         }
         while(numChildren > 0)
         {
            this.childList.push(removeChildAt(0));
         }
      }
      
      public function init() : void
      {
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get windowName() : String
      {
         return this._windowName;
      }
      
      public function get isInit() : Boolean
      {
         return this._isInit;
      }
      
      public function get mode() : Boolean
      {
         return this._mode;
      }
      
      public function set windowMode(param1:Sprite) : void
      {
         this._windowMode = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set windowName(param1:String) : void
      {
         this._windowName = param1;
      }
      
      private function _closeButtonClick(param1:UIEvent) : void
      {
         this.closeHandler();
      }
   }
}


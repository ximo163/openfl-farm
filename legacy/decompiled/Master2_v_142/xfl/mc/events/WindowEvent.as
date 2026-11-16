package mc.events
{
   import flash.events.Event;
   import mc.view.common.BaseWindow;
   
   public class WindowEvent extends Event
   {
      
      public static const OPEN:String = "windowOpen";
      
      public static const CLOSE:String = "windowClose";
      
      private var _windowArgument:Object;
      
      private var _window:BaseWindow;
      
      private var _startX:int = 0;
      
      private var _windowName:String = "";
      
      private var _startY:int = 0;
      
      public function WindowEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function set window(param1:BaseWindow) : void
      {
         this._window = param1;
      }
      
      public function set windowArgument(param1:Object) : void
      {
         this._windowArgument = param1;
      }
      
      public function get windowName() : String
      {
         return this._windowName;
      }
      
      public function set windowName(param1:String) : void
      {
         this._windowName = param1;
      }
      
      public function get windowArgument() : Object
      {
         return this._windowArgument;
      }
      
      public function set startY(param1:int) : void
      {
         this._startY = param1;
      }
      
      public function get window() : BaseWindow
      {
         return this._window;
      }
      
      public function get startX() : int
      {
         return this._startX;
      }
      
      public function get startY() : int
      {
         return this._startY;
      }
      
      public function set startX(param1:int) : void
      {
         this._startX = param1;
      }
   }
}


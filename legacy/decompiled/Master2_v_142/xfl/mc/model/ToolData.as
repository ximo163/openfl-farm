package mc.model
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class ToolData extends EventDispatcher
   {
      
      private static var instance:ToolData;
      
      public static var Enemy_TOTAL:String;
      
      public static const WHISTLE_CHANGE:String = "whistle_change";
      
      public static const VIEW_WHISTLE:String = "view_whistle";
      
      private var _viewWhistleData:Object;
      
      private var _mpData:Object;
      
      public var paradeError:String;
      
      private var _whistleData:Object;
      
      public function ToolData()
      {
         super();
      }
      
      public function get whistleDate() : Object
      {
         return this._whistleData;
      }
      
      public function get mpData() : Object
      {
         return this._mpData;
      }
      
      public function set viewWhistleData(param1:Object) : void
      {
         this._viewWhistleData = param1;
         dispatchEvent(new Event(ToolData.VIEW_WHISTLE));
      }
      
      public function get viewWhistleData() : Object
      {
         return this._viewWhistleData;
      }
      
      public function set mpData(param1:Object) : void
      {
         this._mpData = param1;
      }
      
      public function set whistleData(param1:Object) : void
      {
         this._whistleData = param1;
         dispatchEvent(new Event(ToolData.WHISTLE_CHANGE));
      }
   }
}


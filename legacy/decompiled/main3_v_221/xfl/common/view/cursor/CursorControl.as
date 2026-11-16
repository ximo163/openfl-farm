package common.view.cursor
{
   import common.Consts;
   import events.CursorEvent;
   import interfaces.IMsgCenter;
   
   public class CursorControl
   {
      
      private var m_msgCenter:IMsgCenter;
      
      private var m_cursorArgument:String;
      
      private var m_cusrsorLib:Object;
      
      private var m_preName:String;
      
      private var m_name:String;
      
      public function CursorControl(param1:IMsgCenter)
      {
         super();
         this.m_name = this.m_preName = null;
         this.m_msgCenter = param1;
      }
      
      public function getMsgCenter() : IMsgCenter
      {
         return this.m_msgCenter;
      }
      
      public function getClass(param1:String) : Class
      {
         if(param1 == "")
         {
            return null;
         }
         if(this.m_cusrsorLib == null)
         {
            return null;
         }
         return this.m_cusrsorLib[param1];
      }
      
      public function register(param1:String, param2:Class) : void
      {
         if(this.m_cusrsorLib == null)
         {
            this.m_cusrsorLib = new Object();
         }
         this.m_cusrsorLib[param1] = param2;
      }
      
      public function set cursorArgument(param1:String) : void
      {
         this.m_cursorArgument = param1;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set name(param1:String) : void
      {
         this.m_name = param1;
      }
      
      public function get cursorArgument() : String
      {
         return this.m_cursorArgument;
      }
      
      public function useSystem(param1:Boolean = true) : void
      {
         var _loc2_:CursorEvent = new CursorEvent(CursorEvent.SWITCH_CURSOR);
         if(param1 == true)
         {
            _loc2_.cursorName = Consts.CURSOR_SYSTEM;
         }
         else
         {
            _loc2_.cursorName = Consts.CURSOR_CUSTOMIZE;
         }
         this.m_msgCenter.dispatchEvent(_loc2_);
      }
      
      public function setCursor(param1:String, param2:String = "") : void
      {
         if(this.m_name != "")
         {
            this.m_preName = this.m_name;
         }
         this.m_name = param1;
         this.m_cursorArgument = param2;
         var _loc3_:CursorEvent = new CursorEvent(CursorEvent.SET_CURSOR);
         _loc3_.cursorName = param1;
         _loc3_.cursorArgument = this.m_cursorArgument;
         this.m_msgCenter.dispatchEvent(_loc3_);
      }
   }
}


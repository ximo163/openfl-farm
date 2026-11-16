package framework.net.vo
{
   public class ServiceResultVO
   {
      
      public var m_message:String;
      
      public var m_extra:Object;
      
      public var m_result:String;
      
      public function ServiceResultVO()
      {
         super();
         this.m_result = "";
         this.m_message = "";
         this.m_extra = null;
      }
      
      public function toString() : String
      {
         return "[ServiceResultVO]result:" + this.m_result + ", message:" + this.m_message + ", extra:" + this.m_extra;
      }
   }
}


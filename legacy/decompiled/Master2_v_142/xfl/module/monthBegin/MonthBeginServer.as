package module.monthBegin
{
   import mc.FBridge.FRequest;
   
   public class MonthBeginServer
   {
      
      private static var intence:MonthBeginServer;
      
      private var fr:FRequest;
      
      public function MonthBeginServer()
      {
         super();
         this.fr = FRequest.getInstance();
      }
      
      public static function gi() : MonthBeginServer
      {
         if(intence == null)
         {
            intence = new MonthBeginServer();
         }
         return intence;
      }
      
      public function sendRequest(param1:String, param2:Object, param3:Function) : void
      {
         this.fr.postRequest2(param1,param2,param3);
      }
   }
}


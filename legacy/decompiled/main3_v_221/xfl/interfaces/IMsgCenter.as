package interfaces
{
   import flash.events.Event;
   
   public interface IMsgCenter
   {
      
      function dispatchEvent(param1:Event) : void;
      
      function removeEventListener(param1:String, param2:Function) : void;
      
      function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void;
   }
}


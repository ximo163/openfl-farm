package common
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   
   public class CatchError
   {
      
      public function CatchError()
      {
         super();
      }
      
      public static function catchError(param1:Function = null, param2:Loader = null, param3:LoaderInfo = null) : void
      {
         if(param2 != null)
         {
            if(!param2.hasOwnProperty("uncaughtErrorEvents"))
            {
               return;
            }
            param2["uncaughtErrorEvents"].addEventListener("uncaughtError",param1);
         }
         else if(param3 != null)
         {
            if(!param3.hasOwnProperty("uncaughtErrorEvents"))
            {
               return;
            }
            param3["uncaughtErrorEvents"].addEventListener("uncaughtError",param1);
         }
      }
   }
}


package mc.view.main.WindowControl
{
   public class WindowClassLib
   {
      
      private static var _lib:Object;
      
      public function WindowClassLib()
      {
         super();
      }
      
      public static function getClass(param1:String) : Class
      {
         if(_lib == null)
         {
            return null;
         }
         return _lib[param1];
      }
      
      public static function register(param1:String, param2:Class) : void
      {
         if(_lib == null)
         {
            _lib = new Object();
         }
         _lib[param1] = param2;
      }
   }
}


package mc.control
{
   import flash.events.EventDispatcher;
   import mc.view.main.WindowLayer;
   
   public class ViewControl extends EventDispatcher
   {
      
      private static var instance:ViewControl;
      
      public var windowsLayer:WindowLayer;
      
      public function ViewControl()
      {
         if(instance == null)
         {
            super();
            return;
         }
         throw new Error("实例化单例类出错-ViewControl");
      }
      
      public static function getInstance() : ViewControl
      {
         if(instance == null)
         {
            instance = new ViewControl();
         }
         return instance;
      }
   }
}


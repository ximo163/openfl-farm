package mc.view
{
   import cn.snowkit.containers.Pane;
   
   public class WindowsManager
   {
      
      private static var _ins:WindowsManager;
      
      private var _leftPane:Pane;
      
      public function WindowsManager()
      {
         super();
      }
      
      public static function gi() : WindowsManager
      {
         if(_ins == null)
         {
            _ins = new WindowsManager();
         }
         return _ins;
      }
      
      public function set leftPane(param1:Pane) : void
      {
         this._leftPane = param1;
      }
      
      public function get leftPane() : Pane
      {
         return this._leftPane;
      }
   }
}


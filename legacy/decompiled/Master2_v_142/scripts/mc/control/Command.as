package mc.control
{
   import flash.events.EventDispatcher;
   
   public class Command extends EventDispatcher
   {
      
      private static var instance:Command;
      
      private var _tinCmd:TinItemCommand = null;
      
      private var _diyCmd:DiyItemCommand = null;
      
      private var _taskCommand:TaskCommand = null;
      
      private var _mainCommand:MainCommand;
      
      private var _toolCommand:ToolCommand = null;
      
      private var _farmCommand:FarmCommand;
      
      public function Command()
      {
         super();
         if(instance != null)
         {
            throw new Error("实例化单例类出错-Command");
         }
      }
      
      public static function getInstance() : Command
      {
         if(instance == null)
         {
            instance = new Command();
         }
         return instance;
      }
      
      public function get toolCommand() : ToolCommand
      {
         if(this._toolCommand == null)
         {
            this._toolCommand = new ToolCommand();
         }
         return this._toolCommand;
      }
      
      public function get taskCommand() : TaskCommand
      {
         if(this._taskCommand == null)
         {
            this._taskCommand = new TaskCommand();
         }
         return this._taskCommand;
      }
      
      public function get mainCommand() : MainCommand
      {
         if(this._mainCommand == null)
         {
            this._mainCommand = new MainCommand();
         }
         return this._mainCommand;
      }
      
      public function get farmCommand() : FarmCommand
      {
         if(this._farmCommand == null)
         {
            this._farmCommand = new FarmCommand();
         }
         return this._farmCommand;
      }
      
      public function get diyCommand() : DiyItemCommand
      {
         if(this._diyCmd == null)
         {
            this._diyCmd = new DiyItemCommand();
         }
         return this._diyCmd;
      }
      
      public function get tinCommand() : TinItemCommand
      {
         if(this._tinCmd == null)
         {
            this._tinCmd = new TinItemCommand();
         }
         return this._tinCmd;
      }
   }
}


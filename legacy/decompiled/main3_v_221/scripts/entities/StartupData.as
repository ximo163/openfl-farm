package entities
{
   public class StartupData
   {
      
      public static var serverTime:int;
      
      public var _beast:Object;
      
      public var _welcome:Boolean;
      
      public var _task:Task;
      
      public var _decors:Object;
      
      public var _unread:Object;
      
      public var _serverTime:int;
      
      public var _user:Player;
      
      public var upGoldLandTime:int;
      
      public var _weather:Weather;
      
      public var _landStatus:Array;
      
      public var _dog:Dog;
      
      public function StartupData()
      {
         super();
         this._dog = null;
         this._task = null;
         this._user = null;
         this._weather = null;
         this._serverTime = 0;
         this._decors = null;
         this._landStatus = null;
         this._welcome = false;
         this._unread = null;
      }
   }
}


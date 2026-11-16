package entities
{
   import common.misc.Utils;
   
   public final class HealthMode
   {
      
      public var _set:int;
      
      public var _canClose:int;
      
      public var _endTime:int;
      
      public var _time:String;
      
      public var _date:String;
      
      public var _serverTime:int;
      
      public var _beginTime:int;
      
      public var _valid:int;
      
      public function HealthMode(param1:*)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._beginTime = Utils.getIntAttribute(param1,"beginTime");
         this._canClose = Utils.getIntAttribute(param1,"canClose");
         this._endTime = Utils.getIntAttribute(param1,"endTime");
         this._serverTime = Utils.getIntAttribute(param1,"serverTime");
         this._set = Utils.getIntAttribute(param1,"set");
         this._time = Utils.getStrAttribute(param1,"time");
         this._date = Utils.getStrAttribute(param1,"date");
         this._valid = Utils.getIntAttribute(param1,"valid");
      }
   }
}


package framework.net.parsers
{
   import common.misc.Utils;
   import entities.Dog;
   import entities.FarmLand;
   import entities.Player;
   import entities.StartupData;
   import entities.Task;
   import entities.Weather;
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   
   public class StartupDataParser implements ILogicParser
   {
      
      private var _result:ServiceResultVO;
      
      public function StartupDataParser()
      {
         super();
         this._result = new ServiceResultVO();
      }
      
      public function parse(param1:Object) : ServiceResultVO
      {
         var _loc2_:StartupData = null;
         if(param1 == null)
         {
            return null;
         }
         _loc2_ = new StartupData();
         _loc2_._dog = new Dog(param1["dog"]);
         _loc2_._user = new Player(param1["user"]);
         _loc2_._task = new Task(param1["task"]);
         _loc2_._weather = new Weather(param1["weather"]);
         _loc2_._serverTime = Utils.getIntAttribute(param1["serverTime"],"time");
         StartupData.serverTime = _loc2_._serverTime;
         _loc2_._landStatus = this.parseFarmLandStatus(param1["farmlandStatus"]);
         _loc2_._decors = param1["items"];
         _loc2_._welcome = Utils.getIntAttribute(param1,"welcome") > 0 ? true : false;
         _loc2_._unread = this.parseUnRead(param1);
         _loc2_._beast = param1["beast"];
         if(param1.hasOwnProperty("actInfo") && Boolean(param1["actInfo"].hasOwnProperty("goldLandCard")))
         {
            _loc2_.upGoldLandTime = param1["actInfo"]["goldLandCard"];
         }
         this._result.m_extra = _loc2_;
         if(param1["exp"] != undefined)
         {
            _loc2_._user._exp = Utils.getIntAttribute(param1,"exp");
         }
         return this._result;
      }
      
      private function parseFarmLandStatus(param1:Object) : Array
      {
         var _loc2_:Array = new Array();
         _loc2_ = _loc2_.concat(param1);
         var _loc3_:Array = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_.push(new FarmLand(_loc2_[_loc4_]));
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function parseUnRead(param1:Object) : Object
      {
         var _loc3_:int = 0;
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:Object = new Object();
         _loc2_["a"] = param1["a"];
         _loc2_["b"] = param1["b"];
         _loc2_["c"] = param1["c"];
         _loc2_["d"] = param1["d"];
         if(param1["e"] != undefined)
         {
            _loc3_ = parseInt(param1["e"]);
            _loc2_["e"] = _loc3_ >> 3 & 1;
         }
         return _loc2_;
      }
   }
}


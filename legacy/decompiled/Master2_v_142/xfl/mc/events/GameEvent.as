package mc.events
{
   import flash.events.Event;
   
   public class GameEvent extends Event
   {
      
      public static const ADD_MONEY:String = "add_Money";
      
      public static const ADD_EXPERIENCE:String = "add_Experience";
      
      private var _addMoney:int;
      
      private var _addExperience:int;
      
      public function GameEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      public function get addExperience() : int
      {
         return this._addExperience;
      }
      
      public function set addExperience(param1:int) : void
      {
         this._addExperience = param1;
      }
      
      public function set addMoney(param1:Number) : void
      {
         this._addMoney = param1;
      }
      
      public function get addMoney() : Number
      {
         return this._addMoney;
      }
   }
}


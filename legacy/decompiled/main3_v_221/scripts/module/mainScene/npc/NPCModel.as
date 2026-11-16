package module.mainScene.npc
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.Session;
   import entities.Dog;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class NPCModel extends EventDispatcher
   {
      
      public static const EVENT_DOG_LOADED:String = "DogLoaded";
      
      public static const EVENT_DOG_FOOD_LOADED:String = "DogFoodLoaded";
      
      private var m_session:Session;
      
      private var m_dog:Dog;
      
      private var m_dogFood:Object;
      
      private var m_dogFoodLoading:Boolean;
      
      private var m_ownerId:uint;
      
      public function NPCModel()
      {
         super();
         this.m_dog = null;
         this.m_dogFood = null;
         this.m_dogFoodLoading = false;
         this.m_session = Session.getInstance();
      }
      
      private function onRequestFoodStatusSuccess(param1:CommandEvent) : void
      {
         this.m_dogFoodLoading = false;
         var _loc2_:* = NetHelper.getVOData(param1);
         this.m_dogFood = _loc2_;
         if(_loc2_ != null)
         {
            if(_loc2_["hours"] != undefined && parseInt(_loc2_["hours"]) <= 0)
            {
               if(this.m_dog != null)
               {
                  this.m_dog._isHungry = 1;
                  Session.getInstance().m_isDogHungry;
               }
            }
            dispatchEvent(new CommonEvent(EVENT_DOG_FOOD_LOADED,_loc2_));
         }
         EventRecorder.recordSueecssEvent("160888",null);
      }
      
      public function loadDogFoodStatus() : void
      {
         this.m_dogFoodLoading = true;
         NetHelper.sendRequest(CommandDefs.CMD_GET_DOG_FOOD_STATUS,null,this.onRequestFoodStatusSuccess,this.onNetError);
      }
      
      public function get dogHungry() : Boolean
      {
         if(this.m_dog == null)
         {
            return false;
         }
         return this.m_dog._isHungry > 0;
      }
      
      public function setDogData(param1:Dog) : void
      {
         if(this.m_dog == null)
         {
            this.m_dog = param1;
         }
         else
         {
            if(param1._dogId != -1)
            {
               this.m_dog._dogId = param1._dogId;
            }
            this.m_dog._isHungry = param1._isHungry;
         }
         dispatchEvent(new CommonEvent(EVENT_DOG_LOADED,this.m_dog));
      }
      
      public function changeDog(param1:int) : void
      {
         if(this.m_dog == null)
         {
            this.m_dog = new Dog(null);
            this.m_dog._dogId = param1;
            this.m_dog._isHungry = 1;
         }
         else
         {
            this.m_dog._dogId = param1;
         }
         dispatchEvent(new CommonEvent(EVENT_DOG_LOADED,this.m_dog));
         var _loc2_:* = Session.getInstance().sceneDecorates;
         if(_loc2_ != null)
         {
            _loc2_[Consts.DECOR_DOG.toString()] = {"itemId":param1};
         }
      }
      
      public function get selfDogFood() : Object
      {
         return this.m_dogFood;
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         this.m_dogFoodLoading = false;
         EventRecorder.recordErrorEvent("160888",null,4);
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_dogFoodLoading == true)
         {
            this.m_dogFoodLoading = false;
         }
      }
      
      public function get dogID() : int
      {
         if(this.m_dog == null)
         {
            return -1;
         }
         return this.m_dog._dogId;
      }
   }
}


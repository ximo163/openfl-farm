package com.qzone.allianceActivity.missionActivity.model
{
   import com.qzone.allianceActivity.AllianceActivityInfo;
   import com.qzone.allianceActivity.framewrok.cache.DataCenter;
   
   public class MissionActivityDataModel extends DataCenter
   {
      
      public static const CARD_ID:int = 1;
      
      private var _currentStep:int;
      
      public var activityConfig:AllianceActivityInfo;
      
      public var appId:String;
      
      public function MissionActivityDataModel()
      {
         super();
      }
      
      public function get currentStep() : int
      {
         return this._currentStep;
      }
      
      public function getMissionTitle(param1:String) : String
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.activityConfig.source.missionList.i)
         {
            if(param1 == _loc2_.@id)
            {
               return _loc2_.@name;
            }
         }
         return null;
      }
      
      public function set currentStep(param1:int) : void
      {
         this._currentStep = param1;
      }
      
      public function get doneAllMission() : Boolean
      {
         if(this.currentStep > 5)
         {
            return true;
         }
         return false;
      }
      
      public function get currentStepObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_["npcTalk"] = this.getMissionNpcTalk(this._currentStep.toString());
         return _loc1_;
      }
      
      public function getTimeSetting() : String
      {
         return this.activityConfig.source.@timeTxt;
      }
      
      public function getMissionIntro(param1:String) : String
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.activityConfig.source.missionList.i)
         {
            if(param1 == _loc2_.@id)
            {
               return _loc2_.@intro;
            }
         }
         return null;
      }
      
      public function getMissionNpcTalk(param1:String) : String
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.activityConfig.source.missionList.i)
         {
            if(param1 == _loc2_.@id)
            {
               return _loc2_.@npcTalk;
            }
         }
         return null;
      }
      
      public function getItemName(param1:int, param2:int) : String
      {
         var _loc3_:XML = null;
         for each(_loc3_ in this.activityConfig.source.rewards.i)
         {
            if(param1 == _loc3_.@type && param2 == _loc3_.@id)
            {
               return _loc3_.@name;
            }
         }
         return null;
      }
      
      public function getShowBuyCub(param1:int) : Boolean
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.activityConfig.source.missionList.i)
         {
            if(param1 == _loc2_.@id)
            {
               return _loc2_.@showBoyCub == "1";
            }
         }
         return false;
      }
      
      public function getAnimalSeedID(param1:int) : int
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.activityConfig.source.missionList.i)
         {
            if(param1 == _loc2_.@id)
            {
               return _loc2_.@seedID;
            }
         }
         return 0;
      }
   }
}


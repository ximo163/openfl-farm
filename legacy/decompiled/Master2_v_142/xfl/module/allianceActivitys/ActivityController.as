package module.allianceActivitys
{
   import com.qzone.allianceActivity.AllianceActivityController;
   import common.CommonData;
   import flash.display.DisplayObject;
   import mc.view.farm.land.NPContainer;
   import mc.view.proxy.GameProxy;
   import module.allianceActivitys.olympicGames.OlympicGamesActivityHelper;
   import module.allianceActivitys.wildAdventure.WildAdventureHelper;
   import module.missionActivity.MissionActivityHelper;
   
   public class ActivityController extends AllianceActivityController
   {
      
      public function ActivityController()
      {
         super();
      }
      
      protected function addIconToStage(param1:DisplayObject) : void
      {
      }
      
      protected function showMouseTip(param1:DisplayObject, param2:String) : void
      {
         ActivityTipManager.showMouseTip(param1,param2);
      }
      
      protected function addNpcToStage(param1:DisplayObject, param2:Number, param3:Number) : void
      {
         param1.x = param2;
         param1.y = CommonData.root.stage.stageHeight - param3 + 78;
         NPContainer(GameProxy.npcLand).addNPC(param1);
      }
      
      override protected function initActivityHelpers() : void
      {
         super.initActivityHelpers();
         _helperMap["mission"] = new MissionActivityHelper();
         _helperMap["olympicGames"] = new OlympicGamesActivityHelper();
         _helperMap["wildAdvanture"] = new WildAdventureHelper();
      }
      
      protected function showIconBubbleTip(param1:DisplayObject, param2:String) : void
      {
         ActivityTipManager.showBubble(param1,param2,6,26,32);
      }
      
      protected function showNpcBubbleTip(param1:DisplayObject, param2:String) : void
      {
         NpcbubbleManager.showBubble(GameProxy.npcLand,8000,param2,param1.x,param1.y - param1.height);
      }
   }
}


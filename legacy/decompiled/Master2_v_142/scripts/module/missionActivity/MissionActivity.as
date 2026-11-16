package module.missionActivity
{
   import cn.snowkit.containers.Pane;
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.missionActivity.IMissionActivityConetxt;
   import com.qzone.corelib.js.JSProxy;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import flash.events.Event;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.api.AllianceAppHelper;
   import mc.model.MData;
   import mc.model.MainData;
   
   public class MissionActivity
   {
      
      private static var instance:MissionActivity;
      
      private var allianceName:String = "mission";
      
      private var mainData:MainData;
      
      private var missionContext:IMissionActivityConetxt;
      
      private var acManager:AllianceActivityManager;
      
      private var helper:AllianceAppHelper;
      
      private var leftPane:Pane;
      
      private var _timeOutId:uint;
      
      public function MissionActivity()
      {
         this.mainData = MData.getInstance().mainData;
         super();
      }
      
      public static function gi() : MissionActivity
      {
         if(!instance)
         {
            instance = new MissionActivity();
         }
         return instance;
      }
      
      private function activityModuleLoadComplete(param1:Event = null) : void
      {
         clearTimeout(this._timeOutId);
         this.missionContext = this.acManager.getActivityContext(this.allianceName) as IMissionActivityConetxt;
         this.helper = MissionActivityHelper.gi();
         this.missionContext.appHelper = this.helper;
         this.missionContext.start(JSProxy.addGToken(""));
      }
      
      private function loadConfig() : void
      {
         var config:XML;
         var dateTime:Date;
         var load:Function;
         var data:XML = INI.getInstance().data;
         if(data == null)
         {
            return;
         }
         config = INI.getInstance().data.activity_list[0];
         if(config == null)
         {
            return;
         }
         dateTime = new Date();
         this.acManager.initialize(config,CommonData.serverTime * 1000,LocalData.parameters.appImgPrefix);
         if(this.acManager.checkActivityAvaliable(this.allianceName))
         {
            load = function():void
            {
               acManager.loadActivityModule(allianceName).addEventListener(Event.COMPLETE,activityModuleLoadComplete);
            };
            this._timeOutId = setTimeout(load,2500);
         }
      }
      
      public function start() : void
      {
         this.acManager = AllianceActivityManager.getInstance();
         this.loadConfig();
      }
   }
}


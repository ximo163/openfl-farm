package com.qzone.allianceActivity.arborDayActivity.model
{
   import com.qzone.allianceActivity.framewrok.cache.DataCenter;
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.allianceActivity.framewrok.utils.ArrayUtils;
   import flash.utils.Dictionary;
   
   public class ArborDayDataModel extends DataCenter
   {
      
      private var _appId:String = "";
      
      private var _currentScore:int = 0;
      
      private var _scoreRecords:Array = [];
      
      private var _activityConfig:ArborDayActivityConfig;
      
      private var _assetReadyFlags:Dictionary = new Dictionary();
      
      private var _alreadyGetFinalPresent:Boolean = false;
      
      private var _alreadyGetNcPresent:Boolean = false;
      
      private var _alreadyGetMcPresent:Boolean = false;
      
      private var _alreadyGetCtPresent:Boolean = false;
      
      private var _alreadyGetQsPresent:Boolean = false;
      
      private var _appActionEnable:Boolean = true;
      
      public function ArborDayDataModel()
      {
         super();
      }
      
      public function get activityConfig() : ArborDayActivityConfig
      {
         return this._activityConfig;
      }
      
      public function set activityConfig(param1:ArborDayActivityConfig) : void
      {
         this._activityConfig = param1;
         this.dispatchChangeEvent("activityConfig",this._activityConfig);
      }
      
      public function get scoreRecords() : Array
      {
         return this._scoreRecords;
      }
      
      public function set scoreRecords(param1:Array) : void
      {
         if(!ArrayUtils.isSame(this._scoreRecords,param1))
         {
            this._scoreRecords = param1;
            this.dispatchChangeEvent("scoreRecords",this._scoreRecords);
         }
      }
      
      public function get currentScore() : int
      {
         return this._currentScore;
      }
      
      public function set currentScore(param1:int) : void
      {
         if(this._currentScore != param1)
         {
            this._currentScore = param1;
            this.dispatchChangeEvent("currentScore",this._currentScore);
         }
      }
      
      public function get appId() : String
      {
         return this._appId;
      }
      
      public function set appId(param1:String) : void
      {
         this._appId = param1;
      }
      
      public function setAssetReadyFlag(param1:String, param2:Boolean) : void
      {
         this._assetReadyFlags[param1] = param2;
      }
      
      public function isAssetReady(param1:String) : Boolean
      {
         return this._assetReadyFlags[param1];
      }
      
      public function get alreadyGetAllAppPresent() : Boolean
      {
         return this.alreadyGetNcPresent && this.alreadyGetMcPresent && this.alreadyGetCtPresent && this.alreadyGetQsPresent;
      }
      
      public function get alreadyGetNcPresent() : Boolean
      {
         return this._alreadyGetNcPresent;
      }
      
      public function set alreadyGetNcPresent(param1:Boolean) : void
      {
         if(this._alreadyGetNcPresent != param1)
         {
            this._alreadyGetNcPresent = param1;
            this.dispatchChangeEvent("alreadyGetNcPresent",param1);
         }
      }
      
      public function get alreadyGetMcPresent() : Boolean
      {
         return this._alreadyGetMcPresent;
      }
      
      public function set alreadyGetMcPresent(param1:Boolean) : void
      {
         if(this._alreadyGetMcPresent != param1)
         {
            this._alreadyGetMcPresent = param1;
            this.dispatchChangeEvent("alreadyGetMcPresent",param1);
         }
      }
      
      public function get alreadyGetCtPresent() : Boolean
      {
         return this._alreadyGetCtPresent;
      }
      
      public function set alreadyGetCtPresent(param1:Boolean) : void
      {
         if(this._alreadyGetCtPresent != param1)
         {
            this._alreadyGetCtPresent = param1;
            this.dispatchChangeEvent("alreadyGetCtPresent",param1);
         }
      }
      
      public function get alreadyGetQsPresent() : Boolean
      {
         return this._alreadyGetQsPresent;
      }
      
      public function set alreadyGetQsPresent(param1:Boolean) : void
      {
         if(this._alreadyGetQsPresent != param1)
         {
            this._alreadyGetQsPresent = param1;
            this.dispatchChangeEvent("alreadyGetQsPresent",param1);
         }
      }
      
      public function get alreadyGetFinalPresent() : Boolean
      {
         return this._alreadyGetFinalPresent;
      }
      
      public function set alreadyGetFinalPresent(param1:Boolean) : void
      {
         if(this._alreadyGetFinalPresent != param1)
         {
            this._alreadyGetFinalPresent = param1;
            this.dispatchChangeEvent("alreadyGetFinalPresent",param1);
         }
      }
      
      public function reportClick(param1:String) : void
      {
         ClickReportManager.reportClick("f_" + this.appId + "_arborday_" + param1);
      }
      
      public function get appActionEnable() : Boolean
      {
         return this._appActionEnable;
      }
      
      public function set appActionEnable(param1:Boolean) : void
      {
         if(this._appActionEnable != param1)
         {
            this._appActionEnable = param1;
            this.dispatchChangeEvent("appActionEnable",this._appActionEnable);
         }
      }
   }
}


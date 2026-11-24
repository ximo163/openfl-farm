package com.qzone.allianceActivity.arborDayActivity
{
   import com.qzone.allianceActivity.AbstarctAllianceActivityContext;
   import com.qzone.allianceActivity.AllianceActivityInfo;
   import com.qzone.allianceActivity.arborDayActivity.control.BuyPresentCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.ExchangePresentCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.ExecActivityActionCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.GetFinalPresentCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.GetScoreRecordCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.LoadAssetCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.LoadCurrentScoreCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.RedirectToAppCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.RemoveWinCommand;
   import com.qzone.allianceActivity.arborDayActivity.control.ShowWinCommand;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayActivityConfig;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.arborDayActivity.service.ArborDayService;
   import com.qzone.allianceActivity.arborDayActivity.view.ArborDayMediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityConetxt;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.system.Security;
   
   [SWF(width="500", height="375", backgroundColor="#ffffff", frameRate="24")]
   public class ArborDayActivityContext extends AbstarctAllianceActivityContext implements IArborDayActivityConetxt
   {
      
      private var _config:ArborDayActivityConfig;
      
      public function ArborDayActivityContext()
      {
         Security.allowDomain("*.appimg.qq.com");
         Security.allowDomain("*.appimg1.qq.com");
         Security.allowDomain("*.appimg2.qq.com");
         Security.allowDomain("*.appimg3.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg2.qq.com");
         Security.allowDomain("appimg3.qq.com");
         super();
      }
      
      override public function set appHelper(param1:IAllianceAppHelper) : void
      {
         super.appHelper = param1;
         MVCFacade.getInstance().regObj(ArborDayConsts.ARBORDAY_APPHELPER,appHelper);
      }
      
      override public function initialize(param1:AllianceActivityInfo) : void
      {
         this._config = new ArborDayActivityConfig();
         this._config.assets = param1.assets;
         this._config.expireTime = param1.expireTime;
         this._config.id = param1.id;
         this._config.source = param1.source;
         this._config.src = param1.src;
         this._config.startTime = param1.startTime;
         this._config.parserConfigNode();
         this.startTime = this._config.startTime;
         this.expireTime = this._config.expireTime;
         var _loc2_:ArborDayDataModel = new ArborDayDataModel();
         _loc2_.activityConfig = this._config;
         _loc2_.appId = this.appId;
         MVCFacade.getInstance().serviceLocator.addTextService(ArborDayConsts.ARBORDAY_SERVICE,new ArborDayService());
         MVCFacade.getInstance().regObj(ArborDayConsts.ARBORDAY_MODEL,_loc2_);
         MVCFacade.getInstance().regObj(ArborDayConsts.ARBORDAY_MEDIATOR,ArborDayMediator);
         var _loc3_:CommandController = MVCFacade.getInstance().commandController;
         _loc3_.registerCommand(ArborDayConsts.BUY_PRESENT_CMD,BuyPresentCommand);
         _loc3_.registerCommand(ArborDayConsts.EXCHANGE_PRESENT_CMD,ExchangePresentCommand);
         _loc3_.registerCommand(ArborDayConsts.GET_SCORERECORD_CMD,GetScoreRecordCommand);
         _loc3_.registerCommand(ArborDayConsts.LOAD_ASSET_CMD,LoadAssetCommand);
         _loc3_.registerCommand(ArborDayConsts.GET_SCORERECORD_CMD,GetScoreRecordCommand);
         _loc3_.registerCommand(ArborDayConsts.LOAD_CURRENTSCORE_CMD,LoadCurrentScoreCommand);
         _loc3_.registerCommand(ArborDayConsts.REDIRECT_TOAPP_CMD,RedirectToAppCommand);
         _loc3_.registerCommand(ArborDayConsts.REMOVE_WIN_CMD,RemoveWinCommand);
         _loc3_.registerCommand(ArborDayConsts.SHOW_WIN_CMD,ShowWinCommand);
         _loc3_.registerCommand(ArborDayConsts.GET_FINALPRESENT_CMD,GetFinalPresentCommand);
         _loc3_.registerCommand(ArborDayConsts.EXEC_ACTIVITYACTION_CMD,ExecActivityActionCommand);
         ClickReportManager.reportPv();
      }
      
      public function addEntranceIconTo(param1:DisplayObjectContainer) : DisplayObject
      {
         var _loc2_:ArborDayMediator = null;
         if(this.currentTime > this.startTime && this.currentTime < this.expireTime)
         {
            _loc2_ = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
            return _loc2_.addEntranceIconTo(param1);
         }
         return null;
      }
      
      public function updateScore() : void
      {
         var _loc1_:MVCEvent = null;
         if(this.currentTime > this.startTime && this.currentTime < this.expireTime)
         {
            _loc1_ = new MVCEvent(ArborDayConsts.LOAD_CURRENTSCORE_CMD);
            MVCFacade.getInstance().commandController.executeCommand(_loc1_);
         }
      }
      
      public function set appActionBtnEnable(param1:Boolean) : void
      {
         var _loc2_:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
         _loc2_.appActionEnable = param1;
      }
      
      override public function destory() : void
      {
      }
   }
}


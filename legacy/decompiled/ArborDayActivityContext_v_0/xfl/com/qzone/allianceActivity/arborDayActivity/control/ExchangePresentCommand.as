package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.arborDayActivity.view.ArborDayMediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.serialization.Json;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteOperation;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteService;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   
   public class ExchangePresentCommand extends AsyncCommand
   {
      
      public var service:IRemoteService = MVCFacade.getInstance().serviceLocator.getService(ArborDayConsts.ARBORDAY_SERVICE);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function ExchangePresentCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var _loc2_:IRemoteOperation = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         if(this.dataModel.currentScore < this.dataModel.activityConfig.presentBagScore)
         {
            this.mediator.showScoreNotEnoughtWin();
            this.dispatchCompleteEvent();
         }
         else
         {
            _loc2_ = this.service.getOperation("exchangePresent");
            _loc2_.addResponder(this.resultHandler,this.faultHandler);
            _loc3_ = this.appHelper.loginUin;
            _loc4_ = param1.getData("appId");
            _loc5_ = 2;
            _loc2_.invoke([_loc3_,_loc4_,_loc5_]);
         }
      }
      
      private function resultHandler(param1:*) : void
      {
         var _loc3_:MVCEvent = null;
         var _loc2_:Object = Json.decode(param1);
         if(_loc2_.hasOwnProperty("ecode") && _loc2_.ecode == 0 && _loc2_.hasOwnProperty("ret") && _loc2_.ret == 0)
         {
            _loc3_ = new MVCEvent(ArborDayConsts.LOAD_CURRENTSCORE_CMD);
            MVCFacade.getInstance().commandController.executeCommand(_loc3_);
            this.appHelper.updatePage();
            this.appHelper.alert(this.dataModel.activityConfig.exchangeSuccessMsg);
            this.dispatchCompleteEvent();
         }
         else
         {
            this.appHelper.alert(this.dataModel.activityConfig.exchangeFaultMsg);
            this.dispatchErrorEvent();
         }
      }
      
      private function faultHandler(param1:*) : void
      {
         this.appHelper.alert(this.dataModel.activityConfig.exchangeFaultMsg);
         this.dispatchErrorEvent();
      }
   }
}


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
   
   public class ExecActivityActionCommand extends AsyncCommand
   {
      
      public var service:IRemoteService = MVCFacade.getInstance().serviceLocator.getService(ArborDayConsts.ARBORDAY_SERVICE);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function ExecActivityActionCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var _loc3_:IRemoteOperation = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         super.__exec(param1);
         var _loc2_:String = this.dataModel.appId;
         if(_loc2_ == ArborDayConsts.NC_APPID || _loc2_ == ArborDayConsts.MC_APPID)
         {
            _loc3_ = this.service.getOperation("getLoginPresent");
            _loc3_.addResponder(this.resultHandler,this.faultHandler);
            _loc4_ = this.appHelper.loginUin;
            _loc5_ = 2;
            _loc6_ = 0;
            _loc3_.invoke([_loc2_,_loc5_,_loc6_]);
         }
         else
         {
            this.appHelper.execActivityAction();
            this.dispatchCompleteEvent();
         }
      }
      
      private function resultHandler(param1:*) : void
      {
         var _loc2_:Object = Json.decode(param1);
         if(_loc2_.hasOwnProperty("ecode"))
         {
            if(_loc2_.ecode == 0)
            {
               this.appHelper.showBubbleMessage(this.dataModel.activityConfig.getPresentSuccessMsg);
               this.appHelper.execActivityAction();
               this.dataModel.appActionEnable = false;
               this.dispatchCompleteEvent();
               return;
            }
         }
         this.dispatchErrorEvent();
      }
      
      private function faultHandler(param1:*) : void
      {
         this.appHelper.showBubbleMessage(this.dataModel.activityConfig.getPresentFaultMsg);
         this.dispatchErrorEvent();
      }
   }
}


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
   
   public class GetPresentInfoCommand extends AsyncCommand
   {
      
      public var service:IRemoteService = MVCFacade.getInstance().serviceLocator.getService(ArborDayConsts.ARBORDAY_SERVICE);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function GetPresentInfoCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:IRemoteOperation = this.service.getOperation("getPresentInfo");
         _loc2_.addResponder(this.resultHandler,this.faultHandler);
         var _loc3_:String = this.appHelper.loginUin;
         var _loc4_:String = this.dataModel.appId;
         var _loc5_:int = 2;
         var _loc6_:int = 0;
         _loc2_.invoke([_loc4_,_loc5_,_loc6_]);
      }
      
      private function resultHandler(param1:*) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = Json.decode(param1);
         if(_loc2_.hasOwnProperty("ecode") && _loc2_.ecode == 0)
         {
            if(_loc2_.hasOwnProperty("login"))
            {
               _loc3_ = _loc2_.login;
               if(this.dataModel.appId == ArborDayConsts.NC_APPID || this.dataModel.appId == ArborDayConsts.MC_APPID)
               {
                  if(_loc3_.count > 0)
                  {
                     this.dataModel.appActionEnable = true;
                  }
                  else
                  {
                     this.dataModel.appActionEnable = false;
                  }
               }
            }
            this.dispatchCompleteEvent();
         }
         else
         {
            this.dispatchErrorEvent();
         }
      }
      
      private function faultHandler(param1:*) : void
      {
         this.dispatchErrorEvent();
      }
   }
}


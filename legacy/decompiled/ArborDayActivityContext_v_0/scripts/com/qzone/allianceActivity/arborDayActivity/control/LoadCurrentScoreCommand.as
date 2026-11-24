package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.serialization.Json;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteOperation;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteService;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   
   public class LoadCurrentScoreCommand extends AsyncCommand
   {
      
      public var service:IRemoteService = MVCFacade.getInstance().serviceLocator.getService(ArborDayConsts.ARBORDAY_SERVICE);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function LoadCurrentScoreCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:IRemoteOperation = this.service.getOperation("getCurrentScore");
         var _loc3_:String = this.appHelper.loginUin;
         var _loc4_:String = this.dataModel.appId;
         _loc2_.addResponder(this.resultHandler,this.faultHandler);
         _loc2_.invoke([_loc3_,_loc4_]);
      }
      
      public function resultHandler(param1:*) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         _result = Json.decode(param1);
         if(Boolean(_result) && Boolean(_result.hasOwnProperty("ecode")))
         {
            _loc2_ = int(_result.ecode);
            if(_loc2_ == 0)
            {
               _loc3_ = int(_result.is_lost);
               _loc4_ = int(_result.sc);
               _loc5_ = _result.nc_flag;
               _loc6_ = _result.mc_flag;
               _loc7_ = _result.ct_flag;
               _loc8_ = _result.cs_flag;
               this.dataModel.currentScore = _loc4_;
               if(_loc5_ == "0")
               {
                  this.dataModel.alreadyGetNcPresent = false;
               }
               else
               {
                  this.dataModel.alreadyGetNcPresent = true;
               }
               if(_loc6_ == "0")
               {
                  this.dataModel.alreadyGetMcPresent = false;
               }
               else
               {
                  this.dataModel.alreadyGetMcPresent = true;
               }
               if(_loc7_ == "0")
               {
                  this.dataModel.alreadyGetCtPresent = false;
               }
               else
               {
                  this.dataModel.alreadyGetCtPresent = true;
               }
               if(_loc8_ == "0")
               {
                  this.dataModel.alreadyGetQsPresent = false;
               }
               else
               {
                  this.dataModel.alreadyGetQsPresent = true;
               }
               if(_loc5_ == "2" && _loc6_ == "2" && _loc7_ == "2" && _loc8_ == "2")
               {
                  this.dataModel.alreadyGetFinalPresent = true;
               }
               else
               {
                  this.dataModel.alreadyGetFinalPresent = false;
               }
            }
            else
            {
               this.dispatchErrorEvent();
            }
         }
         dispatchCompleteEvent();
      }
      
      public function faultHandler(param1:*) : void
      {
         _error = param1;
         dispatchErrorEvent();
      }
   }
}


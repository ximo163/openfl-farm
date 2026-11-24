package com.qzone.allianceActivity.collectingActivity.control
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.view.Mediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteOperation;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteService;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   
   public class PullHistoryCommand extends AsyncCommand
   {
      
      private var _appHelper:IAllianceAppHelper;
      
      private var _uid:uint;
      
      private var _service:IRemoteService;
      
      private var _dataModel:CollectingModel;
      
      public function PullHistoryCommand()
      {
         super();
         this._service = MVCFacade.getInstance().serviceLocator.getService(CollectingConsts.SERVICE);
         this._dataModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         this._appHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         this._uid = 0;
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:IRemoteOperation = this._service.getOperation("getHistory");
         _loc2_.addResponder(this.resultHandler,this.faultHandler);
         var _loc3_:String = this._dataModel.appId;
         var _loc4_:Array = this._appHelper.execute("10011") as Array;
         var _loc5_:String = this._appHelper.execute("10003") as String;
         this._uid = param1.getData("uId") as uint;
         if(this._uid == 0)
         {
            _loc4_ = _loc4_.concat([_loc5_,_loc5_,8]);
         }
         else
         {
            _loc4_ = _loc4_.concat([this._uid,this._uid,8]);
         }
         _loc2_.invoke(_loc4_);
      }
      
      private function faultHandler(param1:*) : void
      {
         var _loc2_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         _loc2_.fatalError("",false);
         if(this._uid != 0)
         {
            _loc2_.cancelWaiting();
            this._appHelper.execute("reportOZ",{
               "success":false,
               "id":"160828",
               "errorType":0
            });
         }
         else
         {
            this._appHelper.execute("reportOZ",{
               "success":false,
               "id":"160827",
               "errorType":0
            });
         }
         super.dispatchErrorEvent();
      }
      
      private function resultHandler(param1:*) : void
      {
         var _loc3_:Mediator = null;
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(param1);
         if(this._uid == 0)
         {
            this._dataModel.myProducts = _loc2_["repertory"] as Array;
            this._appHelper.execute("reportOZ",{
               "success":true,
               "id":"160827"
            });
         }
         else
         {
            if(_loc2_["repertory"] == undefined)
            {
               _loc3_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
               _loc3_.fatalError("拉取好友比拼成果详情失败，请稍后再试！",false);
               _loc3_.cancelWaiting();
               _loc3_.cancelPK();
               this._appHelper.execute("reportOZ",{
                  "success":false,
                  "id":"160828",
                  "errorType":0
               });
               super.dispatchCompleteEvent();
               return;
            }
            this._dataModel.addFriendProducts(this._uid,_loc2_["repertory"] as Array);
            this._appHelper.execute("reportOZ",{
               "success":true,
               "id":"160828"
            });
         }
         super.dispatchCompleteEvent();
      }
   }
}


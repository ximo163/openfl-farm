package com.qzone.allianceActivity.collectingActivity.control
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.model.FriendData;
   import com.qzone.allianceActivity.collectingActivity.view.Mediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteOperation;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteService;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   
   public class FriendListInit extends AsyncCommand
   {
      
      private var _dataModel:CollectingModel;
      
      private var _appHelper:IAllianceAppHelper;
      
      private var _service:IRemoteService;
      
      public function FriendListInit()
      {
         super();
         this._service = MVCFacade.getInstance().serviceLocator.getService(CollectingConsts.SERVICE);
         this._dataModel = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         this._appHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
      }
      
      private function onFriendListData(param1:*) : void
      {
         var _loc2_:Array = com.adobe.serialization.json.JSON.decode(param1) as Array;
         if(_loc2_ == null || _loc2_.length == 0)
         {
            super.dispatchCompleteEvent();
            return;
         }
         this._dataModel.loadFriendFromSvrData(_loc2_);
         var _loc3_:IRemoteOperation = null;
         var _loc4_:Array = this._appHelper.execute("10011") as Array;
         var _loc5_:String = this._appHelper.execute("10013") as String;
         var _loc6_:Array = this.getFriendUins(_loc5_);
         if(_loc6_ != null)
         {
            _loc3_ = this._service.getOperation("getFriendStatus");
            _loc3_.addResponder(this.resultHandler,this.faultHandler2);
            _loc3_.invoke(_loc4_.concat(2,3,_loc6_[1],_loc6_[0]));
         }
         this._appHelper.execute("reportOZ",{
            "success":true,
            "id":"160829"
         });
      }
      
      private function faultHandler1(param1:*) : void
      {
         var _loc2_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         _loc2_.fatalError();
         this._appHelper.execute("reportOZ",{
            "success":false,
            "id":"160829",
            "errorType":0
         });
         super.dispatchErrorEvent();
      }
      
      private function faultHandler2(param1:*) : void
      {
         this._appHelper.execute("reportOZ",{
            "success":false,
            "id":"160840"
         });
         super.dispatchErrorEvent();
      }
      
      private function resultHandler(param1:*) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Object = com.adobe.serialization.json.JSON.decode(param1);
         this._dataModel.friendsCollection = _loc2_["status"] as Object;
         this._appHelper.execute("reportOZ",{
            "success":true,
            "id":"160840"
         });
         super.dispatchCompleteEvent();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var _loc5_:Array = null;
         super.__exec(param1);
         var _loc2_:Array = this._appHelper.execute("10011") as Array;
         var _loc3_:String = this._appHelper.execute("10013") as String;
         var _loc4_:IRemoteOperation = null;
         if(this._dataModel.loadFriendListFromCache() == true)
         {
            _loc5_ = this.getFriendUins(_loc3_);
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc4_ = this._service.getOperation("getFriendStatus");
               _loc4_.addResponder(this.resultHandler,this.faultHandler2);
               _loc4_.invoke(_loc2_.concat(2,3,_loc5_[1],_loc5_[0]));
            }
         }
         else
         {
            _loc4_ = this._service.getOperation("getFriendList");
            _loc4_.addResponder(this.onFriendListData,this.faultHandler1);
            _loc4_.invoke(_loc2_);
         }
      }
      
      private function getFriendUins(param1:String) : Array
      {
         var _loc7_:FriendData = null;
         var _loc2_:IAllianceAppHelper = MVCFacade.getInstance().getObj(CollectingConsts.APPHELPER) as IAllianceAppHelper;
         var _loc3_:Object = _loc2_.execute("10014");
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = this._dataModel.friendsList;
         if(_loc6_ == null || _loc6_.length == 0)
         {
            return null;
         }
         for each(_loc7_ in _loc6_)
         {
            if(!(_loc7_.me == true || _loc7_.uin == _loc3_["uin"] || _loc7_.uId == _loc3_["_uId"]))
            {
               if(param1 == "qzone")
               {
                  _loc5_.push(_loc7_.uin);
               }
               _loc4_.push(_loc7_.uId || _loc7_.userId);
            }
         }
         return [_loc5_.join(","),_loc4_.join(",")];
      }
   }
}


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
   
   public class PullFriendCollection extends AsyncCommand
   {
      
      private var _dataModel:CollectingModel;
      
      private var _appHelper:IAllianceAppHelper;
      
      private var _service:IRemoteService;
      
      public function PullFriendCollection()
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
            _loc3_.addResponder(this.onFriendStatus,this.faultHandler2);
            _loc3_.invoke(_loc4_.concat(1,3,_loc6_[1],_loc6_[0]));
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
            "id":"160829"
         });
         super.dispatchErrorEvent();
      }
      
      private function faultHandler2(param1:*) : void
      {
         var _loc2_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         _loc2_.fatalError();
         this._appHelper.execute("reportOZ",{
            "success":false,
            "id":"160830",
            "errorType":0
         });
         super.dispatchErrorEvent();
      }
      
      private function getFriendUins(param1:String) : Array
      {
         var _loc5_:FriendData = null;
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Array = this._dataModel.friendsList;
         if(_loc4_ == null || _loc4_.length == 0)
         {
            return null;
         }
         for each(_loc5_ in _loc4_)
         {
            if(param1 == "qzone")
            {
               _loc3_.push(_loc5_.uin);
            }
            _loc2_.push(_loc5_.uId || _loc5_.userId);
         }
         return [_loc3_.join(","),_loc2_.join(",")];
      }
      
      private function onFriendStatus(param1:*) : void
      {
         var _loc4_:String = null;
         super.dispatchCompleteEvent();
         var _loc2_:* = com.adobe.serialization.json.JSON.decode(param1);
         if(_loc2_ == null || _loc2_.hasOwnProperty("status") == false)
         {
            return;
         }
         var _loc3_:Object = _loc2_["status"] as Object;
         for(_loc4_ in _loc3_)
         {
            if(_loc3_[_loc4_] == null)
            {
               delete _loc3_[_loc4_];
            }
            else if(_loc3_[_loc4_] is String)
            {
               _loc3_[_loc4_] = {};
            }
         }
         this._dataModel.friendListStatus = _loc3_;
         this._appHelper.execute("reportOZ",{
            "success":true,
            "id":"160830"
         });
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:IRemoteOperation = null;
         var _loc3_:Array = this._appHelper.execute("10011") as Array;
         var _loc4_:String = this._appHelper.execute("10013") as String;
         var _loc5_:Array = this.getFriendUins(_loc4_);
         if(_loc5_ != null && _loc5_.length > 0)
         {
            _loc2_ = this._service.getOperation("getFriendStatus");
            _loc2_.addResponder(this.onFriendStatus,this.faultHandler2);
            _loc2_.invoke(_loc3_.concat(1,3,_loc5_[1],_loc5_[0]));
         }
         else
         {
            _loc2_ = this._service.getOperation("getFriendList");
            _loc2_.addResponder(this.onFriendListData,this.faultHandler1);
            _loc2_.invoke(_loc3_);
         }
      }
   }
}


package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.serialization.Json;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteOperation;
   import com.qzone.allianceActivity.framewrok.service.rpc.IRemoteService;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   
   public class GetScoreRecordCommand extends AsyncCommand
   {
      
      public var service:IRemoteService = MVCFacade.getInstance().serviceLocator.getService(ArborDayConsts.ARBORDAY_SERVICE);
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function GetScoreRecordCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var _loc2_:IRemoteOperation = this.service.getOperation("getRecords");
         _loc2_.addResponder(this.resultHandler,this.faultHandler);
         var _loc3_:int = 1;
         var _loc4_:int = 300;
         var _loc5_:int = 0;
         var _loc6_:String = this.appHelper.loginUin;
         var _loc7_:String = this.appHelper.loginUin;
         _loc2_.invoke([_loc3_,_loc4_,_loc5_,_loc6_,_loc7_]);
      }
      
      private function resultHandler(param1:*) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:Number = NaN;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:Date = null;
         var _loc11_:Date = null;
         var _loc2_:Object = Json.decode(param1);
         if(_loc2_.ecode == 0)
         {
            _loc3_ = _loc2_.data;
            _loc4_ = new Array();
            if(Boolean(_loc3_) && _loc3_.length > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc3_.length)
               {
                  _loc6_ = _loc3_[_loc5_];
                  _loc7_ = Number(_loc6_.t);
                  _loc9_ = _loc6_.cn;
                  _loc10_ = new Date(_loc7_ * 1000);
                  _loc11_ = new Date(AllianceActivityManager.getInstance().getSevTime());
                  if(_loc10_.getFullYear() == _loc11_.getFullYear() && _loc10_.getMonth() == _loc11_.getMonth() && _loc10_.getDate() == _loc11_.getDate())
                  {
                     _loc8_ = "今天" + this.formatInt(_loc10_.getHours()) + ":" + this.formatInt(_loc10_.getMinutes());
                  }
                  else
                  {
                     _loc8_ = _loc10_.getDate() + "号" + this.formatInt(_loc10_.getHours()) + ":" + this.formatInt(_loc10_.getMinutes());
                  }
                  _loc4_.push(_loc8_ + "  " + _loc9_);
                  _loc5_++;
               }
            }
            this.dataModel.scoreRecords = _loc4_;
            this.dispatchCompleteEvent();
         }
         else
         {
            this.dispatchErrorEvent();
         }
      }
      
      private function formatInt(param1:int) : String
      {
         return param1 > 9 ? String(param1) : "0" + String(param1);
      }
      
      private function faultHandler(param1:*) : void
      {
         this.dispatchErrorEvent();
      }
   }
}


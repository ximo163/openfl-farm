package module.recall
{
   import com.qzone.qfa.events.CommandEvent;
   import common.CommonData;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class RecallModel extends EventDispatcher
   {
      
      public static var uin:uint;
      
      public static var m_backNum:int;
      
      internal static const EVENT_RECALL_DATA_LOADED:String = "RecallDataLoaded";
      
      internal static const EVENT_RECALL_DATA_LOADING:String = "RecallDataLoading";
      
      internal static const EVENT_RECALL_DATA_FAILED:String = "RecallDataFailed";
      
      internal static const EVENT_BACK_SUCCESS:String = "BackSuccess";
      
      internal static const EVENT_BACK_FAIL:String = "BackFail";
      
      public static const BACK_NUM:String = "BackNum";
      
      public const RECALL_ITEM:String = "recallItem";
      
      private var m_backData:Array;
      
      private var m_preBuyToolType:int;
      
      public const REQUEST_NUM:String = "RequestNum";
      
      private var m_backs:Array;
      
      public const REQUEST_ITEM:String = "RequestItem";
      
      private var m_requestPending:Boolean;
      
      public const RECALL_BG:String = "recallBg";
      
      private var m_extraExp:int;
      
      public function RecallModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_backs = null;
         this.m_preBuyToolType = -1;
         this.m_extraExp = 0;
         this.m_requestPending = false;
      }
      
      public function get backs() : Array
      {
         return this.m_backs;
      }
      
      private function recordResp(param1:String, param2:Boolean, param3:String, param4:int = 0) : void
      {
         if(param1 == "")
         {
            return;
         }
         if(param2 == true)
         {
            EventRecorder.recordSueecssEvent(param1,null,param3);
         }
         else if(param4 == 0)
         {
            EventRecorder.recordErrorEvent(param1,null,EventRecorder.FAULT_ERROR,param3);
         }
         else
         {
            EventRecorder.recordErrorEvent(param1,null,param4,param3);
         }
      }
      
      private function onAppGetRequestInfo(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         CommonData.getRequestData = _loc2_;
      }
      
      public function isEmpty(param1:int) : Boolean
      {
         if(param1 == 0)
         {
            return this.m_backs == null || this.m_backs.length == 0 ? true : false;
         }
         return true;
      }
      
      public function loadBackInfo() : void
      {
         var _loc1_:String = null;
         if(this.m_backs != null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_RECALL_DATA_LOADING,{
            "index":0,
            "show":true
         }));
         if(Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus")
         {
            _loc1_ = Session.getInstance().host.uin.toString();
            NetHelper.sendRequest(CommandDefs.CMD_GAME_REQUEST_GET,{
               "owner":_loc1_,
               "appid":353,
               "cb":true
            },this.onGetRequestInfo,this.onLoadDataError);
         }
         else
         {
            _loc1_ = RecallModel.uin.toString();
            NetHelper.sendRequest(CommandDefs.CMD_GAME_REQUEST_GET,{
               "owner":_loc1_,
               "appid":353,
               "cb":true
            },this.onGetRequestInfo,this.onLoadDataError);
         }
      }
      
      public function clear(param1:int) : void
      {
         if(param1 == 0)
         {
            if(this.m_backs != null)
            {
               this.m_backs.splice(0);
            }
            this.m_backs = null;
         }
      }
      
      private function onLoadDataError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["ret"] < 0)
         {
            QzoneJSAPI.reportError(_loc2_["msg"],2);
         }
         var _loc3_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         dispatchEvent(new CommonEvent(EVENT_RECALL_DATA_FAILED,{
            "index":-1,
            "error":_loc3_
         }));
         EventRecorder.recordErrorEvent("160856",null,4);
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_requestPending == true)
         {
            this.m_requestPending = false;
         }
      }
      
      public function set backData(param1:Array) : void
      {
         this.m_backData = param1;
      }
      
      private function onGetRequestInfo(param1:CommandEvent) : void
      {
         dispatchEvent(new CommonEvent(EVENT_RECALL_DATA_LOADING,{
            "index":0,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.requests;
         if(this.m_backs == null)
         {
            this.m_backs = new Array();
         }
         else
         {
            this.m_backs.splice(0);
         }
         this.m_backs = this.m_backs.concat(_loc3_);
         dispatchEvent(new CommonEvent(EVENT_RECALL_DATA_LOADED,_loc3_));
         EventRecorder.recordSueecssEvent("160856",null);
      }
      
      public function get backData() : Array
      {
         return this.m_backData;
      }
   }
}


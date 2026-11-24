package module.FreeGift
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Language;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   
   public class FreeGiftModel extends EventDispatcher
   {
      
      public static var m_backNum:int;
      
      public static var uin:uint;
      
      public static var setGiftToFriendsNum:int;
      
      public static const BACK_NUM:String = "BackNum";
      
      public static const SEND_FREE_GIFT:String = "sendfreegift";
      
      public static const MaxSend:int = 20;
      
      internal static const EVENT_FREE_DATA_LOADED:String = "FreeDataLoaded";
      
      internal static const EVENT_FREE_DATA_LOADING:String = "FreeDataLoading";
      
      internal static const EVENT_FREE_DATA_FAILED:String = "FreeDataFailed";
      
      internal static const EVENT_BACK_SUCCESS:String = "BackSuccess";
      
      internal static const EVENT_BACK_FAIL:String = "BackFail";
      
      private var m_backData:Array;
      
      private var m_preBuyToolType:int;
      
      public const SET_FREE_WIN:String = "setfreeGiftWindow";
      
      public const SET_FREE_ITEM:String = "setfreeGiftItem";
      
      public const FREE_GIFT_ERROR:String = "freegiftError";
      
      private var m_Frees:Array;
      
      public const FREE_BG:String = "freegiftBg";
      
      public const GET_FREE_ITEM:String = "getfreeGiftItem";
      
      private var m_extraExp:int;
      
      public function FreeGiftModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_Frees = null;
         this.m_preBuyToolType = -1;
         this.m_extraExp = 0;
      }
      
      private function onAppGetRequestInfo(param1:CommandEvent) : void
      {
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
      }
      
      public function isEmpty(param1:int) : Boolean
      {
         if(param1 == 0)
         {
            return this.m_Frees == null || this.m_Frees.length == 0 ? true : false;
         }
         return true;
      }
      
      private function onGetCountSuccess(param1:CommandEvent) : void
      {
         dispatchEvent(new CommonEvent(EVENT_FREE_DATA_LOADING,{
            "index":0,
            "show":false
         }));
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_;
         if(this.m_Frees == null)
         {
            this.m_Frees = new Array();
         }
         else
         {
            this.m_Frees.splice(0);
         }
         this.m_Frees = this.m_Frees.concat(_loc3_);
         this.m_Frees.reverse();
         dispatchEvent(new CommonEvent(EVENT_FREE_DATA_LOADED,this.m_Frees));
      }
      
      public function clear(param1:int) : void
      {
         if(param1 == 0)
         {
            if(this.m_Frees != null)
            {
               this.m_Frees.splice(0);
            }
            this.m_Frees = null;
         }
      }
      
      public function get frees() : Array
      {
         return this.m_Frees;
      }
      
      private function onLoadDataError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         dispatchEvent(new CommonEvent(EVENT_FREE_DATA_FAILED,{
            "index":-1,
            "error":_loc3_
         }));
      }
      
      public function set backData(param1:Array) : void
      {
         this.m_backData = param1;
      }
      
      public function get backData() : Array
      {
         return this.m_backData;
      }
      
      public function loadBackInfo() : void
      {
         if(this.m_Frees != null)
         {
            dispatchEvent(new CommonEvent(EVENT_FREE_DATA_LOADED,this.m_Frees));
         }
         else
         {
            dispatchEvent(new CommonEvent(EVENT_FREE_DATA_LOADING,{
               "index":0,
               "show":true
            }));
            NetHelper.sendRequest(CommandDefs.CMD_FREE_LIST,null,this.onGetCountSuccess,this.onLoadDataError);
         }
      }
   }
}


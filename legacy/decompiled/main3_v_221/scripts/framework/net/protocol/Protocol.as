package framework.net.protocol
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.qfa.debug.Debugger;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class Protocol
   {
      
      public static var _userUin:String = "";
      
      private var m_cmdID:uint;
      
      private var m_response:*;
      
      private var m_request:Object;
      
      public function Protocol(param1:uint)
      {
         super();
         this.m_request = null;
         this.m_response = null;
         this.m_cmdID = param1;
      }
      
      public function decodeForHttp() : Object
      {
         var loadStr:String = null;
         var data:Object = null;
         if(this.m_response == null)
         {
            return null;
         }
         loadStr = "";
         try
         {
            data = null;
            loadStr = this.dataToString(this.m_response);
            if(/^[\{\[].*/.test(loadStr) == false)
            {
               loadStr = "{\"errorType\" : \"ReponseError\", \"errorContent\":\"" + loadStr + "\"}";
            }
            data = com.adobe.serialization.json.JSON.decode(loadStr,false);
            return data;
         }
         catch(e:Error)
         {
            Debugger.log("JSON解码错误:" + e + "\n" + loadStr);
         }
         return null;
      }
      
      public function importResponseObject(param1:*) : void
      {
         this.m_response = param1;
      }
      
      public function importRequestObject(param1:Object) : void
      {
         this.m_request = param1;
      }
      
      public function set cmdID(param1:uint) : void
      {
         this.m_cmdID = param1;
      }
      
      public function get cmdID() : uint
      {
         return this.m_cmdID;
      }
      
      private function dataToString(param1:Object) : String
      {
         var _loc2_:ByteArray = null;
         var _loc3_:String = null;
         if(param1 is ByteArray)
         {
            _loc2_ = param1 as ByteArray;
            _loc2_.position = 0;
            return _loc2_.readUTFBytes(_loc2_.length);
         }
         return param1.toString();
      }
      
      public function encodeForHttp(param1:String, param2:String = "text") : URLVariables
      {
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc3_:Session = Session.getInstance();
         var _loc4_:String = "";
         if(CommonData.getKey != null)
         {
            _loc4_ = CommonData.getKey();
         }
         var _loc5_:String = CommonData.serverTime.toString();
         var _loc6_:URLVariables = new URLVariables();
         if(param1 != "" && param1.toUpperCase() == Consts.NET_HTTP_METHOD_POST)
         {
            _loc6_["farmKey"] = _loc4_;
            _loc6_["farmTime"] = _loc5_;
            _loc6_["uIdx"] = _loc3_.hostId;
         }
         if(Settings.getInstance().mode == "qzone" && param1.toUpperCase() == Consts.NET_HTTP_METHOD_POST)
         {
            _loc7_ = _userUin;
            if(_loc7_ != "")
            {
               _loc6_["uinX"] = _loc7_;
            }
            _loc6_["uinY"] = _loc3_.hostUin;
         }
         if(QzoneJSAPI.WB == true)
         {
            _loc6_["platform"] = 3;
         }
         if(this.m_request != null)
         {
            for(_loc8_ in this.m_request)
            {
               _loc6_[_loc8_] = this.m_request[_loc8_];
            }
         }
         return _loc6_;
      }
      
      public function encodeForSocks() : Object
      {
         return null;
      }
   }
}


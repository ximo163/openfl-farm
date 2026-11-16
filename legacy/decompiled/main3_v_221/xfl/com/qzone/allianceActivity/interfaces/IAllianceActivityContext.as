package com.qzone.allianceActivity.interfaces
{
   import com.qzone.allianceActivity.AllianceActivityInfo;
   
   public interface IAllianceActivityContext
   {
      
      function set startTime(param1:Number) : void;
      
      function get currentTime() : Number;
      
      function get activityId() : String;
      
      function get expireTime() : Number;
      
      function get appHelper() : IAllianceAppHelper;
      
      function initialize(param1:AllianceActivityInfo) : void;
      
      function set currentTime(param1:Number) : void;
      
      function set activityId(param1:String) : void;
      
      function execute(param1:String, param2:Object = null) : Object;
      
      function get startTime() : Number;
      
      function set expireTime(param1:Number) : void;
      
      function destory() : void;
      
      function get appId() : String;
      
      function set appHelper(param1:IAllianceAppHelper) : void;
      
      function set appId(param1:String) : void;
   }
}


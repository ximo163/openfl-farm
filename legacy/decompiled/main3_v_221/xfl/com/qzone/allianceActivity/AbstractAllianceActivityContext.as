package com.qzone.allianceActivity
{
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.Sprite;
   import flash.utils.getTimer;
   
   public class AbstractAllianceActivityContext extends Sprite implements IAllianceActivityContext
   {
      
      private var _startTime:Number;
      
      private var _initializeTime:Number;
      
      private var _appId:String;
      
      private var _initializeSevTime:Number;
      
      private var _activityId:String;
      
      private var _expireTime:Number;
      
      private var _appHelper:IAllianceAppHelper;
      
      public function AbstractAllianceActivityContext()
      {
         super();
      }
      
      public function set appHelper(param1:IAllianceAppHelper) : void
      {
         this._appHelper = param1;
      }
      
      public function get activityId() : String
      {
         return this._activityId;
      }
      
      public function get expireTime() : Number
      {
         return this._expireTime;
      }
      
      public function get startTime() : Number
      {
         return this._startTime;
      }
      
      public function set activityId(param1:String) : void
      {
         this._activityId = param1;
      }
      
      public function initialize(param1:AllianceActivityInfo) : void
      {
         throw new Error("虚函数，子类应覆盖");
      }
      
      public function set expireTime(param1:Number) : void
      {
         this._expireTime = param1;
      }
      
      public function get appId() : String
      {
         return this._appId;
      }
      
      public function set currentTime(param1:Number) : void
      {
         this._initializeSevTime = param1;
         this._initializeTime = getTimer();
      }
      
      public function set startTime(param1:Number) : void
      {
         this._startTime = param1;
      }
      
      public function get currentTime() : Number
      {
         return this._initializeSevTime + getTimer() - this._initializeTime;
      }
      
      public function destory() : void
      {
         throw new Error("虚函数，子类应覆盖");
      }
      
      public function get appHelper() : IAllianceAppHelper
      {
         return this._appHelper;
      }
      
      public function execute(param1:String, param2:Object = null) : Object
      {
         return null;
      }
      
      public function set appId(param1:String) : void
      {
         this._appId = param1;
      }
   }
}


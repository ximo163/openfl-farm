package com.qzone.allianceActivity
{
   public class AllianceActivityConfig
   {
      
      private var _activities:Array;
      
      private var _appImgPrefix:String;
      
      private var _appId:String;
      
      public function AllianceActivityConfig(param1:String)
      {
         super();
         this._appImgPrefix = param1;
      }
      
      public function readXML(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:AllianceActivityInfo = null;
         var _loc5_:XMLList = null;
         var _loc6_:XML = null;
         var _loc7_:AllianceActivityAssetInfo = null;
         this._activities = new Array();
         this._appId = param1.@appId;
         var _loc2_:XMLList = param1.activity;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = new AllianceActivityInfo();
            _loc4_.id = _loc3_.@id;
            _loc4_.startTime = this.parseToUnixTime(_loc3_.@start_time);
            _loc4_.expireTime = this.parseToUnixTime(_loc3_.@expire_time);
            _loc4_.src = this.replaceAppImg(_loc3_.@src);
            _loc4_.assets = new Array();
            _loc4_.source = _loc3_;
            _loc5_ = _loc3_.asset;
            for each(_loc6_ in _loc5_)
            {
               _loc7_ = new AllianceActivityAssetInfo();
               _loc7_.id = _loc6_.@id;
               _loc7_.src = this.replaceAppImg(_loc6_.@src);
               _loc4_.assets.push(_loc7_);
            }
            this._activities.push(_loc4_);
         }
      }
      
      public function getActivityIds() : Array
      {
         var _loc2_:AllianceActivityInfo = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this._activities)
         {
            if(_loc2_)
            {
               _loc1_.push(_loc2_.id);
            }
         }
         return _loc1_;
      }
      
      public function parseToUnixTime(param1:String) : Number
      {
         var _loc2_:RegExp = /(\d{4})-(\d{1,2})-(\d{1,2})\s*(\d{1,2}):(\d{1,2})/;
         var _loc3_:Object = _loc2_.exec(param1);
         var _loc4_:int = parseInt(_loc3_[1]);
         var _loc5_:int = Math.max(0,parseInt(_loc3_[2]) - 1);
         var _loc6_:int = parseInt(_loc3_[3]);
         var _loc7_:int = parseInt(_loc3_[4]);
         var _loc8_:int = parseInt(_loc3_[5]);
         var _loc9_:Date = new Date(_loc4_,_loc5_,_loc6_,_loc7_,_loc8_);
         return _loc9_.getTime();
      }
      
      public function getActivityConfigByModuleUrl(param1:String) : AllianceActivityInfo
      {
         var _loc4_:AllianceActivityInfo = null;
         var _loc2_:Array = param1.split("/");
         var _loc3_:String = _loc2_[_loc2_.length - 1];
         for each(_loc4_ in this._activities)
         {
            if(_loc4_)
            {
               if(_loc4_.src == param1 || param1.indexOf(_loc4_.src) >= 0 || _loc4_.src.indexOf(_loc3_) >= 0)
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }
      
      public function getAppId() : String
      {
         return this._appId;
      }
      
      public function getActivityConfig(param1:String) : AllianceActivityInfo
      {
         var _loc2_:AllianceActivityInfo = null;
         for each(_loc2_ in this._activities)
         {
            if(_loc2_)
            {
               if(_loc2_.id == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      public function getActivityAsset(param1:String, param2:String) : AllianceActivityAssetInfo
      {
         var _loc4_:AllianceActivityAssetInfo = null;
         var _loc3_:AllianceActivityInfo = this.getActivityConfig(param1);
         if(_loc3_)
         {
            if(Boolean(_loc3_.assets) && _loc3_.assets.length > 0)
            {
               for each(_loc4_ in _loc3_.assets)
               {
                  if(_loc4_)
                  {
                     if(_loc4_.id == param2)
                     {
                        return _loc4_;
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function get activities() : Array
      {
         return this._activities;
      }
      
      private function replaceAppImg(param1:String) : String
      {
         if(this._appImgPrefix != "" && param1 != "")
         {
            if(param1.indexOf("" + this._appImgPrefix + ".") == 0 || param1.indexOf(this._appImgPrefix + ".") == 0)
            {
               return param1;
            }
            param1 = param1.replace("appimg.",this._appImgPrefix + ".appimg.");
            param1 = param1.replace("appimg1.",this._appImgPrefix + ".appimg1.");
            param1 = param1.replace("appimg3.",this._appImgPrefix + ".appimg3.");
         }
         return param1;
      }
   }
}


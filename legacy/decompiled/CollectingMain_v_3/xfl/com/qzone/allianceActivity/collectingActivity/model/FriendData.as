package com.qzone.allianceActivity.collectingActivity.model
{
   public final class FriendData
   {
      
      public var userId:uint;
      
      public var name:String;
      
      public var index:int;
      
      public var me:Boolean;
      
      public var uin:uint;
      
      public var stars:int;
      
      public var products:Array;
      
      public var lightedCrops:int;
      
      public var uId:uint;
      
      public var photo:String;
      
      public var collectSerials:int;
      
      public var updated:Boolean;
      
      public function FriendData()
      {
         super();
         this.updated = false;
      }
      
      public function importFromSvrData(param1:*) : void
      {
         if(param1 != null && param1 != undefined)
         {
            this.uId = parseInt(param1["uId"]) as uint;
            this.uin = parseInt(param1["uin"]) as uint;
            this.name = param1["userName"];
            this.photo = param1["headPic"];
            if(param1["userId"] != undefined)
            {
               this.userId = parseInt(param1["userId"]) as uint;
               if(this.uId != this.userId)
               {
                  this.uId = this.userId;
               }
            }
         }
      }
      
      public function importFromCache(param1:*) : void
      {
         if(param1 != null && param1 != undefined)
         {
            this.uId = param1["_uId"];
            this.uin = param1["_uin"];
            this.userId = param1["_userId"];
            this.name = param1["_userName"];
            this.photo = param1["_headPic"];
            this.me = param1["me"];
         }
      }
      
      public function set collectStatus(param1:Object) : void
      {
         if(param1 != null)
         {
            if(param1["9"] != undefined)
            {
               this.collectSerials = param1["9"];
            }
            if(param1["10"] != undefined)
            {
               this.stars = param1["10"];
            }
            if(param1["11"] != undefined)
            {
               this.lightedCrops = param1["11"];
            }
         }
      }
      
      public function importFromPlayer(param1:*) : void
      {
         if(param1 != null && param1 != undefined)
         {
            this.uId = parseInt(param1["_uId"]) as uint;
            this.uin = parseInt(param1["uin"]) as uint;
            this.name = param1["_userName"];
            this.photo = param1["_headPic"];
            this.me = param1["me"];
         }
      }
   }
}


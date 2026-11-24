package com.qzone.allianceActivity.arborDayActivity.service
{
   import com.qzone.allianceActivity.framewrok.manager.JSAPI;
   import com.qzone.allianceActivity.framewrok.service.rpc.TextService;
   
   public class ArborDayService extends TextService
   {
      
      public function ArborDayService()
      {
         super();
         var _loc1_:String = "";
         if(JSAPI.isQzone)
         {
            _loc1_ = "";
         }
         else
         {
            _loc1_ = "";
         }
         this.addOperation("getCurrentScore","mync.php?mod=integral_get_totalscore",["uin","appid"],"post");
         this.addOperation("exchangePresent","mync.php?mod=integral_exchange_gift",["uin","appid","packid"],"post");
         var _loc2_:String = "";
         var _loc3_:String = _loc1_ + "mync.php?mod=hydra_feeds_select";
         this.addOperation("getRecords",_loc3_,["appid","feedsnum","isfeeds","uin","opuin"]);
         var _loc4_:String = _loc1_ + "mync.php?mod=gift_send";
         this.addOperation("getLoginPresent",_loc4_,["appid","type","cb"]);
         var _loc5_:String = _loc1_ + "mync.php?mod=gift_info";
         this.addOperation("getPresentInfo",_loc5_,["appid","types","cb"]);
      }
   }
}


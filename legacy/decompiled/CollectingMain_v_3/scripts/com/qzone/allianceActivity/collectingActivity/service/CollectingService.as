package com.qzone.allianceActivity.collectingActivity.service
{
   import com.qzone.allianceActivity.framewrok.service.rpc.TextService;
   
   public class CollectingService extends TextService
   {
      
      public function CollectingService(param1:String)
      {
         super();
         var _loc2_:Array = ["farmKey","farmTime","uIdx","uinX","uinY","platform"];
         this.addOperation("getHistory","" + param1 + "mync.php?mod=chat&act=getAllInfo",_loc2_.concat("uId","ownerId","flag"),"post");
         this.addOperation("getFriendList","" + param1 + "mync.php?mod=friend",_loc2_,"post");
         this.addOperation("getFriendStatus","" + param1 + "mync.php?mod=cgi_farm_getstatus_filter",_loc2_.concat("op","cmd","friend_uids","friend_uins"),"post");
         this.addOperation("getWBProfile","mync.php?mod=cgi_farm_get_userprofile",_loc2_.concat("uids"),"post");
      }
   }
}


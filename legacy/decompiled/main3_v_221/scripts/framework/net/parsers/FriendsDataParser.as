package framework.net.parsers
{
   import entities.Friend;
   import framework.base.BaseArrayParser;
   
   public class FriendsDataParser extends BaseArrayParser
   {
      
      public function FriendsDataParser()
      {
         super();
         super._class = Friend;
      }
   }
}


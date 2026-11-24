package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class RedirectToAppCommand extends AsyncCommand
   {
      
      public function RedirectToAppCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:String = param1.getData("appId");
         var _loc3_:String = "" + _loc2_;
         navigateToURL(new URLRequest(_loc3_),"_blank");
         this.dispatchCompleteEvent();
      }
   }
}


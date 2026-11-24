package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   
   public class BuyPresentCommand extends AsyncCommand
   {
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public function BuyPresentCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         var event:MVCEvent = param1;
         super.__exec(event);
         try
         {
            this.appHelper.payForPresentBag();
         }
         catch(e:Error)
         {
            appHelper.debugLog(e.toString());
            this.dispatchErrorEvent();
         }
         this.dispatchCompleteEvent();
      }
   }
}


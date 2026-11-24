package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.view.ArborDayMediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   import flash.display.DisplayObject;
   
   public class RemoveWinCommand extends AsyncCommand
   {
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public function RemoveWinCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:DisplayObject = param1.getData("win");
         var _loc3_:Boolean = param1.getData("destory");
         this.appHelper.removePopup(_loc2_);
         if(_loc3_)
         {
            this.mediator.removeWinCache(_loc2_);
         }
         this.dispatchCompleteEvent();
      }
   }
}


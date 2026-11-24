package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.view.ArborDayMediator;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   import flash.display.DisplayObject;
   
   public class ShowWinCommand extends AsyncCommand
   {
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      public var mediator:ArborDayMediator = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MEDIATOR);
      
      public function ShowWinCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         var _loc2_:Class = param1.getData("viewClz") as Class;
         var _loc3_:DisplayObject = new _loc2_();
         this.mediator.addWinToCache(_loc3_);
         this.appHelper.popupWindow(_loc3_);
         this.dispatchCompleteEvent();
      }
   }
}


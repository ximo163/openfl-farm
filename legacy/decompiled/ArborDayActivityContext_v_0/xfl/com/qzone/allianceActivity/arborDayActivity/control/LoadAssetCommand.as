package com.qzone.allianceActivity.arborDayActivity.control
{
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayConsts;
   import com.qzone.allianceActivity.arborDayActivity.model.ArborDayDataModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.command.AsyncCommand;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.framewrok.service.DllLoader;
   import com.qzone.allianceActivity.interfaces.arborDay.IArborDayActivityAppHelper;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   public class LoadAssetCommand extends AsyncCommand
   {
      
      public var dataModel:ArborDayDataModel = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_MODEL);
      
      public var appHelper:IArborDayActivityAppHelper = MVCFacade.getInstance().getObj(ArborDayConsts.ARBORDAY_APPHELPER);
      
      private var _moduleLoader:DllLoader;
      
      public var url:String;
      
      public function LoadAssetCommand()
      {
         super();
      }
      
      override protected function __exec(param1:MVCEvent) : void
      {
         super.__exec(param1);
         this.url = param1.getData("url");
         this._moduleLoader = new DllLoader(new LoaderContext(false,ApplicationDomain.currentDomain));
         this._moduleLoader.addEventListener(Event.COMPLETE,this.loadCompleteHandler);
         this._moduleLoader.addEventListener(IOErrorEvent.IO_ERROR,this.loadErrorHandler);
         this._moduleLoader.load(this.url);
         this.appHelper.showLoadingState();
      }
      
      private function loadCompleteHandler(param1:Event) : void
      {
         this.dataModel.setAssetReadyFlag(this.url,true);
         this.appHelper.hideLoadingState();
         this.dispatchCompleteEvent();
      }
      
      private function loadErrorHandler(param1:Event) : void
      {
         this.appHelper.hideLoadingState();
         this.dispatchErrorEvent();
      }
   }
}


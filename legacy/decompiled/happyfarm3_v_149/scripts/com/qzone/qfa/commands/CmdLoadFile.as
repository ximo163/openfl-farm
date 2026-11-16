package com.qzone.qfa.commands
{
   import com.qzone.qfa.core.Command;
   import com.qzone.qfa.debug.Debugger;
   import com.qzone.qfa.events.LoaderEvent;
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.ResourceManager;
   import flash.events.IEventDispatcher;
   import flash.system.ApplicationDomain;
   
   public class CmdLoadFile extends Command
   {
      
      private var _dispatcher:IEventDispatcher;
      
      private var params:Object;
      
      private var _loader:LoadManager;
      
      private var _resManager:ResourceManager;
      
      public function CmdLoadFile()
      {
         super();
      }
      
      private function handleEvents(param1:LoaderEvent) : void
      {
         if(this._dispatcher)
         {
            this._dispatcher.dispatchEvent(param1);
         }
         switch(param1.type)
         {
            case LoaderEvent.COMPLETE:
               this._resManager.addResource(param1.item);
               break;
            case LoaderEvent.QUEUE_COMPLETE:
               finish(this.params);
               break;
            case LoaderEvent.ERROR:
               Debugger.log("[CmdLoadFile]load fail,url:" + param1.item.url);
               error(param1.item);
         }
      }
      
      override public function init() : void
      {
         super.init();
         this._loader = new LoadManager(ApplicationDomain.currentDomain);
         this._resManager = ResourceManager.gi();
         this._loader.addEventListeners(this.handleEvents);
         this.params = {};
      }
      
      override public function execute(param1:* = null) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            param1 = super.body;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_ is String && _loc2_ != "type" && _loc3_ != "")
            {
               Debugger.log("[CmdLoadFile]load " + _loc3_);
               this._loader.add(_loc3_,ApplicationDomain.currentDomain);
            }
            this.params[_loc2_] = _loc3_;
         }
         if(Boolean(param1) && Boolean(param1.dispatcher))
         {
            this._dispatcher = param1.dispatcher as IEventDispatcher;
         }
         this._loader.start();
      }
      
      override public function destroy() : void
      {
         if(this._loader)
         {
            this._loader.removeEventListeners(this.handleEvents);
            this._loader.removeAll();
            this._loader = null;
         }
         this._dispatcher = null;
      }
   }
}


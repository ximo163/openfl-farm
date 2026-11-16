package framework.base
{
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.managers.ResourceManager;
   import common.CommonData;
   import common.Settings;
   import common.misc.Utils;
   import events.CommonEvent;
   import flash.utils.getTimer;
   import interfaces.IModule;
   import module.FarmApplication;
   import report.EventRecorder;
   
   public class Module implements IModule
   {
      
      protected var m_app:FarmApplication;
      
      protected var _loadEvent:CommonEvent;
      
      private var _triggers:Array;
      
      private var _loaded:Boolean;
      
      protected var _downloadTS:Number;
      
      protected var _reportID:String;
      
      protected var m_container:BaseLayer;
      
      private var _loading:Boolean;
      
      public function Module(param1:FarmApplication)
      {
         super();
         this.m_app = param1;
         this.m_container = null;
         this._loaded = false;
      }
      
      public function get container() : BaseLayer
      {
         return this.m_container;
      }
      
      private function onDownloadSuccess(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc2_:Number = getTimer();
         EventRecorder.recordSueecssEvent(this._reportID,_loc2_ - this._downloadTS);
         for each(_loc3_ in this._triggers)
         {
            this.m_app.removeEventListener(_loc3_,this.onLoadModuleFile);
         }
         this._loading = false;
         this._loaded = true;
         this.onModuleLoadSuccess();
         if(this._loadEvent != null)
         {
            this.app.dispatchEvent(new CommonEvent(this._loadEvent.type,this._loadEvent.data));
         }
      }
      
      private function onDownloadFail(param1:Object) : void
      {
         var _loc2_:Number = getTimer();
         if(param1 != null && param1.hasOwnProperty("404") == true)
         {
            EventRecorder.recordErrorEvent(this._reportID,_loc2_ - this._downloadTS,2,null);
         }
         else
         {
            EventRecorder.recordErrorEvent(this._reportID,_loc2_ - this._downloadTS,3,null);
         }
         this._loading = false;
         this._loaded = false;
      }
      
      public function loadLater(param1:Array, param2:BaseLayer) : void
      {
         var _loc3_:String = null;
         if(param1 == null || param1.length == 0)
         {
            this.load(param2);
            return;
         }
         if(this.m_app == null)
         {
            throw new Error("Application\'s not initialized in advance!");
         }
         this._triggers = param1;
         for each(_loc3_ in param1)
         {
            this.m_app.addEventListener(_loc3_,this.onLoadModuleFile,false,0,true);
         }
         this.m_container = param2;
         this._loaded = false;
      }
      
      public function get name() : String
      {
         return "";
      }
      
      protected function onModuleLoadSuccess() : void
      {
      }
      
      private function onLoadModuleFile(param1:CommonEvent) : void
      {
         var res:Resource;
         var st:Settings;
         var url:String;
         var xml:XML = null;
         var e:CommonEvent = param1;
         if(this._loading == true)
         {
            return;
         }
         st = Settings.getInstance();
         res = ResourceManager.gi().getResource(st.getStringAttribute("config_url"));
         if(res == null)
         {
            return;
         }
         xml = Utils.loadXMLData(res.data);
         if(xml == null)
         {
            return;
         }
         url = xml.moduleList.module.(@name == this.name).@url;
         url = st.replaceAppImg(url);
         if(url == null || url == "")
         {
            return;
         }
         CommonData.rslManager.requestFile(url,this.onDownloadSuccess,this.onDownloadFail);
         e.target.removeEventListener(e.type,this.onLoadModuleFile);
         this._loading = true;
         this._loadEvent = e;
         this._downloadTS = getTimer();
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      public function get app() : FarmApplication
      {
         return this.m_app;
      }
      
      public function onNetRequestStopped() : void
      {
      }
      
      public function load(param1:BaseLayer) : void
      {
         if(this._loaded == true)
         {
            return;
         }
         this.m_container = param1;
         this._loaded = true;
      }
      
      public function onGameLoop(param1:Number) : void
      {
      }
      
      public function unload() : void
      {
         this._loaded = false;
      }
   }
}


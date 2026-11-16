package framework.api
{
   import com.qzone.corelib.net.RSLLoader;
   import com.qzone.farm.api.interfaces.IPlugin;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import common.Settings;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   import flash.system.SecurityDomain;
   
   public class PluginProxy implements IPluginProxy
   {
      
      protected var m_plugin:IPlugin;
      
      private var m_loader:RSLLoader;
      
      protected var m_config:Object;
      
      protected var m_loaded:Boolean;
      
      public function PluginProxy()
      {
         super();
         this.m_loader = null;
         this.m_plugin = null;
         this.m_config = null;
         this.m_loaded = false;
      }
      
      public function get config() : Object
      {
         return this.m_config;
      }
      
      protected function onAllLoaded(param1:Event) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:IPlugin = _loc2_.content as IPlugin;
         if(_loc3_ == null)
         {
            return;
         }
         this.m_plugin = _loc3_;
         this.m_loaded = true;
         _loc3_.load(this.m_config["id"] as int,PluginManager.getInstance().api);
         this.m_loader.reset();
      }
      
      public function initialize(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1["url"] == undefined || param1["url"] == "")
         {
            return false;
         }
         this.m_config = param1;
         return true;
      }
      
      public function executeCommand(param1:int, param2:Object) : Object
      {
         return null;
      }
      
      protected function loadResource(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(this.m_loaded == true)
         {
            return;
         }
         if(this.m_loader == null)
         {
            this.m_loader = new RSLLoader();
            this.m_loader.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
            this.m_loader.securityDomain = SecurityDomain.currentDomain;
            this.m_loader.listCompleteFn = this.onAllLoaded;
         }
         param1 = Settings.getInstance().replaceAppImg(param1);
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:Array = [{"url":param1}];
         this.m_loader.load(_loc2_);
      }
   }
}


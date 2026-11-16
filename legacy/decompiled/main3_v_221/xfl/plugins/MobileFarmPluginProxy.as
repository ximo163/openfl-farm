package plugins
{
   import common.CommonData;
   import common.Consts;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import framework.api.PluginProxy;
   
   public class MobileFarmPluginProxy extends PluginProxy
   {
      
      private var _iconContainer:DisplayObjectContainer;
      
      public function MobileFarmPluginProxy()
      {
         super();
      }
      
      override public function initialize(param1:Object) : Boolean
      {
         if(super.initialize(param1) == false)
         {
            return false;
         }
         if(QzoneJSAPI.QPLUS == true)
         {
            return false;
         }
         if(param1["open"] == 0)
         {
            return false;
         }
         var _loc2_:Number = Number(CommonData.serverTime);
         var _loc3_:Date = new Date(_loc2_ * 1000);
         var _loc4_:Date = new Date(param1["time"][0]);
         var _loc5_:Date = new Date(param1["time"][1]);
         if(_loc3_.time >= _loc4_.time && _loc3_.time <= _loc5_.time)
         {
            return true;
         }
         return false;
      }
      
      override public function executeCommand(param1:int, param2:Object) : Object
      {
         switch(param1)
         {
            case Consts.PLUGIN_PROXY_AMOUNT:
               if(param2["type"] == Consts.PLUGIN_AMOUNT_SHORTCUT)
               {
                  this._iconContainer = param2["container"] as DisplayObjectContainer;
                  loadResource(m_config["url"]);
               }
               break;
            case 100:
               return Utils.addPrefix(String(param2));
         }
         return null;
      }
      
      override protected function onAllLoaded(param1:Event) : void
      {
         var _loc2_:* = undefined;
         super.onAllLoaded(param1);
         if(m_plugin != null)
         {
            _loc2_ = {
               "container":this._iconContainer,
               "config":super.config
            };
            m_plugin.createMainUI(_loc2_);
         }
      }
   }
}


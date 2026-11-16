package plugins
{
   import common.CommonData;
   import common.Consts;
   import common.misc.QzoneJSAPI;
   import flash.events.Event;
   import framework.api.PluginProxy;
   
   public class MailPromotionProxy extends PluginProxy
   {
      
      public function MailPromotionProxy()
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
         if(param1["url"] == undefined || param1["url"] == "")
         {
            return false;
         }
         var _loc2_:Number = CommonData.serverTime * 1000;
         var _loc3_:Date = new Date(param1["start"]);
         var _loc4_:Date = new Date(param1["end"]);
         if(_loc2_ < _loc3_.time || _loc2_ > _loc4_.time)
         {
            return false;
         }
         return true;
      }
      
      override protected function onAllLoaded(param1:Event) : void
      {
         var _loc2_:* = undefined;
         super.onAllLoaded(param1);
         if(m_plugin != null)
         {
            _loc2_ = {"config":super.config};
            m_plugin.createMainUI(_loc2_);
         }
      }
      
      override public function executeCommand(param1:int, param2:Object) : Object
      {
         switch(param1)
         {
            case Consts.PLUGIN_PROXY_AMOUNT:
               if(param2["type"] == Consts.PLUGIN_NO_ENTRANCE_ICON)
               {
                  loadResource(m_config["url"]);
               }
         }
         return null;
      }
   }
}


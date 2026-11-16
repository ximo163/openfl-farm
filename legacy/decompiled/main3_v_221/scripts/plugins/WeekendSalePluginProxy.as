package plugins
{
   import common.CommonData;
   import common.Consts;
   import common.misc.QzoneJSAPI;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import framework.api.PluginProxy;
   
   public class WeekendSalePluginProxy extends PluginProxy
   {
      
      private var _iconContainer:DisplayObjectContainer;
      
      public function WeekendSalePluginProxy()
      {
         super();
      }
      
      override public function initialize(param1:Object) : Boolean
      {
         var _loc8_:* = undefined;
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
         if(param1["open"] == 0)
         {
            return false;
         }
         var _loc2_:Array = param1["time"] as Array;
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc3_:Number = Number(CommonData.serverTime);
         var _loc4_:Date = new Date(_loc3_ * 1000);
         var _loc5_:Date = null;
         var _loc6_:Date = null;
         var _loc7_:Boolean = true;
         for each(_loc8_ in _loc2_)
         {
            _loc5_ = new Date(_loc8_["start"]);
            _loc6_ = new Date(_loc8_["end2"]);
            if(_loc4_.time >= _loc5_.time && _loc4_.time <= _loc6_.time)
            {
               _loc7_ = false;
               break;
            }
         }
         if(_loc7_ == true)
         {
            return false;
         }
         return true;
      }
      
      override public function executeCommand(param1:int, param2:Object) : Object
      {
         switch(param1)
         {
            case Consts.PLUGIN_PROXY_AMOUNT:
               if(param2["type"] == Consts.PLUGIN_AMOUNT_SHORTCUT)
               {
                  loadResource(m_config["url"]);
                  this._iconContainer = param2["container"] as DisplayObjectContainer;
               }
               break;
            case 2001:
            case 2002:
               if(super.m_plugin != null)
               {
                  return super.m_plugin.executeCommand(param1,param2);
               }
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


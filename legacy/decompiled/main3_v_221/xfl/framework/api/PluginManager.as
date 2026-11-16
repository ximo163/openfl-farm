package framework.api
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qui.containers.boxClasses.Box;
   import com.qzone.qui.controls.TabBar;
   import common.CommonData;
   import common.Consts;
   import common.misc.QzoneJSAPI;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import plugins.*;
   
   public class PluginManager
   {
      
      private static var _instance:PluginManager;
      
      private var m_pluginStubs:Array;
      
      private var m_api:FarmAPI;
      
      public function PluginManager()
      {
         super();
         this.m_pluginStubs = new Array();
      }
      
      public static function getInstance() : PluginManager
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new PluginManager();
         return _instance;
      }
      
      public function loadPlugins(param1:FarmAPI, param2:Array) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Class = null;
         var _loc5_:IPluginProxy = null;
         this.m_api = param1;
         for each(_loc3_ in param2)
         {
            if(_loc3_["proxy"] != undefined)
            {
               if(!(QzoneJSAPI.WB == true && _loc3_["id"] <= 6))
               {
                  if(CommonData.applicationDomain.hasDefinition(_loc3_["proxy"]) != false)
                  {
                     _loc4_ = CommonData.applicationDomain.getDefinition(_loc3_["proxy"]) as Class;
                     if(_loc4_ != null)
                     {
                        _loc5_ = new _loc4_() as IPluginProxy;
                        if(_loc5_.initialize(_loc3_) == true)
                        {
                           this.m_pluginStubs.push(_loc5_);
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function amountPlugins(param1:int, param2:DisplayObjectContainer, param3:Object) : void
      {
         var _loc7_:TabBar = null;
         var _loc8_:Box = null;
         var _loc9_:int = 0;
         var _loc10_:Sprite = null;
         if(param2 == null)
         {
            return;
         }
         var _loc4_:IPluginProxy = null;
         var _loc5_:Object = null;
         var _loc6_:Sprite = null;
         if(param1 == Consts.PLUGIN_AMOUNT_BG)
         {
            this.buildPluginsInBG(param2);
         }
         else if(param1 == Consts.PLUGIN_AMOUNT_DECORATE)
         {
            _loc7_ = param2 as TabBar;
            if(_loc7_ == null)
            {
               return;
            }
            for each(_loc4_ in this.m_pluginStubs)
            {
               if(_loc4_.config["amount"] != undefined)
               {
                  for each(_loc5_ in _loc4_.config["amount"])
                  {
                     if(_loc5_["type"] as int == Consts.PLUGIN_AMOUNT_DECORATE)
                     {
                        _loc7_.addTab(_loc5_["tab"] as String,param3["width"],param3["height"]);
                        _loc6_ = new Sprite();
                        _loc7_.viewStack.addView(_loc6_);
                        _loc4_.executeCommand(Consts.PLUGIN_PROXY_AMOUNT,{
                           "type":param1,
                           "container":_loc6_,
                           "index":param3["index"]
                        });
                     }
                  }
               }
            }
         }
         else if(param1 == Consts.PLUGIN_AMOUNT_SHORTCUT)
         {
            _loc8_ = param2 as Box;
            if(_loc8_ == null)
            {
               return;
            }
            _loc9_ = 44;
            for each(_loc4_ in this.m_pluginStubs)
            {
               if(_loc4_.config["amount"] != undefined)
               {
                  for each(_loc5_ in _loc4_.config["amount"])
                  {
                     if(_loc5_["type"] as int == Consts.PLUGIN_AMOUNT_SHORTCUT)
                     {
                        _loc6_ = new Sprite();
                        if(_loc5_["width"] != undefined)
                        {
                           _loc9_ = int(_loc5_["width"]);
                        }
                        else
                        {
                           _loc9_ = 48;
                        }
                        _loc10_ = new Sprite();
                        _loc10_.graphics.beginFill(16777215,0);
                        _loc10_.graphics.drawRect(0,0,_loc9_,40);
                        _loc10_.graphics.endFill();
                        _loc6_.addChild(_loc10_);
                        _loc8_.addElement(_loc6_);
                        _loc4_.executeCommand(Consts.PLUGIN_PROXY_AMOUNT,{
                           "type":param1,
                           "container":_loc6_
                        });
                     }
                     else if(_loc5_["type"] as int == Consts.PLUGIN_NO_ENTRANCE_ICON)
                     {
                        _loc4_.executeCommand(Consts.PLUGIN_PROXY_AMOUNT,{"type":Consts.PLUGIN_NO_ENTRANCE_ICON});
                     }
                  }
               }
            }
         }
      }
      
      private function findLayerContainer(param1:DisplayObjectContainer, param2:int) : DisplayObjectContainer
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:String = Consts.SCENE_ZINDEX_BG;
         if(param2 == 0)
         {
            _loc3_ = Consts.SCENE_ZINDEX_BG;
         }
         else if(param2 == 1)
         {
            _loc3_ = Consts.SCENE_ZINDEX_MIDDLE;
         }
         else if(param2 == 2)
         {
            _loc3_ = Consts.SCENE_ZINDEX_LAND;
         }
         else
         {
            if(param2 != 3)
            {
               return null;
            }
            _loc3_ = Consts.SCENE_ZINDEX_FOREGROUND;
         }
         return param1.getChildByName(_loc3_) as DisplayObjectContainer;
      }
      
      public function onTabSwitched(param1:int, param2:int) : void
      {
         var _loc3_:IPluginProxy = null;
         var _loc4_:Object = null;
         for each(_loc3_ in this.m_pluginStubs)
         {
            if(_loc3_.config["amount"] != undefined)
            {
               for each(_loc4_ in _loc3_.config["amount"])
               {
                  if(_loc4_["type"] as int == param1)
                  {
                     _loc3_.executeCommand(Consts.PLUGIN_PROXY_SHOW_MAIN,param2);
                     break;
                  }
               }
            }
         }
      }
      
      public function get api() : IFarmAPI
      {
         return this.m_api as IFarmAPI;
      }
      
      public function getPluginByID(param1:int) : IPluginProxy
      {
         var _loc2_:IPluginProxy = null;
         for each(_loc2_ in this.m_pluginStubs)
         {
            if(_loc2_.config["id"] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function buildPluginsInBG(param1:DisplayObjectContainer) : void
      {
         var _loc7_:DisplayObjectContainer = null;
         var _loc8_:Object = null;
         var _loc9_:Sprite = null;
         var _loc2_:IPluginProxy = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = [];
         for each(_loc2_ in this.m_pluginStubs)
         {
            if(_loc2_.config["amount"] != undefined)
            {
               for each(_loc3_ in _loc2_.config["amount"])
               {
                  if(_loc3_["type"] as int == Consts.PLUGIN_AMOUNT_BG)
                  {
                     _loc4_ = _loc3_["zIndex"] != undefined ? int(parseInt(_loc3_["zIndex"])) : 0;
                     _loc5_ = _loc3_["layer"] != undefined ? int(parseInt(_loc3_["layer"])) : 0;
                     _loc6_.push({
                        "zIndex":_loc4_ + 1000 * _loc5_,
                        "proxy":_loc2_,
                        "config":_loc3_
                     });
                  }
               }
            }
         }
         _loc6_.sortOn("zIndex");
         _loc7_ = null;
         for each(_loc8_ in _loc6_)
         {
            _loc3_ = _loc8_["config"];
            _loc9_ = new Sprite();
            _loc9_.x = parseInt(_loc3_["x"]);
            _loc9_.y = parseInt(_loc3_["y"]);
            _loc5_ = _loc3_["layer"] != undefined ? int(parseInt(_loc3_["layer"])) : 0;
            _loc7_ = this.findLayerContainer(param1,_loc5_);
            if(_loc7_ != null)
            {
               _loc7_.addChild(_loc9_);
               _loc2_ = _loc8_["proxy"];
               _loc2_.executeCommand(Consts.PLUGIN_PROXY_AMOUNT,{
                  "type":Consts.PLUGIN_AMOUNT_BG,
                  "container":_loc9_,
                  "late":false
               });
            }
         }
      }
   }
}


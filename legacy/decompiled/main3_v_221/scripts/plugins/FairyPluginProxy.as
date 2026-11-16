package plugins
{
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import framework.api.PluginProxy;
   
   public class FairyPluginProxy extends PluginProxy
   {
      
      private var _iconContainer:DisplayObjectContainer;
      
      private var _pluginContainer:DisplayObjectContainer;
      
      public function FairyPluginProxy()
      {
         super();
      }
      
      private function addReward(param1:String, param2:int, param3:String, param4:int) : String
      {
         var _loc5_:String = "<b>" + param1 + "被您的诚意打动，赐予您奖励<font color=\"#FF6600\">";
         var _loc6_:Session = Session.getInstance();
         switch(param3)
         {
            case Consts.ITEM_TYPE_EXP:
               _loc6_.updateHostAccount(0,param4,0);
               _loc5_ += param4 + "点经验";
               break;
            case Consts.ITEM_TYPE_MONEY:
               _loc6_.updateHostAccount(param4,0,0);
               _loc5_ += param4 + "个金币";
               break;
            case Consts.ITEM_TYPE_TOOL:
            case Consts.ITEM_TYPE_FISHFEED:
               _loc6_.app.dispatchEvent(new CommonEvent(Consts.DATA_BAG_RELOAD_FLAG,null));
               _loc5_ += param4 + "袋";
               _loc5_ = _loc5_ + GetCropID.getNameByIDType(param3,param2.toString());
               break;
            case Consts.ITEM_TYPE_DOGFOOD:
               _loc5_ += param4 + "天普通狗粮";
               break;
            case Consts.ITEM_TYPE_FAIRY:
               if(param2 == Consts.FAIRY_LADY)
               {
                  _loc5_ += "小仙女";
               }
               else if(param2 == Consts.FAIRY_LAND)
               {
                  _loc5_ += "土地公公";
               }
               else if(param2 == Consts.FAIRY_MONEY)
               {
                  _loc5_ += "财神爷";
               }
               _loc5_ += "一天体验资格";
         }
         return _loc5_ + "</font>，赶快回我的农场使用吧！</b>";
      }
      
      private function addToolIcon() : void
      {
         var _loc1_:Session = Session.getInstance();
         var _loc2_:String = Settings.getInstance().getStringAttribute("fairy");
         if(_loc2_ == "1")
         {
            if(!(_loc1_.host._yellowlevel >= 7 && _loc1_.host._yellowstatus > 0))
            {
               return;
            }
         }
         else if(_loc2_ == "2")
         {
            if(_loc1_.isMeVIP == false)
            {
               return;
            }
         }
         else if(_loc2_ == "3")
         {
            if(!(_loc1_.host._yellowlevel >= 5 && _loc1_.host._yellowstatus > 0))
            {
               return;
            }
         }
         if(this._iconContainer != null && m_plugin != null)
         {
            m_plugin.executeCommand(1000,this._iconContainer);
         }
      }
      
      override public function executeCommand(param1:int, param2:Object) : Object
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc3_:Session = Session.getInstance();
         switch(param1)
         {
            case Consts.PLUGIN_PROXY_AMOUNT:
               if(QzoneJSAPI.QPLUS == true)
               {
                  break;
               }
               _loc4_ = Settings.getInstance().getStringAttribute("fairy");
               if(_loc4_ == "0")
               {
                  break;
               }
               if(param2["type"] == Consts.PLUGIN_AMOUNT_BG)
               {
                  if(m_config == null || m_config["url"] == undefined || m_config["url"] == "")
                  {
                     trace("ERROR> [Fairy proxy] Invalid config object.");
                     return null;
                  }
                  loadResource(m_config["url"]);
                  trace("INFO> [Fairy proxy] Begin loading plugin.");
                  this._pluginContainer = param2["container"] as DisplayObjectContainer;
               }
               else if(param2["type"] == Consts.PLUGIN_AMOUNT_SHORTCUT)
               {
                  this._iconContainer = param2["container"] as DisplayObjectContainer;
                  this.addToolIcon();
               }
               break;
            case 2000:
               if(_loc3_.me == true)
               {
                  if(param2 != null && param2["itemId"] != undefined && param2["lv"] != undefined && param2["rate"] != undefined)
                  {
                     _loc3_.app.model.setData(Consts.MY_FAIRY_OBJECT,param2);
                     if(_loc3_.me == true)
                     {
                        _loc3_.sceneDecorates[Consts.DECOR_FAIRY] = param2;
                     }
                  }
               }
               break;
            case 2001:
               return _loc3_.sceneDecorates[Consts.DECOR_FAIRY];
            case 2002:
               _loc3_.updateHostAccount(param2 as int);
               break;
            case 2003:
               if(param2 != null)
               {
                  return this.addReward(param2["xian"],param2["item"],param2["type"],param2["num"]);
               }
               break;
            case 2004:
               if(param2 != null)
               {
                  _loc5_ = Settings.getInstance().getSecondUrl("Fertilizer");
                  CommonData.rslManager.requestClass(param2["name"],param2["callback"],_loc5_,param2["param"]);
               }
               break;
            case 2005:
               if(param2 != null)
               {
                  return GetCropID.idToToolName(param2.toString());
               }
               break;
            case 2006:
               if(param2 != null)
               {
                  return Settings.getInstance().replaceAppImg(param2 as String);
               }
               break;
            case 2007:
               if(param2 != null)
               {
                  if(param2 == false)
                  {
                     QzoneJSAPI.reportError("小仙形象动画素材加载失败",3);
                  }
               }
               break;
            case 2008:
               _loc3_.app.dispatchEvent(new CommonEvent(Consts.MSG_FAIRY_DONATED,param2 as uint));
               break;
            case 2009:
               _loc3_.app.useSystemCursor(param2 as Boolean);
               break;
            case 2100:
            case 2101:
            case 2102:
            case 2103:
               if(super.m_plugin != null)
               {
                  return super.m_plugin.executeCommand(param1,param2);
               }
         }
         return null;
      }
      
      override protected function onAllLoaded(param1:Event) : void
      {
         super.onAllLoaded(param1);
         var _loc2_:Session = Session.getInstance();
         var _loc3_:Object = _loc2_.sceneDecorates[Consts.DECOR_FAIRY];
         var _loc4_:* = {
            "player":_loc2_.currentUser,
            "fairy":_loc3_,
            "container":this._pluginContainer,
            "config":super.config
         };
         var _loc5_:Sprite = m_plugin.createMainUI(_loc4_);
         if(_loc5_ != null && this._pluginContainer != null)
         {
            while(this._pluginContainer.numChildren > 0)
            {
               this._pluginContainer.removeChildAt(0);
            }
            this._pluginContainer.addChild(_loc5_);
         }
         this.addToolIcon();
      }
   }
}


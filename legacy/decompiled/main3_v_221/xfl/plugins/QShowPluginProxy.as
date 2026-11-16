package plugins
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import framework.api.FarmAPI;
   import framework.api.PluginManager;
   import framework.api.PluginProxy;
   import module.FarmApplication;
   
   public class QShowPluginProxy extends PluginProxy
   {
      
      private var m_avatarID:String;
      
      private var m_pageContaner:DisplayObjectContainer;
      
      private var m_yellowStatus:int;
      
      private var m_avatarContainer:DisplayObjectContainer;
      
      private var m_avatarLoader:Loader;
      
      private var m_yellowLevel:uint;
      
      private var m_qShowPageIndex:int;
      
      private var m_currentUid:uint;
      
      private var m_qShowPage:MovieClip;
      
      private var m_isMe:Boolean;
      
      private var m_currentUin:uint;
      
      public function QShowPluginProxy()
      {
         super();
         this.m_isMe = true;
         this.m_currentUid = 0;
         this.m_currentUin = 0;
         this.m_yellowLevel = 0;
         this.m_yellowStatus = 0;
         this.m_pageContaner = null;
         this.m_qShowPage = null;
         this.m_qShowPageIndex = -1;
         this.m_avatarID = "";
         this.m_avatarLoader = null;
         this.m_avatarContainer = null;
      }
      
      private function showQShowConfigUI(param1:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc2_:IFarmAPI = PluginManager.getInstance().api;
         var _loc3_:FarmApplication = (_loc2_ as FarmAPI).app;
         if(param1 == true)
         {
            if(m_config == null || m_config["amount"] == undefined)
            {
               return;
            }
            _loc4_ = "";
            for each(_loc5_ in m_config["amount"])
            {
               if(_loc5_["tab"] != undefined)
               {
                  _loc4_ = _loc5_["tab"];
                  break;
               }
            }
            _loc3_.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_DIY,{"plugin_tab":_loc4_}));
         }
         else
         {
            _loc3_.closeWindowByName(Consts.WINDOW_NAME_DIY);
         }
      }
      
      private function onUserChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Player = param1.data as Player;
         if(_loc2_ == null)
         {
            return;
         }
         if(this.m_currentUin == _loc2_.uin && this.m_currentUid == _loc2_._uId)
         {
            return;
         }
         this.m_isMe = _loc2_.me;
         this.m_currentUid = _loc2_._uId;
         this.m_currentUin = _loc2_.uin;
         this.m_yellowLevel = _loc2_._yellowlevel;
         this.m_yellowStatus = _loc2_._yellowstatus;
         this.refreshAvatar(true);
      }
      
      private function onAvatarOut(param1:MouseEvent) : void
      {
         var _loc3_:FarmApplication = null;
         var _loc2_:IFarmAPI = PluginManager.getInstance().api;
         if(_loc2_ != null)
         {
            _loc2_.hideMouseTip();
            _loc3_ = (_loc2_ as FarmAPI).app;
            _loc3_.useSystemCursor(false);
         }
      }
      
      override public function initialize(param1:Object) : Boolean
      {
         if(Settings.getInstance().mode == "")
         {
            return false;
         }
         if(super.initialize(param1) == false)
         {
            return false;
         }
         if(param1["url"] == undefined || param1["url"] == "")
         {
            return false;
         }
         var _loc2_:IFarmAPI = PluginManager.getInstance().api;
         var _loc3_:FarmApplication = (_loc2_ as FarmAPI).app;
         _loc3_.addEventListener(Consts.MSG_CURRENT_USER_CHANGED,this.onUserChanged,false,0,true);
         var _loc4_:CommonEvent = new CommonEvent(Consts.MSG_CURRENT_USER_CHANGED,Session.getInstance().currentUser);
         this.onUserChanged(_loc4_);
         return true;
      }
      
      private function onQShowLoadError(param1:ErrorEvent) : void
      {
         trace("ERROR>[QShow proxy] load avatar failed: " + param1.text);
      }
      
      private function refreshAvatar(param1:Boolean) : void
      {
         var _loc2_:Session = null;
         var _loc3_:Object = null;
         var _loc4_:* = undefined;
         var _loc5_:String = null;
         if(CommonData.useExpressUser == true)
         {
            return;
         }
         if(param1 == true)
         {
            _loc2_ = Session.getInstance();
            _loc3_ = _loc2_.sceneDecorates;
            if(_loc3_ == null)
            {
               this.m_avatarID = "";
            }
            else
            {
               _loc4_ = _loc3_[Consts.DECOR_QSHOW.toString()];
               if(_loc4_ == undefined)
               {
                  this.m_avatarID = "";
               }
               else
               {
                  this.m_avatarID = _loc4_["itemId"].toString();
               }
            }
         }
         if(this.m_avatarID == "")
         {
            this.clear();
         }
         else if(this.m_avatarLoader != null)
         {
            this.clear();
            _loc5_ = this.constructAvatarURL();
            if(_loc5_ != null && _loc5_.length > 0)
            {
               this.m_avatarLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onQShowLoadComplete,false,0,true);
               this.m_avatarLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onQShowLoadError,false,0,true);
               this.m_avatarLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onQShowLoadError,false,0,true);
               this.m_avatarLoader.load(new URLRequest(_loc5_),new LoaderContext(true));
            }
            this.m_avatarContainer.mouseChildren = this.m_isMe;
         }
      }
      
      private function onQShowLoadComplete(param1:Event) : void
      {
         var _loc2_:Bitmap = this.m_avatarLoader.content as Bitmap;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:BitmapData = _loc2_.bitmapData;
         var _loc4_:Rectangle = _loc3_.getColorBoundsRect(4278190080,0,false);
         var _loc5_:BitmapData = new BitmapData(_loc4_.width,_loc4_.height);
         _loc5_.copyPixels(_loc3_,_loc4_,new Point(0,0));
         _loc2_.bitmapData = _loc5_;
         _loc2_.smoothing = true;
         if(this.m_avatarContainer != null)
         {
            this.m_avatarContainer.addChild(this.m_avatarLoader);
            this.m_avatarLoader.scaleX = 0.85;
            this.m_avatarLoader.scaleY = 0.85;
            this.m_avatarLoader.x = -this.m_avatarLoader.width / 2;
            this.m_avatarLoader.y = -this.m_avatarLoader.height;
         }
      }
      
      private function onAvatarOver(param1:MouseEvent) : void
      {
         var _loc3_:FarmApplication = null;
         var _loc2_:IFarmAPI = PluginManager.getInstance().api;
         if(_loc2_ != null)
         {
            _loc2_.popMouseTip("点击设置农场形象");
            _loc3_ = (_loc2_ as FarmAPI).app;
            _loc3_.useSystemCursor(true);
         }
      }
      
      private function onAmountView(param1:Object) : void
      {
         var _loc2_:Sprite = null;
         if(param1["type"] == Consts.PLUGIN_AMOUNT_BG)
         {
            if(param1["container"] == null || param1["container"] == undefined || param1["container"] is DisplayObjectContainer == false)
            {
               return;
            }
            if(this.m_avatarLoader == null)
            {
               this.m_avatarLoader = new Loader();
               this.m_avatarLoader.addEventListener(MouseEvent.CLICK,this.onAvatarClick,false,0,true);
               this.m_avatarLoader.addEventListener(MouseEvent.MOUSE_OVER,this.onAvatarOver,false,0,true);
               this.m_avatarLoader.addEventListener(MouseEvent.MOUSE_OUT,this.onAvatarOut,false,0,true);
               this.m_avatarContainer = param1["container"] as DisplayObjectContainer;
               _loc2_ = this.m_avatarContainer as Sprite;
               if(_loc2_ != null)
               {
                  _loc2_.buttonMode = true;
               }
            }
            this.refreshAvatar(true);
         }
         else if(param1["type"] == Consts.PLUGIN_AMOUNT_DECORATE)
         {
            this.m_pageContaner = param1["container"];
            this.m_qShowPageIndex = param1["index"];
         }
      }
      
      private function onAvatarClick(param1:MouseEvent) : void
      {
         this.showQShowConfigUI(true);
      }
      
      override public function executeCommand(param1:int, param2:Object) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Session = null;
         var _loc5_:Object = null;
         switch(param1)
         {
            case Consts.PLUGIN_PROXY_AMOUNT:
               this.onAmountView(param2);
               break;
            case Consts.PLUGIN_PROXY_SHOW_MAIN:
               if(param2 as int != this.m_qShowPageIndex)
               {
                  trace("ERROR> [QShow proxy][CMD_SHOW_MAIN] not my tab index.");
                  return null;
               }
               if(this.m_pageContaner == null)
               {
                  trace("ERROR> [QShow proxy][CMD_SHOW_MAIN] invalid parent container.");
                  return null;
               }
               if(m_config == null || m_config["url"] == undefined || m_config["url"] == "")
               {
                  trace("ERROR> [QShow proxy][CMD_SHOW_MAIN] invalid config object.");
                  return null;
               }
               loadResource(m_config["url"]);
               trace("INFO> [QShow proxy] begin loading plugin.");
               break;
            case 1000:
               this.showQShowConfigUI(param2 as Boolean);
               break;
            case 1001:
               _loc3_ = param2["itemId"] < 0 ? "" : param2["itemId"].toString();
               if(this.m_avatarID == _loc3_)
               {
                  break;
               }
               this.m_avatarID = _loc3_;
               this.refreshAvatar(false);
               if(param2["preview"] == false)
               {
                  _loc4_ = Session.getInstance();
                  _loc5_ = _loc4_.sceneDecorates;
                  if(_loc3_ == "")
                  {
                     delete _loc5_[Consts.DECOR_QSHOW.toString()];
                  }
                  else
                  {
                     _loc5_[Consts.DECOR_QSHOW.toString()] = {"itemId":_loc3_};
                  }
               }
         }
         return null;
      }
      
      private function clear() : void
      {
         if(this.m_avatarLoader != null)
         {
            this.m_avatarLoader.unload();
            if(this.m_avatarContainer != null)
            {
               while(this.m_avatarContainer.numChildren > 0)
               {
                  this.m_avatarContainer.removeChildAt(0);
               }
            }
         }
      }
      
      override protected function onAllLoaded(param1:Event) : void
      {
         super.onAllLoaded(param1);
         if(m_loaded == false)
         {
            return;
         }
         if(param1 == null || param1.target == null)
         {
            return;
         }
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null)
         {
            return;
         }
         trace("INFO> [QShow proxy] plugin loaded successfully.");
         var _loc3_:Session = Session.getInstance();
         var _loc4_:Player = _loc3_.host;
         var _loc5_:* = {
            "uin":_loc3_.hostUin,
            "level":_loc4_.level
         };
         if(_loc3_.sceneDecorates[Consts.DECOR_QSHOW.toString()] != undefined)
         {
            _loc5_["avatar"] = _loc3_.sceneDecorates[Consts.DECOR_QSHOW.toString()]["itemId"];
         }
         this.m_qShowPage = m_plugin.createMainUI(_loc5_) as MovieClip;
         if(this.m_qShowPage == null)
         {
            trace("ERROR> [QShow proxy] plugin loaded, but can not initialize the main UI instance.");
            return;
         }
         this.m_pageContaner.addChild(this.m_qShowPage);
      }
      
      private function constructAvatarURL() : String
      {
         var _loc2_:int = 0;
         var _loc3_:Session = null;
         var _loc4_:String = null;
         var _loc1_:String = "";
         if(isNaN(parseInt(this.m_avatarID)) == false)
         {
            _loc2_ = parseInt(this.m_avatarID);
            if(_loc2_ < 0)
            {
               if(this.m_currentUin != 0)
               {
                  _loc1_ = "http://acfs.tencent.com/" + this.m_currentUin;
               }
               else
               {
                  _loc1_ = "http://acfs.tencent.com/F" + this.m_currentUid;
               }
            }
            else if(_loc2_ == 2)
            {
               _loc3_ = Session.getInstance();
               _loc4_ = _loc3_.me == true ? this.m_currentUin.toString() : _loc3_.currentUser.uin.toString();
               _loc1_ = "" + Math.abs(int(_loc4_) % 4) + ".qlogo.cn/qs_nbg/" + _loc4_ + "/" + _loc4_ + "_qs_nobg/140/" + "?random=" + Math.random();
            }
            else
            {
               _loc1_ = "http://imgcache.qq.com/qqshow_v3/htdocs/syndata/excel_snashot/" + Math.floor(Number(_loc2_) % 1000 / 100) + "/" + Number(_loc2_) % 100 + "/" + _loc2_ + "_0_0.png";
            }
         }
         return _loc1_;
      }
   }
}


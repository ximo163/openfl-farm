package app4.activities.common
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.allianceActivity.advertisement.ADConfig;
   import com.qzone.allianceActivity.advertisement.IAdvertisement;
   import com.qzone.allianceActivity.framewrok.manager.JSAPI;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import module.FarmStage;
   
   public class FarmAdvertisementAPI implements IAdvertisement
   {
      
      private var _farmStage:FarmStage;
      
      public function FarmAdvertisementAPI(param1:FarmStage)
      {
         super();
         this._farmStage = param1;
      }
      
      public function autoPop(param1:ADConfig) : void
      {
         var urlRequest:URLRequest;
         var urlloader:URLLoader;
         var config:ADConfig = param1;
         var st:Settings = Settings.getInstance();
         var mode:String = st.mode;
         var url:String = "" + mode + "mod=cgi_fetch_strategy_rules?";
         url += "g_tk=" + JSAPI.getToken();
         var uv:URLVariables = new URLVariables();
         uv["bitpos"] = config.bitpos;
         this.setVariablers(uv);
         urlloader = this.initUrlLoader(config.autoPopCallBack,config.autoPopCallBack);
         urlRequest = new URLRequest(url);
         urlRequest.method = URLRequestMethod.POST;
         urlRequest.data = uv;
         try
         {
            urlloader.load(urlRequest);
         }
         catch(e:Error)
         {
            trace("request autoPop error");
         }
      }
      
      public function showStrongGuide(param1:DisplayObject, param2:int, param3:int, param4:String, param5:int = 5, param6:Boolean = false) : void
      {
         var onNewIconTimer:Function;
         var hideNewIcon:Function;
         var layer:Sprite = null;
         var _newIcon:Sprite = null;
         var c:DisplayObjectContainer = null;
         var pt:Point = null;
         var timer:Timer = null;
         var target:DisplayObject = param1;
         var posX:int = param2;
         var posY:int = param3;
         var guideString:String = param4;
         var delaySec:int = param5;
         var dynamicPosition:Boolean = param6;
         layer = this._farmStage.getLayerByName(Consts.LAYER_STRONG_GUIDE);
         var iconCls:Class = ApplicationDomain.currentDomain.getDefinition("monthEndArrow") as Class;
         if(iconCls != null)
         {
            c = target.parent;
            if(c)
            {
               onNewIconTimer = function(param1:TimerEvent):void
               {
                  var _loc3_:Point = null;
                  if(_newIcon == null)
                  {
                     return;
                  }
                  var _loc2_:DisplayObjectContainer = target.parent;
                  if(_loc2_)
                  {
                     _loc3_ = new Point(posX,posY);
                     _loc3_ = _loc2_.localToGlobal(_loc3_);
                     _loc3_ = layer.globalToLocal(_loc3_);
                     _newIcon.x = _loc3_.x;
                     _newIcon.y = _loc3_.y;
                  }
               };
               hideNewIcon = function():void
               {
                  if(_newIcon.parent)
                  {
                     _newIcon.parent.removeChild(_newIcon);
                  }
                  if(_newIcon)
                  {
                     _newIcon = null;
                  }
                  if(timer)
                  {
                     timer.stop();
                     timer = null;
                  }
               };
               _newIcon = new iconCls() as Sprite;
               _newIcon["tipMc"]["tip"].text = guideString;
               _newIcon["tipMc"]["tip"].autoSize = TextFieldAutoSize.LEFT;
               _newIcon["tipMc"]["tip"].y = 14;
               pt = new Point(posX,posY);
               pt = c.localToGlobal(pt);
               pt = layer.globalToLocal(pt);
               _newIcon.x = pt.x;
               _newIcon.y = pt.y;
               layer.addChild(_newIcon);
               if(_newIcon is MovieClip)
               {
                  (_newIcon as MovieClip).play();
               }
               if(dynamicPosition)
               {
                  timer = new Timer(delaySec * 1000,10);
               }
               timer.addEventListener(TimerEvent.TIMER,onNewIconTimer,false,0,true);
               timer.start();
               setTimeout(hideNewIcon,delaySec * 1000);
            }
         }
      }
      
      public function grayScale(param1:ADConfig, param2:Function, param3:Function) : void
      {
         var urlRequest:URLRequest;
         var urlloader:URLLoader;
         var config:ADConfig = param1;
         var successFun:Function = param2;
         var failFun:Function = param3;
         var st:Settings = Settings.getInstance();
         var mode:String = st.mode;
         var url:String = "" + mode + "mod=cgi_farm_tree?";
         url += "g_tk=" + JSAPI.getToken();
         var uv:URLVariables = new URLVariables();
         uv["act"] = config.grayScaleParam;
         this.setVariablers(uv);
         urlloader = this.initUrlLoader(successFun,failFun);
         urlRequest = new URLRequest(url);
         urlRequest.method = URLRequestMethod.POST;
         urlRequest.data = uv;
         try
         {
            urlloader.load(urlRequest);
         }
         catch(e:Error)
         {
            trace("request GrayScale error");
         }
      }
      
      public function get serverTime() : Number
      {
         return CommonData.serverTime;
      }
      
      public function whileList(param1:ADConfig, param2:Function, param3:Function) : void
      {
         var urlRequest:URLRequest;
         var urlloader:URLLoader;
         var config:ADConfig = param1;
         var successFun:Function = param2;
         var failFun:Function = param3;
         var st:Settings = Settings.getInstance();
         var mode:String = st.mode;
         var url:String = "" + mode + "mod=cgi_farm_get_bit?";
         url += "g_tk=" + JSAPI.getToken();
         var uv:URLVariables = new URLVariables();
         uv["bit"] = config.whiteListParam;
         this.setVariablers(uv);
         urlloader = this.initUrlLoader(successFun,failFun);
         urlRequest = new URLRequest(url);
         urlRequest.method = URLRequestMethod.POST;
         urlRequest.data = uv;
         try
         {
            urlloader.load(urlRequest);
         }
         catch(e:Error)
         {
            trace("request WhileList error");
         }
      }
      
      private function initUrlLoader(param1:Function, param2:Function) : URLLoader
      {
         var loader:URLLoader = null;
         var onCompleteHandler:Function = null;
         var onFailHandler:Function = null;
         var successFun:Function = param1;
         var failFun:Function = param2;
         onCompleteHandler = function(param1:Event):void
         {
            var jsonData:Object = null;
            var e:Event = param1;
            try
            {
               jsonData = com.adobe.serialization.json.JSON.decode(e.target.data as String);
            }
            catch(e:Error)
            {
               return;
            }
            if(successFun != null)
            {
               successFun(jsonData);
            }
            loader.removeEventListener(Event.COMPLETE,onCompleteHandler);
            loader.removeEventListener(IOErrorEvent.IO_ERROR,onFailHandler);
            loader.close();
            loader = null;
         };
         onFailHandler = function(param1:IOErrorEvent):void
         {
            var jsonData:Object = null;
            var e:IOErrorEvent = param1;
            try
            {
               jsonData = com.adobe.serialization.json.JSON.decode(e.target.data as String);
            }
            catch(e:Error)
            {
               return;
            }
            if(failFun != null)
            {
               failFun(jsonData);
            }
            loader.removeEventListener(Event.COMPLETE,onCompleteHandler);
            loader.removeEventListener(IOErrorEvent.IO_ERROR,onFailHandler);
            loader.close();
            loader = null;
         };
         loader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.TEXT;
         loader.addEventListener(Event.COMPLETE,onCompleteHandler);
         loader.addEventListener(IOErrorEvent.IO_ERROR,onFailHandler);
         return loader;
      }
      
      private function setVariablers(param1:URLVariables) : void
      {
         param1["farmKey"] = CommonData.getKey();
         param1["farmTime"] = CommonData.serverTime.toString();
         param1["uIdx"] = Session.getInstance().hostId;
         if(Settings.getInstance().mode == "qzone")
         {
            param1["uinY"] = Session.getInstance().hostUin;
         }
         if(QzoneJSAPI.WB == true)
         {
            param1["platform"] = 3;
         }
      }
   }
}


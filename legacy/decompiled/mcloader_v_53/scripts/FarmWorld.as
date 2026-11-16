package
{
   import com.adobe.serialization.json.*;
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.corelib.net.RSLLoader;
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.ResourceManager;
   import com.qzone.qfa.managers.events.LoaderEvent;
   import common.CatchError;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import common.MaterialLib;
   import common.view.Loading;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.external.ExternalInterface;
   import flash.filters.GlowFilter;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.control.Version;
   
   [SWF(width="860", height="500", backgroundColor="#ffffff", frameRate="22")]
   public class FarmWorld extends Sprite
   {
      
      private var _resolveUrl:String;
      
      private var currentUrl:String;
      
      private var hasTimeOut:int;
      
      private var _loadStartTime:Number;
      
      private var _flashVars:Dictionary;
      
      private var _error:Boolean = false;
      
      private var loadedInfo:Array;
      
      private var _intURL:String;
      
      private var materialIndex:int = 0;
      
      private var _loader:LoadManager;
      
      private var swfVersion:String;
      
      private var loadingBar:Loading;
      
      private var mainMaterials:Array;
      
      public var loading:Object;
      
      public function FarmWorld()
      {
         var parameters:Object;
         var key:String = null;
         var swfurl:String = null;
         var result:Array = null;
         this.loadedInfo = [];
         super();
         parameters = this.stage.loaderInfo.parameters;
         LocalData.initTime = getTimer();
         LocalData.textGlowFilter = [new GlowFilter(16777215,1,3,3,7)];
         CommonData.rslLoader = new RSLLoader();
         CommonData.applicationDomain = ApplicationDomain.currentDomain;
         CommonData.rslLoader.applicationDomain = ApplicationDomain.currentDomain;
         CommonData.rslLoader.securityDomain = SecurityDomain.currentDomain;
         CommonData.APP_DOMAIN = CommonData.applicationDomain;
         this._flashVars = new Dictionary();
         if(parameters != null)
         {
            LocalData.parameters = parameters;
            for(key in parameters)
            {
               if(key in LocalData)
               {
                  LocalData[key] = parameters[key];
               }
               else
               {
                  this._flashVars[key] = parameters[key];
               }
            }
            JSProxy.addCallBackProxy = function(param1:String, param2:Function):void
            {
               ExternalInterface.addCallback(param1,param2);
            };
            this._resolveUrl = LocalData.parameters.resolve_url || "";
            swfurl = this.stage.loaderInfo.url;
            result = swfurl.match("//(.+).appimg");
            if(result)
            {
               LocalData.parameters.appImgPrefix = result[1] || "";
            }
            this.changeParamters(parameters);
         }
         this.setup();
         this.entry();
      }
      
      private function loadXMLComp(param1:Event) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         INI.getInstance(param1.target.data);
         this.loadingBar = new Loading();
         addChild(this.loadingBar);
         this.mainMaterials = INI.getInstance().getMaterialUrl("main");
         this.mainMaterials.splice(0,0,{
            "url":LocalData.animalConfig,
            "statusText":"动物配置"
         });
         var _loc2_:Object = INI.getInstance().getModuleUrl("main");
         var _loc3_:String = _loc2_["url"] + this.swfVersion;
         if(Boolean(LocalData.parameters.appImgPrefix) && _loc3_.indexOf(".appimg") == -1)
         {
            _loc3_ = _loc3_.replace("appimg.",LocalData.parameters.appImgPrefix + ".appimg.");
         }
         this._loader = new LoadManager();
         this._loader.maxThreadCount = 4;
         this._loader.add(_loc3_);
         for each(_loc4_ in this.mainMaterials)
         {
            _loc5_ = _loc4_.url;
            if(LocalData.parameters.appImgPrefix)
            {
               if(_loc5_.indexOf(LocalData.parameters.appImgPrefix) == -1)
               {
                  _loc5_ = _loc5_.replace("appimg.",LocalData.parameters.appImgPrefix + ".appimg.");
               }
               if(_loc5_.indexOf("appimg1.qq.com") >= 0)
               {
                  if(_loc5_.indexOf("swf?") == -1)
                  {
                     _loc5_ += "?domian=" + LocalData.parameters.appImgPrefix + ".appimg";
                  }
                  else
                  {
                     _loc5_ += "&domian=" + LocalData.parameters.appImgPrefix + ".appimg";
                  }
               }
            }
            this._loader.add(_loc5_);
         }
         this.mainMaterials.splice(0,0,{
            "url":_loc3_,
            "statusText":_loc2_["statusText"]
         });
         this._loader.addEventListener(LoaderEvent.COMPLETE,this.completeHandler);
         this._loader.addEventListener(LoaderEvent.QUEUE_COMPLETE,this.completeHandler);
         this._loader.addEventListener(LoaderEvent.PROGRESS,this.progressHandler);
         this._loader.addEventListener(LoaderEvent.ERROR,this.completeHandler);
         this._loader.start();
         this._loadStartTime = getTimer();
         EventRecorder.recordSueecssEvent(EventRecorder.LOAD_INIT_THINGS,0,"load_start");
         this.loadingBar.showText = this.mainMaterials[this.materialIndex]["statusText"];
         this.loadingBar.materTotal = this.mainMaterials.length;
         this.loadingBar.materIndex = this.materialIndex + 1;
         this.hasTimeOut = setTimeout(this.showTimeoutError,1000 * 30);
      }
      
      private function addCallback() : void
      {
         var _loc1_:String = null;
         if(ExternalInterface.available)
         {
            _loc1_ = JSProxy.getAppParams();
            if(_loc1_)
            {
               LocalData.useExpressUser = true;
               LocalData.expressUser = com.adobe.serialization.json.JSON.decode(_loc1_);
            }
            JSProxy.flashInit();
         }
      }
      
      private function addMain(param1:LoaderEvent) : void
      {
         CatchError.catchError(this.onUncaughtError,null,this.loaderInfo);
         MaterialLib.getInstance().push(param1.item.applicationDomain);
         LocalData.initTime = getTimer() - LocalData.initTime;
         clearTimeout(this.hasTimeOut);
         LocalData.parameters["loadedInfo"] = this.loadedInfo;
         var _loc2_:* = ResourceManager.gi().getClassInstance("module.Master2");
         _loc2_.init();
         addChild(_loc2_);
         removeChild(this.loadingBar);
         this.loadingBar = null;
      }
      
      private function showTimeoutError() : void
      {
         this.loadingBar.errorText = "由于网络加载太慢或中断，<a href=\'" + this._resolveUrl + "\' target=\'_self\'><u><font color=\'#ff6600\'>点击此处</font></u></a>进入空间小诊所解决。";
      }
      
      private function completeHandler(param1:LoaderEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         if(Boolean(param1) && Boolean(param1.hasOwnProperty("item")) && param1.item.hasOwnProperty("url"))
         {
            _loc2_ = param1.item.url;
         }
         CatchError.catchError(this.onUncaughtError,null,param1.item.loaderInfo);
         if(param1.type == LoaderEvent.COMPLETE)
         {
            EventRecorder.recordSueecssEvent(EventRecorder.LOAD_INIT_THINGS,getTimer() - this._loadStartTime,_loc2_);
            if(param1.item.type == "tXML")
            {
               _loc3_ = XML(param1.item.data);
               INI.getInstance().data.appendChild(_loc3_.elements());
               trace("animals 合并后节点数：",INI.getInstance().data.elements("animals").length());
               this.loadedInfo.push(param1.item.url + ":" + param1.item.bytesTotal);
            }
            else
            {
               MaterialLib.getInstance().push(param1.item.applicationDomain);
               this.loadedInfo.push(param1.item.loaderInfo.url + ":" + param1.item.loaderInfo.bytesTotal);
            }
            if(this.materialIndex < this.mainMaterials.length - 1)
            {
               ++this.materialIndex;
            }
            CatchError.catchError(this.onUncaughtError,null,this.loadingBar.loaderInfo);
            this.loadingBar.materIndex = this.materialIndex + 1;
            this.loadingBar.showText = this.mainMaterials[this.materialIndex]["statusText"];
         }
         else if(param1.type == LoaderEvent.QUEUE_COMPLETE)
         {
            EventRecorder.recordSueecssEvent(EventRecorder.LOAD_INIT_THINGS,getTimer() - this._loadStartTime,"allDone");
            this._loader.removeEventListener(LoaderEvent.COMPLETE,this.completeHandler);
            this._loader.removeEventListener(LoaderEvent.QUEUE_COMPLETE,this.completeHandler);
            this._loader.removeEventListener(LoaderEvent.PROGRESS,this.progressHandler);
            this._loader.removeEventListener(LoaderEvent.ERROR,this.completeHandler);
            clearTimeout(this.hasTimeOut);
            this.addMain(param1);
         }
         else if(param1.type == LoaderEvent.ERROR)
         {
            EventRecorder.recordErrorEvent(EventRecorder.LOAD_INIT_THINGS,getTimer() - this._loadStartTime,EventRecorder.FAULT_ERROR,_loc2_);
            this.loadIOError();
            trace("msg:" + param1.msg);
         }
      }
      
      private function loadIniXML() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(IOErrorEvent.IO_ERROR,this.myLoaderIoError);
         _loc1_.addEventListener(Event.COMPLETE,this.loadXMLComp);
         _loc1_.load(new URLRequest(this._intURL));
      }
      
      private function onUncaughtError(param1:*) : void
      {
         param1.preventDefault();
      }
      
      private function loadIOError(param1:IOErrorEvent = null) : void
      {
         this._error = true;
         this.loadingBar.errorText = "文件加载出错，<a href=\'" + this._resolveUrl + "\' target=\'_self\'><u><font color=\'#ff6600\'>点击此处</font></u></a>进入空间小诊所解决。";
      }
      
      private function progressHandler(param1:LoaderEvent) : void
      {
         this.loadingBar.percent = int(param1.percentQueue);
      }
      
      private function myLoaderIoError(param1:IOErrorEvent) : void
      {
         var _loc2_:TextField = new TextField();
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.defaultTextFormat = new TextFormat("Verdana",30);
         _loc2_.text = "Load \"ini.xml\" ERROR";
         _loc2_.x = (stage.stageWidth - _loc2_.width) / 2;
         _loc2_.y = (stage.stageHeight - _loc2_.height) / 2;
         addChild(_loc2_);
      }
      
      private function changeParamters(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         if(LocalData.mode == "1")
         {
            LocalData.mode = Version.QZONE;
            LocalData.animalConfig = this._flashVars["animalConfig_url_qz"];
            LocalData.cardMaterialConfig = this._flashVars["cardConfig_url_qz"];
            this._intURL = this._flashVars["config_url_qz"];
            _loc2_ = "_qz";
         }
         else
         {
            LocalData.mode = Version.;
            LocalData.animalConfig = this._flashVars["animalConfig_url_xy"];
            LocalData.cardMaterialConfig = this._flashVars["cardConfig_url_xy"];
            this._intURL = this._flashVars["config_url_xy"];
            _loc2_ = "_xy";
         }
         for(_loc3_ in param1)
         {
            _loc4_ = _loc3_.substr(_loc3_.length - 3,3);
            if(_loc4_ == _loc2_)
            {
               _loc5_ = _loc3_.substr(0,_loc3_.length - 3);
               param1[_loc5_] = param1[_loc3_];
            }
         }
      }
      
      private function entry() : void
      {
         this.mainMaterials = [];
         this.swfVersion = "";
         this.loadIniXML();
      }
      
      private function setup() : void
      {
         CommonData.getKey = function getKey():String
         {
            return this.name;
         };
         LocalData.YD_SHEET.parseCSS(LocalData.CSS_A_HOVER);
         LocalData.AD_SHEET.parseCSS(LocalData.CSS_A_HOVER_AD);
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         Security.allowDomain("*");
         Security.allowDomain("happyfarm.qzone.qq.com");
         Security.allowDomain("happyfarm.xiaoyou.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain(loaderInfo.parameters.domian + ".qq.com");
         Security.allowDomain("hydra.qzone.qq.com");
         Security.allowDomain("hydra.t.qq.com");
         Security.allowDomain("hydra.qplus.qq.com");
         Security.allowDomain("hydra.pengyou.qq.com");
         stage.showDefaultContextMenu = false;
         setTimeout(this.addCallback,100);
      }
   }
}


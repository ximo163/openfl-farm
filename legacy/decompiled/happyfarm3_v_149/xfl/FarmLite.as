package
{
   import com.adobe.serialization.json.JSON;
   import com.qzone.qfa.commands.CmdHttpRequest;
   import com.qzone.qfa.commands.CmdLoadFile;
   import com.qzone.qfa.data.Resource;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qfa.events.QFAEvent;
   import com.qzone.qfa.managers.CommandManager;
   import com.qzone.qfa.managers.ResourceManager;
   import common.CommonData;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.net.sendToURL;
   import flash.system.ApplicationDomain;
   import flash.system.Security;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.clearTimeout;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import module.lite.FarmLiteModel;
   import module.lite.FarmLiteView;
   import report.EventRecorder;
   
   [SWF(width="860", height="500", backgroundColor="#ffffff", frameRate="24")]
   public class FarmLite extends Sprite
   {
      
      private var _indexTime:int;
      
      private var _settings:Settings;
      
      private var _text:TextField;
      
      private var _stepTime1:int;
      
      private var _stepTime2:int;
      
      private var _bootData:Object;
      
      private var _liteModel:FarmLiteModel;
      
      private var _mainXML:XML;
      
      private var _liteUI:FarmLiteView;
      
      private var _timeout:uint;
      
      private var _timeoutStep1:uint;
      
      private var _timeStamp:Number;
      
      public function FarmLite()
      {
         super();
         this._settings = Settings.getInstance();
         this._settings.loadFromFlashVars(this.stage.loaderInfo);
         Cookies.intialize("FarmWorld2");
         this._text = new TextField();
         this._text.defaultTextFormat = new TextFormat(null,18,0,false,false,false,null,null,TextFormatAlign.CENTER);
         this._text.width = 800;
         this._text.height = 100;
         this._text.multiline = true;
         this._text.x = 40;
         this._text.y = 200;
         addChild(this._text);
         this.setup();
         this.boot();
      }
      
      private function onIndexPageSuccess(param1:QFAEvent) : void
      {
         var _loc2_:String = param1.data as String;
         if(_loc2_ == null || _loc2_ == "")
         {
            this._text.text = "加载农场游戏数据失败(-1)";
            this.setSnowslide();
            return;
         }
         this._bootData = com.adobe.serialization.json.JSON.decode(_loc2_) as Object;
         if(this._bootData == null)
         {
            this._text.text = "加载农场游戏数据失败(-2)";
            this.setSnowslide();
            return;
         }
         if(this._bootData["ecode"] != undefined)
         {
            this._text.text = "加载农场游戏数据失败: " + this._bootData["direction"];
            this.setSnowslide();
            return;
         }
         Cookies.setObject("snowslide",{
            "counter":0,
            "time":0
         },0,true);
         this._indexTime = getTimer() - (this._timeStamp + 200);
         EventRecorder.recordSueecssEvent(EventRecorder.HF_CGI_ENTER,this._indexTime,"mync.php?mod=user&act=run");
         this.checkStart();
      }
      
      private function onFilesLoadFailed(param1:CommandEvent) : void
      {
         this._text.text = "加载农场游戏数据失败(-6)，请稍后再刷新！";
         this._stepTime1 = getTimer() - this._timeStamp;
         EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD,this._stepTime1,-1,"第1步素材加载失败");
      }
      
      private function onIndexPageError(param1:QFAEvent) : void
      {
         this._text.text = "加载农场游戏数据失败(-3)";
         this._indexTime = getTimer() - this._timeStamp;
         var _loc2_:int = param1.data as int;
         EventRecorder.recordErrorEvent(EventRecorder.HF_CGI_ENTER,this._indexTime,_loc2_,"mync.php?mod=user&act=run");
         this.setSnowslide();
      }
      
      private function startLiteUI() : void
      {
         var loader:CmdLoadFile;
         var timeout:int = 0;
         clearTimeout(this._timeoutStep1);
         this._timeoutStep1 = 0;
         removeChild(this._text);
         this._text = null;
         this._liteModel = new FarmLiteModel(this._bootData);
         this._liteUI = new FarmLiteView(this._liteModel);
         addChild(this._liteUI);
         loader = new CmdLoadFile();
         CommandManager.getInstance().run(loader,{
            "addon":this._settings.addonConfigUrl,
            "res1":this._settings.replaceAppImg(this._mainXML.moduleList.module.(@name == "main").material[0].@url),
            "res2":this._settings.replaceAppImg(this._mainXML.moduleList.module.(@name == "main").material[1].@url),
            "water":this._settings.replaceAppImg(this._mainXML.moduleList.module.(@name == "main").material[2].@url),
            "main":this._settings.replaceAppImg(this._mainXML.moduleList.module.(@name == "main").@url)
         },this.onMainLoaded,this.onMainFailed);
         this._timeStamp = getTimer();
         timeout = 10 * 1000;
         this._timeout = setTimeout(function():void
         {
            EventRecorder.recordErrorEvent("160738",timeout,-1,"第二步加载超时");
         },timeout);
      }
      
      private function onFilesLoadCompleted(param1:CommandEvent) : void
      {
         var res:Resource;
         var url:String;
         var xml:XML = null;
         var e:CommandEvent = param1;
         this._stepTime1 = getTimer() - this._timeStamp;
         url = this._settings.getStringAttribute("config_url");
         res = ResourceManager.gi().getResource(url);
         if(res != null && res.loaded == true)
         {
            try
            {
               xml = new XML(res.data);
            }
            catch(te:TypeError)
            {
               trace("ERROR: invalid XML file:" + te.message);
            }
            finally
            {
               if(xml != null)
               {
                  this._mainXML = xml;
               }
            }
         }
         if(this._mainXML == null)
         {
            this._text.text = "加载农场主配置文件错误(-5)";
            QzoneJSAPI.reportError("加载农场主配置文件错误！",3);
            return;
         }
         this.checkStart();
      }
      
      private function onMainFailed(param1:CommandEvent) : void
      {
         QzoneJSAPI.reportError("加载游戏主模块出错(-8)",1);
         var _loc2_:Number = getTimer() - this._timeStamp;
         EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD,_loc2_,-2,"第2步素材加载失败");
      }
      
      private function uncaughtErrorHandler(param1:*) : void
      {
         QzoneJSAPI.reportError(param1["error"],1);
      }
      
      private function onMainLoaded(param1:CommandEvent) : void
      {
         var _loc4_:Number = NaN;
         clearTimeout(this._timeout);
         this._timeout = 0;
         var _loc2_:Number = getTimer();
         this._stepTime2 = _loc2_ - this._timeStamp;
         if(this._stepTime2 < 10 * 1000)
         {
            EventRecorder.recordSueecssEvent("160738",this._stepTime2,null);
         }
         var _loc3_:Sprite = ResourceManager.gi().getClassInstance("module.Main") as Sprite;
         if(_loc3_ == null)
         {
            QzoneJSAPI.reportError("游戏主模块启动失败(-7)",1);
            EventRecorder.recordErrorEvent(EventRecorder.HF_SWFLOAD,this._stepTime2,-3,"主模块启动失败");
         }
         else
         {
            EventRecorder.recordSueecssEvent(EventRecorder.HF_SWFLOAD,this._stepTime2,"全部加载成功");
            this.startMain(_loc3_);
            _loc4_ = getTimer() - _loc2_;
            this.reportSpeedIndex(_loc4_);
         }
      }
      
      private function addCallback() : void
      {
         var _loc1_:String = null;
         if(ExternalInterface.available == true)
         {
            _loc1_ = QzoneJSAPI.getAppParams();
            if(_loc1_ != null && _loc1_ != "")
            {
               CommonData.useExpressUser = true;
               CommonData.expressUser = com.adobe.serialization.json.JSON.decode(_loc1_);
            }
            QzoneJSAPI.flashInit();
         }
      }
      
      private function setSnowslide() : void
      {
         var _loc1_:Date = new Date();
         var _loc2_:Object = Cookies.getObject("snowslide");
         if(_loc2_ != null)
         {
            ++_loc2_["count"];
            _loc2_["time"] = _loc1_.getTime();
         }
         else
         {
            _loc2_ = {
               "count":1,
               "time":_loc1_.getTime()
            };
         }
         Cookies.setObject("snowslide",_loc2_,0,true);
      }
      
      private function reportSpeedIndex(param1:Number) : void
      {
         var _loc2_:String = null;
         var _loc3_:URLRequest = null;
         EventRecorder.initStartupSpeed();
         EventRecorder.STARTUP_SPEED_INFO[1] = this._stepTime1;
         EventRecorder.STARTUP_SPEED_INFO[2] = this._indexTime;
         EventRecorder.STARTUP_SPEED_INFO[4] = param1;
         EventRecorder.STARTUP_SPEED_INFO[11] = this._stepTime1 + this._stepTime2;
         EventRecorder.STARTUP_SPEED_INFO[12] = this._stepTime2;
         if(int(Math.random() * 60) == 0)
         {
            _loc2_ = Settings.getInstance().getUrlConfigByName("speedReport");
            if(_loc2_ == "")
            {
               return;
            }
            _loc3_ = new URLRequest(_loc2_);
            _loc3_.data = EventRecorder.STARTUP_SPEED_INFO as URLVariables;
            sendToURL(_loc3_);
         }
      }
      
      private function get startCGIUrl() : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc1_:Settings = Settings.getInstance();
         var _loc2_:String = "";
         if(_loc1_.getStringAttribute("agent") == "weibo")
         {
            _loc2_ = "mync.php?mod=user&act=run";
         }
         else
         {
            _loc3_ = _loc1_.mode;
            if(_loc3_ == "qplus")
            {
               _loc3_ = "qzone";
            }
            _loc4_ = _loc3_;
            if(_loc4_ == "qzone")
            {
               _loc4_ = "qzone.qq";
            }
            else if(_loc4_ == "")
            {
               _loc4_ = _loc1_.xymode;
            }
            _loc2_ = "" + _loc4_ + "mync.php?mod=user&act=run";
         }
         return QzoneJSAPI.addGToken(_loc2_);
      }
      
      private function snowSlide() : Boolean
      {
         var _loc1_:Object = Cookies.getObject("snowslide");
         if(_loc1_ == null)
         {
            return true;
         }
         var _loc2_:Date = new Date();
         if(_loc1_["count"] < 7 || _loc2_.getTime() - _loc1_["time"] > 10 * 1000)
         {
            return true;
         }
         return false;
      }
      
      private function boot() : void
      {
         var mainXMLUrl:String;
         var uiResUrl:String;
         var load_files:CmdLoadFile;
         var timeout:int = 0;
         if(this.openByFlashVar())
         {
            this._text.text = this._settings.getStringAttribute("index_tips");
            return;
         }
         if(this.snowSlide() == false)
         {
            this._text.text = "尊敬的用户：由于当前网络请求失败次数过多，建议您过一段时间后再试。";
            EventRecorder.recordErrorEvent("160514",0,3);
            return;
         }
         setTimeout(function():void
         {
            var _loc1_:CmdHttpRequest = new CmdHttpRequest();
            CommandManager.getInstance().run(_loc1_,{
               "url":startCGIUrl,
               "method":"post",
               "params":{
                  "farmTime":0,
                  "farmKey":"db03aaa4c6ae8e56943f5dda8791e48b",
                  "uIdx":"",
                  "uinY":""
               },
               "complete":onIndexPageSuccess,
               "error":onIndexPageError
            });
         },200);
         load_files = new CmdLoadFile();
         mainXMLUrl = this._settings.replaceAppImg(this._settings.getStringAttribute("config_url"));
         uiResUrl = this._settings.replaceAppImg("module/ui/lite_ui_v_0.swf");
         CommandManager.getInstance().run(load_files,{
            "load_main":mainXMLUrl,
            "lite_ui":uiResUrl,
            "config_data":this._settings.dataConfigUrl
         },this.onFilesLoadCompleted,this.onFilesLoadFailed);
         this._timeStamp = getTimer();
         timeout = 7 * 1000;
         this._timeoutStep1 = setTimeout(function():void
         {
            EventRecorder.recordErrorEvent("160738",timeout,-2,"第一步加载超时");
         },timeout);
      }
      
      private function checkStart() : void
      {
         if(this._bootData != null && this._mainXML != null)
         {
            this.startLiteUI();
            return;
         }
      }
      
      private function startMain(param1:Sprite) : void
      {
         var main:Sprite = param1;
         this._liteUI.destroy();
         this._liteModel.finalize();
         this._liteModel = null;
         addChild(main);
         main["startGame"](this._bootData);
         setTimeout(function():void
         {
            removeChild(_liteUI);
            _liteUI = null;
         },5000);
      }
      
      private function setup() : void
      {
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.showDefaultContextMenu = false;
         Security.allowDomain("appbase.qzone.qq.com");
         Security.allowDomain("appbase.xiaoyou.qq.com");
         Security.allowDomain("appbase.xiaoyou.pengyou.com");
         Security.allowDomain("appimg3.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain(this._settings.getStringAttribute("domian_qz") + ".qq.com");
         Security.allowDomain(this._settings.getStringAttribute("domian_xy") + ".qq.com");
         Security.allowDomain(this._settings.getStringAttribute("domian_xy") + ".pengyou.com");
         Security.allowDomain("hydra.qzone.qq.com");
         Security.allowDomain("hydra.t.qq.com");
         Security.allowDomain("hydra.qplus.qq.com");
         Security.allowDomain("hydra.pengyou.com");
         CommonData._root = this;
         CommonData.swfUrl = stage.loaderInfo.url;
         CommonData.applicationDomain = ApplicationDomain.currentDomain;
         CommonData.APP_DOMAIN = CommonData.applicationDomain;
         CommonData.addCallBackProxy = function(param1:String, param2:Function):void
         {
            if(param1 == null || param1.length == 0)
            {
               return;
            }
            if(param2 == null)
            {
               return;
            }
            if(ExternalInterface.available == true)
            {
               ExternalInterface.addCallback(param1,param2);
            }
         };
         setTimeout(this.addCallback,100);
         if(loaderInfo["uncaughtErrorEvents"] != undefined)
         {
            loaderInfo["uncaughtErrorEvents"].addEventListener("uncaughtError",this.uncaughtErrorHandler,false,0,true);
         }
      }
      
      private function openByFlashVar() : Boolean
      {
         var _loc1_:String = Settings.getInstance().getStringAttribute("useflag");
         var _loc2_:int = parseInt(_loc1_) / 1000 % 10;
         return !Boolean(_loc2_);
      }
   }
}


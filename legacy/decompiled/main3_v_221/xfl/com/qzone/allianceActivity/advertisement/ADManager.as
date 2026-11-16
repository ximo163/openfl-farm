package com.qzone.allianceActivity.advertisement
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   
   public class ADManager
   {
      
      private static var _instance:ADManager;
      
      private var _allianceAppHelper:IAllianceAppHelper;
      
      private var _dispatcher:EventDispatcher;
      
      private var _iconUrlDic:Dictionary;
      
      private var _adApi:IAdvertisement;
      
      private var _zoneFlag:String;
      
      private var _loadArr:Array = [];
      
      private var _appId:String;
      
      private var _adDic:Dictionary;
      
      private var _currentId:String;
      
      public function ADManager(param1:SingleClass)
      {
         super();
         this._adDic = new Dictionary();
      }
      
      public static function getInstance() : ADManager
      {
         if(!_instance)
         {
            _instance = new ADManager(new SingleClass());
         }
         return _instance;
      }
      
      private function checkAutoPop(param1:ADConfig) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         var _loc6_:Number = NaN;
         if(param1.autoPopTime != null)
         {
            _loc2_ = param1.autoPopTime;
            _loc3_ = _loc2_.split("-");
            _loc4_ = new Date(_loc3_[0]);
            _loc5_ = new Date(_loc3_[1]);
            _loc6_ = this._adApi.serverTime * 1000;
            if(_loc6_ >= _loc4_.time && _loc6_ <= _loc5_.time)
            {
               this._adApi.autoPop(param1);
            }
         }
      }
      
      public function onCallback(param1:*) : void
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc12_:Class = null;
         var _loc13_:int = 0;
         var _loc2_:ADConfig = this._adDic[this._currentId];
         var _loc3_:Object = _loc2_.callBack;
         if(_loc3_)
         {
            for(_loc7_ in _loc3_)
            {
               if(_loc7_ == param1["key"])
               {
                  _loc4_ = _loc3_[_loc7_] as Array;
                  if(_loc4_)
                  {
                     _loc5_ = int(_loc4_.length);
                     _loc8_ = 0;
                     while(_loc8_ < _loc5_)
                     {
                        _loc9_ = _loc4_[_loc8_][0];
                        _loc10_ = _loc4_[_loc8_][1];
                        _loc11_ = _loc4_[_loc8_][2];
                        _loc12_ = getDefinitionByName(_loc9_) as Class;
                        if(_loc12_)
                        {
                           _loc13_ = int(_loc12_.prototype.constructor.length);
                           if(_loc13_ == 1)
                           {
                              _loc6_ = new _loc12_(_loc10_);
                           }
                           else
                           {
                              _loc6_ = new _loc12_(_loc10_,_loc11_);
                           }
                           this._dispatcher.dispatchEvent(_loc6_ as Event);
                        }
                        _loc8_++;
                     }
                  }
               }
            }
         }
      }
      
      private function initAdvertisementItem(param1:Object) : void
      {
         var _loc2_:ADConfig = new ADConfig(param1,this._appId,this.click);
         this._adDic[_loc2_.id] = _loc2_;
         if(_loc2_.isOutTime(this._adApi.serverTime * 1000) == false)
         {
            this._loadArr.push(_loc2_);
         }
      }
      
      private function click(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:ADConfig = this._adDic[param1];
         if(!_loc2_)
         {
            return;
         }
         ClickReportManager.reportClick(_loc2_.clickIconReport);
         this._currentId = param1;
         var _loc3_:String = null;
         if(this._zoneFlag == "qzone")
         {
            _loc3_ = _loc2_.qzoneLink;
         }
         else if(this._zoneFlag == "")
         {
            _loc3_ = _loc2_.pyLink;
         }
         else if(this._zoneFlag == "weibo")
         {
            _loc3_ = _loc2_.wbLink;
         }
         ExternalInterface.addCallback("getGiftBack",this.onCallback);
         ExternalInterface.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc3_ + "&id=1" + " style=\"width:" + _loc2_.windowW + "px; height:" + _loc2_.windowH + "px; border:0px\" scrolling=no border=0 " + "frameBorder=no allowTransparency=true></iframe>\', " + "{width:" + _loc2_.windowW + ",height:" + _loc2_.windowH + ",noBorder:true})");
      }
      
      public function initAdvertisement(param1:String, param2:String, param3:IAdvertisement, param4:EventDispatcher, param5:IAllianceAppHelper, param6:Array) : void
      {
         var _loc7_:Object = null;
         this._zoneFlag = param1;
         this._appId = param2;
         this._dispatcher = param4;
         this._allianceAppHelper = param5;
         this._adApi = param3;
         for each(_loc7_ in param6)
         {
            this.initAdvertisementItem(_loc7_);
         }
         this.loadNext();
      }
      
      public function loadAndShowIcon(param1:ADConfig) : void
      {
         var _loc2_:Loader = new Loader();
         var _loc3_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         var _loc4_:String = param1.icon_src;
         var _loc5_:URLRequest = new URLRequest(_loc4_);
         var _loc6_:String = _loc4_.substring(_loc4_.lastIndexOf("/") + 1);
         this._iconUrlDic[_loc6_] = param1.id;
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadModuleResultHandler);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadModuleResultHandler);
         if(_loc4_.indexOf("file://") >= 0 || _loc4_.indexOf("://") < 0)
         {
            _loc3_.securityDomain = null;
         }
         else
         {
            _loc3_.securityDomain = SecurityDomain.currentDomain;
         }
         _loc2_.load(_loc5_,_loc3_);
      }
      
      private function loadModuleResultHandler(param1:Event) : void
      {
         var onIconOver:Function = null;
         var onIconOut:Function = null;
         var addIconToStage:Function = null;
         var loader:Loader = null;
         var content:DisplayObject = null;
         var id:String = null;
         var container:Sprite = null;
         var config:ADConfig = null;
         var event:Event = param1;
         onIconOver = function(param1:MouseEvent):void
         {
            _allianceAppHelper.showTips(container,config.mouse_tip);
         };
         onIconOut = function(param1:MouseEvent):void
         {
            _allianceAppHelper.hideTips(container);
         };
         addIconToStage = function(param1:DisplayObject):void
         {
            if(param1)
            {
               _allianceAppHelper.addIconEntrance(param1);
            }
            if(Boolean(config) && config.strongGuide != null)
            {
               _adApi.showStrongGuide(param1,param1.x + config.strongGuidePos[0],param1.y + config.strongGuidePos[1],config.strongGuide,5,true);
            }
         };
         var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
         try
         {
            loader = loaderInfo.loader;
            content = loaderInfo.loader.content;
         }
         catch(e:Error)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("Clinic.log.report","加载配置广告失败",3);
            }
         }
         if(event.type == Event.COMPLETE && Boolean(content))
         {
            (content as Sprite).buttonMode = true;
            id = this.getIconId(loaderInfo.url);
            container = new Sprite();
            container.buttonMode = true;
            container.addChild(content);
            container.name = id;
            config = this._adDic[id];
            if(config.mouse_tip != "" && config.mouse_tip != null)
            {
               container.addEventListener(MouseEvent.ROLL_OVER,onIconOver);
               container.addEventListener(MouseEvent.ROLL_OUT,onIconOut);
            }
            container.addEventListener(MouseEvent.CLICK,this.onAdEntranceClick);
            if(config)
            {
               this.checkAutoPop(config);
               setTimeout(addIconToStage,config.delay_show,container);
            }
         }
         this.loadNext();
      }
      
      private function whiteList(param1:ADConfig) : void
      {
         var callBack:Function = null;
         var adConfig:ADConfig = param1;
         callBack = function(param1:Object):void
         {
            if(Boolean(param1) && Boolean(param1["code"] == 1) && param1["ecode"] == 0)
            {
               loadEntrance(adConfig);
            }
            else
            {
               loadNext();
            }
         };
         if(adConfig.whiteList)
         {
            this._adApi.whileList(adConfig,callBack,callBack);
         }
         else
         {
            this.loadEntrance(adConfig);
         }
      }
      
      public function getIconId(param1:String) : String
      {
         var _loc2_:String = param1.substring(param1.lastIndexOf("/") + 1);
         if(Boolean(this._iconUrlDic) && this._iconUrlDic.hasOwnProperty(_loc2_))
         {
            return this._iconUrlDic[_loc2_];
         }
         return null;
      }
      
      private function grayScale(param1:ADConfig) : void
      {
         var callBack:Function = null;
         var adConfig:ADConfig = param1;
         callBack = function(param1:Object):void
         {
            if(Boolean(param1) && Boolean(param1["code"] == 1) && param1["ecode"] == 0)
            {
               whiteList(adConfig);
            }
            else
            {
               loadNext();
            }
         };
         if(adConfig.grayScale)
         {
            this._adApi.grayScale(adConfig,callBack,callBack);
         }
         else
         {
            this.whiteList(adConfig);
         }
      }
      
      private function onAdEntranceClick(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.name;
         this.click(_loc2_);
      }
      
      private function loadNext() : void
      {
         if(this._loadArr.length == 0)
         {
            return;
         }
         var _loc1_:ADConfig = this._loadArr.shift() as ADConfig;
         this.grayScale(_loc1_);
      }
      
      private function loadEntrance(param1:ADConfig) : void
      {
         var _loc2_:Sprite = null;
         if(param1.enter_type == "npc")
         {
            _loc2_ = this._allianceAppHelper.addNpcEntrance(param1.id,param1.npc_src,param1.npcPos[0],param1.npcPos[1],param1.mouse_tip,param1.bubble_tip);
            if(_loc2_ != null)
            {
               _loc2_.addEventListener(MouseEvent.CLICK,this.onAdEntranceClick);
            }
            this.checkAutoPop(param1);
            this.loadNext();
         }
         else if(param1.enter_type == "icon")
         {
            if(!this._iconUrlDic)
            {
               this._iconUrlDic = new Dictionary();
            }
            this.loadAndShowIcon(param1);
         }
      }
   }
}

class SingleClass
{
   
   public function SingleClass()
   {
      super();
   }
}

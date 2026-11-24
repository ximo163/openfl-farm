package module.quickshoot
{
   import com.adobe.images.JPGEncoder;
   import com.adobe.serialization.json.JSON;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import events.CommonEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.Timer;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   import report.EventRecorder;
   
   public class QuickShootController extends Controller
   {
      
      private var _bigMode:Boolean;
      
      private var _serverPicUrl:String;
      
      private var _window:QuickShootWindow;
      
      private var _headBar:DisplayObject;
      
      private var _farm:DisplayObject;
      
      private var _saveQuickShootUrl:String;
      
      private var _saveUld:URLLoader;
      
      private var _leftInfo:DisplayObject;
      
      private var _counter:int;
      
      public function QuickShootController()
      {
         super(null);
         this._saveQuickShootUrl = "";
         this._bigMode = false;
         if(Cookies.Get("bigmode") == "1")
         {
            this._bigMode = true;
         }
         this._counter = 0;
      }
      
      private function onSaveQuickShootErrorHandler(param1:*) : void
      {
         if(this._window)
         {
            this._window.setStatus(QuickShootWindow.ERROR);
         }
         this._saveUld = null;
      }
      
      private function onZoom(param1:CommonEvent) : void
      {
         this._bigMode = param1.data as Boolean;
      }
      
      private function onQuickShootClick(param1:CommonEvent) : void
      {
         var _loc2_:Sprite = null;
         if(param1.data == true)
         {
            this._farm = this.app.farmView.getLayerByName(Consts.LAYER_SCENE_CONTENT);
            _loc2_ = this.app.farmView.getLayerByName(Consts.LAYER_TOOLS);
            this._headBar = _loc2_.getChildByName("__playerbar__");
            if(Session.getInstance().me == true)
            {
               this._leftInfo = null;
            }
            else
            {
               this._leftInfo = _loc2_.getChildByName("__friendbar__");
            }
            this._window = new QuickShootWindow(this.app);
            this._window.confirmFn = this.confirmQuickShoot;
            this.app.farmView.winCtrl.open(this._window);
            this._window.addBitmap(this.buildPreview());
         }
      }
      
      private function confirmQuickShoot(param1:Boolean) : void
      {
         if(param1 == false)
         {
            if(this._window != null && this._window.currentStatus == QuickShootWindow.UPLOADING)
            {
               if(this._saveUld != null)
               {
                  this._saveUld.close();
                  this._saveUld = null;
               }
            }
            this._window = null;
            this._leftInfo = this._headBar = this._farm = null;
            return;
         }
         if(this._window.currentStatus == QuickShootWindow.SUCCESS)
         {
            this.app.farmView.winCtrl.close(this._window);
            ExternalInterface.call("window.open",this._serverPicUrl);
            this._window = null;
            return;
         }
         if(this._counter >= 5)
         {
            this.app.openWindowByName(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_TIP,
               "text":"每天最多拥有5次拍照留念机会。"
            });
            return;
         }
         this._window.setStatus(QuickShootWindow.UPLOADING);
         var _loc2_:* = QzoneJSAPI.getUpUrl(null);
         if(_loc2_ !== 0)
         {
            this.onSaveQuickShootErrorHandler(null);
         }
      }
      
      private function initQuickShoot() : void
      {
         this._saveQuickShootUrl = Settings.getInstance().getStringAttribute("quick_shoot_url");
         var _loc1_:IMsgCenter = this.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_CAMERA,this.onQuickShootClick,false,0,true);
            _loc1_.addEventListener(Consts.MSG_ZOOM,this.onZoom,false,0,true);
         }
      }
      
      private function onSaveQuickShootCompleteHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Date = null;
         var _loc4_:URLVariables = null;
         this._saveUld = null;
         if(param1 != null && this._window != null)
         {
            _loc2_ = com.adobe.serialization.json.JSON.decode(param1.target.data);
            if(_loc2_ == null)
            {
               this._window.setStatus(QuickShootWindow.ERROR);
               this._window.setTxtInfo("未知错误");
            }
            else if(_loc2_["errno"] != undefined)
            {
               this._window.setStatus(QuickShootWindow.ERROR);
               this._window.setTxtInfo(_loc2_.error.replace(/错误码.+/,""));
            }
            else
            {
               this._serverPicUrl = _loc2_.url;
               this._window.setStatus(QuickShootWindow.SUCCESS);
               ++this._counter;
               _loc3_ = new Date();
               Cookies.Set("CameraShoot",_loc3_.toDateString() + "_" + this._counter);
               if(int(Math.random() * EventRecorder.successRecordProbability) == 0)
               {
                  _loc4_ = new URLVariables();
                  _loc4_["flag1"] = EventRecorder.HF_PHOTO_BIG;
                  if(this._window.smallResolution == true)
                  {
                     _loc4_["flag1"] = EventRecorder.HF_PHOTO_SMALL;
                  }
                  _loc4_["flag2"] = EventRecorder.SUEECSS;
                  _loc4_["1"] = EventRecorder.successRecordProbability;
                  EventRecorder.record(_loc4_);
               }
            }
         }
      }
      
      private function postScreen(param1:TimerEvent) : void
      {
         if(this._saveQuickShootUrl == null || this._saveQuickShootUrl == "")
         {
            this.onSaveQuickShootErrorHandler(null);
            return;
         }
         var _loc2_:DisplayObject = this._window.preview;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Number = 800;
         var _loc4_:Number = 600;
         if(this._window != null && this._window.smallResolution == false)
         {
            _loc3_ = 1000;
            _loc4_ = 768;
         }
         var _loc5_:BitmapData = new BitmapData(_loc3_,_loc4_);
         var _loc6_:Matrix = new Matrix(_loc3_ / 1000,0,0,_loc4_ / 768,0,0);
         _loc5_.draw(_loc2_,_loc6_,null,null,null,true);
         var _loc7_:String = encodeURIComponent(this._window.picName);
         var _loc8_:String = encodeURIComponent(this._window.picDesc);
         trace(this._saveQuickShootUrl);
         this._saveQuickShootUrl = this._saveQuickShootUrl.replace(/refer=[a-zA-Z]*/ig,"1=1");
         trace(this._saveQuickShootUrl);
         var _loc9_:URLRequest = new URLRequest(this._saveQuickShootUrl + "?needcompress=0&charset=utf-8&output_charset=utf-8&albumid=&picname=" + _loc7_ + ".jpg&desc=" + _loc8_);
         _loc9_.method = URLRequestMethod.POST;
         _loc9_.contentType = "application/octet-stream";
         var _loc10_:JPGEncoder = new JPGEncoder(80);
         _loc9_.data = _loc10_.encode(_loc5_);
         this._saveUld = new URLLoader();
         this._saveUld.addEventListener(Event.COMPLETE,this.onSaveQuickShootCompleteHandler,false,0,true);
         this._saveUld.addEventListener(IOErrorEvent.IO_ERROR,this.onSaveQuickShootErrorHandler,false,0,true);
         this._saveUld.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSaveQuickShootErrorHandler,false,0,true);
         this._saveUld.load(_loc9_);
         _loc5_.dispose();
      }
      
      private function hookJS() : void
      {
         var timer:Timer = new Timer(200,1);
         timer.addEventListener(TimerEvent.TIMER,function():void
         {
            CommonData.addCallBackProxy("setUploadUrl",onSetUrlByJS);
         });
         timer.start();
      }
      
      private function get app() : FarmApplication
      {
         return m_module.app;
      }
      
      override public function initialze() : void
      {
         var _loc2_:Array = null;
         var _loc3_:Date = null;
         this.initQuickShoot();
         this.hookJS();
         this._counter = 0;
         var _loc1_:String = Cookies.Get("CameraShoot");
         if(_loc1_ == null || _loc1_ == "")
         {
            this._counter = 0;
         }
         else
         {
            _loc2_ = _loc1_.split("_");
            if(_loc2_ != null && _loc2_.length == 2)
            {
               _loc3_ = new Date();
               if(_loc3_.toDateString() == _loc2_[0])
               {
                  this._counter = parseInt(_loc2_[1]);
               }
               else
               {
                  this._counter = 0;
               }
            }
         }
      }
      
      private function buildPreview() : Sprite
      {
         var _loc1_:Sprite = null;
         var _loc3_:Number = NaN;
         var _loc4_:Matrix = null;
         var _loc5_:Rectangle = null;
         var _loc6_:BitmapData = null;
         var _loc7_:BitmapData = null;
         var _loc8_:Bitmap = null;
         var _loc9_:BitmapData = null;
         var _loc10_:Bitmap = null;
         _loc1_ = new Sprite();
         if(this._farm != null)
         {
            _loc3_ = this._bigMode ? 1.3 : 1;
            _loc4_ = new Matrix(1 / _loc3_,0,0,1 / _loc3_);
            _loc5_ = this._farm.scrollRect;
            this._farm.scrollRect = new Rectangle(0,0,1000 * _loc3_,768 * _loc3_);
            _loc6_ = new BitmapData(1000,768);
            _loc6_.draw(this._farm,_loc4_,null,null,null,true);
            this._farm.scrollRect = _loc5_;
            _loc1_.addChild(new Bitmap(_loc6_,"auto",true));
         }
         if(this._headBar != null)
         {
            _loc7_ = new BitmapData(325,this._headBar.height,true,0);
            _loc7_.draw(this._headBar,null,null,null,null,true);
            _loc8_ = new Bitmap(_loc7_,"auto",true);
            _loc8_.x = _loc8_.y = 30;
            _loc1_.addChild(_loc8_);
         }
         if(this._leftInfo != null)
         {
            _loc9_ = null;
            _loc9_ = new BitmapData(this._leftInfo.width,this._leftInfo.height,true,0);
            _loc9_.draw(this._leftInfo,null,null,null,null,true);
            _loc10_ = new Bitmap(_loc9_,"auto",true);
            _loc10_.x = 30;
            _loc10_.y = 100;
            _loc1_.addChild(_loc10_);
         }
         var _loc2_:DisplayObject = Utils.getMaterial("CameraShootLogo") as DisplayObject;
         if(_loc2_ != null)
         {
            _loc2_.x = _loc1_.width - _loc2_.width - 10;
            _loc2_.y = _loc1_.height - _loc2_.height - 10;
            _loc1_.addChild(_loc2_);
         }
         return _loc1_;
      }
      
      public function onSetUrlByJS(param1:String) : void
      {
         this._saveQuickShootUrl = param1;
         var _loc2_:Timer = new Timer(100,1);
         _loc2_.addEventListener(TimerEvent.TIMER,this.postScreen);
         _loc2_.start();
      }
   }
}


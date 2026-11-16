package mc.control
{
   import com.adobe.images.JPGEncoder;
   import com.adobe.serialization.json.JSON;
   import com.adobe.utils.StringUtil;
   import com.qzone.corelib.js.JSProxy;
   import common.CommonData;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.events.WindowEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.head.HeadBar;
   import mc.view.main.window.tool.QuickShootWindow;
   
   public class ToolCommand extends EventDispatcher
   {
      
      private var mainData:MainData;
      
      private var farmData:FarmData;
      
      private var _serverPicUrl:String;
      
      private var framBmpd:BitmapData;
      
      private var _quickShootWindow:QuickShootWindow;
      
      private var headBmpd:BitmapData;
      
      private var _thisDayUploadNum:Number = 0;
      
      private var _saveUld:URLLoader;
      
      private var _leftInfo:DisplayObject;
      
      private var fr:FRequest;
      
      private var _fram:DisplayObject;
      
      private var _headBar:HeadBar;
      
      private var timeoutId:Number;
      
      private var temp:Sprite = new Sprite();
      
      private var _loadedUploadUrl:Boolean = false;
      
      private var leftInfoBmpd:BitmapData;
      
      private var bmpd:BitmapData;
      
      public function ToolCommand()
      {
         super();
         this.fr = FRequest.getInstance();
         this.mainData = MData.getInstance().mainData;
         this.farmData = MData.getInstance().farmData;
      }
      
      private function checkErrorReturn2(param1:Object, param2:String, param3:Number = -1) : Boolean
      {
         var _loc4_:String = null;
         if(param1.hasOwnProperty("errorType"))
         {
            _loc4_ = param1["errorType"];
            if(_loc4_ == "validateCode")
            {
               return true;
            }
            if(_loc4_ == "IOError" || _loc4_ == "httpStatus" || _loc4_ == "timeOut")
            {
               this.farmData.farmOperate = {
                  "text":"请求超时，稍后再试。",
                  "type":param2
               };
               return true;
            }
            if(_loc4_ == "system")
            {
               this.farmData.farmOperate = {
                  "text":param1["errorContent"],
                  "type":param2
               };
               return true;
            }
            if(_loc4_ != "session" && param1.hasOwnProperty("errorContent") && StringUtil.trim(param1["errorContent"]) != "")
            {
               this.farmData.farmOperate = {
                  "text":param1["errorContent"],
                  "type":param2,
                  "serial":param3
               };
               return true;
            }
            return true;
         }
         return false;
      }
      
      public function setWhistle(param1:Object) : void
      {
         this.fr.postRequest("cgi_set_parade",param1,this.onSetWhistle);
      }
      
      public function setUpUrl(param1:String) : void
      {
         var _loc2_:int = param1.lastIndexOf("?");
         if(_loc2_ > 0)
         {
            param1 += "&";
         }
         else
         {
            param1 += "?";
         }
         LocalData.saveQuickShootUrl = param1;
         if(LocalData.onJSsetUrl())
         {
            LocalData.onJSsetUrl();
         }
      }
      
      private function _confirmQuickShoot(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._quickShootWindow.currentStatus == QuickShootWindow.SUCCESS)
            {
               WControl.close(this._quickShootWindow);
               JSProxy.openWindow(this._serverPicUrl);
               this._quickShootWindow = null;
               return;
            }
            if(this._loadedUploadUrl)
            {
               this._quickShootWindow.setStatus(QuickShootWindow.UPLOADING);
               this._StartSaveQuick();
            }
            else
            {
               this._quickShootWindow.setStatus(QuickShootWindow.UPLOADING);
               this._getUploadUrlFromJS();
            }
         }
         else
         {
            this.framBmpd.dispose();
            this.headBmpd.dispose();
            if(this.leftInfoBmpd)
            {
               this.leftInfoBmpd.dispose();
            }
            this.temp = null;
            this._leftInfo = this._fram = null;
            this._headBar = null;
            this._quickShootWindow = null;
         }
      }
      
      public function getWhistle() : void
      {
         this.fr.postRequest("cgi_get_parade",null,this.onGetWhistle);
      }
      
      private function addMoney(param1:Object) : void
      {
         if(param1.hasOwnProperty("money") && param1["money"] != 0)
         {
            this.mainData.host["money"] = Number(this.mainData.host["money"]) + int(param1["money"]);
            this.mainData.addMoney = param1["money"];
         }
      }
      
      public function drawPic() : Sprite
      {
         var _loc5_:Bitmap = null;
         var _loc1_:Rectangle = this._fram.scrollRect;
         this._fram.scrollRect = new Rectangle(0,0,1024,768);
         this.framBmpd = new BitmapData(1024,768);
         this.framBmpd.draw(this._fram,null,null,null,null,true);
         this._fram.scrollRect = _loc1_;
         this._headBar.headToolBar.visible = false;
         this.headBmpd = new BitmapData(325,this._headBar.height,true,0);
         this.headBmpd.draw(this._headBar,null,null,null,null,true);
         this._headBar.headToolBar.visible = true;
         this.temp = new Sprite();
         this.temp.addChild(new Bitmap(this.framBmpd,"auto",true));
         var _loc2_:Bitmap = new Bitmap(this.headBmpd,"auto",true);
         _loc2_.x = _loc2_.y = 30;
         this.temp.addChild(_loc2_);
         var _loc3_:MovieClip = MaterialLib.getInstance().getMaterial("MCLogo") as MovieClip;
         _loc3_.x = this.framBmpd.width - _loc3_.width - 20;
         _loc3_.y = this.framBmpd.height - _loc3_.height - 20;
         this.temp.addChild(_loc3_);
         if(this._leftInfo)
         {
            this.leftInfoBmpd = new BitmapData(this._leftInfo.width,this._leftInfo.height,true,0);
            this.leftInfoBmpd.draw(this._leftInfo,null,null,null,null,true);
            _loc5_ = new Bitmap(this.leftInfoBmpd,"auto",true);
            _loc5_.x = 30;
            _loc5_.y = 100;
            this.temp.addChild(_loc5_);
         }
         var _loc4_:Number = 1;
         this.bmpd = new BitmapData(Math.floor(_loc4_ * this.temp.width),Math.floor(_loc4_ * this.temp.height));
         this.bmpd.draw(this.temp,new Matrix(_loc4_,0,0,_loc4_),null,null,null,true);
         return this.temp;
      }
      
      private function _getUploadUrlFromJS() : void
      {
         LocalData.onJSsetUrl = this._StartSaveQuick;
         var _loc1_:* = JSProxy.getUpUrl(this.setUpUrl);
         if(_loc1_ !== 0)
         {
            this.__onSaveQuickShootErrorHandler(null);
            return;
         }
      }
      
      public function checkSameDay(param1:Date, param2:Date) : Boolean
      {
         if(param1.getFullYear() == param2.getFullYear() && param1.getDate() == param2.getDate() && param1.getMonth() == param2.getMonth())
         {
            return true;
         }
         return false;
      }
      
      private function checkErrorReturn(param1:Object) : Boolean
      {
         var _loc2_:String = null;
         if(param1.hasOwnProperty("errorType"))
         {
            _loc2_ = param1["errorType"];
            if(_loc2_ == "validateCode")
            {
               return true;
            }
            if(_loc2_ == "IOError" || _loc2_ == "httpStatus" || _loc2_ == "timeOut")
            {
               this.alertWindow("error","请求超时，稍后再试");
               return true;
            }
            if(_loc2_ != "session" && param1.hasOwnProperty("errorContent") && StringUtil.trim(param1["errorContent"]) != "")
            {
               this.alertWindow("error",param1["errorContent"]);
               return true;
            }
            return true;
         }
         return false;
      }
      
      public function quickShoot(param1:DisplayObject, param2:HeadBar, param3:DisplayObject) : void
      {
         if(this._quickShootWindow)
         {
            return;
         }
         var _loc4_:Object = LocalData.getInstance().getObject("quickShootData" + this.mainData.host["uId"]);
         if(_loc4_)
         {
            if(this.checkSameDay(new Date(CommonData.serverTime * 1000),_loc4_.date))
            {
               if(_loc4_.num >= 5)
               {
                  this.alertWindow("error","每天最多拥有5次拍照留念机会。");
                  return;
               }
               this._thisDayUploadNum = _loc4_.num;
            }
            if(!this.checkSameDay(new Date(CommonData.serverTime * 1000),_loc4_.date))
            {
               this._thisDayUploadNum = 0;
            }
         }
         else
         {
            this._thisDayUploadNum = 0;
         }
         this._fram = param1;
         this._headBar = param2;
         this._leftInfo = param3;
         this._quickShootWindow = new QuickShootWindow();
         this._quickShootWindow.confirmFn = this._confirmQuickShoot;
         WControl.open(this._quickShootWindow);
      }
      
      private function __onSaveQuickShootCompleteHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         if(this._quickShootWindow)
         {
            _loc2_ = com.adobe.serialization.json.JSON.decode(param1.target.data);
            this._serverPicUrl = _loc2_.url;
            if(_loc2_.errno)
            {
               this._quickShootWindow.setStatus(QuickShootWindow.ERROR);
               this._quickShootWindow.setTxtInfo(_loc2_.error.replace(/错误码.+/,""));
               return;
            }
            this._quickShootWindow.setStatus(QuickShootWindow.SUCCESS);
            ++this._thisDayUploadNum;
            LocalData.getInstance().setObject("quickShootData" + this.mainData.host["uId"],{
               "num":this._thisDayUploadNum,
               "date":new Date(CommonData.serverTime * 1000)
            },0,false);
         }
         this.disposeSaveUld();
      }
      
      private function onSetWhistle(param1:Object) : void
      {
         if(this.checkErrorReturn(param1))
         {
            EventRecorder.recordErrorEvent("160948",0,14);
            return;
         }
         EventRecorder.recordSueecssEvent("160948",0);
         this.alertWindow("success","设置成功！");
      }
      
      private function _SaveQuick() : void
      {
         clearTimeout(this.timeoutId);
         if(LocalData.saveQuickShootUrl == null || LocalData.saveQuickShootUrl == "")
         {
            this.__onSaveQuickShootErrorHandler(null);
            return;
         }
         this._loadedUploadUrl = true;
         this._saveUld = new URLLoader();
         this._saveUld.addEventListener(Event.COMPLETE,this.__onSaveQuickShootCompleteHandler);
         this._saveUld.addEventListener(IOErrorEvent.IO_ERROR,this.__onSaveQuickShootErrorHandler);
         this._saveUld.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.__onSaveQuickShootErrorHandler);
         var _loc1_:String = encodeURIComponent(this._quickShootWindow.picName);
         var _loc2_:String = encodeURIComponent(this._quickShootWindow.picDesc);
         var _loc3_:URLRequest = new URLRequest(LocalData.saveQuickShootUrl + "needcompress=0&feeds=1&charset=utf-8&output_charset=utf-8&albumid=&refer=qqpasturesnap&picname=" + _loc1_ + ".jpg&desc=" + _loc2_);
         _loc3_.method = URLRequestMethod.POST;
         _loc3_.contentType = "application/octet-stream";
         var _loc4_:JPGEncoder = new JPGEncoder(80);
         _loc3_.data = _loc4_.encode(this.bmpd);
         this._saveUld.load(_loc3_);
      }
      
      private function disposeSaveUld() : void
      {
         if(this._saveUld)
         {
            if(this._saveUld.hasEventListener(Event.COMPLETE))
            {
               this._saveUld.removeEventListener(Event.COMPLETE,this.__onSaveQuickShootCompleteHandler);
               this._saveUld.removeEventListener(ProgressEvent.PROGRESS,this.__onSaveQuickShootErrorHandler);
               this._saveUld.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.__onSaveQuickShootErrorHandler);
            }
            this._saveUld = null;
         }
      }
      
      private function alertWindow(param1:String, param2:String) : void
      {
         var _loc3_:WindowEvent = null;
         if(StringUtil.trim(param2) != "")
         {
            _loc3_ = new WindowEvent(WindowEvent.OPEN);
            _loc3_.windowName = "AlertWindow";
            _loc3_.windowArgument = {
               "type":param1,
               "text":param2
            };
            ViewControl.getInstance().dispatchEvent(_loc3_);
         }
      }
      
      private function _StartSaveQuick() : void
      {
         this.timeoutId = setTimeout(this._SaveQuick,100);
      }
      
      private function __onSaveQuickShootErrorHandler(param1:*) : void
      {
         if(this._quickShootWindow)
         {
            this._quickShootWindow.setStatus(QuickShootWindow.ERROR);
         }
         this.disposeSaveUld();
      }
      
      private function onGetWhistle(param1:Object) : void
      {
         if(this.checkErrorReturn(param1))
         {
            EventRecorder.recordErrorEvent("160947",0,14);
            return;
         }
         EventRecorder.recordSueecssEvent("160947",0);
         MData.getInstance().toolData.whistleData = param1;
      }
   }
}


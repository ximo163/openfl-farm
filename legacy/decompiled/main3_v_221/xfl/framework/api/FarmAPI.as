package framework.api
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.managers.PopUpManager;
   import com.qzone.sns.QQPay;
   import common.CommonData;
   import common.Consts;
   import common.view.window.ContentWindow;
   import common.view.window.WindowControl;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import framework.net.NetHelper;
   import framework.net.ServerServices;
   import framework.net.vo.ServiceResultVO;
   import interfaces.ILogicParser;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   import module.FarmStage;
   import report.EventRecorder;
   
   public class FarmAPI implements IFarmAPI
   {
      
      private var m_app:FarmApplication;
      
      private var m_cmdMap:Dictionary;
      
      public function FarmAPI(param1:FarmApplication)
      {
         super();
         this.m_app = param1;
         this.m_cmdMap = new Dictionary();
      }
      
      public function confirm(param1:String, param2:String, param3:String, param4:int, param5:int, param6:Boolean, param7:Boolean, param8:Function) : void
      {
         var _loc9_:Object = {
            "title":param1,
            "text":param2,
            "confirmEnable":param6
         };
         if(param4 > 0)
         {
            _loc9_["width"] = param4;
         }
         if(param5 > 0)
         {
            _loc9_["height"] = param5;
         }
         if(param3 != null && param3 != "")
         {
            _loc9_["error"] = param3;
         }
         if(param8 != null)
         {
            _loc9_["confirmFn"] = param8;
         }
         if(param7 == true)
         {
            _loc9_["hideIcon"] = true;
         }
         this.m_app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc9_);
      }
      
      public function get messageCenter() : IMsgCenter
      {
         return this.m_app as IMsgCenter;
      }
      
      private function onRequestFailed(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:uint = uint(param1.body["cmdID"] as int);
         if(this.m_cmdMap[_loc3_.toString()] == undefined || this.m_cmdMap[_loc3_.toString()] == null)
         {
            return;
         }
         var _loc4_:* = this.m_cmdMap[_loc3_.toString()];
         if(_loc4_ == null)
         {
            return;
         }
         if(_loc4_["fail"] is Function)
         {
            if(_loc2_.m_extra == null)
            {
               _loc2_.m_extra = {"__body":param1.body["__body"]};
            }
            else
            {
               _loc2_.m_extra["__body"] = param1.body["__body"];
            }
            _loc4_["fail"](_loc3_,_loc2_.m_extra);
         }
         delete this.m_cmdMap[_loc3_.toString()];
      }
      
      public function createWindow(param1:String, param2:DisplayObjectContainer, param3:Function, param4:Object) : Boolean
      {
         var _loc6_:ContentWindow = null;
         if(param1 == null || param1 == "" || param2 == null)
         {
            throw new ArgumentError("Invalid parameter");
         }
         var _loc5_:WindowControl = this.m_app.farmView.winCtrl;
         if(_loc5_.getClass(param1) != null)
         {
            _loc5_.open(_loc6_);
            return true;
         }
         _loc6_ = new ContentWindow(this.m_app,param1,param2);
         _loc6_.data = param4;
         _loc5_.open(_loc6_);
         _loc6_.closeFn = param3;
         return true;
      }
      
      public function popFloatTip(param1:int, param2:String, param3:DisplayObjectContainer = null) : void
      {
         if(param3 == null)
         {
            param3 = CommonData.root;
         }
         var _loc4_:String = Consts.ALERT_TYPE_SUCCESS;
         if(param1 == 0)
         {
            _loc4_ = Consts.ALERT_TYPE_SUCCESS;
         }
         else if(param1 == 1)
         {
            _loc4_ = Consts.ALERT_TYPE_ERROR;
         }
         else if(param1 == 2)
         {
            _loc4_ = Consts.ALERT_TYPE_TIP;
         }
         var _loc5_:Object = {
            "type":_loc4_,
            "text":param2,
            "parent":param3
         };
         this.m_app.openFloat(Consts.FLOAT_TYPE_TEXTTIP,0,_loc5_);
      }
      
      public function reportReturnCode(param1:String, param2:String) : void
      {
         EventRecorder.recordMultiValueInCode(param1,param2);
      }
      
      public function showWindow(param1:String, param2:Boolean) : void
      {
         if(param2 == true)
         {
            this.m_app.openWindowByName(param1,null);
         }
         else
         {
            this.m_app.closeWindowByName(param1);
         }
      }
      
      public function showPopUp(param1:DisplayObjectContainer, param2:Boolean) : void
      {
         if(param1 == null)
         {
            return;
         }
         PopUpManager.addPopUp(param1,param2);
      }
      
      public function reportSuccessError(param1:String, param2:*, param3:int = -1, param4:String = null) : void
      {
         if(param3 == -1)
         {
            EventRecorder.recordSueecssEvent(param1,param2,param4);
         }
         else
         {
            EventRecorder.recordErrorEvent(param1,param2,param3,param4);
         }
      }
      
      public function executeCommand(param1:int, param2:int, param3:Object) : Object
      {
         var _loc4_:PluginManager = PluginManager.getInstance();
         var _loc5_:IPluginProxy = _loc4_.getPluginByID(param1);
         if(_loc5_ != null)
         {
            return _loc5_.executeCommand(param2,param3);
         }
         return null;
      }
      
      public function hideMouseTip() : void
      {
         this.m_app.hideTip();
      }
      
      public function get app() : FarmApplication
      {
         return this.m_app;
      }
      
      public function alert(param1:int, param2:String, param3:String, param4:int, param5:int, param6:Function) : void
      {
         var _loc7_:String = Consts.ALERT_TYPE_TEXT;
         if(param1 == 1)
         {
            _loc7_ = Consts.ALERT_TYPE_SUCCESS;
         }
         else if(param1 == 2)
         {
            _loc7_ = Consts.ALERT_TYPE_ERROR;
         }
         else if(param1 == 3)
         {
            _loc7_ = Consts.ALERT_TYPE_TIP;
         }
         var _loc8_:Object = {
            "type":_loc7_,
            "title":param2,
            "text":param3
         };
         if(param4 > 0)
         {
            _loc8_["width"] = param4;
         }
         if(param5 > 0)
         {
            _loc8_["height"] = param5;
         }
         if(param6 != null)
         {
            _loc8_["confirmButtonClickHandle"] = param6;
         }
         this.m_app.openWindowByName(Consts.WINDOW_NAME_ALERT,_loc8_);
      }
      
      public function useSystemCursor(param1:Boolean) : void
      {
         this.m_app.useSystemCursor(param1);
      }
      
      public function hidePopUp(param1:DisplayObjectContainer) : void
      {
         PopUpManager.removePopUp(param1 as DisplayObjectContainer);
      }
      
      public function popMouseTip(param1:String) : void
      {
         this.m_app.showTip(Consts.TIP_NAME_MOUSE,param1);
      }
      
      public function requestClass(param1:String, param2:Function, param3:String = null, param4:Object = null) : void
      {
         CommonData.rslManager.requestClass(param1,param2,param3,param4);
      }
      
      public function payByPlatform(param1:int, param2:int, param3:int, param4:int, param5:Function) : Boolean
      {
         return QQPay.getInstance().payByPlatform(param1,param2,param3,param4,param5);
      }
      
      public function showStrongGuide(param1:Sprite, param2:int, param3:int, param4:String, param5:int = 5, param6:Boolean = false) : void
      {
         var onNewIconTimer:Function;
         var hideNewIcon:Function;
         var layer:Sprite = null;
         var _newIcon:Sprite = null;
         var c:DisplayObjectContainer = null;
         var pt:Point = null;
         var timer:Timer = null;
         var target:Sprite = param1;
         var posX:int = param2;
         var posY:int = param3;
         var guideString:String = param4;
         var delaySec:int = param5;
         var dynamicPosition:Boolean = param6;
         layer = (this.m_app.view as FarmStage).getLayerByName(Consts.LAYER_STRONG_GUIDE);
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
      
      public function registerNetCommand(param1:uint, param2:String, param3:ILogicParser) : void
      {
         ServerServices.getInstance().registerCmd(param1,param2,param3);
      }
      
      private function onRequestSuccess(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:uint = uint(param1.body["cmdID"] as int);
         if(this.m_cmdMap[_loc3_.toString()] == undefined || this.m_cmdMap[_loc3_.toString()] == null)
         {
            return;
         }
         var _loc4_:* = this.m_cmdMap[_loc3_.toString()];
         if(_loc4_ == null)
         {
            return;
         }
         if(_loc4_["success"] is Function)
         {
            if(_loc2_.m_extra == null)
            {
               _loc2_.m_extra = {"__body":param1.body["__body"]};
            }
            else
            {
               _loc2_.m_extra["__body"] = param1.body["__body"];
            }
            _loc4_["success"](_loc3_,_loc2_.m_extra);
         }
         delete this.m_cmdMap[_loc3_.toString()];
      }
      
      public function sendRequest(param1:uint, param2:Object, param3:Function, param4:Function) : Boolean
      {
         var _loc5_:ServerServices = ServerServices.getInstance();
         if(_loc5_.getRequestUrl(param1) == "")
         {
            return false;
         }
         this.m_cmdMap[param1.toString()] = {
            "success":param3,
            "fail":param4
         };
         NetHelper.sendRequest(param1,param2,this.onRequestSuccess,this.onRequestFailed);
         return true;
      }
   }
}


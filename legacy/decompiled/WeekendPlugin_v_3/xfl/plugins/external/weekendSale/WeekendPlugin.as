package plugins.external.weekendSale
{
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import com.qzone.farm.api.interfaces.IPlugin;
   import com.qzone.qui.styles.Style;
   import common.CommonData;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Security;
   import report.EventRecorder;
   
   [SWF(width="500", height="375", backgroundColor="#869ca7", frameRate="24")]
   public class WeekendPlugin extends Sprite implements IPlugin
   {
      
      private var _iconCls2:Class = WeekendPlugin__iconCls2;
      
      private var _id:int;
      
      private var _iconCls1:Class = WeekendPlugin__iconCls1;
      
      private var _api:IFarmAPI;
      
      private var _config:Object;
      
      private var _model:WeekendSaleModel;
      
      private var _iconEntrance:MovieClip;
      
      private var _mainWnd:MainWindowWrapper;
      
      private var _luckWnd:LuckWindowWrapper;
      
      public function WeekendPlugin()
      {
         super();
         Security.allowDomain("happyfarm.qzone.qq.com");
         Security.allowDomain("happyfarm.xiaoyou.qq.com");
         Security.allowDomain("appimg1.qq.com");
         Security.allowDomain("appimg.qq.com");
         Security.allowDomain("imgcache.qq.com");
      }
      
      public function unload() : void
      {
      }
      
      public function openRefreshWindow(param1:int) : void
      {
         var self:WeekendPlugin = null;
         var index:int = param1;
         this._model.loadCards();
         self = this;
         this._model.addEventListener(WeekendSaleModel.DATA_CARD_LOADED,function(param1:CommonEvent):void
         {
            param1.target.removeEventListener(param1.type,arguments.callee);
            if(_luckWnd == null)
            {
               _luckWnd = new LuckWindowWrapper(self);
            }
            _luckWnd.show(index,param1.data["cards"],param1.data["free"]);
         });
      }
      
      private function openMainWindow() : void
      {
         if(this._model.seeds == null || this._model.seeds.length < 2)
         {
            return;
         }
         if(this._mainWnd == null)
         {
            this._mainWnd = new MainWindowWrapper(this);
         }
         var _loc1_:Array = [this._model.seeds[0]["cId"],this._model.seeds[1]["cId"]];
         var _loc2_:Array = [this._model.seeds[0]["times"],this._model.seeds[1]["times"]];
         var _loc3_:Array = [this._model.seeds[0]["price"],this._model.seeds[1]["price"]];
         var _loc4_:Array = [this._model.seeds[0]["cName"],this._model.seeds[1]["cName"]];
         this._mainWnd.show(_loc1_,_loc2_,_loc3_,_loc4_);
      }
      
      public function showRefreshEffect(param1:int) : void
      {
         if(this._mainWnd == null)
         {
            return;
         }
         this._mainWnd.showEffect(param1);
      }
      
      private function onTimesRefreshed(param1:CommonEvent) : void
      {
         if(param1 != null && param1.data != null)
         {
            this.api.messageCenter.dispatchEvent(new CommonEvent("__PLUGIN_3_PRICE__",param1.data));
         }
      }
      
      public function executeCommand(param1:int, param2:Object) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         switch(param1)
         {
            case 2001:
               if(param2 == null)
               {
                  break;
               }
               _loc5_ = int(param2["cId"]);
               _loc6_ = int(param2["left"]);
               for each(_loc4_ in this.model.seeds)
               {
                  if(_loc4_["cId"] == _loc5_)
                  {
                     _loc4_["times"] = 2;
                     _loc7_ = {
                        "cId":_loc4_["cId"],
                        "price":_loc4_["price"],
                        "times":_loc4_["times"]
                     };
                     this.api.messageCenter.dispatchEvent(new CommonEvent("__PLUGIN_3_PRICE__",_loc7_));
                     if(this._mainWnd != null)
                     {
                        this._mainWnd.updateItem(_loc3_,_loc4_["price"],_loc4_["times"],_loc6_);
                     }
                     break;
                  }
                  _loc3_++;
               }
               break;
            case 2002:
               for each(_loc4_ in this.model.seeds)
               {
                  if(_loc4_["cId"] == param2._id)
                  {
                     if(this._model.canSell == true)
                     {
                        param2._price = _loc4_["price"] * _loc4_["times"];
                     }
                     break;
                  }
               }
         }
         return null;
      }
      
      public function get api() : IFarmAPI
      {
         return this._api;
      }
      
      public function openYellowVIP() : void
      {
         navigateToURL(new URLRequest("http://pay.qq.com/qzone/index.shtml?aid=farm.zmlft.op"),"_blank");
      }
      
      private function toolTip() : String
      {
         var _loc2_:* = undefined;
         if(this._config == null || this._config["amount"] == undefined)
         {
            return "";
         }
         var _loc1_:Array = this._config["amount"] as Array;
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_["type"] == 5)
            {
               return _loc2_["tip"];
            }
         }
         return "";
      }
      
      public function load(param1:int, param2:IFarmAPI) : Boolean
      {
         this._id = param1;
         this._api = param2;
         return true;
      }
      
      public function createMainUI(param1:Object) : Sprite
      {
         var _loc8_:* = undefined;
         this._config = param1["config"];
         var _loc2_:Array = this._config["time"] as Array;
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc3_:Number = Number(CommonData.serverTime);
         var _loc4_:Date = new Date(_loc3_ * 1000);
         var _loc5_:Date = null;
         var _loc6_:Date = null;
         var _loc7_:Boolean = true;
         for each(_loc8_ in _loc2_)
         {
            _loc5_ = new Date(_loc8_["start"]);
            _loc6_ = new Date(_loc8_["end2"]);
            if(_loc4_.time >= _loc5_.time && _loc4_.time <= _loc6_.time)
            {
               _loc7_ = false;
               this._config["start"] = _loc8_["start"];
               this._config["start2"] = _loc8_["start2"];
               this._config["end1"] = _loc8_["end1"];
               this._config["end2"] = _loc8_["end2"];
               break;
            }
         }
         if(_loc7_ == true)
         {
            return null;
         }
         this._model = new WeekendSaleModel(this.api,this._config);
         this._model.addEventListener(WeekendSaleModel.DATA_TIMES,this.onTimesRefreshed,false,0,true);
         var _loc9_:DisplayObjectContainer = param1["container"] as DisplayObjectContainer;
         if(_loc9_ != null)
         {
            if(this._model.isWeekend == true)
            {
               this._iconEntrance = new this._iconCls2() as MovieClip;
            }
            else
            {
               this._iconEntrance = new this._iconCls1() as MovieClip;
            }
            this._iconEntrance.mouseChildren = false;
            this._iconEntrance.buttonMode = true;
            this._iconEntrance.x = 31;
            this._iconEntrance.y = -2;
            if(_loc9_ != null)
            {
               while(_loc9_.numChildren > 0)
               {
                  _loc9_.removeChildAt(0);
               }
            }
            _loc9_.addChild(this._iconEntrance);
            this._iconEntrance.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._iconEntrance.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
            this._iconEntrance.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
         }
         return null;
      }
      
      public function callProxy(param1:int, param2:*) : Object
      {
         return this._api.executeCommand(this._id,param1,param2);
      }
      
      public function get model() : WeekendSaleModel
      {
         return this._model;
      }
      
      public function enableMc(param1:InteractiveObject, param2:Boolean) : void
      {
         if(param1 != null)
         {
            if(param2 == true)
            {
               param1.mouseEnabled = true;
               param1.filters = null;
            }
            else
            {
               param1.mouseEnabled = false;
               param1.filters = Style.getDisableFilter();
            }
         }
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         var _loc3_:String = param1.type;
         switch(_loc3_)
         {
            case MouseEvent.CLICK:
               if(_loc2_ == this._iconEntrance)
               {
                  EventRecorder.recordMultiValueInCode("160709","1");
                  this._model.init();
                  this._model.addEventListener(WeekendSaleModel.DATA_INITIALIZED,this.onInitialized,false,0,true);
               }
               break;
            case MouseEvent.ROLL_OVER:
               if(_loc2_ == this._iconEntrance)
               {
                  this._api.popMouseTip(this.toolTip());
               }
               break;
            case MouseEvent.ROLL_OUT:
               if(_loc2_ == this._iconEntrance)
               {
                  this._api.hideMouseTip();
               }
         }
      }
      
      private function onInitialized(param1:CommonEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         this.openMainWindow();
         for each(_loc2_ in this.model.seeds)
         {
            _loc3_ = {
               "cId":_loc2_["cId"],
               "price":_loc2_["price"],
               "times":_loc2_["times"]
            };
            this.api.messageCenter.dispatchEvent(new CommonEvent("__PLUGIN_3_PRICE__",_loc3_));
         }
      }
   }
}


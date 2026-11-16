package module.monthBegin
{
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.events.LoaderEvent;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.setTimeout;
   import mc.FBridge.EventRecorder;
   import mc.control.Command;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.common.MaterialProxy;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   import mc.view.proxy.GameProxy;
   
   public class MonthBeginWin extends BaseWindow
   {
      
      private var _monthWidth:int;
      
      private var _monthHeight:int;
      
      private var _refresh:Boolean = true;
      
      private var _loadManger:LoadManager;
      
      private var _monthBeginModel:MonthBeginModel;
      
      private var isGetGift:Boolean = false;
      
      private var _monthBegin:MovieClip;
      
      private var _iniData:Object;
      
      public function MonthBeginWin()
      {
         super();
         this._monthBeginModel = MonthBeginModel.gi();
         this._iniData = GameProxy.iniData;
         this.openWindows();
         this._monthBeginModel.addEventListener(MonthBeginEvent.MONTHBEGIN_LIST,this.monthBeginList,false,0,true);
         this._monthBeginModel.addEventListener(MonthBeginEvent.MONTHBEGIN_GETGIFT,this.monthBeginGetGift,false,0,true);
         this._monthBeginModel.addEventListener(MonthBeginEvent.MONTHBEGIN_PRICE,this.monthBeginPrice,false,0,true);
         this._monthBeginModel.addEventListener(MonthBeginEvent.MONTHBEGIN_LASTBUYTIME,this.monthBeginLastBuyTime,false,0,true);
         this._monthBeginModel.addEventListener(MonthBeginEvent.EVENT_BUY_GIFT_SUCCESS,this.buyGiftSuccess,false,0,true);
         this._monthBeginModel.addEventListener(MonthBeginEvent.EVENT_BUY_MONTHBEGIN_FAIL,this.buyGiftFail,false,0,true);
      }
      
      private function monthBeginPrice(param1:MonthBeginEvent) : void
      {
         this._monthBegin.TotalPrice.text = param1.data.toString();
      }
      
      private function getGiftHandler(param1:MouseEvent) : void
      {
         if(this._monthBeginModel.gainFlag == 0)
         {
            this._monthBeginModel.verifyQBRequest();
            EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_SUCCESS_BUY,0,null,10);
         }
         else
         {
            this._monthBeginModel.getMonthBeginGetGift(this.onGetGift);
            EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_SUCCESS_GETGIFT,0,null,10);
         }
      }
      
      private function RefreshNumHandler(param1:MouseEvent) : void
      {
         this._monthBegin.RefreshType.mouseEnabled = false;
         this._monthBegin.RefreshNum.mouseEnabled = false;
         this._monthBegin.RefreshType.mouseChildren = false;
         this._monthBegin.RefreshNum.mouseChildren = false;
         this._monthBegin.RefreshType.gotoAndStop(2);
         this._monthBegin.RefreshNum.gotoAndStop(2);
         this._monthBeginModel.getMonthBeginRefresh(2,this.onRefreshReturn);
         EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_SUCCESS_REFRESH2,0,null,10);
      }
      
      private function onGetGift(param1:Object) : void
      {
         if(param1.hasOwnProperty("ecode"))
         {
            if(param1["ecode"] == 0)
            {
               if(param1.hasOwnProperty("exp"))
               {
                  Command.getInstance().mainCommand.addExp({"addExp":param1["exp"]});
               }
               if(param1.hasOwnProperty("money"))
               {
                  Command.getInstance().mainCommand.addMoney({"money":-500});
               }
               Command.getInstance().mainCommand.floatWindow("领取成功！");
               this.isGetGift = true;
               MData.getInstance().mainData.reloadUserCrop = true;
               MData.getInstance().mainData.reloadUserItems = true;
               MData.getInstance().mainData.reloadUserMaterial = true;
               MData.getInstance().farmData.reloadUserSeed = true;
               this._monthBeginModel.getMonthBeginList(this.onMonthBeginQueryed);
            }
            else if(param1["ecode"] == -10)
            {
               if(param1.hasOwnProperty("direction"))
               {
                  Command.getInstance().mainCommand.floatWindow(param1["direction"]);
               }
               else
               {
                  Command.getInstance().mainCommand.floatWindow("您还没购买礼包");
               }
               this._monthBeginModel.getMonthBeginList(this.onMonthBeginQueryed);
            }
            else if(param1["ecode"] == -11)
            {
               Command.getInstance().mainCommand.floatWindow("12月回馈礼包领取成功，系统将在1个工作日内将礼品发放到您的牧场账户，请留意系统消息!");
               this._monthBegin.getGiftBtn.Qbi.gotoAndStop(2);
            }
            else if(param1.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.floatWindow(param1["direction"]);
            }
            else
            {
               Command.getInstance().mainCommand.floatWindow("系统繁忙");
            }
         }
         else if(param1.hasOwnProperty("direction"))
         {
            Command.getInstance().mainCommand.floatWindow(param1["direction"]);
         }
         else
         {
            Command.getInstance().mainCommand.floatWindow("系统繁忙");
         }
      }
      
      private function onRefreshReturn(param1:Object) : void
      {
         var _controller:MonthBeginController = null;
         var data:Object = param1;
         if(data.hasOwnProperty("ecode"))
         {
            if(data["ecode"] == 0)
            {
               this._monthBeginModel.LastBuyTime = int(data["gainTimes"]);
               this._monthBeginModel.gainFlag = data["gainFlag"];
               this._monthBeginModel.ItemAry = data["item"];
               this._monthBeginModel.TotalPrice = int(data["price"]);
               if(this.isGetGift == false)
               {
                  if(this._refresh)
                  {
                     Command.getInstance().mainCommand.floatWindow("礼品刷新成功，消耗500金币，成功信息将不再提示。");
                     this._refresh = false;
                  }
                  Command.getInstance().mainCommand.addMoney({"money":-500});
               }
               if(this._monthBeginModel.ItemAry.length >= 18)
               {
                  _controller = new MonthBeginController();
                  _controller.createGreatBox();
               }
            }
            else
            {
               if(data.hasOwnProperty("direction"))
               {
                  Command.getInstance().mainCommand.floatWindow(data["direction"]);
               }
               else
               {
                  Command.getInstance().mainCommand.floatWindow("系统繁忙");
               }
               this.Refresh();
            }
         }
         else
         {
            if(data.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.floatWindow(data["direction"]);
            }
            else
            {
               Command.getInstance().mainCommand.floatWindow("系统繁忙");
            }
            this.Refresh();
         }
         if(this.isGetGift == false)
         {
            setTimeout(function():void
            {
               if(data["gainTimes"] < 3)
               {
                  _monthBegin.RefreshType.mouseEnabled = true;
                  _monthBegin.RefreshType.mouseChildren = true;
                  _monthBegin.RefreshNum.mouseChildren = true;
                  _monthBegin.RefreshType.gotoAndStop(1);
                  _monthBegin.RefreshNum.gotoAndStop(1);
               }
            },2000);
         }
      }
      
      private function buyGiftSuccess(param1:MonthBeginEvent) : void
      {
         this._monthBeginModel.gainFlag = 1;
      }
      
      private function monthBeginList(param1:MonthBeginEvent) : void
      {
         var _loc3_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc7_:* = undefined;
         var _loc8_:MovieClip = null;
         var _loc2_:Array = param1.data;
         if(_loc2_.length == 0)
         {
            return;
         }
         this.RemoveListChild(this._monthBegin.list_mc);
         var _loc4_:int = _loc2_.length >= 18 ? 18 : int(_loc2_.length);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            if(_loc2_[_loc3_]["cType"] == 30)
            {
               _loc2_[_loc3_]["cType"] = 7;
            }
            else if(_loc2_[_loc3_]["cType"] == 4)
            {
               _loc2_[_loc3_]["cType"] = 909090;
               _loc2_[_loc3_]["cId"] = 9001;
            }
            else if(_loc2_[_loc3_]["cType"] == 7)
            {
               _loc2_[_loc3_]["cType"] = 4;
            }
            _loc6_ = MaterialLib.getInstance().getMaterial("monthBeginItem") as MovieClip;
            _loc6_.x = _loc3_ % 6 * 75;
            _loc6_.y = Math.floor(_loc3_ / 6) * 73;
            this._monthBegin.list_mc.addChild(_loc6_);
            this._monthWidth = _loc6_.width;
            this._monthHeight = _loc6_.height;
            _loc6_.alpha = 0;
            _loc6_.addEventListener(Event.ENTER_FRAME,this.inEnterFrame);
            if(_loc2_[_loc3_]["img"] == "")
            {
               _loc7_ = new MaterialProxy();
               _loc7_.setContent(_loc2_[_loc3_]["cType"],_loc2_[_loc3_]["cId"]);
            }
            else
            {
               _loc7_ = new Loader();
               _loc7_.load(new URLRequest(GetCropID.addPrefix("module/mc/icon/monthbegin/gift/") + _loc2_[_loc3_]["img"]));
               _loc7_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.MaterialComplete);
            }
            _loc6_.tipName = "名称：" + _loc2_[_loc3_]["cName"] + "\n最大刷新数量：" + _loc2_[_loc3_]["max"];
            _loc6_.addEventListener(MouseEvent.ROLL_OVER,this.RollOver,false,0,true);
            _loc6_.addChild(_loc7_);
            _loc6_.txt.text = _loc2_[_loc3_]["num"];
            _loc3_++;
         }
         var _loc5_:int = this._monthBeginModel.MaxListNum;
         _loc3_ = _loc4_;
         while(_loc3_ < _loc5_)
         {
            _loc8_ = MaterialLib.getInstance().getMaterial("monthBeginNoGift") as MovieClip;
            _loc8_.x = _loc3_ % 6 * 75;
            _loc8_.y = Math.floor(_loc3_ / 6) * 73;
            this._monthBegin.list_mc.addChild(_loc8_);
            _loc8_.alpha = 0;
            _loc8_.addEventListener(Event.ENTER_FRAME,this.inEnterFrame);
            _loc3_++;
         }
      }
      
      private function completeHandler(param1:LoaderEvent) : void
      {
         if(param1.type == LoaderEvent.QUEUE_COMPLETE)
         {
            this._loadManger.removeEventListener(LoaderEvent.COMPLETE,this.completeHandler);
            this._loadManger.removeEventListener(LoaderEvent.QUEUE_COMPLETE,this.completeHandler);
            this._loadManger.removeEventListener(LoaderEvent.ERROR,this.completeHandler);
            this._monthBegin = param1.item.data as MovieClip;
            if(this._monthBegin == null)
            {
               WControl.close(this);
               return;
            }
            this.addChild(this._monthBegin);
            if(this._monthBegin.close_btn)
            {
               this._monthBegin.close_btn.addEventListener(MouseEvent.CLICK,this.closeBtnHandler,false,0,true);
            }
            if(this._monthBegin.hdBtn)
            {
               this._monthBegin.hdBtn.addEventListener(MouseEvent.CLICK,this.hdBtnHandler,false,0,true);
            }
            if(this._monthBegin.ShareToZone)
            {
               this._monthBegin.ShareToZone.addEventListener(MouseEvent.CLICK,this.shareHandler,false,0,true);
            }
            Cursor.useSystem(true);
            this._monthBeginModel.getMonthBeginList(this.onMonthBeginQueryed);
         }
         else if(param1.type == LoaderEvent.ERROR)
         {
            Command.getInstance().mainCommand.floatWindow("系统繁忙！");
            trace("msg:" + param1.msg);
         }
      }
      
      private function buyGiftFail(param1:MonthBeginEvent) : void
      {
         var _loc2_:* = param1.data;
         if(_loc2_)
         {
            if(_loc2_.hasOwnProperty("direction"))
            {
               Command.getInstance().mainCommand.alertWindow("error",_loc2_["direction"]);
            }
            else
            {
               Command.getInstance().mainCommand.alertWindow("error","系统繁忙，请稍后再试！");
            }
         }
         else
         {
            Command.getInstance().mainCommand.alertWindow("error","系统繁忙，请稍后再试！");
         }
      }
      
      private function RollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",param1.currentTarget.tipName);
         param1.currentTarget.addEventListener(MouseEvent.ROLL_OUT,this.RollOut);
      }
      
      private function openWindows() : void
      {
         var _winsUrl:String = null;
         this.x = 0;
         this.y = 0;
         this.closeVisible = false;
         this.mode = true;
         this.headHeight = 0;
         _winsUrl = this._iniData.submodule.module.(@name == "monthbegin").@url;
         this._loadManger = new LoadManager();
         this._loadManger.add(GetCropID.addPrefix(_winsUrl));
         this._loadManger.addEventListener(LoaderEvent.COMPLETE,this.completeHandler);
         this._loadManger.addEventListener(LoaderEvent.QUEUE_COMPLETE,this.completeHandler);
         this._loadManger.addEventListener(LoaderEvent.ERROR,this.completeHandler);
         this._loadManger.start();
         this.visible = false;
         setTimeout(this.addWindows,500);
      }
      
      private function monthBeginGetGift(param1:MonthBeginEvent) : void
      {
         if(param1.data == 0)
         {
            this._monthBegin.getGiftBtn.gotoAndStop(1);
            if(this._monthBeginModel.LastBuyTime == 0)
            {
               this._monthBegin.RefreshType.mouseEnabled = false;
               this._monthBegin.RefreshNum.mouseEnabled = false;
               this._monthBegin.RefreshType.mouseChildren = false;
               this._monthBegin.RefreshNum.mouseChildren = false;
               this._monthBegin.RefreshType.gotoAndStop(2);
               this._monthBegin.RefreshNum.gotoAndStop(2);
               this._monthBegin.getGiftBtn.mouseEnabled = false;
               this._monthBegin.getGiftBtn.mouseChildren = false;
               this._monthBegin.getGiftBtn.Qbi.gotoAndStop(2);
            }
            else
            {
               this._monthBegin.RefreshType.mouseEnabled = true;
               this._monthBegin.RefreshNum.mouseEnabled = true;
               this._monthBegin.RefreshType.mouseChildren = true;
               this._monthBegin.RefreshNum.mouseChildren = true;
               this._monthBegin.RefreshType.gotoAndStop(1);
               this._monthBegin.RefreshNum.gotoAndStop(1);
               this._monthBegin.getGiftBtn.mouseEnabled = true;
               this._monthBegin.getGiftBtn.mouseChildren = true;
               this._monthBegin.getGiftBtn.gotoAndStop(1);
            }
         }
         else
         {
            this._monthBegin.RefreshType.mouseEnabled = false;
            this._monthBegin.RefreshNum.mouseEnabled = false;
            this._monthBegin.RefreshType.mouseChildren = false;
            this._monthBegin.RefreshNum.mouseChildren = false;
            this._monthBegin.RefreshType.gotoAndStop(2);
            this._monthBegin.RefreshNum.gotoAndStop(2);
            this._monthBegin.getGiftBtn.mouseEnabled = true;
            this._monthBegin.getGiftBtn.mouseChildren = true;
            this._monthBegin.getGiftBtn.gotoAndStop(2);
         }
      }
      
      private function MaterialComplete(param1:Event) : void
      {
         var _loc2_:Bitmap = param1.currentTarget.content as Bitmap;
         _loc2_.x = (this._monthWidth - _loc2_.width) / 2 + 5;
         _loc2_.y = 58 - _loc2_.height;
      }
      
      private function addWindows() : void
      {
         this.visible = true;
      }
      
      private function closeBtnHandler(param1:MouseEvent) : void
      {
         this.removeChild(this._monthBegin);
         this._monthBegin = null;
         WControl.close(this);
      }
      
      private function RemoveListChild(param1:MovieClip) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.numChildren)
         {
            _loc3_ = param1.getChildAt(_loc2_) as DisplayObject;
            if(_loc3_)
            {
               if(_loc3_.parent)
               {
                  _loc3_.removeEventListener(MouseEvent.ROLL_OVER,this.RollOver);
                  _loc3_.addEventListener(Event.ENTER_FRAME,this.outEnterFrame);
               }
            }
            _loc2_++;
         }
      }
      
      private function hdBtnHandler(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest(""),"_blank");
      }
      
      private function shareHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         MonthBeginModel.gi().shareHandler("","QQ牧场12月回馈大礼包强势来袭，海量经验、绝版幼仔、稀有道具等你来拿，还等什么呢？赶快回QQ牧场看看吧。","点击参加>>【QQ牧场12月回馈大礼包】","QQ牧场12月回馈大礼包",this._iniData.submodule.module.(@name == "monthbegin").@shareImg);
      }
      
      private function RollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
         param1.currentTarget.removeEventListener(MouseEvent.ROLL_OUT,this.RollOut);
      }
      
      private function outEnterFrame(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         _loc2_.alpha -= 0.1;
         if(_loc2_.alpha <= 0)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.outEnterFrame);
            _loc2_.parent.removeChild(_loc2_);
            _loc2_ = null;
         }
      }
      
      private function monthBeginLastBuyTime(param1:MonthBeginEvent) : void
      {
         this._monthBegin.buyTime.text = param1.data.toString();
         if(param1.data.toString() == "0")
         {
            this._monthBegin.RefreshType.mouseEnabled = false;
            this._monthBegin.RefreshNum.mouseEnabled = false;
            this._monthBegin.RefreshType.mouseChildren = false;
            this._monthBegin.RefreshNum.mouseChildren = false;
            this._monthBegin.RefreshType.gotoAndStop(2);
            this._monthBegin.RefreshNum.gotoAndStop(2);
            this._monthBegin.getGiftBtn.mouseEnabled = false;
            this._monthBegin.getGiftBtn.mouseChildren = false;
         }
      }
      
      private function RefreshTypeHandler(param1:MouseEvent = null) : void
      {
         if(param1 == null)
         {
            this.isGetGift = true;
         }
         else
         {
            this._monthBegin.RefreshType.mouseEnabled = false;
            this._monthBegin.RefreshNum.mouseEnabled = false;
            this._monthBegin.RefreshType.mouseChildren = false;
            this._monthBegin.RefreshNum.mouseChildren = false;
            this._monthBegin.RefreshType.gotoAndStop(2);
            this._monthBegin.RefreshNum.gotoAndStop(2);
            this.isGetGift = false;
         }
         this._monthBeginModel.getMonthBeginRefresh(1,this.onRefreshReturn);
         EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_SUCCESS_REFRESH1,0,null,10);
      }
      
      private function inEnterFrame(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         _loc2_.alpha += 0.1;
         if(_loc2_.alpha >= 1)
         {
            _loc2_.alpha = 1;
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.inEnterFrame);
         }
      }
      
      private function Refresh() : void
      {
         this._monthBegin.RefreshType.mouseEnabled = true;
         this._monthBegin.RefreshNum.mouseEnabled = true;
         this._monthBegin.RefreshType.mouseChildren = true;
         this._monthBegin.RefreshNum.mouseChildren = true;
         this._monthBegin.RefreshType.gotoAndStop(1);
         this._monthBegin.RefreshNum.gotoAndStop(1);
      }
      
      private function onMonthBeginQueryed(param1:Object) : void
      {
         if(param1.hasOwnProperty("code"))
         {
            if(param1["code"] == 1)
            {
               if(this._monthBegin.RefreshType)
               {
                  this._monthBegin.RefreshType.buttonMode = true;
                  this._monthBegin.RefreshType.addEventListener(MouseEvent.CLICK,this.RefreshTypeHandler,false,0,true);
               }
               if(this._monthBegin.RefreshNum)
               {
                  this._monthBegin.RefreshNum.buttonMode = true;
                  this._monthBegin.RefreshNum.addEventListener(MouseEvent.CLICK,this.RefreshNumHandler,false,0,true);
               }
               if(this._monthBegin.getGiftBtn)
               {
                  this._monthBegin.getGiftBtn.buttonMode = true;
                  this._monthBegin.getGiftBtn.addEventListener(MouseEvent.CLICK,this.getGiftHandler,false,0,true);
               }
               this._monthBeginModel.LastBuyTime = int(param1["gainTimes"]);
               this._monthBeginModel.gainFlag = param1["gainFlag"];
               this._monthBeginModel.ItemAry = param1["item"];
               this._monthBeginModel.TotalPrice = int(param1["price"]);
            }
         }
         else if(param1.hasOwnProperty("direction"))
         {
            Command.getInstance().mainCommand.floatWindow(param1["direction"]);
         }
         else
         {
            Command.getInstance().mainCommand.floatWindow("系统繁忙");
         }
      }
   }
}


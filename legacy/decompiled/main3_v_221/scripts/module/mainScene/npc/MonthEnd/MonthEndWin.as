package module.mainScene.npc.MonthEnd
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qfa.events.LoaderEvent;
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qui.managers.PopUpManager;
   import com.qzone.qui.styles.Style;
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.CommonEvent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.setTimeout;
   import framework.net.vo.ServiceResultVO;
   import module.uitools.UIController;
   import report.EventRecorder;
   
   public class MonthEndWin extends Sprite
   {
      
      private var _monthHeight:int;
      
      private var _monthEnd:MovieClip;
      
      private var _refresh:Boolean = true;
      
      private var isGetGift:Boolean = false;
      
      private var _monthEndModel:MonthEndModel;
      
      private var _controller:UIController;
      
      private var _monthWidth:int;
      
      private var _acceptGifts:Boolean;
      
      private var _loadManger:LoadManager;
      
      private var _msgSuccess:String;
      
      private var _wh:Point;
      
      public function MonthEndWin(param1:UIController)
      {
         super();
         param1.module.app.useSystemCursor(true);
         this._monthEndModel = new MonthEndModel();
         this._controller = param1;
         this._acceptGifts = false;
         this._msgSuccess = "4月回馈礼包领取成功，系统将在1个工作日内将礼品发放到您的农场账户，请留意系统消息!";
         this._monthEndModel.addEventListener(MonthEndModel.MONTHEND_LIST,this.monthEndList,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.MONTHEND_GETGIFT,this.monthEndGetGift,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.MONTHEND_PRICE,this.monthEndPrice,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.MONTHEND_LASTBUYTIME,this.monthEndLastBuyTime,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.EVENT_BUY_GIFT_SUCCESS,this.buyGiftSuccess,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.MONTHEND_REFRESHTOTALMONEY,this.refreshTotalMoney,false,0,true);
         this._monthEndModel.addEventListener(MonthEndModel.EVENT_BUY_MONTHEND_FAIL,this.buyGiftFail,false,0,true);
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         if(param1 == null || param1.body == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         if(param1 == null || param1.result == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null || _loc2_.m_extra == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_.hasOwnProperty("ecode"))
         {
            if(_loc3_["ecode"] == -11)
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":this._msgSuccess,
                  "parent":this._controller.module.app.farmView.stage
               });
               this._monthEnd.getGiftBtn.Qbi.gotoAndStop(2);
            }
            else if(_loc3_.hasOwnProperty("direction"))
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":_loc3_["direction"],
                  "parent":this._controller.module.app.farmView.stage
               });
            }
            else
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"系统繁忙",
                  "parent":this._controller.module.app.farmView.stage
               });
            }
         }
         else if(_loc3_.hasOwnProperty("direction"))
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc3_["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function onPreCheckedError(param1:CommandEvent) : void
      {
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.hasOwnProperty("direction") == true)
         {
            this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc3_["direction"]
            });
         }
         EventRecorder.recordErrorEvent("160892",null,4);
      }
      
      private function onNetError2(param1:CommandEvent) : void
      {
         if(param1 == null || param1.body == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         if(param1 == null || param1.result == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null || _loc2_.m_extra == null)
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_.hasOwnProperty("ecode"))
         {
            if(_loc3_.hasOwnProperty("direction"))
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":_loc3_["direction"],
                  "parent":this._controller.module.app.farmView.stage
               });
            }
            else
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"系统繁忙",
                  "parent":this._controller.module.app.farmView.stage
               });
            }
         }
         else if(_loc3_.hasOwnProperty("direction"))
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc3_["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function RollOver(param1:MouseEvent) : void
      {
         this._controller.showTip(Consts.TIP_NAME_MOUSE,param1.currentTarget.tipName);
         param1.currentTarget.addEventListener(MouseEvent.ROLL_OUT,this.RollOut);
      }
      
      private function buyGiftFail(param1:CommonEvent) : void
      {
         var _loc2_:* = param1.data;
         if(_loc2_)
         {
            if(_loc2_.hasOwnProperty("direction"))
            {
               this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_ERROR,
                  "text":_loc2_["direction"]
               });
            }
            else
            {
               this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_ERROR,
                  "text":"系统繁忙，请稍后再试！"
               });
            }
         }
         else
         {
            this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":"系统繁忙，请稍后再试！"
            });
         }
      }
      
      private function refreshTotalMoney(param1:CommonEvent) : void
      {
         this._monthEnd.TotalMoney.text = this._monthEndModel.RefreshTotalMoney.toString();
      }
      
      private function MaterialComplete(param1:Event) : void
      {
         var _loc2_:Bitmap = param1.currentTarget.content as Bitmap;
         _loc2_.x = (this._monthWidth - _loc2_.width) / 2 + 5;
         _loc2_.y = -1 * (_loc2_.height / 4 - this._monthHeight) - 5;
      }
      
      private function getGiftHandler(param1:MouseEvent) : void
      {
         if(this._monthEndModel.gainFlag == 0)
         {
            this._monthEndModel.payCheck(this.qqBuyPreChecked,this.onPreCheckedError);
            EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_CLICKBUY,null,"月末礼包（点击购买）");
         }
         else
         {
            this._monthEndModel.getMonthEndGetGift(this.onGetGift,this.onNetError);
            EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_GETGIFT,null,"月末礼包（领取礼包）");
         }
      }
      
      private function onGetGift(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null || _loc2_.m_extra == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_.hasOwnProperty("ecode"))
         {
            if(_loc3_["ecode"] == 0)
            {
               if(_loc3_.hasOwnProperty("exp"))
               {
                  Session.getInstance().addReward([{
                     "eType":Consts.ITEM_TYPE_EXP,
                     "eNum":_loc3_["exp"]
                  }]);
               }
               if(_loc3_.hasOwnProperty("money"))
               {
                  Session.getInstance().addReward([{
                     "eType":Consts.ITEM_TYPE_MONEY,
                     "eNum":_loc3_["money"]
                  }]);
               }
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"领取成功！",
                  "parent":this.stage
               });
               this.isGetGift = true;
               this._monthEndModel.getMonthEndList(this.onMonthEndQueryed,this.onNetError);
               this._acceptGifts = true;
            }
            else if(_loc3_["ecode"] == -10)
            {
               if(_loc3_.hasOwnProperty("direction"))
               {
                  this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                     "text":_loc3_["direction"],
                     "parent":this.stage
                  });
               }
               else
               {
                  this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                     "text":"您还没购买礼包",
                     "parent":this.stage
                  });
               }
               this._monthEndModel.getMonthEndList(this.onMonthEndQueryed,this.onNetError);
            }
            else if(_loc3_["ecode"] == -11)
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":this._msgSuccess,
                  "parent":this.stage
               });
               this._monthEnd.getGiftBtn.Qbi.gotoAndStop(2);
            }
            else if(_loc3_.hasOwnProperty("direction"))
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":_loc3_["direction"],
                  "parent":this.stage
               });
            }
            else
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"系统繁忙",
                  "parent":this.stage
               });
            }
         }
         else if(_loc3_.hasOwnProperty("direction"))
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc3_["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function monthEndLastBuyTime(param1:CommonEvent) : void
      {
         this._monthEnd.buyTime.text = param1.data.toString();
         if(param1.data.toString() == "0")
         {
            this.refreshNumClickable = false;
            this.refreshTypeClickable = false;
            this._monthEnd.getGiftBtn.mouseEnabled = false;
            this._monthEnd.getGiftBtn.mouseChildren = false;
         }
      }
      
      private function onRefreshReturn(param1:CommandEvent) : void
      {
         var vo:ServiceResultVO;
         var data:Object = null;
         var e:CommandEvent = param1;
         if(e == null || e.result == null)
         {
            return;
         }
         vo = e.result as ServiceResultVO;
         if(vo == null || vo.m_extra == null)
         {
            return;
         }
         data = vo.m_extra;
         if(data.hasOwnProperty("ecode"))
         {
            if(data["ecode"] == 0)
            {
               this._monthEndModel.LastBuyTime = int(data["gainTimes"]);
               this._monthEndModel.gainFlag = data["gainFlag"];
               this._monthEndModel.ItemAry = data["item"];
               this._monthEndModel.TotalPrice = int(data["price"]);
               this._monthEndModel.RefreshTotalMoney = int(data["refNum"]);
               if(this.isGetGift == false)
               {
                  if(this._refresh)
                  {
                     this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                        "text":"礼品刷新成功，消耗500金币，成功信息将不再提示。",
                        "parent":this.stage
                     });
                     this._refresh = false;
                  }
                  Session.getInstance().addReward([{
                     "eType":Consts.ITEM_TYPE_MONEY,
                     "eNum":-500
                  }]);
               }
               if(this._monthEndModel.ItemAry.length >= 18)
               {
                  this._controller.openWindow(Consts.WINDOW_NAME_ALERT,{
                     "type":Consts.ALERT_TYPE_PIC2,
                     "picUrl":"module/ui/icons/monthend.png",
                     "text":"功夫不费有心人，恭喜您刷新出了本轮礼包的全部隐藏礼品。"
                  });
               }
            }
            else if(data.hasOwnProperty("direction"))
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":data["direction"],
                  "parent":this.stage
               });
            }
            else
            {
               this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
                  "text":"系统繁忙",
                  "parent":this.stage
               });
            }
         }
         else if(data.hasOwnProperty("direction"))
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":data["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
         if(this.isGetGift == false)
         {
            setTimeout(function():void
            {
               if(data["gainTimes"] < 3)
               {
                  refreshTypeClickable = true;
                  refreshNumClickable = true;
               }
            },2000);
         }
      }
      
      private function onMonthEndQueryed(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null || _loc2_.m_extra == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_.hasOwnProperty("code"))
         {
            if(_loc3_["code"] == 1)
            {
               if(this._monthEnd.RefreshType)
               {
                  this._monthEnd.RefreshType.addEventListener(MouseEvent.CLICK,this.RefreshTypeHandler,false,0,true);
               }
               if(this._monthEnd.RefreshNum)
               {
                  this._monthEnd.RefreshNum.addEventListener(MouseEvent.CLICK,this.RefreshNumHandler,false,0,true);
               }
               if(this._monthEnd.getGiftBtn)
               {
                  this._monthEnd.getGiftBtn.buttonMode = true;
                  this._monthEnd.getGiftBtn.addEventListener(MouseEvent.CLICK,this.getGiftHandler,false,0,true);
               }
               this._monthEndModel.LastBuyTime = int(_loc3_["gainTimes"]);
               this._monthEndModel.gainFlag = _loc3_["gainFlag"];
               this._monthEndModel.ItemAry = _loc3_["item"];
               this._monthEndModel.TotalPrice = int(_loc3_["price"]);
               this._monthEndModel.RefreshTotalMoney = int(_loc3_["refNum"]);
            }
         }
         else if(_loc3_.hasOwnProperty("direction"))
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc3_["direction"],
               "parent":this.stage
            });
         }
         else
         {
            this._controller.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":"系统繁忙",
               "parent":this.stage
            });
         }
      }
      
      private function monthEndPrice(param1:CommonEvent) : void
      {
         this._monthEnd.TotalPrice.text = param1.data.toString();
      }
      
      private function completeHandler(param1:LoaderEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Date = null;
         if(param1.type == LoaderEvent.COMPLETE)
         {
            this._monthEnd = param1.item.data as MovieClip;
            if(this._monthEnd == null)
            {
               PopUpManager.removePopUp(this);
               return;
            }
            this.addChild(this._monthEnd);
            this._monthEnd.x = -1 * this._monthEnd.width / 2;
            this._monthEnd.y = -1 * this._monthEnd.height / 2;
            if(this._monthEnd.close_btn)
            {
               this._monthEnd.close_btn.addEventListener(MouseEvent.CLICK,this.closeBtnHandler,false,0,true);
            }
            if(this._monthEnd.hdBtn)
            {
               this._monthEnd.hdBtn.addEventListener(MouseEvent.CLICK,this.hdBtnHandler,false,0,true);
            }
            if(this._monthEnd.ShareToZone)
            {
               this._monthEnd.ShareToZone.addEventListener(MouseEvent.CLICK,this.shareHandler,false,0,true);
            }
            if(this._monthEnd["tfEndTime"] != undefined)
            {
               _loc2_ = Settings.getInstance().getMonthEnds("0","end");
               _loc3_ = new Date(_loc2_);
               this._monthEnd["tfEndTime"].text = this.formatDate(_loc3_);
            }
            this._controller.useSystemCursor(true);
            this._monthEndModel.getMonthEndList(this.onMonthEndQueryed,this.onNetError);
            this._loadManger.removeEventListener(LoaderEvent.COMPLETE,this.completeHandler);
            this._loadManger.removeEventListener(LoaderEvent.ERROR,this.completeHandler);
         }
         else if(param1.type == LoaderEvent.ERROR)
         {
            this._controller.openFloat("系统繁忙，请稍后再试！",this._controller.module.app.farmView.stage);
         }
      }
      
      private function buyGiftSuccess(param1:CommonEvent) : void
      {
         this._monthEndModel.gainFlag = 1;
         EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_BUYSUCCESS,null,"月末礼包（购买成功）");
      }
      
      private function RemoveChild() : void
      {
         var _loc1_:DisplayObject = null;
         while(this.numChildren)
         {
            _loc1_ = this.getChildAt(0) as DisplayObject;
            this.removeChild(_loc1_);
            _loc1_ = null;
         }
      }
      
      public function openWindows() : void
      {
         this._loadManger = new LoadManager(CommonData.applicationDomain);
         this._loadManger.add(Utils.addPrefix(Settings.getInstance().getMonthEnds("0","url")));
         this._loadManger.addEventListener(LoaderEvent.COMPLETE,this.completeHandler);
         this._loadManger.addEventListener(LoaderEvent.ERROR,this.completeHandler);
         this._loadManger.start();
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
      
      private function formatDate(param1:Date) : String
      {
         var _loc2_:String = String(param1.getFullYear());
         var _loc3_:String = param1.getMonth() + 1 > 9 ? String(param1.getMonth() + 1) : "0" + (param1.getMonth() + 1);
         var _loc4_:String = param1.getDate() > 9 ? String(param1.getDate()) : "0" + param1.getDate();
         return _loc2_ + "-" + _loc3_ + "-" + _loc4_;
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
      
      private function closeBtnHandler(param1:MouseEvent) : void
      {
         this._refresh = true;
         this._wh = new Point(this.x,this.y);
         this.RemoveChild();
         PopUpManager.removePopUp(this);
         if(this._acceptGifts)
         {
            Session.getInstance().addReward([{"eType":Consts.ITEM_TYPE_DOGFOOD},{"eType":Consts.ITEM_TYPE_TOOL},{"eType":Consts.ITEM_TYPE_SEED},{"eType":Consts.ITEM_TYPE_DECORATE}]);
         }
      }
      
      private function set refreshTypeClickable(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this._monthEnd.RefreshType.mouseEnabled = true;
            this._monthEnd.RefreshType.filters = null;
         }
         else
         {
            this._monthEnd.RefreshType.mouseEnabled = false;
            this._monthEnd.RefreshType.filters = Style.getDisableFilter();
         }
      }
      
      private function hdBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = Settings.getInstance().getMonthEnds("0","blog");
         if(_loc2_ == null || _loc2_ == "")
         {
            return;
         }
         navigateToURL(new URLRequest(_loc2_),"_blank");
      }
      
      private function shareHandler(param1:MouseEvent) : void
      {
         this._monthEndModel.shareHandler("","QQ农场回馈大礼包强势来袭，海量经验、绝版稀有种子道具等你来拿，还等什么呢？","点击参加>>【QQ农场月促大礼包】","QQ农场月促大礼包",Settings.getInstance().getMonthEnds("0","shareImg"));
      }
      
      private function set refreshNumClickable(param1:Boolean) : void
      {
         if(param1 == true)
         {
            this._monthEnd.RefreshNum.mouseEnabled = true;
            this._monthEnd.RefreshNum.filters = null;
         }
         else
         {
            this._monthEnd.RefreshNum.mouseEnabled = false;
            this._monthEnd.RefreshNum.filters = Style.getDisableFilter();
         }
      }
      
      private function qqBuyPreChecked(param1:CommandEvent) : void
      {
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_["code"] == "1")
         {
            if(_loc3_["open"] == "1")
            {
               this._monthEndModel.buyInGame(null,1);
               return;
            }
         }
         EventRecorder.recordSueecssEvent("160892",null);
      }
      
      private function monthEndGetGift(param1:CommonEvent) : void
      {
         if(param1.data == 0)
         {
            this._monthEnd.getGiftBtn.gotoAndStop(1);
            if(this._monthEndModel.LastBuyTime == 0)
            {
               this.refreshNumClickable = false;
               this.refreshTypeClickable = false;
               this._monthEnd.getGiftBtn.mouseEnabled = false;
               this._monthEnd.getGiftBtn.mouseChildren = false;
               this._monthEnd.getGiftBtn.Qbi.gotoAndStop(2);
            }
            else
            {
               this.refreshNumClickable = true;
               this.refreshTypeClickable = true;
               this._monthEnd.getGiftBtn.mouseEnabled = true;
               this._monthEnd.getGiftBtn.mouseChildren = true;
               this._monthEnd.getGiftBtn.gotoAndStop(1);
            }
         }
         else
         {
            this.refreshNumClickable = false;
            this.refreshTypeClickable = false;
            this._monthEnd.getGiftBtn.mouseEnabled = true;
            this._monthEnd.getGiftBtn.mouseChildren = true;
            this._monthEnd.getGiftBtn.gotoAndStop(2);
            this._monthEndModel.RefreshTotalMoney = 0;
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
            this.refreshTypeClickable = false;
            this.refreshNumClickable = false;
            this.isGetGift = false;
         }
         this._monthEndModel.getMonthEndRefresh(1,this.onRefreshReturn,this.onNetError2);
         EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_REFRESHTYPE,null,"月末礼包（刷新礼包种类）");
      }
      
      private function RollOut(param1:MouseEvent) : void
      {
         this._controller.hideTip();
         param1.currentTarget.removeEventListener(MouseEvent.ROLL_OUT,this.RollOut);
      }
      
      private function monthEndList(param1:CommonEvent) : void
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
         this.RemoveListChild(this._monthEnd.list_mc);
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
            _loc6_ = Utils.getMaterial("monthEndItem") as MovieClip;
            _loc6_.x = _loc3_ % 6 * 75;
            _loc6_.y = Math.floor(_loc3_ / 6) * 73;
            this._monthEnd.list_mc.addChild(_loc6_);
            this._monthWidth = _loc6_.width;
            this._monthHeight = _loc6_.height;
            _loc6_.alpha = 0;
            _loc6_.addEventListener(Event.ENTER_FRAME,this.inEnterFrame);
            if(_loc2_[_loc3_]["img"] == "")
            {
               _loc7_ = new MaterialProxy();
               _loc7_.setContent(_loc2_[_loc3_]["cType"],_loc2_[_loc3_]["cId"]);
               _loc7_.x += 8;
               _loc7_.y -= 3;
            }
            else
            {
               _loc7_ = new Loader();
               _loc7_.load(new URLRequest(Utils.addPrefix("module/ui/icons/") + _loc2_[_loc3_]["img"]));
               _loc7_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.MaterialComplete);
            }
            _loc6_.tipName = "名称：" + _loc2_[_loc3_]["cName"] + "\n最大刷新数量：" + _loc2_[_loc3_]["max"];
            _loc6_.addEventListener(MouseEvent.ROLL_OVER,this.RollOver,false,0,true);
            _loc6_.addChild(_loc7_);
            _loc6_.txt.text = _loc2_[_loc3_]["num"];
            _loc3_++;
         }
         var _loc5_:int = this._monthEndModel.MaxListNum;
         _loc3_ = _loc4_;
         while(_loc3_ < _loc5_)
         {
            _loc8_ = Utils.getMaterial("monthEndNoGift") as MovieClip;
            _loc8_.x = _loc3_ % 6 * 75;
            _loc8_.y = Math.floor(_loc3_ / 6) * 73;
            this._monthEnd.list_mc.addChild(_loc8_);
            _loc8_.alpha = 0;
            _loc8_.addEventListener(Event.ENTER_FRAME,this.inEnterFrame);
            _loc3_++;
         }
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
      
      private function RefreshNumHandler(param1:MouseEvent) : void
      {
         this.refreshTypeClickable = false;
         this.refreshNumClickable = false;
         this._monthEndModel.getMonthEndRefresh(2,this.onRefreshReturn,this.onNetError2);
         EventRecorder.recordSueecssEvent(EventRecorder.MONTHEND_REFRESHNUMBER,null,"月末礼包（刷新礼包数量）");
      }
   }
}


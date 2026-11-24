package plugins.external.weekendSale
{
   import common.view.MaterialProxy;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BlurFilter;
   import flash.utils.setTimeout;
   import report.EventRecorder;
   
   public class MainWindowWrapper
   {
      
      private var _eff1:Sprite;
      
      private var _eff2:Sprite;
      
      private var _Class:Class = MainWindowWrapper__Class;
      
      private var _win:MovieClip;
      
      private var _control:WeekendPlugin;
      
      private const NUM_HEIGHT:int = 40;
      
      private var _seed1:MaterialProxy;
      
      private var _seed2:MaterialProxy;
      
      private var _d:int;
      
      private const TIMES:Array = [2,3,4,8,10,12];
      
      private var _stop:Boolean;
      
      private var _curEff:Sprite;
      
      private const MAX_SPEED:int = 20;
      
      private var _blurs:Array;
      
      private var _playing:Boolean;
      
      private var _tempResult:Object;
      
      private var _effClass:Class = MainWindowWrapper__effClass;
      
      private var _stopAt:int;
      
      public function MainWindowWrapper(param1:WeekendPlugin)
      {
         super();
         this._control = param1;
         this._d = 0;
         this._curEff = null;
         this._stop = false;
         this._stopAt = 0;
         this._playing = false;
         this._blurs = [new BlurFilter(0,4,BitmapFilterQuality.LOW),new BlurFilter(0,8,BitmapFilterQuality.LOW),new BlurFilter(0,16,BitmapFilterQuality.LOW)];
      }
      
      private function share() : void
      {
         var _loc1_:String = "mod=cgi_qzshare_onekey";
         _loc1_ += "url=" + encodeURIComponent("http://rc.qzone.qq.com/myhome/353?ref=LFT");
         _loc1_ += "&desc=" + encodeURIComponent("");
         _loc1_ += "&summary=" + encodeURIComponent("QQ农场周末乐翻天！刷倍数？翻倍卖出活动产物，3倍、4倍、8倍、10倍......刷到多少卖多少，由你决定！");
         _loc1_ += "&title=" + encodeURIComponent("点击参加>>【QQ农场周末乐翻天活动】");
         _loc1_ += "&site=" + encodeURIComponent("QQ农场");
         _loc1_ += "&pics=" + encodeURIComponent("http://qzonestyle.gtimg.cn/qzone/sns/pics/2012/2012042639.jpg");
         if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open",_loc1_);
         }
      }
      
      public function updateItem(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(this._win.currentFrame != 2)
         {
            return;
         }
         var _loc5_:* = this._win["item" + param1];
         if(_loc5_ == undefined || _loc5_ == null)
         {
            return;
         }
         _loc5_["tfTimes"].gotoAndStop(param3 as int);
         _loc5_["tfP1"].text = "现单价：金币 " + param2 * param3;
         _loc5_["tfP0"].text = "原单价：金币 " + param2;
         if(param4 <= 0)
         {
            this._control.enableMc(_loc5_["btnSell"],false);
         }
      }
      
      private function buy(param1:int) : void
      {
         if(this._control.model.seeds == null)
         {
            return;
         }
         var _loc2_:CommonEvent = new CommonEvent("ShowBuySeed",{"id":this._control.model.seeds[param1]["cId"]});
         this._control.api.messageCenter.dispatchEvent(_loc2_);
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         if(this._playing == true)
         {
            return;
         }
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = _loc2_.name;
         if(_loc3_ == "btnBuySeed")
         {
            if(_loc2_.parent.name == "item0")
            {
               this.buy(0);
            }
            else
            {
               this.buy(1);
            }
         }
         else if(_loc3_ == "btnRefresh")
         {
            if(_loc2_.parent.name == "item0")
            {
               this.refresh(0);
            }
            else
            {
               this.refresh(1);
            }
         }
         else if(_loc3_ == "btnSell")
         {
            if(_loc2_.parent.name == "item0")
            {
               this.sell(0);
            }
            else
            {
               this.sell(1);
            }
         }
         else if(_loc3_ == "btnShare")
         {
            this.share();
         }
         else if(_loc3_ == "btnClose")
         {
            this.hide();
         }
         else if(_loc3_ == "yellowBtn_vip")
         {
            this._control.openYellowVIP();
         }
      }
      
      public function hide() : void
      {
         this._curEff = null;
         this._control.api.hidePopUp(this._win);
      }
      
      private function sell(param1:int) : void
      {
         var e:CommonEvent;
         var index:int = param1;
         if(this._control.model.seeds == null)
         {
            return;
         }
         this._control.api.messageCenter.addEventListener("NoCropInWarehouse",function(param1:CommonEvent):void
         {
            param1.currentTarget.removeEventListener(param1.type,arguments.callee);
            param1.stopImmediatePropagation();
            var _loc3_:Array = _control.model.seeds;
            if(_loc3_ == null)
            {
               return;
            }
            var _loc4_:int = 0;
            if(_loc3_[1]["cId"] == param1.data)
            {
               _loc4_ = 1;
            }
            _control.api.alert(3,"周末乐翻天","对不起，您还没有收获" + _loc3_[_loc4_]["cName"] + "，快去商店买种子种吧！",0,0,null);
            _control.enableMc(_win["item" + _loc4_]["btnSell"],false);
         });
         e = new CommonEvent("ShowWarehouseSell",{"id":this._control.model.seeds[index]["cId"]});
         this._control.api.messageCenter.dispatchEvent(e);
      }
      
      private function onEffectLoop(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Sprite = null;
         if(this._curEff == null || this._stop == true && this._stopAt == 0)
         {
            if(this._eff1.parent != null)
            {
               this._eff1.parent.removeChild(this._eff1);
            }
            if(this._eff2.parent != null)
            {
               this._eff2.parent.removeChild(this._eff2);
            }
            this._win["item0"]["tfTimes"].visible = true;
            this._win["item1"]["tfTimes"].visible = true;
            param1.target.removeEventListener(Event.ENTER_FRAME,this.onEffectLoop);
            this._playing = false;
            return;
         }
         var _loc2_:Number = 0;
         if(this._stop == false)
         {
            this._d += 2;
            if(this._d >= 90)
            {
               this._d = 90;
            }
            _loc2_ = this.MAX_SPEED * Math.sin(this._d * Math.PI / 180);
            this._eff1.y += _loc2_;
            this._eff2.y += _loc2_;
         }
         else
         {
            this._d -= 2;
            if(this._d <= 10)
            {
               this._d = 10;
               if(Math.floor(this._eff1.y / this.NUM_HEIGHT) as int == this._stopAt || Math.floor(this._eff2.y / this.NUM_HEIGHT) as int == this._stopAt)
               {
                  if(this._tempResult != null)
                  {
                     _loc3_ = int(this._tempResult["index"]);
                     this._win["item" + _loc3_]["tfTimes"].visible = true;
                     this._win["item" + _loc3_]["tfTimes"].gotoAndStop(this._tempResult["times"] as int);
                     this._win["item" + _loc3_]["tfP1"].text = "现单价：金币 " + this._tempResult["times"] * this._tempResult["price"];
                     this._win["item" + _loc3_]["tfP0"].text = "原单价：金币 " + this._tempResult["price"];
                     this._tempResult = null;
                  }
                  this._eff1.parent.removeChild(this._eff1);
                  this._eff2.parent.removeChild(this._eff2);
                  param1.target.removeEventListener(Event.ENTER_FRAME,this.onEffectLoop);
                  this._playing = false;
                  return;
               }
            }
            _loc2_ = this.MAX_SPEED * Math.sin(this._d * Math.PI / 180);
            this._eff1.y += _loc2_;
            this._eff2.y += _loc2_;
         }
         if(this._d == 24)
         {
            this._eff1.filters = [this._blurs[0]];
            this._eff2.filters = [this._blurs[0]];
         }
         else if(this._d == 60)
         {
            this._eff1.filters = [this._blurs[1]];
            this._eff2.filters = [this._blurs[1]];
         }
         else if(this._d == 80)
         {
            this._eff1.filters = [this._blurs[2]];
            this._eff2.filters = [this._blurs[2]];
         }
         if(this._curEff.y > this._curEff.height)
         {
            _loc4_ = this._curEff;
            if(this._curEff == this._eff1)
            {
               this._curEff = this._eff2;
            }
            else
            {
               this._curEff = this._eff1;
            }
            _loc4_.y = this._curEff.y - this._curEff.height - this.NUM_HEIGHT / 2;
         }
      }
      
      private function onRefreshed(param1:CommonEvent) : void
      {
         var _loc2_:int = 0;
         param1.target.removeEventListener(param1.type,this.onRefreshed);
         if(param1.data == null)
         {
            this._tempResult = null;
            this._stopAt = 0;
         }
         else
         {
            this._tempResult = param1.data;
            _loc2_ = 0;
            while(_loc2_ < this.TIMES.length)
            {
               if(this.TIMES[_loc2_] == this._tempResult["times"] as int)
               {
                  this._stopAt = _loc2_;
                  break;
               }
               _loc2_++;
            }
         }
         this.stopEffectLater(2000);
      }
      
      private function refresh(param1:int) : void
      {
         this._control.openRefreshWindow(param1);
         EventRecorder.recordMultiValueInCode("160709","2");
      }
      
      public function showEffect(param1:int) : void
      {
         var _loc5_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.TIMES.length);
         if(this._eff1 == null)
         {
            this._eff1 = new Sprite();
            this._eff2 = new Sprite();
            _loc5_ = null;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc5_ = new this._effClass() as MovieClip;
               _loc5_.gotoAndStop(this.TIMES[_loc2_]);
               _loc5_.y = _loc2_ * -1 * this.NUM_HEIGHT;
               this._eff1.addChild(_loc5_);
               _loc5_ = new this._effClass() as MovieClip;
               _loc5_.gotoAndStop(this.TIMES[_loc2_]);
               _loc5_.y = _loc2_ * -1 * this.NUM_HEIGHT;
               this._eff2.addChild(_loc5_);
               _loc2_++;
            }
         }
         var _loc4_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(this._win["item" + param1]["tfTimes"].currentFrame == this.TIMES[_loc2_])
            {
               _loc4_ = _loc2_;
               this._win["item" + param1]["tfTimes"].visible = false;
               break;
            }
            _loc2_++;
         }
         this._eff1.y = _loc4_ * this.NUM_HEIGHT;
         this._eff1.x = 24;
         this._win["item" + param1]["effectHolder"].addChild(this._eff1);
         this._eff2.y = this._eff1.y - this._eff1.height - this.NUM_HEIGHT / 2;
         this._eff2.x = 24;
         this._win["item" + param1]["effectHolder"].addChild(this._eff2);
         this._curEff = this._eff1;
         this._d = 0;
         this._stop = false;
         this._win["item" + param1].addEventListener(Event.ENTER_FRAME,this.onEffectLoop,false,0,true);
         this._playing = true;
         this._control.model.addEventListener(WeekendSaleModel.DATA_TIMES,this.onRefreshed,false,0,true);
      }
      
      private function stopEffectLater(param1:int = 2000) : void
      {
         var timeout:int = param1;
         if(timeout > 0)
         {
            setTimeout(function():void
            {
               _stop = true;
            },timeout);
         }
         else
         {
            this._stop = true;
         }
      }
      
      public function show(param1:Array, param2:Array, param3:Array, param4:Array) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         if(this._win == null)
         {
            this._win = new this._Class() as MovieClip;
            this._win.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
            if(!this._control.model.isShowNotice)
            {
               this._win.gotoAndStop(2);
               this._seed1 = new MaterialProxy("small");
               this._seed1.x = -12;
               this._seed1.setContent("1",param1[0]);
               this._win["item0"]["holder"].addChildAt(this._seed1,0);
               this._seed2 = new MaterialProxy("small");
               this._seed2.x = -12;
               this._seed2.setContent("1",param1[1]);
               this._win["item1"]["holder"].addChildAt(this._seed2,0);
               this._win["tfDesc"].text = this._control.model.desc2;
            }
            else
            {
               this._win.gotoAndStop(1);
               this._win["item0"].text = this._control.model.startDay;
               this._win["item1"].text = this._control.model.startDayWeek;
               this._win["item2"].text = this._control.model.duration;
               this._win["item3"].text = this._control.model.durationWeek;
               this._win["tfDesc"].text = this._control.model.desc1;
            }
            this._win["tfTitle"].text = this._control.model.durationFull;
         }
         if(this._win.currentFrame == 1)
         {
            this._win["introBar"].visible = false;
            this._win["yellowBtn_vip"].visible = false;
            this._win["btnShare"].x = 379.4;
            this._win["btnShare"].y = 105.5;
         }
         else if(this._win.currentFrame == 2)
         {
            this._win["introBar"].visible = true;
            this._win["yellowBtn_vip"].visible = true;
            this._win["btnShare"].x = 386;
            this._win["btnShare"].y = 406.8;
            this._win["item0"]["tfTimes"].gotoAndStop(param2[0] as int);
            this._win["item0"]["tfP1"].text = "现单价：金币 " + param3[0] * param2[0];
            this._win["item0"]["tfP0"].text = "原单价：金币 " + param3[0];
            this._win["item0"]["tfName"].text = param4[0];
            this._win["item1"]["tfTimes"].gotoAndStop(param2[1] as int);
            this._win["item1"]["tfP1"].text = "现单价：金币 " + param3[1] * param2[1];
            this._win["item1"]["tfP0"].text = "原单价：金币 " + param3[1];
            this._win["item1"]["tfName"].text = param4[1];
            _loc5_ = this._control.model.canSell;
            _loc6_ = this._control.model.canRefresh;
            this._control.enableMc(this._win["item0"]["btnRefresh"],_loc6_);
            this._control.enableMc(this._win["item1"]["btnRefresh"],_loc6_);
            this._control.enableMc(this._win["item0"]["btnSell"],_loc5_);
            this._control.enableMc(this._win["item1"]["btnSell"],_loc5_);
         }
         this._control.api.showPopUp(this._win,true);
      }
   }
}


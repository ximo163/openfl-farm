package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class MainWindowWrapper
   {
      
      private var _win:MovieClip;
      
      private var _Class:Class = MainWindowWrapper__Class;
      
      private var _EffectCls:Class = MainWindowWrapper__EffectCls;
      
      private var _control:FairyPlugin;
      
      public function MainWindowWrapper(param1:FairyPlugin)
      {
         super();
         this._control = param1;
         this._control.model.addEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyBought,false,0,true);
      }
      
      private function buy(param1:int) : void
      {
         var onConfirmed:Function = null;
         var name:String = null;
         var index:int = param1;
         onConfirmed = function():void
         {
            _control.confirmBuySprite(index,1);
            _control.api.reportReturnCode("160563",(index + 1).toString());
         };
         var my:Object = this._control.model.fairyItem;
         if(my != null && my["itemId"] != undefined && my["itemId"] != 0)
         {
            name = "小仙女";
            if(my["itemId"] == FairyPlugin.BASE_ID + 1)
            {
               name = "土地公公";
            }
            else if(my["itemId"] == FairyPlugin.BASE_ID + 2)
            {
               name = "财神爷";
            }
            else if(my["itemId"] == FairyPlugin.BASE_ID + 3)
            {
               name = "仙皇";
            }
            this._control.api.confirm("提示","您的农场已经有" + name + "守护，更换小仙将不保留原小仙的守护时间和功德箱内的金币。" + "您确定要更换小仙么？",null,0,0,true,false,onConfirmed);
         }
         else
         {
            onConfirmed();
         }
      }
      
      private function onFairyBought(param1:CommonEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:Object = param1.data;
         if(_loc2_ != null && _loc2_["succ"] == true)
         {
            _loc3_ = int(_loc2_["id"]);
            _loc4_ = this._control.model.getFairyById(_loc3_);
            if(_loc4_ != null)
            {
               this._control.updateFairy(_loc4_,true);
               this._control.api.hidePopUp(this._win);
            }
         }
      }
      
      private function update(param1:Array, param2:Boolean = false) : void
      {
         var _loc5_:Object = null;
         var _loc6_:MovieClip = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this._win["mcHired"].visible = false;
         this._win["btnRenew"].visible = false;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            _loc3_ = _loc5_["id"] - FairyPlugin.BASE_ID;
            if(_loc3_ >= 0 && _loc3_ <= 3)
            {
               if(this._control.model.fairyItem != null && this._control.model.fairyItem["itemId"] == _loc5_["id"])
               {
                  _loc4_ = int(this._control.model.fairyItem["lv"]);
                  this._win["xian" + _loc3_]["star"].gotoAndStop(_loc4_);
                  this._win["xian" + _loc3_]["max"].text = FairyPlugin.MAX_DONATE[_loc4_];
                  this._win["xian" + _loc3_]["tf"].text = this._control.model.fairyItem["rate"] + "%";
                  this._win["btnHire" + _loc3_].visible = false;
                  this._win["btnRenew"].visible = true;
                  this._win["mcHired"].visible = true;
                  this._win["btnRenew"].x = 205 + (_loc3_ < 3 ? _loc3_ + 1 : 0) * 170;
                  this._win["mcHired"].x = 205 + (_loc3_ < 3 ? _loc3_ + 1 : 0) * 170;
               }
               else
               {
                  _loc4_ = int(_loc5_["lv"]);
                  this._win["xian" + _loc3_]["star"].gotoAndStop(_loc4_);
                  this._win["xian" + _loc3_]["max"].text = FairyPlugin.MAX_DONATE[_loc4_];
                  this._win["xian" + _loc3_]["tf"].text = _loc5_["rate"] + "%";
                  this._win["btnHire" + _loc3_].visible = true;
                  if(param2 == true)
                  {
                     TweenLite.to(this._win["xian" + _loc3_],0.5,{"alpha":0});
                     _loc6_ = new this._EffectCls() as MovieClip;
                     _loc6_.x = 205 + (_loc3_ < 3 ? _loc3_ + 1 : 0) * 170;
                     _loc6_.y = 340;
                     _loc6_.name = "star_" + _loc3_;
                     this._win.addChild(_loc6_);
                     _loc6_.addEventListener(Event.ENTER_FRAME,this.onEffectEnd,false,0,true);
                  }
               }
            }
         }
      }
      
      private function onEffectEnd(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null || _loc2_.name == "")
         {
            return;
         }
         if(_loc2_.currentFrame == 6)
         {
            _loc3_ = parseInt(_loc2_.name.charAt(5));
            TweenLite.killTweensOf(this._win["xian" + _loc3_],false);
            this._win["xian" + _loc3_].alpha = 0;
            TweenLite.to(this._win["xian" + _loc3_],0.8,{"alpha":1});
            this._control.enableMc(this._win["btnRefresh"] as InteractiveObject,true);
         }
         else if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.stop();
            if(_loc2_.parent != null)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEffectEnd);
            _loc2_ = null;
         }
      }
      
      public function get container() : DisplayObjectContainer
      {
         return this._win;
      }
      
      private function onFairyRefreshed(param1:CommonEvent) : void
      {
         this._control.model.removeEventListener(FairyModel.DATA_FAIRY_CHANGED,this.onFairyRefreshed);
         if(param1.data != null)
         {
            this.update(param1.data["list"],true);
            if(this._control.model.fairyItem != null && this._control.model.fairyItem["itemId"] != 0)
            {
               this._win["btnRenew"].visible = true;
            }
         }
      }
      
      private function onFairyRenew(param1:CommonEvent) : void
      {
         this._control.model.removeEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyRenew);
         var _loc2_:Object = param1.data;
         if(_loc2_ != null && _loc2_["succ"] == true)
         {
            this._control.api.popFloatTip(0,"续费小仙" + _loc2_["month"] + "个月成功！",this._win);
         }
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:String = param1.type;
         var _loc3_:String = param1.target.name;
         switch(_loc2_)
         {
            case MouseEvent.CLICK:
               if(_loc3_ == "btnHire0")
               {
                  this.buy(0);
               }
               else if(_loc3_ == "btnHire1")
               {
                  this.buy(1);
               }
               else if(_loc3_ == "btnHire2")
               {
                  this.buy(2);
               }
               else if(_loc3_ == "btnHire3")
               {
                  this.buy(3);
               }
               else if(_loc3_ == "btnRefresh")
               {
                  this._control.model.randomSprite();
                  this._control.model.addEventListener(FairyModel.DATA_FAIRY_CHANGED,this.onFairyRefreshed,false,0,true);
                  this._control.enableMc(param1.target as InteractiveObject,false);
                  this._control.api.reportSuccessError("160565",null);
               }
               else if(_loc3_ == "btnRenew")
               {
                  this._control.confirmBuySprite(this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID,1);
                  this._control.model.addEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyRenew,false,0,true);
               }
               else if(_loc3_ == "btnClose")
               {
                  this._control.api.hidePopUp(this._win);
               }
               else if(_loc3_ == "btnShare")
               {
                  _loc4_ = "mod=cgi_qzshare_onekey";
                  _loc4_ = _loc4_ + ("url=" + encodeURIComponent(""));
                  _loc4_ = _loc4_ + ("&desc=" + encodeURIComponent(""));
                  _loc4_ = _loc4_ + ("&summary=" + encodeURIComponent("QQ农场小仙系统华丽上线，小仙女、财神爷、土地公随您挑，赶快进农场请小仙守护您的农场吧！"));
                  _loc4_ = _loc4_ + ("&title=" + encodeURIComponent("玩QQ农场，请小仙！"));
                  _loc4_ = _loc4_ + ("&site=" + encodeURIComponent("QQ农场"));
                  _loc4_ = _loc4_ + ("&pics=" + encodeURIComponent("http://qzonestyle.gtimg.cn/qzone/sns/pics/2012/2012021410.jpg"));
                  if(ExternalInterface.available)
                  {
                     ExternalInterface.call("window.open",_loc4_);
                  }
               }
         }
      }
      
      public function show(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this._win == null)
         {
            this._win = new this._Class() as MovieClip;
         }
         if(this._win != null)
         {
            _loc2_ = this._control.model.discount;
            if(_loc2_ > 0)
            {
               this._win.gotoAndStop(2);
               this._win["discount"].gotoAndStop(_loc2_);
               this._win["dis0"].gotoAndStop(_loc2_);
               this._win["dis1"].gotoAndStop(_loc2_);
               this._win["dis2"].gotoAndStop(_loc2_);
               this._win["dis3"].gotoAndStop(_loc2_);
            }
            else
            {
               this._win.gotoAndStop(1);
            }
            this.update(param1);
            this._control.enableMc(this._win["btnRefresh"],true);
            if(this._control.model.canBuySprite4 == false)
            {
               this._control.enableMc(this._win["btnHire3"],false);
            }
            this._control.api.showPopUp(this._win,true);
            this._win.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         }
      }
   }
}


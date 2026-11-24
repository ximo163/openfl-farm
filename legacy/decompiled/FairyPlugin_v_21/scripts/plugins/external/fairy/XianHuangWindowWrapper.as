package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import common.CommonData;
   import common.misc.QzoneJSAPI;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import report.ClickReportManager;
   
   public class XianHuangWindowWrapper
   {
      
      private var _mainpane:MovieClip;
      
      private var _ctrl:FairyPlugin;
      
      private var _xianhuangMonth:int;
      
      private var _model:FairyModel;
      
      private var _class:Class = XianHuangWindowWrapper__class;
      
      private var _EffectCls:Class = XianHuangWindowWrapper__EffectCls;
      
      public function XianHuangWindowWrapper(param1:FairyPlugin)
      {
         super();
         this._ctrl = param1;
         this._model = this._ctrl.model;
         this._ctrl.model.addEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyBought,false,0,true);
      }
      
      private function selectShowPane() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this._model.player._yellowstatus > 0 && this._model.player._yellowlevel > 0)
         {
            if(this._model.fairyItem.itemId != 0)
            {
               this._mainpane.gotoAndStop(1);
               _loc1_ = "";
               switch(this._model.fairyItem.itemId)
               {
                  case 92001:
                     _loc1_ = "小仙女";
                     break;
                  case 92002:
                     _loc1_ = "土地公公";
                     break;
                  case 92003:
                     _loc1_ = "财神爷";
               }
               this._mainpane["fairyTF"].text = _loc1_;
               _loc2_ = this._model.myExpireTime - CommonData.serverTime;
               _loc3_ = Math.ceil(_loc2_ / 86400);
               _loc4_ = Math.floor(_loc3_ / 31);
               _loc5_ = _loc3_ - _loc4_ * 31;
               this._mainpane["monthTF"].text = _loc4_;
               this._mainpane["dayTF"].text = _loc5_;
               if(_loc5_ > 0)
               {
                  this._xianhuangMonth = _loc4_ + 1;
               }
               else
               {
                  this._xianhuangMonth = _loc4_;
               }
               this._mainpane["updateMonth"].text = this._xianhuangMonth + "";
               this._mainpane["qdTF"].text = 168 * this._xianhuangMonth + "";
               this._mainpane["saveqdTF"].text = 192 * this._xianhuangMonth + "Q点";
               this._mainpane["updateXianHuang"].visible = true;
               this._ctrl.enableMc(this._mainpane["updateXianHuang"],true);
            }
            else
            {
               this._mainpane.gotoAndStop(3);
               this._mainpane["discountTF"].text = "6";
               this._mainpane["entertainXianHuang"].visible = true;
               this._ctrl.enableMc(this._mainpane["entertainXianHuang"],true);
            }
         }
         else if(this._model.fairyItem.itemId != 0)
         {
            this._mainpane.gotoAndStop(2);
            this._ctrl.enableMc(this._mainpane["openyellow"],true);
            this._mainpane["updateXianHuang"].visible = true;
            this._mainpane["openyellow"].buttonMode = true;
            this._ctrl.enableMc(this._mainpane["updateXianHuang"],false);
         }
         else
         {
            this._mainpane.gotoAndStop(2);
            this._mainpane["entertainXianHuang"].visible = true;
            this._mainpane["openyellow"].buttonMode = true;
            this._ctrl.enableMc(this._mainpane["entertainXianHuang"],false);
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
            _loc4_ = this._ctrl.model.getFairyById(_loc3_);
            if(_loc4_ != null)
            {
               this._ctrl.updateFairy(_loc4_,true);
               this._model.isXianHuangWinOpen = false;
               this._ctrl.api.hidePopUp(this._mainpane);
            }
         }
      }
      
      private function setMainPaneDate() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         for each(_loc1_ in this._model.fairyList)
         {
            if(_loc1_.id == 92004)
            {
               _loc3_ = _loc1_;
            }
         }
         this._mainpane["star"].gotoAndStop(_loc3_["lv"]);
         _loc2_ = "+" + _loc3_["rate"] + "%";
         this._mainpane["getExpTF"].text = _loc2_;
         this._mainpane["getHarvestTF"].text = _loc2_;
         this._mainpane["getFruitTF"].text = _loc2_;
         this._mainpane["GDUplimit"].text = FairyPlugin.MAX_DONATE[_loc3_["lv"]];
      }
      
      private function onEffectEnd(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null || _loc2_.name == "")
         {
            return;
         }
         if(_loc2_.currentFrame == 6)
         {
            TweenLite.killTweensOf(this._mainpane["getExpTF"],false);
            this._mainpane["getExpTF"].alpha = 0;
            TweenLite.to(this._mainpane["getExpTF"],0.8,{"alpha":1});
            TweenLite.killTweensOf(this._mainpane["getHarvestTF"],false);
            this._mainpane["getHarvestTF"].alpha = 0;
            TweenLite.to(this._mainpane["getHarvestTF"],0.8,{"alpha":1});
            TweenLite.killTweensOf(this._mainpane["getFruitTF"],false);
            this._mainpane["getFruitTF"].alpha = 0;
            TweenLite.to(this._mainpane["getFruitTF"],0.8,{"alpha":1});
            TweenLite.killTweensOf(this._mainpane["GDUplimit"],false);
            this._mainpane["GDUplimit"].alpha = 0;
            TweenLite.to(this._mainpane["GDUplimit"],0.8,{"alpha":1});
            this.setMainPaneDate();
            this._ctrl.enableMc(this._mainpane["btnRefresh"],true);
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
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.type;
         var _loc3_:String = param1.target.name;
         switch(_loc2_)
         {
            case MouseEvent.CLICK:
               switch(_loc3_)
               {
                  case "closeBtn":
                     this._model.isXianHuangWinOpen = false;
                     this._ctrl.api.hidePopUp(this._mainpane);
                     break;
                  case "btnRefresh":
                     this._model.randomXianHuang();
                     this._model.addEventListener(FairyModel.DATA_FAIRY_CHANGED,this.refreshXianHuangData);
                     this._ctrl.enableMc(this._mainpane["btnRefresh"],false);
                     this._ctrl.api.reportSuccessError("160565",null);
                     break;
                  case "openyellow":
                     QzoneJSAPI.openWindow("");
                     break;
                  case "updateXianHuang":
                     this._model.buySprite(this._model.fairyItem.itemId,this._xianhuangMonth,26,26);
                     ClickReportManager.reportClick("update xianhuan");
                     break;
                  case "entertainXianHuang":
                     this._ctrl.confirmBuySprite(3,2);
               }
         }
      }
      
      public function get container() : DisplayObjectContainer
      {
         return this._mainpane;
      }
      
      private function initMainPane() : void
      {
         this._ctrl.enableMc(this._mainpane["updateXianHuang"],true);
         this._ctrl.enableMc(this._mainpane["entertainXianHuang"],true);
         this._ctrl.enableMc(this._mainpane["btnRefresh"],true);
         this._mainpane["updateXianHuang"].visible = false;
         this._mainpane["entertainXianHuang"].visible = false;
         this._model.isXianHuangWinOpen = true;
      }
      
      public function show() : void
      {
         if(this._mainpane == null)
         {
            this._mainpane = new this._class();
         }
         this.initMainPane();
         this.setMainPaneDate();
         this.selectShowPane();
         this._mainpane.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
         this._ctrl.api.showPopUp(this._mainpane,true);
      }
      
      public function refreshXianHuangData(param1:CommonEvent) : void
      {
         var _loc2_:MovieClip = null;
         this._model.removeEventListener(FairyModel.DATA_FAIRY_CHANGED,this.refreshXianHuangData);
         if(param1.data != null)
         {
            TweenLite.to(this._mainpane["getExpTF"],0.5,{"alpha":0});
            TweenLite.to(this._mainpane["getHarvestTF"],0.5,{"alpha":0});
            TweenLite.to(this._mainpane["getFruitTF"],0.5,{"alpha":0});
            TweenLite.to(this._mainpane["GDUplimit"],0.5,{"alpha":0});
            _loc2_ = new this._EffectCls() as MovieClip;
            _loc2_.x = 180;
            _loc2_.y = 210;
            _loc2_.name = "stareffect";
            this._mainpane.addChild(_loc2_);
            _loc2_.addEventListener(Event.ENTER_FRAME,this.onEffectEnd,false,0,true);
         }
      }
   }
}


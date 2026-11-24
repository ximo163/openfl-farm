package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class ItemTip
   {
      
      private var _class:Class = ItemTip__class;
      
      private var _parent:DisplayObjectContainer;
      
      private var _delayClose:Timer;
      
      private var _tip1:MovieClip;
      
      private var _class1:Class = ItemTip__class1;
      
      private var _type:int;
      
      private var _tip:Sprite;
      
      private var _delayShow:Timer;
      
      private var _api:IAllianceAppHelper;
      
      private var _params:Object;
      
      private var _model:CollectingModel;
      
      public function ItemTip(param1:IAllianceAppHelper, param2:CollectingModel, param3:DisplayObjectContainer)
      {
         super();
         this._api = param1;
         this._model = param2;
         this._type = -1;
         this._parent = param3;
      }
      
      public function showSerialTip(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(this._parent == null)
         {
            return;
         }
         this._type = 1;
         this._params = {
            "serial":param1,
            "me":param2,
            "x":param3,
            "y":param4
         };
         if(this._delayClose != null && this._delayClose.running == true)
         {
            this._delayClose.stop();
         }
         if(this._tip1 != null && this._tip1.parent != null)
         {
            this.showTip1();
            return;
         }
         if(this._delayShow == null)
         {
            this._delayShow = new Timer(300,1);
            this._delayShow.addEventListener(TimerEvent.TIMER,this.onShowTimeUp,false,0,true);
         }
         this._delayShow.reset();
         this._delayShow.start();
      }
      
      private function showTip1() : void
      {
         if(this._params == null)
         {
            return;
         }
         if(this._tip1 == null)
         {
            this._tip1 = new this._class1() as MovieClip;
            this._tip1.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._tip1.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
            this._tip1.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
         }
         var _loc1_:Dictionary = this._model.serialsData;
         var _loc2_:int = _loc1_ == null || _loc1_[this._params["serial"]] == undefined ? 0 : int(_loc1_[this._params["serial"]]["sum"]);
         if(this._params["me"] >= _loc2_)
         {
            this._tip1.gotoAndStop(1);
         }
         else
         {
            this._tip1.gotoAndStop(2);
            this._tip1["tfText"].text = this._params["me"] + "/" + _loc2_;
         }
         this._tip1["tfName"].text = _loc1_[this._params["serial"]]["name"];
         this._tip1.x = this._params["x"];
         this._tip1.y = this._params["y"];
         this._parent.addChild(this._tip1);
         this.preventScreenOut();
      }
      
      public function hide(param1:Boolean) : void
      {
         if(this._delayShow != null && this._delayShow.running == true && this._delayShow.currentCount == 0)
         {
            this._delayShow.stop();
            param1 = false;
         }
         if(param1 == true)
         {
            if(this._delayClose == null)
            {
               this._delayClose = new Timer(250,1);
               this._delayClose.addEventListener(TimerEvent.TIMER,this.onClose,false,0,true);
               this._delayClose.start();
            }
            else
            {
               this._delayClose.reset();
               this._delayClose.start();
            }
         }
         else
         {
            this.onClose(null);
         }
      }
      
      private function showTip() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._params == null)
         {
            return;
         }
         if(this._tip == null)
         {
            this._tip = new this._class() as Sprite;
            this._tip.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._tip.addEventListener(MouseEvent.ROLL_OVER,this.onMouseEvent,false,0,true);
            this._tip.addEventListener(MouseEvent.ROLL_OUT,this.onMouseEvent,false,0,true);
         }
         if(this._params["star"] == 3)
         {
            this._tip["tfFull"].text = "您已经收集齐了" + this._params["count"] + "个";
            this._tip["tfTip"].text = "";
            this._tip["star1"].visible = true;
            this._tip["star2"].visible = true;
            this._tip["star3"].visible = true;
            this._tip["progressbar"].visible = false;
            this._tip["tfProgress"].visible = false;
         }
         else
         {
            this._tip["tfFull"].text = "";
            _loc2_ = this._model.harvestNumByStar(this._params["id"],this._params["star"] + 1);
            if(_loc2_ > 0)
            {
               _loc4_ = Math.floor(this._params["count"] * this._tip["progressbar"]["totalFrames"] / _loc2_) as int;
               this._tip["progressbar"].gotoAndStop(_loc4_ + 1);
               this._tip["tfProgress"].text = this._params["count"] + "/" + _loc2_;
            }
            else
            {
               this._tip["progressbar"].gotoAndStop(1);
               this._tip["tfProgress"].text = this._params["count"] + "/0";
            }
            this._tip["progressbar"].visible = true;
            this._tip["tfProgress"].visible = true;
            _loc3_ = _loc2_ - this._params["count"];
            this._tip["tfTip"].htmlText = "再收获<font color=\'#ffcc00\'>" + _loc3_ + "</font>个就可到达" + (this._params["star"] + 1) + "星";
            if(this._params["star"] == 0)
            {
               this._tip["star1"].visible = true;
               this._tip["star2"].visible = false;
               this._tip["star3"].visible = false;
            }
            else if(this._params["star"] == 1)
            {
               this._tip["star1"].visible = true;
               this._tip["star2"].visible = true;
               this._tip["star3"].visible = false;
            }
            else
            {
               this._tip["star1"].visible = true;
               this._tip["star2"].visible = true;
               this._tip["star3"].visible = true;
            }
         }
         var _loc1_:Object = this._model.getCropConfig(this._params["id"]);
         if(_loc1_ != null && _loc1_["lv"] != undefined && this.myLevel < _loc1_["lv"])
         {
            this._tip["lvlDown"].visible = true;
            this._tip["btnBuyShop"].visible = false;
            this._tip["btnBuyQD"].visible = false;
         }
         else
         {
            this._tip["lvlDown"].visible = false;
            this._tip["btnBuyShop"].visible = _loc1_["qd"] == 0 || _loc1_["qd"] == undefined ? true : false;
            this._tip["btnBuyQD"].visible = _loc1_["qd"] == 0 || _loc1_["qd"] == undefined ? false : true;
         }
         if(_loc1_["qd"] > 0 && _loc1_["sr"] == 0)
         {
            this._tip["btnBuyQD"].visible = false;
         }
         if(this._params["name"] != null && this._params["name"] != "")
         {
            this._tip["tfName"].text = this._params["name"];
         }
         else if(_loc1_ != null)
         {
            this._tip["tfName"].text = _loc1_["name"];
         }
         this._tip.x = this._params["x"];
         this._tip.y = this._params["y"];
         this._parent.addChild(this._tip);
         this.preventScreenOut();
      }
      
      private function onClose(param1:TimerEvent) : void
      {
         if(this._tip != null && this._tip.parent != null)
         {
            this._tip.parent.removeChild(this._tip);
         }
         if(this._tip1 != null && this._tip1.parent != null)
         {
            this._tip1.parent.removeChild(this._tip1);
         }
         this._type = -1;
         this._params = null;
      }
      
      private function onShowTimeUp(param1:TimerEvent) : void
      {
         if(this._params == null)
         {
            return;
         }
         if(this._type == 0)
         {
            this.showTip();
         }
         else if(this._type == 1)
         {
            this.showTip1();
         }
      }
      
      private function preventScreenOut() : void
      {
         if(this._parent == null || this._tip == null)
         {
            return;
         }
         var _loc1_:Point = new Point(this._tip.x,this._tip.y);
         _loc1_ = this._parent.localToGlobal(_loc1_);
         if(_loc1_.x + this._tip.width >= this._parent.stage.stageWidth)
         {
            this._tip.x = this._parent.stage.stageWidth - this._tip.width - 28;
         }
      }
      
      public function showCropTip(param1:int, param2:String, param3:int, param4:int, param5:int, param6:int) : void
      {
         if(this._parent == null || param1 == 0)
         {
            return;
         }
         this._type = 0;
         this._params = {
            "id":param1,
            "name":param2,
            "star":param3,
            "count":param4,
            "x":param5,
            "y":param6
         };
         if(this._delayClose != null && this._delayClose.running == true)
         {
            this._delayClose.stop();
         }
         if(this._delayShow == null)
         {
            this._delayShow = new Timer(300,1);
            this._delayShow.addEventListener(TimerEvent.TIMER,this.onShowTimeUp,false,0,true);
         }
         this._delayShow.reset();
         this._delayShow.start();
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc3_:SimpleButton = null;
         var _loc2_:Mediator = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
         if(param1.type == MouseEvent.CLICK)
         {
            _loc3_ = param1.target as SimpleButton;
            if(_loc3_ == null)
            {
               return;
            }
            switch(_loc3_.name)
            {
               case "btnBuyShop":
                  this._api.execute("10008",this._params["id"]);
                  this.hide(false);
                  break;
               case "btnBuyQD":
                  _loc2_.openBuyWindow(this._params["id"]);
                  this.hide(false);
                  break;
               case "btnDetails":
                  _loc2_.showSerialPage(this._params["serial"]);
                  this.hide(false);
            }
         }
         else if(param1.type == MouseEvent.ROLL_OVER)
         {
            if(this._delayClose != null && this._delayClose.running == true)
            {
               this._delayClose.stop();
            }
         }
         else if(param1.type == MouseEvent.ROLL_OUT)
         {
            this.hide(false);
         }
      }
      
      public function get myLevel() : int
      {
         return this._api.execute("10004") as int;
      }
   }
}


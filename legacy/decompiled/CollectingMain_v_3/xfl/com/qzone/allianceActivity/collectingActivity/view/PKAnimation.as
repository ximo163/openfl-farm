package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.collectingActivity.model.CollectingConsts;
   import com.qzone.allianceActivity.collectingActivity.model.CollectingModel;
   import com.qzone.allianceActivity.collectingActivity.model.FriendData;
   import com.qzone.allianceActivity.framewrok.MVCFacade;
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Dictionary;
   
   public class PKAnimation extends EventDispatcher
   {
      
      private var _items:Array;
      
      private var _animation:MovieClip;
      
      private var _resultFlag:int;
      
      private var _head1:Loader;
      
      private var _head2:Loader;
      
      private var _api:IAllianceAppHelper;
      
      private var _fd:FriendData;
      
      private var _tip:Sprite;
      
      private var _model:CollectingModel;
      
      private var _btnReturn:SimpleButton;
      
      private var _tipCls:Class = PKAnimation__tipCls;
      
      private var _class:Class = PKAnimation__class;
      
      private var _result:Array;
      
      public function PKAnimation(param1:IAllianceAppHelper)
      {
         super();
         this._api = param1;
         this._model = MVCFacade.getInstance().getObj(CollectingConsts.MODEL) as CollectingModel;
         this._model.addBinding("friendProducts",this,"friendProducts");
      }
      
      private function showCropAt(param1:int, param2:int) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:Loader = null;
         if(param2 >= 5)
         {
            return;
         }
         var _loc3_:MovieClip = this._animation["resultPanel"] as MovieClip;
         if(param1 == 0)
         {
            _loc3_["crop_" + param2]["visible"] = false;
            _loc3_["btn_" + param2]["visible"] = false;
         }
         else
         {
            _loc3_["btn_" + param2]["visible"] = true;
            _loc4_ = _loc3_["crop_" + param2];
            _loc4_["visible"] = true;
            _loc4_["gray"].visible = false;
            _loc5_ = this._api.execute("10006",param1) as String;
            if(_loc5_ != null && _loc5_ != "")
            {
               _loc7_ = new Loader();
               _loc7_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
               _loc7_.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,this.errorHandler);
               _loc7_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete);
               _loc7_.load(new URLRequest(_loc5_),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
               this._items[param2] = {
                  "loader":_loc7_,
                  "cId":param1,
                  "index":param2
               };
            }
            _loc4_["star1"].visible = false;
            _loc4_["star2"].visible = false;
            _loc4_["star3"].visible = false;
            _loc6_ = this._model.getCropConfig(param1);
            if(_loc6_ != null)
            {
               if(_loc6_["lv"] != undefined)
               {
                  _loc4_["tfLvl"].text = _loc6_["lv"] + "级";
               }
            }
         }
      }
      
      private function fillSerials(param1:Array) : void
      {
         var _loc2_:MovieClip = this._animation["resultPanel"] as MovieClip;
         _loc2_.gotoAndStop(1);
         if(param1.length == 1)
         {
            this.showSerialAt(parseInt(param1[0]),0);
            this.showSerialAt(0,1);
            this.showSerialAt(0,2);
            this.showSerialAt(0,3);
            this.showSerialAt(0,4);
         }
         else if(param1.length == 2)
         {
            this.showSerialAt(0,0);
            this.showSerialAt(parseInt(param1[0]),1);
            this.showSerialAt(parseInt(param1[1]),2);
            this.showSerialAt(0,3);
            this.showSerialAt(0,4);
         }
         else if(param1.length == 3)
         {
            this.showSerialAt(parseInt(param1[0]),0);
            this.showSerialAt(parseInt(param1[1]),1);
            this.showSerialAt(parseInt(param1[2]),2);
            this.showSerialAt(0,3);
            this.showSerialAt(0,4);
         }
         else if(param1.length == 4)
         {
            this.showSerialAt(parseInt(param1[0]),0);
            this.showSerialAt(parseInt(param1[1]),1);
            this.showSerialAt(parseInt(param1[2]),2);
            this.showSerialAt(parseInt(param1[3]),3);
            this.showSerialAt(0,4);
         }
         else if(param1.length == 5)
         {
            this.showSerialAt(parseInt(param1[0]),0);
            this.showSerialAt(parseInt(param1[1]),1);
            this.showSerialAt(parseInt(param1[2]),2);
            this.showSerialAt(parseInt(param1[3]),3);
            this.showSerialAt(parseInt(param1[4]),4);
         }
      }
      
      public function set friendProducts(param1:FriendData) : void
      {
         if(param1 == null)
         {
            if(this._btnReturn != null)
            {
               this._btnReturn.visible = true;
            }
            return;
         }
         if(this._animation != null)
         {
            this.fillOtherInfo(param1);
            this.showPKResult();
         }
      }
      
      private function loadComplete(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc5_:Class = null;
         var _loc6_:DisplayObject = null;
         var _loc7_:MovieClip = null;
         var _loc8_:* = undefined;
         var _loc9_:DisplayObjectContainer = null;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            if(!(this._items[_loc3_] == null || this._items[_loc3_] == undefined))
            {
               if(this._items[_loc3_]["loader"] == _loc2_.loader)
               {
                  _loc4_ = "Crop_" + this._items[_loc3_]["cId"] + "_Seed";
                  if(ApplicationDomain.currentDomain.hasDefinition(_loc4_) == true)
                  {
                     _loc5_ = ApplicationDomain.currentDomain.getDefinition(_loc4_) as Class;
                     if(_loc5_ != null)
                     {
                        _loc6_ = new _loc5_() as DisplayObject;
                        _loc6_.width = 60;
                        _loc6_.height = 60;
                        _loc6_.x = 5;
                        _loc6_.y = 2;
                        _loc7_ = this._animation["resultPanel"] as MovieClip;
                        _loc8_ = _loc7_["crop_" + this._items[_loc3_]["index"]];
                        if(_loc8_ != undefined)
                        {
                           _loc9_ = _loc8_["holder"] as DisplayObjectContainer;
                           if(_loc9_ != null)
                           {
                              _loc9_.addChild(_loc6_);
                           }
                        }
                     }
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function fillRecommendInfo() : void
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Dictionary = null;
         var _loc1_:Array = this._model.myCollectedSerials;
         var _loc2_:Array = [];
         var _loc3_:Dictionary = this._model.countEachSerials(this._fd.uId);
         var _loc4_:String = null;
         if(_loc3_ != null)
         {
            _loc7_ = 0;
            _loc8_ = this._model.serialsData;
            for(_loc4_ in _loc3_)
            {
               if(!(_loc8_[_loc4_] == undefined || _loc8_[_loc4_]["visible"] == false))
               {
                  if(_loc8_[_loc4_]["sum"] != undefined)
                  {
                     _loc7_ = _loc8_[_loc4_]["sum"] as int;
                  }
                  if(_loc3_[_loc4_] == _loc7_)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
            }
         }
         var _loc5_:Array = [];
         for each(_loc4_ in _loc2_)
         {
            if(_loc1_.indexOf(_loc4_) == -1)
            {
               _loc5_.push(_loc4_);
            }
         }
         _loc6_ = this._animation["friendPhoto"]["tfName"].text;
         if(_loc5_.length > 0)
         {
            _loc6_ = "以下系列是" + _loc6_ + "完成而你没有完成的：";
            this.fillSerials(_loc5_);
         }
         else if(_loc1_.length > _loc2_.length)
         {
            if(_loc2_.length == 0)
            {
               _loc6_ += "在系列收藏上是菜鸟，你厉害多了！不过还有些种子你没有哦~";
               this.fillRandomCrops();
            }
            else
            {
               _loc6_ += "完成的系列你早已完成！不过还有些种子你没有哦~";
               this.fillRandomCrops();
            }
         }
         else if(_loc1_.length == _loc2_.length)
         {
            if(_loc1_.length == 0)
            {
               _loc6_ = "你们俩在系列收藏上都是菜鸟，赶紧买些种子填补空缺吧~";
               this.fillRandomCrops();
            }
            else
            {
               _loc6_ += "完成的系列你早已完成！不过还有些种子你没有哦~";
               this.fillRandomCrops();
            }
         }
         this._animation["resultPanel"]["tuijian"].text += _loc6_;
      }
      
      public function destroy() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:int = 0;
         if(this._head2 != null && this._head2.parent != null)
         {
            this._head2.parent.removeChild(this._head2);
         }
         if(this._animation != null)
         {
            this._animation.stop();
            _loc1_ = null;
            _loc2_ = 0;
            while(_loc2_ < 5)
            {
               if(this._animation["resultPanel"] != undefined && this._animation["resultPanel"].currentFrame == 1)
               {
                  _loc1_ = this._animation["resultPanel"]["icon_" + _loc2_];
                  while(_loc1_["holder"] != undefined && _loc1_["holder"].numChildren > 0)
                  {
                     _loc1_["holder"].removeChildAt(0);
                  }
               }
               if(this._animation["resultPanel"] != undefined && this._animation["resultPanel"].currentFrame == 2)
               {
                  _loc1_ = this._animation["resultPanel"]["crop_" + _loc2_];
                  while(_loc1_["holder"] != undefined && _loc1_["holder"].numChildren > 0)
                  {
                     _loc1_["holder"].removeChildAt(0);
                  }
               }
               _loc2_++;
            }
            this._animation.removeEventListener(MouseEvent.CLICK,this.onClicked);
            this._animation.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this._animation.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this._animation.parent.removeChild(this._animation);
         }
         this._animation = null;
         this._result = null;
         this._items = null;
         this._resultFlag = 0;
         this._fd = null;
      }
      
      private function shuffle(param1:Array) : void
      {
         if(param1 == null || param1.length < 2)
         {
            return;
         }
         var _loc2_:int = int(param1.length);
         var _loc3_:* = int(_loc2_ - 1);
         var _loc4_:int = 0;
         var _loc5_:* = null;
         while(_loc3_ >= 0)
         {
            _loc4_ = int(Math.random() * _loc2_);
            if(_loc4_ >= _loc2_)
            {
               _loc3_--;
            }
            else
            {
               _loc5_ = param1[_loc4_];
               param1[_loc4_] = param1[_loc3_];
               param1[_loc3_] = _loc5_;
               _loc3_--;
            }
         }
      }
      
      private function onPlaying(param1:Event) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:String = null;
         if(param1.target.currentFrame == 16)
         {
            _loc2_ = this._animation["pkNumber"];
            _loc3_ = "";
            if(this._resultFlag == 1 || this._resultFlag == 0)
            {
               _loc3_ = this._animation["myPhoto"]["tfName"].text;
               this._animation["myPhoto"].gotoAndStop(2);
               this._animation["myPhoto"]["tfName"].text = _loc3_;
               _loc2_["t0"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["t0"].text + "</font>";
               _loc2_["t1"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["t1"].text + "</font>";
               _loc2_["t2"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["t2"].text + "</font>";
            }
            if(this._resultFlag == -1 || this._resultFlag == 0)
            {
               _loc3_ = this._animation["friendPhoto"]["tfName"].text;
               this._animation["friendPhoto"].gotoAndStop(2);
               this._animation["friendPhoto"]["tfName"].text = _loc3_;
               _loc2_["h0"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["h0"].text + "</font>";
               _loc2_["h1"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["h1"].text + "</font>";
               _loc2_["h2"].htmlText = "<font size=\'20\' color=\'#F46219\'>" + _loc2_["h2"].text + "</font>";
            }
         }
         if(param1.target.currentFrame == 27)
         {
            this.fillRecommendInfo();
         }
         else if(param1.target.currentFrame == param1.target.totalFrames)
         {
            param1.target.stop();
            param1.target.removeEventListener(Event.ENTER_FRAME,this.onPlaying);
            this._btnReturn.visible = true;
            this._btnReturn.addEventListener(MouseEvent.CLICK,this.onReturn,false,0,true);
         }
      }
      
      private function replace30(param1:String) : String
      {
         var _loc4_:int = 0;
         if(param1 == null || param1 == "")
         {
            return param1;
         }
         var _loc2_:String = param1;
         var _loc3_:int = _loc2_.lastIndexOf("/30/30");
         if(_loc3_ == -1)
         {
            _loc4_ = _loc2_.lastIndexOf("/30");
            if(_loc4_ != -1)
            {
               _loc2_ = _loc2_.substring(0,_loc4_) + "/50" + _loc2_.substring(_loc4_ + 3,_loc2_.length);
            }
         }
         else
         {
            _loc2_ = _loc2_.substring(0,_loc3_) + "/50/30" + _loc2_.substring(_loc3_ + 6,_loc2_.length);
         }
         return _loc2_;
      }
      
      private function fillRandomCrops() : void
      {
         var _loc7_:* = undefined;
         var _loc10_:* = undefined;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc1_:MovieClip = this._animation["resultPanel"] as MovieClip;
         _loc1_.gotoAndStop(2);
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:Boolean = false;
         var _loc5_:Array = this._model.myNormalProducts;
         var _loc6_:Array = this._model.getCropIDsBySerial(-3);
         for each(_loc7_ in _loc6_)
         {
            _loc4_ = false;
            for each(_loc10_ in _loc5_)
            {
               if(_loc10_["cId"] == _loc7_)
               {
                  _loc4_ = true;
                  break;
               }
            }
            if(_loc4_ == false)
            {
               _loc2_.push(_loc7_);
            }
         }
         if(_loc2_.length < 5)
         {
            _loc5_ = this._model.myMysteriousProducts;
            _loc6_ = this._model.getCropIDsBySerial(-1);
            for each(_loc7_ in _loc6_)
            {
               if(this._model.id2Serial(_loc7_) != 0)
               {
                  _loc4_ = false;
                  for each(_loc10_ in _loc5_)
                  {
                     if(_loc10_["cId"] == _loc7_)
                     {
                        _loc4_ = true;
                        break;
                     }
                  }
                  if(_loc4_ == false)
                  {
                     _loc3_.push(_loc7_);
                  }
               }
            }
         }
         var _loc8_:Array = _loc2_.concat(_loc3_);
         var _loc9_:int = int(_loc8_.length);
         if(_loc9_ == 0)
         {
            _loc1_["btnShare"].visible = true;
            _loc11_ = this._animation["resultPanel"]["tuijian"].text;
            _loc12_ = _loc11_.indexOf("\n");
            if(_loc12_ != -1)
            {
               _loc11_ = _loc11_.substring(0,_loc12_ + 1) + "你太厉害了吧！可以买到的全部收集齐了！这么值得骄傲的事情一定要分享！";
            }
            this._animation["resultPanel"]["tuijian"].text = _loc11_;
         }
         else if(_loc9_ == 1)
         {
            this.showCropAt(_loc8_[0],0);
            this.showCropAt(0,1);
            this.showCropAt(0,2);
            this.showCropAt(0,3);
            this.showCropAt(0,4);
         }
         else if(_loc9_ == 2)
         {
            this.showCropAt(0,0);
            this.showCropAt(_loc8_[0],1);
            this.showCropAt(_loc8_[1],2);
            this.showCropAt(0,3);
            this.showCropAt(0,4);
         }
         else if(_loc9_ == 3)
         {
            this.showCropAt(_loc8_[0],0);
            this.showCropAt(_loc8_[1],1);
            this.showCropAt(_loc8_[2],2);
            this.showCropAt(0,3);
            this.showCropAt(0,4);
         }
         else if(_loc9_ == 4)
         {
            this.showCropAt(_loc8_[0],0);
            this.showCropAt(_loc8_[1],1);
            this.showCropAt(_loc8_[2],2);
            this.showCropAt(_loc8_[3],3);
            this.showCropAt(0,4);
         }
         else if(_loc9_ >= 5)
         {
            this.shuffle(_loc2_);
            _loc13_ = 0;
            _loc13_ = 0;
            while(_loc13_ < _loc2_.length)
            {
               if(_loc13_ == 5)
               {
                  return;
               }
               this.showCropAt(_loc2_[_loc13_],_loc13_);
               _loc8_.splice(_loc8_.indexOf(_loc2_[_loc13_]),1);
               _loc13_++;
            }
            if(_loc13_ < 5)
            {
               this.shuffle(_loc8_);
               while(_loc13_ < _loc8_.length)
               {
                  if(_loc13_ == 5)
                  {
                     return;
                  }
                  this.showCropAt(_loc8_[_loc13_],_loc13_);
                  _loc13_++;
               }
            }
         }
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc5_:MVCEvent = null;
         var _loc6_:Mediator = null;
         var _loc7_:int = 0;
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.name.indexOf("btn_") == -1)
         {
            return;
         }
         var _loc3_:int = parseInt(_loc2_.name.charAt(4));
         var _loc4_:MovieClip = this._animation["resultPanel"] as MovieClip;
         if(_loc4_.currentFrame == 1)
         {
            _loc5_ = new MVCEvent(Event.OPEN);
            _loc5_.put("id",this._items[_loc3_]["id"]);
            dispatchEvent(_loc5_);
         }
         else
         {
            _loc6_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
            _loc7_ = this._items[_loc3_]["cId"] as int;
            _loc6_.openBuyWindow(_loc7_);
         }
         param1.stopImmediatePropagation();
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         var _loc2_:String = this._animation["resultPanel"]["tuijian"].text;
         var _loc3_:int = _loc2_.indexOf("可以买到的全部收集齐了");
         var _loc4_:String = "";
         var _loc5_:String = "";
         if(_loc3_ == -1)
         {
            _loc4_ = "QQ农场又有新追求！我的农场图鉴收藏水平远高于你啊！你要加油喽~";
            _loc5_ = "module/collect/tj_win.jpg";
         }
         else
         {
            _loc4_ = "QQ农场又有新追求！我的农场图鉴收藏太厉害了!现有的所有种子全部收集齐！有比我更厉害的吗？";
            _loc5_ = "module/collect/tj_full.jpg";
         }
         if(ExternalInterface.available == true)
         {
            ExternalInterface.call("fusion2.dialog.tweet",{
               "msg":_loc4_,
               "url":_loc5_,
               "at":[this._fd.uin],
               "source":"QQFARM_TUJIAN"
            });
         }
      }
      
      private function fillOtherInfo(param1:FriendData) : void
      {
         this._animation["friendPhoto"].gotoAndStop(1);
         var _loc2_:String = param1.name;
         if(_loc2_ != null && _loc2_.length > 8)
         {
            _loc2_ = _loc2_.substr(0,8) + "..";
         }
         this._animation["friendPhoto"]["tfName"].text = _loc2_;
         this._animation["pkNumber"]["h0"].text = param1.collectSerials.toString();
         this._animation["pkNumber"]["h1"].text = param1.lightedCrops.toString();
         this._animation["pkNumber"]["h2"].text = param1.stars.toString();
         var _loc3_:String = this.replace30(param1.photo);
         if(_loc3_ != null && _loc3_ != "")
         {
            if(this._head2 != null && this._head2.loaderInfo != null && this._head2.loaderInfo.url == _loc3_)
            {
               return;
            }
            if(this._head2 == null)
            {
               this._head2 = new Loader();
            }
            this._animation["friendPhoto"]["holder"].addChild(this._head2);
            this._head2.load(new URLRequest(_loc3_));
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.target.name.indexOf("icon_") == -1)
         {
            return;
         }
         var _loc2_:int = parseInt(param1.target.name.charAt(5));
         if(this._items[_loc2_] == null)
         {
            return;
         }
         if(this._tip == null)
         {
            this._tip = new this._tipCls() as Sprite;
            this._tip.mouseEnabled = false;
         }
         var _loc3_:Array = this._model.getMyProductIDsBySerial(this._items[_loc2_]["id"]);
         var _loc4_:int = int(this._items[_loc2_]["sum"]);
         if(_loc3_ != null)
         {
            _loc4_ -= _loc3_.length;
         }
         this._tip["tfTip"].text = "您还缺少 " + _loc4_ + " 个种子完成该系列";
         var _loc5_:MovieClip = this._animation["resultPanel"] as MovieClip;
         this._tip.x = param1.target.x + 10;
         this._tip.y = -70;
         _loc5_.addChild(this._tip);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._tip != null && this._tip.parent != null)
         {
            this._tip.parent.removeChild(this._tip);
         }
      }
      
      private function errorHandler(param1:IOErrorEvent) : void
      {
      }
      
      private function showSerialAt(param1:int, param2:int) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:* = undefined;
         var _loc7_:BitmapData = null;
         var _loc8_:Bitmap = null;
         var _loc3_:MovieClip = this._animation["resultPanel"] as MovieClip;
         if(param1 == 0)
         {
            _loc3_["icon_" + param2]["visible"] = false;
            _loc3_["btn_" + param2]["visible"] = false;
         }
         else
         {
            _loc4_ = this._model.serialsData;
            _loc5_ = _loc4_[param1];
            if(_loc5_ != null)
            {
               this._items[param2] = {
                  "id":param1,
                  "name":_loc5_["name"],
                  "sum":_loc5_["sum"]
               };
               _loc3_["btn_" + param2]["visible"] = true;
               _loc6_ = _loc3_["icon_" + param2];
               _loc6_["visible"] = true;
               _loc6_["mouseChildren"] = false;
               _loc6_["tfName0"]["text"] = _loc5_["name"];
               _loc6_["tfName"]["text"] = "";
               _loc6_["holder"];
               _loc6_["gotoAndStop"](1);
               _loc7_ = SerialsCache.getInstance().getSerialIconFromCache(param1);
               _loc8_ = new Bitmap(_loc7_,"auto",true);
               _loc6_["holder"]["addChild"](_loc8_);
               _loc8_.x = (50 - _loc8_.width) * 0.5;
               _loc8_.y = (50 - _loc8_.height) * 0.5;
            }
         }
      }
      
      private function fillMyInfo() : void
      {
         this._animation["myPhoto"].gotoAndStop(1);
         var _loc1_:String = this._api.execute("10014")["_userName"] as String;
         if(_loc1_ != null && _loc1_.length > 8)
         {
            _loc1_ = _loc1_.substr(0,8) + "..";
         }
         this._animation["myPhoto"]["tfName"].text = _loc1_;
         var _loc2_:Array = this._model.myCollectedSerials;
         this._animation["pkNumber"]["t0"].text = _loc2_ != null ? _loc2_.length : 0;
         this._animation["pkNumber"]["t1"].text = this._model.myCollectedSum;
         this._animation["pkNumber"]["t2"].text = this._model.myNormalStars + this._model.myMysteriousStars;
         var _loc3_:String = this._api.execute("10007") as String;
         if(_loc3_ != null && _loc3_ != "")
         {
            if(this._head1 != null && this._head1.loaderInfo != null && this._head1.loaderInfo.url == _loc3_)
            {
               return;
            }
            if(this._head1 == null)
            {
               this._head1 = new Loader();
            }
            this._animation["myPhoto"]["holder"].addChild(this._head1);
            this._head1.load(new URLRequest(_loc3_));
         }
      }
      
      private function onReturn(param1:MouseEvent) : void
      {
         param1.target.removeEventListener(MouseEvent.CLICK,this.onReturn);
         param1.stopImmediatePropagation();
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function play(param1:FriendData, param2:DisplayObjectContainer, param3:SimpleButton) : void
      {
         var _loc4_:Mediator = null;
         if(param1 == null || param2 == null)
         {
            return;
         }
         this._result = new Array(3);
         this._items = new Array(5);
         this._fd = param1;
         this._btnReturn = param3;
         this._btnReturn.visible = false;
         if(this._animation == null)
         {
            this._animation = new this._class() as MovieClip;
            this._animation.x = 447;
            this._animation.y = 151;
            param2.addChild(this._animation);
         }
         this._animation.gotoAndStop(1);
         this.fillMyInfo();
         this.fillOtherInfo(param1);
         if(param1.updated == false)
         {
            _loc4_ = MVCFacade.getInstance().getObj(CollectingConsts.MEDIATOR) as Mediator;
            param1 = _loc4_.loadFriendCrops(param1.uId);
         }
         else
         {
            this.showPKResult();
         }
      }
      
      private function showPKResult() : void
      {
         this._animation.gotoAndPlay(1);
         this._animation.addEventListener(Event.ENTER_FRAME,this.onPlaying,false,0,true);
         this._animation["resultPanel"].gotoAndStop(1);
         this._animation["resultPanel"]["btnShare"]["visible"] = false;
         this._animation.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this._animation.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this._animation.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         if(parseInt(this._animation["pkNumber"]["t0"].text) > parseInt(this._animation["pkNumber"]["h0"].text))
         {
            this._result[0] = 1;
         }
         else if(parseInt(this._animation["pkNumber"]["t0"].text) == parseInt(this._animation["pkNumber"]["h0"].text))
         {
            this._result[0] = 0;
         }
         else
         {
            this._result[0] = -1;
         }
         if(parseInt(this._animation["pkNumber"]["t1"].text) > parseInt(this._animation["pkNumber"]["h1"].text))
         {
            this._result[1] = 1;
         }
         else if(parseInt(this._animation["pkNumber"]["t1"].text) == parseInt(this._animation["pkNumber"]["h1"].text))
         {
            this._result[1] = 0;
         }
         else
         {
            this._result[1] = -1;
         }
         if(parseInt(this._animation["pkNumber"]["t2"].text) > parseInt(this._animation["pkNumber"]["h2"].text))
         {
            this._result[2] = 1;
         }
         else if(parseInt(this._animation["pkNumber"]["t2"].text) == parseInt(this._animation["pkNumber"]["h2"].text))
         {
            this._result[2] = 0;
         }
         else
         {
            this._result[2] = -1;
         }
         var _loc1_:Array = [];
         var _loc2_:String = "";
         if(this._result[0] + this._result[1] + this._result[2] >= 1)
         {
            if(this._result[0] == 1)
            {
               _loc1_.push("收集系列");
            }
            if(this._result[1] == 1)
            {
               _loc1_.push("点亮种子");
            }
            if(this._result[2] == 1)
            {
               _loc1_.push("星星数量");
            }
            if(_loc1_.length > 1)
            {
               _loc2_ = "都";
            }
            this._animation["resultPanel"]["tuijian"].text = "恭喜您赢了！您在" + _loc1_.join("、") + "方面" + _loc2_ + "超过了" + this._animation["friendPhoto"]["tfName"].text + "!\n";
            this._animation["resultPanel"]["btnShare"]["visible"] = true;
            this._animation["resultPanel"]["btnShare"].addEventListener(MouseEvent.CLICK,this.onShare,false,0,true);
            this._resultFlag = 1;
         }
         else if(this._result[0] + this._result[1] + this._result[2] == 0)
         {
            this._animation["resultPanel"]["tuijian"].text = "你们俩战平了！再加把劲超过" + this._animation["friendPhoto"]["tfName"].text + "!\n";
            this._resultFlag = 0;
         }
         else
         {
            if(this._result[0] == -1)
            {
               _loc1_.push("收集系列");
            }
            if(this._result[1] == -1)
            {
               _loc1_.push("点亮种子");
            }
            if(this._result[2] == -1)
            {
               _loc1_.push("星星数量");
            }
            if(_loc1_.length > 1)
            {
               _loc2_ = "都";
            }
            this._animation["resultPanel"]["tuijian"].text = "很遗憾！您在" + _loc1_.join("、") + "方面" + _loc2_ + "不如" + this._animation["friendPhoto"]["tfName"].text + "。\n";
            this._resultFlag = -1;
         }
      }
   }
}


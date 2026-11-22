package module.water
{
   import common.CommonData;
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.cursor.CursorControl;
   import entities.PoolFish;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.Timer;
   import module.GameGuide;
   
   public class WaterPool extends PoolMap
   {
      
      private var _loading:MovieClip;
      
      private var _mouseState:Object;
      
      private var _disableMouse:Boolean;
      
      private var _water:MovieClip;
      
      private var _loader:Loader;
      
      private var _matureFlag:MovieClip;
      
      private var _controller:WaterController;
      
      private var _timer:Timer;
      
      private var _toBeDeleted:int;
      
      private var _tip:FishInfoTip;
      
      private var _stone:MovieClip;
      
      private var _fishMovers:Array;
      
      private var _selectedFish:FishMover;
      
      public function WaterPool(param1:WaterController)
      {
         super();
         this._controller = param1;
         name = "__waterpool__";
         this._water = null;
         this._stone = null;
         this._loading = null;
         this._selectedFish = null;
         this._toBeDeleted = -1;
         this._mouseState = null;
         this._disableMouse = false;
         this.loadRes();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this._disableMouse == true)
         {
            return;
         }
         var _loc2_:CursorControl = null;
         if(this._controller.module != null && this._controller.module.app != null)
         {
            _loc2_ = this._controller.module.app.farmView.cursorCtrl;
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = _loc2_.cursorArgument;
         var _loc4_:String = _loc2_.name;
         var _loc5_:Array = null;
         if(_loc4_ == Consts.CURSOR_STYLE_CROPSEED)
         {
            _loc5_ = _loc3_.split(",");
            if(_loc5_ != null && _loc5_.length == 2 && _loc5_[0] == Consts.ITEM_TYPE_FISH)
            {
               this.operatePlant(parseInt(_loc5_[1]));
            }
         }
         else if(_loc4_ == Consts.CURSOR_STYLE_FISHNET)
         {
            this.operateHarvest();
         }
         else if(_loc4_ == Consts.CURSOR_STYLE_FISHNET_ALL)
         {
            this.operateHarvestAll(true);
         }
         else if(_loc4_ == Consts.CURSOR_STYLE_TOOL)
         {
            _loc5_ = _loc3_.split(",");
            if(_loc5_ != null && _loc5_.length == 2 && _loc5_[0] == Consts.ITEM_TYPE_FISHFEED)
            {
               this.operateFeed(parseInt(_loc5_[1]));
            }
         }
      }
      
      public function findFishByID(param1:int) : FishMover
      {
         if(this._fishMovers == null)
         {
            return null;
         }
         var _loc2_:FishMover = null;
         var _loc3_:int = int(this._fishMovers.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = this._fishMovers[_loc4_] as FishMover;
            if(_loc2_ != null && _loc2_.fish._id == param1)
            {
               return _loc2_;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc6_:Array = null;
         if(this._fishMovers == null || this._fishMovers.length == 0)
         {
            return;
         }
         if(Session.getInstance().m_lockFishMouse == true)
         {
            return;
         }
         var _loc2_:CursorControl = null;
         if(this._controller.module != null && this._controller.module.app != null)
         {
            _loc2_ = this._controller.module.app.farmView.cursorCtrl;
         }
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:String = _loc2_.name;
         if(_loc3_ == Consts.CURSOR_STYLE_ARROW || _loc3_ == Consts.CURSOR_STYLE_FISHNET || _loc3_ == Consts.CURSOR_STYLE_WEED || _loc3_ == Consts.CURSOR_STYLE_INSET || _loc3_ == Consts.CURSOR_STYLE_FISHNET_ALL)
         {
            return;
         }
         if(_loc2_.name == Consts.CURSOR_STYLE_CROPSEED || _loc2_.name == Consts.CURSOR_STYLE_TOOL)
         {
            _loc6_ = _loc2_.cursorArgument.split(",",2);
            if(_loc6_ == null || _loc6_[0] == Consts.ITEM_TYPE_FISH || _loc6_[0] == Consts.ITEM_TYPE_FISHFEED)
            {
               return;
            }
         }
         this._mouseState = {
            "name":_loc2_.name,
            "argument":_loc2_.cursorArgument
         };
         var _loc4_:Boolean = Boolean(Session.getInstance().me);
         var _loc5_:Boolean = this._controller.model.canSteal(_loc4_);
         if(_loc5_ == true)
         {
            _loc2_.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
         }
         else
         {
            _loc2_.setCursor(Consts.CURSOR_STYLE_ARROW);
         }
      }
      
      public function findNearPos() : Point
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:Number = 0;
         var _loc4_:Number = 1000000;
         var _loc5_:Number = 0;
         var _loc6_:uint = uint(_pool.numChildren);
         if(_pool == null)
         {
            return null;
         }
         var _loc7_:Number = mouseX - _pool.x;
         var _loc8_:Number = mouseY - _pool.y;
         var _loc9_:int = 0;
         while(_loc9_ < _loc6_)
         {
            _loc1_ = _pool.getChildAt(_loc9_);
            _loc5_ = _loc1_.width * 0.5;
            if((_loc1_.name.length == 2 || _loc1_.name.length == 3) && _loc1_.name.charAt(0) == "c")
            {
               _loc3_ = (_loc7_ - _loc1_.x - _loc5_) * (_loc7_ - _loc1_.x - _loc5_) + (_loc8_ - _loc1_.y - _loc5_) * (_loc8_ - _loc1_.y - _loc5_);
               if(_loc3_ < _loc4_)
               {
                  _loc4_ = _loc3_;
                  _loc2_ = _loc1_;
               }
            }
            _loc9_++;
         }
         if(_loc2_ != null)
         {
            return new Point(_loc2_.x + _loc5_,_loc2_.y + _loc5_);
         }
         return null;
      }
      
      public function showWaterFlower(param1:Point, param2:int) : void
      {
         var _loc3_:Array = [0,1,2,3];
         var _loc4_:Array = [[1.75,9.25],[1,1],[10.63,-1.63],[11.63,8.5]];
         var _loc5_:MovieClip = null;
         var _loc6_:Class = null;
         var _loc7_:int = 0;
         while(_loc7_ < _loc3_.length)
         {
            if(param2 != _loc3_[_loc7_])
            {
               _loc6_ = ApplicationDomain.currentDomain.getDefinition("FishWave_" + _loc3_[_loc7_]) as Class;
               if(_loc6_ != null)
               {
                  _loc5_ = new _loc6_() as MovieClip;
                  _loc5_.mouseEnabled = false;
                  _loc5_.x = param1.x - _loc4_[_loc3_[_loc7_]][0];
                  _loc5_.y = param1.y - _loc4_[_loc3_[_loc7_]][1];
                  _loc5_.gotoAndPlay(1);
                  _fishContainer.addChild(_loc5_);
               }
            }
            _loc7_++;
         }
      }
      
      public function addFish(param1:PoolFish, param2:Number, param3:Number) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this._fishMovers == null)
         {
            this._fishMovers = new Array();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
         else if(this._fishMovers.length >= Consts.FISH_MAX_SIZE)
         {
            return;
         }
         var _loc4_:FishMover = new FishMover(this,param1);
         _loc4_.spawnPos = new Point(param2,param3);
         _loc4_.think();
         this._fishMovers.push(_loc4_);
         FishAnimationMgr.getInstance().loadFishes([param1]);
      }
      
      private function openLandFloatTip(param1:String, param2:int = 0) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc3_:Point = new Point(mouseX,mouseY);
         _loc3_ = localToGlobal(_loc3_);
         var _loc4_:Boolean = Boolean(Session.getInstance().me);
         var _loc5_:Object = {
            "text":param1,
            "me":_loc4_,
            "x":_loc3_.x,
            "y":_loc3_.y,
            "yAdjust":param2
         };
         this._controller.openFloat(Consts.FLOAT_TYPE_OPERATE,_loc5_);
      }
      
      private function operateHarvestAll(param1:Boolean) : void
      {
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         if(this._fishMovers == null)
         {
            return;
         }
         var _loc2_:int = int(this._fishMovers.length);
         var _loc3_:FishMover = null;
         if(param1 == true)
         {
            _loc4_ = new Point(mouseX,mouseY);
            _loc4_ = localToGlobal(_loc4_);
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc3_ = this._fishMovers[_loc5_] as FishMover;
               if(_loc3_ != null)
               {
                  if(_loc3_.hitTest(_loc4_.x,_loc4_.y) == true)
                  {
                     param1 = false;
                     break;
                  }
               }
               _loc5_++;
            }
         }
         if(param1 == true)
         {
            return;
         }
         if(this._controller.model.harvestAll() == -1)
         {
            this.openLandFloatTip("做人不能贪得无厌！");
            return;
         }
      }
      
      private function resetLastFish() : void
      {
         if(this._selectedFish != null)
         {
            this._selectedFish.continueMove();
            this._selectedFish = null;
         }
         this.hideInfoTip();
      }
      
      private function askDelete(param1:PoolFish) : void
      {
         var data:*;
         var onConfirmDeleteOK:Function = null;
         var pf:PoolFish = param1;
         onConfirmDeleteOK = function():void
         {
            _controller.model.harvest(_toBeDeleted,false);
         };
         if(pf == null)
         {
            return;
         }
         data = {
            "title":"捞起鱼苗",
            "text":"鱼儿还没有成熟，现在捞起将损失鱼苗！确定要进行捕捞么？",
            "confirmFn":onConfirmDeleteOK
         };
         this._controller.module.app.openWindowByName(Consts.WINDOW_NAME_CONFIRM,data);
         this._toBeDeleted = pf._id;
      }
      
      private function onPoolResLoadFailed(param1:IOErrorEvent) : void
      {
         trace("load water resource failed: " + param1.toString());
      }
      
      private function onHoverTimer(param1:TimerEvent) : void
      {
         if(this._fishMovers == null)
         {
            return;
         }
         var _loc2_:Point = new Point(this.mouseX,this.mouseY);
         _loc2_ = localToGlobal(_loc2_);
         var _loc3_:int = int(this._fishMovers.length);
         var _loc4_:FishMover = null;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = this._fishMovers[_loc5_] as FishMover;
            if(_loc4_ != null)
            {
               if(_loc4_.hitTest(_loc2_.x,_loc2_.y) == true)
               {
                  _loc4_.stop();
                  this._selectedFish = _loc4_;
                  this.showInfoTip(_loc4_.fish);
                  break;
               }
            }
            _loc5_++;
         }
      }
      
      public function refreshInfoTip(param1:PoolFish) : void
      {
         if(param1 == null || this._tip == null)
         {
            return;
         }
         if(param1._output > 0)
         {
            this._tip.update();
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._fishMovers == null)
         {
            this.stopLoadingAnimation();
            return;
         }
         var _loc2_:Boolean = true;
         var _loc3_:FishMover = null;
         var _loc4_:int = int(this._fishMovers.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = this._fishMovers[_loc5_] as FishMover;
            if(_loc3_ != null)
            {
               _loc3_.moveFrame();
               if(this._matureFlag != null && this._matureFlag["fish"] == _loc3_)
               {
                  this._matureFlag.x = _pool.x + _loc3_.x + (_loc3_.hFlip ? -1 : 1) * 10;
                  this._matureFlag.y = _pool.y + _loc3_.y - 4;
                  this._matureFlag.visible = true;
               }
               if(_loc3_.loaded == false)
               {
                  _loc2_ = false;
               }
            }
            _loc5_++;
         }
         if(_loc2_ == true)
         {
            this.stopLoadingAnimation();
         }
      }
      
      public function updateMatureFlag(param1:int) : void
      {
         if(this._matureFlag == null)
         {
            return;
         }
         var _loc2_:FishMover = this.findFishByID(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(this._matureFlag["fish"] == null)
         {
            this._matureFlag["fish"] = _loc2_;
            this._matureFlag.addEventListener(MouseEvent.CLICK,this.onClickMatureFlag,false,0,true);
         }
         else if(this._matureFlag["fish"] != _loc2_)
         {
            this._matureFlag["fish"] = _loc2_;
         }
      }
      
      private function createPool() : void
      {
         this.stopLoadingAnimation();
         var _loc1_:* = 0;
         var _loc2_:Class = CommonData.applicationDomain.getDefinition("WaterLand3") as Class;
         this._water = new _loc2_() as MovieClip;
         this._water.x = 8;
         this._water.y = 39;
         this._water.cacheAsBitmap = true;
         this._water.mouseEnabled = false;
         addChildAt(this._water,_loc1_++);
         if(_pool != null)
         {
            _pool.x = 229;
            _pool.y = 42;
            _pool.mouseEnabled = false;
            addChildAt(_pool,_loc1_++);
         }
         if(CommonData.applicationDomain.hasDefinition("StoneFrame1") == true)
         {
            _loc2_ = CommonData.applicationDomain.getDefinition("StoneFrame1") as Class;
            this._stone = new _loc2_();
            this._stone.x = -6;
            this._stone.y = 19;
            this._stone.cacheAsBitmap = true;
            this._stone.mouseEnabled = false;
            addChildAt(this._stone,_loc1_++);
         }
         this._matureFlag = Utils.getMaterial("HarvestFishFlag") as MovieClip;
         if(this._matureFlag != null)
         {
            this._matureFlag.visible = false;
            this._matureFlag.mouseEnabled = false;
            addChildAt(this._matureFlag,_loc1_++);
         }
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      }
      
      public function set disableMouse(param1:Boolean) : void
      {
         this._disableMouse = param1;
      }
      
      private function operateFeed(param1:int) : void
      {
         if(this._fishMovers == null)
         {
            return;
         }
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         if(_loc2_ == false)
         {
            return;
         }
         var _loc3_:Point = new Point(mouseX,mouseY);
         _loc3_ = localToGlobal(_loc3_);
         var _loc4_:int = int(this._fishMovers.length);
         var _loc5_:FishMover = null;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc5_ = this._fishMovers[_loc6_] as FishMover;
            if(_loc5_ != null)
            {
               if(_loc5_.hitTest(_loc3_.x,_loc3_.y) == true)
               {
                  if(_loc5_.fish.level == Consts.FISH_MAX_LEVEL)
                  {
                     this.openLandFloatTip("可收获了，不需要再喂食");
                     break;
                  }
                  if(_loc5_.fish._fertilize == true)
                  {
                     this.openLandFloatTip("对不起，您已经使用过鱼食了");
                     break;
                  }
                  this._controller.model.feed(_loc5_.fish._id,param1);
                  break;
               }
            }
            _loc6_++;
         }
      }
      
      private function showLoadingAnimation() : void
      {
         if(this._loading == null)
         {
            this._loading = new FarmLoading();
            this._loading.x = 220;
            this._loading.y = 148;
            this._loading.mouseEnabled = false;
            this._loading.mouseChildren = false;
            addChild(this._loading);
         }
      }
      
      public function showGuideArrow(param1:int) : void
      {
         var _loc2_:DisplayObjectContainer = this.fishContainer as DisplayObjectContainer;
         var _loc3_:Point = new Point(0,100);
         _loc3_ = _loc2_.localToGlobal(_loc3_);
         GameGuide.instance().showStep(param1,_loc3_.x,_loc3_.y);
         GameGuide.instance().autoHide(3);
      }
      
      private function onCheckLoaded(param1:Event) : void
      {
         if(CommonData.applicationDomain.hasDefinition("WaterLand3") == true)
         {
            removeEventListener(Event.ENTER_FRAME,this.onCheckLoaded);
            this.createPool();
         }
      }
      
      public function reset() : void
      {
         var _loc1_:FishMover = null;
         if(this._fishMovers != null)
         {
            for each(_loc1_ in this._fishMovers)
            {
               if(!(_loc1_ == null || _loc1_.fish == null))
               {
                  _loc1_.fish = null;
               }
            }
            this._fishMovers.splice(0);
         }
         this._selectedFish = null;
         this.hideInfoTip();
         this.hideHarvestFlag();
         this.stopLoadingAnimation();
      }
      
      public function showInfoTip(param1:PoolFish) : void
      {
         if(this._tip == null)
         {
            this._tip = new FishInfoTip(this);
         }
         this._tip.scaleX /= scaleX;
         this._tip.scaleY /= scaleY;
         this._tip.x = this._selectedFish.x + _pool.x - 50 / scaleX;
         this._tip.y = this._selectedFish.y - 25 / scaleY;
         this._tip.show(param1);
      }
      
      private function stopLoadingAnimation() : void
      {
         if(this._loading != null && this.contains(this._loading) == true)
         {
            this._loading.stop();
            removeChild(this._loading);
            this._loading = null;
         }
      }
      
      private function hideHarvestFlag() : void
      {
         if(this._matureFlag != null)
         {
            this._matureFlag.visible = false;
            this._matureFlag["fish"] = null;
            this._matureFlag.removeEventListener(MouseEvent.CLICK,this.onClickMatureFlag);
         }
      }
      
      private function operateHarvest() : void
      {
         if(this._fishMovers == null)
         {
            return;
         }
         var _loc1_:Point = new Point(mouseX,mouseY);
         _loc1_ = localToGlobal(_loc1_);
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         var _loc3_:int = int(this._fishMovers.length);
         var _loc4_:FishMover = null;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = this._fishMovers[_loc5_] as FishMover;
            if(_loc4_ != null)
            {
               if(_loc4_.hitTest(_loc1_.x,_loc1_.y) == true)
               {
                  if(_loc2_ == false && this.canSteal(_loc4_) == false)
                  {
                     break;
                  }
                  if(_loc2_ == true && _loc4_.fish.canHarvest == false)
                  {
                     this.askDelete(_loc4_.fish);
                     break;
                  }
                  this._toBeDeleted = -1;
                  this._controller.model.harvest(_loc4_.fish._id,_loc4_.fish.canHarvest);
                  break;
               }
            }
            _loc5_++;
         }
      }
      
      public function refreshMatureFlag(param1:Boolean) : void
      {
         if(this._fishMovers == null || this._matureFlag == null)
         {
            return;
         }
         if(param1 == false && this._matureFlag.visible == true)
         {
            return;
         }
         var _loc2_:FishMover = null;
         var _loc3_:Boolean = false;
         var _loc4_:int = int(this._fishMovers.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = this._fishMovers[_loc5_] as FishMover;
            if(!(_loc2_ == null || _loc2_.fish == null))
            {
               if(this.canHarvest(_loc2_.fish) == true)
               {
                  if(_loc3_ == false)
                  {
                     this._matureFlag["fish"] = _loc2_;
                     this._matureFlag.addEventListener(MouseEvent.CLICK,this.onClickMatureFlag,false,0,true);
                     _loc3_ = true;
                     break;
                  }
               }
            }
            _loc5_++;
         }
         if(_loc3_ == false)
         {
            this.hideHarvestFlag();
         }
      }
      
      private function loadRes() : void
      {
         var _loc1_:String = Settings.getInstance().getSecondUrl("water");
         if(_loc1_ == null || _loc1_ == "")
         {
            return;
         }
         this.showLoadingAnimation();
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPoolResLoaded,false,0,true);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onPoolResLoadFailed,false,0,true);
         this._loader.load(new URLRequest(_loc1_),new LoaderContext(false,CommonData.applicationDomain));
      }
      
      private function onClickMatureFlag(param1:MouseEvent) : void
      {
         var _loc4_:Boolean = false;
         if(this._disableMouse == true)
         {
            return;
         }
         param1.target.removeEventListener(MouseEvent.CLICK,this.onClickMatureFlag);
         if(this._matureFlag == null)
         {
            return;
         }
         var _loc2_:FishMover = this._matureFlag["fish"] as FishMover;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:CursorControl = null;
         if(this._controller.module != null && this._controller.module.app != null)
         {
            _loc3_ = this._controller.module.app.farmView.cursorCtrl;
         }
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.name == Consts.CURSOR_STYLE_FISHNET)
         {
            _loc4_ = Boolean(Session.getInstance().me);
            if(_loc4_ == false && this.canSteal(_loc2_) == false)
            {
               return;
            }
            this._toBeDeleted = -1;
            this._controller.model.harvest(_loc2_.fish._id,true);
         }
         else if(_loc3_.name == Consts.CURSOR_STYLE_FISHNET_ALL)
         {
            this.operateHarvestAll(false);
         }
      }
      
      private function operatePlant(param1:int) : void
      {
         if(this._controller.model.checkSize() == false)
         {
            this.openLandFloatTip("容量已达上限6，不能再养了");
            this._controller.module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
            return;
         }
         var _loc2_:Object = Settings.getInstance().getFishByID(param1.toString());
         if(_loc2_ == null)
         {
            return;
         }
         if(this._controller.model.poolSize + _loc2_["pool_size"] > Consts.FISH_MAX_SIZE)
         {
            this.openLandFloatTip(_loc2_["crop_name"] + "占用容量" + _loc2_["pool_size"] + "，池塘剩余容量不足");
            this._controller.module.app.dispatchEvent(new Event(Consts.CLOSE_MY_BAG));
            return;
         }
         this._controller.model.grow(param1);
      }
      
      public function harvestFish(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:FishMover = this.findFishByID(param1);
         if(_loc4_ == null)
         {
            return;
         }
         if(param2 > 0)
         {
            this.playHarvestAnimation(_loc4_,"+" + param2);
         }
         if(param3 == true)
         {
            this.removeFish(param1);
         }
         else
         {
            this.hideHarvestFlag();
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(this.checkCursor() == false)
         {
            return;
         }
         if(this._timer != null)
         {
            this._timer.stop();
         }
         this.resetLastFish();
         var _loc2_:CursorControl = null;
         if(this._controller.module != null && this._controller.module.app != null)
         {
            _loc2_ = this._controller.module.app.farmView.cursorCtrl;
         }
         if(this._mouseState != null)
         {
            _loc3_ = Boolean(Session.getInstance().me);
            if(this._mouseState["name"] == Consts.CURSOR_STYLE_ARROW)
            {
               this._controller.restoreLandCursor();
            }
            else if(this._mouseState["name"] == Consts.CURSOR_STYLE_FISHNET)
            {
               if(this._controller.model.canSteal(_loc3_) == false)
               {
                  this._controller.restoreLandCursor();
               }
            }
            else if(_loc2_ != null)
            {
               _loc2_.setCursor(this._mouseState["name"],this._mouseState["argument"]);
            }
            this._mouseState = null;
         }
         else if(this._controller.model.canSteal(_loc3_) == false)
         {
            _loc4_ = _loc2_.name == Consts.CURSOR_STYLE_TOOL && _loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISHFEED) != -1;
            _loc5_ = _loc2_.name == Consts.CURSOR_STYLE_CROPSEED && _loc2_.cursorArgument.indexOf(Consts.ITEM_TYPE_FISH) != -1;
            if(_loc4_ == false && _loc5_ == false)
            {
               this._controller.restoreLandCursor();
            }
         }
      }
      
      public function fillFishes(param1:Array) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this._fishMovers == null)
         {
            this._fishMovers = new Array();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
         var _loc2_:FishMover = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(this._fishMovers.length >= Consts.FISH_MAX_SIZE)
            {
               break;
            }
            _loc2_ = new FishMover(this,param1[_loc3_]);
            _loc2_.spawnPos = null;
            this._fishMovers.push(_loc2_);
            _loc2_.think();
            _loc3_++;
         }
         if(FishAnimationMgr.getInstance().loadFishes(param1) == true)
         {
            this.showLoadingAnimation();
         }
         this._selectedFish = null;
      }
      
      private function onPoolResLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         if(_loc2_ != null)
         {
            addEventListener(Event.ENTER_FRAME,this.onCheckLoaded,false,0,true);
         }
      }
      
      public function hideInfoTip() : void
      {
         if(this._tip != null)
         {
            this._tip.hide();
            this._tip.scaleX = this._tip.scaleY = 1;
         }
      }
      
      private function canSteal(param1:FishMover) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         var _loc2_:PoolFish = param1.fish;
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc3_:int = parseInt(Session.getInstance().hostId);
         if(_loc2_._thief.indexOf(_loc3_) != -1)
         {
            this.openLandFloatTip("做人不能贪得无厌！");
            return false;
         }
         if(_loc2_._left != 0 && _loc2_._left <= _loc2_.min)
         {
            this.openLandFloatTip("行行好吧，我所剩无几了！");
            return false;
         }
         return true;
      }
      
      private function playHarvestAnimation(param1:FishMover, param2:String) : void
      {
         if(param1 == null || param2 == null || param2 == "")
         {
            return;
         }
         var _loc3_:Point = new Point(mouseX,mouseY);
         _loc3_ = localToGlobal(_loc3_);
         _loc3_.x -= 100 * scaleX;
         _loc3_.y -= 20 * scaleY;
         var _loc4_:int = int(param1.fish._type);
         var _loc5_:Object = {
            "text":param2,
            "type":Consts.ITEM_TYPE_FISH,
            "cId":_loc4_,
            "x":_loc3_.x,
            "y":_loc3_.y
         };
         this._controller.openFloat(Consts.FLOAT_TYPE_HA,_loc5_);
      }
      
      public function showErrorMsg(param1:String, param2:int) : void
      {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         var _loc3_:FishMover = this.findFishByID(param2);
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Point = new Point(20,-12);
         _loc4_ = _loc3_.localToGlobal(_loc4_);
         var _loc5_:Boolean = Boolean(Session.getInstance().me);
         var _loc6_:Object = {
            "text":param1,
            "me":_loc5_,
            "x":_loc4_.x,
            "y":_loc4_.y,
            "yAdjust":0
         };
         this._controller.openFloat(Consts.FLOAT_TYPE_OPERATE,_loc6_);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(this._disableMouse == true)
         {
            return;
         }
         if(this.checkCursor() == false)
         {
            return;
         }
         if(this._selectedFish != null && this._selectedFish.hitTest(param1.stageX,param1.stageY) == true)
         {
            return;
         }
         this.resetLastFish();
         if(this._timer == null)
         {
            this._timer = new Timer(50,1);
            this._timer.addEventListener(TimerEvent.TIMER,this.onHoverTimer,false,0,true);
            this._timer.start();
         }
         else
         {
            this._timer.stop();
            this._timer.start();
         }
      }
      
      private function canHarvest(param1:PoolFish) : Boolean
      {
         var _loc3_:int = 0;
         if(param1 == null)
         {
            return false;
         }
         var _loc2_:Boolean = Boolean(Session.getInstance().me);
         if(_loc2_ == true)
         {
            return param1.canHarvest == true;
         }
         if(param1.canHarvest == false)
         {
            return false;
         }
         _loc3_ = parseInt(Session.getInstance().hostId);
         if(param1._thief.indexOf(_loc3_) != -1)
         {
            return false;
         }
         if(param1._left <= param1.min)
         {
            return false;
         }
         return true;
      }
      
      public function removeFish(param1:int) : void
      {
         if(this._fishMovers == null)
         {
            return;
         }
         var _loc2_:FishMover = null;
         var _loc3_:int = int(this._fishMovers.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = this._fishMovers[_loc4_] as FishMover;
            if(_loc2_ != null && _loc2_.fish._id == param1)
            {
               _loc2_.fish = null;
               if(this._selectedFish == _loc2_)
               {
                  this.hideInfoTip();
                  this._selectedFish = null;
               }
               if(this._matureFlag != null && this._matureFlag["fish"] == _loc2_)
               {
                  this.hideHarvestFlag();
               }
               this._fishMovers.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
      }
      
      private function checkCursor() : Boolean
      {
         var _loc2_:Array = null;
         var _loc1_:CursorControl = null;
         if(this._controller.module != null && this._controller.module.app != null)
         {
            _loc1_ = this._controller.module.app.farmView.cursorCtrl;
         }
         if(_loc1_ == null)
         {
            return false;
         }
         if(_loc1_.name == Consts.CURSOR_STYLE_ARROW || _loc1_.name == Consts.CURSOR_STYLE_FISHNET || _loc1_.name == Consts.CURSOR_STYLE_FISHNET_ALL)
         {
            return true;
         }
         if(_loc1_.name == Consts.CURSOR_STYLE_TOOL)
         {
            _loc2_ = _loc1_.cursorArgument.split(",");
            if(_loc2_ == null || _loc2_.length != 2)
            {
               return false;
            }
            if(_loc2_[0] == Consts.ITEM_TYPE_FISHFEED)
            {
               return true;
            }
         }
         return false;
      }
   }
}


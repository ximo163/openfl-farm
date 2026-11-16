package mc.view.farm.animals
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import mc.control.ViewControl;
   import mc.events.CursorEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.farm.GetCropID;
   import mc.view.farm.land.ClockOperateFloating;
   import mc.view.farm.land.FarmOperateFloating;
   import mc.view.main.floating.Float;
   
   public class AnimalManager extends EventDispatcher
   {
      
      private static var instance:AnimalManager;
      
      public static const ANIMAL_YOUZAI:Number = 1;
      
      public static const ANIMAL_SHENGZHANG:Number = 2;
      
      public static const ANIMAL_DAICHAN:Number = 3;
      
      public static const ANIMAL_SHENGCHAN:Number = 4;
      
      public static const ANIMAL_CHANHOU:Number = 5;
      
      public static const ANIMAL_SHOUHUO:Number = 6;
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var _moveRectagle:Rectangle;
      
      private var _state:String = "left";
      
      private var _gameTimer:Timer;
      
      private var _candoFlag:MovieClip;
      
      private var _animals:Array = [];
      
      public function AnimalManager()
      {
         super();
         this._gameTimer = new Timer(100);
         this._gameTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.farmData = MData.getInstance().farmData;
         this.mainData = MData.getInstance().mainData;
         this.farmData.addEventListener(FarmData.FARM_OPERATE,this.farmOperate,false,0,true);
         ViewControl.getInstance().addEventListener(FarmData.BEAT_ANIMAL,this.beatAnimal);
         ViewControl.getInstance().addEventListener(CursorEvent.CURSOR,this.setCursorHandler,false,0,true);
         ViewControl.getInstance().addEventListener("sFeed",this.onFeed);
         ViewControl.getInstance().addEventListener("canFeed",this.onCanFeed);
         ViewControl.getInstance().addEventListener("checkdo",this.checkDo);
         ViewControl.getInstance().addEventListener("animalStop",this.animalStop);
         ViewControl.getInstance().addEventListener("animalMov",this.animalMov);
         this._candoFlag = MaterialLib.getInstance().getMaterial("CandoMC") as MovieClip;
      }
      
      public static function getInstance() : AnimalManager
      {
         if(instance == null)
         {
            instance = new AnimalManager();
         }
         return instance;
      }
      
      private function getTime(param1:Number) : String
      {
         if(param1 >= 3600)
         {
            return Number(param1 / 3600).toFixed(1) + "小时";
         }
         if(param1 >= 60)
         {
            return Number(param1 / 60).toFixed(0) + "分钟";
         }
         if(param1 <= 60)
         {
            return param1 + "秒钟";
         }
         return "0";
      }
      
      private function beatAnimal(param1:ViewEvent) : void
      {
         var _loc3_:Animal = null;
         var _loc2_:int = int(param1.data);
         var _loc4_:Number = this.animals.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(Boolean(this.animals[_loc5_].data) && this.animals[_loc5_].data["serial"] == _loc2_)
            {
               _loc3_ = this.animals[_loc5_] as Animal;
               break;
            }
            _loc5_++;
         }
         _loc3_.mov(Math.floor(Math.random() * 4));
         _loc3_._x = 5 * _loc3_._x;
         _loc3_._y = 5 * _loc3_._y;
      }
      
      public function clearAll() : void
      {
         this._animals = null;
         this._gameTimer.stop();
      }
      
      private function onFeed(param1:Event) : void
      {
         var _loc3_:Animal = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            if(Boolean(_loc3_.data) && _loc3_.data.serial == FarmData.feedAnimalSerial)
            {
               _loc3_.stopMov();
               if(_loc3_.data.status == 3)
               {
                  _loc3_.setState(6);
               }
               else
               {
                  _loc3_.setState(5);
               }
               _loc3_.delayMov(2000);
               _loc3_.feeding = true;
               if(Boolean(_loc3_.flag) && _loc3_.contains(_loc3_.flag))
               {
                  _loc3_.removeChild(_loc3_.flag);
                  _loc3_.flag = null;
               }
               _loc3_.flag = MaterialLib.getInstance().getMaterial("SpecialFeedEnd") as MovieClip;
               _loc3_.flag.y = _loc3_.childBounds.y;
               _loc3_.addChild(_loc3_.flag);
               _loc3_.flag = null;
               break;
            }
            _loc2_++;
         }
      }
      
      private function animalStop(param1:Event) : void
      {
         var _loc3_:Animal = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            _loc3_._stopContinue = true;
            _loc3_.stopMov();
            _loc2_++;
         }
      }
      
      private function setCursorHandler(param1:CursorEvent) : void
      {
         if(param1.cursorName == "")
         {
            return;
         }
         if(param1.cursorName == "CursorTool")
         {
            this.checkFeedAnimal(param1.cursorArgument["tId"],param1.cursorArgument["type"]);
         }
         else if(param1.cursorName == "Cursor_Theft" || param1.cursorName == "Cursor_ShengChan")
         {
            this.checkDo();
         }
      }
      
      private function checkFeedAnimal(param1:Number, param2:String) : void
      {
         var _loc4_:Animal = null;
         var _loc5_:XML = null;
         var _loc6_:MovieClip = null;
         var _loc3_:Number = 0;
         while(_loc3_ < this._animals.length)
         {
            _loc4_ = this._animals[_loc3_] as Animal;
            _loc5_ = GetCropID.toolToAnimal(String(param1));
            if(Boolean(_loc4_.data) && Boolean(_loc5_) && param2 == "4")
            {
               if(Boolean(_loc4_.data && _loc4_.data.status != 4) && Boolean(_loc4_.data.status != 6) && _loc4_.data.cId == _loc5_.@id)
               {
                  if(_loc4_.flag == null)
                  {
                     if(_loc4_.contains(this._candoFlag))
                     {
                        _loc4_.removeChild(this._candoFlag);
                     }
                     _loc6_ = MaterialLib.getInstance().getMaterial("SpecialFeedFlag") as MovieClip;
                     _loc6_.gotoAndStop("f" + param1);
                     _loc6_.y = _loc4_.childBounds.y - 20;
                     _loc4_.addChild(_loc6_);
                     _loc4_.flag = _loc6_;
                  }
                  else
                  {
                     _loc4_.flag.gotoAndStop("f" + param1);
                  }
               }
               else if(_loc4_.flag)
               {
                  if(_loc4_.contains(_loc4_.flag))
                  {
                     _loc4_.removeChild(_loc4_.flag);
                     _loc4_.flag = null;
                  }
               }
            }
            else if(_loc4_.flag)
            {
               if(_loc4_.contains(_loc4_.flag))
               {
                  _loc4_.removeChild(_loc4_.flag);
                  _loc4_.flag = null;
               }
            }
            _loc3_++;
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = this._animals.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._animals[_loc3_].canMove)
            {
               this._animals[_loc3_].x += this._animals[_loc3_]._x;
               this._animals[_loc3_].y += this._animals[_loc3_]._y;
               if(int(Math.random() * 30) == 0)
               {
                  this._animals[_loc3_].changeState();
               }
               if(this._animals[_loc3_].x < this._moveRectagle.x)
               {
                  this._animals[_loc3_].x = this._moveRectagle.x;
                  this._animals[_loc3_].changeState();
               }
               if(this._animals[_loc3_].y < this._moveRectagle.y)
               {
                  this._animals[_loc3_].y = this._moveRectagle.y;
                  this._animals[_loc3_].changeState();
               }
               if(this._animals[_loc3_].x > this._moveRectagle.x + this._moveRectagle.width)
               {
                  this._animals[_loc3_].x = this._moveRectagle.x + this._moveRectagle.width;
                  this._animals[_loc3_].changeState();
               }
               if(this._animals[_loc3_].y > this._moveRectagle.y + this._moveRectagle.height)
               {
                  this._animals[_loc3_].y = this._moveRectagle.y + this._moveRectagle.height;
                  this._animals[_loc3_].changeState();
               }
            }
            _loc3_++;
         }
      }
      
      public function set animals(param1:Array) : void
      {
         this._animals = param1;
         this._gameTimer.start();
         var _loc2_:int = 0;
         while(_loc2_ < this._animals.length)
         {
            if(Boolean(this._animals[_loc2_].data) && this._animals[_loc2_].data["status"] == 4)
            {
               this.farmData.farmOperate = {
                  "text":"",
                  "type":"clock",
                  "serial":this._animals[_loc2_].data["serial"],
                  "t":this._animals[_loc2_].data["growTimeNext"]
               };
            }
            _loc2_++;
         }
      }
      
      public function set moveRectagle(param1:Rectangle) : void
      {
         this._moveRectagle = param1;
      }
      
      public function checkDo(param1:Event = null) : void
      {
         var _loc2_:Animal = null;
         var _loc3_:String = null;
         var _loc5_:Animal = null;
         this.hideflag();
         if(Boolean(this._candoFlag) && Boolean(this._candoFlag.parent))
         {
            this._candoFlag.parent.removeChild(this._candoFlag);
            this._candoFlag = null;
         }
         this._candoFlag = MaterialLib.getInstance().getMaterial("CandoMC") as MovieClip;
         var _loc4_:int = 0;
         while(_loc4_ < this._animals.length)
         {
            _loc5_ = this._animals[_loc4_] as Animal;
            if(Boolean(_loc5_.data) && _loc5_.data.status == 3)
            {
               _loc2_ = _loc5_;
               _loc3_ = "可生产";
               break;
            }
            if(Boolean(_loc5_.data) && Boolean(_loc5_.data.status == 6) && this.mainData.me)
            {
               _loc2_ = _loc5_;
               _loc3_ = "可收获";
               break;
            }
            _loc4_++;
         }
         if(Boolean(_loc2_) && Boolean(_loc2_.childBounds))
         {
            this._candoFlag.doTxt.text = _loc3_;
            this._candoFlag.x = 0;
            this._candoFlag.y = _loc2_.childBounds.y - 10;
            this._candoFlag.name = "cando";
            _loc2_.addChild(this._candoFlag);
         }
      }
      
      private function hideflag(param1:Event = null) : void
      {
         var _loc3_:Animal = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            if(Boolean(_loc3_.flag) && _loc3_.contains(_loc3_.flag))
            {
               _loc3_.removeChild(_loc3_.flag);
               _loc3_.flag = null;
            }
            _loc2_++;
         }
      }
      
      private function onCanFeed(param1:Event) : void
      {
         var _loc3_:Animal = null;
         var _loc4_:Object = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            _loc4_ = FarmData.feedAnimalReturn;
            if(Boolean(_loc3_.data) && _loc3_.data.serial == _loc4_["animal"]["serial"])
            {
               _loc3_.stopMov();
               _loc3_.delayMov(3000);
               _loc3_.feeding = true;
               if(Boolean(_loc3_.flag) && _loc3_.contains(_loc3_.flag))
               {
                  _loc3_.removeChild(_loc3_.flag);
                  _loc3_.flag = null;
               }
               _loc3_.flag = MaterialLib.getInstance().getMaterial("SpecialFeedCanEnd") as MovieClip;
               _loc3_.flag.name = "specialfeed";
               _loc3_.flag.y = _loc3_.childBounds.y;
               _loc3_.flag.t = "减少" + this.getTime(_loc4_.increase);
               _loc3_.flag.gotoAndPlay(2);
               _loc3_.addChild(_loc3_.flag);
               _loc3_.flag = null;
               break;
            }
            _loc2_++;
         }
      }
      
      private function farmOperate(param1:Event) : void
      {
         var _loc3_:Animal = null;
         var _loc6_:* = undefined;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc2_:Object = this.farmData.farmOperate;
         if(_loc2_["type"] != "animal" && _loc2_["type"] != "clock")
         {
            return;
         }
         var _loc4_:Number = this.animals.length;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(Boolean(this.animals[_loc5_].data) && this.animals[_loc5_].data["serial"] == this.farmData.farmOperate["serial"])
            {
               _loc3_ = this.animals[_loc5_] as Animal;
               break;
            }
            _loc5_++;
         }
         if(_loc3_)
         {
            if(_loc2_["type"] == "animal")
            {
               _loc6_ = new FarmOperateFloating(this.farmData.farmOperate["t"]);
               _loc6_.text = this.farmData.farmOperate["text"];
            }
            else if(_loc2_["type"] == "clock")
            {
               _loc6_ = new ClockOperateFloating(this.farmData.farmOperate["t"],_loc3_);
               _loc6_.animal = _loc3_;
            }
            _loc7_ = new Point(_loc3_.x,_loc3_.childBounds.y);
            _loc8_ = _loc3_.localToGlobal(_loc7_);
            _loc9_ = _loc3_.x - LocalData.rollCollection.scrollRect.x;
            _loc10_ = _loc8_.y;
            _loc6_.x = _loc9_;
            _loc6_.y = _loc10_ + 10;
            Float.open(_loc6_);
         }
      }
      
      public function get animals() : Array
      {
         return this._animals;
      }
      
      private function animalMov(param1:Event) : void
      {
         var _loc3_:Animal = null;
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            _loc3_._stopContinue = false;
            _loc3_.delayMov();
            _loc2_++;
         }
      }
   }
}


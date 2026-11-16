package mc.view.farm.animals
{
   import com.qzone.corelib.net.RSLManager;
   import common.MaterialLib;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import mc.model.FarmData;
   import mc.view.farm.GetCropID;
   
   public class Animal extends Sprite
   {
      
      private var farmData:FarmData;
      
      public var _y:Number;
      
      public var feeding:Boolean = false;
      
      private var _visibleMC:MovieClip;
      
      public var waitingShengChan:Boolean = false;
      
      private var _data:Object;
      
      private var _state:String = "left";
      
      private var _type:String = "";
      
      private var dt:Number = 600;
      
      private var _layerArray:Array = [];
      
      public var _stopContinue:Boolean = false;
      
      private var dataLoading:MovieClip;
      
      public var canMove:Boolean = false;
      
      private var _movx:Number = 1.6;
      
      private var _movy:Number = 1.6;
      
      private var _lib:MaterialLib = MaterialLib.getInstance();
      
      private var _posArray:Array = ["upleft","upright","downleft","downright","stop"];
      
      public var index:Number;
      
      private var _moveRectagle:Rectangle;
      
      public var flag:MovieClip;
      
      private var _animalMC:Sprite;
      
      private var _t:Number = 120;
      
      private var _delayTime:Timer;
      
      public var _x:Number;
      
      private var _noSkin:Boolean = false;
      
      public function Animal()
      {
         super();
         this.dataLoading = MaterialLib.getInstance().getMaterial("DataLoading") as MovieClip;
         if(this.dataLoading != null)
         {
            addChild(this.dataLoading);
         }
         this._noSkin = true;
      }
      
      public function set type(param1:String) : void
      {
         this._type = param1;
      }
      
      private function remove(param1:DisplayObjectContainer) : void
      {
         var _loc2_:Object = null;
         if(param1 == null)
         {
            return;
         }
         while(param1.numChildren > 0 && param1.getChildAt(0) != null)
         {
            _loc2_ = param1.getChildAt(0);
            if(_loc2_)
            {
               if(_loc2_ is DisplayObjectContainer)
               {
                  if(_loc2_ is Sprite)
                  {
                     Sprite(_loc2_).graphics.clear();
                  }
                  if(_loc2_ is MovieClip)
                  {
                     MovieClip(_loc2_).stop();
                  }
                  this.remove(_loc2_ as DisplayObjectContainer);
               }
               else
               {
                  param1.removeChildAt(0);
               }
            }
         }
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
      }
      
      public function delayMov(param1:Number = 3000) : void
      {
         if(!this._stopContinue)
         {
            if(!this._delayTime)
            {
               this._delayTime = new Timer(param1,1);
               this._delayTime.addEventListener(TimerEvent.TIMER_COMPLETE,this.doDelayMov);
            }
            this._delayTime.start();
         }
      }
      
      public function get childBounds() : Rectangle
      {
         var _loc1_:Rectangle = null;
         if(Boolean(this._animalMC) && contains(this._animalMC))
         {
            return this._animalMC.getBounds(this);
         }
         if(Boolean(this.dataLoading) && contains(this.dataLoading))
         {
            _loc1_ = this.dataLoading.getBounds(this);
            return this.dataLoading.getBounds(this);
         }
         return null;
      }
      
      public function mov(param1:int = -1) : void
      {
         if(!this._stopContinue)
         {
            this.changeState(param1);
            if(!this._noSkin)
            {
               this.canMove = true;
            }
         }
      }
      
      public function delayDestory(param1:Number = 0) : void
      {
         if(param1)
         {
            this.dt = param1;
         }
         var _loc2_:Timer = new Timer(this.dt,1);
         _loc2_.addEventListener(TimerEvent.TIMER_COMPLETE,this.destory);
         _loc2_.start();
      }
      
      public function destory(param1:TimerEvent = null) : void
      {
         if(param1)
         {
            Timer(param1.target).removeEventListener(TimerEvent.TIMER_COMPLETE,this.destory);
            Timer(param1.target).stop();
         }
         this.stopMov();
         if(this._animalMC)
         {
            this._animalMC.removeEventListener("mov",this.beginMovEvent);
            this._animalMC.removeEventListener("stop",this.stopMovEvent);
         }
         this.stopMC(this);
         this.remove(this);
      }
      
      public function stopMovEvent(param1:Event = null) : void
      {
         this.canMove = false;
      }
      
      public function set movTimer(param1:Number) : void
      {
         this._t = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function beginMovEvent(param1:Event = null) : void
      {
         this.canMove = true;
      }
      
      private function stopMC(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.numChildren > 0 && param1.getChildAt(0) != null)
         {
            param1.cacheAsBitmap = true;
            _loc2_ = param1.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = param1.getChildAt(_loc3_);
               if(_loc4_ is DisplayObjectContainer)
               {
                  if(_loc4_ is MovieClip)
                  {
                     _loc4_.stop();
                  }
                  this.stopMC(_loc4_ as DisplayObjectContainer);
               }
               _loc3_++;
            }
            if(param1 is MovieClip)
            {
               MovieClip(param1).stop();
            }
         }
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      private function doDelayMov(param1:TimerEvent) : void
      {
         if(Boolean(this.data) && this.data.status != FarmData.ANIMAL_SHENGCHAN)
         {
            if(this.feeding)
            {
               this.feeding = false;
            }
            this.mov();
         }
      }
      
      private function onDelayComplete(param1:TimerEvent) : void
      {
         this.mov();
      }
      
      public function changeState(param1:int = -1) : void
      {
         var _loc2_:Number = NaN;
         if(!this._data)
         {
            return;
         }
         if(Boolean(this._data) && this._data.status == FarmData.ANIMAL_SHENGCHAN)
         {
            return;
         }
         this._movy = 1.6;
         this._movx = 1.6;
         this._movx += (this._data.status - 5) / 6;
         this._movy += (this._data.status - 5) / 6;
         this._x = 0;
         this._y = 0;
         if(param1 != -1)
         {
            _loc2_ = param1;
         }
         else if(Math.random() > 0.4)
         {
            _loc2_ = 4;
         }
         else
         {
            _loc2_ = Math.floor(Math.random() * this._posArray.length);
         }
         this._state = this._posArray[_loc2_];
         switch(this._state)
         {
            case "upleft":
               this._x = -this._movx;
               this._y = -this._movy;
               break;
            case "upright":
               this._x = this._movx;
               this._y = -this._movy;
               break;
            case "downleft":
               this._x = -this._movx;
               this._y = this._movy;
               break;
            case "downright":
               this._x = this._movx;
               this._y = this._movy;
               break;
            case "stop":
               this._x = 0;
               this._y = 0;
         }
         this.setState(_loc2_);
      }
      
      public function stopMov() : void
      {
         this.canMove = false;
         if(this._delayTime)
         {
            this._delayTime.stop();
            this._delayTime.removeEventListener(TimerEvent.TIMER_COMPLETE,this.doDelayMov);
            this._delayTime = null;
            this.waitingShengChan = false;
         }
         this.setState(4);
      }
      
      public function setState(param1:Number) : void
      {
         var _loc2_:MovieClip = null;
         if(this._animalMC == null)
         {
            return;
         }
         while(this._animalMC.numChildren > 0)
         {
            _loc2_ = this._animalMC.getChildAt(0) as MovieClip;
            if(_loc2_)
            {
               _loc2_.stop();
               this._animalMC.removeChild(_loc2_);
               _loc2_ = null;
            }
         }
         this._visibleMC = this._layerArray[param1];
         if(this._visibleMC == null)
         {
            this._visibleMC = this._layerArray[0];
         }
         if(this._visibleMC)
         {
            this._visibleMC.cacheAsBitmap = true;
            this._animalMC.addChild(this._visibleMC);
            this._visibleMC.gotoAndPlay(1);
         }
      }
      
      public function set movy(param1:Number) : void
      {
         this._movy = param1;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         this._movy = 1.6;
         this._movx = 1.6;
         if(param1 != null)
         {
            this.setStatus(param1.status);
         }
      }
      
      public function setMoveRect(param1:Rectangle) : void
      {
         this._moveRectagle = param1;
      }
      
      public function set movx(param1:Number) : void
      {
         this._movx = param1;
      }
      
      public function setStatus(param1:Number) : void
      {
         var flagMC:MovieClip = null;
         var sfMC:MovieClip = null;
         var u:String = null;
         var a:MovieClip = null;
         var d:Number = param1;
         if(this._type == "")
         {
            return;
         }
         if(this._animalMC)
         {
            removeChild(this._animalMC);
            this._animalMC.removeEventListener("mov",this.beginMovEvent);
            this._animalMC.removeEventListener("stop",this.stopMovEvent);
         }
         this._animalMC = this._lib.getMaterial("Animal_" + this._type + "_" + d) as Sprite;
         if(!this._animalMC)
         {
            addChild(this.dataLoading);
            u = GetCropID.getAnimalURL(this._type,d);
            RSLManager.getInstance().requestClass("Animal_" + this._type + "_" + d,this.setStatus,u,d);
            return;
         }
         if(Boolean(this.dataLoading) && contains(this.dataLoading))
         {
            this.removeChild(this.dataLoading);
         }
         this._noSkin = false;
         this._animalMC.cacheAsBitmap = true;
         this._animalMC.mouseChildren = false;
         this._movx += (d - 5) / 6;
         this._movy += (d - 5) / 6;
         this._layerArray = [];
         addChild(this._animalMC);
         flagMC = this.getChildByName("cando") as MovieClip;
         if(flagMC)
         {
            setTimeout(function():void
            {
               if(d == FarmData.ANIMAL_DAICHAN || d == FarmData.ANIMAL_SHOUHUO)
               {
                  flagMC.y = childBounds.y - 10;
                  addChild(flagMC);
               }
            },50);
         }
         sfMC = this.getChildByName("specialfeed") as MovieClip;
         if(sfMC)
         {
            setTimeout(function():void
            {
               sfMC.y = childBounds.y;
               addChild(sfMC);
            },50);
         }
         while(this._animalMC.numChildren > 0)
         {
            a = this._animalMC.getChildAt(0) as MovieClip;
            if(a)
            {
               this._layerArray.push(a);
               a.stop();
               this._animalMC.removeChild(a);
            }
         }
         this.setState(4);
         this.canMove = false;
         if(d == FarmData.ANIMAL_SHENGCHAN)
         {
            this._animalMC.addChild(this._layerArray[0]);
            if(this._delayTime)
            {
               this._delayTime.stop();
               this._delayTime.removeEventListener(TimerEvent.TIMER_COMPLETE,this.doDelayMov);
               this._delayTime = null;
               this.waitingShengChan = false;
            }
            return;
         }
         this.mov();
         this._animalMC.addEventListener("mov",this.beginMovEvent);
         this._animalMC.addEventListener("stop",this.stopMovEvent);
      }
   }
}


package mc.view.farm.animals
{
   import com.adobe.serialization.json.JSON;
   import common.INI;
   import common.MaterialLib;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipClassLib;
   import mc.view.main.window.shop.ShopTinWindow;
   
   public class Hunter extends Sprite
   {
      
      private var _workPoint:MovieClip;
      
      public var canWork:Boolean = true;
      
      private var mainData:MainData;
      
      private var _posArray:Array = ["upleft","upright","downleft","downright","stop"];
      
      private var _data:Object;
      
      private var _hunMove:Boolean = false;
      
      private var canMove:Boolean = true;
      
      private var _moveRectagle:Rectangle = new Rectangle(250,370,530,280);
      
      private var _y:Number = 1.5;
      
      private var _mpTimer:Timer;
      
      private var _layerArray:Array = [];
      
      private var _skin:MovieClip;
      
      private var _gameTimer:Timer;
      
      private var _x:Number = 1.5;
      
      private var actions:int = 0;
      
      public function Hunter()
      {
         super();
         this.buttonMode = true;
         this.mouseChildren = false;
         this.mainData = MData.getInstance().mainData;
         ViewControl.getInstance().addEventListener("animalStop",this.hunterStop);
         ViewControl.getInstance().addEventListener("animalMov",this.hunterMov);
      }
      
      public function mp(param1:String = "work") : void
      {
         if(!this.parent)
         {
            return;
         }
         var _loc2_:String = GetCropID.getHunterMP(this.data["id"],param1);
         if(_loc2_)
         {
            this.mainData.mpData = null;
            this.mainData.mpData = {
               "talkInfo":_loc2_,
               "vx":this.x - 20,
               "vy":this.y + this.childBounds.y + 30
            };
            if(this._gameTimer)
            {
               this._gameTimer.stop();
            }
            setTimeout(this.hideMP,4000);
         }
      }
      
      private function openFn() : void
      {
         var _loc1_:Object = com.adobe.serialization.json.JSON.decode(INI.getInstance().data.hunter.food.text());
         var _loc2_:Object = {};
         _loc2_["id"] = _loc1_["id"];
         _loc2_["d"] = _loc1_["description"];
         _loc2_["t"] = _loc1_["type"];
         _loc2_["e"] = _loc1_["effect"];
         _loc2_["n"] = _loc1_["name"];
         _loc2_["l"] = _loc1_["left"];
         _loc2_["p"] = _loc1_["price"];
         _loc2_["qd"] = _loc1_["qdprice"];
         _loc2_["y"] = _loc1_["yqdprice"];
         _loc2_["o"] = _loc1_["order"];
         _loc2_["lt"] = _loc1_["limittips"];
         _loc2_["tips"] = _loc1_["tips"];
         var _loc3_:ShopTinWindow = new ShopTinWindow();
         _loc3_.data = _loc2_;
         WControl.open(_loc3_);
      }
      
      private function hunterMov(param1:Event) : void
      {
         this.canMove = true;
         if(this._skin)
         {
            this.work();
         }
      }
      
      public function setState(param1:int, param2:int = 0) : void
      {
         if(param1 == 4)
         {
            param1 = 5 + param2;
         }
         while(this._skin.numChildren > 0)
         {
            this._skin.removeChildAt(0);
         }
         if(this._layerArray[param1])
         {
            this._skin.addChild(this._layerArray[param1]);
            MovieClip(this._layerArray[param1]).gotoAndPlay(1);
         }
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function stopWork() : void
      {
         this.stop();
         this.canWork = false;
         while(this._skin.numChildren > 0)
         {
            this._skin.removeChildAt(0);
         }
         if(this._layerArray[4])
         {
            this._skin.addChild(this._layerArray[4]);
            MovieClip(this._layerArray[4]).gotoAndPlay(1);
            if(!this._workPoint && this.mainData.me)
            {
               this._workPoint = MaterialLib.getInstance().getMaterial("WorkPoint") as MovieClip;
               this._workPoint.x = 0;
               this._workPoint.y = this.childBounds.y + 20;
               addChild(this._workPoint);
            }
            else if(Boolean(this._workPoint) && contains(this._workPoint))
            {
               this.remove(this._workPoint);
            }
         }
         setTimeout(this.mp,5200,"nowork");
      }
      
      public function work(param1:MouseEvent = null) : void
      {
         if(this.canWork && this.canMove)
         {
            this._hunMove = true;
            if(!this._gameTimer)
            {
               this._gameTimer = new Timer(100);
            }
            this._gameTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this._gameTimer.start();
            this.changeState();
         }
      }
      
      public function changeState() : void
      {
         var _loc1_:Number = 1.5;
         var _loc2_:Number = 1.5;
         var _loc3_:int = Math.floor(Math.random() * this._posArray.length);
         var _loc4_:String = this._posArray[_loc3_];
         switch(_loc4_)
         {
            case "upleft":
               this._x = -_loc2_;
               this._y = -_loc1_;
               break;
            case "upright":
               this._x = _loc2_;
               this._y = -_loc1_;
               break;
            case "downleft":
               this._x = -_loc2_;
               this._y = _loc1_;
               break;
            case "downright":
               this._x = _loc2_;
               this._y = _loc1_;
               break;
            case "stop":
               this._x = 0;
               this._y = 0;
         }
         if(_loc4_ != "stop")
         {
            this.setState(_loc3_);
         }
         else
         {
            this.setState(_loc3_,int(Math.random() * (this.actions - 5)));
            this.mp();
         }
      }
      
      public function stop(param1:MouseEvent = null) : void
      {
         if(this._gameTimer)
         {
            this._gameTimer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._gameTimer.stop();
         }
      }
      
      public function set skin(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(this._skin) && contains(this._skin))
         {
            removeChild(this._skin);
         }
         this._skin = param1;
         addChild(this._skin);
         this._layerArray = [];
         while(this._skin.numChildren > 0)
         {
            _loc2_ = this._skin.getChildAt(0) as MovieClip;
            this._layerArray.push(_loc2_);
            _loc2_.stop();
            this._skin.removeChildAt(0);
         }
         this.canWork = true;
         this.actions = this._layerArray.length;
         if(Boolean(this._workPoint) && contains(this._workPoint))
         {
            this.remove(this._workPoint);
         }
         this.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function clear() : void
      {
         this.stop();
         this.remove(this);
      }
      
      private function hunterStop(param1:Event) : void
      {
         this.canMove = false;
         this.stop();
      }
      
      private function hideMP() : void
      {
         this.work();
         this.mainData.mpData = null;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:HunterFoodWindow = null;
         if(MData.getInstance().mainData.me)
         {
            if(this.canWork)
            {
               _loc2_ = new HunterFoodWindow();
               _loc2_.confirmFn = this.openFn;
               WControl.open(_loc2_);
            }
            else
            {
               this.openFn();
            }
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.filters = MainData.rollOverFilter;
         TipClassLib.register("HunterInfo",HunterInfo);
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "HunterInfo";
         _loc2_.tipArgument = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
         this.stop();
         if(this.canWork)
         {
            this.setState(4,int(Math.random() * (this.actions - 5)));
         }
         Cursor.useSystem(true);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.filters = null;
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         if(this.canWork)
         {
            this.work();
         }
         Cursor.useSystem(false);
      }
      
      public function get childBounds() : Rectangle
      {
         if(Boolean(this._skin) && contains(this._skin))
         {
            return this._skin.getBounds(this);
         }
         return null;
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
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this._hunMove)
         {
            this.x += this._x;
            this.y += this._y;
            if(int(Math.random() * 30) == 0)
            {
               this.changeState();
            }
            if(this.x < this._moveRectagle.x)
            {
               this.x = this._moveRectagle.x;
               this.changeState();
            }
            if(this.y < this._moveRectagle.y)
            {
               this.y = this._moveRectagle.y;
               this.changeState();
            }
            if(this.x > this._moveRectagle.x + this._moveRectagle.width)
            {
               this.x = this._moveRectagle.x + this._moveRectagle.width;
               this.changeState();
            }
            if(this.y > this._moveRectagle.y + this._moveRectagle.height)
            {
               this.y = this._moveRectagle.y + this._moveRectagle.height;
               this.changeState();
            }
         }
      }
   }
}


package mc.view.farm
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import mc.control.Command;
   import mc.control.FarmCommand;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.animals.Fly;
   import mc.view.farm.land.FarmOperateFloating;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   
   public class InsectScene extends Sprite
   {
      
      private var mainData:MainData;
      
      private var _flyArray:Array = [];
      
      private var farmData:FarmData;
      
      private var _post1Num:Number = 0;
      
      private var _helpPos:Point;
      
      private var _flyContent1:MovieClip;
      
      private var _flyContent2:MovieClip;
      
      private var farmCommand:FarmCommand;
      
      private var _myNum:Number;
      
      private var _pos1:Point = new Point(550,250);
      
      private var _pos2:Point = new Point(420,250);
      
      private var _flyNum1:Number = 0;
      
      private var _flyNum2:Number = 0;
      
      private var mouseE:MouseEvent;
      
      private var _mx:Number = 0;
      
      private var _my:Number = 0;
      
      private var time:Timer;
      
      private var postCount:Number = 0;
      
      private var _post2Num:Number = 0;
      
      private var _currentCount:Number = 0;
      
      public function InsectScene()
      {
         super();
         this.farmData = MData.getInstance().farmData;
         this.mainData = MData.getInstance().mainData;
         this.farmData.addEventListener(FarmData.FLY_DATA_CHANGE,this.setCount,false,0,true);
         this.farmData.addEventListener(FarmData.INSECT_KILL,this.killInsect);
         this.mainData.addEventListener(MainData.ANIMAL_CHANGE,this.refresh,false,0,true);
         this.addFly();
         this.addEventListener(Event.ADDED_TO_STAGE,this.onAddStage);
         this.farmCommand = Command.getInstance().farmCommand;
         this.farmData.addEventListener(FarmData.FARM_OPERATE,this.farmOperate,false,0,true);
         ViewControl.getInstance().addEventListener("killInsectError",this.onKillError);
         ViewControl.getInstance().addEventListener("killFlyError",this.onKillFlyError);
         cacheAsBitmap = true;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(Cursor.name == "Cursor_Donate")
         {
            return;
         }
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = MainData.rollOverFilter;
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc3_.tipType = "ProductInfo";
         _loc3_.tipArgument = param1.currentTarget;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      public function addFly() : void
      {
         this._flyContent1 = MaterialLib.getInstance().getMaterial("FlyContent") as MovieClip;
         this._flyContent1.x = this._pos1.x;
         this._flyContent1.y = this._pos1.y;
         this._flyContent1.name = "flyContent1";
         this._flyContent1.mouseChildren = false;
         this._flyContent1.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this._flyContent1.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this._flyContent2 = MaterialLib.getInstance().getMaterial("FlyContent") as MovieClip;
         this._flyContent2.x = this._pos2.x;
         this._flyContent2.y = this._pos2.y;
         this._flyContent2.name = "flyContent2";
         this._flyContent2.mouseChildren = false;
         this._flyContent2.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this._flyContent2.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      }
      
      private function FlyCanNotdo() : void
      {
         this._flyContent1.removeEventListener(MouseEvent.CLICK,this.onClick);
         this._flyContent2.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onTimer(param1:TimerEvent = null) : void
      {
         if(this.postCount > 0)
         {
            Command.getInstance().farmCommand.addFly(this.postCount);
            this.postCount = 0;
         }
         if(this._post1Num > 0)
         {
            Command.getInstance().farmCommand.killFly(1,this._post1Num);
            this._post1Num = 0;
         }
         if(this._post2Num > 0)
         {
            Command.getInstance().farmCommand.killFly(2,this._post2Num);
            this._post2Num = 0;
         }
         if(this._post1Num == 0 && this._post2Num == 0 && this.postCount == 0)
         {
            this.time.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.time = null;
         }
         this.FlyCanNotdo();
      }
      
      private function onKillError(param1:Event) : void
      {
         this.FlyCando();
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this._mx = param1.stageX;
         this._my = param1.stageY;
      }
      
      private function onAddFly(param1:MouseEvent) : void
      {
         var _loc2_:Fly = null;
         if(Cursor.name == "Cursor_Fly" && !Cursor.system)
         {
            if(Math.abs(param1.stageX - this._mx) >= 5 || Math.abs(param1.stageY - this._my) >= 5)
            {
               return;
            }
            this.mouseE = param1;
            if(!this.time)
            {
               this.time = new Timer(1000);
               this.time.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.time.start();
               this.postCount = 0;
            }
            if(FarmData.maxFly || FarmData.leftFly == 0)
            {
               this.farmData.farmOperate = {
                  "text":FarmData.maxErrInfo,
                  "type":"fly",
                  "me":this.mainData.me
               };
               Cursor.setCursor("CursorArrow");
               return;
            }
            if(this.farmData.flyData["num"] >= 8)
            {
               this.farmData.farmOperate = {
                  "text":"主人牧场最多放8只蚊子，现已满",
                  "type":"fly",
                  "me":this.mainData.me
               };
               return;
            }
            if(this._currentCount < 8)
            {
               _loc2_ = new Fly();
               _loc2_.x = param1.stageX + LocalData.rollCollection.scrollRect.x;
               _loc2_.y = param1.stageY + LocalData.rollCollection.scrollRect.y;
               if(this._currentCount % 2 != 0)
               {
                  _loc2_.flyTo(this._pos1);
               }
               else
               {
                  _loc2_.flyTo(this._pos2);
               }
               addChild(_loc2_);
               this._flyArray.push(_loc2_);
               ++this.postCount;
               ++this._currentCount;
            }
            else
            {
               this.farmData.farmOperate = {
                  "text":"主人牧场最多放8只蚊子，现已满",
                  "type":"fly",
                  "me":this.mainData.me
               };
            }
         }
      }
      
      private function onKillFlyError(param1:Event) : void
      {
         if(this.time)
         {
            this.time.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.time = null;
         }
         this.FlyCando();
      }
      
      public function setCount(param1:Event = null) : void
      {
         this._currentCount = this.farmData.flyData["num"];
         this._flyNum1 = this.farmData.flyData["flyNum1"];
         this._flyNum2 = this.farmData.flyData["flyNum2"];
         addChild(this._flyContent1);
         addChild(this._flyContent2);
         if(this._flyNum1 > 0)
         {
            this._flyContent1.gotoAndStop(this._flyNum1);
         }
         else
         {
            removeChild(this._flyContent1);
         }
         if(this._flyNum2 > 0)
         {
            this._flyContent2.gotoAndStop(this._flyNum2);
         }
         else
         {
            removeChild(this._flyContent2);
         }
         this.FlyCando();
      }
      
      private function FlyCando() : void
      {
         this._flyContent1.addEventListener(MouseEvent.CLICK,this.onClick);
         this._flyContent2.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function refresh(param1:Event) : void
      {
         if(this.time)
         {
            this.time.stop();
            this.time.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.time = null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._flyArray.length)
         {
            (this._flyArray[_loc2_] as Fly).distory();
            _loc2_++;
         }
         this._flyArray = [];
      }
      
      private function onAddStage(param1:Event) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onAddFly);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function killInsect(param1:Event) : void
      {
         var _loc2_:MovieClip = MaterialLib.getInstance().getMaterial("HelpAdd") as MovieClip;
         addChild(_loc2_);
         _loc2_.num.text = this.farmData.insectExp["addExp"];
         _loc2_.x = this._helpPos.x;
         _loc2_.y = this._helpPos.y;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(Cursor.name == "Cursor_Donate")
         {
            return;
         }
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [];
         var _loc3_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:FarmOperateFloating = null;
         if(Cursor.name == "")
         {
            return;
         }
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         ViewControl.getInstance().dispatchEvent(_loc2_);
         if(Cursor.name == "Cursor_Flapper")
         {
            this.mouseE = param1;
            if(this.farmData.flyData.num <= this.farmData.flyData["mynum"] && this.farmData.flyData["mynum"] != 0)
            {
               _loc4_ = new FarmOperateFloating();
               _loc4_.text = "证据不能毁灭";
               _loc4_.x = param1.stageX;
               _loc4_.y = param1.stageY;
               Float.open(_loc4_);
               return;
            }
            if(!this.time)
            {
               this.time = new Timer(1000);
               this.time.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.time.start();
            }
            if(param1.currentTarget.name == "flyContent1" && this._post1Num < this.farmData.flyData["flyNum1"])
            {
               ++this._post1Num;
               if(this._post1Num == this._flyNum1)
               {
                  this.onTimer();
               }
            }
            if(param1.currentTarget.name == "flyContent2" && this._post2Num < this.farmData.flyData["flyNum2"])
            {
               ++this._post2Num;
               if(this._post2Num == this._flyNum2)
               {
                  this.onTimer();
               }
            }
            _loc3_ = MaterialLib.getInstance().getMaterial("FlyDead") as MovieClip;
            addChild(_loc3_);
            _loc3_.x = param1.stageX + LocalData.rollCollection.scrollRect.x;
            _loc3_.y = param1.stageY + LocalData.rollCollection.scrollRect.y;
            this._helpPos = new Point(_loc3_.x,_loc3_.y);
         }
      }
      
      private function farmOperate(param1:Event) : void
      {
         var _loc2_:FarmOperateFloating = new FarmOperateFloating(this.farmData.farmOperate["me"]);
         _loc2_.text = this.farmData.farmOperate["text"];
         var _loc3_:String = this.farmData.farmOperate["type"];
         if(Boolean(this.mouseE) && _loc3_ == "fly")
         {
            _loc2_.x = this._mx;
            _loc2_.y = this._my;
            Float.open(_loc2_);
            this.mouseE = null;
         }
      }
   }
}


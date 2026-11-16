package mc.view.farm
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import mc.control.ViewControl;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.view.farm.animals.Animal;
   
   public class WhistleManager extends EventDispatcher
   {
      
      private static var _instance:WhistleManager;
      
      private var hspace:Number = 80;
      
      private var closeTimer:Timer;
      
      private var vspace:Number = 60;
      
      private var _animals:Array;
      
      private var _whistleData:Object;
      
      public function WhistleManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function getInstance() : WhistleManager
      {
         if(_instance == null)
         {
            _instance = new WhistleManager();
         }
         return _instance;
      }
      
      public function setWhistleData(param1:Object) : void
      {
         this._whistleData = param1;
      }
      
      public function start() : void
      {
         if(this._animals == null || this._whistleData == null)
         {
            return;
         }
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._animals.length)
         {
            if(this._animals[_loc2_].data)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         var _loc3_:Array = [];
         switch(this._whistleData["p"])
         {
            case 1:
               _loc3_ = [{
                  "startX":340,
                  "startY":410
               },{
                  "x":0,
                  "y":0
               },{
                  "x":1,
                  "y":0
               },{
                  "x":2,
                  "y":0
               },{
                  "x":3,
                  "y":0
               },{
                  "x":4,
                  "y":0
               },{
                  "x":0,
                  "y":1
               },{
                  "x":1,
                  "y":1
               },{
                  "x":2,
                  "y":1
               },{
                  "x":3,
                  "y":1
               },{
                  "x":4,
                  "y":1
               },{
                  "x":0,
                  "y":2
               },{
                  "x":1,
                  "y":2
               },{
                  "x":2,
                  "y":2
               },{
                  "x":3,
                  "y":2
               },{
                  "x":4,
                  "y":2
               },{
                  "x":0,
                  "y":3
               },{
                  "x":1,
                  "y":3
               },{
                  "x":2,
                  "y":3
               },{
                  "x":3,
                  "y":3
               },{
                  "x":4,
                  "y":3
               }];
               break;
            case 2:
               _loc3_ = [{
                  "startX":370,
                  "startY":410
               },{
                  "x":0,
                  "y":0
               },{
                  "x":0,
                  "y":1
               },{
                  "x":0,
                  "y":2
               },{
                  "x":0,
                  "y":3
               },{
                  "x":0,
                  "y":4
               },{
                  "x":1,
                  "y":0
               },{
                  "x":1,
                  "y":1
               },{
                  "x":1,
                  "y":2
               },{
                  "x":1,
                  "y":3
               },{
                  "x":1,
                  "y":4
               },{
                  "x":2,
                  "y":0
               },{
                  "x":2,
                  "y":1
               },{
                  "x":2,
                  "y":2
               },{
                  "x":2,
                  "y":3
               },{
                  "x":2,
                  "y":4
               },{
                  "x":3,
                  "y":0
               },{
                  "x":3,
                  "y":1
               },{
                  "x":3,
                  "y":2
               },{
                  "x":3,
                  "y":3
               },{
                  "x":3,
                  "y":4
               }];
               break;
            case 3:
               _loc3_ = [{
                  "startX":500,
                  "startY":390
               },{
                  "x":0,
                  "y":0
               },{
                  "x":-0.5,
                  "y":1
               },{
                  "x":0.5,
                  "y":1
               },{
                  "x":-1,
                  "y":2
               },{
                  "x":0,
                  "y":2
               },{
                  "x":1,
                  "y":2
               },{
                  "x":-1.5,
                  "y":3
               },{
                  "x":-0.5,
                  "y":3
               },{
                  "x":0.5,
                  "y":3
               },{
                  "x":1.5,
                  "y":3
               },{
                  "x":-2,
                  "y":4
               },{
                  "x":-1,
                  "y":4
               },{
                  "x":0,
                  "y":4
               },{
                  "x":1,
                  "y":4
               },{
                  "x":2,
                  "y":4
               }];
               break;
            case 4:
               if(_loc1_ == 9)
               {
                  _loc3_ = [{
                     "startX":420,
                     "startY":410
                  },{
                     "x":0,
                     "y":0
                  },{
                     "x":1,
                     "y":0
                  },{
                     "x":2,
                     "y":0
                  },{
                     "x":0,
                     "y":1
                  },{
                     "x":1,
                     "y":1
                  },{
                     "x":2,
                     "y":1
                  },{
                     "x":0,
                     "y":2
                  },{
                     "x":1,
                     "y":2
                  },{
                     "x":2,
                     "y":2
                  }];
                  break;
               }
               if(_loc1_ == 16)
               {
                  _loc3_ = [{
                     "startX":370,
                     "startY":410
                  },{
                     "x":0,
                     "y":0
                  },{
                     "x":1,
                     "y":0
                  },{
                     "x":2,
                     "y":0
                  },{
                     "x":3,
                     "y":0
                  },{
                     "x":0,
                     "y":1
                  },{
                     "x":1,
                     "y":1
                  },{
                     "x":2,
                     "y":1
                  },{
                     "x":3,
                     "y":1
                  },{
                     "x":0,
                     "y":2
                  },{
                     "x":1,
                     "y":2
                  },{
                     "x":2,
                     "y":2
                  },{
                     "x":3,
                     "y":2
                  },{
                     "x":0,
                     "y":3
                  },{
                     "x":1,
                     "y":3
                  },{
                     "x":2,
                     "y":3
                  },{
                     "x":3,
                     "y":3
                  }];
                  break;
               }
            case 5:
               if(_loc1_ == 8)
               {
                  _loc3_ = [{
                     "startX":430,
                     "startY":410
                  },{
                     "x":0,
                     "y":0
                  },{
                     "x":1,
                     "y":0
                  },{
                     "x":2,
                     "y":0
                  },{
                     "x":0,
                     "y":1
                  },{
                     "x":2,
                     "y":1
                  },{
                     "x":0,
                     "y":2
                  },{
                     "x":1,
                     "y":2
                  },{
                     "x":2,
                     "y":2
                  }];
                  break;
               }
               if(_loc1_ == 12)
               {
                  _loc3_ = [{
                     "startX":400,
                     "startY":410
                  },{
                     "x":0,
                     "y":0
                  },{
                     "x":1,
                     "y":0
                  },{
                     "x":2,
                     "y":0
                  },{
                     "x":3,
                     "y":0
                  },{
                     "x":0,
                     "y":1
                  },{
                     "x":3,
                     "y":1
                  },{
                     "x":0,
                     "y":2
                  },{
                     "x":3,
                     "y":2
                  },{
                     "x":0,
                     "y":3
                  },{
                     "x":1,
                     "y":3
                  },{
                     "x":2,
                     "y":3
                  },{
                     "x":3,
                     "y":3
                  }];
                  break;
               }
               if(_loc1_ == 16)
               {
                  _loc3_ = [{
                     "startX":360,
                     "startY":390
                  },{
                     "x":0,
                     "y":0
                  },{
                     "x":1,
                     "y":0
                  },{
                     "x":2,
                     "y":0
                  },{
                     "x":3,
                     "y":0
                  },{
                     "x":4,
                     "y":0
                  },{
                     "x":0,
                     "y":1
                  },{
                     "x":4,
                     "y":1
                  },{
                     "x":0,
                     "y":2
                  },{
                     "x":4,
                     "y":2
                  },{
                     "x":0,
                     "y":3
                  },{
                     "x":4,
                     "y":3
                  },{
                     "x":0,
                     "y":4
                  },{
                     "x":1,
                     "y":4
                  },{
                     "x":2,
                     "y":4
                  },{
                     "x":3,
                     "y":4
                  },{
                     "x":4,
                     "y":4
                  }];
               }
         }
         this._animals.sort(this.sortFunction);
         MData.getInstance().toolData.mpData = {"info":MData.getInstance().toolData.viewWhistleData["i"]};
         this.initPos(_loc3_);
         ViewControl.getInstance().dispatchEvent(new Event(MPScene.MAO_PAO));
         if(!this.closeTimer)
         {
            this.closeTimer = new Timer(5000,1);
            this.closeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onClose);
         }
         this.closeTimer.start();
      }
      
      private function initPos(param1:Array) : void
      {
         var _loc4_:Animal = null;
         var _loc2_:Number = 1;
         var _loc3_:Number = 0;
         while(_loc3_ < this._animals.length)
         {
            _loc4_ = this._animals[_loc3_] as Animal;
            if(Boolean(_loc4_.data) && Boolean(_loc4_.data.status != FarmData.ANIMAL_SHENGCHAN) && _loc4_.data.buyTime != 0)
            {
               if(_loc2_ == param1.length)
               {
                  break;
               }
               _loc4_.stopMov();
               _loc4_.x = param1[0].startX + this.hspace * param1[_loc2_].x;
               _loc4_.y = param1[0].startY + this.vspace * param1[_loc2_].y;
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      public function clear() : void
      {
         if(this.closeTimer)
         {
            this.closeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onClose);
            this.closeTimer.stop();
            this.closeTimer = null;
         }
      }
      
      public function stop(param1:TimerEvent = null) : void
      {
         var _loc3_:Animal = null;
         if(this._animals == null || this._whistleData == null)
         {
            return;
         }
         var _loc2_:Number = 0;
         while(_loc2_ < this._animals.length)
         {
            _loc3_ = this._animals[_loc2_] as Animal;
            if(Boolean(_loc3_.data) && _loc3_.data.status != FarmData.ANIMAL_SHENGCHAN)
            {
               _loc3_.mov();
            }
            _loc2_++;
         }
         this._animals = null;
         this._whistleData = null;
      }
      
      private function sortFunction(param1:Object, param2:Object) : Number
      {
         if(!param1.data || !param2.data)
         {
            return 0;
         }
         if(param1.data.status > param2.data.status)
         {
            return 1;
         }
         if(param1.data.status < param2.data.status)
         {
            return -1;
         }
         if(param1.data.status == param2.data.status)
         {
            if(param1.data.cId < param2.data.cId)
            {
               return -1;
            }
            return 1;
         }
         return 0;
      }
      
      private function onClose(param1:TimerEvent = null) : void
      {
         this.closeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onClose);
         this.closeTimer.stop();
         this.closeTimer = null;
         this.stop();
      }
      
      public function setAnimal(param1:Array) : void
      {
         this._animals = param1;
      }
   }
}


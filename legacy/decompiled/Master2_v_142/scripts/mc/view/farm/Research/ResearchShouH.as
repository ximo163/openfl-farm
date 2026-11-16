package mc.view.farm.Research
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ResearchShouH extends Sprite
   {
      
      private var timer:Timer;
      
      private var _animalID:int;
      
      private var _animals:Array;
      
      public function ResearchShouH(param1:Array)
      {
         super();
         this._animals = param1;
         this.init();
      }
      
      private function init() : void
      {
         var _loc1_:ResearchProduct = new ResearchProduct(this._animals[this._animalID]["id"],this._animals[this._animalID]["num"]);
         _loc1_.x = Math.random() * 30;
         addChild(_loc1_);
         ++this._animalID;
         this.timer = new Timer(1000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:ResearchProduct = null;
         var _loc3_:DisplayObject = null;
         if(this._animalID < this._animals.length)
         {
            _loc2_ = new ResearchProduct(this._animals[this._animalID]["id"],this._animals[this._animalID]["num"]);
            _loc2_.x = Math.random() * 100;
            addChild(_loc2_);
            ++this._animalID;
         }
         else
         {
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer = null;
            while(this.numChildren)
            {
               _loc3_ = this.getChildAt(0) as DisplayObject;
               if(_loc3_)
               {
                  this.removeChild(_loc3_);
                  _loc3_ = null;
               }
            }
            ResearchModel.gi().dispatchEvent(new ResearchEvent(ResearchEvent.DENSHED_RESEARCH_SHOUCOMPLETE_OK));
         }
      }
   }
}


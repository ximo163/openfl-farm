package mc.view.main.floating
{
   import common.LocalData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mc.control.ViewControl;
   import mc.events.FloatingEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.land.ClockOperateFloating;
   
   public class FloatingLayer extends Sprite
   {
      
      private var left:Number;
      
      private var drag:Boolean = false;
      
      private var top:Number;
      
      public function FloatingLayer()
      {
         super();
         mouseEnabled = false;
         mouseChildren = false;
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         this.drag = true;
      }
      
      private function updateAnimalSkin(param1:Event) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            _loc3_ = this.getChildAt(_loc2_);
            if(_loc3_ is ClockOperateFloating)
            {
               ClockOperateFloating(_loc3_).updatePos();
            }
            _loc2_++;
         }
      }
      
      private function addedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         this.init();
      }
      
      private function hideFloating(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            this.getChildAt(_loc2_).visible = false;
            _loc2_++;
         }
         MainData.Stage = "wild";
      }
      
      private function floatingClose(param1:FloatingEvent) : void
      {
         if(contains(param1.floating))
         {
            removeChild(param1.floating);
         }
      }
      
      private function init() : void
      {
         ViewControl.getInstance().addEventListener(FloatingEvent.FLOATING_OPEN,this.floatingOpen,false,0,true);
         ViewControl.getInstance().addEventListener(FloatingEvent.FLOATING_CLOSE,this.floatingClose,false,0,true);
         ViewControl.getInstance().addEventListener("addFoodOk",this.clearFloating,false,0,true);
         this.left = LocalData.rollCollection.scrollRect.x;
         this.top = LocalData.rollCollection.scrollRect.y;
         this.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         this.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         MData.getInstance().mainData.addEventListener(MainData.UPDATE_ANIMAL_MATERIAL,this.updateAnimalSkin,false,0,true);
         ViewControl.getInstance().addEventListener(EvtAPI.SHOW_WILD_STAGE,this.hideFloating);
         ViewControl.getInstance().addEventListener(EvtAPI.SHOW_FARM_STAGE,this.showFloating);
      }
      
      private function showFloating(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            this.getChildAt(_loc2_).visible = true;
            _loc2_++;
         }
         MainData.Stage = "farm";
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         if(this.drag)
         {
            _loc2_ = LocalData.rollCollection.scrollRect.x - this.left;
            _loc3_ = LocalData.rollCollection.scrollRect.y - this.top;
            _loc4_ = 0;
            while(_loc4_ < this.numChildren)
            {
               this.getChildAt(_loc4_).x = this.getChildAt(_loc4_).x + -_loc2_;
               this.getChildAt(_loc4_).y = this.getChildAt(_loc4_).y + -_loc3_;
               _loc4_++;
            }
            this.left = LocalData.rollCollection.scrollRect.x;
            this.top = LocalData.rollCollection.scrollRect.y;
         }
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.drag = false;
      }
      
      private function clearFloating(param1:Event) : void
      {
         while(this.numChildren > 0)
         {
            removeChildAt(0);
         }
      }
      
      private function floatingOpen(param1:FloatingEvent) : void
      {
         param1.floating.start();
         addChild(param1.floating);
         if(MainData.Stage == "wild")
         {
            param1.floating.visible = false;
         }
      }
   }
}


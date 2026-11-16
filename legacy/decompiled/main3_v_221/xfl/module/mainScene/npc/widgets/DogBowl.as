package module.mainScene.npc.widgets
{
   import common.Session;
   import common.misc.Utils;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import module.mainScene.npc.NPCView;
   import report.UserActionRecorder;
   
   public class DogBowl extends Sprite
   {
      
      private var m_parent:NPCView;
      
      private const salverX:int = 400;
      
      private const salverY:int = 200;
      
      public function DogBowl(param1:NPCView)
      {
         super();
         this.m_parent = param1;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.m_parent.controller.useSystemCursor(false);
      }
      
      private function removeSalver() : void
      {
         var _loc3_:DisplayObject = null;
         var _loc1_:int = this.numChildren;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = this.removeChildAt(0);
            _loc3_ = null;
            _loc2_++;
         }
      }
      
      private function onClicked(param1:Event) : void
      {
         this.m_parent.controller.model.loadDogFoodStatus();
         UserActionRecorder.recordAction(UserActionRecorder.HF_DOGBOWL_CLICKED);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.m_parent.controller.useSystemCursor(true);
      }
      
      public function set food(param1:Boolean) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         this.removeSalver();
         if(param1 == true)
         {
            _loc2_ = Utils.getMaterial("DogFoodNull") as Sprite;
            addChild(_loc2_);
            _loc2_.x = this.salverX;
            _loc2_.y = this.salverY;
            _loc2_.scaleX = 0.5;
            _loc2_.scaleY = 0.5;
            if(Session.getInstance().me == true)
            {
               _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
               _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
               _loc2_.addEventListener(MouseEvent.CLICK,this.onClicked);
               _loc2_.buttonMode = true;
               _loc2_.mouseEnabled = true;
            }
            else
            {
               _loc2_.buttonMode = false;
               _loc2_.mouseEnabled = false;
            }
         }
         else
         {
            _loc3_ = Utils.getMaterial("DogFood") as Sprite;
            addChild(_loc3_);
            _loc3_.x = this.salverX;
            _loc3_.y = this.salverY;
            _loc3_.scaleX = 0.5;
            _loc3_.scaleY = 0.5;
            if(Session.getInstance().me == true)
            {
               _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
               _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
               _loc3_.addEventListener(MouseEvent.CLICK,this.onClicked);
               _loc3_.buttonMode = true;
               _loc3_.mouseEnabled = true;
            }
            else
            {
               _loc3_.buttonMode = false;
               _loc3_.mouseEnabled = false;
            }
         }
      }
   }
}


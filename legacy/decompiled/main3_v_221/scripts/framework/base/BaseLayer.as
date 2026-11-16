package framework.base
{
   import flash.display.Sprite;
   import flash.events.Event;
   import interfaces.IMsgCenter;
   
   public class BaseLayer extends Sprite
   {
      
      protected var m_msgCenter:IMsgCenter;
      
      public function BaseLayer(param1:IMsgCenter)
      {
         super();
         this.m_msgCenter = param1;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.init();
      }
      
      protected function init() : void
      {
      }
   }
}


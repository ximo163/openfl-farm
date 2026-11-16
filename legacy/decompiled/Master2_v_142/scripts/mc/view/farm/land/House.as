package mc.view.farm.land
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class House extends MovieClip
   {
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      public var space:Number = 3;
      
      private var _houseMc:MovieClip;
      
      public function House(param1:String)
      {
         super();
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this._houseMc = this.lib.getMaterial("House") as MovieClip;
         addChild(this._houseMc);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
      }
      
      public function addAnimal() : void
      {
      }
   }
}


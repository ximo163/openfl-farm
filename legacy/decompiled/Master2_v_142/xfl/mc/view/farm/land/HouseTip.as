package mc.view.farm.land
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.*;
   import mc.view.main.tip.Tip;
   
   public class HouseTip extends Tip
   {
      
      private var _tip:MovieClip;
      
      public function HouseTip()
      {
         super();
         this._tip = MaterialLib.getInstance().getMaterial("HouseTip") as MovieClip;
         addChild(this._tip);
      }
      
      override public function set data(param1:Object) : void
      {
         this.x = param1.x - LocalData.rollCollection.scrollRect.x;
         this.y = param1.y - LocalData.rollCollection.scrollRect.y;
         if(param1.name == "house1")
         {
            this.x += 140;
            this.y += -80;
         }
      }
   }
}


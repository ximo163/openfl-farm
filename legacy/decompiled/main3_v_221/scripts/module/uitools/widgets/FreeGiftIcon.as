package module.uitools.widgets
{
   import common.Settings;
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class FreeGiftIcon extends MovieClip
   {
      
      public var Name:String;
      
      private var ani:MovieClip;
      
      public function FreeGiftIcon()
      {
         var _loc1_:MovieClip = null;
         super();
         _loc1_ = Utils.getMaterial("Freegift") as MovieClip;
         _loc1_.name = "_freegift_";
         addChild(_loc1_);
         this.mouseChildren = false;
      }
      
      public function init(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc2_:MovieClip = this.getChildByName("_freegift_") as MovieClip;
         var _loc3_:Object = Settings.getInstance().getFreeGift(param1["gift"]);
         if(int(param1["unread"]) > 50)
         {
            _loc4_ = "50+";
         }
         else
         {
            _loc4_ = param1["unread"];
         }
         _loc2_.numBox.num_txt.text = _loc4_;
         if(_loc4_ == "0")
         {
            _loc2_.numBox.visible = false;
         }
         else
         {
            _loc2_.numBox.visible = true;
         }
      }
      
      public function showAnimation() : void
      {
         var _loc1_:int = 0;
         if(this.numChildren == 1)
         {
            this.ani = Utils.getMaterial("FreeGiftAni") as MovieClip;
            this.parent.parent.addChild(this.ani);
            this.ani.y = this.y + this.parent.y;
            this.ani.x = 45;
            _loc1_ = int(setTimeout(this.clear,3000,_loc1_));
         }
      }
      
      private function clear(param1:int) : void
      {
         clearTimeout(param1);
         this.parent.parent.removeChild(this.ani);
         this.ani = null;
      }
   }
}


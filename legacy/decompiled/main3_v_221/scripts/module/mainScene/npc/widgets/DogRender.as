package module.mainScene.npc.widgets
{
   import com.qzone.corelib.net.RSLManager;
   import common.CommonData;
   import common.Consts;
   import common.GetCropID;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class DogRender extends Sprite
   {
      
      private var dogLoading:MovieClip;
      
      private var dogLoadingTimer:int;
      
      private var vectorCartoon:MovieClip;
      
      private const distance:Number = 50;
      
      private const startX:int = 200;
      
      private var _id:String;
      
      public function DogRender(param1:int = 1)
      {
         super();
         if(param1 > Consts.DECOR_DOG_BASE_ID)
         {
            param1 -= Consts.DECOR_DOG_BASE_ID;
         }
         this._id = param1.toString();
         var _loc2_:String = "FDog" + this._id;
         var _loc3_:String = GetCropID.idToDogUrl(_loc2_,false);
         this.dogLoadingTimer = setTimeout(this.showLoading,300);
         CommonData.rslManager.requestClass(_loc2_,this.init,_loc3_);
      }
      
      public function stop() : void
      {
         if(this.vectorCartoon)
         {
            this.vectorCartoon.stop();
         }
      }
      
      private function init() : void
      {
         clearTimeout(this.dogLoadingTimer);
         if(this.dogLoading)
         {
            this.dogLoading.stop();
            this.removeChild(this.dogLoading);
            this.dogLoading = null;
         }
         if(this.vectorCartoon)
         {
            removeChild(this.vectorCartoon);
         }
         this.vectorCartoon = RSLManager.getMaterial("FDog" + this._id) as MovieClip;
         if(this.vectorCartoon != null)
         {
            this.vectorCartoon.x = this.startX + this.distance + 1;
            this.vectorCartoon.y = 200;
            addChild(this.vectorCartoon);
         }
         this.mouseEnabled = false;
         this.mouseChildren = false;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      private function showLoading() : void
      {
         if(this.dogLoading == null)
         {
            this.dogLoading = new FarmLoading();
            this.dogLoading.y = 240;
            this.dogLoading.x = 210 + this.distance;
            this.addChild(this.dogLoading);
         }
      }
   }
}


package module.mainScene.farmLand.widgets
{
   import common.GetCropID;
   import flash.display.Sprite;
   import flash.events.Event;
   import module.mainScene.farmLand.FarmLandsView;
   
   public class LandItemRender extends Sprite
   {
      
      private var _wasteland:Wasteland;
      
      private var _land:LandTile;
      
      private var _cropID:int;
      
      private var _index:int;
      
      private var _waste:Boolean;
      
      private var _step:int;
      
      private var _crop:Crop;
      
      private var _byproduct:Byproduct;
      
      public function LandItemRender()
      {
         super();
         scaleX = scaleY = FarmLandsView.SCALE;
         this._index = -1;
         this._cropID = 0;
         this._waste = false;
         this._step = 0;
         this._land = new LandTile(this);
         this._byproduct = new Byproduct(this);
         this._wasteland = new Wasteland(this);
      }
      
      public function setGrowStep(param1:int, param2:int) : void
      {
         this._step = param1;
         if(this._cropID != param2)
         {
            if(this._crop != null)
            {
               removeChild(this._crop);
               this._crop = null;
            }
            this._cropID = param2;
         }
         else if(this._crop != null)
         {
            this._crop.step = param1;
         }
      }
      
      public function set reclaim(param1:Boolean) : void
      {
         this._wasteland.showExpandBoard(param1);
      }
      
      public function clearAll() : void
      {
         if(this._crop != null)
         {
            removeChild(this._crop);
            this._crop = null;
         }
         if(this._byproduct != null)
         {
            this._byproduct.clear();
         }
         if(this._land != null)
         {
            this._land.reset();
         }
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get waste() : Boolean
      {
         return this._waste;
      }
      
      public function createByproduct(param1:int, param2:int) : void
      {
         this._byproduct.insect = param1;
         this._byproduct.weed = param2;
         var _loc3_:int = 0;
         if(this._step == 3)
         {
            _loc3_ = 1;
         }
         else if(this._step == 4)
         {
            _loc3_ = 2;
         }
         if(_loc3_ != 0)
         {
            this._byproduct.insectPosition = GetCropID.getInsectPosition(this._cropID.toString(),_loc3_);
         }
         this._byproduct.updateInsect();
         this._byproduct.updateWeed();
         this._byproduct.updateInsectPosition();
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
      
      public function createCrop(param1:int, param2:String, param3:String) : void
      {
         if(this._cropID == 0)
         {
            throw new Error("Invalid crop id.");
         }
         if(param2 == "" || param3 == "")
         {
            return;
         }
         if(this._crop == null)
         {
            this._crop = new Crop(param1,param2,param3);
            this._crop.step = this._step;
            this._crop.addEventListener(Event.COMPLETE,this.onCropLoaded,false,0,true);
            addChildAt(this._crop,1);
         }
      }
      
      public function updateLandStatus(param1:uint, param2:Boolean, param3:Boolean, param4:int) : void
      {
         if(this._land == null)
         {
            return;
         }
         var _loc5_:String = "";
         if(param2 && !param3)
         {
            _loc5_ = LandTile.SUITABLE;
         }
         else if(param2 && param3)
         {
            _loc5_ = LandTile.FERTILE;
         }
         else if(!param2 && param3)
         {
            _loc5_ = LandTile.DRY_FERTILE;
         }
         else
         {
            _loc5_ = LandTile.DRY;
         }
         this._land.updateLandStatus(param1,_loc5_,param4);
      }
      
      private function onCropLoaded(param1:Event) : void
      {
         this._byproduct.updateInsect();
         this._byproduct.updateWeed();
         this._byproduct.updateInsectPosition();
      }
      
      public function get cropLoaded() : Boolean
      {
         if(this._crop != null)
         {
            return this._crop.loaded;
         }
         return true;
      }
      
      public function get cropID() : int
      {
         return this._cropID;
      }
      
      public function set waste(param1:Boolean) : void
      {
         this._waste = param1;
         if(param1 == true)
         {
            this._land.clear();
            this._byproduct.clear();
            this._wasteland.showWaste();
            if(this._crop != null)
            {
               removeChild(this._crop);
               this._crop = null;
            }
         }
         else
         {
            this._wasteland.clear();
         }
      }
   }
}


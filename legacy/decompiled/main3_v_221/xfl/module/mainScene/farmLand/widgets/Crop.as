package module.mainScene.farmLand.widgets
{
   import com.qzone.corelib.net.RSLManager;
   import common.CommonData;
   import common.GetCropID;
   import common.Settings;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import report.EventRecorder;
   
   public class Crop extends Sprite
   {
      
      public var _cropUrl:String;
      
      private var _cropLoading:MovieClip;
      
      private var _cropLayers:Array;
      
      private var _loaded:Boolean;
      
      private var _classStep:int;
      
      private var _cropId:int;
      
      private var _step:int;
      
      private var _specialGrow:int;
      
      private var _currentCrop:*;
      
      private var _cropName:String;
      
      private var _cropLoadingTimer:int;
      
      public function Crop(param1:int, param2:String, param3:String, param4:int = -1)
      {
         super();
         this._cropId = param1;
         this._cropUrl = param3;
         this._cropName = param2;
         this._currentCrop = null;
         this._step = param4;
         this._cropLayers = null;
         this._loaded = false;
         this._cropLoading = null;
         this._cropLoadingTimer = 0;
         this._specialGrow = GetCropID.specialGrow(this._cropId.toString());
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      private function showLoadingAnimation() : void
      {
         if(this._cropLoading == null)
         {
            this._cropLoading = new FarmLoading();
            this._cropLoading.y = 30;
            this._cropLoading.x = 100;
            this._cropLoading.mouseEnabled = false;
            this._cropLoading.mouseChildren = false;
            addChild(this._cropLoading);
         }
      }
      
      private function removeCurrentCrop() : void
      {
         if(this._currentCrop != null && contains(this._currentCrop))
         {
            removeChild(this._currentCrop);
            this._currentCrop = null;
         }
         if(this._cropLayers != null)
         {
            this._cropLayers.splice(0);
            this._cropLayers = null;
         }
      }
      
      private function setState() : void
      {
         this._cropUrl = GetCropID.getCropUrl(this._cropId,this._step);
         if(this._cropName != "" && this._cropUrl != "")
         {
            if(this._cropLoadingTimer != 0)
            {
               clearTimeout(this._cropLoadingTimer);
            }
            this._cropLoadingTimer = setTimeout(this.showLoadingAnimation,300);
         }
         if(this._step > 2 && this._step < 6)
         {
            this._classStep = 3;
         }
         else
         {
            this._classStep = this._step;
         }
         var _loc1_:String = Settings.getInstance().getStringAttribute("publicCropPrefix");
         if(this._classStep == 0 && (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_DEAD) || this._classStep == 6 && (this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_SEED))
         {
            CommonData.rslManager.requestClass(_loc1_ + this._classStep,this.onCropLoaded,this._cropUrl,{"404":false});
         }
         else if(Boolean(this._currentCrop) && Boolean(this._classStep == 3) && MovieClip(this._currentCrop).hasOwnProperty("step1"))
         {
            MovieClip(this._currentCrop).step1.visible = false;
            MovieClip(this._currentCrop).step2.visible = false;
            MovieClip(this._currentCrop).step3.visible = false;
            if(this._step == 3)
            {
               MovieClip(this._currentCrop).step1.visible = true;
            }
            else if(this._step == 4)
            {
               MovieClip(this._currentCrop).step2.visible = true;
            }
            else
            {
               MovieClip(this._currentCrop).step3.visible = true;
            }
            this.stopLoadingAnimation();
         }
         else
         {
            CommonData.rslManager.requestClass(this._cropName + "_" + this._classStep,this.onCropLoaded,this._cropUrl,{"404":false});
         }
      }
      
      public function set step(param1:int) : void
      {
         if(param1 == this._step)
         {
            return;
         }
         this._step = param1;
         this.setState();
      }
      
      private function stopLoadingAnimation() : void
      {
         if(this._cropLoadingTimer != 0)
         {
            clearTimeout(this._cropLoadingTimer);
            this._cropLoadingTimer = 0;
         }
         if(this._cropLoading != null && this.contains(this._cropLoading) == true)
         {
            this._cropLoading.stop();
            removeChild(this._cropLoading);
            this._cropLoading = null;
         }
      }
      
      public function get loaded() : Boolean
      {
         return this._loaded;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.stopLoadingAnimation();
         this.removeCurrentCrop();
      }
      
      private function onCropLoaded(param1:Object) : void
      {
         var _loc2_:Class = null;
         if(param1 != null && param1["404"] == true)
         {
            EventRecorder.recordErrorEvent("160453",0,EventRecorder.FAULT_ERROR);
            return;
         }
         EventRecorder.recordSueecssEvent("160453",0);
         var _loc3_:String = Settings.getInstance().getStringAttribute("publicCropPrefix");
         if(this._classStep == 0)
         {
            if(this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_DEAD)
            {
               _loc2_ = RSLManager.getClass(_loc3_ + this._classStep) as Class;
            }
            else
            {
               _loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep) as Class;
            }
         }
         else if(this._classStep == 6)
         {
            if(this._specialGrow == GetCropID.SG_PUBLIC_SEED_PUBLIC_DEAD || this._specialGrow == GetCropID.SG_SPECIAL_SEED)
            {
               _loc2_ = RSLManager.getClass(_loc3_ + this._classStep) as Class;
            }
            else
            {
               _loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep) as Class;
            }
         }
         else
         {
            _loc2_ = RSLManager.getClass(this._cropName + "_" + this._classStep) as Class;
         }
         if(_loc2_ != null)
         {
            this.stopLoadingAnimation();
            this.removeCurrentCrop();
            this._loaded = true;
            this._currentCrop = new _loc2_();
            this._currentCrop.name = "__crop__";
            if(this._classStep == 3)
            {
               MovieClip(this._currentCrop).step1.visible = false;
               MovieClip(this._currentCrop).step2.visible = false;
               MovieClip(this._currentCrop).step3.visible = false;
               if(this._step == 3)
               {
                  MovieClip(this._currentCrop).step1.visible = true;
               }
               else if(this._step == 4)
               {
                  MovieClip(this._currentCrop).step2.visible = true;
               }
               else
               {
                  MovieClip(this._currentCrop).step3.visible = true;
               }
            }
            MovieClip(this._currentCrop).cacheAsBitmap = true;
            this._cropLayers = [];
            this._cropLayers.push(this._currentCrop);
            this._cropLayers.reverse();
            addChild(this._currentCrop);
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}


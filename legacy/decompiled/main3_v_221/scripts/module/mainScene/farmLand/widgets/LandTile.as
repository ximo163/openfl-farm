package module.mainScene.farmLand.widgets
{
   import common.misc.Utils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class LandTile
   {
      
      public static const DRY:String = "arid";
      
      public static const DRY_FERTILE:String = "aridFertile";
      
      public static const FERTILE:String = "fertile";
      
      public static const SUITABLE:String = "suitable";
      
      private var _parent:DisplayObjectContainer;
      
      private var _aFarmlandC:Sprite;
      
      private var _aFarmlandS:DisplayObject;
      
      private var _status:String;
      
      private var _jinPaiBitMap:DisplayObject;
      
      private var _bitsFlag:uint;
      
      public function LandTile(param1:DisplayObjectContainer)
      {
         super();
         this._bitsFlag = 0;
         this._status = "";
         this._aFarmlandS = null;
         this._parent = param1;
      }
      
      private function clearOldLand() : void
      {
         if(this._parent != null)
         {
            if(Boolean(this._aFarmlandC) && this._aFarmlandC.parent == this._parent)
            {
               this._parent.removeChild(this._aFarmlandC);
               this._aFarmlandC.removeChild(this._jinPaiBitMap);
               this._aFarmlandC.removeChild(this._aFarmlandS);
               this._aFarmlandS = null;
               this._aFarmlandC = null;
            }
            else if(Boolean(this._aFarmlandS) && this._aFarmlandS.parent == this._parent)
            {
               this._parent.removeChild(this._aFarmlandS);
               this._aFarmlandS = null;
            }
         }
      }
      
      public function updateLandStatus(param1:uint, param2:String, param3:int) : void
      {
         var _loc4_:Boolean = this._aFarmlandC != null ? true : false;
         if(this._bitsFlag == param1 && this._status == param2 && param3 == _loc4_)
         {
            return;
         }
         this._bitsFlag = param1;
         this._status = param2;
         if(this._status == "" || this._status == null)
         {
            this._status = SUITABLE;
         }
         var _loc5_:int = 0;
         if(this._aFarmlandS != null && this._aFarmlandS.parent == this._parent)
         {
            _loc5_ = this._parent.getChildIndex(this._aFarmlandS);
         }
         else if(Boolean(this._aFarmlandC) && this._aFarmlandC.parent == this._parent)
         {
            _loc5_ = this._parent.getChildIndex(this._aFarmlandC);
         }
         this.clearOldLand();
         var _loc6_:String = "";
         if(this._bitsFlag == 1)
         {
            _loc6_ = ".red";
         }
         else if(this._bitsFlag == 2)
         {
            _loc6_ = ".black";
         }
         if(this._status == SUITABLE)
         {
            this._aFarmlandS = Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandS") as DisplayObject;
         }
         else if(this._status == DRY)
         {
            this._aFarmlandS = Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandG") as DisplayObject;
         }
         else if(this._status == FERTILE)
         {
            this._aFarmlandS = Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandS2") as DisplayObject;
         }
         else if(this._status == DRY_FERTILE)
         {
            this._aFarmlandS = Utils.getMaterial("com.qzone.ui" + _loc6_ + ".FarmlandG2") as DisplayObject;
         }
         if(this._aFarmlandS == null)
         {
            throw new Error("Can not get land res!");
         }
         this._aFarmlandS.cacheAsBitmap = true;
         this._aFarmlandS.name = "__land__";
         this.showGoldLand(param3,_loc5_);
      }
      
      private function showGoldLand(param1:int, param2:int) : void
      {
         if(param1 == 1)
         {
            if(!this._aFarmlandC)
            {
               this._aFarmlandC = new Sprite();
            }
            if(this._status == SUITABLE)
            {
               this._jinPaiBitMap = Utils.getMaterial("com.qzone.ui.JPLandS") as DisplayObject;
            }
            else if(this._status == DRY)
            {
               this._jinPaiBitMap = Utils.getMaterial("com.qzone.ui.JPLandG") as DisplayObject;
            }
            else if(this._status == FERTILE)
            {
               this._jinPaiBitMap = Utils.getMaterial("com.qzone.ui.JPLandS2") as DisplayObject;
            }
            else if(this._status == DRY_FERTILE)
            {
               this._jinPaiBitMap = Utils.getMaterial("com.qzone.ui.JPLandG2") as DisplayObject;
            }
            this._jinPaiBitMap.cacheAsBitmap = true;
            this._aFarmlandC.addChild(this._aFarmlandS);
            this._aFarmlandC.addChild(this._jinPaiBitMap);
            this._parent.addChildAt(this._aFarmlandC,param2);
         }
         else
         {
            this._parent.addChildAt(this._aFarmlandS,param2);
         }
      }
      
      public function clear() : void
      {
         this.clearOldLand();
         this._bitsFlag = 0;
         this._status = "";
      }
      
      public function reset() : void
      {
         this.updateLandStatus(0,SUITABLE,0);
      }
      
      public function get status() : String
      {
         return this._status;
      }
   }
}


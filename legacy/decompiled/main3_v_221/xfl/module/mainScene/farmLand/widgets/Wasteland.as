package module.mainScene.farmLand.widgets
{
   import com.qzone.utils.DisplayUtil;
   import common.misc.Utils;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class Wasteland
   {
      
      private var _reclaimButton:Sprite;
      
      private var _wasteland:DisplayObject;
      
      private var _parent:DisplayObjectContainer;
      
      public function Wasteland(param1:DisplayObjectContainer)
      {
         super();
         this._reclaimButton = null;
         this._parent = param1;
      }
      
      public function clear() : void
      {
         DisplayUtil.removeChild(this._parent,this._wasteland);
         DisplayUtil.removeChild(this._parent,this._reclaimButton);
      }
      
      public function showWaste() : void
      {
         if(this._parent != null)
         {
            if(this._wasteland == null)
            {
               this._wasteland = Utils.getMaterial("com.qzone.ui.Wasteland") as DisplayObject;
               this._wasteland.cacheAsBitmap = true;
            }
            this._parent.addChild(this._wasteland);
         }
      }
      
      public function showExpandBoard(param1:Boolean) : void
      {
         if(param1 == true)
         {
            if(this._reclaimButton == null)
            {
               this._reclaimButton = Utils.getMaterial("Reclaim") as Sprite;
               this._reclaimButton.name = "__reclaim__";
               this._reclaimButton.x = 66;
               this._reclaimButton.y = -28;
               this._reclaimButton.buttonMode = true;
               this._reclaimButton.useHandCursor = true;
            }
            this._parent.addChild(this._reclaimButton);
         }
         if(param1 == false)
         {
            if(this._reclaimButton != null)
            {
               DisplayUtil.removeChild(this._parent,this._reclaimButton);
            }
         }
      }
   }
}


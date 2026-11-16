package module.mainScene.farmLand.widgets
{
   import com.greensock.TweenLite;
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import module.mainScene.farmLand.FarmLandsView;
   
   public class LandPickIcon
   {
      
      private var _startPos:Point;
      
      private var _parent:DisplayObjectContainer;
      
      private var _canPickIcon:MovieClip;
      
      public function LandPickIcon(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError("Invalid parameter");
         }
         this._canPickIcon = null;
         this._parent = param1;
         this._startPos = new Point(param2,param3);
      }
      
      public function play() : void
      {
         if(this._canPickIcon != null)
         {
            if(this._parent != null && this._parent.contains(this._canPickIcon) == false)
            {
               this._parent.addChild(this._canPickIcon);
            }
         }
         this._canPickIcon.play();
         this._canPickIcon.visible = true;
      }
      
      public function creatCanPickIcon(param1:Point = null) : void
      {
         if(this._parent == null)
         {
            return;
         }
         this._canPickIcon = Utils.getMaterial("canPickIcon") as MovieClip;
         this._canPickIcon.mouseChildren = false;
         this._canPickIcon.mouseEnabled = false;
         this._canPickIcon.stop();
         this._canPickIcon.x = this._startPos.x;
         this._canPickIcon.y = this._startPos.y;
         this._parent.addChild(this._canPickIcon);
      }
      
      public function moveTo(param1:LandItemRender) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Point = new Point(param1.x + 100 * FarmLandsView.SCALE,param1.y - 70 * FarmLandsView.SCALE);
         if(this._canPickIcon == null)
         {
            this.creatCanPickIcon();
         }
         this._canPickIcon.alpha = 1;
         TweenLite.to(this._canPickIcon,0.25,{
            "x":_loc2_.x,
            "y":_loc2_.y
         });
      }
      
      public function remove() : void
      {
         if(this._canPickIcon != null)
         {
            if(this._parent != null && this._parent.contains(this._canPickIcon) == true)
            {
               this._parent.removeChild(this._canPickIcon);
            }
            this._canPickIcon.visible = false;
         }
      }
      
      public function stop() : void
      {
         if(this._canPickIcon != null)
         {
            TweenLite.to(this._canPickIcon,0.3,{"alpha":0});
            this._canPickIcon.stop();
         }
      }
   }
}


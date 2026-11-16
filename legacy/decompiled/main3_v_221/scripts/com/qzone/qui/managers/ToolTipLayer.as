package com.qzone.qui.managers
{
   import com.qzone.qui.controls.ToolTip;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   internal class ToolTipLayer extends Sprite
   {
      
      private var _currentComponent:DisplayObject;
      
      private var _toolTip:ToolTip;
      
      private var _rect:Rectangle;
      
      private var _tipStr:String;
      
      public function ToolTipLayer()
      {
         super();
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.addEventListener(Event.ADDED_TO_STAGE,this._added_TO_STAGE);
      }
      
      private function setToolTip(param1:MouseEvent) : void
      {
         var _loc3_:Point = null;
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(Boolean(_loc2_) && _loc2_.hasOwnProperty("toolTip"))
         {
            this._tipStr = _loc2_["toolTip"];
            if(this._tipStr)
            {
               _loc3_ = _loc2_.parent.localToGlobal(new Point(_loc2_.x,_loc2_.y));
               this._rect.x = _loc3_.x;
               this._rect.y = _loc3_.y;
               this._rect.width = _loc2_.width;
               this._rect.height = _loc2_.height;
               this._currentComponent = _loc2_;
               this._currentComponent.addEventListener(MouseEvent.ROLL_OUT,this._MOUSE_OUT);
               this.showToolTip(param1);
            }
         }
      }
      
      protected function moveTip() : void
      {
      }
      
      protected function setPosition(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(ToolTipManager.flowMouse)
         {
            _loc3_ = param1.stageY + 30;
            _loc2_ = param1.stageX;
         }
         else
         {
            _loc3_ = this._rect.y - this._toolTip.height + this._toolTip.offset.y - Style.toolTipPaddingV;
            _loc2_ = param1.stageX - this._toolTip.width / 2 + this._toolTip.offset.x;
         }
         if(_loc3_ < 0)
         {
            _loc3_ = this._rect.y + this._rect.height + Style.toolTipPaddingV;
         }
         else if(_loc3_ > stage.stageHeight - this._toolTip.height - 30)
         {
            _loc3_ = param1.stageY - this._toolTip.height - 10;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = Style.toolTipPaddingH;
         }
         else if(_loc2_ + this._toolTip.width + Style.toolTipPaddingH > this.stage.stageWidth)
         {
            _loc2_ = this.stage.stageWidth - this._toolTip.width - Style.toolTipPaddingH;
         }
         this._toolTip.x = _loc2_;
         this._toolTip.y = _loc3_;
      }
      
      private function _MOUSE_MOVE(param1:MouseEvent) : void
      {
         if(param1.target != this._currentComponent)
         {
            this.hideToolTip();
            return;
         }
         this.setPosition(param1);
      }
      
      public function hideToolTip() : void
      {
         if(Boolean(this._toolTip) && Boolean(this._toolTip.parent))
         {
            EffectManager.Out(this,this._toolTip,this.removeEffectEnd);
         }
      }
      
      private function _MOUSE_OVER(param1:MouseEvent) : void
      {
         this.setToolTip(param1);
      }
      
      private function _added_TO_STAGE(param1:Event) : void
      {
         this._rect = new Rectangle();
         this.removeEventListener(Event.ADDED_TO_STAGE,this._added_TO_STAGE);
         this.stage.addEventListener(MouseEvent.MOUSE_OVER,this._MOUSE_OVER);
      }
      
      private function addedEffectEnd(param1:DisplayObject) : void
      {
         this.addChild(this._toolTip);
      }
      
      private function _MOUSE_OUT(param1:MouseEvent) : void
      {
         param1.currentTarget.removeEventListener(MouseEvent.ROLL_OUT,this._MOUSE_OUT);
         this.hideToolTip();
      }
      
      private function showToolTip(param1:MouseEvent) : void
      {
         if(this._toolTip == null)
         {
            this._toolTip = new ToolTipManager.toolTipClass();
            this.addChild(this._toolTip);
         }
         this._toolTip.text = this._tipStr;
         if(ToolTipManager.flowMouse)
         {
            this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this._MOUSE_MOVE);
         }
         this.setPosition(param1);
         EffectManager.In(this,this._toolTip,this.addedEffectEnd,this._toolTip);
      }
      
      private function removeEffectEnd() : void
      {
         DisplayUtil.removeChild(this,this._toolTip);
         if(ToolTipManager.flowMouse)
         {
            this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this._MOUSE_MOVE);
         }
      }
   }
}


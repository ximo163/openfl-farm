package com.qzone.qui.managers
{
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.GraphicsUtil;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   
   internal class PopUpLayer extends Sprite
   {
      
      private var _items:Array = [];
      
      private var _targets:Object = {};
      
      public function PopUpLayer()
      {
         super();
         this.mouseEnabled = false;
      }
      
      public function get items() : Array
      {
         return this._items;
      }
      
      private function stageKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:DisplayObject = null;
         if(Boolean(numChildren) && param1.keyCode == 13)
         {
            _loc2_ = getChildAt(numChildren - 1) as DisplayObject;
            if(Boolean(_loc2_) && _loc2_.hasOwnProperty("keyEnter"))
            {
               _loc2_["keyEnter"](param1);
            }
         }
      }
      
      private function _CLOSE(param1:Event) : void
      {
         var _loc2_:DisplayObjectContainer = param1.currentTarget as DisplayObjectContainer;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.CLOSE,this._CLOSE);
            this.removePopUp(_loc2_);
            ToolTipManager.hide();
         }
      }
      
      private function addedEffectEnd(param1:DisplayObject) : void
      {
      }
      
      public function addPopUp(param1:DisplayObject, param2:DisplayObjectContainer, param3:Boolean = false) : void
      {
         var _loc4_:Sprite = null;
         if(param3)
         {
            _loc4_ = new Sprite();
            GraphicsUtil.draw(_loc4_,Style.popUpModalColor,Style.popUpModalAlpha,new Rectangle(0,0,this.stage.stageWidth,this.stage.stageHeight),true);
            this.addChild(_loc4_);
         }
         stage.addEventListener(KeyboardEvent.KEY_UP,this.stageKeyUp);
         param1.addEventListener(Event.CLOSE,this._CLOSE);
         param1.filters = Style.getShadowFilter();
         this._targets[param1.name] = {
            "popUp":param1,
            "modal":_loc4_
         };
         this._items.push(this._targets[param1.name]);
         this.addChild(param1);
         EffectManager.In(this,param1,this.addedEffectEnd,param1);
      }
      
      private function removePopUpFromStage(param1:DisplayObjectContainer) : void
      {
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
      }
      
      public function removePopUp(param1:DisplayObjectContainer) : void
      {
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         if(this.contains(param1))
         {
            _loc2_ = param1.name;
            if(this._targets.hasOwnProperty(_loc2_))
            {
               if(this._targets[_loc2_].modal)
               {
                  this.removeChild(this._targets[_loc2_].modal);
               }
               _loc5_ = this._items.indexOf(this._targets[_loc2_]);
               this._items.splice(_loc5_,1);
               delete this._targets[_loc2_];
            }
            _loc3_ = false;
            for each(_loc4_ in this.items)
            {
               if(_loc4_.modal)
               {
                  _loc3_ = true;
                  break;
               }
            }
            if(_loc3_ == false)
            {
               this["root"].tabChildren = true;
            }
            EffectManager.Out(this,param1,this.removePopUpFromStage,param1);
         }
      }
   }
}


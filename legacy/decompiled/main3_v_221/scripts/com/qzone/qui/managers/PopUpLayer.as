package com.qzone.qui.managers
{
   import com.qzone.qui.containers.TitleWindow;
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
            if(param1.hasOwnProperty("disableAnimation") == true && param1["disableAnimation"] == true)
            {
               this.removedEffectEnd(param1);
            }
            else
            {
               EffectManager.Out(this,param1,this.removedEffectEnd,param1);
            }
            param1.removeEventListener(Event.CLOSE,this._CLOSE);
         }
      }
      
      private function removedEffectEnd(param1:DisplayObjectContainer) : void
      {
         var _loc2_:TitleWindow = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
         if(param1 is TitleWindow)
         {
            _loc2_ = param1 as TitleWindow;
            DragManager.removeTarget(_loc2_,_loc2_.headArea);
         }
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
         if(param1.hasOwnProperty("disableAnimation") == true && param1["disableAnimation"] == true)
         {
            this.addedEffectEnd(param1);
         }
         else
         {
            EffectManager.In(this,param1,this.addedEffectEnd,param1);
         }
      }
      
      private function addedEffectEnd(param1:DisplayObject) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.hasOwnProperty("onEffectEnd") == true && param1["onEffectEnd"] is Function)
         {
            param1["onEffectEnd"]();
         }
      }
      
      private function _CLOSE(param1:Event) : void
      {
         var _loc2_:DisplayObjectContainer = param1.currentTarget as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc2_.removeEventListener(Event.CLOSE,this._CLOSE);
            ToolTipManager.hide();
            this.removePopUp(_loc2_);
         }
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
   }
}


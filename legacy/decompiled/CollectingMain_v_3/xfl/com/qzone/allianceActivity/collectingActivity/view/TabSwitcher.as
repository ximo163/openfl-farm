package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.framewrok.events.MVCEvent;
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   public class TabSwitcher extends EventDispatcher
   {
      
      internal static const EVENT_TAB_CHANGED:String = "TAB_CHANGED";
      
      private var _selected:int;
      
      private var _numbers:Array;
      
      private var _class:Class = TabSwitcher__class;
      
      private var _api:IAllianceAppHelper;
      
      private var _tip:Sprite;
      
      private var _tabs:Array;
      
      private var _animating:int;
      
      public function TabSwitcher(param1:Array, param2:int, param3:IAllianceAppHelper)
      {
         var _loc5_:MovieClip = null;
         super();
         this._tabs = param1;
         this._selected = param2;
         this._animating = 0;
         this._api = param3;
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            if(_loc4_ == param2)
            {
               _loc5_.gotoAndStop(_loc5_.totalFrames);
            }
            else
            {
               _loc5_.gotoAndStop(1);
            }
            _loc5_.mouseChildren = false;
            _loc5_.buttonMode = true;
            _loc5_.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
            _loc5_.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
            _loc5_.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
            _loc4_++;
         }
      }
      
      private function bringBack(param1:MovieClip) : void
      {
         if(param1 == null || param1.currentFrame == 1)
         {
            return;
         }
         param1.prevFrame();
         param1.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         ++this._animating;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         if(this._tip == null)
         {
            this._tip = new this._class() as Sprite;
         }
         if(param1.target == this._tabs[0] && this._numbers != null)
         {
            this._tip.y = 164;
            this._tip["tfTip"].text = "普通作物共" + this._numbers[1] + "种\n您已点亮" + this._numbers[0] + "种";
            this._tabs[2].parent.addChild(this._tip);
         }
         if(param1.target == this._tabs[1] && this._numbers != null)
         {
            this._tip.y = 100;
            this._tip["tfTip"].text = "神秘作物共" + this._numbers[3] + "种\n您已点亮" + this._numbers[2] + "种";
            this._tabs[1].parent.addChild(this._tip);
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:MVCEvent = null;
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Boolean = false;
         if(this._tabs[this._selected] == _loc2_)
         {
            if(_loc2_.currentFrame == _loc2_.totalFrames)
            {
               _loc2_.stop();
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
               _loc3_ = true;
               --this._animating;
            }
         }
         else if(_loc2_.currentFrame == 1)
         {
            _loc2_.stop();
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            _loc3_ = true;
            --this._animating;
         }
         else
         {
            _loc2_.prevFrame();
         }
         if(_loc3_ == true)
         {
            if(this._numbers != null)
            {
               _loc4_ = this._tabs.indexOf(_loc2_);
               if(_loc4_ == 0)
               {
                  this._tabs[0]["btnTab"]["tfNum"].text = this._numbers[0] + "/" + this._numbers[1];
               }
               else if(_loc4_ == 1)
               {
                  this._tabs[1]["btnTab"]["tfNum"].text = this._numbers[2] + "/" + this._numbers[3];
               }
            }
         }
         if(this._animating == 0)
         {
            _loc5_ = new MVCEvent(EVENT_TAB_CHANGED);
            _loc5_.put("index",this._selected);
            dispatchEvent(_loc5_);
         }
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         if(this._tip != null && this._tip.parent != null)
         {
            this._tip.parent.removeChild(this._tip);
         }
      }
      
      public function switchTab(param1:int) : void
      {
         if(this._selected == param1)
         {
            return;
         }
         this._selected = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this._tabs.length)
         {
            if(_loc2_ == param1)
            {
               this.bringFront(this._tabs[_loc2_]);
            }
            else
            {
               this.bringBack(this._tabs[_loc2_]);
            }
            _loc2_++;
         }
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         if(this._animating > 0)
         {
            return;
         }
         var _loc3_:int = this._tabs.indexOf(_loc2_);
         if(_loc3_ == this._selected)
         {
            return;
         }
         this.switchTab(_loc3_);
      }
      
      public function get selected() : int
      {
         return this._selected;
      }
      
      public function refreshNumbers(param1:int, param2:int, param3:int, param4:int) : void
      {
         if(this._tabs == null || this._tabs.length < 2)
         {
            return;
         }
         this._tabs[0]["btnTab"]["tfNum"].text = param1 + "/" + param2;
         this._tabs[1]["btnTab"]["tfNum"].text = param3 + "/" + param4;
         this._numbers = [param1,param2,param3,param4];
      }
      
      private function bringFront(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.gotoAndPlay(1);
         param1.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         ++this._animating;
      }
   }
}


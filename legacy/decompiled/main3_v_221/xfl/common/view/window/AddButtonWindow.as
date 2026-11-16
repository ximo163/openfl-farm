package common.view.window
{
   import com.qzone.qui.controls.Button;
   import common.Consts;
   import flash.display.DisplayObject;
   import flash.events.*;
   import interfaces.IMsgCenter;
   
   public class AddButtonWindow extends BaseWindow
   {
      
      private var addChildCache:Array = [];
      
      private var buttonCache:Array = [];
      
      private var _buttonSpace:int = 10;
      
      private var _bottomSpace:int = 40;
      
      public function AddButtonWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 360;
         height = 240;
         mode = true;
         windowName = Consts.WINDOW_NAME_ABUTTON;
      }
      
      public function set betweenSpace(param1:int) : void
      {
         this._buttonSpace = param1;
      }
      
      public function set bottomSpace(param1:int) : void
      {
         this._bottomSpace = param1;
      }
      
      public function addSpecialButton(param1:DisplayObject) : DisplayObject
      {
         this.buttonCache.push(param1);
         return param1;
      }
      
      public function addWindowChild(param1:DisplayObject) : DisplayObject
      {
         this.addChildCache.push(param1);
         return param1;
      }
      
      public function removeAllButton() : void
      {
         this.buttonCache = [];
      }
      
      public function addButton(param1:String = "Button", param2:String = null, param3:int = 100, param4:int = 25, param5:Function = null, param6:Boolean = true, param7:int = 16777215, param8:int = 12, param9:Boolean = false, param10:String = null, param11:int = 0) : Button
      {
         var _loc12_:Button = new winButton(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
         this.buttonCache.push(_loc12_);
         return _loc12_;
      }
      
      public function removeAllWindowChild() : void
      {
         this.addChildCache = [];
      }
      
      override protected function init() : void
      {
         var _loc5_:int = 0;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < this.addChildCache.length)
         {
            this.addChild(this.addChildCache[_loc1_]);
            _loc1_++;
         }
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(this.buttonCache.length);
         if(_loc4_ > 0)
         {
            _loc5_ = _loc4_ - 1;
            _loc1_ = 0;
            while(_loc1_ < _loc5_)
            {
               _loc3_ += this.buttonCache[_loc1_].width + this._buttonSpace;
               _loc1_++;
            }
            _loc3_ += this.buttonCache[_loc5_].width;
            _loc2_ = this.width * 0.5 - _loc3_ * 0.5;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               this.buttonCache[_loc1_].x = _loc2_;
               _loc2_ += this.buttonCache[_loc1_].width + this._buttonSpace;
               this.buttonCache[_loc1_].y = this.height - this._bottomSpace;
               addChild(this.buttonCache[_loc1_]);
               _loc1_++;
            }
         }
         this.toCenterPositon();
      }
      
      private function toCenterPositon() : void
      {
         if(stage != null)
         {
            x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
            y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
         }
      }
   }
}

import com.qzone.qui.controls.Button;
import common.misc.Utils;
import flash.events.Event;
import flash.events.MouseEvent;

class winButton extends Button
{
   
   private var ac:Function = null;
   
   public function winButton(param1:String = "Button", param2:String = null, param3:int = 100, param4:int = 25, param5:Function = null, param6:Boolean = true, param7:int = 16777215, param8:int = 12, param9:Boolean = false, param10:String = null, param11:int = 0)
   {
      super();
      if(param2 != null)
      {
         defaultSkin = Utils.getClass(param2);
      }
      this.text = param1;
      this.textDefaultFormat.color = param7;
      this.textDefaultFormat.size = param8;
      this.textDefaultFormat.bold = param9;
      this.textDefaultFormat.font = param10;
      this.enabled = param6;
      this.width = param3;
      this.height = param4;
      if(param5 == null)
      {
         this.ac = this.empty;
      }
      else
      {
         this.ac = param5;
      }
      addEventListener(MouseEvent.CLICK,this.operation);
   }
   
   override protected function init() : void
   {
      var _loc1_:Function = this.ac;
      super.init();
      this.ac = _loc1_;
      _clickFn = null;
   }
   
   override public function set clickFn(param1:Function) : void
   {
      this.ac = param1;
   }
   
   private function empty() : void
   {
   }
   
   private function operation(param1:Event) : void
   {
      if(this.ac != null && this.ac is Function)
      {
         this.ac();
      }
   }
}

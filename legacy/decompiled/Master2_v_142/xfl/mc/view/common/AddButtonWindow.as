package mc.view.common
{
   import com.minutes.ui.control.LipiButton;
   import flash.display.DisplayObject;
   import flash.events.*;
   
   public class AddButtonWindow extends BaseWindow
   {
      
      private var addChildCache:Array = [];
      
      private var _buttonSpace:int = 10;
      
      private var buttonCache:Array = [];
      
      private var _bottomSpace:int = 45;
      
      public function AddButtonWindow()
      {
         super();
         width = 360;
         height = 240;
         mode = true;
      }
      
      public function set betweenSpace(param1:int) : void
      {
         this._buttonSpace = param1;
      }
      
      private function toCenterPositon() : void
      {
         x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
         y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
      }
      
      public function closeWindow(param1:Event = null) : void
      {
         this.closeHandler();
      }
      
      public function addWindowChild(param1:DisplayObject) : DisplayObject
      {
         this.addChildCache.push(param1);
         return param1;
      }
      
      public function removeAllWindowChild() : void
      {
         this.addChildCache = [];
      }
      
      override public function init() : void
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
      
      public function addSpecialButton(param1:DisplayObject) : DisplayObject
      {
         this.buttonCache.push(param1);
         return param1;
      }
      
      public function removeAllButton() : void
      {
         this.buttonCache = [];
      }
      
      public function addButton(param1:String = "Button", param2:String = null, param3:int = 100, param4:int = 25, param5:Function = null, param6:Boolean = true, param7:int = 16777215, param8:int = 12, param9:Boolean = false, param10:String = null, param11:int = 0) : LipiButton
      {
         var _loc12_:LipiButton = new winButton(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
         this.buttonCache.push(_loc12_);
         return _loc12_;
      }
      
      public function set bottomSpace(param1:int) : void
      {
         this._bottomSpace = param1;
      }
   }
}

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import common.MaterialLib;
import flash.events.Event;
import flash.events.MouseEvent;

class winButton extends LipiButton
{
   
   private var ac:Function = null;
   
   public function winButton(param1:String = "Button", param2:String = null, param3:int = 100, param4:int = 25, param5:Function = null, param6:Boolean = true, param7:int = 16777215, param8:int = 12, param9:Boolean = false, param10:String = null, param11:int = 0)
   {
      super();
      if(param2 != null)
      {
         bgSkin = new LipiSkin(MaterialLib.getInstance().getClass(param2));
      }
      this.label = param1;
      this.textColor = param7;
      this.textSize = param8;
      this.textBold = param9;
      this.textFont = param10;
      this.bgAlpha = param11;
      this.enable = param6;
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
   
   private function empty() : void
   {
   }
   
   private function operation(param1:Event) : void
   {
      this.ac();
   }
}

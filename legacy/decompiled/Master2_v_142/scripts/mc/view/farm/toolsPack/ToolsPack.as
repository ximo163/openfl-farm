package mc.view.farm.toolsPack
{
   import com.minutes.ui.collections.SimpleCollection;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.model.OpenControl;
   import mc.model.ToolData;
   import mc.view.farm.ToolBar;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.farm.toolBar.Tool_Camera;
   import mc.view.farm.toolBar.Tool_Donate;
   import mc.view.farm.toolBar.Tool_Whistle;
   import mc.view.farm.toolBar.Tool_Whistle2;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.tip.TipControl;
   
   public class ToolsPack extends SimpleCollection
   {
      
      private var rButton:SimpleButton;
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      private var aTool_Whistle:Tool_Whistle;
      
      private var childBar:Sprite;
      
      private var hideTimer:uint;
      
      private var aTool_Whistle2:Tool_Whistle2;
      
      private var aTool_Camera:Tool_Camera;
      
      private var aTool_Donate:Tool_Donate;
      
      private var lButton:SimpleButton;
      
      public function ToolsPack()
      {
         super();
         bg = this.lib.getMaterial("PackBarBg") as Sprite;
         width = 400;
         height = 50;
         this.aTool_Whistle = new Tool_Whistle();
         this.aTool_Whistle.tipText = "队形设置（须饲养5只及以上动物）";
         this.aTool_Whistle.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Whistle.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Whistle.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Whistle);
         this.aTool_Whistle2 = new Tool_Whistle2();
         this.aTool_Whistle2.tipText = "吹口哨，查看主人设置的欢迎队形";
         this.aTool_Whistle2.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Whistle2.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Whistle2.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Whistle2);
         this.aTool_Camera = new Tool_Camera();
         this.aTool_Camera.tipText = "牧场拍照留念";
         this.aTool_Camera.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Camera.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Camera.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Camera);
         this.aTool_Donate = new Tool_Donate();
         this.aTool_Donate.tipText = "捐赠未成熟动物";
         this.aTool_Donate.addEventListener(MouseEvent.CLICK,this.toolClick);
         this.aTool_Donate.addEventListener(MouseEvent.ROLL_OVER,this.toolRollOver);
         this.aTool_Donate.addEventListener(MouseEvent.ROLL_OUT,this.toolRollOut);
         addChild(this.aTool_Donate);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this.changeBarVisible();
      }
      
      private function hideThis() : void
      {
         this.visible = false;
      }
      
      private function lButtonClick(param1:MouseEvent) : void
      {
      }
      
      private function toolClick(param1:MouseEvent) : void
      {
         if(param1.currentTarget == this.aTool_Whistle)
         {
            dispatchEvent(new Event("whistleClick"));
         }
         else if(param1.currentTarget == this.aTool_Camera)
         {
            ViewControl.getInstance().dispatchEvent(new Event("onquickshoot"));
         }
         else if(param1.currentTarget == this.aTool_Whistle2)
         {
            Command.getInstance().mainCommand.setParade();
         }
         else if(param1.currentTarget == this.aTool_Donate)
         {
            Cursor.setCursor("Cursor_Donate");
            this.onOut(null);
         }
         param1.stopPropagation();
      }
      
      private function rButtonClick(param1:MouseEvent) : void
      {
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         Cursor.useSystem(true);
         clearTimeout(this.hideTimer);
      }
      
      private function toolRollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(stage != null)
         {
            stage.addEventListener(MouseEvent.CLICK,this.stageClick);
         }
         super.visible = param1;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.hideTimer = setTimeout(this.hideThis,100);
      }
      
      private function toolRollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
      
      private function stageClick(param1:MouseEvent) : void
      {
         this.visible = false;
         if(stage)
         {
            stage.removeEventListener(MouseEvent.CLICK,this.stageClick);
         }
      }
      
      private function setPosition() : void
      {
         var _loc6_:DisplayObject = null;
         var _loc1_:int = 15;
         var _loc2_:int = 55;
         var _loc3_:int = 5;
         var _loc4_:Array = [this.aTool_Camera,this.aTool_Whistle,this.aTool_Whistle2,this.aTool_Donate];
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_] as DisplayObject;
            if(_loc6_.visible)
            {
               _loc6_.x = Math.floor(_loc1_);
               _loc6_.y = Math.floor(_loc3_);
               _loc1_ += _loc2_;
            }
            _loc5_++;
         }
         width = _loc1_ + 12;
      }
      
      public function changeBarVisible(param1:ToolBar = null) : void
      {
         var _loc2_:ToolData = MData.getInstance().toolData;
         var _loc3_:MainData = MData.getInstance().mainData;
         if(_loc3_.me)
         {
            this.aTool_Whistle.visible = true;
            this.aTool_Whistle2.visible = false;
            this.aTool_Donate.visible = true;
         }
         else
         {
            this.aTool_Whistle.visible = false;
            this.aTool_Whistle2.visible = true;
            this.aTool_Donate.visible = false;
         }
         if(_loc3_.me)
         {
            this.aTool_Whistle2.visible = false;
            if(param1 != null)
            {
               this.x = param1.x + param1.width - this.width - 30;
               this.y = param1.y - this.height - 10;
            }
         }
         else
         {
            this.aTool_Whistle2.visible = true;
            if(_loc2_.paradeError)
            {
               this.aTool_Whistle2.alpha = 0.5;
               this.aTool_Whistle2.tipText = _loc2_.paradeError;
            }
            else
            {
               this.aTool_Whistle2.tipText = "吹口哨，查看主人设置的欢迎队形";
               this.aTool_Whistle2.alpha = 1;
            }
            if(param1 != null)
            {
               this.x = param1.x + param1.width - this.width - 100;
               this.y = param1.y - this.height - 10;
            }
         }
         if(OpenControl.open("quickshoot"))
         {
            this.aTool_Camera.visible = true;
         }
         else if(_loc3_.host["yellowstatus"] == 1 && _loc3_.host["yellowlevel"] >= OpenControl.getOpenYellowLv("quickshoot"))
         {
            this.aTool_Camera.visible = true;
         }
         else
         {
            this.aTool_Camera.visible = false;
         }
         this.setPosition();
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
   }
}


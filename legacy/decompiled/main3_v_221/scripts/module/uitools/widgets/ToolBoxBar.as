package module.uitools.widgets
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import common.Consts;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.cursor.CursorControl;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLVariables;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import framework.base.Module;
   import module.uitools.UIController;
   import report.EventRecorder;
   
   public class ToolBoxBar extends HBox
   {
      
      private var _toolZoomOut:DisplayObject;
      
      private var m_hideTimer:uint;
      
      private var m_controller:UIController;
      
      private var _toolZoomIn:DisplayObject;
      
      public function ToolBoxBar(param1:UIController)
      {
         var _loc2_:int = QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false ? 356 : 310;
         super(_loc2_,70);
         buttonMode = true;
         verticalScrollPolicy = ScrollPolicy.OFF;
         horizontalScrollPolicy = ScrollPolicy.OFF;
         alignH = Align.CENTER;
         alignV = Align.TOP;
         paddingH = 20;
         paddingV = 16;
         gapH = 12;
         defaultSkin = PackBarBg;
         this.m_hideTimer = 0;
         this.m_controller = param1;
         var _loc3_:DisplayObject = null;
         _loc3_ = this.addToolBtn("ToolHook","清除地里的杂草(W)");
         _loc3_ = this.addToolBtn("ToolPesticide","清除地里的害虫(E)");
         _loc3_ = this.addToolBtn("ToolWater","用来浇水(Q)");
         if(QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            _loc3_ = this.addToolBtn("CameraButton","农场拍照留念");
         }
         _loc3_ = this.addToolBtn("newHealthModeIcon","健康模式");
         MovieClip(_loc3_).stop();
         if(Cookies.Get("bigmode") == "1")
         {
            this._toolZoomOut = this.addToolBtn("ToolZoomOut","缩小");
         }
         else
         {
            this._toolZoomIn = this.addToolBtn("ToolZoomIn","放大");
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      private function hideThis() : void
      {
         this.visible = false;
      }
      
      private function addToolBtn(param1:String, param2:String) : *
      {
         var _loc3_:* = Utils.getMaterial(param1);
         if(_loc3_ == null)
         {
            return null;
         }
         _loc3_.name = param1;
         _loc3_.tipText = param2;
         _loc3_.addEventListener(MouseEvent.CLICK,this.onToolClick,false,0,true);
         _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.onToolRollOver,false,0,true);
         _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onToolRollOut,false,0,true);
         addElement(_loc3_);
         return _loc3_;
      }
      
      override protected function setSkin() : void
      {
         if(defaultSkin != null)
         {
            _skin = new defaultSkin();
            this.addChildAt(_skin,0);
         }
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this.m_controller.useSystemCursor(true);
         if(this.m_hideTimer != 0)
         {
            clearTimeout(this.m_hideTimer);
         }
         this.m_hideTimer = 0;
      }
      
      private function adjustPosition() : void
      {
         x = stage.mouseX - this.width * 0.5;
         y = stage.stageHeight - 66 - this.height;
      }
      
      public function toggleHealthMode(param1:Boolean) : void
      {
         var _loc2_:MovieClip = content.getChildByName("__health__") as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1 == true)
         {
            _loc2_.gotoAndStop(2);
         }
         else
         {
            _loc2_.gotoAndStop(1);
         }
      }
      
      private function setCursor(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc4_:Module = null;
         var _loc5_:CursorControl = null;
         var _loc3_:Boolean = false;
         if(this.m_controller != null)
         {
            _loc4_ = this.m_controller.module as Module;
            if(_loc4_ != null && _loc4_.app != null)
            {
               _loc5_ = _loc4_.app.farmView.cursorCtrl;
               if(param2 == false)
               {
                  _loc5_.setCursor(param1);
                  _loc3_ = true;
               }
               else if(_loc5_.name != param1)
               {
                  _loc5_.setCursor(param1);
                  _loc3_ = true;
               }
               else
               {
                  this.setCursor(Consts.CURSOR_STYLE_ARROW);
                  _loc3_ = false;
               }
            }
         }
         return _loc3_;
      }
      
      private function onToolRollOver(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.target.tipText;
         if(_loc2_ == null || _loc2_ == "")
         {
            return;
         }
         this.m_controller.showTip(Consts.TIP_NAME_MOUSE,_loc2_);
      }
      
      private function onStageClick(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         param1.target.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.adjustPosition();
         addEventListener(MouseEvent.ROLL_OVER,this.onOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         stage.addEventListener(MouseEvent.CLICK,this.onStageClick,false,999,true);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.m_hideTimer = setTimeout(this.close,300);
      }
      
      override protected function updateBackGround() : void
      {
      }
      
      private function onToolClick(param1:MouseEvent) : void
      {
         var _loc3_:URLVariables = null;
         var _loc4_:URLVariables = null;
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.name == "ToolHook")
         {
            this.setCursor(Consts.CURSOR_STYLE_HOOK);
         }
         else if(_loc2_.name == "ToolPesticide")
         {
            this.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
         }
         else if(_loc2_.name == "ToolWater")
         {
            this.setCursor(Consts.CURSOR_STYLE_WATER);
         }
         else if(_loc2_.name == "CameraButton")
         {
            this.m_controller.openCameraShootWindow();
         }
         else if(_loc2_.name == "newHealthModeIcon")
         {
            this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_HEALTHMODE,null));
         }
         else if(_loc2_.name == "ToolZoomIn")
         {
            if(this._toolZoomOut == null)
            {
               this._toolZoomOut = this.addToolBtn("ToolZoomOut","缩小");
               this._toolZoomOut.x = this._toolZoomIn.x;
               this._toolZoomOut.y = this._toolZoomIn.y;
            }
            this.content.removeChild(this._toolZoomIn);
            this.content.addChild(this._toolZoomOut);
            this.m_controller.switchBigMode(true);
            if(int(Math.random() * EventRecorder.successRecordProbability) == 0)
            {
               _loc3_ = new URLVariables();
               _loc3_["flag1"] = EventRecorder.HF_ZOOMIN;
               _loc3_["flag2"] = EventRecorder.SUEECSS;
               _loc3_["1"] = EventRecorder.successRecordProbability;
               EventRecorder.record(_loc3_);
            }
         }
         else if(_loc2_.name == "ToolZoomOut")
         {
            if(this._toolZoomIn == null)
            {
               this._toolZoomIn = this.addToolBtn("ToolZoomIn","放大");
               this._toolZoomIn.x = this._toolZoomOut.x;
               this._toolZoomIn.y = this._toolZoomOut.y;
            }
            this.content.removeChild(this._toolZoomOut);
            this.content.addChild(this._toolZoomIn);
            this.m_controller.switchBigMode(false);
            if(int(Math.random() * EventRecorder.successRecordProbability) == 0)
            {
               _loc4_ = new URLVariables();
               _loc4_["flag1"] = EventRecorder.HF_ZOOMOUT;
               _loc4_["flag2"] = EventRecorder.SUEECSS;
               _loc4_["1"] = EventRecorder.successRecordProbability;
               EventRecorder.record(_loc4_);
            }
         }
         param1.stopPropagation();
         this.hideThis();
      }
      
      private function onToolRollOut(param1:MouseEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      public function toggleVisible() : void
      {
         if(this.visible == true)
         {
            this.close();
            return;
         }
         this.visible = true;
         if(stage != null)
         {
            stage.addEventListener(MouseEvent.CLICK,this.onStageClick,false,999,true);
         }
      }
      
      public function close() : void
      {
         this.visible = false;
         stage.removeEventListener(MouseEvent.CLICK,this.onStageClick);
      }
   }
}


package framework.layers
{
   import common.Consts;
   import common.view.cursor.CursorControl;
   import events.CursorEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import framework.base.BaseLayer;
   
   public class CursorLayer extends BaseLayer
   {
      
      private var m_cursorCtrl:CursorControl;
      
      private var m_currentCursor:MovieClip;
      
      public function CursorLayer(param1:CursorControl)
      {
         if(param1 != null)
         {
            super(param1.getMsgCenter());
            this.m_cursorCtrl = param1;
            mouseEnabled = false;
            mouseChildren = false;
            this.name = Consts.LAYER_CURSOR;
            return;
         }
         throw new ArgumentError("Null parameter");
      }
      
      private function stageDown(param1:MouseEvent) : void
      {
         if(this.m_currentCursor == null)
         {
            return;
         }
         if(this.m_currentCursor.visible == false)
         {
            return;
         }
         if(this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW)
         {
            this.m_currentCursor.gotoAndStop(2);
         }
      }
      
      private function remove() : void
      {
         if(this.m_currentCursor != null)
         {
            removeChild(this.m_currentCursor as DisplayObject);
            this.m_currentCursor = null;
         }
      }
      
      private function cursorMove(param1:MouseEvent) : void
      {
         if(this.m_currentCursor == null || this.m_currentCursor.visible == false)
         {
            return;
         }
         this.setPosition(param1.stageX,param1.stageY);
         param1.updateAfterEvent();
      }
      
      private function stageUp(param1:MouseEvent) : void
      {
         if(this.m_currentCursor == null)
         {
            return;
         }
         if(this.m_currentCursor.visible == false)
         {
            return;
         }
         if(this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW)
         {
            this.m_currentCursor.gotoAndStop(1);
         }
      }
      
      private function onSwitchCursor(param1:CursorEvent) : void
      {
         if(param1.cursorName == Consts.CURSOR_SYSTEM)
         {
            if(this.m_currentCursor != null)
            {
               (this.m_currentCursor as DisplayObject).visible = false;
            }
            Mouse.show();
         }
         else if(this.m_currentCursor != null)
         {
            this.m_currentCursor.visible = true;
            this.setPosition(mouseX,mouseY);
            Mouse.hide();
         }
         else
         {
            Mouse.show();
         }
      }
      
      private function stageClick(param1:MouseEvent) : void
      {
         if(this.m_currentCursor == null)
         {
            return;
         }
         if(this.m_currentCursor.visible == false)
         {
            return;
         }
         if(this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW)
         {
            return;
         }
         this.m_currentCursor.gotoAndPlay(2);
      }
      
      private function setPosition(param1:int, param2:int) : void
      {
         if(this.m_currentCursor == null)
         {
            return;
         }
         if(this.m_currentCursor.name == Consts.CURSOR_STYLE_CROPSEED)
         {
            this.m_currentCursor.x = param1 - this.m_currentCursor.width * 0.5;
            this.m_currentCursor.y = param2 - this.m_currentCursor.height * 0.5;
         }
         else
         {
            this.m_currentCursor.x = param1;
            this.m_currentCursor.y = param2;
         }
      }
      
      private function setCurrentCursor(param1:MovieClip) : void
      {
         Mouse.hide();
         this.remove();
         this.m_currentCursor = param1;
         addChild(this.m_currentCursor as DisplayObject);
         this.setPosition(mouseX,mouseY);
      }
      
      override protected function init() : void
      {
         super.init();
         m_msgCenter.addEventListener(CursorEvent.SET_CURSOR,this.onSetCursor,false,0,true);
         m_msgCenter.addEventListener(CursorEvent.SWITCH_CURSOR,this.onSwitchCursor,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.stageDown,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.stageUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.cursorMove,false,0,true);
         stage.addEventListener(MouseEvent.CLICK,this.stageClick,false,0,true);
      }
      
      private function onSetCursor(param1:CursorEvent) : void
      {
         var _loc3_:Class = null;
         var _loc4_:* = undefined;
         var _loc2_:Boolean = false;
         if(param1.cursorName == "")
         {
            _loc2_ = true;
         }
         if(this.m_cursorCtrl == null)
         {
            _loc2_ = true;
         }
         if(_loc2_ == false)
         {
            _loc3_ = this.m_cursorCtrl.getClass(param1.cursorName);
            if(_loc3_ != null)
            {
               _loc4_ = new _loc3_();
               if(param1.cursorArgument != "")
               {
                  _loc4_["cursorArgument"] = param1.cursorArgument;
               }
               _loc4_.name = param1.cursorName;
               _loc4_["mouseChildren"] = false;
               _loc4_["mouseEnabled"] = false;
               this.setCurrentCursor(_loc4_);
            }
            else
            {
               _loc2_ = true;
            }
         }
         if(_loc2_ == true)
         {
            Mouse.show();
            this.remove();
         }
      }
   }
}


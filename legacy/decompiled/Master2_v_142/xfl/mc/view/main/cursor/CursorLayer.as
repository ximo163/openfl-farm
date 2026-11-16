package mc.view.main.cursor
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.ui.Mouse;
   import mc.control.ViewControl;
   import mc.events.CursorEvent;
   
   public class CursorLayer extends Sprite
   {
      
      private var currentCursor:BaseCursor;
      
      public function CursorLayer()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function stageDown(param1:MouseEvent) : void
      {
         if(this.currentCursor == null)
         {
            return;
         }
         if((this.currentCursor as DisplayObject).visible == false)
         {
            return;
         }
         this.currentCursor.down();
      }
      
      private function setCursorHandler(param1:CursorEvent) : void
      {
         var _loc3_:Class = null;
         var _loc4_:BaseCursor = null;
         var _loc2_:Boolean = false;
         if(param1.cursorName == "")
         {
            _loc2_ = true;
         }
         if(!_loc2_)
         {
            _loc3_ = CursorClassLib.getClass(param1.cursorName);
            if(_loc3_ != null)
            {
               _loc4_ = new _loc3_() as BaseCursor;
               if(param1.cursorArgument != "")
               {
                  _loc4_.cursorArgument = param1.cursorArgument;
               }
               this.setCurrentCursor(_loc4_);
            }
            else
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            Mouse.show();
            if(this.currentCursor != null)
            {
               removeChild(this.currentCursor as DisplayObject);
               this.currentCursor = null;
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         mouseEnabled = false;
         mouseChildren = false;
         ViewControl.getInstance().addEventListener(CursorEvent.CURSOR,this.setCursorHandler,false,0,true);
         ViewControl.getInstance().addEventListener(CursorEvent.API,this.setAPICursorHandler,false,0,true);
         ViewControl.getInstance().addEventListener(CursorEvent.USE_TYPE,this.setTypeHandler,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.stageDown,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.stageUp,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.cursorMove,false,0,true);
         stage.addEventListener(MouseEvent.CLICK,this.stageClick,false,0,true);
      }
      
      private function setTypeHandler(param1:CursorEvent) : void
      {
         if(param1.cursorName == "system")
         {
            if(this.currentCursor != null)
            {
               (this.currentCursor as DisplayObject).visible = false;
            }
            Cursor.system = true;
            Mouse.show();
         }
         else if(this.currentCursor != null)
         {
            (this.currentCursor as DisplayObject).visible = true;
            (this.currentCursor as DisplayObject).x = mouseX;
            (this.currentCursor as DisplayObject).y = mouseY;
            Mouse.hide();
            Cursor.system = false;
         }
         else
         {
            Mouse.show();
         }
      }
      
      private function cursorMove(param1:MouseEvent) : void
      {
         if(this.currentCursor == null)
         {
            return;
         }
         if((this.currentCursor as DisplayObject).visible == false)
         {
            return;
         }
         (this.currentCursor as DisplayObject).x = param1.stageX;
         (this.currentCursor as DisplayObject).y = param1.stageY;
         param1.updateAfterEvent();
      }
      
      private function stageUp(param1:MouseEvent) : void
      {
         if(this.currentCursor == null)
         {
            return;
         }
         if((this.currentCursor as DisplayObject).visible == false)
         {
            return;
         }
         this.currentCursor.up();
      }
      
      private function stageClick(param1:MouseEvent) : void
      {
         if(this.currentCursor == null)
         {
            return;
         }
         if((this.currentCursor as DisplayObject).visible == false)
         {
            return;
         }
         this.currentCursor.click();
      }
      
      private function setAPICursorHandler(param1:CursorEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:BaseCursor = null;
         var _loc2_:Boolean = false;
         if(param1.cursorName == "")
         {
            _loc2_ = true;
         }
         if(!_loc2_)
         {
            _loc3_ = param1.materialName;
            if(_loc3_ != null)
            {
               _loc4_ = new CursorAPI(_loc3_) as BaseCursor;
               _loc4_.cursorArgument = param1.cursorArgument;
               this.setCurrentCursor(_loc4_);
            }
            else
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            Mouse.show();
            if(this.currentCursor != null)
            {
               removeChild(this.currentCursor as DisplayObject);
               this.currentCursor = null;
            }
         }
      }
      
      private function setCurrentCursor(param1:BaseCursor) : void
      {
         Mouse.hide();
         if(this.currentCursor != null)
         {
            removeChild(this.currentCursor as DisplayObject);
            this.currentCursor = null;
         }
         this.currentCursor = param1;
         addChild(this.currentCursor as DisplayObject);
         (this.currentCursor as DisplayObject).x = mouseX;
         (this.currentCursor as DisplayObject).y = mouseY;
         Cursor.currentCursor = this.currentCursor;
      }
   }
}


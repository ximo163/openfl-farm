package com.qzone.allianceActivity.collectingActivity.view
{
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ShareWindow
   {
      
      private var _class:Class;
      
      private var _api:IAllianceAppHelper;
      
      private var _win:MovieClip;
      
      public function ShareWindow(param1:IAllianceAppHelper)
      {
         super();
         this._api = param1;
         this._win = new this._class() as MovieClip;
         this._win.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
      }
      
      public function destroy() : void
      {
         if(this._win != null)
         {
            this._api.removePopup(this._win);
            this._win.stop();
            this._win = null;
         }
      }
      
      public function show(param1:int, param2:String) : void
      {
         var _loc3_:String = "恭喜您！";
         if(param1 == 0)
         {
            _loc3_ += "点亮了<font color=\"#FF6600\">" + param2 + "</font>种子，<br>赶快告诉好友吧！";
            this._win.gotoAndStop(2);
         }
         else if(param1 == 1)
         {
            _loc3_ += "集齐了三星<font color=\"#FF6600\">" + param2 + "</font>种子，<br>赶快告诉好友吧！";
            this._win.gotoAndStop(1);
         }
         else if(param1 == 2)
         {
            _loc3_ += "完成了图鉴<font color=\"#FF6600\">" + param2 + "</font>系列，<br>赶快告诉好友吧！";
            this._win.gotoAndStop(2);
         }
         this._api.popupWindow(this._win);
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         if(param1.type == MouseEvent.CLICK)
         {
            if(_loc2_.name == "btnShare")
            {
               this.destroy();
            }
            else if(_loc2_.name == "btnClose")
            {
               this.destroy();
            }
         }
      }
   }
}


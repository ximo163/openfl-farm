package com.cbmland.ui
{
   import flash.display.InteractiveObject;
   import flash.events.ContextMenuEvent;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   
   public class RightMenu
   {
      
      public function RightMenu()
      {
         super();
      }
      
      public static function addMenuItem(param1:InteractiveObject, param2:String, param3:Function, param4:Boolean = false, param5:Boolean = true, param6:Boolean = true, param7:Boolean = true) : void
      {
         var _loc8_:ContextMenu = null;
         if(param1.contextMenu == null)
         {
            _loc8_ = new ContextMenu();
         }
         else
         {
            _loc8_ = param1.contextMenu as ContextMenu;
         }
         if(param7)
         {
            _loc8_.hideBuiltInItems();
         }
         var _loc9_:ContextMenuItem = new ContextMenuItem(param2,param4,param5,param6);
         _loc9_.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,param3);
         _loc8_.customItems.push(_loc9_);
         param1.contextMenu = _loc8_;
      }
   }
}


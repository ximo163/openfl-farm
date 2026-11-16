package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.LipiUIComponent;
   import com.minutes.ui.core.UIEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class JerryTabNavigation extends LipiUIComponent
   {
      
      public static const TAB_SELECT:String = "tabSelect";
      
      private var unInit:Boolean = true;
      
      public var menu:JerryNavigation;
      
      private var tabContainer:JerryTabContainer;
      
      private var _selectedIndex:int = 0;
      
      public function JerryTabNavigation()
      {
         super();
         this.bgAlpha = 0;
         this.menu = new JerryNavigation();
         this.tabContainer = new JerryTabContainer();
         this.menu.addEventListener(JerryNavigation.MOUSE_DOWN,this.dosomething);
      }
      
      public function set menuDefaultButtonHeight(param1:Number) : void
      {
         this.menu.menuButtonHeight = param1;
      }
      
      public function selectedFontStyle(param1:uint = 12, param2:uint = 13369344, param3:String = "", param4:Boolean = false) : void
      {
         this.menu.selectedFontStyle(param1,param2,param3,param4);
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.menu.width = param1 - this.menu.x;
         this.tabContainer.width = param1;
      }
      
      public function set menuDefaultSkin(param1:Class) : void
      {
         this.menu.defaultSkin = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.menu.height = this.menu.menuHeight;
         this.tabContainer.height = param1 - this.menu.menuHeight;
      }
      
      private function dosomething(param1:Event) : void
      {
         this._selectedIndex = this.tabContainer.selectedIndex = JerryNavigation(param1.currentTarget).selectedIndex;
         var _loc2_:UIEvent = new UIEvent(JerryTabNavigation.TAB_SELECT,true);
         _loc2_.data = JerryNavigation(param1.currentTarget).selectedIndex;
         dispatchEvent(_loc2_);
      }
      
      public function set topHeight(param1:Number) : void
      {
         this.menu.topHeight = param1;
      }
      
      public function set menuHeight(param1:Number) : void
      {
         this.menu.menuHeight = param1;
         this.autoLayer();
      }
      
      public function addItem(param1:String, param2:DisplayObject, param3:Number = 0, param4:Number = 0, param5:Array = null) : void
      {
         this.menu.addItem(param1,param3,param4,param5);
         this.tabContainer.addItem(param2);
         this.selectedIndex = 0;
         this.show();
      }
      
      public function getTabItem(param1:int) : DisplayObject
      {
         return this.menu.getItem(param1);
      }
      
      public function get menuLeftDistance() : int
      {
         return this.menu.leftDistance;
      }
      
      public function get topHeight() : Number
      {
         return this.menu.topHeight;
      }
      
      public function defaultFontStyle(param1:uint = 12, param2:uint = 0, param3:String = "", param4:Boolean = false) : void
      {
         this.menu.defaultFontStyle(param1,param2,param3,param4);
      }
      
      private function autoLayer() : void
      {
         this.tabContainer.width = this.width;
         this.tabContainer.height = this.height - this.menu.menuHeight;
         this.tabContainer.x = 0;
         this.tabContainer.y = this.menu.menuHeight;
      }
      
      public function set menuDefaultButtonWidth(param1:Number) : void
      {
         this.menu.menuButtonWidth = param1;
      }
      
      public function set bgClass(param1:Class) : void
      {
         this.bgSkin = new LipiSkin(param1);
      }
      
      public function set menuBgClass(param1:Class) : void
      {
         this.menu.bgSkin = new LipiSkin(param1);
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._selectedIndex = param1;
         this.menu.selectedIndex = param1;
         this.tabContainer.selectedIndex = param1;
      }
      
      public function get menuDefaultButtonWidth() : Number
      {
         return this.menu.menuButtonWidth;
      }
      
      public function set contentBgClass(param1:Class) : void
      {
         this.tabContainer.bgSkin = new LipiSkin(param1);
      }
      
      public function set menuSelectedSkin(param1:Class) : void
      {
         this.menu.selectedSkin = param1;
      }
      
      public function set menuLeftDistance(param1:int) : void
      {
         this.menu.leftDistance = param1;
      }
      
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      public function set menuSpaceDistance(param1:int) : void
      {
         this.menu.spaceBetween = param1;
      }
      
      public function get menuDefaultButtonHeight() : Number
      {
         return this.menu.menuButtonHeight;
      }
      
      public function get menuSpaceDistance() : int
      {
         return this.menu.spaceBetween;
      }
      
      private function show() : void
      {
         if(this.unInit)
         {
            this.unInit = false;
            addChild(this.tabContainer);
            addChild(this.menu);
         }
         this.autoLayer();
      }
   }
}


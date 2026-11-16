package com.qzone.qui.controls
{
   import com.qzone.qui.containers.HBox;
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import com.qzone.qui.core.Align;
   import com.qzone.qui.skins.TabSelectedSkin;
   import com.qzone.qui.skins.TabSkin;
   import com.qzone.qui.styles.Style;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.text.TextFormat;
   
   public class TabBar extends HBox
   {
      
      private var _currentChild:Button;
      
      public var tabDefaultFormat:TextFormat;
      
      public var tabDefaultSkin:Class;
      
      private var _childArray:Array = [];
      
      public var tabOverFormat:TextFormat;
      
      public var viewStack:ViewStack;
      
      public var tabSelectedFormat:TextFormat;
      
      public var tabSelectedSkin:Class;
      
      private var _currentIndex:int = -1;
      
      private var _childObject:Object = {};
      
      public function TabBar()
      {
         super();
         _height = 20;
         backgroundAlpha = 0;
         gapH = -1;
         paddingH = 0;
         paddingV = 0;
         alignV = Align.TOP;
         alignH = Align.LEFT;
         defaultSkin = Shape;
         borderSizeH = 0;
         borderSizeV = 0;
         horizontalScrollPolicy = ScrollPolicy.OFF;
         verticalScrollPolicy = ScrollPolicy.OFF;
         this.tabDefaultSkin = TabSkin;
         this.tabSelectedSkin = TabSelectedSkin;
         this.tabDefaultFormat = Style.getButtonFormat();
         this.tabSelectedFormat = Style.getButtonSelectedFormat();
         this.tabOverFormat = Style.getButtonOverFormat();
      }
      
      private function select(param1:Button) : void
      {
         param1.selected = true;
      }
      
      private function unselect(param1:Button) : void
      {
         param1.selected = false;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(this._currentIndex == param1)
         {
            return;
         }
         this.unselect(this._currentChild);
         this._currentChild = this._childArray[param1];
         this.select(this._currentChild);
         this._currentIndex = param1;
         if(this.viewStack)
         {
            this.viewStack.selectedIndex = this._currentIndex;
         }
      }
      
      public function get tabNum() : int
      {
         if(this._childArray == null)
         {
            return 0;
         }
         return this._childArray.length;
      }
      
      public function addTab(param1:String = "新建标签", param2:Number = NaN, param3:Number = NaN) : DisplayObject
      {
         var _loc4_:Button = new Button(param1,this.tabClick);
         _loc4_.defaultSkin = this.tabDefaultSkin;
         _loc4_.selectedSkin = this.tabSelectedSkin;
         _loc4_.textDefaultFormat = this.tabDefaultFormat;
         _loc4_.textOverFormat = this.tabOverFormat;
         _loc4_.textSelectedFormat = this.tabSelectedFormat;
         this._childArray.push(_loc4_);
         this._childObject[_loc4_.name] = this._childArray.length - 1;
         this.addElement(_loc4_);
         if(param3)
         {
            _loc4_.height = param3;
         }
         if(param2)
         {
            _loc4_.width = param2;
         }
         if(this._childArray.length == 1)
         {
            _loc4_.selected = true;
            this._currentChild = _loc4_;
            this._currentIndex = 0;
         }
         param2 = content.width;
         return _loc4_;
      }
      
      public function get selectedIndex() : int
      {
         return this._currentIndex;
      }
      
      private function tabClick(param1:Event) : void
      {
         if(this._currentIndex != this._childObject[param1.target.name])
         {
            this.unselect(this._currentChild);
            this._currentChild = param1.target as Button;
            this.select(this._currentChild);
            this._currentIndex = this._childObject[this._currentChild.name];
            if(this.viewStack)
            {
               this.viewStack.selectedIndex = this._currentIndex;
            }
            this.dispatchEvent(new Event(Event.CHANGE));
         }
      }
   }
}


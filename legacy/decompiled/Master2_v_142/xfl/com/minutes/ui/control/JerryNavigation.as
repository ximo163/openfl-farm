package com.minutes.ui.control
{
   import com.minutes.ui.constant.ScrollPolicy;
   import com.minutes.ui.core.LipiContainer;
   import com.minutes.ui.core.LipiSkin;
   import com.minutes.ui.core.UIEvent;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class JerryNavigation extends LipiContainer
   {
      
      public static const MOUSE_DOWN:String = "mousedown";
      
      private var _spaceBetween:int = 0;
      
      private var indexChanged:Boolean = false;
      
      private var _leftDistance:Number = 0;
      
      private var _defaultColor:uint = 0;
      
      private var buttonList:Array = [];
      
      private var _selectedSkin:Class = null;
      
      private var _selectedColor:uint = 10027008;
      
      private var _defaultButtonHeight:Number = 40;
      
      private var _defaultSkin:Class = null;
      
      private var layerChanged:Boolean = false;
      
      private var _selectedBold:Boolean = false;
      
      private var _defaultBold:Boolean = false;
      
      private var _defaultSize:uint = 12;
      
      private var _selectedSize:uint = 12;
      
      private var _defaultButtonWidth:Number = 120;
      
      private var SkinChanged:Boolean = false;
      
      private var _topHeight:Number = 10;
      
      private var _defaultWidthSet:Boolean = false;
      
      private var _selectedFont:String = "";
      
      private var _defaultFont:String = "";
      
      private var _trueHeight:Number = 20;
      
      private var _selectedIndex:int;
      
      public function JerryNavigation()
      {
         super();
         this.bgAlpha = 0;
         this.width = 0;
         this.height = 0;
         this.verticalScrollPolicy = ScrollPolicy.OFF;
         this.horizontalScrollPolicy = ScrollPolicy.OFF;
         this.menuHeight = 30;
      }
      
      public function get menuButtonHeight() : Number
      {
         return this._defaultButtonHeight;
      }
      
      public function set menuButtonHeight(param1:Number) : void
      {
         this._defaultButtonHeight = param1;
      }
      
      public function getItem(param1:int) : DisplayObject
      {
         return this.getChildAt(param1);
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         super.addChildAt(param1,param2);
         this.layerChanged = true;
         invalidateDisplayList();
         return param1;
      }
      
      public function get leftDistance() : Number
      {
         return this._leftDistance;
      }
      
      public function get spaceBetween() : int
      {
         return this._spaceBetween;
      }
      
      public function set menuButtonWidth(param1:Number) : void
      {
         this._defaultButtonWidth = param1;
         this._defaultWidthSet = true;
         this.autoLayer();
      }
      
      private function setSelectedButton() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.buttonList.length)
         {
            (this.buttonList[_loc1_] as ToggleButton).selected = false;
            (this.buttonList[_loc1_] as ToggleButton).textSize = this._defaultSize;
            (this.buttonList[_loc1_] as ToggleButton).textColor = this._defaultColor;
            if(this._defaultFont != "")
            {
               (this.buttonList[_loc1_] as ToggleButton).textFont = this._defaultFont;
            }
            (this.buttonList[_loc1_] as ToggleButton).textBold = this._defaultBold;
            _loc1_++;
         }
         (this.buttonList[this.selectedIndex] as ToggleButton).selected = true;
         (this.buttonList[this.selectedIndex] as ToggleButton).textSize = this._selectedSize;
         (this.buttonList[this.selectedIndex] as ToggleButton).textColor = this._selectedColor;
         if(this._selectedFont != "")
         {
            (this.buttonList[this.selectedIndex] as ToggleButton).textFont = this._selectedFont;
         }
         (this.buttonList[this.selectedIndex] as ToggleButton).textBold = this._selectedBold;
      }
      
      private function skinPack() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.buttonList.length)
         {
            this.buttonList[_loc1_].defaultSkin = new LipiSkin(this.defaultSkin);
            this.buttonList[_loc1_].selectedSkin = new LipiSkin(this.selectedSkin);
            _loc1_++;
         }
      }
      
      public function get selectedSkin() : Class
      {
         return this._selectedSkin;
      }
      
      public function set defaultSkin(param1:Class) : void
      {
         this._defaultSkin = param1;
         this.SkinChanged = true;
         invalidateDisplayList();
      }
      
      public function set leftDistance(param1:Number) : void
      {
         this._leftDistance = param1;
         this.layerChanged = true;
         invalidateDisplayList();
      }
      
      private function getSelectedIndex(param1:ToggleButton) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.buttonList.length)
         {
            if(this.buttonList[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return this.selectedIndex;
      }
      
      public function set spaceBetween(param1:int) : void
      {
         this._spaceBetween = param1;
         this.layerChanged = true;
         invalidateDisplayList();
      }
      
      public function selectedFontStyle(param1:uint = 12, param2:uint = 13369344, param3:String = "", param4:Boolean = false) : void
      {
         this._selectedSize = param1;
         this._selectedColor = param2;
         this._selectedFont = param3;
         this._selectedBold = param4;
      }
      
      public function set menuHeight(param1:Number) : void
      {
         this._trueHeight = param1;
         super.height = param1;
      }
      
      public function set topHeight(param1:Number) : void
      {
         this._topHeight = param1;
         this.autoLayer();
      }
      
      public function addItem(param1:String, param2:Number = 0, param3:Number = 0, param4:Array = null) : void
      {
         var _loc5_:ToggleButton = new ToggleButton();
         _loc5_.bgAlpha = 0;
         _loc5_.label = param1;
         _loc5_.labelFilters = param4;
         _loc5_.textSize = this._defaultSize;
         _loc5_.textColor = this._defaultColor;
         if(this._defaultFont != "")
         {
            _loc5_.textFont = this._defaultFont;
         }
         this.buttonList.push(_loc5_);
         if(param2 != 0 && param3 != 0)
         {
            _loc5_.width = param2;
            _loc5_.height = param3;
            _loc5_.name = "selfSize";
         }
         else
         {
            _loc5_.width = this._defaultButtonWidth;
            _loc5_.height = this._defaultButtonHeight;
            _loc5_.name = "defaultSize";
         }
         this.addChild(_loc5_);
         _loc5_.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownDispatcher);
         this.SkinChanged = true;
         invalidateDisplayList();
      }
      
      public function get menuButtonWidth() : Number
      {
         return this._defaultButtonWidth;
      }
      
      public function get topHeight() : Number
      {
         return this._topHeight;
      }
      
      public function defaultFontStyle(param1:uint = 12, param2:uint = 0, param3:String = "", param4:Boolean = false) : void
      {
         this._defaultSize = param1;
         this._defaultColor = param2;
         this._defaultFont = param3;
         this._defaultBold = param4;
      }
      
      public function get defaultSkin() : Class
      {
         return this._defaultSkin;
      }
      
      public function get menuHeight() : Number
      {
         return this._trueHeight;
      }
      
      private function mouseDownDispatcher(param1:MouseEvent) : void
      {
         var _loc2_:ToggleButton = ToggleButton(param1.currentTarget);
         this.selectedIndex = this.getSelectedIndex(_loc2_);
         var _loc3_:UIEvent = new UIEvent(JerryNavigation.MOUSE_DOWN);
         _loc3_.data = this;
         this.dispatchEvent(_loc3_);
      }
      
      public function set selectedSkin(param1:Class) : void
      {
         this._selectedSkin = param1;
         this.SkinChanged = true;
         invalidateDisplayList();
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 < this.buttonList.length)
         {
            this._selectedIndex = param1;
            this.indexChanged = true;
            invalidateDisplayList();
         }
      }
      
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      private function autoLayer() : void
      {
         var _loc4_:DisplayObject = null;
         var _loc1_:Number = this._leftDistance;
         var _loc2_:int = 0;
         var _loc3_:int = this.numChildren;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this.getChildAt(_loc2_);
            if(_loc4_.name == "defaultSize")
            {
               _loc4_.width = this._defaultButtonWidth;
               _loc4_.height = this._defaultButtonHeight;
            }
            _loc4_.x = _loc1_;
            _loc4_.y = this._topHeight;
            _loc1_ += _loc4_.width + this._spaceBetween;
            _loc2_++;
         }
         resetSize();
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         super.addChild(param1);
         this.layerChanged = true;
         invalidateDisplayList();
         return param1;
      }
      
      override protected function updateDisplayList(param1:Number, param2:Number) : void
      {
         super.updateDisplayList(param1,param2);
         if(this.SkinChanged)
         {
            this.skinPack();
            this.SkinChanged = false;
         }
         if(this.indexChanged)
         {
            this.setSelectedButton();
            this.indexChanged = false;
         }
         if(this.layerChanged)
         {
            this.autoLayer();
            this.layerChanged = false;
         }
      }
   }
}


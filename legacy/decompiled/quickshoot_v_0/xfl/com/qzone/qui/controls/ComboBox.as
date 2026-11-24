package com.qzone.qui.controls
{
   import com.qzone.qui.managers.EffectManager;
   import com.qzone.qui.managers.PopUpManager;
   import com.qzone.qui.skins.ComboBoxDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.qui.utils.EventUtil;
   import com.qzone.utils.AlignUtil;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class ComboBox extends Label
   {
      
      private var _dropdwon:List;
      
      private var _data:Array;
      
      public var arrowSkin:Class;
      
      protected var _arrowSkin:DisplayObject;
      
      private var _selectedItem:Object;
      
      public var selectedSkin:Class;
      
      private var _hasOpen:Boolean;
      
      public var rowCount:int = 8;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public var labelField:String = "label";
      
      private var _selectedIndex:int;
      
      private var _selected:Boolean;
      
      public function ComboBox(param1:String = "请选择...")
      {
         super(param1);
         this.defaultSkin = ComboBoxDefaultSkin.skin;
         this.selectedSkin = ComboBoxDefaultSkin.selectedSkin;
         this.arrowSkin = ComboBoxDefaultSkin.arrowSkin;
         textDefaultFormat = Style.getComboBoxFormat();
         _height = 20;
         this.buttonMode = true;
         this.useHandCursor = false;
         this.mouseChildren = false;
      }
      
      private function hideDropdwon() : void
      {
         PopUpManager.removePopUp(this._dropdwon);
         this._hasOpen = false;
         this.onRollOut(null);
      }
      
      override protected function setSkin() : void
      {
         if(this._selected)
         {
            this.setArrowSkin();
            this.setSelectedSkin();
         }
         else
         {
            this.setArrowSkin();
            this.setDefaultSkin();
         }
      }
      
      private function onRollOver(param1:Event) : void
      {
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this._selected = true;
         this.setSkin();
         this.filters = Style.getRollOverFilter();
      }
      
      override protected function init() : void
      {
         super.init();
         _textField.setTextFormat(textDefaultFormat);
      }
      
      override protected function setSize() : void
      {
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
         if(this._arrowSkin)
         {
            this._arrowSkin.x = AlignUtil.right(_width,this._arrowSkin.width) - Style.comboBoxArrowPaddingH;
            this._arrowSkin.y = Math.round(AlignUtil.middle(_height,this._arrowSkin.height));
         }
         _textField.width = _width - Style.comboBoxArrowWidth;
         _textField.height = Math.max(18,_textField.textHeight);
         _textField.y = Math.round(_height - _textField.height) / 2;
      }
      
      public function set selectedItem(param1:Object) : void
      {
         this._selectedItem = param1;
         if(this._dropdwon)
         {
            this._dropdwon.selectedItem = this._selectedItem;
         }
         this.updateValue(param1);
      }
      
      protected function setDefaultSkin() : void
      {
         if(this._skin)
         {
            DisplayUtil.removeChild(this,this._skin);
         }
         this._skin = new this.defaultSkin();
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
      
      private function onPress(param1:Event) : void
      {
         this.addEventListener(MouseEvent.MOUSE_UP,this.onRollOver);
         this.filters = Style.getHitFilter();
      }
      
      private function onRelease(param1:Event) : void
      {
         this.removeEventListener(MouseEvent.MOUSE_UP,this.onRelease);
         this.filters = Style.getRollOverFilter();
      }
      
      private function updateValue(param1:Object) : void
      {
         if(param1.hasOwnProperty(this.labelField))
         {
            text = param1[this.labelField];
         }
         else
         {
            text = param1.toString();
         }
      }
      
      private function onRollOut(param1:Event) : void
      {
         this.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         if(!this._hasOpen)
         {
            this._selected = false;
            this.setSkin();
            this.filters = Style.getRollOutFilter();
         }
      }
      
      protected function setSelectedSkin() : void
      {
         if(this._skin)
         {
            DisplayUtil.removeChild(this,this._skin);
         }
         this._skin = new this.selectedSkin();
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
      
      public function get dataProvider() : Array
      {
         return this._data;
      }
      
      private function showDropdwon() : void
      {
         var _loc1_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         if(this._dropdwon == null)
         {
            this._dropdwon = new List();
            this._dropdwon.labelField = this.labelField;
            this._dropdwon.width = _width;
            _loc3_ = this.rowCount;
            if(this._data)
            {
               _loc3_ = Math.min(this._data.length,this.rowCount);
            }
            this._dropdwon.height = this._dropdwon.rowHeight * _loc3_ + this._dropdwon.borderSizeV * 2 + this._dropdwon.paddingV * 2;
            this._dropdwon.dataProvider = this._data;
            if(this._selectedIndex)
            {
               this._dropdwon.selectedIndex = this._selectedIndex;
               this.updateValue(this._data[this._selectedIndex]);
            }
            else if(this._selectedItem)
            {
               this._dropdwon.selectedItem = this._selectedItem;
               this.updateValue(this._dropdwon.selectedItem);
            }
            this._dropdwon.effect = EffectManager.comboBaseEffect;
            this._dropdwon.addEventListener(Event.CHANGE,this._CHANGE);
            this._dropdwon.addEventListener(MouseEvent.MOUSE_DOWN,EventUtil.stopImmediatePropagation);
         }
         _loc1_ = this.stage as DisplayObjectContainer;
         var _loc2_:Point = this.parent.localToGlobal(new Point(this.x,this.y + this.height - 1));
         this._dropdwon.x = _loc2_.x;
         this._dropdwon.y = _loc2_.y;
         this.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseUp);
         PopUpManager.addPopUp(this._dropdwon,false,false,_loc1_);
         this._hasOpen = true;
      }
      
      private function onStageMouseUp(param1:Event) : void
      {
         if(param1.target != this && param1.target != this._dropdwon)
         {
            if(this.stage)
            {
               this.stage.removeEventListener(MouseEvent.CLICK,this.onStageMouseUp);
            }
            this.hideDropdwon();
         }
      }
      
      private function _CHANGE(param1:Event) : void
      {
         var _loc2_:Object = param1.currentTarget.selectedItem;
         var _loc3_:String = param1.currentTarget.labelField;
         this.value = _loc2_.hasOwnProperty(_loc3_) ? _loc2_[_loc3_] : _loc2_.toString();
         this.hideDropdwon();
         dispatchEvent(param1);
      }
      
      public function get selectedItem() : Object
      {
         return this._dropdwon.selectedItem;
      }
      
      public function set value(param1:String) : void
      {
         _text = param1 || "";
         this._textField.text = _text;
      }
      
      protected function setArrowSkin() : void
      {
         if(this._arrowSkin == null)
         {
            this._arrowSkin = new this.arrowSkin();
            this.addChild(this._arrowSkin);
         }
      }
      
      private function onClick(param1:Event) : void
      {
         if(this._hasOpen)
         {
            this.hideDropdwon();
         }
         else
         {
            this.showDropdwon();
         }
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._selectedIndex = param1;
         if(this._dropdwon)
         {
            this._dropdwon.selectedIndex = this._selectedIndex;
         }
         this.updateValue(this._data[this._selectedIndex]);
      }
      
      public function get value() : String
      {
         return _text;
      }
      
      private function removeEvent() : void
      {
         this.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function get selectedIndex() : int
      {
         return this._dropdwon.selectedIndex;
      }
      
      private function addEvent() : void
      {
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
         this.addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      public function set dataProvider(param1:Array) : void
      {
         this._data = param1;
      }
      
      override protected function setEnabled() : void
      {
         if(false == _enabled)
         {
            this.removeEvent();
            _textField.setTextFormat(Style.getDisabledFormat());
            this.filters = Style.getDisableFilter();
         }
         else
         {
            this.addEvent();
            _textField.setTextFormat(Style.getButtonFormat());
            this.filters = Style.getRollOutFilter();
         }
         this.mouseEnabled = _enabled;
         this.tabEnabled = _enabled;
      }
   }
}


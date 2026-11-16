package com.qzone.qui.controls.listClasses
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.UIComponent;
   import com.qzone.qui.skins.ListItemDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.DisplayUtil;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ListItemRenderer extends UIComponent
   {
      
      private var _labelText:String;
      
      protected var _data:Object;
      
      private var _index:int;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public var labelField:String = "label";
      
      private var _label:Label;
      
      public var selectedSkin:Class;
      
      protected var _selected:Boolean;
      
      public function ListItemRenderer(param1:int)
      {
         super();
         this._index = param1;
         this.defaultSkin = ListItemDefaultSkin.skin;
         this.selectedSkin = ListItemDefaultSkin.selectedSkin;
         _height = 18;
         _width = 100;
         this._label = new Label();
         this.buttonMode = true;
         this.useHandCursor = false;
         this.mouseChildren = false;
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
      
      override protected function setSize() : void
      {
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
         this._label.width = _width;
         this._label.height = _height;
      }
      
      override protected function setSkin() : void
      {
         if(this._selected)
         {
            this.setSelectedSkin();
         }
         else
         {
            this.setDefaultSkin();
         }
      }
      
      override protected function init() : void
      {
         super.init();
         this._label.text = this._labelText;
         addChild(this._label);
         this.addEvent();
      }
      
      public function set data(param1:Object) : void
      {
         if(param1 != null)
         {
            this._data = param1;
            this._labelText = this._data.hasOwnProperty(this.labelField) ? this._data[this.labelField] : this._data.toString();
            if(this._label)
            {
               this._label.text = this._labelText;
            }
         }
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      protected function setDefaultSkin() : void
      {
         if(this._skin)
         {
            DisplayUtil.removeChild(this,this._skin);
         }
         this._skin = new this.defaultSkin();
         this._skin.alpha = 0;
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
      
      private function onRollOver(param1:Event) : void
      {
         this.filters = Style.getRollOverFilter();
         this._skin.alpha = 1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      private function onRollOut(param1:Event) : void
      {
         this.filters = Style.getRollOutFilter();
         if(!this._selected)
         {
            this._skin.alpha = 0;
         }
      }
      
      protected function removeEvent() : void
      {
         this.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      protected function addEvent() : void
      {
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(this._selected != param1)
         {
            this._selected = param1;
            this.setSkin();
         }
      }
   }
}


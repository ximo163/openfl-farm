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
      
      protected var _selected:Boolean;
      
      protected var _data:Object;
      
      protected var _index:int;
      
      protected var _skin:DisplayObject;
      
      public var defaultSkin:Class;
      
      public var labelField:String = "label";
      
      protected var _label:Label;
      
      public var selectedSkin:Class;
      
      public function ListItemRenderer(param1:int)
      {
         super();
         this._index = param1;
         this.defaultSkin = ListItemDefaultSkin.skin;
         this.selectedSkin = ListItemDefaultSkin.selectedSkin;
         _height = 18;
         _width = 100;
         this._label = null;
         this.buttonMode = true;
         this.useHandCursor = false;
         this.mouseChildren = false;
      }
      
      override protected function setSize() : void
      {
         if(this._skin)
         {
            this._skin.width = _width;
            this._skin.height = _height;
         }
         if(this._label)
         {
            this._label.width = _width;
            this._label.height = _height;
         }
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
         if(this._label == null)
         {
            this._label = new Label();
            addChild(this._label);
         }
         var _loc1_:String = "";
         if(this._data != null)
         {
            _loc1_ = this._data.hasOwnProperty(this.labelField) ? this._data[this.labelField] : this._data.toString();
         }
         this._label.text = _loc1_;
         this.addEvent();
      }
      
      public function set data(param1:Object) : void
      {
         var _loc2_:String = null;
         if(param1 != null)
         {
            this._data = param1;
            _loc2_ = this._data.hasOwnProperty(this.labelField) ? this._data[this.labelField] : this._data.toString();
            if(this._label != null)
            {
               this._label.text = _loc2_;
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
            this._skin = null;
         }
         this._skin = new this.defaultSkin();
         this._skin.alpha = 0;
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      protected function onRollOut(param1:Event) : void
      {
         this.filters = Style.getRollOutFilter();
         if(!this._selected)
         {
            this._skin.alpha = 0;
         }
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(this._selected != param1)
         {
            this._selected = param1;
            this.setSkin();
         }
      }
      
      protected function onRollOver(param1:Event) : void
      {
         this.filters = Style.getRollOverFilter();
         this._skin.alpha = 1;
      }
      
      protected function addEvent() : void
      {
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      protected function setSelectedSkin() : void
      {
         if(this._skin)
         {
            DisplayUtil.removeChild(this,this._skin);
            this._skin = null;
         }
         this._skin = new this.selectedSkin();
         this.addChildAt(this._skin,0);
         _added && this.setSize();
      }
      
      protected function removeEvent() : void
      {
         this.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
   }
}


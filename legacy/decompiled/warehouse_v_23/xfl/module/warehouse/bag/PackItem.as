package module.warehouse.bag
{
   import com.qzone.qui.controls.listClasses.ListItemRenderer;
   import common.Consts;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import entities.BagItem;
   import events.ViewEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class PackItem extends ListItemRenderer
   {
      
      private var m_material:MaterialProxy;
      
      public function PackItem(param1:int)
      {
         super(param1);
         buttonMode = true;
         useHandCursor = true;
         mouseChildren = false;
         this.m_material = null;
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         addEventListener(MouseEvent.CLICK,this.onChildClick,false,0,true);
      }
      
      override protected function setSize() : void
      {
      }
      
      protected function onChildClick(param1:MouseEvent) : void
      {
         if(this.m_material != null && this.m_material.loaded == false)
         {
            return;
         }
         var _loc2_:BagItem = super._data as BagItem;
         if(_loc2_._type.toString() == Consts.ITEM_TYPE_WEAPON || _loc2_._type.toString() == Consts.ITEM_TYPE_TOOL && _loc2_._cId == 34)
         {
            return;
         }
         var _loc3_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK,true);
         _loc3_.data = data;
         dispatchEvent(_loc3_);
      }
      
      override protected function init() : void
      {
         var _loc2_:BagItem = null;
         var _loc3_:Boolean = false;
         super.init();
         if(super._label != null)
         {
            super._label.textDefaultFormat = new TextFormat("embedFontA",12,3355443,null,null,null,null,null,TextFormatAlign.RIGHT);
            super._label.embedFonts = true;
         }
         var _loc1_:Sprite = Utils.getMaterial("ItemBg") as Sprite;
         if(_loc1_ != null)
         {
            _loc1_.mouseEnabled = false;
            addChildAt(_loc1_,0);
         }
         if(this.m_material == null)
         {
            this.m_material = new MaterialProxy();
            this.m_material.showLoading();
            addChildAt(this.m_material,1);
         }
         if(super._data != null)
         {
            _loc2_ = super._data as BagItem;
            _loc3_ = true;
            if(_loc2_._type.toString() == Consts.ITEM_TYPE_WEAPON || _loc2_._type.toString() == Consts.ITEM_TYPE_TOOL && _loc2_._cId == 34)
            {
               _loc3_ = false;
            }
            this.m_material.setContent(_loc2_._type.toString(),_loc2_._cId,_loc3_);
            this.setAmount(_loc2_._amount);
         }
      }
      
      override protected function onRollOut(param1:Event) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OUT,true);
         _loc2_.data = data;
         dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:BagItem = param1 as BagItem;
         super._data = _loc2_;
         var _loc3_:int = int(_loc2_._type);
         var _loc4_:int = int(_loc2_._cId);
         if(this.m_material != null)
         {
            this.m_material.setContent(_loc3_.toString(),_loc4_);
         }
         if(_loc2_._amount > 0)
         {
            this.setAmount(_loc2_._amount);
         }
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         removeEventListener(MouseEvent.CLICK,this.onChildClick);
      }
      
      override protected function onRollOver(param1:Event) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OVER,true);
         _loc2_.data = data;
         dispatchEvent(_loc2_);
      }
      
      public function setAmount(param1:int) : void
      {
         if(super._label != null)
         {
            super._label.text = param1.toString();
            super._label.x = 60 - super._label.width;
            super._label.y = 63 - super._label.height;
         }
      }
      
      override protected function setSkin() : void
      {
      }
   }
}


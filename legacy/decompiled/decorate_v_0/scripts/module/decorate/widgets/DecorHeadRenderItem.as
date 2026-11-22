package module.decorate.widgets
{
   import com.qzone.qui.styles.Style;
   import common.Consts;
   import entities.DecorateItem;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class DecorHeadRenderItem extends DecorRenderItem
   {
      
      public function DecorHeadRenderItem()
      {
         super();
      }
      
      override public function toggleDecorated() : void
      {
         var _loc1_:DecorateItem = null;
         _loc1_ = super.data as DecorateItem;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_._status == 1)
         {
            if(_setText == null)
            {
               _setText = new TextField();
               _setText.width = 60;
               _setText.height = 20;
               _setText.selectable = false;
               _setText.mouseEnabled = false;
               _setText.defaultTextFormat = new TextFormat("Verdana",12,13369344,null,null,null,null,null,TextFormatAlign.CENTER);
               _setText.filters = Style.getTextGlowFilter();
               _setText.text = "点击装饰";
               _setText.visible = false;
               addChild(_setText);
               _setText.x = 0;
               _setText.y = (60 - _setText.height) * 0.5;
            }
            else
            {
               _setText.visible = false;
            }
            if(_loc1_._type == Consts.DECOR_DOG)
            {
               _material.setContent(Consts.ITEM_TYPE_DOG,_loc1_._itemId - 80000,true);
            }
            else
            {
               _material.setContent(Consts.ITEM_TYPE_DECORATE,_loc1_._itemId,true);
            }
         }
         else
         {
            if(_setText != null)
            {
               _setText.visible = true;
            }
            if(_loc1_._type == Consts.DECOR_DOG)
            {
               _material.setContent(Consts.ITEM_TYPE_DOG,_loc1_._itemId - 80000,false);
            }
            else
            {
               _material.setContent(Consts.ITEM_TYPE_DECORATE,_loc1_._itemId,false);
            }
         }
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1 == super._item)
         {
            if((param1 as DecorateItem)._status != (super._item as DecorateItem)._status)
            {
               this.toggleDecorated();
            }
            return;
         }
         super.data = param1;
         this.toggleDecorated();
         createMask("ItemBorder",60,60);
         registerListeners();
      }
   }
}


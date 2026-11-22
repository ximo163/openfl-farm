package module.decorate.widgets
{
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.GraphicsUtil;
   import common.Consts;
   import entities.DecorateItem;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class DecorRenderItem extends BaseTileItem
   {
      
      protected var _setText:TextField;
      
      protected var _setCropTime:int;
      
      public function DecorRenderItem()
      {
         super();
         createBackground("ItemBorder",60,60);
         _material.y = 1;
         this._setText = null;
         this._setCropTime = -1;
         GraphicsUtil.draw(this,16777215,0,new Rectangle(0,0,60,80));
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null || param1 == super._item)
         {
            return;
         }
         super.data = param1;
         this.toggleDecorated();
         createMask("ItemBorder",60,60);
         registerListeners();
      }
      
      public function toggleDecorated() : void
      {
         var _loc1_:DecorateItem = super.data as DecorateItem;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_._status == 1)
         {
            if(this._setText == null)
            {
               this._setText = new TextField();
               this._setText.width = 60;
               this._setText.height = 20;
               this._setText.selectable = false;
               this._setText.mouseEnabled = false;
               this._setText.defaultTextFormat = new TextFormat("Verdana",12,13369344,null,null,null,null,null,TextFormatAlign.CENTER);
               this._setText.filters = Style.getTextGlowFilter();
               this._setText.text = "已装饰";
               addChild(this._setText);
               this._setText.x = 0;
               this._setText.y = (60 - this._setText.height) * 0.5;
            }
            else
            {
               this._setText.visible = true;
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
         else
         {
            if(this._setText != null)
            {
               this._setText.visible = false;
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
      }
   }
}


package module.decorate.widgets
{
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.GraphicsUtil;
   import common.Consts;
   import common.GetCropID;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.base.BaseTileItem;
   
   public class BoardRenderItem extends BaseTileItem
   {
      
      private var _setText:TextField;
      
      public function BoardRenderItem()
      {
         super();
         createBackground("ItemBg",100,100);
         this._setText = null;
         GraphicsUtil.draw(this,16777215,0,new Rectangle(0,0,100,120));
      }
      
      public function toggleDecorated() : void
      {
         if(super.data["status"] == 1)
         {
            if(this._setText == null)
            {
               this._setText = new TextField();
               this._setText.width = 100;
               this._setText.height = 20;
               this._setText.selectable = false;
               this._setText.mouseEnabled = false;
               this._setText.defaultTextFormat = new TextFormat("Verdana",12,13369344,null,null,null,null,null,TextFormatAlign.CENTER);
               this._setText.filters = Style.getTextGlowFilter();
               this._setText.text = "已装饰";
               addChild(this._setText);
               this._setText.x = 0;
               this._setText.y = (this.height - this._setText.height) * 0.5;
            }
            else
            {
               this._setText.visible = true;
            }
            _material.setContent(Consts.DECOR_BILLBOARD.toString(),super.data["id"],false);
         }
         else
         {
            if(this._setText != null)
            {
               this._setText.visible = false;
            }
            _material.setContent(Consts.DECOR_BILLBOARD.toString(),super.data["id"],true);
         }
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null || param1 == super._item)
         {
            return;
         }
         super.data = param1;
         if(param1["id"] == undefined)
         {
            return;
         }
         var _loc2_:String = GetCropID.idToBoardUrl(param1["id"]);
         if(_loc2_ == "")
         {
            return;
         }
         _material.loadBillBoard(_loc2_);
         _material.showLoading();
         this.toggleDecorated();
         registerListeners();
      }
   }
}


package common.view.window
{
   import common.Consts;
   import common.GetCropID;
   import common.view.MaterialProxy;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class GiftItem extends Sprite
   {
      
      private var _label:TextField;
      
      private var _materialProxy:MaterialProxy;
      
      private var _data:Object;
      
      public function GiftItem(param1:Boolean)
      {
         super();
         this._label = new TextField();
         this._label.defaultTextFormat = new TextFormat("SimSun",20,16737792,true,null,null,null,null,TextFormatAlign.CENTER);
         this._label.embedFonts = false;
         this._label.selectable = false;
         if(param1 == true)
         {
            this._label.x = 0;
            this._label.y = 115;
            this._label.width = 120;
            this._label.height = 30;
         }
         else
         {
            this._label.x = -15;
            this._label.y = 65;
            this._label.autoSize = TextFieldAutoSize.CENTER;
            this._label.height = 30;
         }
         addChild(this._label);
         this._materialProxy = new MaterialProxy(param1 ? MaterialProxy.BIG : MaterialProxy.SMALL);
         addChild(this._materialProxy);
         this._materialProxy.y = -3;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
         this.update();
      }
      
      private function update() : void
      {
         var _loc1_:String = "";
         if(this.data.hasOwnProperty("eType"))
         {
            if(this._materialProxy != null)
            {
               this._materialProxy.setContent(this.data["eType"],this.data["eParam"]);
            }
            _loc1_ = GetCropID.getNameByIDType(this.data["eType"],this.data["eParam"]);
            if(this._label != null)
            {
               this._label.text = _loc1_ + "×" + (this.data["eType"] == Consts.ITEM_TYPE_DECORATE ? "1" : this.data["eNum"]);
            }
         }
         else
         {
            if(this._materialProxy != null)
            {
               this._materialProxy.setContent(this.data["type"],this.data["id"]);
            }
            _loc1_ = GetCropID.getNameByIDType(this.data["type"],this.data["id"]);
            if(this._label != null)
            {
               this._label.text = _loc1_ + "×" + (this.data["type"] == Consts.ITEM_TYPE_DECORATE ? "1" : this.data["num"]);
            }
         }
         if(this._materialProxy != null && this.data["eType"] == Consts.ITEM_TYPE_WEAPON)
         {
            this._materialProxy.scaleX = 0.85;
            this._materialProxy.scaleY = 0.85;
         }
      }
   }
}


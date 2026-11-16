package mc.view.main.leftInfo
{
   import com.minutes.ui.collections.LipiListChild;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.common.MaterialProxy;
   
   public class GiftItem extends LipiListChild
   {
      
      private var numText:TextField;
      
      private var materialProxy:MaterialProxy;
      
      public function GiftItem()
      {
         super();
         this.materialProxy = new MaterialProxy();
         addChild(this.materialProxy);
         this.numText = new TextField();
         this.numText.defaultTextFormat = new TextFormat("embedFontA",22,16737792,true,null,null,null,null,TextFormatAlign.CENTER);
         this.numText.embedFonts = true;
         this.numText.width = 60;
         this.numText.height = 22;
         this.numText.y = 65;
         this.numText.selectable = false;
         addChild(this.numText);
      }
      
      override public function get data() : Object
      {
         return super.data;
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc2_:MaterialLoaderProxy = null;
         var _loc3_:MaterialProxy = null;
         var _loc4_:MaterialProxy = null;
         super.data = param1;
         if(this.data.eType == "9")
         {
            _loc2_ = new MaterialLoaderProxy();
            _loc2_.setContent(this.data.eType,this.data.eParam);
            addChild(_loc2_);
         }
         else if(this.data.eType == "5")
         {
            _loc3_ = new MaterialProxy();
            _loc3_.setContent("5_5",this.data.eParam);
            addChild(_loc3_);
         }
         else
         {
            _loc4_ = new MaterialProxy();
            _loc4_.setContent(this.data.eType,this.data.eParam);
            addChild(_loc4_);
         }
         this.numText.text = param1["eNum"];
      }
      
      override public function get width() : Number
      {
         return 60;
      }
   }
}


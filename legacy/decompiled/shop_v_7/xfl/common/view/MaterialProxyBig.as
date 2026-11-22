package common.view
{
   import com.qzone.qfa.managers.ResourceManager;
   import flash.display.Sprite;
   
   public class MaterialProxyBig extends Sprite
   {
      
      private var materialProxy:MaterialProxy;
      
      public function MaterialProxyBig(param1:int = 120)
      {
         var _loc2_:Sprite = null;
         super();
         _loc2_ = ResourceManager.gi().getClassInstance("ItemBg") as Sprite;
         _loc2_.name = "ItemBg";
         _loc2_.width = param1;
         _loc2_.height = param1;
         addChild(_loc2_);
         this.materialProxy = new MaterialProxy(MaterialProxy.BIG);
         addChild(this.materialProxy);
      }
      
      public function loadBillBoard(param1:String) : void
      {
         this.materialProxy.loadBillBoard(param1);
      }
      
      public function setContent(param1:String, param2:int, param3:Boolean = true) : void
      {
         this.materialProxy.setContent(param1,param2,param3);
      }
   }
}


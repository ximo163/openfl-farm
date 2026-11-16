package mc.view.common
{
   import flash.display.Sprite;
   
   public class MaterialProxyBig extends Sprite
   {
      
      private var materialProxy:MaterialProxy;
      
      public function MaterialProxyBig()
      {
         super();
         this.materialProxy = new MaterialProxy();
         addChild(this.materialProxy);
      }
      
      public function setContent(param1:String, param2:int, param3:Boolean = true) : void
      {
         this.materialProxy.setContent(param1,param2,param3);
      }
   }
}


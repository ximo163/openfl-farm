package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiTile2;
   import flash.display.Sprite;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WindowClassLib;
   
   public class ShopToolTile extends Sprite
   {
      
      private var dataLoading:DataLoading;
      
      private var tile:LipiTile2;
      
      public function ShopToolTile()
      {
         super();
         this.tile = new LipiTile2(ToolItem,5,90,98,23,10);
         this.tile.addEventListener(ViewEvent.CHILD_CLICK,this.tileChildClick);
         this.tile.y = 1;
         this.tile.width = 480;
         this.tile.height = 300 + 30;
         this.tile.bgAlpha = 0;
         addChild(this.tile);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = this.tile.width / 2;
         this.dataLoading.y = this.tile.height / 2;
         addChild(this.dataLoading);
      }
      
      public function set dataList(param1:Array) : void
      {
         this.tile.dataList = param1;
         this.tile.resetSize();
      }
      
      public function set errText(param1:String) : void
      {
         this.dataLoading.errorText = param1;
      }
      
      public function get dataList() : Array
      {
         return this.tile.dataList;
      }
      
      private function tileChildClick(param1:ViewEvent) : void
      {
         var _loc2_:Object = param1.data;
         WindowClassLib.register("ShopToolWindow",ShopToolWindow);
         var _loc3_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc3_.windowName = "ShopToolWindow";
         _loc3_.windowArgument = param1.data;
         ViewControl.getInstance().dispatchEvent(_loc3_);
      }
      
      public function set loadingVisible(param1:Boolean) : void
      {
         this.dataLoading.visible = param1;
         this.tile.visible = !param1;
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
   }
}


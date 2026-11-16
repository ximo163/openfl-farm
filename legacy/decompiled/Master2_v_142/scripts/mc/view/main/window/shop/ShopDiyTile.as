package mc.view.main.window.shop
{
   import com.minutes.ui.collections.LipiTile2;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.WindowControl.WindowClassLib;
   
   public class ShopDiyTile extends Sprite
   {
      
      private var alertTxt2:TextField = new TextField();
      
      private var dataLoading:DataLoading;
      
      private var tile:LipiTile2;
      
      private var alertTxt3:TextField = new TextField();
      
      public function ShopDiyTile()
      {
         var _loc1_:TextFormat = null;
         super();
         this.tile = new LipiTile2(ShopDiyItem,2,222,180 + 30,20,0);
         this.tile.y = 25;
         this.tile.width = 473;
         this.tile.height = 278 + 30;
         this.tile.bgAlpha = 0;
         this.tile.addEventListener(ViewEvent.CHILD_CLICK,this.tileChildClick);
         addChild(this.tile);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = this.tile.width / 2;
         this.dataLoading.y = this.tile.height / 2;
         addChild(this.dataLoading);
         _loc1_ = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         this.alertTxt2.backgroundColor = 16777176;
         this.alertTxt2.background = true;
         this.alertTxt2.width = 478;
         this.alertTxt2.height = 18;
         this.alertTxt2.selectable = false;
         addChild(this.alertTxt2);
         this.alertTxt2.defaultTextFormat = _loc1_;
         this.alertTxt2.htmlText = "购买牧场装饰，打造属于自己的个性化牧场。";
         _loc1_ = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"left");
         this.alertTxt3.width = 100;
         this.alertTxt3.height = 18;
         this.alertTxt3.y = 302 + 30;
         this.alertTxt3.x = 12;
         this.alertTxt3.selectable = false;
         addChild(this.alertTxt3);
         this.alertTxt3.defaultTextFormat = _loc1_;
         this.alertTxt3.htmlText = "<a href=\'event:a\'><b>查看我的装饰</b</a>";
         this.alertTxt3.addEventListener(MouseEvent.CLICK,this.openMyDiyWindow);
      }
      
      public function get dataList() : Array
      {
         return this.tile.dataList;
      }
      
      public function updateShopDiyTile(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:ShopDiyItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.tile)
         {
            _loc2_ = this.tile.numChildren;
            _loc3_ = int(param1.length);
            _loc6_ = 0;
            while(_loc6_ < _loc2_)
            {
               _loc4_ = this.tile.getChildAt(_loc6_) as ShopDiyItem;
               _loc5_ = int(_loc4_.data["itemId"]);
               _loc7_ = 0;
               while(_loc7_ < _loc3_)
               {
                  if(param1[_loc7_]["itemId"] == _loc5_)
                  {
                     _loc4_.updateHaveBuyIcon(true);
                     break;
                  }
                  _loc7_++;
               }
               _loc6_++;
            }
         }
      }
      
      public function set errText(param1:String) : void
      {
         this.dataLoading.errorText = param1;
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
      
      public function set dataList(param1:Array) : void
      {
         this.tile.dataList = param1;
         setTimeout(this.tile.resetSize,200);
      }
      
      private function tileChildClick(param1:ViewEvent) : void
      {
         WindowClassLib.register("ShopDiyWindow",ShopDiyWindow);
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.OPEN);
         _loc2_.windowName = "ShopDiyWindow";
         _loc2_.windowArgument = param1.data;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function openMyDiyWindow(param1:MouseEvent) : void
      {
         WControl.openForName("diy",{"tabSelected":0});
         setTimeout(WControl.closeForName,0,"shop");
         if(!MData.getInstance().mainData.me)
         {
            Command.getInstance().mainCommand.setUser();
         }
      }
   }
}


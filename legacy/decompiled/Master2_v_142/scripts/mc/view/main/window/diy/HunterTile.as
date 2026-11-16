package mc.view.main.window.diy
{
   import com.minutes.ui.collections.LipiTile2;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.view.ViewEvent;
   import mc.view.common.ConfirmWindow;
   import mc.view.common.DataLoading;
   import mc.view.main.WindowControl.WControl;
   
   public class HunterTile extends Sprite
   {
      
      private var alertTxt2:TextField = new TextField();
      
      private var tile:LipiTile2;
      
      private var dataLoading:DataLoading;
      
      private var alertTxt3:TextField = new TextField();
      
      public function HunterTile()
      {
         super();
         this.tile = new LipiTile2(HunterItem,5,90,85,23,10);
         this.tile.y = 10;
         this.tile.width = 473;
         this.tile.height = 278;
         this.tile.bgAlpha = 0;
         this.tile.addEventListener(ViewEvent.CHILD_CLICK,this.tileChildClick);
         addChild(this.tile);
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.x = this.tile.width / 2;
         this.dataLoading.y = this.tile.height / 2;
         addChild(this.dataLoading);
      }
      
      public function set errText(param1:String) : void
      {
         this.dataLoading.errorText = param1;
      }
      
      public function get dataList() : Array
      {
         return this.tile.dataList;
      }
      
      private function setHide(param1:Object) : void
      {
         Command.getInstance().mainCommand.hideHunter(param1["itemId"]);
      }
      
      public function set loadingVisible(param1:Boolean) : void
      {
         this.dataLoading.visible = param1;
         this.tile.visible = !param1;
      }
      
      public function set dataList(param1:Array) : void
      {
         this.tile.dataList = param1;
         setTimeout(this.tile.resetSize,200);
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.data;
         dispatchEvent(_loc2_);
      }
      
      private function tileChildClick(param1:ViewEvent) : void
      {
         var cw:ConfirmWindow = null;
         var e:ViewEvent = param1;
         if(e.data["status"] != 1)
         {
            Command.getInstance().mainCommand.activeHunter(e.data["itemId"]);
         }
         else if(e.data["itemValidTime"] > 0)
         {
            cw = new ConfirmWindow();
            cw.data = {"text":"您的看守员当前还有剩余工资，隐藏看守员后，看守员将不再帮您看守牧场。是否现在隐藏？<br> <br>特别说明：隐藏看守员后依旧会正常消耗工资。"};
            cw.confirmFn = function():void
            {
               setHide(e.data);
            };
            WControl.open(cw);
         }
         else
         {
            this.setHide(e.data);
         }
      }
   }
}


package mc.view.main.window.profile
{
   import com.minutes.ui.collections.LipiTile2;
   import flash.display.Sprite;
   import flash.events.Event;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   import mc.view.main.tip.TipClassLib;
   import mc.view.main.tip.TipControl;
   
   public class ProfileHistory extends Sprite
   {
      
      public static var me:Boolean;
      
      private var mainData:MainData;
      
      private var dataLoading:DataLoading;
      
      private var tile:LipiTile2;
      
      public function ProfileHistory()
      {
         super();
         this.addEventListener(Event.ADDED_TO_STAGE,this.init);
         this.tile = new LipiTile2(HistoryItem,5,90,100);
         this.tile.addEventListener(LipiTile2.CHILD_OVER,this.onOver);
         this.tile.addEventListener(LipiTile2.CHILD_OUT,this.onOut);
         this.tile.x = 25;
         this.tile.y = 15;
         this.tile.bgAlpha = 0;
         this.tile.width = 460;
         this.tile.height = 210;
         addChild(this.tile);
         this.mainData = MData.getInstance().mainData;
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.visible = this.mainData.profileLoading;
         this.dataLoading.x = 230;
         this.dataLoading.y = 100;
         addChild(this.dataLoading);
      }
      
      public function get dataList() : Array
      {
         return this.tile.dataList;
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         var _loc2_:String = null;
         if(param1.data == "reload")
         {
            this.dataLoading.visible = true;
            _loc2_ = this.mainData.host["uId"];
            if(!me)
            {
               _loc2_ = this.mainData.currentUserId;
            }
            Command.getInstance().mainCommand.getHistoryInfo(this.getCostInfoFn,_loc2_);
         }
      }
      
      private function onOut(param1:ViewEvent) : void
      {
         TipControl.hide();
      }
      
      private function init(param1:Event) : void
      {
         this.dataLoading.visible = true;
         var _loc2_:String = this.mainData.host["uId"];
         if(!me)
         {
            _loc2_ = this.mainData.currentUserId;
         }
         Command.getInstance().mainCommand.getHistoryInfo(this.getCostInfoFn,_loc2_);
      }
      
      public function set dataList(param1:Array) : void
      {
         this.tile.dataList = param1;
      }
      
      private function getCostInfoFn(param1:Array) : void
      {
         if(param1)
         {
            this.dataLoading.visible = false;
            this.dataList = param1;
         }
         else
         {
            this.dataLoading.errorText = "系统繁忙！<a href=\'event:reload\'><u><font color=\'#ff6600\'>请重试</font></u></a>";
         }
      }
      
      private function onOver(param1:ViewEvent) : void
      {
         TipClassLib.register("HistoryTip",HistoryTip);
         TipControl.show("HistoryTip",param1.data);
      }
   }
}


package mc.view.farm.Research
{
   import common.INI;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.utils.setTimeout;
   import mc.view.common.BaseWindow;
   import mc.view.farm.GetCropID;
   import mc.view.main.cursor.Cursor;
   
   public class ResearchFirstOpen extends BaseWindow
   {
      
      private var _theBox:MovieClip;
      
      public function ResearchFirstOpen()
      {
         super();
         this.closeVisible = false;
         this.width = 0;
         this.height = 0;
         this.mode = true;
         this.visible = false;
         setTimeout(this.windowIn,500);
         this.addWindow();
      }
      
      private function closeClick(param1:MouseEvent) : void
      {
         this.closeHandler();
      }
      
      private function addWindow() : void
      {
         var _loc1_:Loader = new Loader();
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.winComplete);
         _loc1_.load(new URLRequest(GetCropID.addPrefix(String(INI.getInstance().data.updataDen.@firstOpen))));
      }
      
      private function winComplete(param1:Event) : void
      {
         this._theBox = param1.currentTarget.content as MovieClip;
         addChild(this._theBox);
         this._theBox.closeBtn.addEventListener(MouseEvent.CLICK,this.closeClick,false,0,true);
         this._theBox.shareBtn.addEventListener(MouseEvent.CLICK,this.shareClick,false,0,true);
      }
      
      private function shareClick(param1:MouseEvent) : void
      {
         ResearchModel.gi().shareHandler("","千呼万唤始出来~QQ牧场窝棚升级啦！还有科研新玩法！可以复活灭绝动物，培育新物种！","点击进入牧场>>【窝棚升级真开心！】","窝棚升级真开心",INI.getInstance().data.updataDen.@shareImg);
         this.closeHandler();
      }
      
      private function windowIn() : void
      {
         this.visible = true;
         Cursor.useSystem(true);
      }
   }
}


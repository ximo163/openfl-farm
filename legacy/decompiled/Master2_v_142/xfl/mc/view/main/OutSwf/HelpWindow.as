package mc.view.main.OutSwf
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import mc.control.Command;
   import mc.view.farm.GetCropID;
   
   public class HelpWindow extends Sprite
   {
      
      private var _helpLoader:Loader;
      
      public function HelpWindow()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAdded);
      }
      
      private function onAdded(param1:Event) : void
      {
         var _loc2_:Sprite = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         this._helpLoader = new Loader();
         this._helpLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioerror);
         this._helpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this._helpLoader.load(new URLRequest(GetCropID.getSwfUrl() + "main/outswf/help.swf"));
         addChild(this._helpLoader);
         if(stage != null)
         {
            _loc2_ = new Sprite();
            _loc2_.graphics.beginFill(16777215,0.3);
            _loc2_.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            _loc2_.graphics.endFill();
            addChildAt(_loc2_,0);
         }
      }
      
      private function ioerror(param1:IOErrorEvent) : void
      {
         trace("加载新手帮助错误");
      }
      
      private function onComplete(param1:Event) : void
      {
         var _loc2_:DisplayObject = null;
         _loc2_ = param1.currentTarget.content;
         _loc2_.x = Math.floor((stage.stageWidth - _loc2_.width) / 2);
         _loc2_.y = Math.floor((stage.stageHeight - _loc2_.height) / 2);
         _loc2_.addEventListener("closeEvent",this.helpCloseHandler,false,0,true);
      }
      
      private function helpCloseHandler(param1:Event) : void
      {
         if(parent != null)
         {
            Command.getInstance().mainCommand.welcomeEnd();
            parent.removeChild(this);
         }
      }
   }
}


package module.water
{
   import common.Consts;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import common.view.window.PostWindow;
   import events.CommonEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import framework.base.Controller;
   import module.GameGuide;
   
   public class WaterGrayOpen
   {
      
      private var _container:DisplayObjectContainer;
      
      private var _board:MovieClip;
      
      private var _loader:Loader;
      
      private var _controller:Controller;
      
      private var _tutorial:PostWindow;
      
      public function WaterGrayOpen(param1:Controller, param2:DisplayObjectContainer)
      {
         super();
         this._controller = param1;
         this._container = param2;
      }
      
      private function onNPCRollOver(param1:MouseEvent) : void
      {
         this._controller.useSystemCursor(true);
      }
      
      private function onWaterOpened(param1:CommonEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         param1.target.removeEventListener(WaterModel.EVENT_WATER_OPENED,this.onWaterOpened);
         if(param1.data == null)
         {
            _loc2_ = Settings.getInstance().getStringAttribute("fishTutorial");
            if(_loc2_ != null && _loc2_ != "")
            {
               _loc2_ = Settings.getInstance().replaceAppImg(_loc2_);
               if(this._tutorial == null)
               {
                  this._tutorial = new PostWindow(null,"",null,true);
                  this._tutorial.title = "池塘成功开启";
                  this._tutorial.fixSize = false;
                  this._tutorial.imgUrl = _loc2_;
                  this._tutorial.closeFn = this.onTutorialClosed;
               }
               this._controller.module.app.farmView.winCtrl.open(this._tutorial);
            }
            Session.getInstance().m_waterPoolOpen = true;
            this._controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_POOL_OPEN,true));
            if(this._board != null && this._board.parent != null)
            {
               this._board.parent.removeChild(this._board);
               this._board = null;
            }
         }
         else
         {
            _loc3_ = param1.data as String;
            if(_loc3_ == null || _loc3_ == "")
            {
               _loc3_ = "对不起，服务器返回失败，请稍后再试。";
            }
            _loc4_ = {
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc3_
            };
            this._controller.module.app.openWindowByName(Consts.WINDOW_NAME_ALERT,_loc4_);
         }
      }
      
      public function set myHome(param1:Boolean) : void
      {
         if(this._board != null)
         {
            this._board.visible = param1;
         }
         if(this._loader != null)
         {
            this._loader.visible = param1;
         }
      }
      
      private function onTutorialClosed(param1:Event) : void
      {
         GameGuide.toggle_water = true;
         GameGuide.instance().showStep(GameGuide.WATER_SHOP_ICON);
         GameGuide.instance().autoHide(8);
      }
      
      private function onNPCRollOut(param1:MouseEvent) : void
      {
         this._controller.useSystemCursor(false);
      }
      
      private function onClickOpen(param1:MouseEvent) : void
      {
         (this._controller as WaterController).model.openWater();
         (this._controller as WaterController).model.addEventListener(WaterModel.EVENT_WATER_OPENED,this.onWaterOpened);
      }
      
      public function set flag(param1:Boolean) : void
      {
         var img:String = null;
         var w:Boolean = param1;
         if(this._container == null)
         {
            return;
         }
         if(w == true)
         {
            if(this._board == null)
            {
               this._board = Utils.getMaterial("WaterOpenBoard") as MovieClip;
            }
            this._board.x = 214;
            this._board.y = 80;
            this._board.buttonMode = true;
            this._container.addChild(this._board);
            this._board.addEventListener(MouseEvent.CLICK,this.onClickOpen,false,0,true);
            this._board.addEventListener(MouseEvent.ROLL_OVER,this.onNPCRollOver,false,0,true);
            this._board.addEventListener(MouseEvent.ROLL_OUT,this.onNPCRollOut,false,0,true);
            if(this._loader != null && this._container.contains(this._loader) == true)
            {
               this._loader.removeChild(this._loader);
            }
         }
         else
         {
            if(this._loader != null)
            {
               this._loader.visible = true;
               this._container.addChild(this._loader);
               return;
            }
            img = Settings.getInstance().getSecondUrl("fishNPC");
            if(img == null || img == "")
            {
               return;
            }
            this._loader = new Loader();
            this._loader.x = 260;
            this._loader.y = -114;
            this._container.addChild(this._loader);
            this._loader.load(new URLRequest(img));
            this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):void
            {
               _loader.addEventListener(MouseEvent.CLICK,onClickNPC,false,0,true);
               _loader.addEventListener(MouseEvent.ROLL_OVER,onNPCRollOver,false,0,true);
               _loader.addEventListener(MouseEvent.ROLL_OUT,onNPCRollOut,false,0,true);
            });
         }
      }
      
      private function onClickNPC(param1:MouseEvent) : void
      {
         var _loc2_:String = Settings.getInstance().getStringAttribute("fishNPC");
         if(_loc2_ == null || _loc2_ == "")
         {
            return;
         }
         navigateToURL(new URLRequest(_loc2_),"_blank");
      }
   }
}


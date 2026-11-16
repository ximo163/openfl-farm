package mc.view.farm.land
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.corelib.js.JSProxy;
   import common.CommonData;
   import common.INI;
   import common.LocalData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import mc.model.MData;
   import mc.view.farm.GetCropID;
   import mc.view.main.cursor.Cursor;
   import mc.view.proxy.GameProxy;
   
   public class NPContainer extends Sprite
   {
      
      private var _holder:Sprite;
      
      public function NPContainer()
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         super();
         GameProxy.npcLand = this;
         GameProxy.getInstance().addEventListener(GameProxy.CURRENT_USER_CHANGE,this.onUserChanged);
         var _loc1_:String = String(INI.getInstance().data.a361);
         if(_loc1_ != null && _loc1_ != "")
         {
            _loc2_ = _loc1_.split("-");
            _loc3_ = CommonData.serverTime * 1000;
            _loc4_ = new Date(_loc2_[0]);
            _loc5_ = new Date(_loc2_[1]);
            if(_loc3_ >= _loc4_.time && _loc3_ <= _loc5_.time)
            {
               this.loadAdvertiseIcon("module/ui/361.swf");
            }
         }
      }
      
      public function addNPC(param1:DisplayObject, param2:Number = 0, param3:Number = 0) : void
      {
         if(this._holder == null)
         {
            this._holder = new Sprite();
            this._holder.x = param2;
            this._holder.y = param3;
            addChild(this._holder);
            this._holder.addChild(param1);
         }
      }
      
      private function loadAdvertiseIcon(param1:String) : void
      {
         var loader:Loader;
         var loadComplete:Function = null;
         var errorHandler:Function = null;
         var on361:Function = null;
         var on361Over:Function = null;
         var on361Out:Function = null;
         var url:String = param1;
         loadComplete = function(param1:Event):void
         {
            var _loc2_:DisplayObject = null;
            if(param1.target is LoaderInfo)
            {
               _loc2_ = (param1.target as LoaderInfo).content;
            }
            if(_loc2_ == null)
            {
               return;
            }
            _loc2_.x = 100;
            _loc2_.y = 580;
            addChild(_loc2_);
            _loc2_.addEventListener(MouseEvent.CLICK,on361,false,0,true);
            _loc2_.addEventListener(MouseEvent.MOUSE_OVER,on361Over,false,0,true);
            _loc2_.addEventListener(MouseEvent.MOUSE_OUT,on361Out,false,0,true);
         };
         errorHandler = function(param1:IOErrorEvent):void
         {
         };
         on361 = function(param1:MouseEvent):void
         {
            var _loc2_:String = "";
            if(LocalData.mode == "qzone" || LocalData.xymode == "qq.com")
            {
               _loc2_ = "";
            }
            JSProxy.addCallBackProxy("getGiftBack",on361Callback);
            ExternalInterface.call("QZFL.dialog.create(\'\'," + "\'<iframe src=" + _loc2_ + "&id=1" + " style=\"width:570px; height:460px; border:0px\" scrolling=no border=0 frameBorder=no allowTransparency=true></iframe>\', {width:570,height:460,noBorder:true})");
            ClickReportManager.reportClick("361_Click_Icon_MC");
         };
         on361Over = function(param1:MouseEvent):void
         {
            Cursor.useSystem(true);
         };
         on361Out = function(param1:MouseEvent):void
         {
            Cursor.useSystem(false);
         };
         if(url == "" || url == null)
         {
            return;
         }
         url = GetCropID.addPrefix(url);
         loader = new Loader();
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR,errorHandler);
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
         loader.load(new URLRequest(url),new LoaderContext(true,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
      }
      
      private function on361Callback(param1:*) : void
      {
         if(param1 as Boolean == true)
         {
            MData.getInstance().farmData.reloadUserSeed = true;
         }
      }
      
      private function onUserChanged(param1:Event) : void
      {
         var _loc2_:GameProxy = GameProxy.getInstance();
         if(this._holder != null)
         {
            if(_loc2_.me == true)
            {
               this._holder.visible = true;
            }
            else
            {
               this._holder.visible = false;
            }
         }
      }
   }
}


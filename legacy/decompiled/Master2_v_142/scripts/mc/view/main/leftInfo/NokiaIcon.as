package mc.view.main.leftInfo
{
   import com.qzone.allianceActivity.framewrok.manager.ClickReportManager;
   import com.qzone.corelib.js.JSProxy;
   import com.qzone.qui.managers.PopUpManager;
   import common.INI;
   import common.MaterialLib;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.model.MData;
   import mc.view.farm.GetCropID;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.main.tip.TipControl;
   
   public class NokiaIcon extends ToolBase
   {
      
      private var _fr:FRequest;
      
      private var _adopted:Boolean;
      
      private var _win:MovieClip;
      
      private var _icon:MovieClip;
      
      public function NokiaIcon()
      {
         super();
         buttonMode = true;
         useHandCursor = true;
         this._fr = FRequest.getInstance();
         this._adopted = false;
         var _loc1_:String = GetCropID.addPrefix(String(INI.getInstance().data.nokia));
         var _loc2_:Loader = new Loader();
         _loc2_.load(new URLRequest(_loc1_),new LoaderContext(false,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete,false,0,true);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError,false,0,true);
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.beginFill(0,0);
         _loc3_.graphics.drawRect(0,0,40,34);
         _loc3_.graphics.endFill();
         addChild(_loc3_);
         ClickReportManager.reportPv();
      }
      
      private function onError(param1:Event) : void
      {
         ClickReportManager.reportClick("NOKIA_LOAD_ERROR");
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip","诺基亚 Lumia非凡系列");
      }
      
      private function onCloseWin(param1:MouseEvent) : void
      {
         if(this._win != null)
         {
            PopUpManager.removePopUp(this._win);
         }
      }
      
      private function onInitInfo(param1:Object) : void
      {
         if(Boolean(param1) && param1["ecode"] == 0)
         {
            if(param1["login"]["count"] != 0)
            {
               this._adopted = false;
               this.enableMc(this._win["btnAdopt"],true);
            }
            else
            {
               this._adopted = true;
            }
         }
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         JSProxy.openWindow("http://c.l.qq.com/lclick?seq=20120511000088&loc=hdjc");
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this._win == null)
         {
            this._win = MaterialLib.getInstance().getMaterial("NokiaMainWindow") as MovieClip;
            this._win["btnClose"].addEventListener(MouseEvent.CLICK,this.onCloseWin,false,0,true);
            this._win["btnAdopt"].addEventListener(MouseEvent.CLICK,this.onAdopt,false,0,true);
            this._win["btnShare"].addEventListener(MouseEvent.CLICK,this.onShare,false,0,true);
            this.enableMc(this._win["btnAdopt"],false);
            this._fr.postRequest(JSProxy.addGToken("gift_info"),{
               "appid":358,
               "types":2,
               "cb":0,
               "hformat":0
            },this.onInitInfo);
         }
         PopUpManager.addPopUp(this._win,true);
         ClickReportManager.reportClick("NOKIA_CLICK_ICON");
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function onAdopt(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.enableMc(this._win["btnAdopt"],false);
         ClickReportManager.reportClick("NOKIA_CLICK_ADOPT");
         this._fr.postRequest(JSProxy.addGToken("gift_send"),{
            "appid":358,
            "type":2,
            "cb":0,
            "hformat":0
         },function(param1:Object):void
         {
            if(Boolean(param1) && param1["ecode"] == 0)
            {
               _adopted = true;
               enableMc(_win["btnAdopt"],false);
               Command.getInstance().mainCommand.floatWindow("您获得了辣辣狗一只，已放入您的背包中。");
               MData.getInstance().farmData.reloadUserSeed = true;
            }
            else
            {
               Command.getInstance().mainCommand.alertWindow("error","领取奖励失败，请稍后再试！");
               enableMc(_win["btnAdopt"],true);
            }
         });
      }
      
      private function onComplete(param1:Event) : void
      {
         this._icon = MaterialLib.getInstance().getMaterial("NokiaIcon") as MovieClip;
         this._icon.stop();
         this._icon.x = 6;
         this._icon.y = -1;
         addChild(this._icon);
         this._icon.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this._icon.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         this._icon.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
      }
      
      private function enableMc(param1:InteractiveObject, param2:Boolean) : void
      {
         if(param1 != null)
         {
            if(param2 == true)
            {
               param1.mouseEnabled = true;
               param1.filters = [];
            }
            else
            {
               param1.mouseEnabled = false;
               param1.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
         }
      }
   }
}


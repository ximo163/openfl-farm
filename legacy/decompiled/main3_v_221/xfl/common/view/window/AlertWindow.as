package common.view.window
{
   import com.qzone.corelib.controls.ExtLoader;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.core.Align;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import framework.api.beast.BeastAPI;
   import interfaces.IMsgCenter;
   
   public class AlertWindow extends BaseWindow
   {
      
      private var _alertText:TextField;
      
      private var _textLinkHandle:Function;
      
      private var _confirmButton:Button;
      
      private var _icon:Sprite;
      
      private var _confirmButtonClickHandle:Function;
      
      private var _picLoader:ExtLoader;
      
      public function AlertWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 320;
         height = 240;
         title = "提示";
         windowName = Consts.WINDOW_NAME_ALERT;
         mode = true;
         this._alertText = null;
         this._confirmButton = null;
         this._icon = null;
      }
      
      public function set textLinkHandle(param1:Function) : void
      {
         this._textLinkHandle = param1;
      }
      
      override protected function setData() : void
      {
         var _loc1_:TextFormat = null;
         if(data == null)
         {
            return;
         }
         this.graphics.clear();
         if(data["width"] != undefined)
         {
            this.width = data["width"] as int;
            this._alertText.width = this.width - 20;
         }
         else
         {
            this.width = 320;
            this._alertText.width = this.width - 20;
         }
         if(data["height"] != undefined)
         {
            this.height = data["height"] as int;
         }
         else
         {
            this.height = 240;
         }
         if(data["textAlign"] != undefined)
         {
            _loc1_ = new TextFormat("Verdana",14,3355443,null,null,null,null,null);
            _loc1_.leading = 6;
            _loc1_.align = data["textAlign"];
            this._alertText.defaultTextFormat = _loc1_;
         }
         this.createIcon();
         this.createPic();
         if(data["type"] == Consts.ALERT_TYPE_SUCCESS || data["type"] == Consts.ALERT_TYPE_ERROR || data["type"] == Consts.ALERT_TYPE_TIP)
         {
            if(this._icon != null)
            {
               this._icon.visible = true;
            }
            this._alertText.y = 110;
            if(this._picLoader)
            {
               this._picLoader.visible = false;
            }
         }
         else if(data["type"] == Consts.ALERT_TYPE_TEXT)
         {
            if(this._icon != null)
            {
               this._icon.visible = false;
            }
            this._alertText.y = 35;
            if(this._picLoader)
            {
               this._picLoader.visible = false;
            }
         }
         else if(data["type"] == Consts.ALERT_TYPE_PIC)
         {
            if(this._icon != null)
            {
               this._icon.visible = false;
            }
            this._alertText.y = 113;
            if(this._picLoader)
            {
               this._picLoader.visible = true;
            }
         }
         else if(data["type"] == Consts.ALERT_TYPE_PIC2)
         {
            if(this._icon != null)
            {
               this._icon.visible = false;
            }
            this._alertText.y = 140;
            if(this._picLoader)
            {
               this._picLoader.visible = true;
            }
         }
         else
         {
            if(this._icon != null)
            {
               this._icon.visible = false;
            }
            this._alertText.y = 110;
            if(this._picLoader)
            {
               this._picLoader.visible = false;
            }
         }
         if(data["text"] != undefined)
         {
            this._alertText.htmlText = data["text"];
            this._alertText.width = width - 40;
            this._alertText.height = this._alertText.textHeight + 10;
            if(data["height"] == undefined)
            {
               this.height = this._alertText.height + this._alertText.y + 60;
            }
            this._alertText.x = (width - this._alertText.width) / 2;
         }
         if(data["title"] != undefined)
         {
            title = data["title"];
         }
         else
         {
            title = "提示";
         }
         if(data["textLinkHandle"] != undefined)
         {
            this._textLinkHandle = data["textLinkHandle"] as Function;
         }
         else
         {
            this._textLinkHandle = null;
         }
         if(data["confirmButtonClickHandle"] != undefined)
         {
            this._confirmButtonClickHandle = data["confirmButtonClickHandle"] as Function;
         }
         else
         {
            this._confirmButtonClickHandle = null;
         }
         if(data["textSelectable"] != undefined)
         {
            this._alertText.selectable = data["textSelectable"] as Boolean;
         }
         else
         {
            this._alertText.selectable = false;
         }
         if(data["buttonText"] != undefined)
         {
            this._confirmButton.text = data["buttonText"];
         }
         this._confirmButton.x = (this.width - this._confirmButton.width) / 2;
         this._confirmButton.y = this.height - this._confirmButton.height - 15;
         this._confirmButton.visible = true;
         if(titleAlign == Align.CENTER)
         {
            panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
         }
      }
      
      private function alertTextLink(param1:TextEvent) : void
      {
         if(this._textLinkHandle != null)
         {
            this._textLinkHandle(param1);
         }
         if(param1.text == "gotoWild")
         {
            BeastAPI.getInstance().showWildStage();
         }
         else if(param1.text == "wildInfo")
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("window.open","http://blog.qq.com/qzone/1006666002/1293072967.htm");
            }
         }
         else if(ExternalInterface.available)
         {
            ExternalInterface.call("window.open",param1.text);
         }
      }
      
      private function createIcon() : void
      {
         if(data == null)
         {
            return;
         }
         if(data["type"] == Consts.ALERT_TYPE_SUCCESS)
         {
            this._icon = Utils.getMaterial("SuccessIcon") as Sprite;
         }
         else if(data["type"] == Consts.ALERT_TYPE_ERROR)
         {
            this._icon = Utils.getMaterial("ErrorIcon") as Sprite;
         }
         else
         {
            if(data["type"] != Consts.ALERT_TYPE_TIP)
            {
               return;
            }
            this._icon = Utils.getMaterial("TipIcon") as Sprite;
         }
         this._icon.x = AlignUtil.middle(width,this._icon.width);
         this._icon.y = 40;
         addChild(this._icon);
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         super.close();
         if(data["gotourl"] != undefined && data["gotourl"] != "")
         {
            navigateToURL(new URLRequest(data["gotourl"]),"_blank");
         }
         if(data["confirmButtonClickHandle"] != null)
         {
            this._confirmButtonClickHandle();
         }
      }
      
      override protected function init() : void
      {
         this._alertText = new TextField();
         this._alertText.selectable = false;
         var _loc1_:TextFormat = new TextFormat("Verdana",14,3355443,null,null,null,null,null,TextFormatAlign.CENTER);
         _loc1_.leading = 8;
         this._alertText.defaultTextFormat = _loc1_;
         this._alertText.wordWrap = true;
         this._alertText.multiline = true;
         this._alertText.mouseWheelEnabled = false;
         this._alertText.addEventListener(TextEvent.LINK,this.alertTextLink,false,0,true);
         addChild(this._alertText);
         this._confirmButton = new Button();
         this._confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         this._confirmButton.width = 65;
         this._confirmButton.height = 25;
         this._confirmButton.text = "确定";
         this._confirmButton.visible = false;
         this._confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this._confirmButton);
      }
      
      override public function keyEnter(param1:KeyboardEvent) : void
      {
         this.confirmButtonClick(null);
      }
      
      private function createPic() : void
      {
         if(data["type"] != Consts.ALERT_TYPE_PIC && data["type"] != Consts.ALERT_TYPE_PIC2)
         {
            return;
         }
         this._picLoader = new ExtLoader();
         if(data["type"] != Consts.ALERT_TYPE_PIC2)
         {
            this._picLoader.x = AlignUtil.middle(width,346);
         }
         else
         {
            this._picLoader.x = AlignUtil.middle(width,80);
         }
         this._picLoader.y = 35;
         this._picLoader.load(data["picUrl"]);
         addChild(this._picLoader);
      }
      
      override protected function close() : void
      {
         super.close();
         if(data["confirmButtonClickHandle"] != null)
         {
            this._confirmButtonClickHandle();
         }
      }
   }
}


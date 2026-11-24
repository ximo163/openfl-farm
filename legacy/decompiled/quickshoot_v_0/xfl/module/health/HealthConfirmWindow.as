package module.health
{
   import com.qzone.qui.controls.Button;
   import common.Language;
   import common.misc.Utils;
   import common.view.window.ConfirmWindow;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   
   public class HealthConfirmWindow extends ConfirmWindow
   {
      
      public function HealthConfirmWindow(param1:IMsgCenter)
      {
         super(param1);
         title = Language.L["HM_TITLE"];
         windowName = "__INNER_WINDOW_HEALTH_CONFIRM__";
         mode = true;
         _hideIcon = true;
         _confirmEnable = true;
         _confirmFn = null;
      }
      
      override protected function init() : void
      {
         _confirmButton = new Button();
         _confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         _confirmButton.width = 64;
         _confirmButton.height = 25;
         _confirmButton.x = width / 2 - _confirmButton.width - 10;
         _confirmButton.y = height - 45;
         _confirmButton.text = "确定";
         _confirmButton.addEventListener(MouseEvent.CLICK,confirmButtonClick);
         addChild(_confirmButton);
         _cancelButton = new Button();
         _cancelButton.defaultSkin = Utils.getClass("ButtonBlue");
         _cancelButton.width = 64;
         _cancelButton.height = 25;
         _cancelButton.x = width / 2 + 10;
         _cancelButton.y = height - 45;
         _cancelButton.text = "取消";
         _cancelButton.addEventListener(MouseEvent.CLICK,cancelButtonClick);
         addChild(_cancelButton);
      }
      
      override protected function setData() : void
      {
         var _loc1_:TextFormat = null;
         var _loc2_:TextFormat = null;
         if(data != null)
         {
            if(_alertText == null)
            {
               _alertText = new TextField();
               _alertText.selectable = false;
               _loc1_ = new TextFormat("Verdana",14,3355443,null,null,null,null,null,TextFormatAlign.CENTER);
               _loc1_.leading = 10;
               _alertText.defaultTextFormat = _loc1_;
               _alertText.width = width - 18;
               _alertText.height = 80;
               _alertText.wordWrap = true;
               _alertText.multiline = true;
               addChild(_alertText);
            }
            if(!_alertText.parent)
            {
               _alertText.autoSize = TextFieldAutoSize.LEFT;
               _alertText.selectable = false;
               _loc2_ = new TextFormat("Verdana",14,3355443,null,null,null,null,null,TextFormatAlign.CENTER);
               _loc2_.leading = 10;
               _alertText.defaultTextFormat = _loc2_;
               _alertText.width = width - 18;
               _alertText.wordWrap = true;
               _alertText.multiline = true;
               addChild(_alertText);
            }
            if(data["text"] != undefined)
            {
               _alertText.htmlText = data["text"] || "";
               _alertText.height = _alertText.textHeight + 10;
               _alertText.x = (width - _alertText.width) / 2;
            }
            if(data["confirmFn"] != undefined)
            {
               _confirmFn = data["confirmFn"] as Function;
            }
            else
            {
               _confirmFn = null;
            }
         }
         if(_confirmButton != null)
         {
            _confirmButton.enabled = confirmEnable;
         }
      }
   }
}


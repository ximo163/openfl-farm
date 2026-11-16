package common.view.window
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.core.Align;
   import com.qzone.utils.AlignUtil;
   import common.CommonData;
   import common.Consts;
   import common.Settings;
   import common.misc.Utils;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import framework.net.core.RequestChecker;
   import interfaces.IMsgCenter;
   import report.EventRecorder;
   
   public class RequestErrorWindow extends BaseWindow
   {
      
      private var m_info:String;
      
      private var m_okButton:Button;
      
      private var m_img:Bitmap;
      
      private var m_lbInfo:TextField;
      
      private var m_imgName:String;
      
      public function RequestErrorWindow(param1:IMsgCenter = null)
      {
         super(param1);
         width = 390;
         height = 310;
         windowName = Consts.WINDOW_NAME_REQUEST_ERROR;
         this.m_info = "";
         this.m_img = null;
         this.m_imgName = "";
         this.m_lbInfo = null;
         this.m_okButton = null;
      }
      
      private function onImageLoaded() : void
      {
         var _loc1_:Class = Utils.getClass(this.m_imgName);
         if(_loc1_ == null)
         {
            return;
         }
         if(this.m_img != null && this.m_img.parent != null)
         {
            removeChild(this.m_img);
         }
         var _loc2_:DisplayObject = getChildByName("__error__");
         if(_loc2_ != null)
         {
            removeChild(_loc2_);
         }
         this.m_img = new Bitmap(new _loc1_(270,125) as BitmapData);
         this.m_img.x = AlignUtil.middle(width,this.m_img.width);
         this.m_img.y = 100;
         addChild(this.m_img);
         EventRecorder.recordErrorEvent(EventRecorder.HF_SNOW,0,EventRecorder.SUEECSS,"BlizzardError");
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         super.close();
      }
      
      protected function defaultError(param1:String = "ErrorIcon") : void
      {
         title = "提示";
         if(titleAlign == Align.CENTER)
         {
            panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
         }
         else
         {
            panelTitle.x = 4;
         }
         if(this.m_img != null && this.m_img.parent != null)
         {
            removeChild(this.m_img);
         }
         var _loc2_:Sprite = Utils.getMaterial(param1) as Sprite;
         _loc2_.x = (width - _loc2_.width) / 2;
         _loc2_.y = 50;
         _loc2_.name = "__error__";
         addChild(_loc2_);
         this.m_lbInfo.y = 150;
         height = 250;
         this.m_okButton.x = width / 2 - this.m_okButton.width / 2;
         this.m_okButton.y = height - 45;
      }
      
      override protected function init() : void
      {
         var _loc1_:TextFormat = null;
         if(this.m_lbInfo == null)
         {
            this.m_lbInfo = new TextField();
            this.m_lbInfo.selectable = false;
            this.m_lbInfo.autoSize = TextFieldAutoSize.LEFT;
            this.m_lbInfo.multiline = true;
            this.m_lbInfo.x = 20;
            this.m_lbInfo.y = 45;
            addChild(this.m_lbInfo);
            _loc1_ = new TextFormat("Verdana",14,6710886);
            _loc1_.leading = 6;
            this.m_lbInfo.defaultTextFormat = _loc1_;
         }
         if(this.m_info != "")
         {
            this.m_lbInfo.htmlText = this.m_info;
            this.m_lbInfo.x = AlignUtil.middle(width,this.m_lbInfo.width);
         }
         if(this.m_okButton == null)
         {
            this.m_okButton = new Button();
            this.m_okButton.defaultSkin = Utils.getClass("ButtonOrange");
            this.m_okButton.width = 65;
            this.m_okButton.height = 25;
            this.m_okButton.addEventListener(MouseEvent.CLICK,this.onOK);
            this.m_okButton.text = "确定";
            this.m_okButton.x = width / 2 - this.m_okButton.width / 2;
            this.m_okButton.y = height - 45;
            addChild(this.m_okButton);
         }
      }
      
      public function set errorUrl(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.m_imgName = "";
         if(RequestChecker.checkRequest(param1) == false)
         {
            _loc2_ = RequestChecker.getInofByUrl(param1);
            if(_loc2_ != null)
            {
               title = "温馨提示";
               if(param1.indexOf("harvest") != -1)
               {
                  if(_loc2_["showed"] == false)
                  {
                     this.m_info = "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color=\'#ff9900\'>" + _loc2_["limitMinute"] + "</font>分钟后才会返回，暂时无法收获果实。";
                     this.m_imgName = "RequestErrorBG";
                  }
                  else
                  {
                     this.m_info = "您还不可以进行收获操作，可以等一会儿再试。";
                     this.defaultError("TipIcon");
                  }
               }
               else if(param1.indexOf("scrounge") != -1)
               {
                  if(_loc2_["showed"] == false)
                  {
                     this.m_info = "抱歉，您的准摘证已过期。村委会需要花<font color=\'#ff9900\'>" + _loc2_["limitMinute"] + "</font>分钟为您重<br/>新办理，办理完毕之前您没有权限摘取好友的果实。";
                     this.m_imgName = "RequestErrorZZ";
                  }
                  else
                  {
                     this.m_info = "您还不可以进行摘取操作，可以等一会儿再试。";
                     this.defaultError("TipIcon");
                  }
               }
               else if(param1.indexOf("planting") != -1)
               {
                  if(_loc2_["showed"] == false)
                  {
                     this.m_info = "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color=\'#ff9900\'>" + _loc2_["limitMinute"] + "</font>分钟后才会返回，暂时无法耕种田地。";
                     this.m_imgName = "RequestErrorBG";
                  }
                  else
                  {
                     this.m_info = " 您还不可以进行种植操作，可以等一会儿再试。";
                     this.defaultError("TipIcon");
                  }
               }
               else if(param1.indexOf("scarify") != -1)
               {
                  if(_loc2_["showed"] == false)
                  {
                     this.m_info = "和平天使降临，农场一片祥和宁静。大使感召您花<font color=\'#ff9900\'>" + _loc2_["limitMinute"] + "</font>分<br/>钟和她一起祈祷世界和平，此期间需要您停止翻地。";
                     this.m_imgName = "RequestErrorHP";
                  }
                  else
                  {
                     this.m_info = "您还不可以进行翻地操作，可以等一会儿再试。";
                     this.defaultError("TipIcon");
                  }
               }
               else if(param1.indexOf("cgi_farm_index") != -1)
               {
                  if(_loc2_["showed"] == false)
                  {
                     this.m_info = "2012即将到来，黎明前的黑暗总是恐怖的，您被限制访问<br/>该好友的农场<font color=\'#ff9900\'>" + _loc2_["limitMinute"] + "</font>分钟。诺亚方舟即将建成，等待希望的出现吧！";
                     this.m_imgName = "RequestErrorFZ";
                  }
                  else
                  {
                     this.m_info = "您还不可以访问该好友，可以等一会儿再试。";
                     this.defaultError("TipIcon");
                  }
               }
               else
               {
                  this.m_info = "请求失败，请稍后再试。";
                  width = 320;
                  this.defaultError();
               }
               if(this.m_imgName != "")
               {
                  _loc3_ = "RequestErrorBG";
                  param1 = Settings.getInstance().getSecondUrl(_loc3_);
                  CommonData.rslManager.requestClass(_loc3_,this.onImageLoaded,param1);
               }
               _loc2_["showed"] = true;
               return;
            }
         }
         this.m_info = "请求失败，请稍后再试。";
         width = 320;
         this.defaultError();
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         this.errorUrl = super.data["url"] as String;
         if(this.m_info != "")
         {
            this.m_lbInfo.htmlText = this.m_info;
            this.m_lbInfo.x = AlignUtil.middle(width,this.m_lbInfo.width);
         }
      }
   }
}


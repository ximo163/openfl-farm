package module.messages.widgets
{
   import com.qzone.qui.controls.TextArea;
   import com.qzone.utils.StringUtil;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import module.messages.MessageView;
   
   public class ProfileLog extends Sprite
   {
      
      private var _log:TextArea;
      
      private var _parent:MessageView;
      
      private var _delAll:TextField;
      
      public function ProfileLog(param1:MessageView)
      {
         super();
         this._parent = param1;
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.lineStyle(1,16777215);
         _loc2_.graphics.moveTo(0,0);
         _loc2_.graphics.lineTo(490,0);
         _loc2_.y = 195;
         _loc2_.x = 3;
         addChild(_loc2_);
         this._log = new TextArea();
         this._log.width = 470;
         this._log.height = 190;
         this._log.x = 20;
         this._log.y = 2;
         this._log.defaultSkin = null;
         this._log.selectedSkin = null;
         this._log.readOnly = true;
         this._log.textField.addEventListener(TextEvent.LINK,this.onLinkClicked);
         addChild(this._log);
         this._delAll = new TextField();
         this._delAll.autoSize = TextFieldAutoSize.LEFT;
         this._delAll.selectable = false;
         this._delAll.defaultTextFormat = new TextFormat("Verdana",null,39423);
         this._delAll.htmlText = "<a href=\'event:del\'>" + Language.L["清空消息记录"] + "</a>";
         this._delAll.addEventListener(TextEvent.LINK,this.onDeleteAll);
         this._delAll.x = 30;
         this._delAll.y = 180 + 18;
         addChild(this._delAll);
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:int = Math.abs(param2.getTime() - param1.getTime());
         return _loc3_ / 86400000;
      }
      
      private function delLogConfirm() : void
      {
         this._parent.controller.model.clearAllLog();
      }
      
      private function genMsgNewFeed(param1:Object) : String
      {
         var _loc17_:RegExp = null;
         var _loc18_:int = 0;
         var _loc2_:String = "";
         var _loc3_:String = param1["cn"] as String;
         var _loc4_:String = param1["opuin"];
         var _loc5_:String = param1["opuin"];
         var _loc6_:String = "";
         var _loc7_:String = "";
         var _loc8_:String = "";
         var _loc9_:Array = ["","空间","校友","微博"];
         var _loc10_:Settings = Settings.getInstance();
         var _loc11_:Session = Session.getInstance();
         if(_loc10_.mode == "qzone")
         {
            _loc9_[1] = "";
         }
         else
         {
            _loc9_[2] = "";
         }
         if(param1.hasOwnProperty("domain") == true)
         {
            if(param1["domain"] == 6)
            {
               param1["domain"] = 3;
            }
            _loc8_ = _loc9_[param1["domain"]];
         }
         _loc7_ = _loc8_ + _loc3_;
         var _loc12_:Boolean = this._parent.controller.model.me;
         if(_loc10_.mode == "qzone" && _loc12_ == true)
         {
            if(Boolean(param1["domain"] == 1) && Boolean(_loc4_) && _loc3_.indexOf("来农场摘取，摘走") > 0)
            {
               _loc11_.initFriendMap();
               if(_loc11_.friendsMap != null && !_loc11_.friendsMap[_loc4_])
               {
                  _loc17_ = RegExp("<b>(.*)</b>");
                  _loc6_ = _loc17_.exec(_loc3_)[1];
                  _loc7_ += "\t<a href=\'event:" + _loc5_ + "," + _loc6_ + "\'><font color=\'#0099FF\'>不让他摘</font></a>";
               }
            }
         }
         var _loc13_:Date = new Date(parseFloat(param1["t"]) * 1000);
         var _loc14_:String = this.twoData(_loc13_.getHours());
         var _loc15_:String = this.twoData(_loc13_.getMinutes());
         var _loc16_:String = "";
         if(Language.lang == Language.CN)
         {
            _loc18_ = this.compareDate(_loc13_,new Date());
            if(_loc18_ == 0)
            {
               _loc16_ = "    " + Language.L["今天"] + _loc14_ + ":" + _loc15_;
            }
            else if(_loc18_ == 1)
            {
               _loc16_ = "    " + Language.L["昨天"] + _loc14_ + ":" + _loc15_;
            }
            else if(_loc18_ == 2)
            {
               _loc16_ = "    " + Language.L["前天"] + _loc14_ + ":" + _loc15_;
            }
            else
            {
               _loc16_ = this.twoData(_loc13_.getMonth() + 1) + "-" + this.twoData(_loc13_.getDate()) + " " + _loc14_ + ":" + _loc15_;
            }
         }
         else
         {
            _loc16_ = this.twoData(_loc13_.getMonth() + 1) + "-" + this.twoData(_loc13_.getDate()) + " " + _loc14_ + ":" + _loc15_;
         }
         return "<b>" + _loc16_ + "</b>  " + _loc7_ + "<br>";
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         if(param1 == null || param1.text == "")
         {
            return;
         }
         var _loc2_:Array = param1.text.split(",");
         var _loc3_:uint = parseInt(_loc2_[0]);
         var _loc4_:String = _loc2_[1].toString();
         var _loc5_:String = "<p align=\'left\'><font color=\'#009900\'><b>";
         if(_loc4_ != null && _loc4_.length > 0)
         {
            _loc5_ += StringUtil.htmlEscape(_loc4_);
         }
         if(_loc3_ > 0)
         {
            _loc5_ += "(QQ:" + _loc3_ + ")";
         }
         var _loc6_:String = Settings.getInstance().getStringAttribute("filterUrl") || "http://blog.qq.com/qzone/1006666002/1300264199.htm";
         var _loc7_:String = Settings.getInstance().getStringAttribute("friendUrl") || "";
         _loc5_ += "</b></font> 可能不是您的好友，您可以进入“我的QQ中心”删除单向好友，" + "防止对方进入您的农/牧场进行摘取等操作。<br/>" + "<font color=\'#0000FF\'><u><b><a href=\'event:" + _loc7_ + "\' target=\'_blank\'>前往管理您的单向好友</a></b></u>。</font></p>" + "<p align=\'right\'><font color=\'#0000FF\'><u><a href=\'event:" + _loc6_ + "\' target=\'_blank\'>详细</a></u></font></p>";
         var _loc8_:* = {
            "textSelectable":true,
            "title":"友情提示",
            "width":380,
            "height":240,
            "text":_loc5_,
            "type":Consts.ALERT_TYPE_TEXT,
            "textLinkHandle":this.onAlertNaviagte
         };
         this._parent.controller.openWindow(Consts.WINDOW_NAME_ALERT,_loc8_);
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:* = undefined;
         this._delAll.visible = Session.getInstance().me ? true : false;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsgNewFeed(_loc3_);
         }
         this._log.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1.toString();
         }
         return param1.toString();
      }
      
      private function onDeleteAll(param1:TextEvent) : void
      {
         var _loc2_:* = {
            "title":Language.L["清空记录"],
            "text":Language.L["确认清空消息记录？"],
            "confirmFn":this.delLogConfirm
         };
         this._parent.controller.openWindow(Consts.WINDOW_NAME_CONFIRM,_loc2_);
      }
      
      private function onAlertNaviagte(param1:TextEvent) : void
      {
         if(param1 == null || param1.text == "")
         {
            return;
         }
         ExternalInterface.call("window.open(\"" + param1.text + "\")");
      }
   }
}


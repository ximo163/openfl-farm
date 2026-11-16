package module.messages.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.TextArea;
   import com.qzone.utils.StringUtil;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import module.messages.MessageView;
   
   public class ProfileMsg extends Sprite
   {
      
      private var _parent:MessageView;
      
      private var chatInput:TextField;
      
      private var _tName:String;
      
      private var _fName:String;
      
      private var replyLabel:TextField;
      
      private var chatLipiList:TextArea;
      
      private var delChatLabel:TextField;
      
      private var _me:Boolean;
      
      private var _sendToId:String;
      
      public function ProfileMsg(param1:MessageView)
      {
         super();
         this._parent = param1;
         this._sendToId = "0";
         this._me = false;
         this.createView();
      }
      
      private function createView() : void
      {
         this.chatLipiList = new TextArea();
         this.chatLipiList.addEventListener(TextEvent.LINK,this.onReply);
         this.chatLipiList.defaultSkin = null;
         this.chatLipiList.selectedSkin = null;
         this.chatLipiList.readOnly = true;
         this.chatLipiList.width = 470;
         this.chatLipiList.height = 150;
         this.chatLipiList.x = 20;
         this.chatLipiList.y = 2;
         addChild(this.chatLipiList);
         this.chatInput = new TextField();
         this.chatInput.defaultTextFormat = new TextFormat("Verdana");
         this.chatInput.maxChars = 50;
         this.chatInput.wordWrap = true;
         this.chatInput.addEventListener(KeyboardEvent.KEY_DOWN,this.onChatInputKeyDown);
         this.chatInput.type = TextFieldType.INPUT;
         this.chatInput.background = true;
         this.chatInput.backgroundColor = 16777215;
         this.chatInput.border = true;
         this.chatInput.borderColor = 39423;
         this.chatInput.htmlText = "";
         this.chatInput.width = 450;
         this.chatInput.height = 35;
         this.chatInput.x = 20;
         this.chatInput.y = 160;
         addChild(this.chatInput);
         var _loc1_:TextField = new TextField();
         _loc1_.autoSize = TextFieldAutoSize.LEFT;
         _loc1_.selectable = false;
         _loc1_.defaultTextFormat = new TextFormat("Verdana",null,6710886);
         _loc1_.text = Language.L["(每条最多 50 字)"];
         _loc1_.y = 200;
         _loc1_.x = 410 - _loc1_.width;
         addChild(_loc1_);
         var _loc2_:Button = new Button();
         _loc2_.width = 43;
         _loc2_.height = 23;
         _loc2_.defaultSkin = Utils.getClass("ButtonGreen");
         _loc2_.addEventListener(MouseEvent.CLICK,this.sendMsg);
         _loc2_.y = 198;
         _loc2_.x = 420;
         _loc2_.text = Language.L["发送留言"];
         addChild(_loc2_);
         this.delChatLabel = new TextField();
         this.delChatLabel.autoSize = TextFieldAutoSize.LEFT;
         this.delChatLabel.selectable = false;
         this.delChatLabel.defaultTextFormat = new TextFormat("Verdana",null,39423);
         this.delChatLabel.htmlText = "<a href=\'event:del\'>" + Language.L["清空留言记录"] + "</a>";
         this.delChatLabel.addEventListener(TextEvent.LINK,this.delChat);
         this.delChatLabel.y = 200;
         this.delChatLabel.x = 20;
         addChild(this.delChatLabel);
         this.replyLabel = new TextField();
         this.replyLabel.selectable = false;
         this.replyLabel.autoSize = TextFieldAutoSize.LEFT;
         this.replyLabel.background = true;
         this.replyLabel.backgroundColor = 16777215;
         this.replyLabel.defaultTextFormat = new TextFormat("Verdana",null,39168,true);
         this.replyLabel.text = "";
         this.replyLabel.height = 22;
         this.replyLabel.y = 140;
         this.replyLabel.x = 20;
         addChild(this.replyLabel);
      }
      
      private function delChat(param1:TextEvent) : void
      {
         var _loc2_:* = {
            "title":Language.L["清空记录"],
            "text":Language.L["确认删除您的留言记录？"],
            "confirmFn":this.delLogConfirm
         };
         this._parent.controller.openWindow(Consts.WINDOW_NAME_CONFIRM,_loc2_);
      }
      
      private function delLogConfirm() : void
      {
         this._parent.controller.model.clearChat();
      }
      
      public function hideReply() : void
      {
         if(this.replyLabel != null)
         {
            this.replyLabel.visible = false;
         }
         this._sendToId = "0";
      }
      
      private function onReply(param1:TextEvent) : void
      {
         var _loc2_:Array = param1.text.split(",");
         this.replyLabel.text = Language.L["回复"] + _loc2_[1] + ": ";
         this._tName = _loc2_[1];
         this.replyLabel.visible = true;
         this._sendToId = _loc2_[0];
         stage.focus = this.chatInput;
      }
      
      public function reset() : void
      {
         if(this.chatInput != null)
         {
            this.chatInput.text = "";
         }
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:* = undefined;
         this.delChatLabel.visible = Session.getInstance().me ? true : false;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         this.chatLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc16_:int = 0;
         var _loc2_:String = "";
         var _loc3_:String = "0";
         if(Session.getInstance().me == true)
         {
            _loc3_ = Session.getInstance().currentUser._uId.toString();
         }
         var _loc4_:String = "";
         var _loc5_:String = param1["fromName"] || "";
         _loc5_ = StringUtil.htmlEscape(_loc5_);
         var _loc6_:String = param1["toName"] || "";
         _loc6_ = StringUtil.htmlEscape(_loc6_);
         if(_loc3_ == "0" || _loc3_ == param1["fromId"] || param1["isAdmin"] == true)
         {
            _loc4_ = "";
         }
         else
         {
            _loc4_ = "<a href=\'event:" + param1["fromId"] + "," + _loc5_ + "\'><font color=\'#0099FF\'>" + Language.L["回复"] + "</font></a>";
         }
         var _loc7_:String = unescape(param1["msg"]);
         var _loc8_:String = "";
         _loc7_ = StringUtil.htmlEscape(_loc7_);
         var _loc9_:String = "";
         var _loc10_:Array = ["","空间","校友","微博"];
         if(Settings.getInstance().mode == "qzone")
         {
            _loc10_[1] = "";
         }
         else
         {
            _loc10_[2] = "";
         }
         if(param1.hasOwnProperty("domain") == true)
         {
            if(param1["domain"] == 6)
            {
               param1["domain"] = 3;
            }
            _loc9_ = _loc10_[param1["domain"]];
         }
         var _loc11_:String = param1["color"] || "#009900";
         if(param1.hasOwnProperty("isReply") == false || param1["isReply"] == false)
         {
            _loc8_ = _loc9_ + "<font color=\'" + _loc11_ + "\'><b>" + _loc5_ + "</b></font>：" + _loc7_;
         }
         else
         {
            _loc8_ = _loc9_ + "<font color=\'" + _loc11_ + "\'><b>" + _loc5_ + "</b></font> 回复 <font color=\'#009900\'><b>" + _loc6_ + "</b></font>：" + _loc7_;
         }
         var _loc12_:Date = new Date(parseFloat(param1["time"]) * 1000);
         var _loc13_:String = this.twoData(_loc12_.getHours());
         var _loc14_:String = this.twoData(_loc12_.getMinutes());
         var _loc15_:String = "";
         if(Language.lang == Language.CN)
         {
            _loc16_ = this.compareNow(_loc12_);
            if(_loc16_ == 0)
            {
               _loc15_ = "   " + Language.L["今天"] + _loc13_ + ":" + _loc14_;
            }
            else if(_loc16_ == 1)
            {
               _loc15_ = "    " + Language.L["昨天"] + _loc13_ + ":" + _loc14_;
            }
            else if(_loc16_ == 2)
            {
               _loc15_ = "    " + Language.L["前天"] + _loc13_ + ":" + _loc14_;
            }
            else
            {
               _loc15_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc13_ + ":" + _loc14_;
            }
         }
         else
         {
            _loc15_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc13_ + ":" + _loc14_;
         }
         return "<b>" + _loc15_ + "</b>  " + _loc8_ + "  " + _loc4_ + "<br>";
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1.toString();
         }
         return param1.toString();
      }
      
      private function sendMsg(param1:Event = null) : void
      {
         if(StringUtil.trim(this.chatInput.text) == "")
         {
            this.chatInput.text = "";
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:String = "0";
         var _loc4_:String = "0";
         if(this._parent.me == true)
         {
            _loc4_ = Session.getInstance().hostId;
         }
         else
         {
            _loc4_ = Session.getInstance().currentUser._uId.toString();
         }
         if(this._sendToId != "0")
         {
            _loc3_ = this._sendToId;
            _loc2_ = 1;
         }
         else
         {
            _loc3_ = _loc4_;
         }
         var _loc5_:String = this.chatInput.text;
         _loc5_ = _loc5_.replace("\r"," ");
         this._parent.controller.model.sendChat(_loc3_,_loc4_,_loc2_,_loc5_,this._tName);
         this.chatInput.text = "";
         this.replyLabel.visible = false;
         this._sendToId = "0";
      }
      
      private function onChatInputKeyDown(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            this.sendMsg();
         }
      }
      
      private function compareNow(param1:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         var _loc2_:Date = new Date();
         var _loc3_:Number = _loc2_.getTime() - param1.getTime();
         return _loc3_ / 86400000;
      }
   }
}


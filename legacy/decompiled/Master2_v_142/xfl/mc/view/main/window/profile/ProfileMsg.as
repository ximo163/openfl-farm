package mc.view.main.window.profile
{
   import com.adobe.utils.StringUtil;
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.control.LipiTextArea;
   import com.minutes.ui.core.LipiSkin;
   import common.CommonData;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.model.MData;
   import mc.view.common.ConfirmWindow;
   import mc.view.main.WindowControl.WControl;
   
   public class ProfileMsg extends Sprite
   {
      
      private var fName:String;
      
      public var chatInput:TextField;
      
      private var sendToId:String = "0";
      
      private var tName:String;
      
      private var replyLabel:TextField;
      
      private var chatLipiList:LipiTextArea;
      
      private var delChatLabel:TextField;
      
      private var _me:Boolean = false;
      
      public function ProfileMsg()
      {
         var _loc1_:TextField = null;
         super();
         this.chatLipiList = new LipiTextArea();
         this.chatLipiList.addEventListener(TextEvent.LINK,this.replyClickHandler);
         this.chatLipiList.bgAlpha = 0;
         this.chatLipiList.type = TextFieldType.DYNAMIC;
         this.chatLipiList.width = 465;
         this.chatLipiList.height = 150;
         this.chatLipiList.x = 20;
         this.chatLipiList.y = 2;
         this.chatLipiList.vLipiScrollBar.visible = false;
         addChild(this.chatLipiList);
         this.chatInput = new TextField();
         this.chatInput.defaultTextFormat = new TextFormat("Verdana");
         this.chatInput.maxChars = 50;
         this.chatInput.wordWrap = true;
         this.chatInput.addEventListener(KeyboardEvent.KEY_DOWN,this.chatInputKeyDown);
         this.chatInput.type = TextFieldType.INPUT;
         this.chatInput.background = true;
         this.chatInput.backgroundColor = 16777215;
         this.chatInput.border = true;
         this.chatInput.borderColor = 10982267;
         this.chatInput.htmlText = "";
         this.chatInput.width = 450;
         this.chatInput.height = 35;
         this.chatInput.x = 20;
         this.chatInput.y = 160;
         addChild(this.chatInput);
         _loc1_ = new TextField();
         _loc1_.autoSize = TextFieldAutoSize.LEFT;
         _loc1_.selectable = false;
         _loc1_.defaultTextFormat = new TextFormat("Verdana",null,8355198);
         _loc1_.text = "(每条最多 50 字)";
         _loc1_.y = 200;
         _loc1_.x = 410 - _loc1_.width;
         addChild(_loc1_);
         var _loc2_:LipiButton = new LipiButton();
         _loc2_.width = 43;
         _loc2_.height = 23;
         _loc2_.bgAlpha = 0;
         _loc2_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
         _loc2_.addEventListener(MouseEvent.CLICK,this.sendMsg);
         _loc2_.y = 198;
         _loc2_.x = 420;
         _loc2_.label = "留言";
         _loc2_.textColor = 16777215;
         addChild(_loc2_);
         this.delChatLabel = new TextField();
         this.delChatLabel.autoSize = TextFieldAutoSize.LEFT;
         this.delChatLabel.selectable = false;
         this.delChatLabel.defaultTextFormat = new TextFormat("Verdana",null,8999699);
         this.delChatLabel.htmlText = "<a href=\'event:del\'>清空留言记录</a>";
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
         var e:TextEvent = param1;
         var cw:ConfirmWindow = new ConfirmWindow();
         cw.data = {"text":"确认删除您的留言记录？"};
         cw.confirmFn = function():void
         {
            Command.getInstance().mainCommand.clearChat();
         };
         WControl.open(cw);
      }
      
      public function hideReply() : void
      {
         if(this.replyLabel != null)
         {
            this.replyLabel.visible = false;
         }
         this.sendToId = "0";
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc2_:String = "";
         if(!param1)
         {
            return;
         }
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         if(param1.length == 0)
         {
            this.delChatLabel.removeEventListener(TextEvent.LINK,this.delChat);
         }
         else
         {
            this.delChatLabel.addEventListener(TextEvent.LINK,this.delChat);
         }
         this.chatLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
         if(MData.getInstance().mainData.me)
         {
            this.delChatLabel.visible = true;
         }
         else
         {
            this.delChatLabel.visible = false;
         }
         if(this.chatLipiList.textField.numLines > 8)
         {
            this.chatLipiList.vLipiScrollBar.visible = true;
         }
         else
         {
            this.chatLipiList.vLipiScrollBar.visible = false;
         }
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + String(param1);
         }
         return String(param1);
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
         if(this.me)
         {
            _loc4_ = MData.getInstance().mainData.host["uId"];
         }
         else
         {
            _loc4_ = MData.getInstance().mainData.currentUserId;
         }
         if(this.sendToId != "0")
         {
            _loc3_ = this.sendToId;
            _loc2_ = 1;
         }
         else
         {
            _loc3_ = _loc4_;
         }
         var _loc5_:String = this.chatInput.text;
         _loc5_ = _loc5_.replace("\r"," ");
         Command.getInstance().mainCommand.sendChat(_loc3_,_loc4_,_loc2_,_loc5_,this.tName);
         this.chatInput.text = "";
         this.replyLabel.visible = false;
         this.sendToId = "0";
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc6_:String = null;
         var _loc13_:String = null;
         var _loc2_:String = "";
         var _loc3_:String = param1["fromName"] || "";
         if(_loc3_ != "null")
         {
            _loc3_ = _loc3_.replace(/&/g,"&amp;");
            _loc3_ = _loc3_.replace(/</g,"&lt;");
            _loc3_ = _loc3_.replace(/>/g,"&gt;");
         }
         var _loc4_:String = param1["toName"] || "";
         if(_loc4_ != "null")
         {
            _loc4_ = _loc4_.replace(/&/g,"&amp;");
            _loc4_ = _loc4_.replace(/</g,"&lt;");
            _loc4_ = _loc4_.replace(/>/g,"&gt;");
         }
         if(param1["color"])
         {
            _loc3_ = "<font color=\'" + param1["color"] + "\'>" + _loc3_ + "</font>";
         }
         var _loc5_:String = "0";
         if(MData.getInstance().mainData.me)
         {
            _loc5_ = MData.getInstance().mainData.currentUserId;
         }
         if(_loc5_ == "0" || _loc5_ == param1["fromId"])
         {
            _loc6_ = "";
         }
         else
         {
            _loc6_ = "<a href=\'event:" + param1["fromId"] + "," + _loc3_ + "\'><font color=\'#0099FF\'>回复</font></a>";
         }
         var _loc7_:String = unescape(param1["msg"]);
         var _loc8_:String = "";
         _loc7_ = _loc7_.replace(/&/g,"&amp;");
         _loc7_ = _loc7_.replace(/</g,"&lt;");
         _loc7_ = _loc7_.replace(/>/g,"&gt;");
         var _loc9_:String = "";
         var _loc10_:Array = ["","空间","校友"];
         if(LocalData.mode == "qzone")
         {
            _loc10_[1] = "";
         }
         else
         {
            _loc10_[2] = "";
         }
         if(param1.hasOwnProperty("domain"))
         {
            _loc9_ = _loc10_[param1["domain"]];
         }
         if(!param1.hasOwnProperty("isReply") || param1["isReply"] - 0 == 0)
         {
            _loc8_ = _loc9_ + "<font color=\'#009900\'><b>" + _loc3_ + ":</b></font> " + _loc7_;
         }
         else
         {
            _loc8_ = _loc9_ + "<font color=\'#009900\'><b>" + _loc3_ + "</b></font> 回复 <font color=\'#009900\'><b>" + _loc4_ + ":</b></font> " + _loc7_;
         }
         var _loc11_:Array = MData.getInstance().mainData.friendList;
         var _loc12_:Date = new Date(Number(param1["time"]) * 1000);
         var _loc14_:String = this.twoData(_loc12_.getHours());
         var _loc15_:String = this.twoData(_loc12_.getMinutes());
         if(this.compareDate(_loc12_,new Date(CommonData.serverTime * 1000)) == 0)
         {
            _loc13_ = "    " + "今天" + _loc14_ + ":" + _loc15_;
         }
         else if(this.compareDate(_loc12_,new Date(CommonData.serverTime * 1000)) == 1)
         {
            _loc13_ = "    " + "昨天" + _loc14_ + ":" + _loc15_;
         }
         else if(this.compareDate(_loc12_,new Date(CommonData.serverTime * 1000)) == 2)
         {
            _loc13_ = "    " + "前天" + _loc14_ + ":" + _loc15_;
         }
         else
         {
            _loc13_ = this.twoData(_loc12_.getMonth() + 1) + "-" + this.twoData(_loc12_.getDate()) + " " + _loc14_ + ":" + _loc15_;
         }
         return "<b>" + _loc13_ + "</b>  " + _loc8_ + "  " + _loc6_ + "<br>";
      }
      
      public function get me() : Boolean
      {
         return this._me;
      }
      
      private function chatInputKeyDown(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            this.sendMsg();
         }
      }
      
      public function set me(param1:Boolean) : void
      {
         this._me = param1;
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:Number = param2.getTime() - param1.getTime();
         return _loc3_ / 3600 / 24 / 1000;
      }
      
      private function replyClickHandler(param1:TextEvent) : void
      {
         var _loc2_:Array = param1.text.split(",");
         this.replyLabel.text = "回复" + _loc2_[1] + ": ";
         this.tName = _loc2_[1];
         this.replyLabel.visible = true;
         this.sendToId = _loc2_[0];
         stage.focus = this.chatInput;
      }
   }
}


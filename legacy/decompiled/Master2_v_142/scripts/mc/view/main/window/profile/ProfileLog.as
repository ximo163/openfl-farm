package mc.view.main.window.profile
{
   import com.minutes.ui.control.LipiTextArea;
   import common.INI;
   import common.LocalData;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.model.MData;
   import mc.view.common.ConfirmWindow;
   import mc.view.main.WindowControl.WControl;
   
   public class ProfileLog extends Sprite
   {
      
      private var aLipiList:LipiTextArea;
      
      private var delLogLabel:TextField;
      
      public function ProfileLog()
      {
         super();
         this.aLipiList = new LipiTextArea();
         this.aLipiList.bgAlpha = 0;
         this.aLipiList.vLipiScrollBar.visible = false;
         this.aLipiList.width = 465;
         this.aLipiList.height = 190;
         this.aLipiList.x = 20;
         this.aLipiList.y = 2;
         this.aLipiList.type = TextFieldType.DYNAMIC;
         this.aLipiList.addEventListener(TextEvent.LINK,this.addFilterHandle);
         addChild(this.aLipiList);
         this.delLogLabel = new TextField();
         this.delLogLabel.autoSize = TextFieldAutoSize.LEFT;
         this.delLogLabel.selectable = false;
         this.delLogLabel.defaultTextFormat = new TextFormat("Verdana",null,8999699);
         this.delLogLabel.htmlText = "<a href=\'event:del\'>清空消息记录</a>";
         this.delLogLabel.addEventListener(TextEvent.LINK,this.delLog);
         this.delLogLabel.x = 30;
         this.delLogLabel.y = 180 + 18;
         addChild(this.delLogLabel);
         Command.getInstance().mainCommand.getFriendList();
      }
      
      private function getFriendFlag(param1:Array, param2:String) : Boolean
      {
         var _loc4_:Object = null;
         var _loc3_:Boolean = false;
         for each(_loc4_ in param1)
         {
            if(_loc4_["uin"] == param2)
            {
               _loc3_ = true;
               break;
            }
         }
         return _loc3_;
      }
      
      private function addFilterHandle(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text.split(",")[0];
         var _loc3_:String = param1.text.split(",")[1];
         var _loc4_:String = "";
         _loc4_ = _loc4_ + "<p align=\'left\'><font color=\'#009900\'><b>";
         if(_loc3_)
         {
            _loc3_ = _loc3_.replace(/</g,"&lt;");
            _loc3_ = _loc3_.replace(/>/g,"&gt;");
            _loc4_ += _loc3_;
         }
         if(_loc2_)
         {
            _loc4_ += "(QQ:" + _loc2_ + ")";
         }
         var _loc5_:String = "http://blog.qq.com/qzone/1006666002/1300264199.htm";
         var _loc6_:String = INI.getInstance().data.logic.urlFriend.@url || "";
         _loc4_ += "</b></font> 可能不是您的好友，您可以进入“我的QQ中心”删除单向好友，防止对方进入您的农/牧场摘取等操作。<br/>或者 <font color=\'#0000FF\'><u><b><a href=\'event:" + _loc6_ + "\' target=\'_blank\'>前往管理您的单向好友</a></b></u>。</font></p>" + "<p align=\'right\'><font color=\'#0000FF\'><u><a href=\'event:" + _loc5_ + "\' target=\'_blank\'>详细</a></u></font></p>";
         Command.getInstance().mainCommand.alertWindow("tip",_loc4_,true);
      }
      
      private function delLogConfirm() : void
      {
         Command.getInstance().mainCommand.clearLog();
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:Object = null;
         this.delLogLabel.visible = MData.getInstance().mainData.me;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         this.aLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
         if(this.aLipiList.textField.numLines > 9)
         {
            this.aLipiList.vLipiScrollBar.visible = true;
         }
         else
         {
            this.aLipiList.vLipiScrollBar.visible = false;
         }
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc7_:String = null;
         var _loc11_:String = null;
         var _loc14_:int = 0;
         var _loc15_:RegExp = null;
         var _loc16_:String = null;
         var _loc2_:String = "";
         var _loc3_:String = String(param1["msg"]);
         var _loc4_:String = _loc3_.replace(/(.*?)\|(.*?)\|(.*)/,"$2");
         var _loc5_:Array = MData.getInstance().mainData.friendList;
         var _loc6_:String = "";
         var _loc8_:String = "";
         var _loc9_:Array = ["","空间","校友","空间"];
         if(LocalData.mode == "qzone")
         {
            _loc9_[1] = "";
            _loc9_[3] = "";
         }
         else
         {
            _loc9_[2] = "";
         }
         if(param1.hasOwnProperty("domain"))
         {
            _loc8_ = _loc9_[param1["domain"]];
         }
         if(_loc4_.length < 12)
         {
            if(_loc5_ != null)
            {
               _loc14_ = 0;
               while(_loc14_ < _loc5_.length)
               {
                  if(_loc5_[_loc14_]["uId"].toString() == _loc4_.toString())
                  {
                     _loc6_ = _loc5_[_loc14_]["userName"];
                     break;
                  }
                  _loc14_++;
               }
            }
            else
            {
               _loc6_ = _loc4_;
            }
            _loc7_ = _loc8_ + _loc3_.replace(/(.*?)\|(.*?)\|(.*?)/,"$1<a href=\'event:" + _loc4_ + "\'><font color=\'#009900\'><b>" + _loc6_ + "</b></font></a>$3");
         }
         else
         {
            _loc7_ = _loc8_ + _loc3_;
         }
         var _loc10_:Date = new Date(Number(param1["time"]) * 1000);
         var _loc12_:String = this.twoData(_loc10_.getHours());
         var _loc13_:String = this.twoData(_loc10_.getMinutes());
         if(this.compareDate(_loc10_,new Date()) == 0)
         {
            _loc11_ = "    " + "今天" + _loc12_ + ":" + _loc13_;
         }
         else if(this.compareDate(_loc10_,new Date()) == 1)
         {
            _loc11_ = "    " + "昨天" + _loc12_ + ":" + _loc13_;
         }
         else if(this.compareDate(_loc10_,new Date()) == 2)
         {
            _loc11_ = "    " + "前天" + _loc12_ + ":" + _loc13_;
         }
         else
         {
            _loc11_ = this.twoData(_loc10_.getMonth() + 1) + "-" + this.twoData(_loc10_.getDate()) + " " + _loc12_ + ":" + _loc13_;
         }
         if(LocalData.mode == "qzone" && MData.getInstance().mainData.me)
         {
            if(Boolean(param1["domain"] == 1) && Boolean(param1["qq"]) && _loc3_.indexOf("来牧场收获,收走了") > 0)
            {
               if(Boolean(_loc5_) && !this.getFriendFlag(_loc5_,param1["qq"]))
               {
                  _loc15_ = RegExp("<b>(.*)</b>");
                  _loc16_ = _loc15_.exec(_loc3_)[1];
                  _loc7_ += "\t<a href=\'event:" + param1["qq"] + "," + _loc16_ + "\'><font color=\'#FF6600\'><b><u>不让他收</u></b></font></a>";
               }
            }
         }
         return "<b>" + _loc11_ + "</b>  " + _loc7_ + "<br>";
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:int = Math.abs(param2.getTime() - param1.getTime());
         return _loc3_ / 3600 / 24 / 1000;
      }
      
      private function delLog(param1:TextEvent) : void
      {
         var _loc2_:ConfirmWindow = new ConfirmWindow();
         _loc2_.data = {"text":"确认清空消息记录？"};
         _loc2_.confirmFn = this.delLogConfirm;
         WControl.open(_loc2_);
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + String(param1);
         }
         return String(param1);
      }
   }
}


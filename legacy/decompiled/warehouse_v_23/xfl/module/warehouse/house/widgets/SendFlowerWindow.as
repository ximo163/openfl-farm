package module.warehouse.house.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.StringUtil;
   import common.Consts;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.Line;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class SendFlowerWindow extends BaseWindow
   {
      
      private var _uinErrorTxt:TextField;
      
      private var _lack:TextField;
      
      private var _okButton:Button;
      
      private var _imgBorder:Sprite;
      
      private const _imgWH:int = 120;
      
      private var _ld:Loader;
      
      private var _txtWord:TextField;
      
      private const _defaultWord:String = "花束里的每一朵花，都是我点滴的心意，一枝枝的扎起来送给您。希望能为您带来快乐！";
      
      private var _toUin:String;
      
      private var _desc:TextField;
      
      private var _txtToUin:TextField;
      
      private var _txtWordLimit:TextField;
      
      private var _pickFriend:Button;
      
      public function SendFlowerWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 400;
         height = 410;
         mode = true;
         title = "包装花束赠送";
         windowName = Consts.WINDOW_NAME_SENDFLOWER;
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         var _loc3_:* = undefined;
         if(int(this._txtToUin.text) > 10000)
         {
            this._toUin = this._txtToUin.text;
         }
         var _loc2_:String = data["desc"] as String;
         if(_loc2_ != null && _loc2_.indexOf("<script") != -1)
         {
            return;
         }
         if(this._toUin)
         {
            _loc3_ = {
               "uin":this._toUin,
               "word":this._txtWord.text,
               "flower":super.data
            };
            m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_FLOWER_SEND,_loc3_));
            super.close();
         }
         else
         {
            this._uinErrorTxt.text = "*请先选择受赠好友";
         }
      }
      
      private function onFocus(param1:FocusEvent) : void
      {
         if(param1.type == FocusEvent.FOCUS_IN)
         {
            if(this._txtWord.text == this._defaultWord)
            {
               this._txtWord.text = "";
            }
         }
         else if(StringUtil.trim(this._txtWord.text) == "")
         {
            this._txtWord.text = this._defaultWord;
         }
         this.onTextChanged();
      }
      
      public function onFriendSelected(param1:String, param2:String) : void
      {
         this._toUin = param1;
         this._txtToUin.htmlText = param2;
         this._uinErrorTxt.text = "";
      }
      
      private function onTextChanged(param1:Event = null) : void
      {
         this._txtWordLimit.htmlText = "<font color=\'#ff0000\'>" + this._txtWord.text.length + "</font>/50";
      }
      
      private function onSelectFriend(param1:MouseEvent) : void
      {
         QzoneJSAPI.selectFriend(this.onFriendSelected);
      }
      
      override protected function setData() : void
      {
         var _loc6_:Object = null;
         this.graphics.clear();
         var _loc1_:Object = super.data;
         if(_loc1_["pic"] != undefined && _loc1_["pic"] != "")
         {
            this._ld.load(new URLRequest(_loc1_["pic"]));
         }
         var _loc2_:String = "<p><b><font size=\'26\' color=\'#39983C\'>" + _loc1_["fName"] + "</font></b></p>";
         _loc2_ += "<font size=\'12\' color=\'#636768\'>";
         _loc2_ += "<p>" + "花语：" + _loc1_["desc"] + "</p>";
         var _loc3_:String = "";
         var _loc4_:String = "";
         var _loc5_:Boolean = true;
         for each(_loc6_ in _loc1_["need"])
         {
            if(_loc5_ == false)
            {
               _loc3_ += "<p><textformat indent=\'37\'>";
            }
            else
            {
               _loc3_ += "<p>需要：<textformat>";
            }
            _loc5_ = false;
            _loc3_ += _loc6_["cName"] + " <b><font color=\'#39983C\'>" + _loc6_["amount"] + "</font></b> 朵</textformat></p>";
            if(_loc6_["lack"] > 0)
            {
               _loc4_ += "<b>还差 <font color=\'#D2732F\'>" + _loc6_["lack"] + "</font> 朵</b><br/>";
            }
            else
            {
               _loc4_ += "<br/>";
            }
         }
         this._desc.htmlText = _loc2_ + _loc3_ + "</font>";
         this._lack.htmlText = _loc4_;
         this._txtWord.mouseEnabled = _loc1_["canMake"];
         this._pickFriend.enabled = _loc1_["canMake"];
         this._okButton.enabled = _loc1_["canMake"];
      }
      
      override protected function addedToLayer() : void
      {
         var txt:TextField;
         var tf:TextFormat;
         var l1:Line;
         var wordBg:Sprite;
         var uinBg:Sprite;
         this._imgBorder = Utils.getMaterial("ItemBg") as Sprite;
         this._imgBorder.name = "ItemBg";
         this._imgBorder.width = this._imgWH;
         this._imgBorder.height = this._imgWH;
         this._imgBorder.x = 20;
         this._imgBorder.y = 45;
         addChild(this._imgBorder);
         this._ld = new Loader();
         this._ld.mouseChildren = this._ld.mouseEnabled = false;
         this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            var _loc2_:Loader = arguments[0].target.loader;
            _loc2_.width = _loc2_.height = _imgWH - 4;
            _loc2_.x = _imgBorder.x + 2;
            _loc2_.y = _imgBorder.y + 2;
            Bitmap(_loc2_.content).smoothing = true;
            _loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
         });
         addChild(this._ld);
         this._desc = new TextField();
         this._desc.multiline = true;
         this._desc.selectable = false;
         this._desc.width = 222;
         this._desc.autoSize = "left";
         this._desc.x = 156;
         this._desc.y = 45;
         addChild(this._desc);
         this._lack = new TextField();
         tf = new TextFormat("Verdana",12,6514536);
         tf.color = 3774524;
         this._lack.defaultTextFormat = tf;
         this._lack.selectable = false;
         this._lack.width = 110;
         this._lack.autoSize = "left";
         this._lack.multiline = this._lack.wordWrap = true;
         this._lack.x = 300;
         this._lack.y = 105;
         addChild(this._lack);
         l1 = new Line(360,3,3852787);
         l1.y = this._imgBorder.y + this._imgBorder.height + 10;
         l1.x = this._imgBorder.x;
         addChild(l1);
         txt = new TextField();
         txt.defaultTextFormat = new TextFormat("Verdana",12,6514536);
         txt.selectable = false;
         txt.autoSize = "left";
         txt.text = "赠送给：";
         txt.x = this._imgBorder.x;
         txt.y = l1.y + 10;
         addChild(txt);
         uinBg = Utils.getMaterial("ItemBg") as Sprite;
         uinBg.width = 140;
         uinBg.height = 20;
         uinBg.x = this._imgBorder.x;
         uinBg.y = txt.y + txt.height + 4;
         addChild(uinBg);
         this._txtToUin = new TextField();
         this._txtToUin.defaultTextFormat = new TextFormat("Verdana",12,6514536);
         this._txtToUin.width = uinBg.width - 4;
         this._txtToUin.height = uinBg.height;
         this._txtToUin.x = uinBg.x + 2;
         this._txtToUin.y = uinBg.y;
         if(Settings.getInstance().mode == "qzone")
         {
            this._txtToUin.type = TextFieldType.INPUT;
            this._txtToUin.restrict = "0-9";
         }
         else
         {
            this._txtToUin.mouseEnabled = this._txtToUin.mouseWheelEnabled = false;
            uinBg.addEventListener(MouseEvent.CLICK,this.onSelectFriend);
         }
         addChild(this._txtToUin);
         this._pickFriend = new Button();
         this._pickFriend.defaultSkin = Utils.getClass("ButtonBlue");
         this._pickFriend.width = 60;
         this._pickFriend.height = 25;
         this._pickFriend.x = uinBg.x + uinBg.width + 20;
         this._pickFriend.y = uinBg.y - 3;
         this._pickFriend.text = "选择好友";
         this._pickFriend.clickFn = this.onSelectFriend;
         addChild(this._pickFriend);
         this._uinErrorTxt = new TextField();
         this._uinErrorTxt.defaultTextFormat = new TextFormat("Verdana",12,15829835);
         this._uinErrorTxt.selectable = false;
         this._uinErrorTxt.autoSize = "left";
         this._uinErrorTxt.x = this._txtToUin.x;
         this._uinErrorTxt.y = uinBg.y + 22;
         addChild(this._uinErrorTxt);
         txt = new TextField();
         txt.defaultTextFormat = new TextFormat("Verdana",12,6514536);
         txt.selectable = false;
         txt.autoSize = "left";
         txt.text = "留言：";
         txt.height = 22;
         txt.x = this._imgBorder.x;
         txt.y = uinBg.y + uinBg.height + 30;
         addChild(txt);
         wordBg = Utils.getMaterial("ItemBg") as Sprite;
         wordBg.width = 360;
         wordBg.height = 80;
         wordBg.x = this._imgBorder.x;
         wordBg.y = txt.y + txt.height + 4;
         addChild(wordBg);
         this._txtWordLimit = new TextField();
         this._txtWordLimit.defaultTextFormat = new TextFormat("Verdana",12,6514536);
         this._txtWordLimit.selectable = false;
         this._txtWordLimit.width = 50;
         this._txtWordLimit.autoSize = "right";
         this._txtWordLimit.x = wordBg.x + wordBg.width - this._txtWordLimit.width;
         this._txtWordLimit.y = txt.y;
         addChild(this._txtWordLimit);
         this._txtWord = new TextField();
         this._txtWord.defaultTextFormat = new TextFormat("Verdana",12,6514536);
         this._txtWord.type = TextFieldType.INPUT;
         this._txtWord.width = wordBg.width - 8;
         this._txtWord.height = wordBg.height - 8;
         this._txtWord.text = "";
         this._txtWord.maxChars = 50;
         this._txtWord.multiline = this._txtWord.wordWrap = true;
         this._txtWord.x = wordBg.x + 4;
         this._txtWord.y = wordBg.y + 4;
         this._txtWord.addEventListener(Event.CHANGE,this.onTextChanged);
         this._txtWord.addEventListener(FocusEvent.FOCUS_IN,this.onFocus);
         this._txtWord.addEventListener(FocusEvent.FOCUS_OUT,this.onFocus);
         this._txtWord.text = this._defaultWord;
         addChild(this._txtWord);
         this.onTextChanged();
         this._okButton = new Button();
         this._okButton.defaultSkin = Utils.getClass("ButtonBlue");
         this._okButton.width = 70;
         this._okButton.height = 25;
         this._okButton.x = width / 2 - 35;
         this._okButton.y = height - 35;
         this._okButton.text = "确定赠送";
         this._okButton.clickFn = this.onOK;
         addChild(this._okButton);
      }
   }
}


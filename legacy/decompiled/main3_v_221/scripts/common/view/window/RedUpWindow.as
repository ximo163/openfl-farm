package common.view.window
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.RadioButton;
   import com.qzone.qui.controls.TabBar;
   import com.qzone.qui.makers.RadioGroup;
   import com.qzone.utils.DateTimeUtils;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import entities.Player;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.ServerServices;
   import framework.net.vo.ServiceResultVO;
   import framework.net.vo.ServiceResultVOHelper;
   import interfaces.IMsgCenter;
   
   public class RedUpWindow extends ConfirmWindow
   {
      
      private var _cd:int;
      
      private var _rbtnJB:RadioButton;
      
      private var _tf:TextFormat;
      
      private var _adText:TextField = new TextField();
      
      private var _redText:String;
      
      private var _goldCarFlag:Boolean = false;
      
      private const HEIGHT:uint = 445;
      
      private var _tipText:TextField;
      
      private var _showAdFlag:Boolean = true;
      
      private var _targetBlack:int;
      
      private var _tipText2:TextField;
      
      private var _buyRequesting:Boolean = true;
      
      private var _checking:Boolean;
      
      private var _tf1:TextFormat;
      
      private var _tipBg:Shape;
      
      private var _tf2:TextFormat;
      
      private var _timer:Timer;
      
      private var _landFlag:Boolean = false;
      
      private var ss:Session = Session.getInstance();
      
      private var _radioGroup:RadioGroup;
      
      private var _showGoldLand:Boolean = false;
      
      private var _rbtnQB:RadioButton;
      
      private var _tabNav:TabBar;
      
      private var _isFirst:Boolean = true;
      
      private var _redEnable:Boolean;
      
      private var _checkBlack:Boolean;
      
      private var _timeStamp:Number;
      
      private var _newIcon:MovieClip;
      
      private var _helpText:TextField;
      
      public function RedUpWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 465;
         height = this.HEIGHT;
         title = "升级土地";
         windowName = Consts.WINDOW_NAME_UPGRADE_RED;
         closeFn = this.onClosed;
         this._redText = "";
         this._redEnable = false;
         this._checkBlack = true;
         this._targetBlack = -1;
         this._cd = 0;
         this._tf = new TextFormat("SimSun",14,0,null,null,null,null,null,"left");
         this._tf1 = new TextFormat("SimSun",14,8947848,null,null,null,null,null,"left");
         this._tf2 = new TextFormat("SimSun",14,16711680,null,null,null,null,null,"left");
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         _alertText.x = 5;
         if(data != null && data["ecode"] == -30120 && !this._showGoldLand)
         {
            _alertText.y = 220;
         }
         else
         {
            _alertText.y = 242;
         }
         _confirmButton.x = (this.width - _confirmButton.width) * 0.5;
         _confirmButton.y = this.height - 45;
      }
      
      private function refreshBlack() : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Player = null;
         _confirmButton.text = "升级为黑土地";
         this.confirmEnable = false;
         if(_confirmIcon is MovieClip)
         {
            (_confirmIcon as MovieClip).gotoAndStop(2);
         }
         if(data != null && data["ecode"] == -30121)
         {
            _alertText.htmlText = Language.L["BlackUpNoLand"];
            return;
         }
         if(data != null && data["allBlack"] == true)
         {
            _alertText.htmlText = "恭喜您！您已经把所有的土地升级成了黑土地！";
            return;
         }
         var _loc1_:String = Settings.getInstance().getStringAttribute("BlackUpgrade");
         if(_loc1_ != "")
         {
            _loc2_ = "<font size=\'14\'>QQ农场40级以上玩家可以升级黑土地了，升级之后可以种植更多稀有作物，" + "增加作物产量，缩短作物成熟时间。<br/>扩地内测期间，暂时提供";
            _loc3_ = "优先体验，请大家耐心等待。<br><br>" + "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "<font color=\'#FF6532\' size=\'14\'><a href=\'tools.php?mod=vip" + "tools.php?mod=vip\' target=\'_blank\'>开通VIP</a></font></b></font>";
            _loc4_ = Session.getInstance().host;
            if(_loc1_ == "1" && _loc4_._yellowstatus <= 0)
            {
               _loc2_ += "<font color=\'#FF6532\'>VIP用户</font>";
               _loc2_ += _loc3_;
               _alertText.htmlText = _loc2_;
               return;
            }
            if(_loc1_ == "2" && (_loc4_._yellowstatus > 0 && _loc4_._yellowlevel < 7 || _loc4_._yellowstatus == 0))
            {
               _loc2_ += "<font color=\'#FF6532\'>VIP 7级用户</font>";
               _loc2_ += _loc3_;
               _alertText.htmlText = _loc2_;
               return;
            }
         }
         if(Session.getInstance().host.level < 40)
         {
            _alertText.htmlText = Language.L["BlackUp"] + "<b><font color=\"#399200\">必须达到40级才能升级黑土地</font></b>";
            return;
         }
         if(this._checkBlack == true)
         {
            this._targetBlack = -1;
            NetHelper.sendRequest(CommandDefs.CMD_UPGRADE_BLACK,{"op":0},this.onBlackUp,this.onNetError);
            this._checking = true;
         }
      }
      
      override protected function init() : void
      {
         var dTextFormat:TextFormat;
         var st:Settings;
         var jpLand:String;
         var item:DisplayObject;
         var onAddToStage:Function = null;
         var arr:Array = null;
         var start:Date = null;
         var end:Date = null;
         var now:Number = NaN;
         onAddToStage = function(param1:Event):void
         {
            ss.app.useSystemCursor(true);
         };
         var className:String = "redUpBanner";
         var url:String = Settings.getInstance().getSecondUrl(className);
         CommonData.rslManager.requestClass(className,this.onRedBannerLoaded,url);
         addEventListener(Event.ADDED_TO_STAGE,onAddToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,function():void
         {
            ss.app.useSystemCursor(false);
         });
         this._tabNav = new TabBar();
         WindowTabBarMaker.addTarget(this._tabNav);
         this._tabNav.paddingH = 18;
         this._tabNav.x = 0;
         this._tabNav.y = 33;
         this._tabNav.width = width - 2;
         this._tabNav.addEventListener(Event.CHANGE,this.onTabSwitched);
         this._tabNav.addTab("红土地",NaN,24);
         this._tabNav.addTab("黑土地",NaN,24);
         st = Settings.getInstance();
         jpLand = st.getStringAttribute("jinPaiLand");
         if(jpLand)
         {
            arr = jpLand.split("-");
            start = new Date(arr[0]);
            end = new Date(arr[1]);
            now = CommonData.serverTime * 1000;
            if(now >= start.time && now <= end.time)
            {
               this._tabNav.addTab("金牌土地",NaN,24);
               this._showGoldLand = true;
            }
         }
         addChild(this._tabNav);
         _alertText = new TextField();
         dTextFormat = new TextFormat("Verdana",12,3355443,null,null,null,null,null,TextFormatAlign.LEFT);
         dTextFormat.leading = 8;
         dTextFormat.indent = 10;
         _alertText.defaultTextFormat = dTextFormat;
         _alertText.width = width - 10;
         _alertText.height = 160;
         _alertText.x = 5;
         _alertText.wordWrap = true;
         _alertText.multiline = true;
         _alertText.selectable = false;
         _alertText.htmlText = "";
         addChild(_alertText);
         _confirmButton = new Button();
         _confirmButton.defaultSkin = Utils.getClass("ButtonOrange");
         _confirmButton.width = 120;
         _confirmButton.height = 25;
         _confirmButton.x = (width - _confirmButton.width) * 0.5;
         _confirmButton.y = this.HEIGHT - 45;
         _confirmButton.visible = false;
         _confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(_confirmButton);
         this._newIcon = Utils.getMaterial("ShopTabNewIcon") as MovieClip;
         if(this._newIcon == null)
         {
            return;
         }
         item = this._tabNav.content.getChildAt(this._tabNav.tabNum - 1);
         this._newIcon.x = item.x + (item.width - this._newIcon.width);
         this._newIcon.y = 29;
         addChild(this._newIcon);
         this._adText.defaultTextFormat = new TextFormat("SimSun",12,16755312);
         this._adText.htmlText = "VIP特权升级红土地无需等级限制。";
         this._adText.mouseEnabled = true;
         this._adText.selectable = false;
         this._adText.width = width;
         this._adText.height = 30;
         this.addYellowLink();
      }
      
      private function showBlackTip2(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            if(this._tipBg != null && contains(this._tipBg))
            {
               removeChild(this._tipBg);
            }
            if(this._tipText2 != null && contains(this._tipText2))
            {
               removeChild(this._tipText2);
            }
            return;
         }
         if(this._tipBg != null)
         {
            this._tipBg.graphics.clear();
            this._tipBg.graphics.beginFill(16777113,1);
            this._tipBg.graphics.drawRect(0,0,440,40);
            this._tipBg.graphics.endFill();
         }
         if(this._tipText2 == null)
         {
            this._tipText2 = new TextField();
            this._tipText2.selectable = false;
            this._tipText2.multiline = false;
            this._tipText2.mouseEnabled = false;
            this._tipText2.width = 440;
            this._tipText2.defaultTextFormat = new TextFormat("SimSun",13,0,false,false,false,null,null,TextFormatAlign.LEFT);
            this._tipText2.x = this._tipBg.x + 3;
            this._tipText2.y = this._tipBg.y + 23;
         }
         addChild(this._tipText2);
         this._tipText2.htmlText = param1;
      }
      
      private function onBlackUp(param1:CommandEvent) : void
      {
         this._checking = false;
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Player = Session.getInstance().host;
         var _loc5_:Number = Number(CommonData.serverTime);
         this._targetBlack = _loc3_["place"];
         var _loc6_:String = "升级第<font color=\"#FF6600\">" + (_loc3_["place"] + 1) + "</font>块黑土地需要<font color=\"#FF6600\">" + _loc3_["level"] + "</font>级，您可以使用农场" + "<font color=\"#FF6600\">金币</font>或者<font color=\"#FF6600\">元宝</font>升级黑土地。";
         if(_loc4_._money < _loc3_["money"] || _loc3_["ecode"] == -30342)
         {
            _loc6_ += "连续升级黑土地时升级价格将会翻倍增长。";
         }
         _loc6_ += "请您选择：";
         _alertText.htmlText = "<font size=\'14\'>" + _loc6_ + "</font>";
         this._cd = _loc3_["cd"] as int;
         if(this._cd > _loc5_)
         {
            if(this._timer == null)
            {
               this._timer = new Timer(1000);
               this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            }
            this._timer.start();
            this.onTimer(null);
            this.showRadioGroup(_loc3_["money"],_loc4_._yellowstatus == 0 ? int(_loc3_["qd"]) : int(_loc3_["yqd"]),_loc4_._money >= _loc3_["money"] ? true : false,true);
         }
         else
         {
            if(this._timer != null)
            {
               this._timer.stop();
            }
            this.showRadioGroup(_loc3_["money"],_loc4_._yellowstatus == 0 ? int(_loc3_["qd"]) : int(_loc3_["yqd"]),_loc4_._money >= _loc3_["money"] ? true : false,false);
            this.showBlackTip("连续升级黑土地时升级价格将会翻倍增长。");
         }
         if(_loc4_._money < _loc3_["money"])
         {
            if(this._cd == 0 || this._cd < _loc5_)
            {
               this.showBlackTip("您的金币不足，试试用元宝升级黑土地吧！");
            }
            else
            {
               this.showBlackTip2("您的金币不足，试试用元宝升级黑土地吧！");
            }
         }
         if(_loc3_["ecode"] == 0)
         {
            _confirmButton.enabled = true;
         }
         else if(_loc3_["ecode"] == -30342)
         {
            if(this._cd == 0 || this._cd < _loc5_)
            {
               this.showBlackTip(Language.L["BlackUpNoLand"]);
            }
            else
            {
               this.showBlackTip2(Language.L["BlackUpNoLand"]);
            }
         }
         if(_loc4_.level < _loc3_["level"])
         {
            if(this._cd == 0 || this._cd < _loc5_)
            {
               this.showBlackTip("您的等级不够。");
            }
            else
            {
               this.showBlackTip2("您的等级不够。");
            }
         }
         this.graphics.clear();
      }
      
      override protected function confirmButtonClick(param1:MouseEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(_confirmButton.enabled == true)
         {
            if(_confirmFn != null)
            {
               _loc2_ = 0;
               if(this._radioGroup != null)
               {
                  _loc2_ = this._radioGroup.selectedTarget == this._rbtnQB ? 1 : 0;
               }
               _loc3_ = false;
               if(this._tabNav.selectedIndex == 1 && this._cd > 0 && this._cd > CommonData.serverTime)
               {
                  _loc3_ = true;
               }
               if(this._tabNav.selectedIndex == 0)
               {
                  _confirmFn(this._tabNav.selectedIndex,_loc2_,data["place"],false);
               }
               else if(this._tabNav.selectedIndex == 1)
               {
                  _confirmFn(this._tabNav.selectedIndex,_loc2_,this._targetBlack,_loc3_);
               }
               else
               {
                  _confirmFn(this._tabNav.selectedIndex,0,this._targetBlack,_loc3_);
               }
            }
            _confirmFn = null;
            super.close();
         }
      }
      
      private function onRedBannerLoaded() : void
      {
         _hideIcon = false;
         _confirmIcon = Utils.getMaterial("redUpBanner") as Sprite;
         _confirmIcon.x = 10;
         if(data != null && data["ecode"] == -30120 && !this._showGoldLand)
         {
            _confirmIcon.y = 36;
         }
         else
         {
            _confirmIcon.y = 62;
         }
         addChild(_confirmIcon);
         if(_confirmIcon is MovieClip)
         {
            if(this._tabNav.selectedIndex == 1 || data["allBlack"] == true)
            {
               (_confirmIcon as MovieClip).gotoAndStop(2);
            }
            else if(this._tabNav.selectedIndex == 2)
            {
               (_confirmIcon as MovieClip).gotoAndStop(3);
            }
            else
            {
               (_confirmIcon as MovieClip).gotoAndStop(1);
            }
         }
         _confirmButton.visible = true;
         if(this._showGoldLand)
         {
            this._tabNav.selectedIndex = 2;
         }
         this.showTheTab(this._tabNav.selectedIndex);
         this._isFirst = false;
      }
      
      private function updateBtnStatus() : void
      {
         var _loc1_:int = parseInt(_confirmIcon["chanceTime"].text);
         if(_loc1_ <= 0)
         {
            _confirmIcon["chanceTime"].text = "0";
            this._goldCarFlag = false;
         }
         else
         {
            this._goldCarFlag = true;
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         if(this._tabNav != null && this._tabNav.selectedIndex != 1)
         {
            return;
         }
         if(this._cd > 0)
         {
            _loc2_ = this._cd - CommonData.serverTime;
            this.showBlackTip("黑土地为稀缺资源，升级价格已经上涨一倍，<font color=\'0xFF6600\'>" + DateTimeUtils.formatSecondCount(_loc2_,true) + "</font>后恢复原价。");
         }
      }
      
      private function showRadioGroup(param1:int, param2:int, param3:Boolean, param4:Boolean, param5:Boolean = false) : void
      {
         var _loc6_:int = _alertText.y + _alertText.textHeight + 17;
         if(this._rbtnJB == null)
         {
            this._rbtnJB = new RadioButton(param1 + " 金币");
            this._rbtnJB.textDefaultFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textSelectedFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textOverFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textDisabledFormat = this._tf1;
            this._rbtnJB.x = param5 ? 120 : 60;
            this._rbtnJB.y = _loc6_;
            addChild(this._rbtnJB);
         }
         else
         {
            this._rbtnJB.textDefaultFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textSelectedFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textOverFormat = param4 ? this._tf2 : this._tf;
            this._rbtnJB.textDisabledFormat = this._tf1;
            this._rbtnJB.text = param1 + " 金币";
            this._rbtnJB.x = param5 ? 120 : 60;
            this._rbtnJB.y = _loc6_;
            addChild(this._rbtnJB);
         }
         if(this._rbtnQB == null)
         {
            this._rbtnQB = new RadioButton(param2 + " 元宝");
            this._rbtnQB.textDefaultFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textSelectedFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textOverFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textDisabledFormat = this._tf1;
            this._rbtnQB.x = param5 ? 260 : 200;
            this._rbtnQB.y = _loc6_;
            addChild(this._rbtnQB);
         }
         else
         {
            this._rbtnQB.textDefaultFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textSelectedFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textOverFormat = param4 ? this._tf2 : this._tf;
            this._rbtnQB.textDisabledFormat = this._tf1;
            this._rbtnQB.text = param2 + " 元宝";
            this._rbtnQB.x = param5 ? 260 : 200;
            this._rbtnQB.y = _loc6_;
            addChild(this._rbtnQB);
         }
         if(this._radioGroup == null)
         {
            this._radioGroup = new RadioGroup();
            this._radioGroup.addTarget(this._rbtnJB);
            this._radioGroup.addTarget(this._rbtnQB);
         }
         this._radioGroup.selectedTarget = param3 ? this._rbtnJB : this._rbtnQB;
         if(param3 == true)
         {
            this._rbtnJB.selected = true;
            this._rbtnJB.enabled = true;
         }
         else
         {
            this._rbtnJB.enabled = false;
            this._rbtnQB.selected = true;
         }
         if(this._helpText == null)
         {
            this._helpText = new TextField();
            this._helpText.selectable = false;
            this._helpText.multiline = false;
            this._helpText.defaultTextFormat = new TextFormat("SimSun",14,3381708,false,false,true);
            this._helpText.htmlText = "<a href=\'http://blog.qq.com/qzone/1006666001/1320119200.htm\' target=\'_blank\'>" + "查看升级帮助</a>";
         }
         if(param5 == false)
         {
            this._helpText.x = 280;
            this._helpText.y = _loc6_;
            addChild(this._helpText);
         }
      }
      
      private function addYellowLink() : void
      {
         var _loc1_:Number = Number(CommonData.serverTime);
         if(_loc1_ <= 0)
         {
            return;
         }
         var _loc2_:Date = new Date(_loc1_ * 1000);
         if(_loc2_.fullYear > 2011)
         {
            return;
         }
         var _loc3_:TextField = new TextField();
         _loc3_.multiline = false;
         _loc3_.selectable = false;
         _loc3_.textColor = 16711680;
         _loc3_.autoSize = TextFieldAutoSize.RIGHT;
         _loc3_.htmlText = "<a target=\"_blank\" href=\"tools.php?mod=vip\">" + "农场700万金币等您拿，助您升级黑土地！" + "</a>";
         _loc3_.x = 236;
         _loc3_.y = 36;
         addChild(_loc3_);
         var _loc4_:StyleSheet = new StyleSheet();
         _loc4_.parseCSS("a:link {color:#FF0000;font-family:\"Arial Black\";} a:hover{text-decoration:underline;color:#FF0000;}");
         _loc3_.styleSheet = _loc4_;
      }
      
      private function refreshRed() : void
      {
         _confirmButton.text = "升级为红土地";
         _alertText.htmlText = this._redText;
         this.confirmEnable = this._redEnable;
         if(_confirmIcon is MovieClip)
         {
            (_confirmIcon as MovieClip).gotoAndStop(1);
         }
         if(data["ecode"] == -30120 || data["ecode"] == -30121 || data["ecode"] == -30123)
         {
            return;
         }
         var _loc1_:Player = Session.getInstance().host;
         this.showRadioGroup(data["money"],_loc1_._yellowstatus == 0 ? int(data["qd"]) : int(data["yqd"]),_loc1_._money >= data["money"] ? true : false,false,true);
      }
      
      private function onTabSwitched(param1:Event) : void
      {
         if(param1 == null || param1.currentTarget == null)
         {
            return;
         }
         this.showBlackTip(null);
         this.showBlackTip2(null);
         this.hideRadios();
         this.showTheTab(param1.currentTarget.selectedIndex);
      }
      
      private function onInGameBuySuccess(param1:* = null) : void
      {
         var onSuccess:Function = null;
         var onRequestFailed:Function = null;
         var o_:* = param1;
         onSuccess = function(param1:CommandEvent):void
         {
            if(Boolean(param1 && param1.result) && Boolean(param1.result["m_extra"] != undefined) && param1.result["m_extra"]["goldLandCard"] != undefined)
            {
               Session.getInstance().upGoldLandTime = param1.result["m_extra"]["goldLandCard"];
               if(_tabNav.selectedIndex == 2)
               {
                  data["upGoldTime"] = Session.getInstance().upGoldLandTime;
                  _confirmIcon["chanceTime"].text = data["upGoldTime"];
                  m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME_CHANGE,Session.getInstance().upGoldLandTime));
                  updateGoldLandBtn();
               }
            }
         };
         onRequestFailed = function(param1:*):void
         {
         };
         var ss:ServerServices = ServerServices.getInstance();
         if(ss.getRequestUrl(CommandDefs.REFRESH_UP_GOLD_TIME) == "")
         {
            return;
         }
         NetHelper.sendRequest(CommandDefs.REFRESH_UP_GOLD_TIME,null,onSuccess,onRequestFailed);
      }
      
      override protected function setData() : void
      {
         if(data["text"] != undefined)
         {
            this._redText = data["text"] || "";
         }
         this._redEnable = true;
         if(data["ecode"] == -30120 || data["ecode"] == -30121 || data["ecode"] == -30123)
         {
            this._redEnable = false;
         }
         if(data["confirmFn"] != undefined)
         {
            _confirmFn = data["confirmFn"] as Function;
         }
         else
         {
            _confirmFn = null;
         }
         var _loc1_:int = int(this.HEIGHT);
         if(data != null && data["ecode"] == -30120 && !this._showGoldLand)
         {
            _loc1_ -= 24;
            this._tabNav.selectedIndex = 1;
            if(contains(this._tabNav) == true)
            {
               removeChild(this._tabNav);
            }
            if(contains(this._newIcon) == true)
            {
               removeChild(this._newIcon);
            }
         }
         else
         {
            if(contains(this._tabNav) == false)
            {
               this._tabNav.selectedIndex = 0;
               addChild(this._tabNav);
            }
            if(contains(this._newIcon) == false)
            {
               addChild(this._newIcon);
            }
         }
         this.showBlackTip(null);
         this.showBlackTip2(null);
         this.hideRadios();
         if(data["ecode"] == -30121 || data["allBlack"] == true)
         {
            this.height = _loc1_ - (140 - _alertText.textHeight);
         }
         this.updateNote();
         if(!this._isFirst)
         {
            this.showTheTab(this._tabNav.selectedIndex);
         }
         this.graphics.clear();
      }
      
      private function hideRadios() : void
      {
         if(this._rbtnJB != null && contains(this._rbtnJB))
         {
            removeChild(this._rbtnJB);
         }
         if(this._rbtnQB != null && contains(this._rbtnQB))
         {
            removeChild(this._rbtnQB);
         }
         if(this._helpText != null && contains(this._helpText))
         {
            removeChild(this._helpText);
         }
      }
      
      private function showTheTab(param1:int) : void
      {
         if(param1 == 0)
         {
            this.refreshRed();
            this.showAdText();
         }
         else if(param1 == 1)
         {
            this.refreshBlack();
            this.hideAdText();
         }
         else if(param1 == 2)
         {
            this.refreshJPLand();
            this.hideAdText();
         }
      }
      
      private function showBlackTip(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            if(this._tipBg != null)
            {
               this._tipBg.graphics.clear();
            }
            if(this._tipBg != null && contains(this._tipBg))
            {
               removeChild(this._tipBg);
            }
            if(this._tipText != null && contains(this._tipText))
            {
               removeChild(this._tipText);
            }
            return;
         }
         if(this._tipBg == null)
         {
            this._tipBg = new Shape();
            this._tipBg.x = (width - 440) * 0.5;
            this._tipBg.y = _alertText.y + _alertText.textHeight + 68;
            addChild(this._tipBg);
         }
         this._tipBg.graphics.beginFill(16777113,1);
         this._tipBg.graphics.drawRect(0,0,440,20);
         this._tipBg.graphics.endFill();
         if(this._tipText == null)
         {
            this._tipText = new TextField();
            this._tipText.selectable = false;
            this._tipText.multiline = false;
            this._tipText.mouseEnabled = false;
            this._tipText.width = 440;
            this._tipText.defaultTextFormat = new TextFormat("SimSun",13,0,false,false,false,null,null,TextFormatAlign.LEFT);
            this._tipText.x = this._tipBg.x + 3;
            this._tipText.y = this._tipBg.y + 3;
            addChild(this._tipText);
         }
         this._tipText.htmlText = param1;
         if(this._tipBg != null && contains(this._tipBg) == false)
         {
            addChild(this._tipBg);
         }
         if(this._tipText != null && contains(this._tipText) == false)
         {
            addChild(this._tipText);
         }
      }
      
      private function showAdText() : void
      {
         if(this._showAdFlag)
         {
            addChild(this._adText);
            this._adText.x = 140;
            if(!this._rbtnJB || !this._rbtnJB.parent)
            {
               this._adText.y = _alertText.y + _alertText.textHeight + (_confirmButton.y - (_alertText.y + _alertText.textHeight) - 10) / 2;
            }
            else
            {
               this._adText.y = this._rbtnJB.y + 15 + (_confirmButton.y - (this._rbtnJB.y + 19) - 10) / 2;
            }
            addChild(_confirmButton);
         }
      }
      
      private function onClosed(param1:Event) : void
      {
         this._checkBlack = true;
         this._checking = false;
         this._redText = "";
         this._redEnable = false;
         if(this._timer != null)
         {
            this._timer.stop();
         }
      }
      
      private function updateNote() : void
      {
         if(data["ecode"] == -30122 || data["ecode"] == -30123 || data["ecode"] == 0)
         {
            if(this.ss.host._yellowstatus > 0 && this.ss.host._yellowlevel > 0)
            {
               this.renewalsYellowVIP();
            }
            else
            {
               this.openYellowVIP();
            }
            this._showAdFlag = true;
         }
         else
         {
            this._showAdFlag = false;
         }
      }
      
      private function openYellowVIP() : void
      {
         this._adText.htmlText = "VIP特权升级红土地无需等级限制。";
      }
      
      private function updateConfirmIconPos() : void
      {
         if(_confirmIcon != null)
         {
            if(data != null && data["ecode"] == -30120 && !this._showGoldLand)
            {
               _confirmIcon.y = 36;
            }
            else
            {
               _confirmIcon.y = 62;
            }
         }
      }
      
      public function updateGoldLandTimeShow(param1:int) : void
      {
         if(this._tabNav.selectedIndex == 2)
         {
            if(param1 == 3)
            {
               _confirmIcon["allIsGoldLand"].text = "提示：您的所有土地都已经升级至金牌土地！";
               this._landFlag = false;
            }
            else if(param1 == 1)
            {
               _confirmIcon["allIsGoldLand"].text = "提示：您需要扩地后才能升级！";
               this._landFlag = false;
            }
            else
            {
               _confirmIcon["allIsGoldLand"].text = "测试测试";
               this._landFlag = true;
            }
         }
      }
      
      private function updateGoldLandBtn() : void
      {
         this.updateBtnStatus();
         if(this._landFlag && this._goldCarFlag)
         {
            this.confirmEnable = true;
         }
         else
         {
            this.confirmEnable = false;
         }
      }
      
      override public function onEffectEnd() : void
      {
         super.onEffectEnd();
         this.updateConfirmIconPos();
         this.graphics.clear();
      }
      
      private function renewalsYellowVIP() : void
      {
         this._adText.htmlText = "您是VIP，升级红土地无等级限制。";
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc5_:int = 0;
         this._checking = false;
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = _loc2_.m_extra;
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:int = param1.body["cmdID"] as int;
         if(_loc4_ == CommandDefs.CMD_UPGRADE_BLACK)
         {
            _loc5_ = int(param1.body["__body"]["op"]);
            if(_loc5_ == 0)
            {
               _alertText.htmlText = "获取服务器数据失败！";
               this._cd = 0;
            }
         }
      }
      
      private function refreshJPLand() : void
      {
         var onClick:Function = null;
         onClick = function(param1:MouseEvent):void
         {
            var ss:ServerServices;
            var postValue:Object;
            var onSuccess:Function = null;
            var onRequestFailed:Function = null;
            var e:MouseEvent = param1;
            onSuccess = function(param1:CommandEvent):void
            {
               _buyRequesting = false;
               var _loc2_:Object = ServiceResultVOHelper.getVOData(param1);
               var _loc3_:Object = param1.body["__body"];
               _loc2_["post_data"] = _loc3_;
               if(_loc2_ != null && _loc2_["ret"] == "0")
               {
                  QzoneJSAPI.getInGamePay(_loc2_["url"],onInGameBuySuccess);
               }
               else
               {
                  m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_BUY_FAIL,_loc2_));
               }
            };
            onRequestFailed = function(param1:int, param2:*):void
            {
               _buyRequesting = false;
               m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_BUY_FAIL,param2));
            };
            _timeStamp = getTimer();
            _buyRequesting = true;
            postValue = {
               "appid":353,
               "id":46,
               "num":1,
               "serviceid":1,
               "type":1,
               "name":"",
               "v":2
            };
            ss = ServerServices.getInstance();
            if(ss.getRequestUrl(CommandDefs.CMD_ALLIANCE_PRICE) == "")
            {
               return;
            }
            NetHelper.sendRequest(CommandDefs.CMD_ALLIANCE_PRICE,postValue,onSuccess,onRequestFailed);
         };
         if(_confirmIcon)
         {
            if(_confirmIcon is MovieClip)
            {
               (_confirmIcon as MovieClip).gotoAndStop(3);
            }
            _confirmIcon["buyTime"].buttonMode = true;
            _confirmIcon["buyTime"].addEventListener(MouseEvent.CLICK,onClick,false,0,true);
            _confirmIcon["chanceTime"].text = data["upGoldTime"];
         }
         _alertText.htmlText = "";
         _confirmButton.text = "升级";
         this.updateGoldLandNote();
         this.updateGoldLandBtn();
      }
      
      private function updateGoldLandNote() : void
      {
         m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME,this));
      }
      
      private function hideAdText() : void
      {
         if(Boolean(this._adText) && Boolean(this._adText.parent))
         {
            this._adText.parent.removeChild(this._adText);
         }
      }
   }
}


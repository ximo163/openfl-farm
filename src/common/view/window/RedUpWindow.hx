package common.view.window;

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
import framework.net.CommandDefs;
import framework.net.NetHelper;
import framework.net.ServerServices;
import framework.net.vo.ServiceResultVO;
import framework.net.vo.ServiceResultVOHelper;
import interfaces.IMsgCenter;
import openfl.Lib.getTimer;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TimerEvent;
import openfl.text.StyleSheet;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.utils.Timer;
import shim.As3;
import shim.SymbolClass;

/**
 * common.view.window.RedUpWindow —— RedUpWindow.as 逐句对应（issue #41
 * 替换 #7 的闭包 stub）。红/黑/金牌土地升级窗（ConfirmWindow 族）：
 * TabBar 三页签 + redUpBanner 素材 + 金币/元宝 RadioGroup，黑土地查询
 * 走 CMD_UPGRADE_BLACK（op=0），金牌页签按 jinPaiLand 配置窗口期开放、
 * 购买走 CMD_ALLIANCE_PRICE + QzoneJSAPI.getInGamePay。
 *
 * onRedBannerLoaded 的 gotoAndStop 帧：redUpBanner_v_2 是非预载库，
 * requestClass 被 shim 短路后符号可能仍在 bind 的异步装载窗口里，帧落点
 * 经 SymbolClass.afterAttach 登记（Crop 先例）——原版回调发生在装载完成
 * 后、必落已挂实例，重放时读现场与之一致。
 */
@:keep
class RedUpWindow extends ConfirmWindow {
	// RedUpWindow.as:42
	private var _cd:Int;

	// RedUpWindow.as:44
	private var _rbtnJB:RadioButton;

	// RedUpWindow.as:46
	private var _tf:TextFormat;

	// RedUpWindow.as:48
	private var _adText:TextField = new TextField();

	// RedUpWindow.as:50
	private var _redText:String;

	// RedUpWindow.as:52
	private var _goldCarFlag:Bool = false;

	// RedUpWindow.as:54（const → static final）
	private static final HEIGHT:UInt = 445;

	// RedUpWindow.as:56
	private var _tipText:TextField;

	// RedUpWindow.as:58
	private var _showAdFlag:Bool = true;

	// RedUpWindow.as:60
	private var _targetBlack:Int;

	// RedUpWindow.as:62
	private var _tipText2:TextField;

	// RedUpWindow.as:64
	private var _buyRequesting:Bool = true;

	// RedUpWindow.as:66
	private var _checking:Bool;

	// RedUpWindow.as:68
	private var _tf1:TextFormat;

	// RedUpWindow.as:70
	private var _tipBg:Shape;

	// RedUpWindow.as:72
	private var _tf2:TextFormat;

	// RedUpWindow.as:74
	private var _timer:Timer;

	// RedUpWindow.as:76
	private var _landFlag:Bool = false;

	// RedUpWindow.as:78
	private var ss:Session = Session.getInstance();

	// RedUpWindow.as:80
	private var _radioGroup:RadioGroup;

	// RedUpWindow.as:82
	private var _showGoldLand:Bool = false;

	// RedUpWindow.as:84
	private var _rbtnQB:RadioButton;

	// RedUpWindow.as:86
	private var _tabNav:TabBar;

	// RedUpWindow.as:88
	private var _isFirst:Bool = true;

	// RedUpWindow.as:90
	private var _redEnable:Bool;

	// RedUpWindow.as:92
	private var _checkBlack:Bool;

	// RedUpWindow.as:94（Number → Float）
	private var _timeStamp:Float;

	// RedUpWindow.as:96
	private var _newIcon:MovieClip;

	// RedUpWindow.as:98
	private var _helpText:TextField;

	// RedUpWindow.as:100-116
	public function new(param1:IMsgCenter) {
		super(param1);
		width = 465;
		height = HEIGHT;
		title = "升级土地";
		windowName = Consts.WINDOW_NAME_UPGRADE_RED;
		closeFn = this.onClosed;
		this._redText = "";
		this._redEnable = false;
		this._checkBlack = true;
		this._targetBlack = -1;
		this._cd = 0;
		this._tf = new TextFormat("SimSun", 14, 0, null, null, null, null, null, "left");
		this._tf1 = new TextFormat("SimSun", 14, 8947848, null, null, null, null, null, "left");
		this._tf2 = new TextFormat("SimSun", 14, 16711680, null, null, null, null, null, "left");
	}

	// RedUpWindow.as:118-132
	override private function setSize():Void {
		super.setSize();
		_alertText.x = 5;
		if (data != null && Reflect.field(data, "ecode") == -30120 && !this._showGoldLand) {
			_alertText.y = 220;
		} else {
			_alertText.y = 242;
		}
		_confirmButton.x = (this.width - _confirmButton.width) * 0.5;
		_confirmButton.y = this.height - 45;
	}

	// RedUpWindow.as:134-187
	private function refreshBlack():Void {
		var _loc2_:String = null;
		var _loc3_:String = null;
		var _loc4_:Player = null;
		_confirmButton.text = "升级为黑土地";
		this.confirmEnable = false;
		if (Std.isOfType(_confirmIcon, MovieClip)) {
			cast(_confirmIcon, MovieClip).gotoAndStop(2);
		}
		if (data != null && Reflect.field(data, "ecode") == -30121) {
			_alertText.htmlText = Reflect.field(Language.L, "BlackUpNoLand");
			return;
		}
		if (data != null && Reflect.field(data, "allBlack") == true) {
			_alertText.htmlText = "恭喜您！您已经把所有的土地升级成了黑土地！";
			return;
		}
		var _loc1_:String = Settings.getInstance().getStringAttribute("BlackUpgrade");
		if (_loc1_ != "") {
			_loc2_ = "<font size='14'>QQ农场40级以上玩家可以升级黑土地了，升级之后可以种植更多稀有作物，"
				+ "增加作物产量，缩短作物成熟时间。<br/>扩地内测期间，暂时提供";
			_loc3_ = "优先体验，请大家耐心等待。<br><br>" + "<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + "<font color='#FF6532' size='14'><a href='tools.php?mod=vip"
				+ "tools.php?mod=vip' target='_blank'>开通VIP</a></font></b></font>";
			_loc4_ = Session.getInstance().host;
			if (_loc1_ == "1" && _loc4_._yellowstatus <= 0) {
				_loc2_ += "<font color='#FF6532'>VIP用户</font>";
				_loc2_ += _loc3_;
				_alertText.htmlText = _loc2_;
				return;
			}
			if (_loc1_ == "2" && (_loc4_._yellowstatus > 0 && _loc4_._yellowlevel < 7 || _loc4_._yellowstatus == 0)) {
				_loc2_ += "<font color='#FF6532'>VIP 7级用户</font>";
				_loc2_ += _loc3_;
				_alertText.htmlText = _loc2_;
				return;
			}
		}
		if (Session.getInstance().host.level < 40) {
			_alertText.htmlText = Reflect.field(Language.L, "BlackUp") + "<b><font color=\"#399200\">必须达到40级才能升级黑土地</font></b>";
			return;
		}
		if (this._checkBlack == true) {
			this._targetBlack = -1;
			NetHelper.sendRequest(CommandDefs.CMD_UPGRADE_BLACK, {"op": 0}, this.onBlackUp, this.onNetError);
			this._checking = true;
		}
	}

	// RedUpWindow.as:189-274。AS3 的匿名闭包原样翻成局部函数表达式；
	// `new Date(str)`（字符串解析）→ As3.dateOf，解析失败原版是 Invalid
	// Date、NaN 比较恒 false 不开金牌页签，Haxe null 先判（NPCView 先例）
	override private function init():Void {
		var dTextFormat:TextFormat;
		var st:Settings;
		var jpLand:String;
		var item:DisplayObject;
		var onAddToStage:Event->Void = null;
		var arr:Array<Dynamic> = null;
		var start:Date = null;
		var end:Date = null;
		var now:Float = Math.NaN;
		onAddToStage = function(param1:Event):Void {
			ss.app.useSystemCursor(true);
		};
		var className:String = "redUpBanner";
		var url:String = Settings.getInstance().getSecondUrl(className);
		CommonData.rslManager.requestClass(className, this.onRedBannerLoaded, url);
		addEventListener(Event.ADDED_TO_STAGE, onAddToStage, false, 0, true);
		// 原版是零参匿名函数，openfl 监听签名要事件参，补形参
		addEventListener(Event.REMOVED_FROM_STAGE, function(param1:Event):Void {
			ss.app.useSystemCursor(false);
		});
		this._tabNav = new TabBar();
		WindowTabBarMaker.addTarget(this._tabNav);
		this._tabNav.paddingH = 18;
		this._tabNav.x = 0;
		this._tabNav.y = 33;
		this._tabNav.width = width - 2;
		this._tabNav.addEventListener(Event.CHANGE, this.onTabSwitched);
		this._tabNav.addTab("红土地", Math.NaN, 24);
		this._tabNav.addTab("黑土地", Math.NaN, 24);
		st = Settings.getInstance();
		jpLand = st.getStringAttribute("jinPaiLand");
		if (As3.truthy(jpLand)) {
			arr = jpLand.split("-");
			start = As3.dateOf(arr[0]);
			end = As3.dateOf(arr[1]);
			now = CommonData.serverTime * 1000;
			if (start != null && end != null && now >= start.getTime() && now <= end.getTime()) {
				this._tabNav.addTab("金牌土地", Math.NaN, 24);
				this._showGoldLand = true;
			}
		}
		addChild(this._tabNav);
		_alertText = new TextField();
		dTextFormat = new TextFormat("Verdana", 12, 3355443, null, null, null, null, null, TextFormatAlign.LEFT);
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
		_confirmButton.y = HEIGHT - 45;
		_confirmButton.visible = false;
		_confirmButton.addEventListener(MouseEvent.CLICK, this.confirmButtonClick);
		addChild(_confirmButton);
		this._newIcon = Std.isOfType(Utils.getMaterial("ShopTabNewIcon"),
			MovieClip) ? cast(Utils.getMaterial("ShopTabNewIcon"), MovieClip) : null;
		if (this._newIcon == null) {
			return;
		}
		item = this._tabNav.content.getChildAt(this._tabNav.tabNum - 1);
		this._newIcon.x = item.x + (item.width - this._newIcon.width);
		this._newIcon.y = 29;
		addChild(this._newIcon);
		this._adText.defaultTextFormat = new TextFormat("SimSun", 12, 16755312);
		this._adText.htmlText = "VIP特权升级红土地无需等级限制。";
		this._adText.mouseEnabled = true;
		this._adText.selectable = false;
		this._adText.width = width;
		this._adText.height = 30;
		this.addYellowLink();
	}

	// RedUpWindow.as:276-310
	private function showBlackTip2(param1:String):Void {
		if (param1 == null || param1 == "") {
			if (this._tipBg != null && contains(this._tipBg)) {
				removeChild(this._tipBg);
			}
			if (this._tipText2 != null && contains(this._tipText2)) {
				removeChild(this._tipText2);
			}
			return;
		}
		if (this._tipBg != null) {
			this._tipBg.graphics.clear();
			this._tipBg.graphics.beginFill(16777113, 1);
			this._tipBg.graphics.drawRect(0, 0, 440, 40);
			this._tipBg.graphics.endFill();
		}
		if (this._tipText2 == null) {
			this._tipText2 = new TextField();
			this._tipText2.selectable = false;
			this._tipText2.multiline = false;
			this._tipText2.mouseEnabled = false;
			this._tipText2.width = 440;
			this._tipText2.defaultTextFormat = new TextFormat("SimSun", 13, 0, false, false, false, null, null,
				TextFormatAlign.LEFT);
			this._tipText2.x = this._tipBg.x + 3;
			this._tipText2.y = this._tipBg.y + 23;
		}
		addChild(this._tipText2);
		this._tipText2.htmlText = param1;
	}

	// RedUpWindow.as:312-394。`_loc3_["x"]` 的 Object 键读 → Reflect.field；
	// `as int`/`int()` → As3.intOf（截断+非数字归 0）
	private function onBlackUp(param1:CommandEvent):Void {
		this._checking = false;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result,
			ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Player = Session.getInstance().host;
		var _loc5_:Float = CommonData.serverTime;
		this._targetBlack = As3.intOf(Reflect.field(_loc3_, "place"));
		var _loc6_:String = "升级第<font color=\"#FF6600\">" + (Reflect.field(_loc3_, "place") + 1)
			+ "</font>块黑土地需要<font color=\"#FF6600\">" + Reflect.field(_loc3_, "level")
			+ "</font>级，您可以使用农场" + "<font color=\"#FF6600\">金币</font>或者<font color=\"#FF6600\">元宝</font>升级黑土地。";
		if (_loc4_._money < As3.floatOf(Reflect.field(_loc3_, "money")) || Reflect.field(_loc3_, "ecode") == -30342) {
			_loc6_ += "连续升级黑土地时升级价格将会翻倍增长。";
		}
		_loc6_ += "请您选择：";
		_alertText.htmlText = "<font size='14'>" + _loc6_ + "</font>";
		this._cd = As3.intOf(Reflect.field(_loc3_, "cd"));
		if (this._cd > _loc5_) {
			if (this._timer == null) {
				this._timer = new Timer(1000);
				this._timer.addEventListener(TimerEvent.TIMER, this.onTimer);
			}
			this._timer.start();
			this.onTimer(null);
			this.showRadioGroup(As3.intOf(Reflect.field(_loc3_, "money")),
				_loc4_._yellowstatus == 0 ? As3.intOf(Reflect.field(_loc3_, "qd")) : As3.intOf(Reflect.field(_loc3_, "yqd")),
				_loc4_._money >= As3.floatOf(Reflect.field(_loc3_, "money")) ? true : false, true);
		} else {
			if (this._timer != null) {
				this._timer.stop();
			}
			this.showRadioGroup(As3.intOf(Reflect.field(_loc3_, "money")),
				_loc4_._yellowstatus == 0 ? As3.intOf(Reflect.field(_loc3_, "qd")) : As3.intOf(Reflect.field(_loc3_, "yqd")),
				_loc4_._money >= As3.floatOf(Reflect.field(_loc3_, "money")) ? true : false, false);
			this.showBlackTip("连续升级黑土地时升级价格将会翻倍增长。");
		}
		if (_loc4_._money < As3.floatOf(Reflect.field(_loc3_, "money"))) {
			if (this._cd == 0 || this._cd < _loc5_) {
				this.showBlackTip("您的金币不足，试试用元宝升级黑土地吧！");
			} else {
				this.showBlackTip2("您的金币不足，试试用元宝升级黑土地吧！");
			}
		}
		if (Reflect.field(_loc3_, "ecode") == 0) {
			_confirmButton.enabled = true;
		} else if (Reflect.field(_loc3_, "ecode") == -30342) {
			if (this._cd == 0 || this._cd < _loc5_) {
				this.showBlackTip(Reflect.field(Language.L, "BlackUpNoLand"));
			} else {
				this.showBlackTip2(Reflect.field(Language.L, "BlackUpNoLand"));
			}
		}
		if (_loc4_.level < As3.intOf(Reflect.field(_loc3_, "level"))) {
			if (this._cd == 0 || this._cd < _loc5_) {
				this.showBlackTip("您的等级不够。");
			} else {
				this.showBlackTip2("您的等级不够。");
			}
		}
		this.graphics.clear();
	}

	// RedUpWindow.as:396-430
	override private function confirmButtonClick(param1:MouseEvent = null):Void {
		var _loc2_:Int = 0;
		var _loc3_:Bool = false;
		if (_confirmButton.enabled == true) {
			if (_confirmFn != null) {
				_loc2_ = 0;
				if (this._radioGroup != null) {
					_loc2_ = this._radioGroup.selectedTarget == this._rbtnQB ? 1 : 0;
				}
				_loc3_ = false;
				if (this._tabNav.selectedIndex == 1 && this._cd > 0 && this._cd > CommonData.serverTime) {
					_loc3_ = true;
				}
				if (this._tabNav.selectedIndex == 0) {
					_confirmFn(this._tabNav.selectedIndex, _loc2_, Reflect.field(data, "place"), false);
				} else if (this._tabNav.selectedIndex == 1) {
					_confirmFn(this._tabNav.selectedIndex, _loc2_, this._targetBlack, _loc3_);
				} else {
					_confirmFn(this._tabNav.selectedIndex, 0, this._targetBlack, _loc3_);
				}
			}
			_confirmFn = null;
			super.close();
		}
	}

	// RedUpWindow.as:432-468
	private function onRedBannerLoaded():Void {
		_hideIcon = false;
		_confirmIcon = Std.isOfType(Utils.getMaterial("redUpBanner"),
			Sprite) ? cast(Utils.getMaterial("redUpBanner"), Sprite) : null;
		_confirmIcon.x = 10;
		if (data != null && Reflect.field(data, "ecode") == -30120 && !this._showGoldLand) {
			_confirmIcon.y = 36;
		} else {
			_confirmIcon.y = 62;
		}
		addChild(_confirmIcon);
		if (Std.isOfType(_confirmIcon, MovieClip)) {
			SymbolClass.afterAttach(cast(_confirmIcon, MovieClip), function(mc:MovieClip):Void {
				if (this._tabNav.selectedIndex == 1 || Reflect.field(this.data, "allBlack") == true) {
					mc.gotoAndStop(2);
				} else if (this._tabNav.selectedIndex == 2) {
					mc.gotoAndStop(3);
				} else {
					mc.gotoAndStop(1);
				}
			});
		}
		_confirmButton.visible = true;
		if (this._showGoldLand) {
			this._tabNav.selectedIndex = 2;
		}
		this.showTheTab(this._tabNav.selectedIndex);
		this._isFirst = false;
	}

	// RedUpWindow.as:470-482。`_confirmIcon["chanceTime"]` 时间轴具名子件
	// → As3.childOf + cast TextField（Dynamic 裸写在 cpp 上会 Invalid field）
	private function updateBtnStatus():Void {
		var _loc1_:Int = As3.intOf(As3.parseInt(cast(As3.childOf(_confirmIcon, "chanceTime"), TextField).text));
		if (_loc1_ <= 0) {
			cast(As3.childOf(_confirmIcon, "chanceTime"), TextField).text = "0";
			this._goldCarFlag = false;
		} else {
			this._goldCarFlag = true;
		}
	}

	// RedUpWindow.as:484-496
	private function onTimer(param1:TimerEvent):Void {
		var _loc2_:Int = 0;
		if (this._tabNav != null && this._tabNav.selectedIndex != 1) {
			return;
		}
		if (this._cd > 0) {
			_loc2_ = Std.int(this._cd - CommonData.serverTime);
			this.showBlackTip("黑土地为稀缺资源，升级价格已经上涨一倍，<font color='0xFF6600'>"
				+ DateTimeUtils.formatSecondCount(_loc2_, true) + "</font>后恢复原价。");
		}
	}

	// RedUpWindow.as:498-576
	private function showRadioGroup(param1:Int, param2:Int, param3:Bool, param4:Bool, param5:Bool = false):Void {
		var _loc6_:Int = Std.int(_alertText.y + _alertText.textHeight + 17);
		if (this._rbtnJB == null) {
			this._rbtnJB = new RadioButton(param1 + " 金币");
			this._rbtnJB.textDefaultFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textSelectedFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textOverFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textDisabledFormat = this._tf1;
			this._rbtnJB.x = param5 ? 120 : 60;
			this._rbtnJB.y = _loc6_;
			addChild(this._rbtnJB);
		} else {
			this._rbtnJB.textDefaultFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textSelectedFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textOverFormat = param4 ? this._tf2 : this._tf;
			this._rbtnJB.textDisabledFormat = this._tf1;
			this._rbtnJB.text = param1 + " 金币";
			this._rbtnJB.x = param5 ? 120 : 60;
			this._rbtnJB.y = _loc6_;
			addChild(this._rbtnJB);
		}
		if (this._rbtnQB == null) {
			this._rbtnQB = new RadioButton(param2 + " 元宝");
			this._rbtnQB.textDefaultFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textSelectedFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textOverFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textDisabledFormat = this._tf1;
			this._rbtnQB.x = param5 ? 260 : 200;
			this._rbtnQB.y = _loc6_;
			addChild(this._rbtnQB);
		} else {
			this._rbtnQB.textDefaultFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textSelectedFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textOverFormat = param4 ? this._tf2 : this._tf;
			this._rbtnQB.textDisabledFormat = this._tf1;
			this._rbtnQB.text = param2 + " 元宝";
			this._rbtnQB.x = param5 ? 260 : 200;
			this._rbtnQB.y = _loc6_;
			addChild(this._rbtnQB);
		}
		if (this._radioGroup == null) {
			this._radioGroup = new RadioGroup();
			this._radioGroup.addTarget(this._rbtnJB);
			this._radioGroup.addTarget(this._rbtnQB);
		}
		this._radioGroup.selectedTarget = param3 ? this._rbtnJB : this._rbtnQB;
		if (param3 == true) {
			this._rbtnJB.selected = true;
			this._rbtnJB.enabled = true;
		} else {
			this._rbtnJB.enabled = false;
			this._rbtnQB.selected = true;
		}
		if (this._helpText == null) {
			this._helpText = new TextField();
			this._helpText.selectable = false;
			this._helpText.multiline = false;
			this._helpText.defaultTextFormat = new TextFormat("SimSun", 14, 3381708, false, false, true);
			this._helpText.htmlText = "<a href='http://blog.qq.com/qzone/1006666001/1320119200.htm' target='_blank'>"
				+ "查看升级帮助</a>";
		}
		if (param5 == false) {
			this._helpText.x = 280;
			this._helpText.y = _loc6_;
			addChild(this._helpText);
		}
	}

	// RedUpWindow.as:578-602。`new Date(ms)` → Date.fromTime；`.fullYear` →
	// getFullYear()
	private function addYellowLink():Void {
		var _loc1_:Float = CommonData.serverTime;
		if (_loc1_ <= 0) {
			return;
		}
		var _loc2_:Date = Date.fromTime(_loc1_ * 1000);
		if (_loc2_.getFullYear() > 2011) {
			return;
		}
		var _loc3_:TextField = new TextField();
		_loc3_.multiline = false;
		_loc3_.selectable = false;
		_loc3_.textColor = 16711680;
		_loc3_.autoSize = TextFieldAutoSize.RIGHT;
		_loc3_.htmlText = "<a target=\"_blank\" href=\"tools.php?mod=vip\">" + "农场700万金币等您拿，助您升级黑土地！"
			+ "</a>";
		_loc3_.x = 236;
		_loc3_.y = 36;
		addChild(_loc3_);
		var _loc4_:StyleSheet = new StyleSheet();
		_loc4_.parseCSS("a:link {color:#FF0000;font-family:\"Arial Black\";} a:hover{text-decoration:underline;color:#FF0000;}");
		_loc3_.styleSheet = _loc4_;
	}

	// RedUpWindow.as:604-619
	private function refreshRed():Void {
		_confirmButton.text = "升级为红土地";
		_alertText.htmlText = this._redText;
		this.confirmEnable = this._redEnable;
		if (Std.isOfType(_confirmIcon, MovieClip)) {
			cast(_confirmIcon, MovieClip).gotoAndStop(1);
		}
		if (Reflect.field(data, "ecode") == -30120 || Reflect.field(data, "ecode") == -30121 || Reflect.field(data,
			"ecode") == -30123) {
			return;
		}
		var _loc1_:Player = Session.getInstance().host;
		this.showRadioGroup(As3.intOf(Reflect.field(data, "money")),
			_loc1_._yellowstatus == 0 ? As3.intOf(Reflect.field(data, "qd")) : As3.intOf(Reflect.field(data, "yqd")),
			_loc1_._money >= As3.floatOf(Reflect.field(data, "money")) ? true : false, false, true);
	}

	// RedUpWindow.as:621-631。currentTarget 是 Dynamic，selectedIndex 经
	// Reflect 取后入 int 参
	private function onTabSwitched(param1:Event):Void {
		if (param1 == null || param1.currentTarget == null) {
			return;
		}
		this.showBlackTip(null);
		this.showBlackTip2(null);
		this.hideRadios();
		this.showTheTab(As3.intOf(Reflect.field(param1.currentTarget, "selectedIndex")));
	}

	// RedUpWindow.as:633-661。AS3 嵌套闭包原样翻（局部函数表达式，捕获
	// 等价；内层 param1 影蔽外层同名参，Haxe 允许）
	private function onInGameBuySuccess(param1:Dynamic = null):Void {
		var onSuccess:Dynamic = null;
		var onRequestFailed:Dynamic = null;
		onSuccess = function(param1:CommandEvent):Void {
			if (As3.truthy(param1) && As3.truthy(param1.result) && As3.truthy(param1.result) && Reflect.field(param1.result,
				"m_extra") != null && As3.hasProp(Reflect.field(param1.result, "m_extra"), "goldLandCard")) {
				Session.getInstance().upGoldLandTime = Reflect.field(Reflect.field(param1.result, "m_extra"), "goldLandCard");
				if (_tabNav.selectedIndex == 2) {
					Reflect.setField(this.data, "upGoldTime", Session.getInstance().upGoldLandTime);
					cast(As3.childOf(_confirmIcon, "chanceTime"),
						TextField).text = Std.string(Reflect.field(this.data, "upGoldTime"));
					m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME_CHANGE,
						Session.getInstance().upGoldLandTime));
					updateGoldLandBtn();
				}
			}
		};
		onRequestFailed = function(param1:Dynamic):Void {};
		var ss:ServerServices = ServerServices.getInstance();
		if (ss.getRequestUrl(CommandDefs.REFRESH_UP_GOLD_TIME) == "") {
			return;
		}
		NetHelper.sendRequest(CommandDefs.REFRESH_UP_GOLD_TIME, null, onSuccess, onRequestFailed);
	}

	// RedUpWindow.as:663-721
	override private function setData():Void {
		if (As3.hasProp(data, "text")) {
			this._redText = As3.or(Reflect.field(data, "text"), "");
		}
		this._redEnable = true;
		if (Reflect.field(data, "ecode") == -30120 || Reflect.field(data, "ecode") == -30121 || Reflect.field(data,
			"ecode") == -30123) {
			this._redEnable = false;
		}
		if (As3.hasProp(data, "confirmFn")) {
			_confirmFn = Reflect.field(data, "confirmFn");
		} else {
			_confirmFn = null;
		}
		var _loc1_:Int = HEIGHT;
		if (data != null && Reflect.field(data, "ecode") == -30120 && !this._showGoldLand) {
			_loc1_ -= 24;
			this._tabNav.selectedIndex = 1;
			if (contains(this._tabNav) == true) {
				removeChild(this._tabNav);
			}
			if (contains(this._newIcon) == true) {
				removeChild(this._newIcon);
			}
		} else {
			if (contains(this._tabNav) == false) {
				this._tabNav.selectedIndex = 0;
				addChild(this._tabNav);
			}
			if (contains(this._newIcon) == false) {
				addChild(this._newIcon);
			}
		}
		this.showBlackTip(null);
		this.showBlackTip2(null);
		this.hideRadios();
		if (Reflect.field(data, "ecode") == -30121 || Reflect.field(data, "allBlack") == true) {
			this.height = _loc1_ - (140 - Std.int(_alertText.textHeight));
		}
		this.updateNote();
		if (!this._isFirst) {
			this.showTheTab(this._tabNav.selectedIndex);
		}
		this.graphics.clear();
	}

	// RedUpWindow.as:723-737
	private function hideRadios():Void {
		if (this._rbtnJB != null && contains(this._rbtnJB)) {
			removeChild(this._rbtnJB);
		}
		if (this._rbtnQB != null && contains(this._rbtnQB)) {
			removeChild(this._rbtnQB);
		}
		if (this._helpText != null && contains(this._helpText)) {
			removeChild(this._helpText);
		}
	}

	// RedUpWindow.as:739-756
	private function showTheTab(param1:Int):Void {
		if (param1 == 0) {
			this.refreshRed();
			this.showAdText();
		} else if (param1 == 1) {
			this.refreshBlack();
			this.hideAdText();
		} else if (param1 == 2) {
			this.refreshJPLand();
			this.hideAdText();
		}
	}

	// RedUpWindow.as:758-807
	private function showBlackTip(param1:String):Void {
		if (param1 == null || param1 == "") {
			if (this._tipBg != null) {
				this._tipBg.graphics.clear();
			}
			if (this._tipBg != null && contains(this._tipBg)) {
				removeChild(this._tipBg);
			}
			if (this._tipText != null && contains(this._tipText)) {
				removeChild(this._tipText);
			}
			return;
		}
		if (this._tipBg == null) {
			this._tipBg = new Shape();
			this._tipBg.x = (width - 440) * 0.5;
			this._tipBg.y = _alertText.y + _alertText.textHeight + 68;
			addChild(this._tipBg);
		}
		this._tipBg.graphics.beginFill(16777113, 1);
		this._tipBg.graphics.drawRect(0, 0, 440, 20);
		this._tipBg.graphics.endFill();
		if (this._tipText == null) {
			this._tipText = new TextField();
			this._tipText.selectable = false;
			this._tipText.multiline = false;
			this._tipText.mouseEnabled = false;
			this._tipText.width = 440;
			this._tipText.defaultTextFormat = new TextFormat("SimSun", 13, 0, false, false, false, null, null,
				TextFormatAlign.LEFT);
			this._tipText.x = this._tipBg.x + 3;
			this._tipText.y = this._tipBg.y + 3;
			addChild(this._tipText);
		}
		this._tipText.htmlText = param1;
		if (this._tipBg != null && contains(this._tipBg) == false) {
			addChild(this._tipBg);
		}
		if (this._tipText != null && contains(this._tipText) == false) {
			addChild(this._tipText);
		}
	}

	// RedUpWindow.as:809-825。AS3 的 `!obj` 真值判断 → null 检查
	private function showAdText():Void {
		if (this._showAdFlag) {
			addChild(this._adText);
			this._adText.x = 140;
			if (this._rbtnJB == null || this._rbtnJB.parent == null) {
				this._adText.y = _alertText.y + _alertText.textHeight + (_confirmButton.y - (_alertText.y
					+ _alertText.textHeight) - 10) / 2;
			} else {
				this._adText.y = this._rbtnJB.y + 15 + (_confirmButton.y - (this._rbtnJB.y + 19) - 10) / 2;
			}
			addChild(_confirmButton);
		}
	}

	// RedUpWindow.as:827-837
	private function onClosed(param1:Event):Void {
		this._checkBlack = true;
		this._checking = false;
		this._redText = "";
		this._redEnable = false;
		if (this._timer != null) {
			this._timer.stop();
		}
	}

	// RedUpWindow.as:839-857
	private function updateNote():Void {
		if (Reflect.field(data, "ecode") == -30122 || Reflect.field(data, "ecode") == -30123 || Reflect.field(data,
			"ecode") == 0) {
			if (this.ss.host._yellowstatus > 0 && this.ss.host._yellowlevel > 0) {
				this.renewalsYellowVIP();
			} else {
				this.openYellowVIP();
			}
			this._showAdFlag = true;
		} else {
			this._showAdFlag = false;
		}
	}

	// RedUpWindow.as:859-862
	private function openYellowVIP():Void {
		this._adText.htmlText = "VIP特权升级红土地无需等级限制。";
	}

	// RedUpWindow.as:864-877
	private function updateConfirmIconPos():Void {
		if (_confirmIcon != null) {
			if (data != null && Reflect.field(data, "ecode") == -30120 && !this._showGoldLand) {
				_confirmIcon.y = 36;
			} else {
				_confirmIcon.y = 62;
			}
		}
	}

	// RedUpWindow.as:879-899
	public function updateGoldLandTimeShow(param1:Int):Void {
		if (this._tabNav.selectedIndex == 2) {
			if (param1 == 3) {
				cast(As3.childOf(_confirmIcon, "allIsGoldLand"),
					TextField).text = "提示：您的所有土地都已经升级至金牌土地！";
				this._landFlag = false;
			} else if (param1 == 1) {
				cast(As3.childOf(_confirmIcon, "allIsGoldLand"), TextField).text = "提示：您需要扩地后才能升级！";
				this._landFlag = false;
			} else {
				cast(As3.childOf(_confirmIcon, "allIsGoldLand"), TextField).text = "测试测试";
				this._landFlag = true;
			}
		}
	}

	// RedUpWindow.as:901-912
	private function updateGoldLandBtn():Void {
		this.updateBtnStatus();
		if (this._landFlag && this._goldCarFlag) {
			this.confirmEnable = true;
		} else {
			this.confirmEnable = false;
		}
	}

	// RedUpWindow.as:914-919
	override public function onEffectEnd():Void {
		super.onEffectEnd();
		this.updateConfirmIconPos();
		this.graphics.clear();
	}

	// RedUpWindow.as:921-924
	private function renewalsYellowVIP():Void {
		this._adText.htmlText = "您是VIP，升级红土地无等级限制。";
	}

	// RedUpWindow.as:926-950
	private function onNetError(param1:CommandEvent):Void {
		var _loc5_:Int = 0;
		this._checking = false;
		var _loc2_:ServiceResultVO = Std.isOfType(param1.result,
			ServiceResultVO) ? cast(param1.result, ServiceResultVO) : null;
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Dynamic = _loc2_.m_extra;
		if (_loc3_ == null) {
			return;
		}
		var _loc4_:Int = As3.intOf(Reflect.field(param1.body, "cmdID"));
		if (_loc4_ == CommandDefs.CMD_UPGRADE_BLACK) {
			_loc5_ = As3.intOf(Reflect.field(Reflect.field(param1.body, "__body"), "op"));
			if (_loc5_ == 0) {
				_alertText.htmlText = "获取服务器数据失败！";
				this._cd = 0;
			}
		}
	}

	// RedUpWindow.as:952-1014。onClick 闭包内的嵌套 onSuccess/
	// onRequestFailed 照原样局部函数表达式；`_loc2_["post_data"] = _loc3_`
	// 的 Object 键写 → Reflect.setField
	private function refreshJPLand():Void {
		var onClick:Dynamic = null;
		onClick = function(param1:MouseEvent):Void {
			var ss:ServerServices;
			var postValue:Dynamic;
			var onSuccess:Dynamic = null;
			var onRequestFailed:Dynamic = null;
			onSuccess = function(param1:CommandEvent):Void {
				_buyRequesting = false;
				var _loc2_:Dynamic = ServiceResultVOHelper.getVOData(param1);
				var _loc3_:Dynamic = Reflect.field(param1.body, "__body");
				Reflect.setField(_loc2_, "post_data", _loc3_);
				if (_loc2_ != null && Reflect.field(_loc2_, "ret") == "0") {
					QzoneJSAPI.getInGamePay(Reflect.field(_loc2_, "url"), onInGameBuySuccess);
				} else {
					m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_BUY_FAIL, _loc2_));
				}
			};
			onRequestFailed = function(param1:Int, param2:Dynamic):Void {
				_buyRequesting = false;
				m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_BUY_FAIL, param2));
			};
			_timeStamp = getTimer();
			_buyRequesting = true;
			postValue = {
				"appid": 353,
				"id": 46,
				"num": 1,
				"serviceid": 1,
				"type": 1,
				"name": "",
				"v": 2
			};
			ss = ServerServices.getInstance();
			if (ss.getRequestUrl(CommandDefs.CMD_ALLIANCE_PRICE) == "") {
				return;
			}
			NetHelper.sendRequest(CommandDefs.CMD_ALLIANCE_PRICE, postValue, onSuccess, onRequestFailed);
		};
		if (_confirmIcon != null) {
			if (Std.isOfType(_confirmIcon, MovieClip)) {
				cast(_confirmIcon, MovieClip).gotoAndStop(3);
			}
			cast(As3.childOf(_confirmIcon, "buyTime"), Sprite).buttonMode = true;
			cast(As3.childOf(_confirmIcon, "buyTime"), Sprite).addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			cast(As3.childOf(_confirmIcon, "chanceTime"),
				TextField).text = Std.string(Reflect.field(this.data, "upGoldTime"));
		}
		_alertText.htmlText = "";
		_confirmButton.text = "升级";
		this.updateGoldLandNote();
		this.updateGoldLandBtn();
	}

	// RedUpWindow.as:1016-1019
	private function updateGoldLandNote():Void {
		m_msgCenter.dispatchEvent(new CommonEvent(Consts.GOLD_LAND_UPDATE_TIME, this));
	}

	// RedUpWindow.as:1021-1027。`Boolean(x) && Boolean(x.parent)` 真值判断
	// → null 检查
	private function hideAdText():Void {
		if (this._adText != null && this._adText.parent != null) {
			this._adText.parent.removeChild(this._adText);
		}
	}
}

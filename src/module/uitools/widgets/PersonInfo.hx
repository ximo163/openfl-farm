package module.uitools.widgets;

import common.Consts;
import common.Session;
import common.Settings;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import common.view.MoneyIcon;
import common.view.NumAnimation;
import entities.Player;
import events.CommonEvent;
import module.uitools.UIController;
import module.uitools.UIToolsModel;
import module.uitools.widgets.profile.ExpBar;
import module.uitools.widgets.profile.Level;
import module.uitools.widgets.profile.LevelAndExperience;
import module.uitools.widgets.profile.NameText;
import module.uitools.widgets.profile.PropertyText;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import report.UserActionRecorder;
import shim.As3;
import shim.NavigateToURL;
import shim.QQOutlets;

/**
 * module.uitools.widgets.PersonInfo —— PersonInfo.as 逐句对应（issue #9
 * uitools 片）。顶栏个人信息区（自己/好友两形态）：头像（圆角蒙版 + 点击
 * 开资料窗）、昵称（VIP 黄名）、等级牌、经验条、金币/人品数值；账户变更走
 * NumAnimation 滚动 + 飘字。navigateToURL → shim.NavigateToURL（openfl 支持
 * 不完整，CLAUDE.md 映射规则；VIP 特权链接 html5 开新窗、无浏览器目标留痕）。
 * 头像加载 → shim.QQOutlets.loadImage（headPic 指向宿主 ucenter 头像服务，
 * 独立部署无宿主，no-qzone-jsapi 决策族；空头像框与原版跑本部署包一致，
 * 见 set_url 的 PORT-NOTE）。
 * ROLL_OVER/OUT 监听照抄——悬停合成在 spec/interaction-map.json 落地前不做
 * （见 BLOCKED 项）。
 */
class PersonInfo extends Sprite {
	private var _propertyText:PropertyText;
	private var _level:Level;
	private var _animation:NumAnimation;
	private var _rpValue:Float = 0;
	private var _rpPropertyText:PropertyText;
	private var _levelAndExp:LevelAndExperience;
	private var m_controller:UIController;
	private var _url:String;
	private var _nameText:NameText;
	private var _loader:Loader;
	private var _isMe:Bool;
	private var _expBar:ExpBar;
	private var _msgIcon:MovieClip;
	private var _exp:Int;
	private var _fb:Int;
	private var _goldValue:Float;
	private var _nextExp:Int;

	// PersonInfo.as:67-136
	public function new(param1:UIController, param2:Bool) {
		super();
		this._goldValue = 0;
		this._exp = 0;
		this._nextExp = 0;
		this._fb = 0;
		this._url = "";
		this._loader = null;
		this._levelAndExp = null;
		this._isMe = param2;
		this._animation = null;
		this.m_controller = param1;
		var _loc3_:Int = param2 == true ? 65 : 60;
		this._expBar = new ExpBar();
		this._expBar.name = "__experience__";
		this._expBar.buttonMode = true;
		this._expBar.useHandCursor = true;
		this._expBar.x = _loc3_;
		this._expBar.y = 25;
		this._expBar.percent = 0;
		if (param2 == false) {
			this._expBar.scaleX = 0.9;
		}
		this.addChild(this._expBar);
		this._level = new Level();
		this._level.name = "__level__";
		this._level.buttonMode = true;
		this._level.useHandCursor = true;
		this._level.x = this._expBar.x + this._expBar.width + 3;
		this._level.y = 15;
		this._level.level = 0;
		if (param2 == false) {
			this._level.scaleX = 0.95;
			this._level.scaleY = 0.95;
		}
		this.addChild(this._level);
		this._propertyText = new PropertyText();
		this._propertyText.x = _loc3_;
		this._propertyText.y = 40;
		this.addChild(this._propertyText);
		this._nameText = new NameText();
		this._nameText.x = _loc3_;
		this._nameText.y = 5;
		this.addChild(this._nameText);
		this._rpPropertyText = new PropertyText(MoneyIcon.RP);
		this._rpPropertyText.y = 40;
		this._rpPropertyText.x = this._propertyText.width + this._propertyText.x - 10;
		this.addChild(this._rpPropertyText);
		if (param2 == false) {
			this._msgIcon = cast(Utils.getMaterial("MsgIcon"), MovieClip);
			if (this._msgIcon != null) {
				this._msgIcon.name = "__msg__";
				this._msgIcon.x = this._level.x + this._level.width + 3;
				this._msgIcon.y = 20;
				this._msgIcon.scaleX = 0.8;
				this._msgIcon.scaleY = 0.8;
				this._msgIcon.mouseChildren = false;
				this._msgIcon.buttonMode = true;
				this._msgIcon.gotoAndStop(1);
				this.addChild(this._msgIcon);
			}
		}
		this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
		this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage, false, 0, true);
	}

	// PersonInfo.as:138-141
	public var goldValue(get, set):Float;

	private function get_goldValue():Float {
		return this._goldValue;
	}

	// PersonInfo.as:143-146
	private function gradeToExp(param1:Int):UInt {
		return 100 * param1 * (param1 + 1);
	}

	// PersonInfo.as:148-151（public set updateGold，无 get；NumAnimation 按
	// 属性名 "updateGold" 反射驱动数值滚动）
	public var updateGold(never, set):Float;

	private function set_updateGold(param1:Float):Float {
		this._propertyText.goldValue = param1;
		return param1;
	}

	// PersonInfo.as:153-170
	private function onPhotoClicked(param1:MouseEvent):Void {
		var _loc2_:Player = null;
		if (this._isMe == true) {
			_loc2_ = Session.getInstance().host;
			UserActionRecorder.recordAction(UserActionRecorder.HF_PERSONINFO_OPEN);
		} else {
			_loc2_ = Session.getInstance().currentUser;
		}
		var _loc3_:Dynamic = {
			"index": -1,
			"player": _loc2_
		};
		this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE, _loc3_));
	}

	// PersonInfo.as:172-175
	public var exp(get, set):Int;

	private function get_exp():Int {
		return this._exp;
	}

	// PersonInfo.as:177-208
	private function onAddedToStage(param1:Event):Void {
		this.addEventListener(MouseEvent.ROLL_OVER, this.onRollOver, true, 0, true);
		this.addEventListener(MouseEvent.ROLL_OUT, this.onRollOut, true, 0, true);
		this.addEventListener(MouseEvent.CLICK, this.onClick, false, 0, true);
		if (this._isMe == true && this.m_controller != null && this.m_controller.model != null) {
			this.m_controller.model.addEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, this.onPlayerBaseInfoChanged);
			this.m_controller.model.addEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, this.onAccountInfoChanged);
		}
		var _loc2_:Player = null;
		if (this._isMe == true) {
			_loc2_ = Session.getInstance().host;
		} else {
			_loc2_ = Session.getInstance().currentUser;
		}
		if (_loc2_ == null || _loc2_._yellowstatus == 0) {
			this.color = Level.BLUE;
		} else {
			this.color = Level.YELLOW;
			if (_loc2_ != null) {
				this.vip = "VipL" + _loc2_._yellowlevel;
			}
		}
	}

	// PersonInfo.as:210-217
	public var rpValue(get, set):Float;

	private function set_rpValue(param1:Float):Float {
		if (Math.isNaN(param1) == false) {
			this._rpValue = param1;
			this._rpPropertyText.goldValue = param1;
		}
		return param1;
	}

	private function get_rpValue():Float {
		return this._rpValue;
	}

	// PersonInfo.as:219-229（原文 `param1 == null && param1.target == null`：
	// 事件处理器里 param1 恒非 null、恒不短路，null 时取 .target 同抛——
	// 照抄不纠）
	private function onRollOut(param1:MouseEvent):Void {
		if (param1 == null && param1.target == null) {
			return;
		}
		// PORT-NOTE: e.target 静态是 openfl Object（=Dynamic），.name 裸读在
		// js/eval 恒 undefined（openfl get/set 无物理字段，机制见 handbook/
		// lessons）——(: DisplayObject) 强类型读恢复 AS3 getter 语义，本类
		// 三个鼠标处理器同款
		if ((param1.target : DisplayObject).name == "__vip__" || (param1.target : DisplayObject).name == "__msg__") {
			this.m_controller.hideTip();
		}
	}

	// PersonInfo.as:231-244（set exp：expToGrade 反推等级、gradeToExp 段界、
	// percent 按段内占比；Number 表达式进 ExpBar 的 int 槽位原版隐式截断）
	private function set_exp(param1:Int):Int {
		this._exp = param1;
		this._level.level = this.expToGrade(param1);
		var _loc2_:Int = As3.intOf(this.gradeToExp(this._level.level));
		var _loc3_:Int = As3.intOf(this.gradeToExp(this._level.level + 1));
		this._nextExp = param1 - _loc2_;
		if (_loc3_ - _loc2_ != 0) {
			// AS3 把 Float 表达式塞进 int 槽位（ExpBar.set percent(int)）隐式
			// 截断，Std.int 复刻
			this._expBar.percent = Std.int((this._exp - _loc2_) / (_loc3_ - _loc2_) * 100);
		}
		this._expBar.exp = _loc3_ - _loc2_;
		this._expBar.nextExp = this._nextExp;
		return param1;
	}

	// PersonInfo.as:246-249（Number 返回值进 int 槽位，Std.int 复刻截断）
	private function expToGrade(param1:UInt):Int {
		return Std.int(Math.sqrt((param1 + 25) / 100) - 0.5);
	}

	// PersonInfo.as:251-263
	private function onLeftMessageClicked(param1:MouseEvent):Void {
		if (this._isMe == true) {
			return;
		}
		var _loc2_:Player = Session.getInstance().currentUser;
		var _loc3_:Dynamic = {
			"index": 1,
			"player": _loc2_
		};
		this.m_controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_PROFILE, _loc3_));
	}

	// PersonInfo.as:265-268（public set vip，无 get）
	public var vip(never, set):String;

	private function set_vip(param1:String):String {
		this._nameText.vip = param1;
		return param1;
	}

	// PersonInfo.as:270-274（public set color，无 get）
	public var color(never, set):String;

	private function set_color(param1:String):String {
		this._expBar.color = param1;
		this._level.color = param1;
		return param1;
	}

	// PersonInfo.as:281-319（public set url，无 get；`*` → Dynamic）
	public var url(never, set):Dynamic;

	private function set_url(param1:Dynamic):Dynamic {
		var _loc2_:Sprite = null;
		var _loc3_:Sprite = null;
		if (this._loader == null) {
			this._loader = new Loader();
			this._loader.mouseEnabled = false;
			this._loader.x = 0;
			this._loader.y = 0;
			this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onPhotoLoaded);
			this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onPhotoLoadError);
			_loc2_ = new Sprite();
			_loc2_.x = 1;
			_loc2_.y = 8;
			_loc2_.graphics.clear();
			_loc2_.graphics.beginFill(15658734);
			_loc2_.graphics.drawRoundRect(0, 0, 50, 50, 10, 10);
			_loc2_.graphics.endFill();
			this.addChild(_loc2_);
			_loc3_ = new Sprite();
			_loc3_.x = 1;
			_loc3_.y = 8;
			_loc3_.buttonMode = true;
			_loc3_.useHandCursor = true;
			_loc3_.graphics.clear();
			_loc3_.graphics.beginFill(15658734, 1);
			_loc3_.graphics.drawRect(0, 0, 50, 50);
			_loc3_.graphics.endFill();
			_loc3_.addEventListener(MouseEvent.CLICK, this.onPhotoClicked);
			_loc3_.mask = _loc2_;
			_loc3_.addChild(this._loader);
			this.addChildAt(_loc3_, 0);
		}
		if (param1 != null && param1 != "") {
			// PORT-NOTE(host-avatar)：原版 `this._loader.load(new URLRequest(param1),
			// new LoaderContext(true))` 直连宿主 ucenter 头像服务（headPic 由
			// user_run.php:276 下发）。独立部署没有该宿主：快照 UC_API 是参考部署
			// 的局域网地址（legacy/snapshot/home-config.php:45），照发在任何部署
			// 外环境挂死并记资源错（#9 两轮 CI web-smoke 同点红的根因）。出口并入
			// shim.QQOutlets（no-qzone-jsapi 决策族，deviations 候选待人登记）；
			// 视觉与原版跑本部署包一致（头像取不到 → IOError 吞掉 → 空头像框）。
			QQOutlets.loadImage(this._loader, new URLRequest(param1), new LoaderContext(true));
		}
		return param1;
	}

	// PersonInfo.as:321-349（同 onRollOut：恒不短路的 null 组合判，照抄不纠）
	private function onClick(param1:MouseEvent):Void {
		var _loc2_:String = null;
		if (param1 == null && param1.target == null) {
			return;
		}
		// PORT-NOTE 同 onRollOut：.name 经 ( : DisplayObject) 强类型读
		if ((param1.target : DisplayObject).name == "__experience__" || (param1.target : DisplayObject).name == "__level__") {
			if (this._isMe == false) {
				return;
			}
			if (this._levelAndExp == null) {
				this._levelAndExp = new LevelAndExperience();
			}
			this.m_controller.module.app.farmView.winCtrl.open(this._levelAndExp);
		} else if ((param1.target : DisplayObject).name == "__vip__") {
			_loc2_ = Settings.getInstance().getUrlConfigByName("vipIntroduce");
			NavigateToURL.navigateToURL(new URLRequest(_loc2_));
		} else if ((param1.target : DisplayObject).name == "__msg__") {
			this.onLeftMessageClicked(null);
		}
	}

	// PersonInfo.as:351-354（public set userName，无 get；`param1 || "…"` 的
	// 字符串真值 → As3.or（null/"" 让位后者））
	public var userName(never, set):Dynamic;

	private function set_userName(param1:Dynamic):Dynamic {
		this._nameText.text = cast(As3.or(param1, "农场玩家"), String);
		return param1;
	}

	// PersonInfo.as:356-381
	private function onPlayerBaseInfoChanged(param1:Event):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:UIToolsModel = cast(param1.target, UIToolsModel);
		if (_loc2_ == null) {
			return;
		}
		this.userName = _loc2_.myProfile.m_userName;
		var _loc3_:String = _loc2_.myProfile.m_photoUrl;
		if (QzoneJSAPI.WB == true) {
			if (_loc3_ == null || _loc3_ == "") {
				_loc3_ = "http://mat1.gtimg.com/www/mb/images/head_50.jpg";
			} else {
				_loc3_ += "/50";
			}
		}
		this.url = _loc3_;
	}

	// PersonInfo.as:383-426
	public function setFriendInfo(param1:Player):Void {
		if (this._isMe == true) {
			return;
		}
		if (param1 == null) {
			return;
		}
		if (param1._yellowstatus == 0) {
			this.color = Level.BLUE;
			this.vip = "";
		} else {
			this.color = Level.YELLOW;
			if (param1 != null) {
				this.vip = "VipL" + param1._yellowlevel;
			}
		}
		this.userName = param1._userName;
		this.goldValue = param1._money;
		this.updateGold = param1._money;
		this.exp = param1._exp;
		this.rpValue = param1._moralExp;
		if (QzoneJSAPI.WB == true) {
			if (param1._headPic == null || param1._headPic == "") {
				this.url = "http://mat1.gtimg.com/www/mb/images/head_50.jpg";
			} else {
				this.url = param1._headPic + "/50";
			}
		} else {
			this.url = Utils.formatPhotoUrl50(param1.uin, param1._headPic);
		}
	}

	// PersonInfo.as:428-430
	private function onPhotoLoadError(param1:IOErrorEvent):Void {}

	// PersonInfo.as:432-446
	private function onRollOver(param1:MouseEvent):Void {
		if (param1 == null && param1.target == null) {
			return;
		}
		// PORT-NOTE 同 onRollOut：.name 经 ( : DisplayObject) 强类型读
		if ((param1.target : DisplayObject).name == "__vip__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "点击查看VIP特权详情");
		} else if ((param1.target : DisplayObject).name == "__msg__") {
			this.m_controller.showTip(Consts.TIP_NAME_MOUSE, "给TA留言");
		}
	}

	// PersonInfo.as:448-455
	private function set_goldValue(param1:Float):Float {
		if (param1 < 0) {
			param1 = 0;
		}
		this._goldValue = param1;
		return param1;
	}

	// PersonInfo.as:457-467
	private function onRemovedFromStage(param1:Event):Void {
		this.removeEventListener(MouseEvent.ROLL_OVER, this.onRollOver);
		this.removeEventListener(MouseEvent.ROLL_OUT, this.onRollOut);
		this.removeEventListener(MouseEvent.CLICK, this.onClick);
		if (this._isMe == true && this.m_controller != null && this.m_controller.model != null) {
			this.m_controller.model.removeEventListener(UIToolsModel.EVENT_PLAYER_BASEINFO_CHANGED, this.onPlayerBaseInfoChanged);
			this.m_controller.model.removeEventListener(UIToolsModel.EVENT_PLAYER_ACCOUNT_CHANGED, this.onAccountInfoChanged);
		}
	}

	// PersonInfo.as:469-473
	private function onPhotoLoaded(param1:Event):Void {
		this._loader.width = 50;
		this._loader.height = 50;
	}

	// PersonInfo.as:475-527
	private function onAccountInfoChanged(param1:Event):Void {
		if (param1 == null) {
			return;
		}
		var _loc2_:UIToolsModel = cast(param1.target, UIToolsModel);
		if (_loc2_ == null) {
			return;
		}
		var _loc3_:Float = _loc2_.myProfile.m_gold - this.goldValue;
		if (_loc3_ != 0) {
			if (this._goldValue == 0) {
				this.goldValue = _loc2_.myProfile.m_gold;
				this.updateGold = _loc2_.myProfile.m_gold;
			} else {
				if (this._animation == null) {
					this._animation = new NumAnimation(this, "updateGold", this.goldValue, _loc2_.myProfile.m_gold);
					this._animation.start();
				} else {
					this._animation.end = _loc2_.myProfile.m_gold;
				}
				this.goldValue = _loc2_.myProfile.m_gold;
				this.m_controller.openFloat(Consts.FLOAT_TYPE_MONEY, {
					"x": 100,
					"y": 60,
					"value": _loc3_
				});
			}
		}
		_loc3_ = _loc2_.myProfile.m_exp - this._exp;
		if (_loc3_ != 0) {
			if (this._exp != 0) {
				this.m_controller.openFloat(Consts.FLOAT_TYPE_EXP, {
					"x": 240,
					"y": 17,
					"value": _loc3_
				});
			}
		}
		this.exp = _loc2_.myProfile.m_exp;
		this.rpValue = _loc2_.myProfile.m_moral;
	}
}

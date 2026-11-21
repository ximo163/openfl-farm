package module.uitools.widgets;

import com.qzone.qui.containers.HBox;
import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
import com.qzone.qui.core.Align;
import common.CommonData;
import common.Consts;
import common.Session;
import common.Settings;
import common.misc.Utils;
import common.view.cursor.CursorControl;
import framework.api.beast.BeastAPI;
import framework.base.Module;
import module.uitools.UIController;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import report.ClickReportManager;
import report.UserActionRecorder;
import shim.As3;
import EvtAPI;

/**
 * module.uitools.widgets.ToolBar —— ToolBar.as 逐句对应（issue #9 uitools
 * 片，替换 write-tests 签名 stub；基类回到原版 HBox）。底部工具条：自己农场
 * 锄/包/手/一键 vs 好友农场放虫/放草/偷摘两组按 myHome 切换，渔网组按水池
 * 开放态入列；红土地升级按钮带金土地时间角标。ROLL_OVER/OUT 监听照抄——
 * 悬停合成在 spec/interaction-map.json 落地前不做（见 BLOCKED 项）。
 * 注：initRedUpBtn（:206-248）对缺素材不加守卫，原版缺素材时 addChild(null)
 * 同抛 #2007——eval 无资源环境构造本类即走该路径，单测按 FarmLiteTest 先例
 * 绕开 ctor（test/module/uitools/widgets/ToolBarTest.hx 的说明）。
 */
class ToolBar extends HBox {
	// ToolBar.as:26/:28
	public static final MODULE_EVENT_CLICK_PACK:String = "PackBtnClicked";
	public static final MODULE_EVENT_CLICK_TOOLBOX:String = "ToolBoxBtnClicked";

	// ToolBar.as:30-56
	private static final TOOL_ARROW:Int = 0;
	private static final TOOL_HAND:Int = 1;
	private static final TOOL_ONECLICK:Int = 2;
	private static final TOOL_HOE:Int = 3;
	private static final TOOL_INSECT:Int = 4;
	private static final TOOL_PACK:Int = 5;
	private static final TOOL_TOOLBOX:Int = 6;
	private static final TOOL_THEFT:Int = 7;
	private static final TOOL_UPRED:Int = 8;
	private static final TOOL_WEED:Int = 9;
	private static final TOOL_WILD:Int = 10;
	private static final TOOL_FISHNET:Int = 11;
	private static final TOOL_FISHNET_ALL:Int = 12;
	private static final TOOL_MAX:Int = 13;

	// ToolBar.as:58/:60
	private final TOOLS_TIP:Array<Dynamic> = ["可拖动屏幕", "用来收获果实(R)", "一键摘取(T)", "可用来翻地", "在地里放害虫", "我的物品包", "我的工具箱", "摘取好友的果实(R)", "升级土地", "在地里放杂草", "领养、放养野生动物", "捞鱼", "一键捞鱼"];
	private final TOOLS:Array<Dynamic> = ["ToolArrow", "ToolHand", "OneClickHand", "ToolHoe", "ToolInsect", "ToolPack", "ToolBox", "ToolTheft", "ToolUpgradeNew", "ToolWeed", "Tool_Wild", "ToolFishNet", "ToolFishNetAll"];

	private var _redUpBtn:ToolBase;
	private var _API:BeastAPI;
	private var _showMe:Bool;
	private var _isActived:String = "";
	private var _tools:Array<Dynamic>;
	private var _controller:UIController;
	private var _wildTool:Tool_Wild;

	// ToolBar.as:76-96
	public function new(param1:UIController) {
		super(460, 56);
		this._controller = param1;
		this.alignH = Align.LEFT;
		this.alignV = Align.MIDDLE;
		this.gapH = 10;
		this.gapV = 10;
		this.borderSizeH = 7;
		this.borderSizeV = 2;
		this.autoLayout = true;
		this.verticalScrollPolicy = ScrollPolicy.OFF;
		this.horizontalScrollPolicy = ScrollPolicy.OFF;
		this.defaultSkin = ToolBarBg;
		this._showMe = true;
		// AS3 `new Array(TOOL_MAX)` 预留 13 槽（length 立即 13，addTools 前后
		// 无 length 读取方，槽位 null 复刻长度即可）
		this._tools = [for (_i in 0...TOOL_MAX) null];
		this.addTools();
		this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage, false, 0, true);
		this._API = BeastAPI.getInstance();
		this._API.addEventListener(EvtAPI.REWARD_CHANGE, this.onRewardChange);
	}

	// ToolBar.as:98-101
	public function updateGoldLandTime(param1:Int):Void {
		cast(As3.childOf(cast(this._tools[TOOL_UPRED], ToolBase).getChildAt(0), "updateTime"), TextField).text = Std.string(param1);
	}

	// ToolBar.as:103-116
	private function addToolBtn(param1:Int):Dynamic {
		var _loc2_:Dynamic = Utils.getMaterial(this.TOOLS[param1]);
		if (_loc2_ == null) {
			return null;
		}
		_loc2_.tipText = this.TOOLS_TIP[param1];
		_loc2_.addEventListener(MouseEvent.CLICK, this.onToolClick, false, 0, true);
		_loc2_.addEventListener(MouseEvent.ROLL_OVER, this.onToolRollOver, false, 0, true);
		_loc2_.addEventListener(MouseEvent.ROLL_OUT, this.onToolRollOut, false, 0, true);
		this.addElement(_loc2_);
		return _loc2_;
	}

	// ToolBar.as:118-121
	private function onToolRollOut(param1:MouseEvent):Void {
		this._controller.hideTip();
	}

	// ToolBar.as:123-135
	private function addWildBtn():Tool_Wild {
		if (this._wildTool == null) {
			this._wildTool = new Tool_Wild();
			this._wildTool.tipText = this.TOOLS_TIP[TOOL_WILD];
			this._wildTool.addEventListener(MouseEvent.CLICK, this.onToolClick, false, 0, true);
			this._wildTool.addEventListener(MouseEvent.ROLL_OVER, this.onToolRollOver, false, 0, true);
			this._wildTool.addEventListener(MouseEvent.ROLL_OUT, this.onToolRollOut, false, 0, true);
		}
		this.addElement(this._wildTool);
		return this._wildTool;
	}

	// ToolBar.as:137-143（set）/ :257-260（get）
	public var myHome(get, set):Bool;

	private function set_myHome(param1:Bool):Bool {
		if (this._showMe == param1) {
			return param1;
		}
		this._showMe = param1;
		this.refresh();
		return param1;
	}

	private function get_myHome():Bool {
		return this._showMe;
	}

	// ToolBar.as:147-151
	private function adjustPosition():Void {
		this.x = (this.stage.stageWidth - this.width) * 0.5;
		this.y = this.stage.stageHeight - this.height + 1;
	}

	// ToolBar.as:153-172
	public function refresh():Void {
		if (this._tools == null || this._tools.length == 0) {
			return;
		}
		this.removeAllElements();
		var _loc1_:Bool = Session.getInstance().m_waterPoolOpen;
		if (this._showMe == true) {
			this.width = _loc1_ ? 566 : 460;
		} else {
			this.width = _loc1_ ? 518 : 416;
		}
		this.addTools();
		cast(this._tools[TOOL_WILD], Tool_Wild).actived = this._isActived;
		this.adjustPosition();
	}

	// ToolBar.as:174-204（setCursor：param2 且当前同名 → 弹回 ARROW；行尾按
	// 是否渔网类光标写 Session.m_lockFishMouse）
	private function setCursor(param1:String, param2:Bool = false):Bool {
		var _loc4_:Module = null;
		var _loc5_:CursorControl = null;
		var _loc3_:Bool = false;
		if (this._controller != null) {
			_loc4_ = cast(this._controller.module, Module);
			if (_loc4_ != null && _loc4_.app != null) {
				_loc5_ = _loc4_.app.farmView.cursorCtrl;
				if (param2 == false) {
					_loc5_.setCursor(param1);
					_loc3_ = true;
				} else if (_loc5_.name != param1) {
					_loc5_.setCursor(param1);
					_loc3_ = true;
				} else {
					this.setCursor(Consts.CURSOR_STYLE_ARROW);
					_loc3_ = false;
				}
			}
		}
		Session.getInstance().m_lockFishMouse = param1 == Consts.CURSOR_STYLE_FISHNET || param1 == Consts.CURSOR_STYLE_FISHNET_ALL;
		return _loc3_;
	}

	// ToolBar.as:206-248（`if(!_redUpBtn)`/`if(_loc3_)` 的对象/字符串真值 →
	// truthy；缺素材时 addChild(null) 照原版同抛 #2007——见类头注）
	private function initRedUpBtn():Void {
		var _loc1_:MovieClip = null;
		var _loc2_:Settings = null;
		var _loc3_:String = null;
		var _loc4_:Array<Dynamic> = null;
		var _loc5_:Date = null;
		var _loc6_:Date = null;
		var _loc7_:Float = Math.NaN;
		if (As3.truthy(this._redUpBtn) == false) {
			this._redUpBtn = new ToolBase();
			_loc1_ = cast(Utils.getMaterial(this.TOOLS[TOOL_UPRED]), MovieClip);
			this._redUpBtn.addChild(_loc1_);
			_loc2_ = Settings.getInstance();
			_loc3_ = _loc2_.getStringAttribute("jinPaiLand");
			if (As3.truthy(_loc3_)) {
				// nc_addon.php:113 配置形态 `7/10/2012-11/12/2012 23:59:59`，
				// 两段都是美式 m/d/Y[ H:M:S]
				_loc4_ = _loc3_.split("-");
				_loc5_ = As3.dateOf(_loc4_[0]);
				_loc6_ = As3.dateOf(_loc4_[1]);
				_loc7_ = CommonData.serverTime * 1000;
				// PORT-NOTE: AS3 `new Date(无效串)` 得 .time 为 NaN 的 Date；
				// As3.dateOf 解析失败回 null，按 NaN 语义代入
				var startTime:Float = _loc5_ == null ? Math.NaN : _loc5_.getTime();
				var endTime:Float = _loc6_ == null ? Math.NaN : _loc6_.getTime();
				if (_loc7_ >= startTime && _loc7_ <= endTime) {
					// PORT-NOTE: 原版 `_loc1_["updateTime"]` 是时间轴具名子实例
					// （AS3 dynamic 查找），Haxe 经 As3.childOf 补全（#8 Crop step1 先例）
					cast(As3.childOf(_loc1_, "updateTime"), TextField).text = Std.string(Session.getInstance().upGoldLandTime);
				} else {
					cast(As3.childOf(_loc1_, "updateTime"), TextField).text = "0";
				}
			} else {
				cast(As3.childOf(_loc1_, "updateTime"), TextField).text = "0";
			}
		}
		this._redUpBtn.tipText = this.TOOLS_TIP[TOOL_UPRED];
		this._redUpBtn.addEventListener(MouseEvent.CLICK, this.onToolClick, false, 0, true);
		this._redUpBtn.addEventListener(MouseEvent.ROLL_OVER, this.onToolRollOver, false, 0, true);
		this._redUpBtn.addEventListener(MouseEvent.ROLL_OUT, this.onToolRollOut, false, 0, true);
		this.addElement(this._redUpBtn);
		this._tools[TOOL_UPRED] = this._redUpBtn;
	}

	// ToolBar.as:250-255
	private function onAddedToStage(param1:Event):Void {
		this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyUp, false, 0, true);
		this.adjustPosition();
	}

	// ToolBar.as:262-265（currentTarget.tipText：素材剪辑动态属性，Object 点取）
	private function onToolRollOver(param1:MouseEvent):Void {
		this._controller.showTip(Consts.TIP_NAME_MOUSE, param1.currentTarget.tipText);
	}

	// ToolBar.as:267-388
	private function onToolClick(param1:MouseEvent):Void {
		Session.getInstance().m_lockFishMouse = false;
		if (param1.currentTarget == this._tools[TOOL_ARROW]) {
			this.setCursor(Consts.CURSOR_STYLE_ARROW);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_move.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_move.click");
			}
		} else if (param1.currentTarget == this._tools[TOOL_UPRED]) {
			this._controller.module.app.dispatchEvent(new Event(Consts.MSG_SHOW_UPGRADE_RED));
			ClickReportManager.reportClick("down.banner.icon_upgrade.click");
		} else if (param1.currentTarget == this._tools[TOOL_WEED]) {
			this.setCursor(Consts.CURSOR_STYLE_WEED, true);
			ClickReportManager.reportClick("friend.down.banner.icon_put_grass.click");
		} else if (param1.currentTarget == this._tools[TOOL_INSECT]) {
			this.setCursor(Consts.CURSOR_STYLE_INSET, true);
			ClickReportManager.reportClick("friend.down.banner.icon_put_bug.click");
		} else if (param1.currentTarget == this._tools[TOOL_HOE]) {
			this.setCursor(Consts.CURSOR_STYLE_HOE, true);
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_HOE_CLICKED);
			ClickReportManager.reportClick("down.banner.icon_shovel.click");
		} else if (param1.currentTarget == this._tools[TOOL_PACK]) {
			this.setCursor(Consts.CURSOR_STYLE_ARROW);
			this.dispatchEvent(new Event(MODULE_EVENT_CLICK_PACK));
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_PACK_CLICKED);
			ClickReportManager.reportClick("down.banner.icon_backpack.click");
		} else if (param1.currentTarget == this._tools[TOOL_TOOLBOX]) {
			this.setCursor(Consts.CURSOR_STYLE_ARROW);
			this.dispatchEvent(new Event(MODULE_EVENT_CLICK_TOOLBOX));
			BeastAPI.getInstance().hideBeastPack();
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_TOOLBOX_CLICKED);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_toolbox.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_toolbox.click");
			}
		} else if (param1.currentTarget == this._tools[TOOL_HAND]) {
			this.setCursor(Consts.CURSOR_STYLE_HAND, true);
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_HAND_CLICKED);
			ClickReportManager.reportClick("down.banner.icon_harvest.click");
		} else if (param1.currentTarget == this._tools[TOOL_ONECLICK]) {
			this.setCursor(Consts.CURSOR_STYLE_ONEHAND, true);
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_ONECLICK_CLICKED);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_all_harvest.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_all_harvest.click");
			}
		} else if (param1.currentTarget == this._tools[TOOL_THEFT]) {
			this.setCursor(Consts.CURSOR_STYLE_HAND, true);
			ClickReportManager.reportClick("friend.down.banner.icon_harvest.click");
		} else if (param1.currentTarget == this._tools[TOOL_WILD]) {
			this.setCursor(Consts.CURSOR_STYLE_ARROW);
			BeastAPI.getInstance().showBeastPack();
			UserActionRecorder.recordAction(UserActionRecorder.HF_TOOL_WILD_CLICKED);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_wild_animal.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_wild_animal.click");
			}
		} else if (param1.currentTarget == this._tools[TOOL_FISHNET]) {
			this.setCursor(Consts.CURSOR_STYLE_FISHNET);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_fishing.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_fishing.click");
			}
		} else if (param1.currentTarget == this._tools[TOOL_FISHNET_ALL]) {
			this.setCursor(Consts.CURSOR_STYLE_FISHNET_ALL);
			if (Session.getInstance().me) {
				ClickReportManager.reportClick("down.banner.icon_all_fishing.click");
			} else {
				ClickReportManager.reportClick("friend.down.banner.icon_all_fishing.click");
			}
		}
		param1.stopPropagation();
	}

	// ToolBar.as:390-413（焦点在 TextField 时忽略；switch 无 default 分支）
	private function onKeyUp(param1:KeyboardEvent):Void {
		if (Std.isOfType(param1.target, TextField)) {
			return;
		}
		switch (param1.keyCode) {
			case 81:
				this.setCursor(Consts.CURSOR_STYLE_WATER);
			case 87:
				this.setCursor(Consts.CURSOR_STYLE_HOOK);
			case 69:
				this.setCursor(Consts.CURSOR_STYLE_PESTICIDE);
			case 82:
				this.setCursor(Consts.CURSOR_STYLE_HAND);
			case 84:
				this.setCursor(Consts.CURSOR_STYLE_ONEHAND);
		}
	}

	// ToolBar.as:415-417（空实现覆写：工具条不自绘背景，皮肤由 setSkin 铺）
	private override function updateBackGround():Void {}

	// ToolBar.as:419-422
	private function hideFn():Void {
		this.dispatchEvent(new Event("hidebeast"));
	}

	// ToolBar.as:424-457（工具组装配：自己农场 vs 好友农场两组、渔网组按
	// 水池开放态、验证开关包住整段装配）
	private function addTools():Void {
		this.enableValidate = false;
		this._tools[TOOL_ARROW] = this.addToolBtn(TOOL_ARROW);
		if (this._showMe == true) {
			this.initRedUpBtn();
			this._tools[TOOL_HOE] = this.addToolBtn(TOOL_HOE);
			this._tools[TOOL_PACK] = this.addToolBtn(TOOL_PACK);
		} else {
			this._tools[TOOL_INSECT] = this.addToolBtn(TOOL_INSECT);
			this._tools[TOOL_WEED] = this.addToolBtn(TOOL_WEED);
		}
		this._tools[TOOL_TOOLBOX] = this.addToolBtn(TOOL_TOOLBOX);
		this._tools[TOOL_WILD] = this.addWildBtn();
		if (this._showMe == true) {
			this._tools[TOOL_HAND] = this.addToolBtn(TOOL_HAND);
		} else {
			this._tools[TOOL_THEFT] = this.addToolBtn(TOOL_THEFT);
		}
		this._tools[TOOL_ONECLICK] = this.addToolBtn(TOOL_ONECLICK);
		if (Session.getInstance().m_waterPoolOpen == true) {
			this._tools[TOOL_FISHNET] = this.addToolBtn(TOOL_FISHNET);
			this._tools[TOOL_FISHNET_ALL] = this.addToolBtn(TOOL_FISHNET_ALL);
		}
		this.enableValidate = true;
		this.validateNow();
	}

	// ToolBar.as:459-466
	public function removeWildText():Void {
		var _loc1_:Tool_Wild = cast(this._tools[TOOL_WILD], Tool_Wild);
		if (_loc1_ != null) {
			_loc1_.removeText();
		}
	}

	// ToolBar.as:468-472
	private function onRewardChange(param1:EvtAPI):Void {
		this._isActived = cast(param1.data, String);
		cast(this._tools[TOOL_WILD], Tool_Wild).actived = cast(param1.data, String);
	}

	// ToolBar.as:474-481（override setSkin；`new defaultSkin()` 的动态类
	// 实例化 → Type.createInstance，ToolBoxBar 同款 PORT-NOTE）
	private override function setSkin():Void {
		if (this.defaultSkin != null) {
			this._skin = Type.createInstance(this.defaultSkin, []);
			this.addChildAt(this._skin, 0);
		}
	}
}

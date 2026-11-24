package module.load;

import common.Consts;
import common.view.DataLoading;
import events.CommonEvent;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * module.load.UserChangingBar —— UserChangingBar.as 逐句对应（issue #43 真身，
 * 替换 #7 闭包 stub）。切换用户时的 60% 白遮罩 + 居中转圈 + 错误文案条：
 * ADDED_TO_STAGE 后建三件并听 MSG_USER_SWITCH_FLAG，error 缺位/空串走
 * showLoading 驱动遮罩与转圈，非空走错误文案（<a href='event:…'> 链接点击
 * 重派发 __reload__ 载荷再切一次）。FarmStage.initTopLayer 建进 LAYER_TOPMOST。
 */
@:keep
class UserChangingBar extends Sprite {
	// UserChangingBar.as:16（居中转圈件）
	private var m_dataLoading:DataLoading;

	// UserChangingBar.as:18（错误文案/重试链接）
	private var m_textField:TextField;

	// UserChangingBar.as:20（60% 白遮罩）
	private var m_mask:Sprite;

	// UserChangingBar.as:22
	private var m_app:IMsgCenter;

	// UserChangingBar.as:24-29
	public function new(param1:IMsgCenter) {
		super();
		this.m_app = param1;
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
	}

	// UserChangingBar.as:31-57（三件按舞台尺寸建：遮罩全屏、转圈居中、
	// 文案条在中心左偏 50px；初始全隐，等切换结果驱动）
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		this.m_mask = new Sprite();
		this.m_mask.graphics.beginFill(16777215, 0.6);
		this.m_mask.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		this.m_mask.graphics.endFill();
		this.m_mask.visible = false;
		addChild(this.m_mask);
		this.m_dataLoading = new DataLoading();
		this.m_dataLoading.x = stage.stageWidth / 2;
		this.m_dataLoading.y = stage.stageHeight / 2;
		this.m_dataLoading.visible = false;
		addChild(this.m_dataLoading);
		this.m_textField = new TextField();
		this.m_textField.addEventListener(TextEvent.LINK, this.onLinkClicked);
		this.m_textField.defaultTextFormat = new TextFormat("Verdana", 14, 3355443);
		this.m_textField.width = 200;
		this.m_textField.height = 25;
		this.m_textField.x = stage.stageWidth / 2 - 50;
		this.m_textField.y = stage.stageHeight / 2;
		this.m_textField.text = "";
		this.m_textField.selectable = false;
		this.m_textField.visible = false;
		addChild(this.m_textField);
		this.m_app.addEventListener(Consts.MSG_USER_SWITCH_FLAG, this.onUserSwitchResult);
	}

	// UserChangingBar.as:59-76（error 键缺位或空串走 showLoading 驱动遮罩/
	// 转圈，非空走错误文案覆盖。PORT-NOTE：`data["error"] == undefined` 按
	// OperationQueue 先例译 hasField + 非 null 双查；`as Boolean` 是类型检查
	// 不是真值化——非 Boolean（含 null）落 false）
	private function onUserSwitchResult(param1:CommonEvent):Void {
		if (param1 == null || param1.data == null) {
			return;
		}
		if (!(Reflect.hasField(param1.data, "error") && Reflect.field(param1.data, "error") != null)
			|| Reflect.field(param1.data, "error") == "") {
			var _loc1_:Dynamic = Reflect.field(param1.data, "showLoading");
			var _loc2_:Bool = false;
			if (Std.isOfType(_loc1_, Bool)) {
				_loc2_ = _loc1_;
			}
			this.m_dataLoading.visible = _loc2_;
			this.m_mask.visible = _loc2_;
		} else {
			this.m_textField.htmlText = Reflect.field(param1.data, "error");
			this.m_textField.visible = true;
			this.m_dataLoading.visible = false;
		}
	}

	// UserChangingBar.as:78-83（onLinkClicked：__reload__ 载荷重派发
	// MSG_USER_SWITCH_FLAG + 文案隐藏转圈复亮）
	private function onLinkClicked(param1:TextEvent):Void {
		this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG, {"__reload__": true}));
		this.m_textField.visible = false;
		this.m_dataLoading.visible = true;
	}
}

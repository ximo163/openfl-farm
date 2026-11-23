package framework.layers;

import common.Consts;
import common.view.cursor.CursorControl;
import events.CursorEvent;
import framework.base.BaseLayer;
import openfl.display.MovieClip;
import openfl.errors.ArgumentError;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;

/**
 * framework.layers.CursorLayer —— CursorLayer.as 逐句对应（issue #43 真身，
 * 替换 #7 闭包 stub）。光标层：SET_CURSOR 按注册表反射构造光标剪辑并跟随，
 * SWITCH_CURSOR 在系统鼠标与剪辑光标间切换（Mouse.show/hide 对偶），stage
 * 四鼠标事件驱动按下/弹起/点击帧与移动跟随。触屏下本层实际可见性由
 * shim 适配层按 spec/interaction-map.json 决定，不进翻译类（任务边界）。
 */
@:keep
class CursorLayer extends BaseLayer {
	// CursorLayer.as:15
	private var m_cursorCtrl:CursorControl;

	// CursorLayer.as:17
	private var m_currentCursor:MovieClip;

	// CursorLayer.as:19-31
	public function new(param1:CursorControl) {
		if (param1 != null) {
			super(param1.getMsgCenter());
			this.m_cursorCtrl = param1;
			mouseEnabled = false;
			mouseChildren = false;
			this.name = Consts.LAYER_CURSOR;
			return;
		}
		throw new ArgumentError("Null parameter");
	}

	// CursorLayer.as:33-47（stageDown：ARROW 光标按下列 2 帧）
	private function stageDown(param1:MouseEvent):Void {
		if (this.m_currentCursor == null) {
			return;
		}
		if (this.m_currentCursor.visible == false) {
			return;
		}
		if (this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW) {
			this.m_currentCursor.gotoAndStop(2);
		}
	}

	// CursorLayer.as:49-56（remove：摘除当前光标并置空）
	private function remove():Void {
		if (this.m_currentCursor != null) {
			removeChild(this.m_currentCursor);
			this.m_currentCursor = null;
		}
	}

	// CursorLayer.as:58-66（cursorMove：可见光标跟随 + 立即重绘）
	private function cursorMove(param1:MouseEvent):Void {
		if (this.m_currentCursor == null || this.m_currentCursor.visible == false) {
			return;
		}
		this.setPosition(Std.int(param1.stageX), Std.int(param1.stageY));
		param1.updateAfterEvent();
	}

	// CursorLayer.as:68-82（stageUp：ARROW 光标弹回 1 帧）
	private function stageUp(param1:MouseEvent):Void {
		if (this.m_currentCursor == null) {
			return;
		}
		if (this.m_currentCursor.visible == false) {
			return;
		}
		if (this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW) {
			this.m_currentCursor.gotoAndStop(1);
		}
	}

	// CursorLayer.as:84-104（onSwitchCursor：system 显系统鼠标藏剪辑，
	// 有剪辑则亮剪辑藏系统鼠标，都没有显系统鼠标）
	private function onSwitchCursor(param1:CursorEvent):Void {
		if (param1.cursorName == Consts.CURSOR_SYSTEM) {
			if (this.m_currentCursor != null) {
				this.m_currentCursor.visible = false;
			}
			Mouse.show();
		} else if (this.m_currentCursor != null) {
			this.m_currentCursor.visible = true;
			this.setPosition(Std.int(mouseX), Std.int(mouseY));
			Mouse.hide();
		} else {
			Mouse.show();
		}
	}

	// CursorLayer.as:106-121（stageClick：非 ARROW 可见光标点击播 2 帧起）
	private function stageClick(param1:MouseEvent):Void {
		if (this.m_currentCursor == null) {
			return;
		}
		if (this.m_currentCursor.visible == false) {
			return;
		}
		if (this.m_currentCursor.name == Consts.CURSOR_STYLE_ARROW) {
			return;
		}
		this.m_currentCursor.gotoAndPlay(2);
	}

	// CursorLayer.as:123-139（setPosition：CROPSEED 光标按自身宽高居中，
	// 其余光标直接落位）
	private function setPosition(param1:Int, param2:Int):Void {
		if (this.m_currentCursor == null) {
			return;
		}
		if (this.m_currentCursor.name == Consts.CURSOR_STYLE_CROPSEED) {
			this.m_currentCursor.x = param1 - this.m_currentCursor.width * 0.5;
			this.m_currentCursor.y = param2 - this.m_currentCursor.height * 0.5;
		} else {
			this.m_currentCursor.x = param1;
			this.m_currentCursor.y = param2;
		}
	}

	// CursorLayer.as:141-148（setCurrentCursor：藏系统鼠标、换剪辑、落当前
	// 鼠标位）
	private function setCurrentCursor(param1:MovieClip):Void {
		Mouse.hide();
		this.remove();
		this.m_currentCursor = param1;
		addChild(this.m_currentCursor);
		this.setPosition(Std.int(mouseX), Std.int(mouseY));
	}

	// CursorLayer.as:150-159（init：msgCenter 光标双事件 + stage 鼠标四连，
	// init 由 BaseLayer 的 ADDED_TO_STAGE 触发，stage 非空）
	override private function init():Void {
		super.init();
		m_msgCenter.addEventListener(CursorEvent.SET_CURSOR, this.onSetCursor, false, 0, true);
		m_msgCenter.addEventListener(CursorEvent.SWITCH_CURSOR, this.onSwitchCursor, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, this.stageDown, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, this.stageUp, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, this.cursorMove, false, 0, true);
		stage.addEventListener(MouseEvent.CLICK, this.stageClick, false, 0, true);
	}

	// CursorLayer.as:161-199（onSetCursor：空名/无控件/未注册名都回落系统
	// 光标；注册名反射构造，带参写 cursorArgument（PORT-NOTE：光标类的
	// (never,set) 属性，js 裸 Dynamic 写只落影子字段，走 Reflect.setProperty，
	// LevelUpWindow 先例）；name/mouse* 是 openfl 真属性，cast 后写真身）
	private function onSetCursor(param1:CursorEvent):Void {
		var _loc3_:Class<Dynamic> = null;
		var _loc4_:MovieClip = null;
		var _loc2_:Bool = false;
		if (param1.cursorName == "") {
			_loc2_ = true;
		}
		if (this.m_cursorCtrl == null) {
			_loc2_ = true;
		}
		if (_loc2_ == false) {
			_loc3_ = this.m_cursorCtrl.getClass(param1.cursorName);
			if (_loc3_ != null) {
				_loc4_ = cast(Type.createInstance(_loc3_, []), MovieClip);
				if (param1.cursorArgument != "") {
					Reflect.setProperty(_loc4_, "cursorArgument", param1.cursorArgument);
				}
				_loc4_.name = param1.cursorName;
				_loc4_.mouseChildren = false;
				_loc4_.mouseEnabled = false;
				this.setCurrentCursor(_loc4_);
			} else {
				_loc2_ = true;
			}
		}
		if (_loc2_ == true) {
			Mouse.show();
			this.remove();
		}
	}
}

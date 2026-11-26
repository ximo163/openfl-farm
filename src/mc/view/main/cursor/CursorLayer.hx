package mc.view.main.cursor;

import mc.control.ViewControl;
import mc.events.CursorEvent;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.ui.Mouse;
import shim.As3;

/**
 * mc.view.main.cursor.CursorLayer —— CursorLayer.as 逐句对应（issue #87
 * 「光标」片真身）。光标层：挂 stage 级 down/up/move/click 转发给
 * currentCursor，三路 CursorEvent（CURSOR/API/USE_TYPE）换光标——CURSOR 走
 * CursorClassLib 取类、API 用 materialName 直接建 CursorAPI、USE_TYPE
 * "system" 切系统光标。PORT-NOTE：currentCursor 静态类型已是 BaseCursor
 * （Sprite 子类），原文遍地的 `as DisplayObject` 是拓宽转型、Haxe 直读
 * 属性即可，不逐处照抄括弧。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorLayer.as。
 */
@:keep
class CursorLayer extends Sprite {
	// CursorLayer.as:14
	private var currentCursor:BaseCursor;

	// CursorLayer.as:16-20
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
	}

	// CursorLayer.as:22-33
	private function stageDown(param1:MouseEvent):Void {
		if (this.currentCursor == null) {
			return;
		}
		if (this.currentCursor.visible == false) {
			return;
		}
		this.currentCursor.down();
	}

	// CursorLayer.as:35-70（CursorClassLib 取类建光标；cursorName=="" 或类
	// 缺失则 Mouse.show + 摘当前光标。PORT-NOTE：`param1.cursorArgument != ""`
	// 是 Dynamic 与空串的松不等——空串唯一跳过形态，对象/null 都放行（AS3
	// 松等下 null/object 与 "" 皆不等），走 As3.eqString 取反，lessons #8 条）
	private function setCursorHandler(param1:CursorEvent):Void {
		var _loc3_:Class<Dynamic> = null;
		var _loc4_:BaseCursor = null;
		var _loc2_:Bool = false;
		if (param1.cursorName == "") {
			_loc2_ = true;
		}
		if (!_loc2_) {
			_loc3_ = CursorClassLib.getClass(param1.cursorName);
			if (_loc3_ != null) {
				_loc4_ = cast Type.createInstance(_loc3_, []);
				if (!As3.eqString(param1.cursorArgument, "")) {
					_loc4_.cursorArgument = param1.cursorArgument;
				}
				this.setCurrentCursor(_loc4_);
			} else {
				_loc2_ = true;
			}
		}
		if (_loc2_) {
			Mouse.show();
			if (this.currentCursor != null) {
				removeChild(this.currentCursor);
				this.currentCursor = null;
			}
		}
	}

	// CursorLayer.as:72-84
	private function onAddedToStage(param1:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
		mouseEnabled = false;
		mouseChildren = false;
		ViewControl.getInstance().addEventListener(CursorEvent.CURSOR, this.setCursorHandler, false, 0, true);
		ViewControl.getInstance().addEventListener(CursorEvent.API, this.setAPICursorHandler, false, 0, true);
		ViewControl.getInstance().addEventListener(CursorEvent.USE_TYPE, this.setTypeHandler, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, this.stageDown, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_UP, this.stageUp, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, this.cursorMove, false, 0, true);
		stage.addEventListener(MouseEvent.CLICK, this.stageClick, false, 0, true);
	}

	// CursorLayer.as:86-109（"system" 则隐自定义光标 Mouse.show，否则挪
	// 光标到 mouseX/mouseY 并 Mouse.hide）
	private function setTypeHandler(param1:CursorEvent):Void {
		if (param1.cursorName == "system") {
			if (this.currentCursor != null) {
				this.currentCursor.visible = false;
			}
			Cursor.system = true;
			Mouse.show();
		} else if (this.currentCursor != null) {
			this.currentCursor.visible = true;
			this.currentCursor.x = mouseX;
			this.currentCursor.y = mouseY;
			Mouse.hide();
			Cursor.system = false;
		} else {
			Mouse.show();
		}
	}

	// CursorLayer.as:111-124
	private function cursorMove(param1:MouseEvent):Void {
		if (this.currentCursor == null) {
			return;
		}
		if (this.currentCursor.visible == false) {
			return;
		}
		this.currentCursor.x = param1.stageX;
		this.currentCursor.y = param1.stageY;
		param1.updateAfterEvent();
	}

	// CursorLayer.as:126-137
	private function stageUp(param1:MouseEvent):Void {
		if (this.currentCursor == null) {
			return;
		}
		if (this.currentCursor.visible == false) {
			return;
		}
		this.currentCursor.up();
	}

	// CursorLayer.as:139-150
	private function stageClick(param1:MouseEvent):Void {
		if (this.currentCursor == null) {
			return;
		}
		if (this.currentCursor.visible == false) {
			return;
		}
		this.currentCursor.click();
	}

	// CursorLayer.as:152-184（materialName 建 CursorAPI；空则回系统光标）
	private function setAPICursorHandler(param1:CursorEvent):Void {
		var _loc3_:String = null;
		var _loc4_:BaseCursor = null;
		var _loc2_:Bool = false;
		if (param1.cursorName == "") {
			_loc2_ = true;
		}
		if (!_loc2_) {
			_loc3_ = param1.materialName;
			if (_loc3_ != null) {
				_loc4_ = cast new CursorAPI(_loc3_);
				_loc4_.cursorArgument = param1.cursorArgument;
				this.setCurrentCursor(_loc4_);
			} else {
				_loc2_ = true;
			}
		}
		if (_loc2_) {
			Mouse.show();
			if (this.currentCursor != null) {
				removeChild(this.currentCursor);
				this.currentCursor = null;
			}
		}
	}

	// CursorLayer.as:186-199（Mouse.hide + 换入新光标置 mouseX/mouseY +
	// Cursor.currentCursor 同步）
	private function setCurrentCursor(param1:BaseCursor):Void {
		Mouse.hide();
		if (this.currentCursor != null) {
			removeChild(this.currentCursor);
			this.currentCursor = null;
		}
		this.currentCursor = param1;
		addChild(this.currentCursor);
		this.currentCursor.x = mouseX;
		this.currentCursor.y = mouseY;
		Cursor.currentCursor = this.currentCursor;
	}
}

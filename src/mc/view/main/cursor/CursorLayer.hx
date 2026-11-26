package mc.view.main.cursor;

import mc.events.CursorEvent;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * mc.view.main.cursor.CursorLayer —— CursorLayer.as 的签名面 stub（原类
 * 201 loc，issue #87「光标」片充真身）。光标层：挂 stage 级 down/up/move/
 * click 转发给 currentCursor，三路 CursorEvent（CURSOR/API/USE_TYPE）
 * 换光标——CURSOR 走 CursorClassLib 取类、API 用 materialName 直接建
 * CursorAPI、USE_TYPE "system" 切系统光标。成员签名逐字取自反编译原文，
 * 方法体随 implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorLayer.as。
 */
@:keep
class CursorLayer extends Sprite {
	// CursorLayer.as:14
	private var currentCursor:BaseCursor;

	// CursorLayer.as:16-20（ctor 挂 ADDED_TO_STAGE 监听——有副作用，入 stub 掷）
	public function new() {
		super();
		throw new Error("not implemented");
	}

	// CursorLayer.as:22-33
	private function stageDown(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:35-70（CursorClassLib 取类建光标；cursorName=="" 或类
	// 缺失则 Mouse.show + 摘当前光标）
	private function setCursorHandler(param1:CursorEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:72-84
	private function onAddedToStage(param1:Event):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:86-109（"system" 则隐自定义光标 Mouse.show，否则挪
	// 光标到 mouseX/mouseY 并 Mouse.hide）
	private function setTypeHandler(param1:CursorEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:111-124
	private function cursorMove(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:126-137
	private function stageUp(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:139-150
	private function stageClick(param1:MouseEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:152-184（materialName 建 CursorAPI；空则回系统光标）
	private function setAPICursorHandler(param1:CursorEvent):Void {
		throw new Error("not implemented");
	}

	// CursorLayer.as:186-199（Mouse.hide + 换入新光标置 mouseX/mouseY +
	// Cursor.currentCursor 同步）
	private function setCurrentCursor(param1:BaseCursor):Void {
		throw new Error("not implemented");
	}
}

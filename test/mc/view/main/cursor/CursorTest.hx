package mc.view.main.cursor;

import mc.control.ViewControl;
import mc.events.CursorEvent;
import mc.view.main.cursor.Cursor;
import utest.Assert;

/**
 * mc.view.main.cursor.Cursor 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 光标调度静态面的事件派发。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/Cursor.as
 * —— useSystem :28-40（true → cursorName "system"、false → "customize"，
 * 经 ViewControl 派 CursorEvent.USE_TYPE）；setCursor :67-80（派
 * CursorEvent.CURSOR 带 cursorName/cursorArgument；cursorArgument.type
 * 松等命中 "7" 时补派 Event("animalStop")，否则 "animalMov"——原文
 * `cursorArgument["type"] == "7"` 是 Dynamic 松等，翻译走 As3.eqString
 * 见 lessons #8）；setCursorForAPI :47-60（派 CursorEvent.API
 * 带 cursorName/cursorArgument/materialName）；delaySetCursor :62-65
 * （setTimeout 80ms——异步面不在单测）；setAPICurosr :42-45 是
 * setCursorForAPI 的拼写错误别名（原文如此，逐字照译）。
 *
 * 事件捕获：ViewControl 是已译真身 EventDispatcher 单例
 * （src/mc/control/ViewControl.hx），测试直接 addEventListener 捕获。
 * Cursor.name/preName/cursorArgument 是 public static 位（Cursor.as:10-20），
 * 测试前后复位。
 */
class CursorTest {
	var captured:Array<{type:String, name:String, arg:Dynamic, material:String}>;
	var plainEvents:Array<String>;

	public function new() {}

	function setup() {
		captured = [];
		plainEvents = [];
		Cursor.name = "";
		Cursor.preName = "";
		Cursor.cursorArgument = null;
		var vc = ViewControl.getInstance();
		vc.addEventListener(CursorEvent.USE_TYPE, onCursorEvent);
		vc.addEventListener(CursorEvent.CURSOR, onCursorEvent);
		vc.addEventListener(CursorEvent.API, onCursorEvent);
		vc.addEventListener("animalStop", onPlain);
		vc.addEventListener("animalMov", onPlain);
	}

	function teardown() {
		var vc = ViewControl.getInstance();
		vc.removeEventListener(CursorEvent.USE_TYPE, onCursorEvent);
		vc.removeEventListener(CursorEvent.CURSOR, onCursorEvent);
		vc.removeEventListener(CursorEvent.API, onCursorEvent);
		vc.removeEventListener("animalStop", onPlain);
		vc.removeEventListener("animalMov", onPlain);
		Cursor.name = "";
		Cursor.preName = "";
		Cursor.cursorArgument = null;
	}

	function onCursorEvent(e:CursorEvent):Void {
		captured.push({type: e.type, name: e.cursorName, arg: e.cursorArgument, material: e.materialName});
	}

	function onPlain(e:openfl.events.Event):Void {
		plainEvents.push(e.type);
	}

	// useSystem(true) → cursorName "system"；false → "customize"
	// （Cursor.as:28-40）
	public function test_useSystem_dispatches_type_name() {
		Cursor.useSystem(true);
		Cursor.useSystem(false);
		Assert.equals(2, captured.length);
		Assert.equals(CursorEvent.USE_TYPE, captured[0].type);
		Assert.equals("system", captured[0].name);
		Assert.equals("customize", captured[1].name);
	}

	// setCursor 派 CURSOR 事件携带 name/argument（:67-80）；静态位
	// name/cursorArgument 同步更新
	public function test_setCursor_event_and_statics() {
		var arg = {type: "1", tId: 101};
		Cursor.setCursor("CursorTool", arg);
		Assert.equals(1, captured.length);
		Assert.equals(CursorEvent.CURSOR, captured[0].type);
		Assert.equals("CursorTool", captured[0].name);
		Assert.equals(arg, captured[0].arg);
		Assert.equals("CursorTool", Cursor.name);
		Assert.equals(arg, Cursor.cursorArgument);
	}

	// cursorArgument.type=="7"（字符串）→ animalStop；否则 animalMov
	// （:74-79）。原文是 `cursorArgument["type"] == "7"`——Dynamic 与
	// 字符串字面量比较走 AS3 松等（`7 == "7"` 为真），翻译一律
	// As3.eqString（handbook/lessons #8 条，#8 曾五处现形）。**不写
	// {type: 7} 数值用例**：正解翻译下它派 animalStop，但数值命中是
	// 松等机制的边角语义、字符串 "7" 才是协议下发形态，钉住反而把
	// review 焦点引离主路径——松等转换本身由 eqString 的既有测试
	// （test/shim/As3Test.hx）负责
	public function test_setCursor_animal_stop_mov_gate() {
		Cursor.setCursor("x", {type: "7"});
		Assert.equals("animalStop", plainEvents[plainEvents.length - 1]);
		Cursor.setCursor("x", {type: "1"});
		Assert.equals("animalMov", plainEvents[plainEvents.length - 1]);
		Cursor.setCursor("x", null); // null argument → else 分支
		Assert.equals("animalMov", plainEvents[plainEvents.length - 1]);
	}

	// setCursorForAPI 派 API 事件带 materialName（:47-60）
	public function test_setCursorForAPI_event_fields() {
		var arg = {type: "2"};
		Cursor.setCursorForAPI("MyCursor", arg, "MatName");
		Assert.equals(1, captured.length);
		Assert.equals(CursorEvent.API, captured[0].type);
		Assert.equals("MyCursor", captured[0].name);
		Assert.equals(arg, captured[0].arg);
		Assert.equals("MatName", captured[0].material);
	}

	// setAPICurosr 是 setCursorForAPI 的别名（:42-45——原文拼写如此）
	public function test_setAPICurosr_alias() {
		Cursor.setAPICurosr("AliasCursor", null, "Mat");
		Assert.equals(1, captured.length);
		Assert.equals(CursorEvent.API, captured[0].type);
		Assert.equals("AliasCursor", captured[0].name);
	}

	// delaySetCursor 经 setTimeout 80ms 转 setCursor（:62-65）——异步面
	// 不在 eval 单测断言（无真定时器泵），仅钉方法存在可调用不抛同步错
	public function test_delaySetCursor_callable() {
		Cursor.delaySetCursor("CursorTool", "");
		Assert.isTrue(true); // 同步不抛即过——80ms 后的派发由 implement 期集成面核
	}
}

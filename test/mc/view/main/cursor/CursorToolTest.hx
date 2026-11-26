package mc.view.main.cursor;

import mc.view.main.cursor.CursorTool;
import openfl.display.MovieClip;
import support.MaterialFakes;
import utest.Assert;

/**
 * mc.view.main.cursor.CursorTool 纯逻辑（issue #87 write-tests，对 stub
 * 失败）：cursorArgument 的 type 两分拼装。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorTool.as
 * —— ctor :11-15（cacheAsBitmap=true）；set cursorArgument :22-49（type
 * !=9 → 素材名 "CursorTool_"+type+"_"+tId、取回即 MovieClip、
 * `_cursor.cacheAsBitmap=true`——:29-32；type==9 → 新 MovieClip 装
 * "Animal_"+id+"_1" **的第一子件**（`getChildAt(0)`），id 取 cId 优先、
 * tId 兜底 :33-41）；素材装配完 `addChild(this._cursor)` :47。
 *
 * 素材通道用 support/MaterialFakes 的假域注入（MaterialFakes.hx 类头——
 * MaterialLib.searchClass 经 ApplicationDomain.hasDefinition 走
 * Type.resolveClass，push 一个普通域后 root 包同名假面即被 getMaterial
 * 取到）：{type:1,tId:101} 推导 "CursorTool_1_101"（test/CursorTool_1_101.hx）、
 * {type:9,cId:1001} 推导 "Animal_1001_1"（子件名 a1001）、{type:9,tId:1502}
 * 兜底推导 "Animal_1502_1"（子件名 a1502）——名字推导错一位假域就取空、
 * `_cursor.cacheAsBitmap`/`getChildAt` 随即炸 null，测试据此红。
 *
 * 隔离：MaterialLib 是单例——install 重建 instance 起装、用例结束
 * teardown reset 归位（同 suite 的 MaterialProxyTest/MoneyIconTest 等以
 * 「注册表为空」为前提）。
 */
@:access(mc.view.main.cursor.CursorTool)
class CursorToolTest {
	public function new() {}

	function teardown() {
		MaterialFakes.reset();
	}

	// ctor cacheAsBitmap（CursorTool.as:14）
	public function test_ctor_cacheAsBitmap() {
		var tool = new CursorTool();
		Assert.isTrue(tool.cacheAsBitmap);
	}

	// type!=9 分支（:29-32）：{type:1,tId:101} → "CursorTool_1_101"——
	// 素材名推导正确时假域命中、装配进 MovieClip 且 cacheAsBitmap 置位
	public function test_type_non9_assembles_named_material() {
		MaterialFakes.install();
		var tool = new CursorTool();
		tool.cursorArgument = {type: 1, tId: 101};
		// _cursor 是假面 CursorTool_1_101 的实例（MovieClip 子类）
		Assert.isTrue(Std.isOfType(tool._cursor, CursorTool_1_101));
		// `_cursor.cacheAsBitmap=true`（:31）
		Assert.isTrue(tool._cursor.cacheAsBitmap);
		// addChild(this._cursor)（:47）——装配进显示树
		Assert.isTrue(tool.contains(tool._cursor));
	}

	// type==9 + cId 分支（:33-38）：{type:9,cId:"1001"} → "Animal_1001_1"
	// ——新 MovieClip 装其**第一子件**（getChildAt(0)），子件名 a1001
	public function test_type9_cId_branch_wraps_first_child() {
		MaterialFakes.install();
		var tool = new CursorTool();
		tool.cursorArgument = {type: 9, cId: "1001"};
		// _cursor 是 new MovieClip（:34——不是素材本体）
		Assert.isTrue(Std.isOfType(tool._cursor, MovieClip));
		Assert.isFalse(Std.isOfType(tool._cursor, Animal_1001_1));
		// 第一子件被摘进 _cursor——名字面 a1001 区分 cId/tId 两分支
		Assert.equals(1, tool._cursor.numChildren);
		Assert.equals("a1001", tool._cursor.getChildAt(0).name);
	}

	// type==9 无 cId 有 tId 兜底（:39-41）：{type:9,tId:"1502"} →
	// "Animal_1502_1"——子件名 a1502 区别于 cId 支
	public function test_type9_tId_fallback_branch() {
		MaterialFakes.install();
		var tool = new CursorTool();
		tool.cursorArgument = {type: 9, tId: "1502"};
		Assert.equals(1, tool._cursor.numChildren);
		Assert.equals("a1502", tool._cursor.getChildAt(0).name);
	}

	// cursorArgument 赋值经父类通道记录（BaseCursor.as:21-24——super.
	// cursorArgument=param1 在装配前先行，素材装配成败不影响 argument
	// 存取链路本身）
	public function test_cursorArgument_recorded() {
		MaterialFakes.install();
		var tool = new CursorTool();
		var arg = {type: 1, tId: 101};
		tool.cursorArgument = arg;
		Assert.equals(arg, tool.cursorArgument);
	}
}

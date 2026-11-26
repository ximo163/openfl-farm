package mc.view.main.cursor;

import mc.view.main.cursor.CursorArrow;
import mc.view.main.cursor.CursorClassLib;
import mc.view.main.cursor.CursorTool;
import mc.view.main.cursor.Cursor_ClearBB;
import mc.view.main.cursor.Cursor_Donate;
import mc.view.main.cursor.Cursor_Flapper;
import mc.view.main.cursor.Cursor_Fly;
import mc.view.main.cursor.Cursor_ShengChan;
import mc.view.main.cursor.Cursor_ShouHuo;
import mc.view.main.cursor.Cursor_ShouHuoAll;
import mc.view.main.cursor.Cursor_Tanabata;
import mc.view.main.cursor.Cursor_Theft;
import utest.Assert;

/**
 * mc.view.main.cursor.CursorClassLib 纯逻辑（issue #87 write-tests，对
 * stub 失败）：内置注册表的键面与 register/getClass 通道。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorClassLib.as
 * —— 内置表 :6-19（11 行键值：CursorArrow/Cursor_ShengChan/Cursor_ShouHuo/
 * Cursor_Theft/CursorArrow（重复键后者盖前者）/CursorTool/Cursor_Fly/
 * Cursor_Flapper/Cursor_ClearBB/Cursor_ShouHuoAll/Cursor_Donate/
 * Cursor_Tanabata）；getClass :26-33（_lib null → null、缺键 → null
 * （undefined））；register :35-40（_lib null 时建新表——原文语义：
 * 内置表是静态字面量初值，register 只在null重建——永真路径是写入现有表）。
 */
class CursorClassLibTest {
	public function new() {}

	// 内置键全表（CursorClassLib.as:6-19）：11 个键各映射到对应类
	public function test_builtin_registry_keys() {
		Assert.equals(CursorArrow, CursorClassLib.getClass("CursorArrow"));
		Assert.equals(Cursor_ShengChan, CursorClassLib.getClass("Cursor_ShengChan"));
		Assert.equals(Cursor_ShouHuo, CursorClassLib.getClass("Cursor_ShouHuo"));
		Assert.equals(Cursor_Theft, CursorClassLib.getClass("Cursor_Theft"));
		Assert.equals(CursorTool, CursorClassLib.getClass("CursorTool"));
		Assert.equals(Cursor_Fly, CursorClassLib.getClass("Cursor_Fly"));
		Assert.equals(Cursor_Flapper, CursorClassLib.getClass("Cursor_Flapper"));
		Assert.equals(Cursor_ClearBB, CursorClassLib.getClass("Cursor_ClearBB"));
		Assert.equals(Cursor_ShouHuoAll, CursorClassLib.getClass("Cursor_ShouHuoAll"));
		Assert.equals(Cursor_Donate, CursorClassLib.getClass("Cursor_Donate"));
		Assert.equals(Cursor_Tanabata, CursorClassLib.getClass("Cursor_Tanabata"));
	}

	// 缺键 → null（getClass :26-33）
	public function test_missing_key_returns_null() {
		Assert.isNull(CursorClassLib.getClass("NoSuchCursor"));
	}

	// register 写入新键可查（register :35-40）——用不撞内置的键名
	public function test_register_roundtrip() {
		CursorClassLib.register("TestCustomCursor", CursorArrow);
		Assert.equals(CursorArrow, CursorClassLib.getClass("TestCustomCursor"));
	}

	// register 覆盖内置键生效（写表语义同通道）
	public function test_register_overrides() {
		CursorClassLib.register("CursorArrow", CursorTool);
		Assert.equals(CursorTool, CursorClassLib.getClass("CursorArrow"));
		CursorClassLib.register("CursorArrow", CursorArrow); // 复原——静态表跨测试污染防护
	}
}

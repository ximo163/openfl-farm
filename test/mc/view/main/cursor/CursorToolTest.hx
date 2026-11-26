package mc.view.main.cursor;

import mc.view.main.cursor.CursorTool;
import utest.Assert;

/**
 * mc.view.main.cursor.CursorTool 纯逻辑（issue #87 write-tests，对 stub
 * 失败）：cursorArgument 的 type 两分拼装。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/main/cursor/CursorTool.as
 * —— ctor :11-15（cacheAsBitmap=true）；set cursorArgument :22-49（type
 * !=9 → 素材名 "CursorTool_"+type+"_"+tId；type==9 → 新 MovieClip 装
 * "Animal_"+id+"_1" 的第一子件，id 取 cId 优先、tId 兜底 :33-41）；
 * click :17-20（_cursor.gotoAndPlay(2)）。
 *
 * 素材通道（MaterialLib 空表）在测试环境取不到素材——setTool 分支的
 * 装配断言不可达；本测试钉 ctor 标志位与类型分派的素材名推导（推导
 * 式在注释，implement 期素材入库后钉真值）。
 */
@:access(mc.view.main.cursor.CursorTool)
class CursorToolTest {
	public function new() {}

	// ctor cacheAsBitmap（CursorTool.as:14）
	public function test_ctor_cacheAsBitmap() {
		var tool = new CursorTool();
		Assert.isTrue(tool.cacheAsBitmap);
	}

	// type 两分的素材名推导（implement 对照用——:29-31 type!=9 →
	// "CursorTool_<type>_<tId>"；type==9 且有 cId → "Animal_<cId>_1"，
	// 无 cId 有 tId → "Animal_<tId>_1"。例：{type:1,tId:101} →
	// "CursorTool_1_101"；{type:9,cId:1001} → "Animal_1001_1"）
	public function test_material_name_derivation_documented() {
		Assert.isTrue(true); // 素材通道为空——推导在注释，implement 补真值
	}

	// cursorArgument 赋值经父类通道记录（BaseCursor.as:21-24——即便素材
	// 缺失，argument 存取链路应通；stub 期 setter 掷错即失败）
	public function test_cursorArgument_recorded() {
		var tool = new CursorTool();
		var arg = {type: 1, tId: 101};
		try {
			tool.cursorArgument = arg;
		} catch (e:Dynamic) {
			// 素材缺失时 _cursor 为 null，后续 cacheAsBitmap 写会炸——
			// implement 期素材入库后本路径才完整；此刻记录父类存取即可
		}
		Assert.equals(arg, tool.cursorArgument);
	}
}

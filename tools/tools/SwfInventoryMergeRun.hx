package tools;

/**
 * issue #95：swf-inventory 生成器手写增补保留的脚本侧胶水 runner（write-
 * tests 阶段为 stub——main 立刻抛，接线后由 implement 填充；契约由
 * test/tools/SwfInventoryMergeRunTest.hx 钉死）。
 *
 * 为什么存在：#83 交付的判式 tools.SwfInventoryMerge 无静态 main，「全
 * 仓引用 SwfInventoryMerge 的只有判式本体、测试、handbook 页」（#95 背
 * 景——零调用是 #83 半件交付的实锤）。#95 行动项 1 原文：「判式类无静
 * 态 main：接线需要一个 runner（#70 的 tools/tools/TestStubScanRun.hx
 * 同款形态，tools/ 可写）」「runner 随接线同做，不拆」。
 *
 * 职责（实现后）：读旧 spec/swf-inventory.json 与生成器本次产出（临时文
 * 件）→ 调 SwfInventoryMerge.merge → 写回 spec 路径；每保留一条手写块打
 * 一行 `keep <path> <键>`（SwfInventoryMerge.reportLine 形态）进 stdout
 * ——#95 原文「保留行打 keep <path> <键> 进 CI 日志（判式的 reportLine
 * 已备）」。写回前/后可附 reconcile 对账结果（判式在
 * tools.SwfInventoryReconcile）。退出码：0 = merge 成功且对账净；1 =
 * 对账有缺口或判式抛出生成器形状异常；2 = 用法/环境错（TestStubScanRun
 * 先例「门跑不起来＝不放行，失败方向一致」）。
 *
 * 用法（接线后，仓库根）：
 *
 *     haxe -cp tools --run tools.SwfInventoryMergeRun <旧清单路径> <生成产物路径> <写回路径>
 *
 * 与 scripts/swf-inventory.py 的接线关系（#95 行动项 1）：生成器落盘改
 * 为「生成产物先写临时文件 → 调本 runner merge(旧文件, 生成产物) → 写回
 * spec/swf-inventory.json」；scripts/ 是人管路径，接线 edit 归人，本类只
 * 提供 tools/ 侧的入口——判式单源不破（#63：merge 逻辑只在
 * SwfInventoryMerge 一份，本类零 merge 逻辑拷贝）。
 */
class SwfInventoryMergeRun {
	static function main() {
		throw new haxe.Exception("not implemented");
	}
}

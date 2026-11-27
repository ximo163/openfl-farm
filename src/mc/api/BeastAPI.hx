package mc.api;

import openfl.errors.Error;
import openfl.events.EventDispatcher;

/**
 * mc.api.BeastAPI —— BeastAPI.as 的最小编译 stub（issue #87 范围外依赖
 * 占位：mc.view.common.AlertWindow.onLinkClicked 的 `gotoWild` 链接分支
 * 调 BeastAPI.getInstance().showWildStage()。本类属 activities 模块
 * 「wild 野兽」子系统——spec/modules/activities.json 登记在案，真身归
 * 该模块翻译，届时本 stub 整文件替换）。成员面只立当前消费通道：
 * getInstance/showWildStage，签名逐字取自反编译原文。
 * legacy/decompiled/Master2_v_142/scripts/mc/api/BeastAPI.as。
 *
 * PORT-NOTE（继承面简化）：原文 `extends McAPI implements IBeastAPI`
 * ——McAPI（spec 入口子系统）与 IBeastAPI（activities）本切片均未译，
 * stub 期落 EventDispatcher 兜底（真身补全继承链；AlertWindow 只经
 * getInstance 静态面取用，实例类型无观察差）。
 */
@:keep
class BeastAPI extends EventDispatcher {
	// BeastAPI.as:16
	private static var instance:BeastAPI;

	// BeastAPI.as:35-37
	public function new() {
		super();
	}

	// BeastAPI.as:45-52
	public static function getInstance():BeastAPI {
		if (instance == null) {
			instance = new BeastAPI();
		}
		return instance;
	}

	// BeastAPI.as:201-206
	public function showWildStage():Void {
		throw new Error("not implemented");
	}
}

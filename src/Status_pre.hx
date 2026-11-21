package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 好友状态角标——将熟（farmui_full_v_40.swf SymbolClass 导出，char#278）。
// FriendItemRender.updateStatusFlag 的 preMode 计时分支经 Utils.getClass
// ("Status_pre") 反射 new；原 swf 无同名脚本类（纯符号绑定），时间轴由
// SymbolClass.bind 补挂（Weed 先例）。
@:keep
class Status_pre extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "Status_pre");
	}
}

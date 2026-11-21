package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 好友召回角标 z（farmui_full_v_40.swf SymbolClass 导出，char#273）。
// FriendItemRender.updateStatusFlag 的召回好友分支经 Utils.getClass
// ("Status_z") 反射 new；原 swf 无同名脚本类（纯符号绑定），时间轴由
// SymbolClass.bind 补挂（Weed 先例）。
@:keep
class Status_z extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "Status_z");
	}
}

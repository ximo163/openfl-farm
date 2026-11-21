package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 好友状态角标 6——鱼塘可操作（farmui2_v_58.swf SymbolClass 导出，
// char#162）。FriendItemRender.updateStatusFlag 的鱼塘分支经 Utils.getClass
// ("Status_6") 反射 new；原 swf 无同名脚本类（纯符号绑定），时间轴由
// SymbolClass.bind 补挂（MonthEndIcon 同库先例）。
@:keep
class Status_6 extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "Status_6");
	}
}

package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 好友列表面板微博皮肤关态（farmui2_v_58.swf SymbolClass 导出，char#185）。
// FriendsView.createView 的 WB 分支经 Utils.getMaterial("List_Close_WB")
// as MovieClip 反射构造（原 swf 无同名脚本类——纯符号绑定）；时间轴由
// SymbolClass.bind 补挂（MonthEndIcon 同库先例）。
@:keep
class List_Close_WB extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui2_v_58", "List_Close_WB");
	}
}

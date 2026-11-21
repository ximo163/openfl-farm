package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 好友列表行符号（farmui_full_v_40.swf SymbolClass 导出，char#351）。
// FriendItemRender 构造器经 Utils.getMaterial("List_Item") as Sprite 反射
// 构造（原 swf 无同名脚本类——FFDec 未导出，纯符号绑定）；时间轴由
// SymbolClass.bind 补挂（Weed 先例）。
@:keep
class List_Item extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "List_Item");
	}
}

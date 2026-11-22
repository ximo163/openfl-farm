package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ItemBg —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#525）。
// 商店瓦片底板：BaseTileItem.createBackground("ItemBg") 经 Utils.getMaterial
// 反射构造（AdvertisementItem/ToolItem/FishItem/CropItem 等），swf 无同名
// 脚本类——纯符号绑定，时间轴由 SymbolClass.bind 补挂（ItemBorder 先例）。
@:keep
class ItemBg extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ItemBg");
	}
}

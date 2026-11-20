import shim.SymbolClass;

// PackBarBg —— farmui_full_v_40.swf 的 SymbolClass 符号（char#423），AS3 里
// 作为类名直接引用（ToolBoxBar.as:46 `defaultSkin = PackBarBg`），反编译产物
// 里没有对应 .as 源，按 ItemLoading/Reclaim 先例做符号绑定 shim。
@:keep
class PackBarBg extends openfl.display.MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "PackBarBg");
	}
}

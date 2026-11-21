import shim.SymbolClass;

// ToolBarBg —— farmui_full_v_40.swf 的 SymbolClass 符号（char#476），AS3 里
// 作为类名直接引用（ToolBar.as:89 `defaultSkin = ToolBarBg`），反编译产物里
// 没有对应 .as 源，按 PackBarBg/ItemLoading 先例做符号绑定 shim。
@:keep
class ToolBarBg extends openfl.display.MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ToolBarBg");
	}
}

import shim.SymbolClass;

// TipBg —— farmui_full_v_40.swf 的 SymbolClass 导出符号（char#222），提示
// 底板（MouseTip/CropInfoTip/DiyMouseTip/HistoryItemTip 经 Utils.getMaterial
// ("TipBg") 反射构造）。该 swf 的符号关联类体长在 DoABC2，不在 CI 反编译的
// 五代码 swf 内、无 FFDec 产物；ABC 字节码（tools/DumpAbcMethod.hx retarget
// 导出）显示 TipBg 是自动生成的空类——无字段、构造器只调 super()，全部视觉
// 都在符号时间轴上。按 ToolBarBg 先例做符号绑定 shim（AnimateLibrary 绑
// 时间轴要 MovieClip 目标；单帧图形与原版 Sprite 基显示无差）。
@:keep
class TipBg extends openfl.display.MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "TipBg");
	}
}

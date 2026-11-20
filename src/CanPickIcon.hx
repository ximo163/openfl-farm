package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// 可摘作物图标动画，LandPickIcon 经 Utils.getMaterial("canPickIcon") 反射构造（farmui_full_v_40.swf SymbolClass 导出符号，char#241）。原 swf 无同名
// 脚本类（FFDec 未导出——纯符号绑定）；时间轴由 SymbolClass.bind 补挂，
// 见该 shim 头注释（FarmLoading_Lite 先例）。
//
// PORT-NOTE: 原符号名小写开头（canPickIcon）。Haxe 跨模块引用小写类是编译
// 错（表达式/类型位置/各类型 import 全禁，probe 证实），小写类只能当「从未
// 被引用的孤儿」存在——即永远进不了产物、反射恒 null。等价物：类名改大写
// CanPickIcon，@:native 把 js 运行时注册键改回原符号名 canPickIcon（probe
// 证实 $hxClasses["canPickIcon"] 命中、resolveClass("canPickIcon") 可取），
// 反射调用点（字符串 "canPickIcon"）一字不动。eval/cpp 的 resolveClass 不看
// @:native 键：eval 单测不解析显示符号（handbook 惯例）、cpp/android 门只
// 编译不跑场景，均不受影响。
@:native("canPickIcon")
@:keep
class CanPickIcon extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "canPickIcon");
	}
}

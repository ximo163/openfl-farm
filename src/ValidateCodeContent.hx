package;

import openfl.display.MovieClip;
import shim.SymbolClass;

// ValidateCodeContent —— farmui_full_v_40.swf 的 SymbolClass 导出符号
// （char#601，单帧 DefineSprite）。图形验证码窗体版面：时间轴具名子件
// postText（提示文）/input_txt（输入框）/renew_txt（换一张）/img_mc（验证
// 码图挂点），ValidateCodeWindow.init 经 Utils.getMaterial 反射构造后按名
// 取子件。（#41）
@:keep
class ValidateCodeContent extends MovieClip {
	public function new() {
		super();
		SymbolClass.bind(this, "farmui_full_v_40", "ValidateCodeContent");
	}
}

package common.view.window;

import com.qzone.qui.controls.TabBar;
import com.qzone.qui.styles.Style;
import com.qzone.qui.utils.TextFormatUtil;
import common.misc.Utils;
import openfl.text.TextFormat;

/**
 * common.view.window.WindowTabBarMaker —— WindowTabBarMaker.as 逐句对应
 * （issue #18 qui 收尾：通用窗口片）。窗口标签条装配器：首次调用克隆三套
 * 按钮文本格式并改色（0x099FF/无色/0xFFFFFF 加粗），再给 TabBar 换
 * TabBg/TabDefault/TabSelected 符号皮肤。符号经 Utils.getClass 反射取名，
 * 对应根包符号 shim（dceAnchor 锚住）。
 */
@:keep
class WindowTabBarMaker {
	// WindowTabBarMaker.as:12-16（首用前为 null：addTarget 里懒建）
	public static var tabOverFormat:TextFormat;

	public static var tabDefaultFormat:TextFormat;

	public static var tabSelectedFormat:TextFormat;

	// :18-21（FFDec 在无父类构造器里也照印 super()，Haxe 无父类不可调，省）
	public function new() {}

	// :23-48
	public static function addTarget(param1:TabBar):Void {
		if (param1 == null) {
			return;
		}
		if (tabDefaultFormat == null) {
			tabDefaultFormat = TextFormatUtil.clone(Style.getButtonFormat());
			tabDefaultFormat.color = 39423;
			tabOverFormat = TextFormatUtil.clone(Style.getButtonOverFormat());
			tabOverFormat.color = null;
			tabSelectedFormat = TextFormatUtil.clone(Style.getButtonSelectedFormat());
			tabSelectedFormat.color = 16777215;
			tabSelectedFormat.bold = true;
		}
		param1.height = 25;
		param1.paddingH = 25;
		param1.gapH = 3;
		param1.tabDefaultFormat = tabDefaultFormat;
		param1.tabOverFormat = tabOverFormat;
		param1.tabSelectedFormat = tabSelectedFormat;
		param1.defaultSkin = Utils.getClass("TabBg");
		param1.tabDefaultSkin = Utils.getClass("TabDefault");
		param1.tabSelectedSkin = Utils.getClass("TabSelected");
	}
}

package shim;

import openfl.Lib;
import openfl.display.StageScaleMode;

/**
 * Flash 播放器固定盒子（860×500）的宿主等价物——手机屏幕适配（等比缩放+
 * 信箱）的唯一落点，翻译类一律不碰 scaleMode。
 *
 * 原版：nc.htm 的 swfobject 把播放器盒子钉死在 860×500（PublishSettings
 * Width/Height，mcloader_v_53 同），FarmLite.as:406 的
 * `stage.scaleMode = NO_SCALE` 在固定盒子里是 no-op——「窗口变了不重缩放」
 * 从不发生，舞台读数永远是 860×500。
 *
 * openfl：窗口尺寸来自 Project.xml（860×500、resizable="false"），但
 * Android 的 surface 是全屏（2340×1080 一类），照译的 NO_SCALE 把盒子
 * 拆掉：stageWidth/stageHeight 变成全屏、内容原尺寸锚在左上、所有按
 * 舞台尺寸定位的 UI（ToolBar/NavigationBar/FarmStage…）全散架（#10
 * 真机实证）。openfl 自家对 resizable=false 的窗口本来就走 SHOW_ALL +
 * 逻辑尺寸（9.5.2 Window 构造器 __setLogicalSize + scaleMode=SHOW_ALL
 * 分支）——这层宿主行为被 FarmLite 构造器的照译覆盖掉，本 shim 装回去。
 *
 * 效果：stageWidth/stageHeight 恢复 860/500（与原版 Flash 舞台读数一致，
 * 读数的翻译代码零改动）；手机上等比缩放+信箱（decisions.md 允许的唯一
 * 屏幕适配形态）。html5 上窗口就是 860×500、缩放恒 1，行为不变（CI
 * web-smoke 把关）。align 不动——FarmLite.setup 照译设的 TOP_LEFT。
 */
class PlayerBox {
	public static function install():Void {
		Lib.current.stage.scaleMode = StageScaleMode.SHOW_ALL;
	}
}

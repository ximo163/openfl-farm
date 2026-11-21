package shim;

import common.Consts;
import openfl.Lib;
import openfl.display.StageScaleMode;

/**
 * 播放器盒子的宿主等价物——屏幕适配的唯一落点，翻译类一律不碰
 * scaleMode / 舞台逻辑尺寸（FarmLite.setup 照译的 NO_SCALE 不动）。
 *
 * 原版：nc.htm 的 swfobject 把播放器盒子钉死在 860×500（PublishSettings
 * Width/Height），FarmLite.as:406 的 `stage.scaleMode = NO_SCALE` 在固定
 * 盒子里是 no-op，舞台读数恒 860×500；代码全按 stageWidth/stageHeight
 * 锚定 UI、FarmLayer 以 scrollRect 视口在 1024×800 的场景内容里平移。
 *
 * openfl：Android 的 surface 是全屏（如 2340×1080），照译的 NO_SCALE 把
 * 盒子拆掉——舞台读数变全屏、内容原尺寸锚左上、UI 全散（#10 真机实证）。
 * openfl 9.5.2 的 Window 构造器对 resizable=false 本来就设 SHOW_ALL+逻辑
 * 尺寸，但那只是把盒子缩进信箱（860×500 比例下 19.5:9 屏白边占 21%）。
 *
 * 终态（2026-11-21 所有者拍板「铺满全屏」，deviations.json
 * android-fullbleed-viewport）：逻辑视口重映射为
 * - 宽 = Consts.SCENE_WIDTH（1024，场景内容的真实宽度，再宽原版没画）
 * - 高 = windowH/windowW × 1024（自适应，上限 SCENE_HEIGHT 800）
 * 等比缩放、零信箱；UI 锚点全部随 stageWidth/stageHeight 自适应（原代码
 * 即如此写）。代价（所有者知情）：横向场景拖动余量归零（视口=内容宽，
 * FarmLayer 钳制永假），纵向余量保留；宽于 2.05 的屏纵向视野比 860×500
 * 略少（2340×1080 上 473 vs 500）。
 * html5（窗口即 860×500）与桌面窗口（surface 不宽于盒子）不重映射，行为
 * 不变，CI web-smoke 把关。
 */
class PlayerBox {
	public static function install():Void {
		var stage = Lib.current.stage;
		#if !html5
		// 与 Stage.__resize 同口径的物理像素（openfl Stage.__resize：
		// window.width * window.scale）
		var window = stage.window;
		var windowW = window.width * window.scale;
		var windowH = window.height * window.scale;
		// 只在 surface 宽于原播放器盒子（Project.xml 860）时重映射：
		// 桌面 860×500 固定窗口维持原样
		if (windowW > 860) {
			var scale = windowW / Consts.SCENE_WIDTH;
			var viewportH = Math.round(windowH / scale);
			if (viewportH > Consts.SCENE_HEIGHT) {
				viewportH = Consts.SCENE_HEIGHT;
			}
			@:privateAccess stage.__setLogicalSize(Consts.SCENE_WIDTH, viewportH);
		}
		#end
		stage.scaleMode = StageScaleMode.SHOW_ALL;
	}
}

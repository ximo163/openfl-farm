package framework.layers;

import common.Consts;
import events.WindowEvent;
import framework.layers.WindowLayer;
import common.view.window.WindowControl;
import module.FarmApplication;
import utest.Assert;

/**
 * WindowLayer 纯逻辑（issue #41）：init 挂 WindowEvent.OPEN 监听后，按名
 * 弹「模块托管窗」（shop/warehouse/profile）抛 ArgumentError——这三窗由
 * 各功能模块自建，宿主层代建会丢装配链，原版用异常拦。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/framework/layers/WindowLayer.as
 * （init :99-110 注册 WindowEvent.OPEN/CLOSE 监听、onWindowOpen :145-161
 * 的 `_loc2_ == WINDOW_NAME_SHOP || WAREHOUSE || PROFILE` →
 * `throw new ArgumentError("Window can not be initialized.")` :149-152；
 * ctor :22-33 的 name = Consts.LAYER_WINDOW）。
 *
 * msgCenter 用 FarmApplication（EventDispatcher 路由，DogFoodWindowTest
 * 先例）。openWindow 的 PopUpManager 装载路径在 eval 上不可构造
 * （PopUpLayer 依赖 stage，probe 实测 addPopUp 即空引用），弹窗装载/
 * 缓存语义由 CI web-smoke 兜底，不进单测。
 */
@:access(framework.layers.WindowLayer)
class WindowLayerTest {
	public function new() {}

	private function buildLayer():FarmApplication {
		var app = new FarmApplication();
		var ctrl = new WindowControl(app);
		var layer = new WindowLayer(ctrl);
		Assert.equals(Consts.LAYER_WINDOW, layer.name); // :29 "Window Layer"
		layer.init(); // :99-110 挂 OPEN/CLOSE 监听
		return app;
	}

	// :149-152：模块托管窗（shop/warehouse/profile）按名弹 → ArgumentError
	public function test_onWindowOpen_rejects_module_managed_windows() {
		for (name in [Consts.WINDOW_NAME_SHOP, Consts.WINDOW_NAME_WAREHOUSE, Consts.WINDOW_NAME_PROFILE]) {
			var app = buildLayer();
			var ev = new WindowEvent(WindowEvent.OPEN);
			ev.windowName = name;
			// utest 1.13 的 Assert.raises 只回 Bool，文案经 catch 内捡
			var message:String = null;
			Assert.raises(function() {
				try {
					app.dispatchEvent(ev);
				} catch (e:openfl.errors.ArgumentError) {
					message = e.message;
					throw e;
				}
			}, openfl.errors.ArgumentError);
			Assert.equals("Window can not be initialized.", message, name);
		}
	}
}

package support;

import lime._internal.backend.native.NativeWindow;
import lime.ui.Window;
import openfl.display.Stage;
import openfl.events.UncaughtErrorEvents;

/**
 * 无窗口 Stage 垫子（issue #44，FrameTimer 单测专用）：eval 解释器没有
 * lime 窗口，`new Stage(null)` 在 ctor 的 `window.application` 上抛
 * "field access on null"——用 Type.createEmptyInstance 跳过 ctor 后补钉
 * 四个字段（openfl 9.5.2 + lime 8.3.2 容器内实证，MouseTipTest 补
 * __transform 同款手法）：
 * - `stage` 指自身（Stage ctor 本做的 `this.stage = this`），使
 *   `_stage.stage` 解析回本对象；
 * - `window` → 空 Window + NativeWindow 后端钉 `frameRate`，使
 *   `stage.frameRate` 可读可写（getter 经 window.__backend.getFrameRate，
 *   Stage 本体在 window == null 时恒 0）；
 * - `__uncaughtErrorEvents`：Stage.__dispatchEvent 进门就读它，空实例上
 *   为 null 会炸派发链。
 * 事件机制（addEventListener/dispatchEvent/removeEventListener）不依赖
 * 窗口，照常工作——测试侧用它手动派发 Event.ENTER_FRAME 推进帧。
 */
class FakeStage {
	public static function make(frameRate:Float = 30):Stage {
		var stage = Type.createEmptyInstance(Stage);
		Reflect.setField(stage, "stage", stage);
		Reflect.setField(stage, "__uncaughtErrorEvents", new UncaughtErrorEvents());
		var backend = Type.createEmptyInstance(NativeWindow);
		Reflect.setField(backend, "frameRate", frameRate);
		var window = Type.createEmptyInstance(Window);
		Reflect.setField(window, "__backend", backend);
		Reflect.setField(stage, "window", window);
		return stage;
	}
}

package module.mainScene.background;

import framework.base.Controller;
import interfaces.IModule;

/**
 * module.mainScene.background.BackgroundController —— V3b 模块翻译，闭包
 * stub（issue #7）。背景控制器（BackgroundController.as 173 loc：
 * BackgroundScreen/BackgroundModel 的场景背景与前后景装载）。
 * ModuleMainScene.load 只调 initialze/finalize/switchMode，背景装载随 V3b 片。
 */
@:keep
class BackgroundController extends Controller {
	public function new(param1:IModule) {
		super(param1);
	}

	// BackgroundController.as:80-（initialze：建背景视图/模型，V3b 片）
	override public function initialze():Void {}

	// BackgroundController.as:141-（switchMode：大小场景背景切换，V3b 片）
	public function switchMode(param1:Bool):Void {}

	// BackgroundController.as:163-（finalize：V3b 片）
	override public function finalize():Void {
		super.finalize();
	}
}

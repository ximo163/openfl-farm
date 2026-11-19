package module.load;

import interfaces.IMsgCenter;
import openfl.display.Sprite;

/**
 * module.load.UserChangingBar —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 切换用户时的遮罩/加载条（UserChangingBar.as 86 loc，依赖 DataLoading
 * 动画件）；FarmStage.initTopLayer 建进 LAYER_TOPMOST。这里只保构造形态
 * （Sprite + IMsgCenter）让建层编译，遮罩/文案/链接行为随 uitools 片接入。
 */
@:keep
class UserChangingBar extends Sprite {
	// UserChangingBar.as:26
	private var m_app:IMsgCenter;

	public function new(param1:IMsgCenter) {
		super();
		this.m_app = param1;
	}
}

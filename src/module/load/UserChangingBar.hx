package module.load;

import common.view.DataLoading;
import events.CommonEvent;
import interfaces.IMsgCenter;
import openfl.display.Sprite;
import openfl.errors.Error;
import openfl.events.TextEvent;
import openfl.text.TextField;

/**
 * module.load.UserChangingBar —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 切换用户时的遮罩/加载条（UserChangingBar.as 86 loc，依赖 DataLoading
 * 动画件）；FarmStage.initTopLayer 建进 LAYER_TOPMOST。这里只保构造形态
 * （Sprite + IMsgCenter）让建层编译，遮罩/文案/链接行为随 uitools 片接入。
 * issue #43（引导与启动杂尾）真身化；write-tests 阶段先落 onAddedToStage
 * 才建的三个显示件字段声明 + 两个事件处理器的 throw stub（监听还没挂，
 * 无运行期调用方）。
 */
@:keep
class UserChangingBar extends Sprite {
	// UserChangingBar.as:16（m_dataLoading：居中转圈件）
	private var m_dataLoading:DataLoading;

	// UserChangingBar.as:18（m_textField：错误文案/重试链接）
	private var m_textField:TextField;

	// UserChangingBar.as:20（m_mask：60% 白遮罩）
	private var m_mask:Sprite;

	// UserChangingBar.as:22
	private var m_app:IMsgCenter;

	public function new(param1:IMsgCenter) {
		super();
		this.m_app = param1;
	}

	// UserChangingBar.as:59-76（onUserSwitchResult：error 键缺位或空串走
	// showLoading 驱动遮罩/转圈，非空走错误文案覆盖，issue #43 翻译）
	private function onUserSwitchResult(param1:CommonEvent):Void {
		throw new Error("not implemented");
	}

	// UserChangingBar.as:78-83（onLinkClicked：__reload__ 载荷重派发
	// MSG_USER_SWITCH_FLAG + 文案隐藏转圈复亮，issue #43 翻译）
	private function onLinkClicked(param1:TextEvent):Void {
		throw new Error("not implemented");
	}
}

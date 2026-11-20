package module.uitools;

import framework.base.Controller;
import interfaces.IModule;
import openfl.errors.Error;

/**
 * module.uitools.UIController —— issue #9 write-tests 签名 stub
 * （UIController.as 653 loc，V3c 工具区片整类翻译：工具条/个人信息/仓库/
 * 消息弹窗的输入分发）。这里只保基类形态（Controller 子类 + model getter
 * 签名）让 ToolBar 构造链编译。
 */
class UIController extends Controller {
	// UIController.as:61-65（super(module)）
	public function new(param1:IModule) {
		super(param1);
	}

	// UIController.as:376-379（get model：UIToolsModel）
	public var model(get, never):UIToolsModel;

	private function get_model():UIToolsModel {
		throw new Error("not implemented");
	}
}

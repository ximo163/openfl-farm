package module.mainScene.npc;

import framework.base.Controller;
import interfaces.IModule;
import module.mainScene.npc.NPCModel;

/**
 * module.mainScene.npc.NPCController —— V3b 模块翻译，闭包 stub（issue #7）。
 * NPC 控制器（NPCController.as 134 loc：NPCModel/NPCView 的狗/NPC 装载）。
 * ModuleMainScene.onNetRequestStopped 经 model.resetLoadingFlags() 复位，
 * 这里 model 恒 null（V3b 片接入模型后才有值），与原版未初始化时的空路径一致。
 */
@:keep
class NPCController extends Controller {
	public function new(param1:IModule) {
		super(param1);
	}

	// NPCController.as:58-61（get model：NPCModel）
	public var model(get, never):NPCModel;

	private function get_model():NPCModel {
		return this.m_model;
	}

	// NPCController.as（initialze：建 NPCModel/NPCView，V3b 片）
	override public function initialze():Void {}

	// NPCController.as:37-（finalize：模型置空）
	override public function finalize():Void {
		if (this.m_model != null) {
			this.m_model = null;
		}
	}
}

package module.uitools.widgets;

/**
 * module.uitools.widgets.Tool_Wild —— 闭包 stub（issue #9）。完整类归
 * spec/modules/activities.json :2300（wild 野兽/丛林寻宝片，依赖
 * wild.com.Shell.command.CmdAPI 的 canReleaseNum 事件）；farm-basic.json :3989
 * 已把 ToolBar→Tool_Wild 列为跨模块依赖。本片 ToolBar 引用的成员：
 * ctor（Tool_Wild.as:28-39）、tipText（ToolBase 继承）、addEventListener
 * （显示对象继承）、actived 写入（:68-119：null/""/“1”/“3” 四态换
 * Wild_Animal_Icon 系素材）、removeText（:41-55：撤文本角标）。
 * stub 保最小时序语义：actived 只收值、removeText 无角标可撤即无操作；
 * 素材换装与 CmdAPI 监听随 activities 片全译接入。
 * legacy/decompiled/main3_v_221/scripts/module/uitools/widgets/Tool_Wild.as
 */
@:keep
class Tool_Wild extends ToolBase {
	public function new() {
		super();
	}

	// Tool_Wild.as:68-119（set actived，无 get；四态素材换装随 activities 片，
	// stub 只收值——refresh/onRewardChange 的写入不炸即可）
	public var actived(never, set):String;

	private function set_actived(param1:String):String {
		return param1;
	}

	// Tool_Wild.as:41-55（removeText：清 num 角标；stub 无角标，无操作）
	public function removeText():Void {}
}

package shim;

// PORT-NOTE: flash.ui.ContextMenu 的目标相关等价物（CLAUDE.md：openfl 对
// 右键菜单支持不完整——openfl.ui 下根本没有 ContextMenu/ContextMenuItem/
// NativeMenu，InteractiveObject.contextMenu 属性行也是注释）。等价物进 shim。
//
// 为什么这样落地：原版右键菜单是 Flash Player 托管的原生菜单，html5 浏览器
// 没有对应注入通道（移动端无右键概念）——菜单永远不会显示，但 customItems
// 数组与 hideBuiltInItems 签名原样保留，与原版在非 Flash 宿主下无右键菜单
// 的行为一致。com.qzone.utils.RightMenu（main3 变体）的 stub 决策同源
// （issue #7）。InteractiveObject.contextMenu 的读写走 ContextMenuStore
// 侧表（openfl 对象没有该属性，裸写在 cpp 上抛 Invalid field）。
class ContextMenu {
	// flash.ui.ContextMenu.customItems：自定义菜单项数组
	public var customItems:Array<Dynamic> = [];

	public function new() {}

	// flash.ui.ContextMenu.hideBuiltInItems：隐藏内建项。无宿主菜单可
	// 操作，无操作。
	public function hideBuiltInItems():Void {}
}

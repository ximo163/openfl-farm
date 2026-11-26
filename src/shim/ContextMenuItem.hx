package shim;

import openfl.events.EventDispatcher;

// PORT-NOTE: flash.ui.ContextMenuItem 的目标相关等价物（见 ContextMenu.hx
// 头注）。构造参数 caption/separatorBefore/enabled/visible 原样保存；本身
// 是 EventDispatcher——ContextMenuEvent.MENU_ITEM_SELECT 监听挂在菜单项上
// （无宿主菜单永远不会触发，登记语义保留）。
class ContextMenuItem extends EventDispatcher {
	// flash.ui.ContextMenuItem 属性
	public var caption:String;

	public var separatorBefore:Bool;

	public var enabled:Bool;

	public var visible:Bool;

	// flash.ui.ContextMenuItem(caption, separatorBefore=false, enabled=true,
	// visible=true) 构造签名
	public function new(caption:String, separatorBefore:Bool = false, enabled:Bool = true, visible:Bool = true) {
		super();
		this.caption = caption;
		this.separatorBefore = separatorBefore;
		this.enabled = enabled;
		this.visible = visible;
	}
}

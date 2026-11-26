package mc.view;

import cn.snowkit.containers.Pane;
import openfl.errors.Error;

/**
 * mc.view.WindowsManager —— WindowsManager.as 的签名面 stub（原类 36 loc，
 * issue #87「通用视图」片充真身）。窗口管理单例：gi() 惰性建，leftPane
 * 属性对存取 snowkit Pane 容器。成员签名逐字取自反编译原文，方法体随
 * implement 充真身。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/WindowsManager.as。
 */
@:keep
class WindowsManager {
	// WindowsManager.as:8
	private static var _ins:WindowsManager;

	// WindowsManager.as:10
	private var _leftPane:Pane;

	// WindowsManager.as:12-15（ctor 原文即仅 super()——空构造入 stub 不掷。
	// 注意：原文无单例守卫，构造不掷错，gi() 之外的直接 new 原文亦放过）
	public function new() {}

	// WindowsManager.as:17-24
	public static function gi():WindowsManager {
		throw new Error("not implemented");
	}

	// WindowsManager.as:26-33（leftPane 存取——原文即纯字段读写，入 stub 不掷）
	public var leftPane(get, set):Pane;

	private function set_leftPane(param1:Pane):Pane {
		this._leftPane = param1;
		return param1;
	}

	private function get_leftPane():Pane {
		return this._leftPane;
	}
}

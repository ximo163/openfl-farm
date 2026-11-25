package module.mini;

import framework.base.Controller;

// issue #63 扫描器样例——迷你子类修复后形态：同一对象改经类型化局部
// 与 typed getter（scan_dyn_writes 文件头「正确写法三选一之 1」），
// 基类 Dynamic 字段读/写命中须清零。残余形态：m_view == null 判、
// m_view = typed 的「对 m_view 本身赋值」（不是 m_view 上的字段写——
// WaterController.hx:364 修复后同形，本就不在命中面）。
class MiniController extends Controller {
	public var view(get, never):MiniView;

	private function get_view():MiniView {
		return cast(m_view, MiniView);
	}

	public function act():Void {
		if (m_view == null) {
			var typed = new MiniView();
			m_view = typed;
			typed.x = 46;
			typed.y = 320;
		}
		if (this.view != null && this.view.visible) {
			this.view.show(false);
		}
		var s = this.view.stage;
		openFloat("texttip", {"parent": this.view.stage});
	}
}

class MiniView {
	public var x:Float = 0;
	public var y:Float = 0;
	public var visible:Bool = true;
	public var stage:Dynamic = null;
	public var width:Float = 0;

	public function new() {}

	public function show(v:Bool):Void {}
}

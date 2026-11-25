package module.mini;

import framework.base.Controller;

// issue #63 扫描器样例——迷你子类修复前形态：基类 Dynamic 字段（m_view/
// m_model）上的读/写混布。命中/不命中面按行内注释，行号由
// test/tools/BaseFieldScanTest.hx 的断言钉死。
class MiniController extends Controller {
	public function act():Void {
		if (m_view == null) {
			m_view.x = 46;
			m_view.y = 320;
		}
		if (m_view != null && m_view.visible) {
			m_view.show(false);
		}
		var s = m_view.stage;
		openFloat("texttip", {"parent": m_view.stage});
		if (m_model != null) {
			m_model.dirty = true;
		}
		var n = m_model.total;
		this.m_view.alpha = 0.5;
		var w = this.m_view.width;
	}
}

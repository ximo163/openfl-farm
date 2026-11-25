package framework.base;

// issue #63 扫描器样例——迷你基类：字段声明形态与
// src/framework/base/Controller.hx:12-14 逐字同形（m_view/m_model 是
// Dynamic 字段、m_module 是 IModule 非 Dynamic——collect 只收 Dynamic，
// m_module 恰作「非 Dynamic 字段不进名单」的对照位）。
class Controller {
	private var m_view:Dynamic;
	private var m_module:IModule;
	private var m_model:Dynamic;

	public function new() {
		this.m_module = null;
		this.m_model = null;
		this.m_view = null;
	}
}

interface IModule {}

package module.recall;

/**
 * module.recall.RecallModel —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 好友召回数据（RecallModel.as 212 loc）；启动链只碰两个静态（uin、
 * m_backNum，module.Main/Main.onGetRequestCount 写）。召回请求/窗口随
 * recall 片接入。
 */
@:keep
class RecallModel {
	// RecallModel.as:19/:21
	public static var uin:UInt;
	public static var m_backNum:Int;

	// RecallModel.as:33
	public static final BACK_NUM:String = "BackNum";

	public function new() {}
}

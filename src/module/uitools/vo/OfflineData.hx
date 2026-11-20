package module.uitools.vo;

// module.uitools.vo.OfflineData —— OfflineData.as 逐句对应（issue #9
// write-tests 签名 stub：纯计数 VO 无行为，字段默认值照抄；AS3 `final class`
// 在 Haxe 侧无本仓对应写法，不入 stub）。UIToolsModel.updateOfflineStatus /
// clearUnReadMsgFlag 读写（b/c/d/e → 帖子/私信/礼物/鲜花计数）。
class OfflineData {
	// OfflineData.as:8-16
	public var m_postNum:Int;
	public var m_infoNum:Int;
	public var m_msgNum:Int;
	public var m_flowerNum:Int;
	public var m_giftNum:Int;

	// OfflineData.as:18-27
	public function new() {
		this.m_infoNum = 0;
		this.m_msgNum = 0;
		this.m_postNum = 0;
		this.m_giftNum = 0;
		this.m_flowerNum = 0;
	}
}

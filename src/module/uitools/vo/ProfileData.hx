package module.uitools.vo;

// module.uitools.vo.ProfileData —— ProfileData.as 逐句对应（issue #9
// write-tests 签名 stub：纯档案 VO 无行为，字段默认值照抄；AS3 `final class`
// 在 Haxe 侧无本仓对应写法，不入 stub）。UIToolsModel.updateHostInfo /
// initializeMyProfile 读写——PersonInfo 面板与金币/经验飘字的数据源。
class ProfileData {
	// ProfileData.as:8-18
	public var m_userName:String;
	public var m_moral:UInt;
	public var m_exp:UInt;
	public var m_fb:UInt;
	public var m_photoUrl:String;
	public var m_gold:Float;

	// ProfileData.as:20-30
	public function new() {
		this.m_userName = "";
		this.m_photoUrl = "";
		this.m_gold = 0;
		this.m_exp = 0;
		this.m_fb = 0;
		this.m_moral = 0;
	}
}

package entities;

// Player.as —— 后续模块翻译，stub 同 module/Main 先例（issue #7 闭包类：StartupDataParser
// 构造 _user = new Player(...) 并写 _user._exp，这里只保证可编译、不抛）。
class Player {
	// StartupDataParser.as:52 写入（_loc2_._user._exp = ...），翻译阶段保留该字段。
	public var _exp:Int;

	// Session 的 me/hostId/hostUin 读取（Session.as:108-118/:441-448/:130-137，
	// FarmLandModel.buildCommonPostParams :307-308 也读 _uId/_userName）。
	// 出处 Player.as:22（_uId:uint）、:42（_userName:String）、:12（_uinLogin:uint）。
	public var _uId:UInt;
	public var _userName:String;
	public var _uinLogin:UInt;

	// FarmLandModel.operate_addBug/floatHandler 读 host._canbad（Player.as:40，
	// :107 从回包 canbad 解析；floatHandler :663 写回）
	public var _canbad:Int;

	public function new(param1:Dynamic = null) {}
}

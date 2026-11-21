package entities;

// Friend.as —— 后续模块翻译，stub 同 module/Main 先例（issue #7 闭包类：
// FarmLandModel 不构造 Friend，这里只保证可编译、不抛）。
// 翻译阶段（V3a 启动链 Main/FarmApplication.switchUser 读 m_switchUser 的字段）
// 补齐被引用的 public 字段（Friend.as:7-35），importObject 留给后续模块片。
@:final
class Friend {
	// Friend.as 字段（原版 public var，翻译阶段只加被引用的）
	public var _money:Float;
	public var _yellowstatus:Int;
	public var _headPic:String;
	public var _userName:String;
	public var _yellowlevel:Int;
	public var _uin:UInt;
	public var _pf:Int;
	public var _exp:Int;
	public var me:Bool;
	public var _uId:UInt;

	// issue #20（friends）引用面补齐（Friend.as:7-35 字段区，同上文模式）：
	// FriendsModel 列表处理写 sort/status（processFriendList/sortBy）、hasMe
	// 读 _userId。其余成员（importObject/importFromCache/importFromPlayer/
	// _fid getter，Friend.as:47-131）仍留给实现阶段。
	public var _userId:UInt;
	public var sort:Int;
	public var status:Dynamic;

	public function new(param1:Dynamic = null) {}
}

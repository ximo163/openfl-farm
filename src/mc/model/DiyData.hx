package mc.model;

/**
 * mc.model.DiyData —— DiyData.as 逐句对应（原类 25 loc，issue #87「数据」
 * 片；类体太小——单例 + currentDiy 一个公开位——成员面即真身）。
 * legacy/decompiled/Master2_v_142/scripts/mc/model/DiyData.as。
 */
@:keep
class DiyData {
	// DiyData.as:6
	private static var instance:DiyData;

	// DiyData.as:8
	public var currentDiy:Bool = false;

	// DiyData.as:10-13
	public function new() {}

	// DiyData.as:15-23
	public static function getInstance():DiyData {
		if (instance == null) {
			instance = new DiyData();
		}
		return instance;
	}
}

package framework.api.beast;

/**
 * framework.api.beast.WildData —— 最小 stub（issue #36 登记）。
 * 原版 legacy/decompiled/main3_v_221/scripts/framework/api/beast/WildData.as
 * （66 loc：牧场水晶数据单例——getInstance、crystals/crystalsLoading/
 * crystalsError 三存取器与 CRYSTAL_* 事件派发）属 main3 侧 beast/wild 片
 * （spec/modules 未开工），本仓库模块清单外。
 * warehouse_v_23 只触它的静态位：WarehouseModel.as:365 在水晶应答到达后
 * 写 `WildData.reloadCrystal = false` 关闭重拉标记。这里只落该静态字段
 * （初值 true 照原版 :16），其余成员留待 beast 片整类翻译——列为本模块
 * PR 的后续模块依赖。
 */
class WildData {
	// WildData.as:16
	public static var reloadCrystal:Bool = true;
}

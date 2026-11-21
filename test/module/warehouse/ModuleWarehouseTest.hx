package module.warehouse;

import common.Consts;
import module.FarmApplication;
import utest.Assert;

/**
 * ModuleWarehouse 模块壳纯逻辑（issue #29）：壳语义 + onModuleLoadSuccess
 * 双控制器反射失败分支。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/warehouse/ModuleWarehouse.as
 *   （:13 _myBagCtrl、:15 _warehouseCtrl、ctor 置 _reportID="160592"、
 *   空 load 覆写、unload 不调 super、onModuleLoadSuccess 反射
 *   "module.warehouse.bag.MyBagController" 与
 *   "module.warehouse.house.WarehouseController" 双类、name "Warehouse Module"）
 * - name 与 nc_main.php:17-23 moduleList 的键一致
 *   （Warehouse Module→warehouse_v_23）。
 *
 * 反射失败分支：openfl 不执行外部 swf 的 AS3（probe 验证 getClass 恒
 * null），照译解析失败分支即两个控制器都保持 null（后续「功能 swf
 * 翻译」批次的接入点）。stub 阶段失败点：_reportID 未置。
 */
@:access(framework.base.Module)
@:access(module.warehouse.ModuleWarehouse)
class ModuleWarehouseTest {
	public function new() {}

	public function test_shell_name_report_id_and_reflection_null_branch() {
		var app = new FarmApplication();
		var warehouse = new ModuleWarehouse(app);
		// ModuleWarehouse.as name override（= Consts.hx:56 "Warehouse Module"）
		Assert.equals(Consts.MODULE_WAREHOUSE, warehouse.name);
		// ModuleWarehouse.as ctor 落 "160592"
		Assert.equals("160592", warehouse._reportID);
		// onModuleLoadSuccess：MyBagController/WarehouseController 双反射，
		// openfl 下必 null → 双失败分支，两个字段都保持 null
		warehouse.onModuleLoadSuccess();
		Assert.isNull(warehouse._myBagCtrl);
		Assert.isNull(warehouse._warehouseCtrl);
	}

	public function test_load_is_empty_override_and_unload_keeps_loaded() {
		var app = new FarmApplication();
		var warehouse = new ModuleWarehouse(app);
		// 空 load 覆写：不落基类 Module.as:175-181 的 _loaded=true
		warehouse.load(null);
		Assert.isFalse(warehouse.loaded);
		// unload 覆写不调 super：基类 Module.as:187-189 的复位不执行
		warehouse._loaded = true;
		warehouse.unload();
		Assert.isTrue(warehouse.loaded);
		// onNetRequestStopped（null 控制器下的防护分支，不崩即可）
		warehouse.onNetRequestStopped();
	}
}

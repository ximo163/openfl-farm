package module.warehouse;

import common.Consts;
import common.misc.Utils;
import framework.base.BaseLayer;
import framework.base.Controller;
import framework.base.Module;
import module.FarmApplication;

/**
 * module.warehouse.ModuleWarehouse —— ModuleWarehouse.as 逐句对应（issue #29
 * 替换闭包 stub）。仓库模块壳：双控制器（背包 MyBagController + 仓库
 * WarehouseController，都在外部功能 swf warehouse_v_23 里经反射装配）。
 * legacy/decompiled/main3_v_221/scripts/module/warehouse/ModuleWarehouse.as。
 */
@:keep
class ModuleWarehouse extends Module {
	// ModuleWarehouse.as:13
	private var _myBagCtrl:Controller;

	// ModuleWarehouse.as:15
	private var _warehouseCtrl:Controller;

	// ModuleWarehouse.as:17-21
	public function new(param1:FarmApplication) {
		super(param1);
		this._reportID = "160592";
	}

	// ModuleWarehouse.as:23-25（空覆写：不调 super.load，_loaded 保持 false）
	override public function load(param1:BaseLayer):Void {}

	// ModuleWarehouse.as:27-38（unload 不调 super：_loaded 不复位）
	override public function unload():Void {
		if (this._myBagCtrl != null) {
			this._myBagCtrl.finalize();
			this._myBagCtrl = null;
		}
		if (this._warehouseCtrl != null) {
			this._warehouseCtrl.finalize();
			this._warehouseCtrl = null;
		}
	}

	// ModuleWarehouse.as:40-57
	override private function onModuleLoadSuccess():Void {
		var _loc1_:Class<Dynamic> = Utils.getClass("module.warehouse.bag.MyBagController");
		if (_loc1_ != null) {
			// PORT-NOTE: 同 ModuleShop——外部 swf（warehouse_v_23）的 AS3 在
			// openfl 下不执行，getClass 恒 null → 双控制器保持 null（反射
			// 失败即移植终态），「功能 swf 翻译」批次的接入点
			this._myBagCtrl = Type.createInstance(_loc1_, []);
			this._myBagCtrl.module = this;
			this._myBagCtrl.initialze();
		}
		_loc1_ = Utils.getClass("module.warehouse.house.WarehouseController");
		if (_loc1_ != null) {
			this._warehouseCtrl = Type.createInstance(_loc1_, []);
			this._warehouseCtrl.module = this;
			this._warehouseCtrl.initialze();
		}
	}

	// 原版 override get name
	override private function get_name():String {
		return Consts.MODULE_WAREHOUSE;
	}
}

package module.mainScene.farmLand;

import common.GetCropID;
import entities.FarmLand;
import module.FarmApplication;
import module.mainScene.farmLand.widgets.LandItemRender;
import module.mainScene.farmLand.widgets.LandTile;
import utest.Assert;

/**
 * FarmLandsView 的布局度量和地块数据→控件形态分派纯逻辑（issue #8）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * FarmLandsView.as（SCALE/ITEM_WIDTH/ITEM_HEIGHT :31-35、createLandTiles
 * :109-152、updateLandItem :154-202、checkCropLoaded :591-610、landNum
 * :612-619）。作物名恒 "Crop_"+cId（Settings.as:190-193，翻译版同）。
 *
 * eval 无资源：updateLandItem 的中途 updateLandStatus 会在 LandTile 取素材
 * 处抛 "Can not get land res!"（LandTile.as:108-111，状态已先行写入）——测试
 * 捕获后断言已落定的形态；后续 createCrop 不会执行。坐标全是 0.75 的整数倍
 *（dyadic），浮点等值精确成立。
 */
@:access(module.mainScene.farmLand.FarmLandsView)
@:access(module.mainScene.farmLand.widgets.LandItemRender)
@:access(module.mainScene.farmLand.widgets.Byproduct)
class FarmLandsViewTest {
	public function new() {}

	// :31-35：SCALE 是 var、宽高是 204/102*SCALE 的导出常量——画面保真的
	// 视觉参数，逐字照抄
	public function test_scale_constants() {
		Assert.equals(0.75, FarmLandsView.SCALE);
		Assert.equals(153.0, FarmLandsView.ITEM_WIDTH); // 204*0.75
		Assert.equals(76.5, FarmLandsView.ITEM_HEIGHT); // 102*0.75
	}

	// createLandTiles :109-152（onAddedToStage 固定 6×3）：主网格 18 块按
	// 行列表序，x=275.5+r*76.5-c*76.5、y=281.75+r*38.25+c*38.25（:118-119 的
	// 46+3*ITEM_WIDTH/2=275.5、320-ITEM_HEIGHT/2=281.75），名
	// "__FarmlandItem__"+r+"."+c；随后 6 块副行（:138-139 的 _loc3_=46、
	// _loc4_=320+ITEM_HEIGHT=396.5；:144 复用内层循环尾的 _loc6_==3 → 名
	// "<r>.3"），x=46+r*76.5、y=396.5+r*38.25。
	// 断言必须强类型读：m_items 存 LandItemRender（:132/:148），而 openfl 自家
	// 的 name/x/y 是库内 get/set 属性（DisplayObject.hx:603/948/962，无物理
	// 字段），经 Dynamic 反射在 eval/js 上恒 null——见 handbook/lessons #8
	public function test_createLandTiles_layout_grid_positions_and_names() {
		var view = new FarmLandsView(new FarmLandController(null));
		view.createLandTiles(6, 3);
		Assert.equals(24, view.m_items.length); // 6*3 主网格 + 6 副行
		Assert.equals(24, view.landNum);
		Assert.isTrue(view.checkCropLoaded()); // :600-608 全部无作物实例 → true

		var r0c0:LandItemRender = view.m_items[0];
		Assert.equals("__FarmlandItem__0.0", r0c0.name);
		Assert.equals(275.5, r0c0.x);
		Assert.equals(281.75, r0c0.y);
		var r1c2:LandItemRender = view.m_items[5];
		Assert.equals("__FarmlandItem__1.2", r1c2.name);
		Assert.equals(199.0, r1c2.x); // 275.5+76.5-153
		Assert.equals(396.5, r1c2.y); // 281.75+38.25+76.5
		var r5c2:LandItemRender = view.m_items[17];
		Assert.equals("__FarmlandItem__5.2", r5c2.name);
		Assert.equals(505.0, r5c2.x); // 275.5+5*76.5-2*76.5
		Assert.equals(549.5, r5c2.y); // 281.75+5*38.25+2*38.25
		var extra0:LandItemRender = view.m_items[18];
		Assert.equals("__FarmlandItem__0.3", extra0.name);
		Assert.equals(46.0, extra0.x);
		Assert.equals(396.5, extra0.y);
		var extra5:LandItemRender = view.m_items[23];
		Assert.equals("__FarmlandItem__5.3", extra5.name);
		Assert.equals(428.5, extra5.x); // 46+5*76.5
		Assert.equals(587.75, extra5.y); // 396.5+5*38.25
	}

	// landNum :612-619 / checkCropLoaded :591-610：未建格时 0 / 空表恒 true
	public function test_landNum_and_checkCropLoaded_before_tiles() {
		var view = new FarmLandsView(new FarmLandController(null));
		Assert.equals(0, view.landNum); // m_items == null → 0
		Assert.isTrue(view.checkCropLoaded()); // :593-595
	}

	// 调 updateLandItem，预期在 LandTile 取素材处中断（LandTile.as:108-111），
	// 返回是否如期抛出
	function runUpdate(view:FarmLandsView, render:LandItemRender, land:FarmLand):Bool {
		var threw = false;
		try {
			view.updateLandItem(render, land);
		} catch (e:Dynamic) {
			threw = true;
		}
		return threw;
	}

	// :168-180 有作物分支的成熟态（step 5/6）：病虫草计数一律清零
	//（createByproduct(0,0)），地块状态固定 (true,false) → SUITABLE，
	// setGrowStep(_step, cId) 落状态；createCrop（:195）不会执行
	public function test_updateLandItem_mature_land_clears_byproduct_and_pins_suitable() {
		var view = new FarmLandsView(new FarmLandController(null));
		var render = new LandItemRender();
		var land = new FarmLand({});
		land._cId = 1;
		land._step = 5;
		land._pest = 2;
		land._weed = 3;
		land._humidity = 1;
		land._fertilize = true;
		Assert.isTrue(runUpdate(view, render, land));
		Assert.equals(5, render._step);
		Assert.equals(1, render._cropID);
		Assert.equals(0, render._byproduct._insect); // :178 清零
		Assert.equals(0, render._byproduct._weed);
		Assert.equals(LandTile.SUITABLE, render._land.status); // :179 (true,false)
	}

	// :171-174：_cropStatus>=7 截到 7-1=6——枯萎态仍按成熟分支渲染
	public function test_updateLandItem_clamps_withered_status_to_step6() {
		var view = new FarmLandsView(new FarmLandController(null));
		var render = new LandItemRender();
		var land = new FarmLand({});
		land._cId = 1;
		land._step = 5;
		land._cropStatus = 7;
		Assert.isTrue(runUpdate(view, render, land));
		Assert.equals(6, render._step); // setGrowStep(6, 1)
		Assert.equals(1, render._cropID);
		Assert.equals(LandTile.SUITABLE, render._land.status); // 6 走成熟分支
	}

	// :181-193 生长期分支：虫只在 step 3/4 带入（这里 _pest=0）、草原样带入
	//（_weed=0）；地块状态按 humidity/fertilize 映射（0/false → DRY）。
	// step 3 会触发 getInsectPosition（LandItemRender.as:103-105）——给
	// GetCropID.theApp 装空 model 的 app（Main 启动才设置），无 crops 配置 →
	// 返回 null → byproduct.insectPosition 置 null（Byproduct.as:53-56 纯赋值）
	public function test_updateLandItem_growing_land_maps_dry_status() {
		GetCropID.theApp = new FarmApplication();
		var view = new FarmLandsView(new FarmLandController(null));
		var render = new LandItemRender();
		var land = new FarmLand({});
		land._cId = 1;
		land._step = 3;
		land._pest = 0;
		land._weed = 0;
		land._humidity = 0;
		land._fertilize = false;
		Assert.isTrue(runUpdate(view, render, land));
		Assert.equals(3, render._step);
		Assert.equals(1, render._cropID);
		Assert.equals(0, render._byproduct._insect);
		Assert.equals(0, render._byproduct._weed);
		Assert.equals(LandTile.DRY, render._land.status); // :193 (false,false)
	}

	// :197-201 空地分支（cId=0 → getCropName 不会被调、_loc4_ 为 ""）：
	// clearAll（清作物 + byproduct.clear + land.reset，LandItemRender.as:63-78）
	// → reset 抛出中断，槽状态 SUITABLE（LandTile.as:159-162 传 SUITABLE），
	// 后续 :200 的 updateLandStatus 不会执行；作物位保持空
	public function test_updateLandItem_empty_land_runs_clearall_reset_path() {
		var view = new FarmLandsView(new FarmLandController(null));
		var render = new LandItemRender();
		var land = new FarmLand({});
		land._cId = 0;
		land._humidity = 1;
		land._fertilize = false;
		Assert.isTrue(runUpdate(view, render, land));
		Assert.equals(0, render._cropID); // 没建作物
		Assert.equals(0, render._step);
		Assert.equals(0, render._byproduct._insect); // clear 计数归零
		Assert.equals(0, render._byproduct._weed);
		Assert.equals(LandTile.SUITABLE, render._land.status); // reset 的 SUITABLE
	}
}

package module.mainScene.farmLand.widgets;

import utest.Assert;

/**
 * LandItemRender 的状态→控件形态映射纯逻辑（issue #8）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * widgets/LandItemRender.as（ctor 默认 :27-38、setGrowStep :40-56、clearAll
 * :63-78、createByproduct :90-110、createCrop :117-134、updateLandStatus
 * :136-160、cropLoaded :169-176）、widgets/LandTile.as（四态串 :11-17、
 * updateLandStatus :60-115、同参短路 :62-66、无素材抛 :108-111）。
 *
 * eval 无资源：LandTile.updateLandStatus 在写完 _status 之后、取素材处抛
 * "Can not get land res!"（LandTile.as:108-111）——测试捕获后经公有 status
 * 读回已落定的状态。素材名选取（.red/.black 前缀、金牌地）随资源链，不在
 * 纯逻辑单测里证明（记 issue #8 PR 说明）。
 */
@:access(module.mainScene.farmLand.widgets.LandItemRender)
@:access(module.mainScene.farmLand.widgets.Byproduct)
class LandItemRenderTest {
	public function new() {}

	// updateLandStatus(flags, humid, fertile, gold)（:136-160）：两布尔 →
	// LandTile 状态串四象限（:143-158）。无素材环境下调用以 LandTile 的抛出
	// 收场（预期路径），threw=true 断言没被静默吞掉
	function statusAfter(render:LandItemRender, humid:Bool, fertile:Bool):String {
		var threw = false;
		try {
			render.updateLandStatus(0, humid, fertile, 0);
		} catch (e:Dynamic) {
			threw = true; // LandTile.as:108-111（状态已先行写入）
		}
		Assert.isTrue(threw);
		return render._land.status;
	}

	// :143-158 四象限：湿+未肥 SUITABLE、湿+肥 FERTILE、干+肥 DRY_FERTILE、
	// 全无 DRY
	public function test_updateLandStatus_maps_humidity_and_fertility_to_tile_status() {
		var render = new LandItemRender();
		Assert.equals(LandTile.SUITABLE, statusAfter(render, true, false));
		Assert.equals(LandTile.FERTILE, statusAfter(render, true, true));
		Assert.equals(LandTile.DRY_FERTILE, statusAfter(render, false, true));
		Assert.equals(LandTile.DRY, statusAfter(render, false, false));
	}

	// LandTile.as:62-66：参数完全相同的重复调用直接短路——第二次不再取素材、
	// 也就不再抛
	public function test_updateLandStatus_same_state_short_circuits_without_reload() {
		var render = new LandItemRender();
		var first = false;
		try {
			render.updateLandStatus(0, true, false, 0);
		} catch (e:Dynamic) {
			first = true;
		}
		Assert.isTrue(first);
		var second = false;
		try {
			render.updateLandStatus(0, true, false, 0);
		} catch (e:Dynamic) {
			second = true;
		}
		Assert.isFalse(second);
	}

	// ctor 默认（:27-38）：index -1 / cropID 0 / 无作物实例时 cropLoaded 恒 true
	//（:169-176）
	public function test_defaults() {
		var render = new LandItemRender();
		Assert.equals(-1, render.index);
		Assert.equals(0, render.cropID);
		Assert.isTrue(render.cropLoaded);
		Assert.isFalse(render.waste);
	}

	// setGrowStep :40-56：纯状态位——换 cropID 走清作物分支（:43-50），同
	// cropID 且无作物实例只记 _step（:52-55）
	public function test_setGrowStep_updates_state_without_crop_instance() {
		var render = new LandItemRender();
		render.setGrowStep(3, 7);
		Assert.equals(3, render._step);
		Assert.equals(7, render._cropID);
		render.setGrowStep(4, 7);
		Assert.equals(4, render._step); // 同 id：只写 _step
		Assert.equals(7, render._cropID);
		render.setGrowStep(5, 9);
		Assert.equals(5, render._step); // 换 id：作物位重置后仍记录新帧
		Assert.equals(9, render._cropID);
	}

	// createCrop :119-121：守卫读**实例字段** _cropID（非 param1）——全新
	// render ctor 默认 _cropID=0（:32），param1 传什么都抛 "Invalid crop id."
	public function test_createCrop_throws_while_render_crop_id_is_zero() {
		var render = new LandItemRender(); // :32 默认 _cropID=0
		var message = "";
		try {
			render.createCrop(0, "Crop_2", "url");
		} catch (e:openfl.errors.Error) {
			message = e.message;
		}
		Assert.equals("Invalid crop id.", message);
		var second = "";
		try {
			render.createCrop(2, "Crop_2", "url"); // param1 非 0：守卫不看它
		} catch (e:openfl.errors.Error) {
			second = e.message;
		}
		Assert.equals("Invalid crop id.", second);
		Assert.isNull(render._crop); // 没建实例
	}

	// createCrop :123-126：_cropID!=0（过 :119 守卫）时名字或 url 为空直接
	// 返回，不建作物实例——cropLoaded 走 "无实例恒 true" 一侧（:169-176）
	public function test_createCrop_empty_name_or_url_returns_without_creating_crop() {
		var render = new LandItemRender();
		render.setGrowStep(1, 2); // :50 _cropID=2
		render.createCrop(2, "", "url"); // :123 名字空
		Assert.isTrue(render.cropLoaded);
		render.createCrop(2, "Crop_2", ""); // :123 url 空
		Assert.isTrue(render.cropLoaded);
		Assert.isNull(render._crop); // 两次都没建实例
	}
}

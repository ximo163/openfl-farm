package module.mainScene.npc.widgets;

import com.qzone.corelib.net.RSLManager;
import common.CommonData;
import common.Consts;
import common.GetCropID;
import FarmLoading;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import shim.As3;

/**
 * module.mainScene.npc.widgets.DogRender —— V3b 顺手翻（issue #8 闭包，
 * DogRender.as 90 loc ≤ 100）。NPCView 的看门狗矢量渲染：requestClass
 * 拉狗素材后 getMaterial 构造。逐句对应 legacy/decompiled/main3_v_221/
 * scripts/module/mainScene/npc/widgets/DogRender.as。
 */
class DogRender extends Sprite {
	// DogRender.as:8-12
	private var dogLoading:MovieClip;
	private var dogLoadingTimer:Int;
	private var vectorCartoon:MovieClip;

	// DogRender.as:14-18（AS3 实例 const → static final，CLAUDE.md 规则）
	private static final distance:Float = 50;
	private static final startX:Int = 200;

	// DogRender.as:20
	private var _id:String;

	// DogRender.as:22-37
	public function new(param1:Int = 1) {
		super();
		if (param1 > Consts.DECOR_DOG_BASE_ID) {
			param1 -= Consts.DECOR_DOG_BASE_ID;
		}
		this._id = Std.string(param1);
		var _loc2_:String = "FDog" + this._id;
		var _loc3_:String = GetCropID.idToDogUrl(_loc2_, false);
		this.dogLoadingTimer = As3.setTimeout(this.showLoading, 300);
		CommonData.rslManager.requestClass(_loc2_, this.init, _loc3_);
	}

	// DogRender.as:39-44
	public function stop():Void {
		if (this.vectorCartoon != null && As3.truthy(this.vectorCartoon)) {
			this.vectorCartoon.stop();
		}
	}

	// DogRender.as:46-66（init：素材到位后换上矢量狗）
	private function init():Void {
		As3.clearTimeout(this.dogLoadingTimer);
		if (this.dogLoading != null) {
			this.dogLoading.stop();
			this.removeChild(this.dogLoading);
			this.dogLoading = null;
		}
		if (this.vectorCartoon != null && As3.truthy(this.vectorCartoon)) {
			removeChild(this.vectorCartoon);
		}
		var _loc2_:Dynamic = RSLManager.getMaterial("FDog" + this._id);
		this.vectorCartoon = Std.isOfType(_loc2_, MovieClip) ? cast(_loc2_, MovieClip) : null;
		if (this.vectorCartoon != null) {
			this.vectorCartoon.x = startX + distance + 1;
			this.vectorCartoon.y = 200;
			addChild(this.vectorCartoon);
		}
		this.mouseEnabled = false;
		this.mouseChildren = false;
	}

	// DogRender.as:68-71（get id）
	public var id(get, never):String;

	private function get_id():String {
		return this._id;
	}

	// DogRender.as:73-83（showLoading：300ms 没到位先放加载条）
	private function showLoading():Void {
		if (this.dogLoading == null) {
			this.dogLoading = new FarmLoading();
			this.dogLoading.y = 240;
			this.dogLoading.x = 210 + distance;
			this.addChild(this.dogLoading);
		}
	}
}

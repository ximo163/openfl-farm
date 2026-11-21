package module.levelup;

import common.misc.Utils;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import shim.As3;

/**
 * module.levelup.LandRender —— LandRender.as 逐句对应（issue #18 升级模块
 * 片）。升级面板的地块行：Update.landRender 素材 + 文案/图标按地块类型三选
 * （黄/红/黑）。素材在部署包缺符号（UpdateLandRender 空壳注），具名子件
 * landTxt/landIcon 查空，赋值行与原版跑本部署包同点崩。
 * PORT-NOTE: `this._ui["landTxt"]`（swf 符号具名子件）→ As3.childOf
 * （先实例字段再 getChildByName）；`.text =` 按名写走 Reflect.setProperty。
 */
@:keep
class LandRender extends Sprite {
	// LandRender.as:10-18
	public static final NORMAL_LAND:Int = 1;

	public static final RED_LAND:Int = 2;

	public static final BLACK_LAND:Int = 3;

	public static final ROW_GAP:Int = 150;

	public static final COLUMN_GAP:Int = 70;

	// :20-22
	private var _data:Dynamic;

	private var _ui:Sprite;

	// :24-31
	public function new(param1:Dynamic) {
		super();
		this._data = param1;
		this._ui = Std.isOfType(Utils.getMaterial("Update.landRender"), Sprite)
			? cast(Utils.getMaterial("Update.landRender"), Sprite) : null;
		addChild(this._ui);
		this.setData();
	}

	// :33-50
	private function setData():Void {
		if (Reflect.field(this._data, "landType") == NORMAL_LAND) {
			Reflect.setProperty(As3.childOf(this._ui, "landTxt"), "text", "黄土地");
			cast(As3.childOf(this._ui, "landIcon"), MovieClip).gotoAndStop(NORMAL_LAND);
		} else if (Reflect.field(this._data, "landType") == RED_LAND) {
			Reflect.setProperty(As3.childOf(this._ui, "landTxt"), "text", "红土地");
			cast(As3.childOf(this._ui, "landIcon"), MovieClip).gotoAndStop(RED_LAND);
		} else if (Reflect.field(this._data, "landType") == BLACK_LAND) {
			Reflect.setProperty(As3.childOf(this._ui, "landTxt"), "text", "黑土地");
			cast(As3.childOf(this._ui, "landIcon"), MovieClip).gotoAndStop(BLACK_LAND);
		}
	}
}

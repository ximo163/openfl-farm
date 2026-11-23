package module;

import common.misc.Utils;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.errors.Error;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.GameGuide —— GameGuide.as 逐句对应（issue #43 真身，替换 #7 闭包
 * stub——2026-11-21 真机「引导不弹」的正主就是本类空体）。
 * 鱼塘新手引导箭头：步骤数据是本类私有静态表 fishGuideStep（GameGuide.as
 * :42-87 硬编码，无服务端/xml 下发）；唯一开关 toggle_water 由
 * WaterGrayOpen.onTutorialClosed（WaterGrayOpen.as:103，#37 已翻）在鱼塘教程
 * 关闭后置位，随后同处 showStep(WATER_SHOP_ICON)+autoHide(8) 起步，链路经
 * ShopView/ShopController/BuyFishWindow/MyBagController/WaterPool 逐步推进
 * （#35/#36/#37 调用点已在）。箭头素材 Arrow 是 farmui2_v_58 的导出符号
 * （spec/modules/farm-basic.json 本条 assets，宿主 shim src/Arrow.hx）。
 */
@:keep
class GameGuide {
	// GameGuide.as:16
	private static var _instance:GameGuide;

	// GameGuide.as:18（issue #37：WaterGrayOpen.onTutorialClosed 置位）
	public static var toggle_water:Bool = false;

	// GameGuide.as:20
	public static final WATER_SHOP_ICON:Int = 0;

	// GameGuide.as:22-32（issue #35 闭包成员补齐：ShopView/ShopController/
	// 买入窗口的鱼苗引导步骤号）
	public static final WATER_FISH_TAB:Int = 1;

	// GameGuide.as:24
	public static final WATER_FISH_ITEM:Int = 2;

	// GameGuide.as:26
	public static final WATER_UNLOCK_FISH:Int = 3;

	// GameGuide.as:28
	public static final WATER_FISH_ITEM_AGAIN:Int = 4;

	// GameGuide.as:30
	public static final WATER_BUY_FISH:Int = 5;

	// GameGuide.as:32
	public static final WATER_BAG_ICON_FISH:Int = 6;

	// GameGuide.as:34（issue #36：MyBagController.showFishGuide 的背包鱼苗
	// 引导步骤号）
	public static final WATER_BAG_FISH_ITEM:Int = 7;

	// GameGuide.as:36（issue #36：MyBagView.onChildClick 的鱼苗引导派发步）
	public static final WATER_POOL_CENTER:Int = 8;

	// GameGuide.as:38（bigMode 档 x 偏移）
	private static final OFFSET_BIG_MODE:Int = 60;

	// GameGuide.as:40（normalView 档 x 偏移）
	private static final OFFSET_SMALL_MODE:Int = -50;

	// GameGuide.as:42-87（fishGuideStep：九步硬编码坐标表；id 8 的 x/y == -1
	// 是动态锚——showStep 落 param2/param3 参数位）
	private static final fishGuideStep:Array<Dynamic> = [
		{"id": 0, "x": 710, "y": 55, "dir": 0},
		{"id": 1, "x": 235, "y": 120, "dir": 1},
		{"id": 2, "x": 183, "y": 220, "dir": 3},
		{"id": 3, "x": 515, "y": 362, "dir": 1},
		{"id": 4, "x": 183, "y": 220, "dir": 3},
		{"id": 5, "x": 365, "y": 458, "dir": 0},
		{"id": 6, "x": 322, "y": 510, "dir": 1},
		{"id": 7, "x": 215, "y": 436, "dir": 3},
		{"id": 8, "x": -1, "y": -1, "dir": 1}
	];

	// GameGuide.as:89（教程关闭后封死 showStep）
	private var _stop:Bool;

	// GameGuide.as:91
	private var _container:DisplayObjectContainer;

	// GameGuide.as:93（引导文案 TextField，showStep 懒建）
	private var _tip:TextField;

	// GameGuide.as:95（autoHide 的可清除句柄）
	private var _timeout:UInt;

	// GameGuide.as:97（Utils.getMaterial("Arrow") 的箭头剪辑）
	private var _arrow:MovieClip;

	// GameGuide.as:99
	private var _step:Int;

	// GameGuide.as:101（stageWidth < 720 的小视图偏移档）
	private var _normalView:Bool;

	// GameGuide.as:103（stageWidth > 820 的大视图偏移档）
	private var _bigMode:Bool;

	// GameGuide.as:105-115
	public function new() {
		this._arrow = cast(Utils.getMaterial("Arrow"), MovieClip);
		this._container = null;
		this._step = -1;
		this._bigMode = false;
		this._timeout = 0;
		this._stop = false;
		this._tip = null;
	}

	// GameGuide.as:117-125
	public static function instance():GameGuide {
		if (_instance != null) {
			return _instance;
		}
		_instance = new GameGuide();
		return _instance;
	}

	// GameGuide.as:127-141（sec<=0 立即 hide；否则到点 hide 并封死后续步骤）
	public function autoHide(param1:Int):Void {
		var sec:Int = param1;
		if (sec <= 0) {
			this.hide();
			return;
		}
		this.resetTimeout();
		this._timeout = As3.setTimeout(function():Void {
			hide();
			_stop = true;
		}, sec * 1000);
	}

	// GameGuide.as:143-146
	public var currentStep(get, never):Int;

	private function get_currentStep():Int {
		return this._step;
	}

	// GameGuide.as:148-161（箭头与 tip 都只在还挂着时摘）
	public function hide():Void {
		if (this._container != null) {
			if (this._arrow != null && this._container.contains(this._arrow) == true) {
				this._container.removeChild(this._arrow);
			}
			if (this._tip != null && this._container.contains(this._tip) == true) {
				this._container.removeChild(this._tip);
			}
		}
	}

	// GameGuide.as:163-260（showStep 四道门：toggle_water/_stop → 箭头 →
	// 前进向 → 表长；越界步只记 _step 不渲染。容器缺失抛错）
	public function showStep(param1:Int, param2:Int = 0, param3:Int = 0, param4:String = ""):Void {
		var _loc5_:Int = 0;
		if (toggle_water == false || this._stop == true) {
			return;
		}
		if (this._arrow == null) {
			return;
		}
		if (param1 <= this._step) {
			return;
		}
		this._step = param1;
		if (this._step >= fishGuideStep.length) {
			return;
		}
		if (this._container != null) {
			this._arrow.x = Reflect.field(fishGuideStep[this._step], "x");
			this._arrow.y = Reflect.field(fishGuideStep[this._step], "y");
			this._container.addChild(this._arrow);
			if (this._bigMode == true) {
				this._arrow.x += OFFSET_BIG_MODE;
				if (param1 == WATER_SHOP_ICON) {
					this._arrow.x += 68;
				}
			} else if (this._normalView == true) {
				this._arrow.x += OFFSET_SMALL_MODE;
				if (param1 == WATER_SHOP_ICON) {
					this._arrow.x += -50;
				}
			}
			if (Reflect.field(fishGuideStep[this._step], "x") == -1 && Reflect.field(fishGuideStep[this._step], "y") == -1) {
				this._arrow.x = param2;
				this._arrow.y = param3;
			}
			_loc5_ = As3.intOf(Reflect.field(fishGuideStep[this._step], "dir"));
			if (_loc5_ == 0) {
				this._arrow.scaleX = 1;
				this._arrow.scaleY = 1;
				this._arrow.rotation = 0;
			} else if (_loc5_ == 1) {
				this._arrow.scaleX = 1;
				this._arrow.scaleY = -1;
				this._arrow.rotation = 0;
			} else if (_loc5_ == 2) {
				this._arrow.scaleX = 1;
				this._arrow.scaleY = 1;
				this._arrow.rotation = -90;
			} else if (_loc5_ == 3) {
				this._arrow.scaleX = 1;
				this._arrow.scaleY = 1;
				this._arrow.rotation = 90;
			}
			if (param4 != null && param4 != "") {
				if (this._tip == null) {
					this._tip = new TextField();
					this._tip.defaultTextFormat = new TextFormat("SimSun", 14, 16750848, true, false, false, null, null, "left", 0, 0, 0, 0);
					this._tip.selectable = false;
					this._tip.autoSize = TextFieldAutoSize.RIGHT;
					this._tip.filters = [new GlowFilter(10053171, 1, 3, 3, 5, 1)];
				}
				if (param1 == WATER_FISH_ITEM) {
					this._tip.text = param4;
					this._tip.x = this._arrow.x - this._tip.width - 10;
					this._tip.y = this._arrow.y - this._tip.height - 20;
					this._container.addChild(this._tip);
				}
			} else if (this._tip != null && this._tip.parent != null) {
				this._tip.parent.removeChild(this._tip);
			}
			this.resetTimeout();
			return;
		}
		throw new Error("Container property must be set first!");
	}

	// GameGuide.as:262-269（uint 恒 >= 0，条件照原文保留）
	private function resetTimeout():Void {
		if (this._timeout >= 0) {
			As3.clearTimeout(this._timeout);
			this._timeout = 0;
		}
	}

	// GameGuide.as:271-279（container：引导挂的容器层；按舞台宽度定偏移档）
	public var container(get, set):DisplayObjectContainer;

	private function get_container():DisplayObjectContainer {
		return this._container;
	}

	private function set_container(param1:DisplayObjectContainer):DisplayObjectContainer {
		this._container = param1;
		if (this._container != null && this._container.stage != null) {
			this._bigMode = this._container.stage.stageWidth > 820;
			this._normalView = this._container.stage.stageWidth < 720;
		}
		return param1;
	}
}

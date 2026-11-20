package module.mainScene.farmLand.widgets;

import common.misc.Utils;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;

/**
 * module.mainScene.farmLand.widgets.Byproduct —— V3b 翻译（issue #8）。
 * 虫/草副产物：计数 0..3 对位摆精灵，位置表可被作物配置的 insect 串覆写。
 * 逐句对应 legacy/decompiled/main3_v_221/scripts/module/mainScene/farmLand/
 * widgets/Byproduct.as。
 */
class Byproduct {
	// Byproduct.as:10-22
	private var _insect:Int;
	private var _parent:DisplayObjectContainer;
	private var _insectSprite:Sprite;
	private var _insectPosition:Array<Dynamic>;
	private var _weedSprite:Sprite;
	private var _weed:Int;
	private var _weedPosition:Array<Dynamic>;

	// Byproduct.as:24-32
	public function new(param1:DisplayObjectContainer) {
		this._insectPosition = [[0, 10], [45, 20], [120, 10]];
		this._weedPosition = [[0, 10], [45, 20], [120, 10]];
		this._weed = 0;
		this._insect = 0;
		this._parent = param1;
	}

	// Byproduct.as:34-52（updateInsectPosition：按位置表刷已有虫精灵坐标）
	public function updateInsectPosition():Void {
		var _loc1_:Int = 0;
		if (this._insectPosition == null) {
			return;
		}
		if (this._insectSprite != null) {
			_loc1_ = 0;
			while (_loc1_ < this._insectSprite.numChildren) {
				this._insectSprite.getChildAt(_loc1_).x = this._insectPosition[_loc1_][0];
				this._insectSprite.getChildAt(_loc1_).y = this._insectPosition[_loc1_][1];
				_loc1_++;
			}
		}
	}

	// Byproduct.as:53-56（set insectPosition：纯赋值）
	public var insectPosition(never, set):Array<Dynamic>;

	private function set_insectPosition(param1:Array<Dynamic>):Array<Dynamic> {
		this._insectPosition = param1;
		return param1;
	}

	// Byproduct.as:58-75（clear：摘精灵、计数归零）
	public function clear():Void {
		if (this._parent != null) {
			if (this._insectSprite != null && this._parent.contains(this._insectSprite) == true) {
				this._parent.removeChild(this._insectSprite);
				this._insectSprite = null;
			}
			if (this._weedSprite != null && this._parent.contains(this._weedSprite) == true) {
				this._parent.removeChild(this._weedSprite);
				this._weedSprite = null;
			}
		}
		this._weed = 0;
		this._insect = 0;
	}

	// Byproduct.as:77-105（updateWeed：0..3 株草对位增删。素材缺失时
	// numChildren 永不增长、原版同形死循环——只在无资源环境发生，测试只碰
	// 计数 0 的路径）
	public function updateWeed():Void {
		var _loc1_:Sprite = null;
		if (this._weedSprite == null && this._weed != 0) {
			this._weedSprite = new Sprite();
			this._weedSprite.name = "__weeds__";
			this._parent.addChild(this._weedSprite);
		}
		if (this._weedSprite == null) {
			return;
		}
		this._weed = Std.int(Math.min(3, this._weed));
		if (this._weedSprite.numChildren > this._weed) {
			while (this._weedSprite.numChildren > this._weed) {
				this._weedSprite.removeChildAt(this._weedSprite.numChildren - 1);
			}
		} else {
			while (this._weedSprite.numChildren < this._weed) {
				_loc1_ = asSprite(Utils.getMaterial("Weed"));
				if (_loc1_ != null) {
					_loc1_.cacheAsBitmap = true;
					_loc1_.x = this._weedPosition[this._weedSprite.numChildren][0];
					_loc1_.y = this._weedPosition[this._weedSprite.numChildren][1];
					this._weedSprite.addChild(_loc1_);
				}
			}
		}
	}

	// Byproduct.as:107-112（set insect）
	public var insect(never, set):Int;

	private function set_insect(param1:Int):Int {
		this._insect = param1;
		return param1;
	}

	// Byproduct.as:114-117（set weed）
	public var weed(never, set):Int;

	private function set_weed(param1:Int):Int {
		this._weed = param1;
		return param1;
	}

	// Byproduct.as:119-136（updateInsect：0..3 只虫追加；与 updateWeed 同形）
	public function updateInsect():Void {
		var _loc1_:Sprite = null;
		if (this._insectSprite == null && this._insect != 0) {
			this._insectSprite = new Sprite();
			this._insectSprite.name = "__insects__";
			this._parent.addChild(this._insectSprite);
		}
		if (this._insectSprite == null) {
			return;
		}
		this._insect = Std.int(Math.min(3, this._insect));
		if (this._insectSprite.numChildren > this._insect) {
			while (this._insectSprite.numChildren > this._insect) {
				this._insectSprite.removeChildAt(this._insectSprite.numChildren - 1);
			}
		} else {
			while (this._insectSprite.numChildren < this._insect) {
				_loc1_ = asSprite(Utils.getMaterial("Insect"));
				this._insectSprite.addChild(_loc1_);
			}
		}
	}

	// 原版 `Utils.getMaterial(...) as Sprite`
	private static function asSprite(param1:Dynamic):Sprite {
		if (Std.isOfType(param1, Sprite)) {
			return cast(param1, Sprite);
		}
		return null;
	}
}

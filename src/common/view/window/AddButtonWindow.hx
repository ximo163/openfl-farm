package common.view.window;

import com.qzone.qui.controls.Button;
import common.view.window.BaseWindow;
import openfl.display.DisplayObject;
/**
 * common.view.window.AddButtonWindow —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 带附加按钮的提示窗（AddButtonWindow.as）；FarmStage 建层时按 Consts 注册进控件表，本片只保类形态
 * （@:keep 防 dce，供 register/Type.resolveClass 拿到类引用），窗体/动效
 * 随对应片接入。
 * issue #29 最小补了 DogFoodWindow 用到的成员（addChildCache/buttonCache 字段、
 * addWindowChild/removeAllButton），字段/方法体照抄原文行号；其余（init 的
 * 缓存子件上树 + 按钮排布 + toCenterPositon、winButton 内部类）仍属 qui 窗口
 * 片（后续模块依赖）。
 * issue #35 补译 init/toCenterPositon（AddButtonWindow.as:68-112）：BuyDiyWindow
 * （shop 片，本仓库 spec/modules/farm-shop-ui.json）setData 的 `super.init()`
 * 直落这里——没有这段，addWindowChild 缓存的子件永不上树、窗体空白。
 * addButton（winButton）本体仍属 qui 窗口片：stub 恒返 null 且不进 buttonCache，
 * init 的按钮排布循环在本部署是原版死代码，照抄保留。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	// AddButtonWindow.as:15
	private var addChildCache:Array<Dynamic> = [];

	// AddButtonWindow.as:17
	private var buttonCache:Array<Dynamic> = [];

	// AddButtonWindow.as:16（issue #35 补，init 按钮排布用）
	private var _buttonSpace:Int = 10;

	// AddButtonWindow.as:18（issue #35 补，init 按钮排布用）
	private var _bottomSpace:Int = 40;

	public function new(param1:interfaces.IMsgCenter = null) {
		super(param1);
	}

	// AddButtonWindow.as:68-103（issue #35 补译；buttonCache 元素是 winButton
	// （Button 子类，DisplayObject），Dynamic 接收者按三选一规则 cast 真类型；
	// 本部署 addButton 恒返 null、buttonCache 恒空，排布循环为原版死代码）
	private override function init():Void {
		var _loc5_:Int = 0;
		var _loc1_:Int = 0;
		_loc1_ = 0;
		while (_loc1_ < this.addChildCache.length) {
			this.addChild(cast(this.addChildCache[_loc1_], DisplayObject));
			_loc1_++;
		}
		var _loc2_:Int = 0;
		var _loc3_:Int = 0;
		var _loc4_:Int = this.buttonCache.length;
		if (_loc4_ > 0) {
			_loc5_ = _loc4_ - 1;
			_loc1_ = 0;
			while (_loc1_ < _loc5_) {
				// AS3 int += Number 的逐次截断 → Std.int（openfl width 是 Float）
				_loc3_ += Std.int(cast(this.buttonCache[_loc1_], DisplayObject).width + this._buttonSpace);
				_loc1_++;
			}
			_loc3_ += Std.int(cast(this.buttonCache[_loc5_], DisplayObject).width);
			_loc2_ = Std.int(this.width * 0.5 - _loc3_ * 0.5);
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				cast(this.buttonCache[_loc1_], DisplayObject).x = _loc2_;
				_loc2_ += Std.int(cast(this.buttonCache[_loc1_], DisplayObject).width + this._buttonSpace);
				cast(this.buttonCache[_loc1_], DisplayObject).y = this.height - this._bottomSpace;
				addChild(cast(this.buttonCache[_loc1_], DisplayObject));
				_loc1_++;
			}
		}
		this.toCenterPositon();
	}

	// AddButtonWindow.as:105-112（issue #35 补译）
	private function toCenterPositon():Void {
		if (stage != null) {
			x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
			y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
		}
	}

	// AddButtonWindow.as:29-32（issue #41 write-tests 补签名，体照原文一行）
	private function set_betweenSpace(param1:Int):Int {
		this._buttonSpace = param1;
		return param1;
	}

	// AddButtonWindow.as:34-37（issue #41 write-tests 补签名，体照原文一行）
	private function set_bottomSpace(param1:Int):Int {
		this._bottomSpace = param1;
		return param1;
	}

	public var betweenSpace(never, set):Int;
	public var bottomSpace(never, set):Int;

	// AddButtonWindow.as:39-43（issue #41 write-tests 补签名，体照原文两行）
	public function addSpecialButton(param1:DisplayObject):DisplayObject {
		this.buttonCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:56-62（addButton：建 qui Button + 排布 + 挂点按回调，
	// qui 按钮片翻译；本片 PreviewDiyWindow 只调不用返回值。Function → Dynamic）
	public function addButton(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25,
		param5:Dynamic = null, param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false,
		param10:String = null, param11:Int = 0):Button {
		return null;
	}

	// AddButtonWindow.as:64-68（缓存进窗，AddButtonWindow.init 上树）
	public function addWindowChild(param1:DisplayObject):DisplayObject {
		this.addChildCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:70-73
	public function removeAllButton():Void {
		this.buttonCache = [];
	}

	// AddButtonWindow.as:63-66（issue #41 write-tests 补签名，体照原文一行）
	public function removeAllWindowChild():Void {
		this.addChildCache = [];
	}
}

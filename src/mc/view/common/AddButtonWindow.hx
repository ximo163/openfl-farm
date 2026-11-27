package mc.view.common;

import com.minutes.ui.control.LipiButton;
import com.minutes.ui.core.LipiSkin;
import common.MaterialLib;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * mc.view.common.AddButtonWindow —— AddButtonWindow.as 逐句对应（issue #87
 * 牧场「通用视图」片；#19 的签名面 stub 充真身——stub 期 addButton 直添
 * 子件是权宜，原文语义是入 buttonCache、init 才排布上树，本翻译归真）。
 * 底行按钮窗：addButton/addSpecialButton 只入缓存，init 时把缓存子件上树、
 * 按钮按「总宽居中、间距 _buttonSpace、y=height-_bottomSpace」排布后上树，
 * 并 toCenterPositon 按 stage 居中。文件尾内部类 winButton 同文件模块
 * 子类型（仓内先例：LipiContainer.hx 的 ScrollBarSkin、不加 private）。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/common/AddButtonWindow.as。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	// AddButtonWindow.as:11-17
	private var addChildCache:Array<Dynamic> = [];
	private var _buttonSpace:Int = 10;
	private var buttonCache:Array<Dynamic> = [];
	private var _bottomSpace:Int = 45;

	// AddButtonWindow.as:20-26
	public function new() {
		super();
		width = 360;
		height = 240;
		mode = true;
	}

	// AddButtonWindow.as:28-31
	public var betweenSpace(never, set):Int;

	private function set_betweenSpace(param1:Int):Int {
		this._buttonSpace = param1;
		return param1;
	}

	// AddButtonWindow.as:33-36
	// PORT-NOTE（stage null 守卫，deviations 候选）：Master2 原文**无**
	// `if(stage != null)` 守卫（main3 同名类 AddButtonWindow.as:107 有——
	// 两部署包同族类的变体差异）。原版生产链 init 必由 WindowLayer 在
	// 上树后调用（stage 恒非 null），守卫不改变任何原版可达行为的
	// 结果；裸调 init（未上树）时原文 NPE、守卫版跳过居中——纯逻辑
	// 单测（无 stage 环境）依赖后者，与 main3 变体形态对齐。
	private function toCenterPositon():Void {
		if (stage != null) {
			x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
			y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
		}
	}

	// AddButtonWindow.as:38-41
	public function closeWindow(param1:Event = null):Void {
		this.closeHandler();
	}

	// AddButtonWindow.as:42-46
	public function addWindowChild(param1:DisplayObject):DisplayObject {
		this.addChildCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:48-51
	public function removeAllWindowChild():Void {
		this.addChildCache = [];
	}

	// AddButtonWindow.as:53-87（init：缓存子件先上树，再按钮排布。
	// PORT-NOTE（类型二处）：① _loc2_/_loc3_ 原文是 int——Number 表达式
	// 赋进 int 变量在 AS3 逐次截断（宽度实践上是整数，截断无观察差，
	// 但语义逐字：累进/赋值都经 Std.int 截一次）。② buttonCache 是
	// 无类型 Array，`.width/.x/.y` 原文走 AVM2 动态查找（访问器照常
	// 解析）——Haxe 的 Dynamic 字段访问在 eval 看不见 openfl 库内
	// get/set 属性（lessons #8），且 cpp 禁 Dynamic 裸写；数组元素
	// 实为 winButton/addSpecialButton 进的 DisplayObject，强转
	// DisplayObject 后读写（addSpecialButton 的形参类型即证成）。
	// toCenterPositon 依赖 stage——未上树调用 NPE 与原版一致）
	override public function init(param1:openfl.geom.Rectangle = null):Void {
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
				_loc3_ = Std.int(_loc3_ + cast(this.buttonCache[_loc1_], DisplayObject).width + this._buttonSpace);
				_loc1_++;
			}
			_loc3_ = Std.int(_loc3_ + cast(this.buttonCache[_loc5_], DisplayObject).width);
			_loc2_ = Std.int(this.width * 0.5 - _loc3_ * 0.5);
			_loc1_ = 0;
			while (_loc1_ < _loc4_) {
				cast(this.buttonCache[_loc1_], DisplayObject).x = _loc2_;
				_loc2_ = Std.int(_loc2_ + cast(this.buttonCache[_loc1_], DisplayObject).width + this._buttonSpace);
				cast(this.buttonCache[_loc1_], DisplayObject).y = this.height - this._bottomSpace;
				addChild(cast(this.buttonCache[_loc1_], DisplayObject));
				_loc1_++;
			}
		}
		this.toCenterPositon();
	}

	// AddButtonWindow.as:89-93
	public function addSpecialButton(param1:DisplayObject):DisplayObject {
		this.buttonCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:95-98
	public function removeAllButton():Void {
		this.buttonCache = [];
	}

	// AddButtonWindow.as:100-106
	public function addButton(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25, param5:Dynamic = null,
			param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false, param10:String = null, param11:Int = 0):LipiButton {
		var _loc12_:LipiButton = new WinButton(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10, param11);
		this.buttonCache.push(_loc12_);
		return _loc12_;
	}

	// AddButtonWindow.as:108-111
	public var bottomSpace(never, set):Int;

	private function set_bottomSpace(param1:Int):Int {
		this._bottomSpace = param1;
		return param1;
	}
}

/**
 * AddButtonWindow.as 文件尾内部类 winButton（:113-161）：带点击动作闭包
 * 的 LipiButton——ctor 收 addButton 全 11 参，param5 为 null 时 ac 落空
 * 方法 empty，CLICK 派发到 ac()。
 * PORT-NOTE（命名）：Haxe 类型名必须大写字母开头，落 WinButton——
 * main3 侧 common.view.window.AddButtonWindow 同款内部类先例同形。
 */
class WinButton extends LipiButton {
	// winButton（AddButtonWindow.as:117）
	private var ac:Dynamic = null;

	// :119-152
	public function new(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25, param5:Dynamic = null,
			param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false, param10:String = null, param11:Int = 0) {
		super();
		if (param2 != null) {
			bgSkin = new LipiSkin(MaterialLib.getInstance().getClass(param2));
		}
		this.label = param1;
		this.textColor = param7;
		this.textSize = param8;
		this.textBold = param9;
		this.textFont = param10;
		this.bgAlpha = param11;
		this.enable = param6;
		this.width = param3;
		this.height = param4;
		if (param5 == null) {
			this.ac = this.empty;
		} else {
			this.ac = param5;
		}
		addEventListener(MouseEvent.CLICK, this.operation);
	}

	// :154-157
	private function empty():Void {}

	// :159-161
	private function operation(param1:Event):Void {
		this.ac();
	}
}

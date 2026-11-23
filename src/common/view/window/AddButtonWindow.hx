package common.view.window;

import com.qzone.qui.controls.Button;
import common.Consts;
import common.misc.Utils;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
 * common.view.window.AddButtonWindow —— AddButtonWindow.as 逐句对应
 * （issue #41 替换 #7 的闭包 stub；#29 补过缓存成员、#35 补过
 * init/toCenterPositon）。带附加按钮的提示窗基类：addButton 建内部类
 * winButton（构造参数→皮肤/文本格式/尺寸/点击闭包）入 buttonCache，
 * init 时统一上树并按 _buttonSpace/_bottomSpace 排布居中。
 */
@:keep
class AddButtonWindow extends BaseWindow {
	// AddButtonWindow.as:12
	private var addChildCache:Array<Dynamic> = [];

	// AddButtonWindow.as:14
	private var buttonCache:Array<Dynamic> = [];

	// AddButtonWindow.as:16
	private var _buttonSpace:Int = 10;

	// AddButtonWindow.as:18
	private var _bottomSpace:Int = 40;

	// AddButtonWindow.as:20-27
	public function new(param1:interfaces.IMsgCenter) {
		super(param1);
		width = 360;
		height = 240;
		mode = true;
		windowName = Consts.WINDOW_NAME_ABUTTON;
	}

	// AddButtonWindow.as:29-32（AS3 public set，无 get → 只写属性）
	public var betweenSpace(never, set):Int;

	private function set_betweenSpace(param1:Int):Int {
		this._buttonSpace = param1;
		return param1;
	}

	// AddButtonWindow.as:34-37
	public var bottomSpace(never, set):Int;

	private function set_bottomSpace(param1:Int):Int {
		this._bottomSpace = param1;
		return param1;
	}

	// AddButtonWindow.as:39-43
	public function addSpecialButton(param1:DisplayObject):DisplayObject {
		this.buttonCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:45-49
	public function addWindowChild(param1:DisplayObject):DisplayObject {
		this.addChildCache.push(param1);
		return param1;
	}

	// AddButtonWindow.as:51-54
	public function removeAllButton():Void {
		this.buttonCache = [];
	}

	// AddButtonWindow.as:56-61（winButton 是本文件包外内部类，Haxe 同文件
	// 模块级私有类，语义同为文件内可见）
	public function addButton(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25,
			param5:Dynamic = null, param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false,
			param10:String = null, param11:Int = 0):Button {
		var _loc12_:Button = new WinButton(param1, param2, param3, param4, param5, param6, param7, param8, param9,
			param10, param11);
		this.buttonCache.push(_loc12_);
		return _loc12_;
	}

	// AddButtonWindow.as:63-66
	public function removeAllWindowChild():Void {
		this.addChildCache = [];
	}

	// AddButtonWindow.as:68-103（buttonCache 元素是 winButton（Button 子类，
	// DisplayObject），Dynamic 接收者按三选一规则 cast 真类型；
	// AS3 int += Number 的逐次截断 → Std.int（openfl width 是 Float））
	override private function init():Void {
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

	// AddButtonWindow.as:105-112
	private function toCenterPositon():Void {
		if (stage != null) {
			x = Math.floor(stage.stageWidth * 0.5 - width * 0.5);
			y = Math.floor(stage.stageHeight * 0.5 - height * 0.5);
		}
	}
}

// AddButtonWindow.as:121-176（AS3 包外内部类 winButton → Haxe 同文件私有类，
// 只在本模块可见，与原文件内 internal 语义一致）。构造参数原样透传：皮肤名
// 经 Utils.getClass 反射，文本格式三元组落 textDefaultFormat，点击闭包存 ac
// （clickFn 写路径被覆写成只写 ac——本类不走 Label 的 clickFn 挂监听链）。
// 类名：Haxe 的 new 后类型名必须大写开头（小写在语法层解析不过），按 Task7/
// CanPickIcon 先例用 @:native 改回原类名
@:native("winButton")
private class WinButton extends Button {
	// winButton.as:124
	private var ac:Dynamic = null;

	// winButton.as:126-150。AS3 构造器与类同名，Haxe 归一为 new
	public function new(param1:String = "Button", param2:String = null, param3:Int = 100, param4:Int = 25,
			param5:Dynamic = null, param6:Bool = true, param7:Int = 16777215, param8:Int = 12, param9:Bool = false,
			param10:String = null, param11:Int = 0) {
		super();
		if (param2 != null) {
			defaultSkin = Utils.getClass(param2);
		}
		this.text = param1;
		this.textDefaultFormat.color = param7;
		this.textDefaultFormat.size = param8;
		this.textDefaultFormat.bold = param9;
		this.textDefaultFormat.font = param10;
		this.enabled = param6;
		this.width = param3;
		this.height = param4;
		if (param5 == null) {
			this.ac = this.empty;
		} else {
			this.ac = param5;
		}
		addEventListener(MouseEvent.CLICK, this.operation);
	}

	// winButton.as:152-158。Label.init 会 `clickFn = _clickFn`，被覆写的
	// setter 会把 ac 打回 _clickFn（默认 null）——先存后复原，再把基类
	// 挂监听用的 _clickFn 清掉，点击只走 operation→ac
	override private function init():Void {
		var _loc1_:Dynamic = this.ac;
		super.init();
		this.ac = _loc1_;
		_clickFn = null;
	}

	// winButton.as:160-163（AS3 setter 无返回值，Haxe 属性 setter 返回入参）
	override private function set_clickFn(param1:Dynamic):Dynamic {
		this.ac = param1;
		return param1;
	}

	// winButton.as:165-167
	private function empty():Void {}

	// winButton.as:169-175。`this.ac is Function` → Reflect.isFunction
	private function operation(param1:Event):Void {
		if (this.ac != null && Reflect.isFunction(this.ac)) {
			this.ac();
		}
	}
}

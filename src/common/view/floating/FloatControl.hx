package common.view.floating;

import interfaces.IMsgCenter;

/**
 * common.view.floating.FloatControl —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 飘字控件（注册表 + open/close）属于通用视图的飘字片；这里只保公共 API
 * 形态（FloatControl.as:13-58 的签名）让 FarmStage/FarmApplication 编译，
 * 原版行为（收获/加钱/经验飘字动画）随飘字片接入。issue #9 write-tests：
 * open/close 由空体改为 throw stub（注册表路径保留真实现）。
 */
@:keep
class FloatControl {
	// FloatControl.as:8
	private var m_libs:Dynamic;

	// FloatControl.as:13-18
	public function new(param1:IMsgCenter) {
		this.m_libs = {};
		this.m_msgControl = param1;
	}

	private var m_msgControl:IMsgCenter;

	// FloatControl.as:20-27（open：飘一个 floating——FLOATING_OPEN 带
	// floating/fid/data 经 msgCenter 派发，飘字片翻译）
	public function open(param1:String, param2:Int = 0, param3:Dynamic = null):Void {
		throw new openfl.errors.Error("not implemented");
	}

	// FloatControl.as:29-32
	public function getMsgControl():IMsgCenter {
		return this.m_msgControl;
	}

	// FloatControl.as:34-41（getClass：注册表查类）
	public function getClass(param1:String):Class<Dynamic> {
		return Reflect.field(this.m_libs, param1);
	}

	// FloatControl.as:43-50（register：floating 名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		Reflect.setField(this.m_libs, param1, param2);
	}

	// FloatControl.as:52-58（close：关掉某类 floating——FLOATING_CLOSE 带
	// floating 名派发，飘字片翻译）
	public function close(param1:String):Void {
		throw new openfl.errors.Error("not implemented");
	}
}

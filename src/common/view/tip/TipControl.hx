package common.view.tip;

import interfaces.IMsgCenter;

/**
 * common.view.tip.TipControl —— V3b/V3c 模块翻译，闭包 stub（issue #7）。
 * 提示控件（注册表 + show/hide/update）属于通用视图的提示片；这里只保
 * 公共 API 形态（TipControl.as:13-62 的签名）让 FarmStage/FarmApplication
 * 编译，原版行为（延时显示 TipLayer 上的 tip）随提示片接入。
 */
@:keep
class TipControl {
	// TipControl.as:8
	private var m_libs:Dynamic;

	// TipControl.as:13-18
	public function new(param1:IMsgCenter) {
		this.m_libs = {};
		this.m_msgCenter = param1;
	}

	private var m_msgCenter:IMsgCenter;

	// TipControl.as:20-23
	public function getMsgCenter():IMsgCenter {
		return this.m_msgCenter;
	}

	// TipControl.as:25-31（update：同屏 tip 数据刷新，提示片翻译）
	public function update(param1:String, param2:Dynamic):Void {}

	// TipControl.as:33-40（getClass：注册表查类）
	public function getClass(param1:String):Class<Dynamic> {
		return Reflect.field(this.m_libs, param1);
	}

	// TipControl.as:42-46（hide：隐藏当前 tip，提示片翻译）
	public function hide():Void {}

	// TipControl.as:48-55（register：tip 名 → 类）
	public function register(param1:String, param2:Class<Dynamic>):Void {
		Reflect.setField(this.m_libs, param1, param2);
	}

	// TipControl.as:57-62（show：显示 tip，提示片翻译）
	public function show(param1:String, param2:Dynamic, param3:Int = 0, param4:Int = 0):Void {}
}

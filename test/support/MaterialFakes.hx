package support;

import common.MaterialLib;
import openfl.system.ApplicationDomain;

/**
 * MaterialLib 假域注入（issue #87 write-tests，牧场窗件/光标测试共用）：
 * MaterialLib 的 searchClass 逐 _materialArray 里的 ApplicationDomain 查
 * hasDefinition/getDefinition（MaterialLib.as:76-89），而 openfl 的
 * ApplicationDomain 两个方法都走 Type.resolveClass（openfl 9.5.2
 * ApplicationDomain.hx：hasDefinition = resolveClass(name) != null）——
 * 所以 push 一个普通 ApplicationDomain 后，编译表里与素材同名的 root 包
 * 类即被 getMaterial 取到（Type.createInstance 零参构造）。真素材绑定类
 * 已在 src/ root（SuccessIcon/ErrorIcon/ConfirmIcon/TipBg/ButtonOrange/
 * ButtonBlue，SymbolClass.bind 在 eval 只留痕不做事）；CursorTool 派生名
 * 的两张 Animal 光标假面在 test/ root（test/CursorTool_1_101.hx 等）。
 *
 * eval 按引用收模块：root 包符号类零静态引用不进编译表，resolveClass 得
 * null（容器内实测）——本类的 anchor 数组静态引用它们强制入表。
 *
 * 隔离：MaterialLib 是单例且表无清除口，install 重建 instance（空表起装），
 * reset 把 instance 复位 null——后续 getInstance 得全新空表（同表其他
 * 测试以「注册表为空」为前提：MaterialProxyTest/MoneyIconTest/
 * ValidateCodeWindowTest 等，用例结束必须归位）。
 */
@:access(common.MaterialLib)
class MaterialFakes {
	// 静态引用锚（见类头注）：把素材假类模块拉进 eval 编译表
	static var anchor:Array<Class<Dynamic>> = [
		SuccessIcon, ErrorIcon, ConfirmIcon, ButtonOrange, ButtonBlue, TipBg,
		CursorTool_1_101, Animal_1001_1, Animal_1502_1
	];

	public function new() {}

	// 重建单例并压入假域——此后 MaterialLib.getMaterial("SuccessIcon") 等按名命中
	public static function install():Void {
		MaterialLib.instance = null;
		MaterialLib.getInstance().push(new ApplicationDomain(null));
	}

	// 复位空表：MaterialLib 回到「无注册域」的基线态
	public static function reset():Void {
		MaterialLib.instance = null;
	}
}

package mc.view.main.floating;

import mc.control.ViewControl;
import mc.events.FloatingEvent;

/**
 * mc.view.main.floating.Float —— Float.as 逐句对应（issue #87「飘字」片）。
 * 飘字开闭静态门面：open/close 各造一个 FloatingEvent（FLOATING_OPEN/
 * FLOATING_CLOSE）挂 floating 载荷经 ViewControl 派发。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/floating/Float.as。
 *
 * PORT-NOTE(命名遮蔽)：类名 `Float` 遮蔽 Haxe 标准库 Float 类型——本文件
 * 内无 Float 类型成员，无影响；其它文件引用浮点类型不受影响（仅本包内
 * 裸写 `Float` 会解析到本类），import 本类的文件如需浮点类型应写全
 * `Std`/`Float` 时注意遮蔽。
 */
@:keep
class Float {
	// Float.as:9-12
	public function new() {}

	// Float.as:14-19
	public static function close(param1:FloatingBase):Void {
		var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_CLOSE);
		_loc2_.floating = param1;
		ViewControl.getInstance().dispatchEvent(_loc2_);
	}

	// Float.as:21-26
	public static function open(param1:FloatingBase):Void {
		var _loc2_:FloatingEvent = new FloatingEvent(FloatingEvent.FLOATING_OPEN);
		_loc2_.floating = param1;
		ViewControl.getInstance().dispatchEvent(_loc2_);
	}
}

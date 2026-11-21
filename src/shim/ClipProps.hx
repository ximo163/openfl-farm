package shim;

/**
 * 素材剪辑动态属性的等价物（issue #10 真机排查确立，2026-11-21）。
 *
 * 原版 AS3 在 swf 素材剪辑上随手挂动态属性——ToolBar/NavigationBar/
 * ToolBoxBar 的 `clip.tipText = ...`、FarmLandController 的 `dogTip.effect =
 * Move`——AS3 对象任意加字段。翻译后素材剪辑是编译类实例（swf.exporters.
 * animate.*）：html5/JS 上 Dynamic 裸写还能落自有字段，静态目标（android/
 * cpp）上对不存在的字段写入报 "Invalid field"（真机 logcat 实证：3 次
 * `Invalid field:tipText` 后进程死亡），写入被丢弃后读取拿回 null 再崩。
 *
 * 这里用侧表（对象 → {字段名: 值}）在**所有目标**上给出同一语义：读写都走
 * 这一条通道，html5 冒烟测的就是真机跑的同一条代码路径。键是对象引用
 * （同对象多次挂值、不同对象互不串）。注意：侧表持强引用，预览期可接受；
 * 将来若有高频换素材的场景再考虑弱引用。
 */
class ClipProps {
	static var table:Map<{}, Map<String, Dynamic>> = new Map();

	/** 挂值（同键覆写）。等价 AS3 的 `clip.name = value` 动态属性写。 */
	public static function set(clip:Dynamic, name:String, value:Dynamic):Void {
		var fields:Map<String, Dynamic> = table.get(clip);
		if (fields == null) {
			fields = new Map();
			table.set(clip, fields);
		}
		fields.set(name, value);
	}

	/** 取值；没挂过返回 null（等价 AS3 点取不存在的动态属性）。 */
	public static function get(clip:Dynamic, name:String):Dynamic {
		var fields:Map<String, Dynamic> = table.get(clip);
		return fields == null ? null : fields.get(name);
	}

	/** 挂过且键存在（等价 `clip["name"] != undefined` 的存在性判断）。 */
	public static function has(clip:Dynamic, name:String):Bool {
		var fields:Map<String, Dynamic> = table.get(clip);
		return fields != null && fields.exists(name);
	}

	/** 删键（等价 AS3 的 `delete clip["name"]`；没挂过也是无操作）。
	 *  issue #20 FriendItemRender.updateStatusFlag 起手删 status_mc["s_name"]。 */
	public static function remove(clip:Dynamic, name:String):Void {
		var fields:Map<String, Dynamic> = table.get(clip);
		if (fields != null) {
			fields.remove(name);
		}
	}
}

package shim;

/**
 * AS3 → Haxe 直译中反复出现的语义差异助手（语言差异胶水，非新架构）：
 *
 * - truthy/or：AS3 的 Boolean(x) 与 a || b 作用在 Dynamic 上的真值规则
 *   （false/null/undefined/NaN/0/"" 为假；"0"、[]、{} 为真）。
 * - replaceFirst：AS3 的 String.replace(字符串模式, 替换串) 只替换第一处，
 *   Haxe 的 StringTools.replace 是全局替换，不能直用。
 */
class As3 {
	public static function truthy(v:Dynamic):Bool {
		if (v == null) {
			return false;
		}
		if (Std.isOfType(v, Bool)) {
			return v;
		}
		if (Std.isOfType(v, Int)) {
			return v != 0;
		}
		if (Std.isOfType(v, Float)) {
			return v == v && v != 0; // NaN 为假（AS3 Boolean(NaN) == false）
		}
		if (Std.isOfType(v, String)) {
			return v != "";
		}
		return true;
	}

	/** AS3 的 `a || b`（动态真值短路取值）。 */
	public static function or(a:Dynamic, b:Dynamic):Dynamic {
		return truthy(a) ? a : b;
	}

	/**
	 * AS3 的 `x == "字面量"`（String 常量一侧）：另一侧是 Number 时按
	 * Number(字符串) 比较（"1"==1 为真），是 String 时直比。
	 * Haxe 对 Dynamic == String 走严格比较，1 == "1" 为假，不等价。
	 */
	public static function eqString(a:Dynamic, s:String):Bool {
		if (a == null) {
			return false;
		}
		if (Std.isOfType(a, String)) {
			return a == s;
		}
		return floatOf(a) == floatOf(s);
	}

	/** AS3 的 String.replace(搜索串, 替换串)：只替换第一处。 */
	public static function replaceFirst(s:String, search:String, replacement:String):String {
		var i = s.indexOf(search);
		if (i == -1) {
			return s;
		}
		return s.substr(0, i) + replacement + s.substr(i + search.length);
	}

	/**
	 * AS3 的 int 减法 `a - b`（a/b 为 int 形参或属性时）：操作数按 Number 参与
	 * 运算——未设值的字段是 undefined，Number 减法得 NaN，赋回 int 得 0。
	 * Haxe 在 eval 目标上对 null 操作数直接抛 "Invalid operation"，js 又把
	 * null 当 0（两边都和 AS3 不同），这里显式复刻 AS3 语义。
	 */
	public static function intSub(a:Dynamic, b:Dynamic):Int {
		var fa:Float = toNumber(a);
		var fb:Float = toNumber(b);
		var r = fa - fb;
		if (Math.isNaN(r)) {
			return 0;
		}
		return Std.int(r);
	}

	/**
	 * AS3 的 int(x) 强制转换：Number 截断、数字字符串解析、undefined/null → 0。
	 * Haxe 的 Std.int 只收 Float（传 String 在 eval 上抛错），Std.parseFloat 对
	 * 非数字返回 null，都不等价。
	 */
	public static function intOf(v:Dynamic):Int {
		var f:Float = toNumber(v);
		if (Math.isNaN(f)) {
			return 0;
		}
		return Std.int(f);
	}

	/**
	 * AS3 的 parseFloat(x)（参数先隐式转 String 再解析前缀）。
	 */
	public static function floatOf(v:Dynamic):Float {
		return toNumber(v);
	}

	/**
	 * flash.utils.setTimeout/clearTimeout（Haxe 没有返回可清除句柄的内建物，
	 * 用 Map<UInt, Timer> 复刻 uint 句柄语义）。
	 */
	private static var timeoutTimers:Map<UInt, haxe.Timer> = new Map();
	private static var timeoutNextId:UInt = 1;

	public static function setTimeout(f:Void->Void, ms:Int):UInt {
		var id:UInt = timeoutNextId++;
		var timer:haxe.Timer = new haxe.Timer(ms);
		timer.run = function():Void {
			timer.stop();
			timeoutTimers.remove(id);
			f();
		};
		timeoutTimers.set(id, timer);
		return id;
	}

	public static function clearTimeout(id:UInt):Void {
		var timer:haxe.Timer = timeoutTimers.get(id);
		if (timer != null) {
			timer.stop();
			timeoutTimers.remove(id);
		}
	}

	static function toNumber(v:Dynamic):Float {
		if (v == null) {
			return Math.NaN;
		}
		if (Std.isOfType(v, Bool)) {
			return v ? 1 : 0;
		}
		if (Std.isOfType(v, Int) || Std.isOfType(v, Float)) {
			return v;
		}
		var f:Null<Float> = Std.parseFloat(Std.string(v));
		return f == null || Math.isNaN(f) ? Math.NaN : f;
	}
}

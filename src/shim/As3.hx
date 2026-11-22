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
	 * AS3 密封类实例的 hasOwnProperty（含 trait：方法与 get/set 属性）。
	 * Haxe 的 Reflect.hasField 只看实例自有字段，原型上的方法
	 * （TitleWindow.keyEnter）和存取器属性（UIComponent.toolTip）都查不到，
	 * js/eval 上会漏——Reflect.field 沿原型链且走属性 getter，兜底补全。
	 * 值为 null 的真字段两侧都判真（AS3 hasOwnProperty 不看值）。
	 */
	public static function hasProp(o:Dynamic, name:String):Bool {
		if (o == null) {
			return false;
		}
		if (Reflect.hasField(o, name)) {
			return true;
		}
		return Reflect.field(o, name) != null;
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
	 * AS3 的 `mc["子件名"]`：swf 符号类是 dynamic class，属性访问先查真实
	 * 字段/先前动态写入，查不到再落到**时间轴具名子实例**（hasOwnProperty
	 * ("step1") 为真的那种，MovieClip 的显示列表查找）。openfl 动画运行时
	 * 里子实例不是实例字段——Reflect.field 恒 null（#8 Crop 的 step1 先例），
	 * 这里先 Reflect.field 再 DisplayObjectContainer.getChildByName 补全同源
	 * 语义。返回 Dynamic：具名子件多数再被当 MovieClip/TextField 用。
	 */
	public static function childOf(target:Dynamic, name:String):Dynamic {
		var v:Dynamic = Reflect.field(target, name);
		if (v != null) {
			return v;
		}
		if (Std.isOfType(target, openfl.display.DisplayObjectContainer)) {
			return cast(target, openfl.display.DisplayObjectContainer).getChildByName(name);
		}
		return null;
	}

	/**
	 * AS3 数组按字符串键取值 `arr[key]`：键是正则无符号整数字串（无前导
	 * 零、≤ 2^32-2）就按下标访问（越界 undefined→null）；其余字串走动态
	 * 属性——数组上没人挂过这类属性，等价 undefined→null。TileList.as:134
	 * 的 `_data[_loc2_ + _loc3_ * maxGrop]` 依赖此语义：for-in 键是 String，
	 * String + Number 在 AS3 是拼接（"1"+12→"112"），"00"/"012" 这类非正则
	 * 串落 undefined、"112" 这类正则串落（多半错位的）元素。
	 */
	public static function arrayIndex(arr:Array<Dynamic>, key:String):Dynamic {
		if (arr == null) {
			return null;
		}
		var len:Int = key.length;
		if (len == 0 || len > 10) {
			return null;
		}
		for (i in 0...len) {
			var c:Int = StringTools.fastCodeAt(key, i);
			if (c < "0".code || c > "9".code) {
				return null;
			}
		}
		if (len > 1 && StringTools.fastCodeAt(key, 0) == "0".code) {
			return null;
		}
		var value:Float = Std.parseFloat(key);
		if (value > 4294967294.0) {
			return null;
		}
		if (value >= arr.length) {
			return null;
		}
		return arr[Std.int(value)];
	}

	/**
	 * AS3 的数组下标读（越界语义）：越界读得 undefined→null。js 越界读返回
	 * undefined（恰好同 AS3），eval/cpp 行为未定义（cpp 直接崩）——静态目标
	 * 规则要求判下标范围。ShopModel.onGetDecorsInfo 的四元块换位在非 4 倍数
	 * 长度时读 _loc4_+1..+3 越界（原版缺陷照留），依赖此语义。
	 */
	public static function arrAt(arr:Array<Dynamic>, i:Int):Dynamic {
		if (i < 0 || i >= arr.length) {
			return null;
		}
		return arr[i];
	}

	/**
	 * AS3 的数组下标写（越界语义）：写越界把 length 垫到下标+1、中间补
	 * undefined→null 槽。与 arrAt 配对（同上出处）。
	 */
	public static function arrPut(arr:Array<Dynamic>, i:Int, v:Dynamic):Void {
		while (arr.length <= i) {
			arr.push(null);
		}
		arr[i] = v;
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
	 * AS3 把 Number 赋进 int 变量的 ToInt32 强制（ECMA-262：先截断取整、
	 * 再按 2^32 回绕到带符号区间）。Haxe 的 Int 在 js/eval 上是双精度数
	 * **不回绕**（cpp 才隐式截断），裸 `Std.int` 会让两族 compareDate 把
	 * 2^31ms（≈24.9 天）以上的 |Δms| 当正数——原版是回绕后再除，约
	 * 49.7-52.6 天的流水回绕成 0/1/2 天、被错标成今天/昨天/前天（24.9-49.7
	 * 天回绕成负数、仍走真实日期支）。原版 bug，照抄（ProfileLog/
	 * ProfileCost/ProfileSystemMsg 两族共六处 int 形）。
	 */
	public static function int32(v:Float):Int {
		if (Math.isNaN(v) || Math.isFinite(v) == false) {
			return 0;
		}
		// 向零截断（ToInt32 第一步）。不用 Math.floor/ceil：eval 目标的
		// floor/ceil 内部走 Int32 换算，≥2^31 的输入先坏（js/cpp 的 floor
		// 无此问题，但 % 在所有目标都是 fmod 语义）
		var t:Float = v - v % 1.0;
		var m:Float = t % 4294967296.0;
		if (m >= 2147483648.0) {
			m -= 4294967296.0;
		} else if (m < -2147483648.0) {
			m += 4294967296.0;
		}
		return Std.int(m);
	}

	/**
	 * AS3 `obj["k"]` 的取值落进 String 属性（TextField.text 等）时的强制：
	 * 键缺位是 undefined → "undefined"、显式 null → "null"、其余 String(v)。
	 * Haxe 里缺位和 null 都落 null，用 hasField 区分。原始值（""/数字/
	 * 布尔）的包装类上没有自定义键、一律 undefined（AS3 同——HistoryTip.as
	 * :77-83 的 null 数据路径把 "undefined" 印进 TextField 而不是抛错）。
	 */
	public static function stringField(o:Dynamic, name:String):String {
		if (o == null) {
			return "undefined";
		}
		if (Std.isOfType(o, String) || Std.isOfType(o, Int) || Std.isOfType(o, Float) || Std.isOfType(o, Bool)) {
			return "undefined";
		}
		if (Reflect.hasField(o, name)) {
			var v:Dynamic = Reflect.field(o, name);
			return v == null ? "null" : Std.string(v);
		}
		return "undefined";
	}

	/**
	 * AS3 的 parseFloat(x)（参数先隐式转 String 再解析前缀）。
	 */
	public static function floatOf(v:Dynamic):Float {
		return toNumber(v);
	}

	/**
	 * AS3 的 parseInt(x)（参数先隐式转 String 再解析前缀整数段，无数字得
	 * NaN，"0x" 前缀按 16 进制）。与 floatOf 的差别在截断：parseFloat("0.5")
	 * =0.5、parseInt("0.5")=0（NPCModel.as:46 的 hours 判饿靠它）。
	 */
	public static function parseInt(v:Dynamic):Float {
		var s:String = Std.string(v);
		var i:Int = 0;
		while (i < s.length) {
			var c:Int = StringTools.fastCodeAt(s, i);
			if (c == " ".code || c == "\t".code || c == "\n".code || c == "\r".code || c == "\x0C".code) {
				i++;
			} else {
				break;
			}
		}
		var sign:Float = 1;
		if (i < s.length && (StringTools.fastCodeAt(s, i) == "+".code || StringTools.fastCodeAt(s, i) == "-".code)) {
			if (StringTools.fastCodeAt(s, i) == "-".code) {
				sign = -1;
			}
			i++;
		}
		var radix:Int = 10;
		if (i + 1 < s.length && StringTools.fastCodeAt(s, i) == "0".code
			&& (StringTools.fastCodeAt(s, i + 1) == "x".code || StringTools.fastCodeAt(s, i + 1) == "X".code)) {
			radix = 16;
			i += 2;
		}
		var value:Float = 0;
		var digits:Int = 0;
		while (i < s.length) {
			var d:Int = digitValue(StringTools.fastCodeAt(s, i), radix);
			if (d < 0) {
				break;
			}
			value = value * radix + d;
			digits++;
			i++;
		}
		if (digits == 0) {
			return Math.NaN;
		}
		return sign * value;
	}

	// parseInt 的单数位（10/16 进制共用；非数位或 ≥radix 得 -1）
	private static function digitValue(c:Int, radix:Int):Int {
		var d:Int = -1;
		if (c >= "0".code && c <= "9".code) {
			d = c - "0".code;
		} else if (c >= "a".code && c <= "f".code) {
			d = c - "a".code + 10;
		} else if (c >= "A".code && c <= "F".code) {
			d = c - "A".code + 10;
		}
		return d < radix ? d : -1;
	}

	/**
	 * AS3 的 Array.sortOn(字段, Array.DESCENDING)（MessageModel.as:123、
	 * mc ProfileCost.as:188）。AVM2 不带 Array.NUMERIC 选项时按字段值的
	 * **字符串序**比较，DESCENDING 反转比较器；原地排序。真实数据源的 time
	 * 是等宽 10 位时间戳（cgi_farm_exchange.php:26,28），字符串序与数值序一致。
	 */
	public static function sortOnDesc(arr:Array<Dynamic>, field:String):Void {
		arr.sort(function(a:Dynamic, b:Dynamic):Int {
			var va:String = Std.string(Reflect.field(a, field));
			var vb:String = Std.string(Reflect.field(b, field));
			if (va < vb) {
				return 1;
			}
			if (va > vb) {
				return -1;
			}
			return 0;
		});
	}

	/**
	 * AS3 全局 unescape（ProfileMsg.as genMsg 的留言正文解转义）：逐个解
	 * %XX 与 %uXXXX，非法/截断的 % 序列原样保留。与 Haxe
	 * StringTools.urlDecode 的差别在后者把 "+" 换成空格（AS3 不换，
	 * `urlDecode("a+b")=="a b"` 而 `unescape("a+b")=="a+b"`，已 eval 实测）。
	 */
	public static function unescape(s:String):String {
		if (s == null) {
			return "null";
		}
		var buf:StringBuf = new StringBuf();
		var i:Int = 0;
		var len:Int = s.length;
		while (i < len) {
			var c:Int = StringTools.fastCodeAt(s, i);
			if (c != "%".code) {
				buf.addChar(c);
				i++;
				continue;
			}
			// %uXXXX
			if (i + 6 <= len && StringTools.fastCodeAt(s, i + 1) == "u".code) {
				var u:Int = hex4(s, i + 2);
				if (u >= 0) {
					buf.addChar(u);
					i += 6;
					continue;
				}
			}
			// %XX
			if (i + 3 <= len) {
				var h:Int = hexVal(StringTools.fastCodeAt(s, i + 1));
				var l:Int = hexVal(StringTools.fastCodeAt(s, i + 2));
				if (h >= 0 && l >= 0) {
					buf.addChar(h * 16 + l);
					i += 3;
					continue;
				}
			}
			buf.addChar(c);
			i++;
		}
		return buf.toString();
	}

	private static function hexVal(c:Int):Int {
		if (c >= "0".code && c <= "9".code) {
			return c - "0".code;
		}
		if (c >= "a".code && c <= "f".code) {
			return c - "a".code + 10;
		}
		if (c >= "A".code && c <= "F".code) {
			return c - "A".code + 10;
		}
		return -1;
	}

	private static function hex4(s:String, at:Int):Int {
		var v:Int = 0;
		for (j in 0...4) {
			var d:Int = hexVal(StringTools.fastCodeAt(s, at + j));
			if (d < 0) {
				return -1;
			}
			v = v * 16 + d;
		}
		return v;
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

	/**
	 * flash.utils.getTimer：播放器启动以来的毫秒数（恒非负）。
	 * openfl.Lib.getTimer 在 eval 目标上是纪元毫秒溢出 Int32 的负值，AS3 里
	 * set 用 int(x/1000)、get 用 Math.floor(x/1000)（CommonData.serverTime
	 * 漂移公式），负数让两者分歧 1 秒——flash 播放器上 getTimer 恒非负、两者
	 * 恒一致。以首次调用为基线复刻「自启动毫秒」；js 上 Timer.stamp 与
	 * openfl 的 performance.now 同基，数值不变。
	 */
	private static var timerBase:Float = Math.NaN;

	public static function getTimer():Int {
		if (Math.isNaN(timerBase)) {
			timerBase = haxe.Timer.stamp();
		}
		return Std.int((haxe.Timer.stamp() - timerBase) * 1000);
	}

	/**
	 * AS3 `new Date(字符串)` 的日期串解析。Haxe Date.fromString 只认 ISO
	 * "Y-M-D H:M:S"，而原版配置里走这一支的是美式串（xml/mod/nc_addon.php:113
	 * `<jinPaiLand>7/10/2012-11/12/2012 23:59:59</jinPaiLand>`，FarmLand.as:233
	 * `new Date(_loc3_[0])`），只复刻配置用到的 m/d/Y[ H:M[:S]] 形态。解析失败
	 * 返回 null：原版是 time=NaN 的 Invalid Date，getTime 比较恒 false，等价于
	 * 跳过窗口判断——但调用点必须先判 null 再比较（FarmLand.get__goldLand、
	 * NPCView 构造器两处都是如此），裸读 null.getTime() 会抛。
	 */
	public static function dateOf(s:String):Date {
		if (s == null) {
			return null;
		}
		var dateParts:Array<String> = s.split(" ");
		var d:Array<String> = dateParts[0].split("/");
		if (d.length < 3) {
			return null;
		}
		var year:Int = As3.intOf(d[2]);
		var month:Int = As3.intOf(d[0]);
		var day:Int = As3.intOf(d[1]);
		var h:Int = 0;
		var m:Int = 0;
		var sec:Int = 0;
		if (dateParts.length > 1) {
			var t:Array<String> = dateParts[1].split(":");
			h = As3.intOf(t[0]);
			if (t.length > 1) {
				m = As3.intOf(t[1]);
			}
			if (t.length > 2) {
				sec = As3.intOf(t[2]);
			}
		}
		if (year <= 0 || month <= 0 || day <= 0) {
			return null;
		}
		return new Date(year, month - 1, day, h, m, sec);
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

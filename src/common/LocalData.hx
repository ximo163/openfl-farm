package common;

import openfl.display.Sprite;

/**
 * common.LocalData —— LocalData.as（mcloader_v_53/scripts，预加载器与
 * Master2 同应用域共享，Master2 反编译里无此文件）的签名面 stub（原类
 * 255 loc，mcloader 片真身待译——后续模块；issue #19 只保 profile 窗族
 * 读到的 isMe/mode/rollCollection 三个静态位，issue #87 补 mc.FBridge
 * 网栈与 GetCropID 读到的 parameters/xymode/lastRequest 四件/appImgPrefix
 * 通道位）。行号对应 mcloader 反编译。纯静态字段本身无逻辑可 throw。
 * setObject/getObject/flush 的 SharedObject 读写**已由 issue #87 充真身**
 * ——RequestManagerTest 的多调用闭包序列（一个 tolerate 包装里两次
 * addUin/addAction）要求 setObject 不掷错：空掷 stub 的异常会吞掉同闭包
 * 内的第二次调用、errNum 永远到不了 errTotal，熔断测试恒假。openfl eval
 * 的 SharedObject 实测可写可读，三方法按 mcloader 原文逐句翻译
 * （hasObject/clearObject 仍留 mcloader 片，本类未立）。
 */
@:keep
class LocalData {
	// LocalData.as:15
	private static var _parameters:Dynamic;

	// LocalData.as:27/29/45/55（FRequest 的 lastRequest 四件，
	// FRequest.as:56-59/:139-142）
	public static var lastRequestHandle:Dynamic;
	public static var lastRequestUrl:String;
	public static var lastRequestFn:Dynamic;
	public static var lastRequestValue:Dynamic;

	// LocalData.as:57
	public static var isMe:Bool;

	// LocalData.as:67
	public static var rollCollection:Sprite;

	// LocalData.as:85
	public static var mode:String = "";

	// LocalData.as:95
	public static var xymode:String = "";

	// LocalData.as:121-127/141-143（parameters 读写——读方向在 mode==qzone
	// 或 xymode=="" 时有加工（LocalData.as:129），stub 直通存取，加工逻辑
	// 随 mcloader 片充真身）
	public static var parameters(get, set):Dynamic;

	private static function get_parameters():Dynamic {
		return _parameters;
	}

	private static function set_parameters(param1:Dynamic):Dynamic {
		_parameters = param1;
		return param1;
	}

	// LocalData.as:100-110（ctor：instance 未建时记 localDataName——原文
	// 签名带 param1，stub 期零参；issue #87 为 setObject 充真身需要
	// localDataName，恢复原文双件。PORT-NOTE：单例守卫在「instance 已建」
	// 时抛——原文 `if(instance == null) { … return; } throw` 形态照抄）
	private var localDataName:String;

	public function new(param1:String = "FarmWorld") {
		if (LocalData.instance == null) {
			this.localDataName = param1;
			return;
		}
		throw new openfl.errors.Error("实例化单例类出错-LocalData");
	}

	public static var instance:LocalData;

	// LocalData.as:112-118
	public static function getInstance(param1:String = "FarmWorld"):LocalData {
		if (instance == null) {
			instance = new LocalData(param1);
		}
		return instance;
	}

	// LocalData.as:146-168（issue #87 充真身——RequestManager 的熔断持久化
	// 通道：测试的多调用闭包序列要求 setObject 不掷错才能完整执行，空掷
	// stub 会让首个 setObject 的异常吞掉同闭包后续调用。PORT-NOTE：
	// `new Date(2038,12,31)` 月份 12 溢出进位 2039 年 1 月——AS3/Haxe
	// Date ctor 同规格化语义，照抄；`.time` → getTime() 毫秒。
	// `so.data[param1]` 动态键读写 → Reflect 通道；param4 false 时
	// `return param4` 即返 false——原文如此（写入已生效、仅 flush 门控））
	public function setObject(param1:String, param2:Dynamic, param3:Float = 0, param4:Bool = false):Bool {
		var _loc6_:Bool = false;
		var _loc5_:openfl.net.SharedObject = openfl.net.SharedObject.getLocal(this.localDataName);
		if (param3 == 0) {
			param3 = new Date(2038, 12, 31, 0, 0, 0).getTime();
		}
		Reflect.setField(_loc5_.data, param1, {
			"value": param2,
			"time": param3
		});
		if (param4) {
			_loc6_ = this.flush(_loc5_);
			if (_loc6_ == false) {
				Reflect.deleteField(_loc5_.data, param1);
			}
			return _loc6_;
		}
		return param4;
	}

	// LocalData.as:170-192（flush：try 内返 true、catch 落穿返 false——
	// PENDING/FLUSHED 两分支只 trace，原文如此）
	private function flush(param1:openfl.net.SharedObject):Bool {
		var flushResult:String = null;
		var so:openfl.net.SharedObject = param1;
		try {
			flushResult = so.flush();
			if (flushResult == openfl.net.SharedObjectFlushStatus.PENDING) {
				trace("PENDING -- 数据超出限制");
			} else if (flushResult == openfl.net.SharedObjectFlushStatus.FLUSHED) {
				trace("FlUSHED -- 成功写入");
			}
			return true;
		} catch (e:Dynamic) {
			trace("ERROR -- 写入失败");
		}
		return false;
	}

	// LocalData.as:194-216（time==0 → 当前毫秒；存储 time 是过期界——
	// dif = 存储 time - time >= 0 未过期才取值；无 time 键的老数据直通。
	// 整个方法体在 try/catch 内——原文如此）
	public function getObject(param1:String, param2:Float = 0):Dynamic {
		var returnValue:Dynamic = null;
		var so:openfl.net.SharedObject = null;
		var dif:Float = Math.NaN;
		var name:String = param1;
		var time:Float = param2;
		try {
			so = openfl.net.SharedObject.getLocal(this.localDataName);
			if (time == 0) {
				time = Date.now().getTime();
			}
			var _entry:Dynamic = Reflect.field(so.data, name);
			if (shim.As3.truthy(_entry)) {
				if (shim.As3.hasProp(_entry, "time")) {
					dif = shim.As3.floatOf(Reflect.field(_entry, "time")) - time;
					if (dif >= 0) {
						returnValue = Reflect.field(_entry, "value");
					}
				} else {
					returnValue = _entry;
				}
			}
		} catch (e:Dynamic) {
			trace(e);
		}
		return returnValue;
	}
}

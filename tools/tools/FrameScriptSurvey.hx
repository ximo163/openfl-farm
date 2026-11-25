package tools;

// issue #58 帧脚本清查器（write-tests 阶段的 stub，函数体 not implemented；
// 契约由 test/tools/FrameScriptSurveyTest.hx 钉死，implement 原地填充）。
// 职责：素材 swf 的 DoABC2 → 各符号类的 addFrameScript 登记表（帧号/方法名）
// + frameN 方法体空体判定，产出补偿登记表（shim.FrameScriptCompensation）
// 的逐条出处数据。本模块只做纯逻辑：入口收 FrameScriptOp 流（format.abc
// OpCode 的显式镜像），不 import format——真工具的 swf → FrameScriptOp 解码
// 按 tools/DumpAbcMethod.hx 先例（format.abc.Reader + OpReader，一次性工具
// 依赖 format 3.7.0，不进 test.hxml 的 -lib 集）由 implement 接上，解码器
// 本身不在单测覆盖范围（与 T3 TimelineSpec 的「swf→ClipSpec 提取走数据侧、
// 纯逻辑走单测」同分工）。

/** ABC 操作码镜像：本仓 69 个素材 swf 的帧脚本构造器/方法体里实际出现的
 *  形态 + 调试 op + 未映射兜底。名字取 format.abc.Data.OpCode 的同形
 *  名（OThis/OScope/OFindPropStrict…），参数只留清查需要的常量值；
 *  OInt 折叠 OSmallInt/OIntRef/OUIntRef 等全部压帧常量形态（值同，
 *  帧号/实参个数是清查唯一关心的量）。 */
enum FrameScriptOp {
	OThis;
	OScope;
	OPop;
	ORetVoid;
	OInt(v:Int);
	OStr(v:String);
	OFindProp(n:String);
	OFindPropStrict(n:String);
	OGetProp(n:String);
	OGetLex(n:String);
	OSetProp(n:String);
	OInitProp(n:String);
	OCallProp(n:String, argc:Int);
	OCallPropVoid(n:String, argc:Int);
	OConstructProp(n:String, argc:Int);
	OConstructSuper(argc:Int);
	/** 调试信息（ODebug/ODebugFile/ODebugReg 家族）：与行为无关。 */
	ODebug(name:String);
	/** 未映射的 OpCode：一律按实义处理，清查器不猜。 */
	OOther(name:String);
}

/** 一条 addFrameScript 登记：method 是方法名（frameN 的 N 与 frame
 *  恒一致——mxmlc 生成约定，也是 haxelib swf 3.4.0 FrameScriptParser
 *  映射 frameN ↔ 帧 N 的规则）；frame 是 1 基帧号（= addFrameScript 的
 *  0 基实参 + 1）。 */
typedef FrameScriptBinding = {
	frame:Int,
	method:String
}

class FrameScriptSurvey {
	/** 符号类构造器的操作码流 → addFrameScript 登记表。mxmlc 家族把全部
	 *  (帧, 方法) 对合成单次 addFrameScript 调用（实参个数是 2 的倍数，
	 *  两个对就是 4 个实参），且不同期编译器取方法的形态不同
	 *  （OFindPropStrict+OGetProp / OGetLex / OThis+OGetProp——
	 *  test/tools/FrameScriptSurveyTest.hx 的四型 fixtures）。无
	 *  addFrameScript 调用的构造器返回 []。
	 *
	 *  实现：两态扫描。scan 态找 OFindPropStrict("addFrameScript")（mxmlc
	 *  家族对虚方法的被调方恒用 findpropstrict 取，四型 fixtures 同证），
	 *  命中转 collect 态；collect 态把实参段折叠成值序列——OInt 是 0 基帧
	 *  实参（登记时 +1 转 1 基），方法引用按三型折叠（OGetLex 直取 /
	 *  OFindPropStrict(m)+OGetProp(m) / OThis+OGetProp(m)，第二对前的
	 *  OThis 只置接收者期待、不产值）；OCallProp/OCallPropVoid 收口时按
	 *  (帧, 方法) 两两配对入表，回 scan 态（构造器分段多次调用的形态同样
	 *  可收，虽然 fixtures 里未出现）。段内其余 op（OThis/OScope 壳、
	 *  OPop 弃值）不产值也不打断扫描。 */
	public static function ctorBindings(ops:Array<FrameScriptOp>):Array<FrameScriptBinding> {
		var bindings:Array<FrameScriptBinding> = [];
		var collecting:Bool = false;
		// collect 态的值序列：奇偶交替——偶位 0 基帧号（Int）、奇位方法名（String）
		var values:Array<Dynamic> = [];
		// 方法引用的接收者期待：OFindPropStrict(m) 后等 OGetProp(m)；OThis 后
		// 的 OGetProp(m) 即 this.m。二者互斥出现，配对后一并清空
		var pendingName:String = null;
		var pendingThis:Bool = false;
		for (op in ops) {
			switch (op) {
				case OFindPropStrict(n):
					if (n == "addFrameScript") {
						collecting = true;
						values = [];
						pendingName = null;
						pendingThis = false;
					} else if (collecting) {
						pendingName = n;
					}
				case OInt(v) if (collecting):
					values.push(v);
				case OGetLex(n) if (collecting):
					values.push(n);
				case OThis:
					if (collecting) {
						pendingThis = true;
					}
				case OGetProp(n) if (collecting):
					if (pendingThis || (pendingName != null && pendingName == n)) {
						values.push(n);
					}
					pendingName = null;
					pendingThis = false;
				case OCallProp(n, _) | OCallPropVoid(n, _):
					if (collecting && n == "addFrameScript") {
						// (帧, 方法) 两两配对；尾巴凑不成对（烂字节码防御）丢弃
						var i:Int = 0;
						while (i + 1 < values.length) {
							var frame:Dynamic = values[i];
							var method:Dynamic = values[i + 1];
							if ((frame is Int) && (method is String)) {
								bindings.push({frame: frame + 1, method: method});
							}
							i += 2;
						}
						collecting = false;
						values = [];
					}
				default:
			}
		}
		return bindings;
	}

	/** frameN 方法体的操作码流 → 空体判定：剥去 OThis/OScope/ODebug 与
	 *  尾部 return 后无行为 op 即空体（含整流为空）。任何行为 op——包括
	 *  只置空串的 init prop——都算实义；OOther 也算实义（未映射不猜）。
	 *  空体 = 不进补偿登记表（src/FarmInfoPlus.hx:14-16 先例）。 */
	public static function isBodyEmpty(ops:Array<FrameScriptOp>):Bool {
		for (op in ops) {
			switch (op) {
				case OThis | OScope | ORetVoid | ODebug(_):
					// 壳与调试信息：无行为
				default:
					return false;
			}
		}
		return true;
	}
}

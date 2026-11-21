// 一次性 ABC 字节码核对工具（issue #20，用后可删）。
// 动机：FFDec 反编译的 FriendsModel.filterOut 闭包是
//   return m_friendListFilter.hasOwnProperty(param1._uin);
// （Array.filter 保留返回 true 的项 → 表内好友被「保留」），但 FriendsView 的
// 用法是表内好友仅 setGray、仍照常渲染——两种极性都说不通，怀疑 FFDec 丢了
// 取反。本工具直接读部署 swf 的 DoABC，按类/方法名打印字节码（含闭包），以
// 字节码为唯一依据。
// 实现阶段二次复用（attempt 2，2026-11-21）：retarget 到 goBackPage/goNextPage/
// onFriendsDataLoaded/processFriendList/friendSort，核对 approved 测试三处存疑
// 期望（FriendsModelTest :379/:845/:1149）是否 FFDec 忠实——分支结构、break、
// sort 就地重排。filterOut 一轮的结论不变，仍见 test 头注。
// 依赖 format 3.7.0（CLAUDE.md：只供 tools/ 下的一次性工具用，不进工程）。
// 用法（容器内，仓库根目录）：haxe -cp tools -lib format -main DumpAbcMethod --interp

import format.abc.Data;
import haxe.io.BytesInput;
import sys.io.File;

class DumpAbcMethod {
	// issue #20 implement 阶段：五方法核对（filterOut 一轮已毕，见头注）
	static var TARGET_CLASS = "FriendsModel";
	static var TARGET_METHODS = ["goBackPage", "goNextPage", "onFriendsDataLoaded", "processFriendList", "friendSort"];

	public static function main() {
		var bytes = File.getBytes("legacy/deploy/QFarmFlash/source/core/module/main3_v_221.swf");
		var swf = new format.swf.Reader(new BytesInput(bytes)).read();
		for (tag in swf.tags) {
			switch (tag) {
				case TActionScript3(data, _):
					var abc = new format.abc.Reader(new BytesInput(data)).read();
					dumpTargets(abc);
				default:
			}
		}
	}

	static function dumpTargets(abc:ABCData) {
		var bodies = new Map<Int, Function>();
		for (b in abc.functions) {
			bodies.set(b.type.asInt(), b);
		}
		for (c in abc.classes) {
			if (nameStr(abc, c.name).indexOf(TARGET_CLASS) < 0) {
				continue;
			}
			Sys.println("== class " + nameStr(abc, c.name));
			for (f in c.fields) {
				var mIdx = switch (f.kind) {
					case FMethod(m, _, _, _): m.asInt();
					default: -1;
				};
				if (mIdx < 0) {
					continue;
				}
				var fname = nameStr(abc, f.name);
				if (TARGET_METHODS.indexOf(fname) < 0) {
					continue;
				}
				var body = bodies.get(mIdx);
				if (body == null) {
					Sys.println("== " + fname + ": no body");
					continue;
				}
				var ops = decode(abc, body);
				dumpOps(abc, ops, fname);
				// AS3 闭包 → newfunction（OFunction），把引用到的闭包体一并打出来
				for (op in ops) {
					switch (op) {
						case OFunction(m):
							var closure = bodies.get(m.asInt());
							if (closure != null) {
								dumpOps(abc, decode(abc, closure), fname + " closure#" + m.asInt());
							}
						default:
					}
				}
			}
		}
	}

	static function decode(abc:ABCData, body:Function):Array<OpCode> {
		var out:Array<OpCode> = [];
		var inp = new BytesInput(body.code);
		var opr = new format.abc.OpReader(inp);
		while (inp.position < body.code.length) {
			var b = inp.readByte();
			out.push(opr.readOp(b));
		}
		return out;
	}

	static function dumpOps(abc:ABCData, ops:Array<OpCode>, label:String) {
		Sys.println("== " + label + " (" + ops.length + " ops)");
		for (op in ops) {
			Sys.println("   " + opStr(abc, op));
		}
	}

	static function nameStr(abc:ABCData, idx:Index<Name>):String {
		if (idx == null || idx.asInt() == 0) {
			return "?";
		}
		var n = abc.get(abc.names, idx);
		return switch (n) {
			case NName(s, _): abc.get(abc.strings, s);
			case NMulti(s, _): abc.get(abc.strings, s);
			case NParams(inner, _): nameStr(abc, inner);
			default: "?" + Std.string(n);
		}
	}

	static function opStr(abc:ABCData, op:OpCode):String {
		return switch (op) {
			case OString(v): 'OString("${abc.get(abc.strings, v)}")';
			case OIntRef(v): 'OIntRef(${abc.get(abc.ints, v)})';
			case OUIntRef(v): 'OUIntRef(${abc.get(abc.uints, v)})';
			case OFloat(v): 'OFloat(${abc.get(abc.floats, v)})';
			case ODxNs(v): 'ODxNs("${abc.get(abc.strings, v)}")';
			case ODebugReg(v, r, line): 'ODebugReg("${abc.get(abc.strings, v)}",r$r,line$line)';
			case ODebugFile(v): 'ODebugFile("${abc.get(abc.strings, v)}")';
			case OCallProperty(n, a): 'OCallProperty(${nameStr(abc, n)},$a)';
			case OCallPropLex(n, a): 'OCallPropLex(${nameStr(abc, n)},$a)';
			case OCallPropVoid(n, a): 'OCallPropVoid(${nameStr(abc, n)},$a)';
			case OCallSuper(n, a): 'OCallSuper(${nameStr(abc, n)},$a)';
			case OCallSuperVoid(n, a): 'OCallSuperVoid(${nameStr(abc, n)},$a)';
			case OConstructProperty(n, a): 'OConstructProperty(${nameStr(abc, n)},$a)';
			case OGetLex(n): 'OGetLex(${nameStr(abc, n)})';
			case OFindPropStrict(n): 'OFindPropStrict(${nameStr(abc, n)})';
			case OFindProp(n): 'OFindProp(${nameStr(abc, n)})';
			case OFindDefinition(n): 'OFindDefinition(${nameStr(abc, n)})';
			case OGetProp(n): 'OGetProp(${nameStr(abc, n)})';
			case OSetProp(n): 'OSetProp(${nameStr(abc, n)})';
			case OInitProp(n): 'OInitProp(${nameStr(abc, n)})';
			case ODeleteProp(n): 'ODeleteProp(${nameStr(abc, n)})';
			case OGetSuper(n): 'OGetSuper(${nameStr(abc, n)})';
			case OSetSuper(n): 'OSetSuper(${nameStr(abc, n)})';
			case OCast(n): 'OCast(${nameStr(abc, n)})';
			case OIsType(n): 'OIsType(${nameStr(abc, n)})';
			case OFunction(m): 'ONewFunction(methodType=${m.asInt()})';
			case OJump(j, d): 'OJump(${Std.string(j)},$d)';
			case OOp(o): 'OOp(${Std.string(o)})';
			default: Std.string(op);
		}
	}
}

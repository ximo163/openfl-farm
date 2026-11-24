package shim;

// PORT-NOTE: issue #58 帧脚本补偿登记表（write-tests 阶段的 stub，函数体
// not implemented；契约由 test/shim/FrameScriptCompensationTest.hx 钉死，
// implement 原地填充）。为什么需要这层胶水：原版素材 swf 的符号关联类在
// 构造器里 addFrameScript(帧0基, frameN) 登记帧脚本，播放头到达该帧时执行
// frameN 方法体（MaoPaoFlag 的 infoTxt.text = talkInfo; stop()、RedUp 主轴
// 的 dispatchEvent(new Event("end"))）。openfl 侧资产经 swf haxelib 转换后
// 这些脚本不生效：只有 SymbolClass 绑定的符号才带 scriptSource
// （FrameScriptParser 转的 JS），且只在 html5 目标 eval、在 Haxe 实例上跑
// 不动（动态属性缺失，异常被 Log 吞）；非 js 目标整体丢弃（swf 3.4.0
// AnimateLibraryExporter/AnimateTimeline，容器内 /usr/local/lib/haxelib/
// swf/3,4,0 实测）。结果即 issue 列的已知三例：气泡文本不出现、升级动画
// 不自报 "end"、收获动画收不了尾。
//
// 补偿方式遵守符号 shim 惯例（src/FarmInfoPlus.hx / handbook/architecture/
// assets.md）：不改被翻译类的原调用形态（LandTalkTag 照旧 gotoAndPlay +
// 写 talkInfo、FarmLandsView 照旧监听 "end"），接线点查本表后用 openfl
// MovieClip.addFrameScript 按原登记形态回挂（帧号是 0 基实参，与原版
// addFrameScript(23, frame24) 同形）。注意 openfl 9.5.2 的 addFrameScript
// 只在实例已挂 Timeline 时生效（否则静默丢弃）——接线必须在
// SymbolClass.afterAttach（符号绑定场景）或 LocalSwfLoader content
// （根时间轴场景）之后。
//
// 表内容逐条出自 legacy 字节码（DoABC2 构造器 + frameN 方法体，出处注释
// 在 test/shim/FrameScriptCompensationTest.hx）。空体脚本不登记——
// frame1 只有 return 的类（FarmInfoPlus 等）本来就无行为可补，
// src/FarmInfoPlus.hx:14-16 的「空体不译」先例同款。

/** 一条补偿登记：libraryId 是 libraries.xml 的库 id；symbolKey 是符号
 *  导出名，空串 = 主时间轴（T3 约定，tools/TimelineTypes）；frame 是
 *  1 基帧号（= 原版 addFrameScript 的 0 基实参 + 1，与 frameN 方法名的
 *  N 恒一致）；actions 是 frameN 方法体逐句还原的动作序列。 */
typedef FrameScriptEntry = {
	libraryId:String,
	symbolKey:String,
	frame:Int,
	actions:Array<FrameScriptAction>
}

/** 帧脚本动作原语。只列已知三例方法体里实际出现的形态；新形态出现时
 *  须先扩本枚举（带字节码出处）再登记，不得并入近似原语。 */
enum FrameScriptAction {
	/** 方法体里的 stop()：停在当前帧。 */
	Stop;
	/** dispatchEvent(new Event(name))：素材对外自报完成（RedUp "end"）。 */
	DispatchEvent(name:String);
	/** 具名子件 target 的 text 属性 ← 本实例同名属性 prop（MaoPaoFlag
	 *  frame24：infoTxt.text = talkInfo）。 */
	SetText(target:String, prop:String);
}

class FrameScriptCompensation {
	/** 查 (libraryId, symbolKey) 的全部补偿登记，按 frame 升序。未登记
	 *  的组合返回 []——含空体脚本的键（空体=无行为可补）与整个 swf 无
	 *  帧脚本的符号。 */
	public static function entriesFor(libraryId:String, symbolKey:String):Array<FrameScriptEntry> {
		// issue #58 write-tests stub
		throw new haxe.Exception("not implemented");
	}
}

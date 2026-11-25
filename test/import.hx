// issue #67：强制把 Issue67TriageNotes 拉进编译图。Haxe 只编译从 main
// 可达的类型，该考证结论类只经 Type.resolveClass("Issue67TriageNotes")
// 反射取用（test/SwfTriageBaselineTest.hx:85）——零编译期引用时类整体
// 不进产物，反射恒 null（与 src/shim/SymbolClass.hx:67 的 DCE 锚同病）。
// 测试文件本体 append-only 不可改（加 import 违反规则），解法用 Haxe 的
// import.hx 默认导入机制：classpath 根目录的本文件对每个编译单元生效
// （lesson #56 的 import.hx 先例同机制——那条教训是「遮蔽」滥用，本条
// 是正用：不遮蔽任何名字，仅把纯 const 字符串类拉进类型图）。
// 影响面核查：-cp test 只出现在 test.hxml（全仓 grep 核实），html5/cpp
// 生产编译不含 test/ classpath，本文件对产物零影响。
import Issue67TriageNotes;

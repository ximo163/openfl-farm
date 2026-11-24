package tools;

// issue #56（T3 时间轴行为对拍）：本目录的契约测试（TimelineSpecTest/
// TimelineDiffTest）用未限定名 TimelineSpec/TimelineDiff 调用实现；实现
// **不在** test/tools/TimelineSpec.hx / TimelineDiff.hx 里——那是 write-tests
// 阶段留的 stub（throw "not implemented"），而 test/** 对本阶段是
// append-only（既有文件不可改，attempt 1 原地填 stub 被规则驳回），stub 的
// 类路径 tools.TimelineSpec / tools.TimelineDiff 就此占死。
//
// 解法：实现换模块路径到 t3 包（test/t3/），靠本文件把包内所有模块的
// 未限定名默认解析过去——Haxe 名字解析 import（含 import.hx 默认 import）
// 优先于同包同名类型（容器 haxe 4.3.6 --interp 实测：同包 stub 存在时
// 解析到 import 的类）。stub 文件不再被任何链加载，保持原样只作文档。
//
// 加新文件到 test/tools/ 时无需理会本文件；改这行 import 会把两个契约
// 测试打回 stub（测试全红），handbook/architecture/timeline-gate.md 有布局。
import t3.TimelineSpec;
import t3.TimelineDiff;

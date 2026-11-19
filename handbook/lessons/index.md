# 踩坑记录

环境差异、工具行为、legacy 反直觉之处。格式：一句话教训 + 背景/怎么发现
+ 怎么防。新条目追加在末尾，标上日期和 issue。

## 2026-11 · #7（V3a）

- **自编 fixture 查不出脏数据**：自编 JSON 是干净的，真后端 80KB 配置里
  有裸控制字符——本地测试全绿、CI web-smoke 连红两轮。防：fixture 从
  `legacy/snapshot/` 真实载荷抽（裁剪可、改内容不可）；JSON 解析走
  `JSON.decode` 门面（`checks/json-facade-only.sh` 拦直连）。
- **eval 裸 cast ≠ AS3 as**：`cast` 在 eval 目标上不做运行时检查，`as`
  失配返回 null 的回退分支被吞掉（NetHelper.hx:75，review round 1 驳回）。
  防：`as` 语义译成 `Std.isOfType` 门 + 直取，标 `// PORT-NOTE:`。
- **web-smoke 红叉的排查顺序**：先看 pageerror 的 e.stack（html5 的 JS
  未压缩，栈帧就是 Haxe 类名），再看输出末尾的 `.php` 请求表（最后 30 条，
  404 = 库没声明），别先猜代码。

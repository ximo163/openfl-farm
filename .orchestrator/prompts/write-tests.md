只写这个任务的测试，不做实现。先读 CLAUDE.md。

- 要弄清被测逻辑在系统里的位置（归哪个子系统、谁调它、有哪些约定和坑），先看
  `handbook/index.md` 路由表指到的页面，不要靠翻代码猜。
- 需求来自原版：期望值从 `spec/`（模块清单在 `spec/modules/<模块>.json`）、
  `legacy/deploy/`（先看 `legacy/manifest.json` 找到 PHP 和配置在哪）、
  `legacy/decompiled/` 推出来，不要凭感觉猜。每个期望值上方用注释写明出处
  （文件和位置）。原版没有的东西（shim、工具）以 issue 的描述为需求，出处写
  `// issue #<编号>`。
- 只测**纯逻辑**（mod 请求参数的拼装、返回 JSON 的解析、数值公式、工具函数）。
  显示对象、网络、真实时间、随机数一律不进测试。测试不能 sleep。
- 只读需要的部分：先 `rg -n` 找名字，再读前后几十行。`legacy/decompiled/` 和
  `legacy/deploy/` 很大，整个文件读进来会很快耗光轮数。
- 测试放在 `test/`，包路径对应 `src/` 下的被测类。表驱动，测试名说明行为。
- **新测试文件必须同一个 commit 注册进 `test/TestMain.hx`** 的 Runner
  （`runner.addCase(...)`）——implement 阶段 `append_only` 挡着它补这个，
  漏了只能整轮回退重写（#8 踩过，review-impl round 2 驳回点）。
- 被测代码还不存在时，加最小的能编译的 stub：签名正确，函数体
  `throw new Error("not implemented")`。不要做任何实现。
- 新测试必须在实现之前失败；已有的测试必须照样通过。
- 只有 issue 改变了某个已有测试检查的行为时，才能改那个测试，并在上方注释
  `// changed for #<issue>: <原因>`。
- 大段 fixture 放 `test/fixtures/`。
- legacy 和 spec 里都推不出某个行为时，最后输出 `BLOCKED: <缺什么，在哪里遇到>`，
  不要自己设计。
- 最后的回答里列出新增的测试，以及改过的已有测试。

实现这个任务，让测试通过。先读 CLAUDE.md。

- 已通过审核的测试不能改，只能新增测试文件。测试本身错了（和 legacy 对不上），
  最后一行输出 `NEEDS-TESTS: <哪个测试错在哪里，legacy 的出处>`。
- **这是翻译任务**：依据是 `legacy/decompiled/**/scripts/` 里的 AS3 原文，逐类翻成
  `src/` 下的 Haxe。遵守 CLAUDE.md 的翻译规则：一类对一类、API 按映射表、语言差异
  按清单、不顺手优化、不引入新架构。翻不过去的地方标 `// PORT-NOTE:` 或 BLOCKED，
  不要静默改行为。
- 只翻译 issue（或 `spec/modules/<模块>.json`）范围内的类。范围内类用到的范围外
  类：加最小 stub（编译需要），并在回答里列为「后续模块依赖」。
- 实现的依据是原版行为，不是测试里的具体数字：不要针对测试输入写特判。
- 资产：需要新资产时把路径加进 `assets/legacy-assets.txt`，不手拷文件；需要改
  `Project.xml`（新增 `<library>` 等）时输出 `BLOCKED: Project.xml 需要新增 library
  <路径>`，不要自己改。
- 只读需要的部分：先 `rg -n` 找名字，再读附近的行。
- 验证命令只有：`haxelib run openfl build html5`、`haxe test.hxml`。不要尝试
  `openfl build android`（容器里没有 SDK/NDK），不要安装任何大型工具。
- 新增 haxelib 依赖一律 BLOCKED，不自己加。
- 最后的回答里概括：翻译了哪些类（原类 → 移植类）、stub 了哪些、PORT-NOTE 了哪些、
  以及发现的 legacy 里的矛盾或疑点。

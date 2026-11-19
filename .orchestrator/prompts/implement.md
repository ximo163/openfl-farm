实现这个任务，让测试通过。先读 CLAUDE.md，再按 `handbook/index.md` 路由表读
这次要动的子系统页面（职责、约定、前人踩的坑都在那里，不要靠翻反编译代码猜
系统结构）。

- 已通过审核的测试不能改，只能新增测试文件。测试本身错了（和 legacy 对不上），
  最后一行输出 `NEEDS-TESTS: <哪个测试错在哪里，legacy 的出处>`。
- **这是翻译任务**：依据是 `legacy/decompiled/**/scripts/` 里的 AS3 原文，逐类翻成
  `src/` 下的 Haxe。遵守 CLAUDE.md 的翻译规则：一类对一类、API 按映射表、语言差异
  按清单、不顺手优化、不引入新架构。翻不过去的地方标 `// PORT-NOTE:` 或 BLOCKED，
  不要静默改行为。
- **画面保真是硬需求**：坐标、缩放、颜色、alpha、滤镜参数、帧率、帧标签、文本样式
  逐字照抄原文；不重排界面、不为手机「优化」布局（适配只进 `src/shim/`）。CI 有
  逐资产渲染比对，视觉跑偏的 PR 过不了。
- 只翻译 issue（或 `spec/modules/<模块>.json`）范围内的类。范围内类用到的范围外
  类：加最小 stub（编译需要），并在回答里列为「后续模块依赖」。
- 实现的依据是原版行为，不是测试里的具体数字：不要针对测试输入写特判。
- 资产：需要新资产时把路径加进 `assets/legacy-assets.txt`，不手拷文件；需要新资产库时
  在根目录 `libraries.xml` 加一行 `<library>`（两个文件同 commit 改）。`Project.xml`
  本体不改，其他构建配置（`*.hxml`、haxelib 依赖）需要动时 BLOCKED。
- 只读需要的部分：先 `rg -n` 找名字，再读附近的行。
- 验证命令只有：`haxelib run openfl build html5`、`haxe test.hxml`。不要尝试
  `openfl build android`（容器里没有 SDK/NDK），不要安装任何大型工具。
- 新增 haxelib 依赖一律 BLOCKED，不自己加。
- **handbook 边实现边补**：翻译了新子系统、或本次改动让某子系统的结构/约定
  变了，同一个改动里建好/更新 `handbook/` 对应页面和 `handbook/index.md`
  路由表行；值得记住的坑（环境差异、工具行为、legacy 反直觉处）按
  `handbook/lessons/index.md` 的格式追加。页面写「为什么」和「在哪」，
  不复述代码。
- 最后的回答里概括：翻译了哪些类（原类 → 移植类）、stub 了哪些、PORT-NOTE 了哪些、
  以及发现的 legacy 里的矛盾或疑点。

做这个脚手架、配置或探路类的改动。先读 CLAUDE.md。

- 只做 issue 要求的事；不翻译游戏逻辑，那属于默认流水线（先写测试）。
- 不改 legacy/、spec/、checks/、scripts/、harness/、Project.xml、*.hxml，不写给人
  看的文档。
- 资产：把要引用的路径加进 `assets/legacy-assets.txt`（`assets/legacy/` 由脚本
  同步生成，不手拷），需要新资产库时在根目录 `libraries.xml` 加一行 `<library>`
  （两个文件同 commit 改）。`Project.xml` 本体（窗口、依赖、include 结构）不改。
- 容器里没有 SDK/NDK/浏览器/Docker/Java：不要尝试安装或使用它们，需要这些的验证
  在 GitHub CI 上。本地验证只有 `haxelib run openfl build html5`、
  `haxe test.hxml`、`bash checks/*.sh`。
- 探路类任务（如 V1 资产通道）：结论写进 PR 说明——可行/不可行、现象（空白、形状
  错、帧不动）、影响范围。
- 最后的回答里概括改了什么，以及人需要做的后续步骤（如果有）。

这个仓库是把 Flash 农场游戏（phpYe.QFarm 7.0）的客户端**翻译**成 OpenFL/Haxe。
拆分时遵守：

- 依赖顺序：规格（`pipeline:spec`，从 legacy 提取到 spec/）→ 翻译实现。后面的
  子 issue 用「依赖 #N」写明依赖前面的。
- 每个子 issue 写明：对应 `legacy/decompiled/` 里哪些类（或 `spec/modules/`
  哪个模块）、用到的资产、调用的 mod、怎么算做完。位置先看 `legacy/manifest.json`。
- 标签：从 legacy 提取规格的用 `pipeline:spec`；脚手架、依赖、探路的用
  `pipeline:chore`；能先写失败测试的翻译不打 pipeline 标签（走默认流水线）。
- 按游戏系统拆（加载链路、农场基础、背包、商店、牧场、好友、狗、活动……），
  不要按文件个数机械拆。一个子 issue 的翻译量控制在几十个类以内。已翻译的
  子系统边界先看 `handbook/index.md` 路由表（哪个子系统有什么、什么还没翻），
  别把已翻的和没翻的拆混。
- 整个项目无人值守，不要安排需要人动手的步骤。重操作（反编译、旧后端、浏览器、
  APK）都在 GitHub CI 上，不进子 issue。
- 需要改 `harness/`、`.github/`、`scripts/`、`checks/`、`Project.xml`、`.orchestrator/`
  的工作 agent 做不了（受保护）：不拆进计划，在最后单独列出来说明需要什么。

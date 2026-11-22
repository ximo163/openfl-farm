# openfl-farm 手册（给 agent 的工作知识库）

这个目录是移植工作的系统手册：每个子系统一页，写它的职责、关键类、legacy
里的出处和不能破坏的约定。**动手前先读下面路由表指到的页面**，用页面了解
系统怎么拼起来，源码只看页面指到的文件——不要靠翻反编译代码去猜结构。
页面和代码不一致时以代码为准，并在同一个改动里把页面改对。

## 路由表

| 你要动的东西 | 先读 | 主要 legacy 出处 |
|---|---|---|
| 启动链（预加载器 → config → main3 → 模块加载与四个外部 swf 模块壳） | [architecture/startup.md](architecture/startup.md) | `decompiled main3 module/Main.as`、`FarmApplication.as` |
| 网络请求与返回解析 | [architecture/net.md](architecture/net.md) | `decompiled main3 framework/net/`、`legacy/deploy` 的 PHP |
| 会话与全局数据（Session、Model、FarmLandModel、实体 Player/PoolFish） | [architecture/data.md](architecture/data.md) | `decompiled main3 common/Session.as`、`module/mainScene/farmLand/`、`entities/Player.as`、`entities/PoolFish.as` |
| 农田场景渲染（farmLand 视图/控件、背景装饰槽、NPC、qui 窗口链） | [architecture/farmscene.md](architecture/farmscene.md) | `decompiled main3 module/mainScene/` |
| 工具区与通用视图（uitools 模块、qui 控件子集、飘字/光标） | [architecture/uitools.md](architecture/uitools.md) | `decompiled main3 module/uitools/`、`com/qzone/qui/`、`common/view/` |
| 升级弹窗（module/levelup、Update.* 面板符号、levelUpUI 库） | [architecture/levelup.md](architecture/levelup.md) | `decompiled main3 module/levelup/` |
| 站内信/留言/日志/公告（main3 module/messages + Master2 mc/view/main/window/profile 两族） | [architecture/messages.md](architecture/messages.md) | `decompiled main3 module/messages/`、`decompiled Master2 mc/view/main/` |
| 好友列表栏（module.friend：列表/状态角标/召回/过滤/跳转好友农场） | [architecture/friends.md](architecture/friends.md) | `decompiled main3 module/friend/` |
| 新手任务/欢迎引导（module.task：11 任务表、taskComp 三门、help 引导、task_v_2 符号垫片） | [architecture/tasks.md](architecture/tasks.md) | `decompiled main3 module/task/`、`nc_data.php` secondList |
| 商店（shop_v_7 功能 swf：module.shop 主窗/六买入窗/ShopModel 购买协议、ModuleShop 反射接入） | [architecture/shop.md](architecture/shop.md) | `decompiled shop_v_7 scripts/module/shop/`、`spec/modules/farm-shop-ui.json` |
| 资产声明与本地化加载 | [architecture/assets.md](architecture/assets.md) | `assets/legacy-assets.txt`、根目录 `libraries.xml`、`src/shim/LocalSwfLoader.hx` |
| 场景运行器与请求对拍（tools/scenario.mjs、场景/基线 JSON、nodeboot 应答分档） | [architecture/scenario-runner.md](architecture/scenario-runner.md) | 判定期望值的出处见 `test/ScenarioRunnerContractTest.hx` 断言消息 |
| 环境、工具、反直觉的坑 | [lessons/index.md](lessons/index.md) | — |

还没有页面的子系统：翻译完成时由实现 agent 建页并在表里加一行。

## 维护规则

- **边实现边补**（所有者 2026-11-19 决定）：翻译一个子系统时，在同一个
  改动里建好或更新它的页面——职责、关键类与 legacy 出处、遇到的约定；
  路由表加行。页面写给下一个 agent：写「为什么」和「在哪」，不复述代码。
- 简体中文；文件名小写；页面间相对链接。
- 踩坑（环境差异、工具行为、legacy 反直觉处）按 [lessons/index.md](lessons/index.md)
  的格式追加。
- 本目录之外的 `*.md` 仍然不许写（根目录 md 是受保护路径）。

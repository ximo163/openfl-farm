# 资产声明与本地化加载

原版 swf 资产的入库与加载机制。

- **同步**：`assets/legacy-assets.txt` 一行一个 `legacy/deploy/QFarmFlash/`
  相对路径 → `scripts/sync-legacy-assets.sh` 拷到 `assets/legacy/` 下同样
  相对路径（生成物不入库；流水线在每次 agent 运行后自动同步）。**不手拷
  文件、不改资产内容**，只改清单。
- **声明**：根目录 `libraries.xml` 一行一库（`<library path id/>`），id =
  swf 文件名去 `.swf`，`Assets.getMovieClip("<id>:符号名")` 取符号。
  **必须和 legacy-assets.txt 同 commit 改**——只改 libraries.xml 不同步
  清单时构建打 Warning「Could not find library file」继续出产物（#8 实测，
  并非 CLAUDE.md 说的直接红），运行期库为空。`Project.xml` 本体由人管，
  只通过 include 合并 libraries.xml。
- **场景窗口请求的 module swf 逐项入库**：翻译把加载链接通后，凡是启动/
  场景窗口内会 `Loader.load` 的 module swf 都必须入库（uid=1 快照数据实际
  触发的集合），缺一个 = html5 运行期对未声明库 404 → CI web-smoke
  console.error FAIL。表格式门三个（新窗口接入新 URL 时照式加条目，别等
  CI）：`test/StartupModuleLibrariesTest.hx`（#7 启动窗口，已注册在
  TestMain 里跑批）、`test/SceneDecorLibrariesTest.hx`（#8 场景装饰窗口，
  **尚未注册**）与 `test/CropLifecycleLibrariesTest.hx`（#8 作物生命周期 +
  看板窗口，**尚未注册**）。implement 阶段对 test/ 既有文件 append-only，
  注册行只能由 write-tests 阶段补 `runner.addCase(new …())`；注册前这两
  片的不变量由 CI web-smoke 的 404 计数兜底（两文件各用 /tmp 侧 harness
  对当前树跑过全绿，见 lessons 的 append-only 条目）。作物窗口的数据链
  从 farmlandstatus 字母协议起读（a=作物号，b=cropStatus——见 lessons 的
  字母协议条目），别按字母猜。
- **加载**：原版运行期网络加载的库**不** `preload`（只有 V1 探路样本
  preload="true"）；代码里的 `Loader.load(远端URL)` 只在加载器类里换成
  `src/shim/LocalSwfLoader.hx`（`libraryIdForUrl` 按 URL 尾段映射库名），
  其余代码保持原调用形态。文件名做库名的约定遇**同名文件撞库**时（已发生：
  `diy/board/1.swf` vs `diy/1.swf`，nc_data.php:2260/:51）以目录前缀消歧
  （LocalSwfLoader 的 diy/board/ 特判 → 库名 `board_1`，libraries.xml 同款
  id）——撞库不 404、槽位装错图，CI 冒烟拦不住，新撞库照式扩特判 +
  CropLifecycleLibrariesTest 那样的消歧断言。onComplete 把字段补齐 + 显示
  挂载 + COMPLETE 派发整体交给 openfl 原生完成路径 `Loader_onComplete`
  （`@:access` 调私有成员）。不能在子类里照抄原生路径的
  `super.addChildAt(content, 0)`：super 只上溯一层，从本子类调命中的是
  Loader 自己的 #2069 覆写（#21 attempt 2 的 CI web-smoke 红在这，细节
  见 lessons #21 的 super 条目）。help.swf 引导是首个把 **loader 本身**
  addChild 的调用方，不挂内容就整屏空白（#21）；只读字段的调用方
  （RSLManager 等）不受挂载影响。
- **SymbolClass 符号 shim**（`src/shim/SymbolClass.hx` + 各同名类）：原版
  swf 的 SymbolClass 把导出符号绑到同名 AS3 类，视图 `new Farmland_Lite()`
  直构带时间轴；openfl 只有 `Assets.getMovieClip` 实例化才挂时间轴。同
  名 Haxe 类（`@:keep`）构造器里补 `SymbolClass.bind(this, 库id, 符号名)`
  挂回。**三个登记义务**：① 新符号 shim 必须同步加进
  `SymbolClass.dceAnchor` 数组（仅生产目标，`#if !eval`）——零引用的
  `@:keep` 类不进 `-dce full` 产物（见 lessons）；② 符号名小写开头的
  （如 canPickIcon）类名大写 + `@:native("原名")` 回键；③ 库**首次**拉起
  是异步窗口，构造器返回后立即对符号**子件**的写（显隐/定位）会被吞
  （时间轴还没挂上）——一律经 `SymbolClass.afterAttach(target, fn)`
  登记、attach 后重放（已挂上则立即执行）；写实例自身属性（name/
  cacheAsBitmap）不受影响。先例：Crop.onCropLoaded 的 step1/2/3 显隐
  （#8 review round 1，见 lessons）。④ **DefineButton2 符号的 shim 基类是
  SimpleButton**（#9）：tag 是 DefineButton2（按钮符号——
  AnimateButtonSymbol.__constructor 往实例写 downState/hitTestState/
  overState/upState 四态）的导出符号，同名 Haxe 类必须 `extends
  SimpleButton` + `SymbolClass.bindButton(this, 库id, 符号名)`；MovieClip
  基类在 js 上炸 `set_downState is not a function`（#9 工具条 11 枚素材全
  如此：ToolHand/ToolHoe/… 及 ToolBoxBar/UIController 的角标按钮）。判法：
  新增符号 shim 前先用 /tmp 侧 probe 看 swf 的 DefineButton/DefineButton2
  char id 与 SymbolClass 对应关系（CWS 解压 + fps/frameCount 跳过即可），
  别按 MovieClip 惯例写完再撞运行期。bind/bindButton 共用 pending 队列
  （target 放宽到 DisplayObject；afterAttach 登记只有 MovieClip 路径会走，
  SimpleButton 恒空数组）。**部署包缺符号的**（#9：ButtonMaker 表引用的
  ButtonSuperMarket/ButtonMill1/NavigationLeftArrow/NavigationRightArrow
  全部署 swf 都不导出——main3 代码比部署包的 farmui_full 新一个版本位）：
  保空 MovieClip 垫片让 getMaterial 反射可构造、启动不炸（原版跑这份
  部署包同样 null 后 NPE），不渲染是 deviations 候选。
- 当前已入库的库和每个库的来源依据，看 `libraries.xml` 和
  `assets/legacy-assets.txt` 里的分组注释（V1 样本 / V2 加载链 / V3a
  启动链 / V3b 作物分档 + 场景装饰 / V3c 收获飘字苗图）。

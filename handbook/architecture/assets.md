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
  console.error FAIL。这条有两道门：
  `test/StartupModuleLibrariesTest.hx`（#7 启动窗口）与
  `test/SceneDecorLibrariesTest.hx`（#8 场景装饰窗口）——新窗口接入新 URL
  时照这两个文件的表格式样加条目，别等 CI。
- **加载**：原版运行期网络加载的库**不** `preload`（只有 V1 探路样本
  preload="true"）；代码里的 `Loader.load(远端URL)` 只在加载器类里换成
  `src/shim/LocalSwfLoader.hx`（`libraryIdForUrl` 按 URL 尾段映射库名），
  其余代码保持原调用形态。
- **SymbolClass 符号 shim**（`src/shim/SymbolClass.hx` + 各同名类）：原版
  swf 的 SymbolClass 把导出符号绑到同名 AS3 类，视图 `new Farmland_Lite()`
  直构带时间轴；openfl 只有 `Assets.getMovieClip` 实例化才挂时间轴。同
  名 Haxe 类（`@:keep`）构造器里补 `SymbolClass.bind(this, 库id, 符号名)`
  挂回。**两个登记义务**：① 新符号 shim 必须同步加进
  `SymbolClass.dceAnchor` 数组（仅生产目标，`#if !eval`）——零引用的
  `@:keep` 类不进 `-dce full` 产物（见 lessons）；② 符号名小写开头的
  （如 canPickIcon）类名大写 + `@:native("原名")` 回键。
- 当前已入库的库和每个库的来源依据，看 `libraries.xml` 和
  `assets/legacy-assets.txt` 里的分组注释（V1 样本 / V2 加载链 / V3a
  启动链 / V3b 作物分档 + 场景装饰）。

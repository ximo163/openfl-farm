# openfl-farm：给 agent 的工作规则

这个仓库把一个 Flash 农场游戏（phpYe.QFarm 7.0，原版只剩部署包：swf + PHP 后端，
没有源码）的客户端**翻译**成 OpenFL（Haxe），构建 Android APK 和 html5。开发由
编排器流水线完成，你很可能就是其中一个 agent。计划、架构和验收标准的说明在
`ximo163/openfl-farm-docs`；这个仓库**不写任何给人看的文档**（`*.md` 是受保护
路径，唯一例外是本文件）。

**核心方法论：翻译，不重写。** 移植的类和反编译出的 AS3 类 1:1 对应，显示树、
协议、时间轴语义全部保留。不引入原版没有的架构（没有 Intent、没有 GameService、
没有自写时间轴播放器）。上一轮 FarmCocos 的重写方案已放弃，不要把它搬回来。

## 目录

| 路径 | 内容 | 谁改 |
|---|---|---|
| `legacy/deploy/QFarmFlash/` | 原版部署包，原样放置（152 MB）：PHP 后端（规则权威）、客户端 swf、配置 | 人，只读 |
| `legacy/manifest.json` | 部署包说明：入口 PHP、swf 位置、配置目录、运行环境 | 人，只读 |
| `legacy/decompiled/` | FFDec 从 5 个主代码 swf 导出的内容（`scripts/` 反编译 AS3、`swf.xml`、`header.txt`…）。**翻译的唯一依据** | CI 生成，只读 |
| `legacy/references/` | 逐资产/场景的**原版参考截图**（Ruffle 录出）。画面验收的标准答案 | CI 生成，只读 |
| `spec/` | 规格：`modules/`（模块移植清单）、`protocol.json`、`interaction-map.json`、`deviations.json`、`swf-inventory.json` | `pipeline:spec` 提取、人审核后只读 |
| `src/` | 移植的 Haxe 代码，包结构对应 `legacy/decompiled/**/scripts/` | agent |
| `src/shim/` | 唯一允许的原版没有的代码：平台差异薄胶水（悬停→长按、ExternalInterface 等），每个文件头注释写明为什么 | agent |
| `assets/legacy/` | 从 `legacy/deploy/QFarmFlash/` 拷贝的原 swf 资产副本（**不入库**：构建时由脚本同步，清单见 `assets/legacy-assets.txt`） | 脚本生成，不手改、不提交 |
| `assets/legacy-assets.txt` | 资产同步清单：一行一个 `legacy/deploy/QFarmFlash/` 相对路径（如 `module/main3_v_221.swf`） | agent（按模块需要增删） |
| `test/` | utest 单元测试（eval 目标，纯逻辑） | agent |
| `tools/` | 转换与比对工具 | agent |
| `checks/`、`scripts/`、`harness/` | 校验脚本、反编译/资产同步脚本、自动验收 | 人，只读 |
| `Project.xml`、`test.hxml` | OpenFL 工程与测试编译配置 | 人，只读 |
| `.github/workflows/` | CI：反编译、html5 构建+冒烟（`web-build`/`web-smoke`）、Android APK | 人，只读 |

## 读原版之前：先读 legacy/manifest.json

- 所有路径相对 `legacy/`。PHP 入口、swf 位置、配置目录都在 manifest 里，不要在
  整个部署包里盲搜。
- 原版代码里的路径按部署关系理解：PHP 相对 include 相对当前文件；swf 里的相对
  URL 相对 swf 所在 URL；`web_root` 对应站点根。
- 客户端加载链（从代码核实过）：`nmc.php` 页面 → `happyfarm3_v_149.swf`（预加载器）
  → `xml.php` 的 config → `main3_v_221.swf`（农场主程序）；牧场 `mcloader_v_53.swf`
  → `Master2_v_142.swf`。翻译的类主要来自 main3/Master2 的反编译结果。
- `legacy/decompiled/` 还没生成（manifest 或 spec 里会说明）时，需要它的任务最后
  一行输出 `BLOCKED: legacy/decompiled 尚未生成（先跑 CI 的 legacy-decompile）`。

## 原版行为就是需求

- 除非 `spec/deviations.json` 列出，否则行为必须和原版一致：数值、公式、时序、
  请求参数、事件顺序、动画帧上触发的事。
- 依据优先级：`legacy/traces/`（录下的行为）> `legacy/deploy/` 的 PHP > 
  `legacy/decompiled/`（反编译客户端）> 下发的 XML 配置。矛盾时以前者为准，
  并在 PR 说明里写明矛盾。
- 测试里每个期望值都要能指出处：测试上方注释写明 legacy 文件和位置（如
  `// legacy/deploy/.../mync.php farmlandstatus_harvest` 或
  `// legacy/decompiled/.../scripts/xxx.as: getOutput()`）。出处是 issue 的写
  `// issue #<编号>`。
- 规格（`spec/`）里已有该模块的清单时，以它为准；规格和 legacy 对不上，输出
  `BLOCKED: <哪里对不上>`，不要自行裁决。
- 规格里没有、legacy 里也推不出的行为，不要自己设计：最后输出
  `BLOCKED: <缺什么规格，在哪个文件遇到>`。

## 翻译规则

### 对应关系

- 一类对一类：`legacy/decompiled/.../scripts/` 下的 `com/qfarm/Foo.as` → 
  `src/com/qfarm/Foo.hx`。不合并、不拆分、不改名、不增删公共 API。
- 一个模块 issue 只翻译 `spec/modules/<模块>.json` 列出的类。顺手的「改进」一律
  不做：原版写法再烂也照译，偏差只进 `spec/deviations.json`（由人维护）。

### API 映射（flash.* → openfl.*）

`flash.display.*`、`flash.events.*`、`flash.net.*`、`flash.media.*`、`flash.text.*`、
`flash.geom.*`、`flash.utils.*`（Timer、ByteArray、getTimer）、`flash.system.*`
整体映射到 `openfl.*` 同名类，import 换前缀即可。注意：

- `flash.external.ExternalInterface`：只在 html5 目标可用，包在 `src/shim/` 下按
  目标编译（`#if html5`）。
- `flash.net.LocalConnection`、`navigateToURL`：openfl 支持不完整，遇到时在
  `src/shim/` 做目标相关的等价物并在类头标 `// PORT-NOTE:`。
- `Loader.load()` 远程 swf：原版资产已本地化，统一走 `Assets.getLibrary()` /
  `Assets.getMovieClip("库名:符号名")`，这个映射**只写在 mcloader 对应的加载器类里**，
  其余代码保持原调用形态（包一层同名方法）。
- `SharedObject`：openfl 有，但路径/行为有平台差异，读写集中到 `src/shim/Save.hx`
  这样的封装（原版调用点照翻，指向 shim）。

### 语言差异（AS3 → Haxe）

- 类型：`Number→Float`、`int→Int`、`uint→UInt`、`Boolean→Bool`、`*→Dynamic`、
  `Array→Array<Dynamic>`、`Object→Dynamic`（结构固定的匿名对象可用匿名结构，
  但不要造 typedef 层级）。
- 包声明不带大括号；类成员默认 private，原版 `internal` 的写 `private`，`public`
  照写。
- getter/setter：`function get x()` → `@:property` 或显式 `get_x()/set_x()` 加
  public 字段，选一种并在整个文件里一致。
- `const`/`static const` → `static final`（或 `inline`，仅限字面量）。
- 字符串双引号/单引号随意，但保持原文件风格。
- 反射：`getDefinitionByName` → `Type.resolveClass`（需要 `@:keep` 保持类不被
  裁剪）；`describeType` 没有等价物，遇到标 `// PORT-NOTE:` 并找替代或 BLOCKED。
- for-in / for-each：Haxe 用 `for (k in Reflect.fields(o))` / `for (v in arr)`，
  语义保持原样。
- 默认参数、`arguments`、`...rest`：`function f(...args)` → `function f(args:Array<Dynamic>)`
  语义不同时标 `// PORT-NOTE:`。
- 翻不过去（行为无法等价）的地方不要硬翻：`BLOCKED: <类名.方法名，卡在什么>`。

### 资产

- 需要新资产时：把路径加进 `assets/legacy-assets.txt`（相对
  `legacy/deploy/QFarmFlash/` 的完整路径），同步脚本会拷进 `assets/legacy/`。
  **不要手拷文件、不要改资产内容**。
- `Project.xml` 的 `<library>` 声明由人管：需要新 library 时在 PR 说明里列出，
  输出 `BLOCKED: Project.xml 需要新增 library <路径>` 也行。

### 交互

- 原版的 `MouseEvent.CLICK/DOWN/UP` 照翻（OpenFL 移动端自动把触摸合成为鼠标事件）。
- `ROLL_OVER`/`MOUSE_OVER`/右键/滚轮：**不改原代码**，在 `src/shim/` 的输入适配层
  按 `spec/interaction-map.json` 的映射合成这些事件。映射表里没有的交互输出
  `BLOCKED`，不要发明。

## 画面保真（硬需求）

用户的要求是**原汁原味复刻**：画面跑偏等于失败。CI 用逐资产渲染比对 + 场景比对做
门禁，所以在代码层面就要保证：

- **视觉参数逐字照抄**：坐标、尺寸、缩放、旋转、颜色、alpha、滤镜参数、帧率、帧
  标签、文本内容与样式，和反编译原文逐字一致。任何「顺手调一下更好看/更合适手机」
  都不允许。
- **不重排界面、不换资产**：布局结构（哪个显示对象挂在哪个父级、第几层）保持原样；
  手机适配（等比缩放、信箱）只允许在 `src/shim/` 的适配层做，不进翻译的类。
- 动画语义保持：帧数、帧率、`gotoAndPlay` 的目标、循环点不变。**代码驱动的动画
  逐字照抄**：`Event.ENTER_FRAME` 处理器的每帧位移与条件、`Timer` 的 delay/
  repeatCount、缓动/插值公式，一个数字都不改；帧驱动的不许改成时间驱动（反之亦然）。
  CI 有时间轴行为比对（固定步长推进对拍帧序列）和场景连拍，动画跑偏过不了门禁。

## 测试规则

- 只测纯逻辑（不碰显示对象、不联网、不读真实时间、不 sleep）：mod 参数拼装、
  JSON 解析、数值公式、工具函数。`haxe test.hxml`（eval 解释器）秒级跑完。
- 表驱动；测试名说明行为。期望值出处规则见上。
- 显示层、交互、渲染的正确性不在单测里证明——那由 CI 的 `web-build`/`web-smoke`
  和画面比对负责。

## 环境边界（重要）

容器里**没有也不装**：JDK、FFDec、Android SDK/NDK、浏览器、Docker。不要尝试安装
它们（也不会有权限）。所以：

- 反编译产物（`legacy/decompiled/`）只能读，不能再生成——缺了就 BLOCKED。
- Android 构建不要在本地试，`openfl build android` 会失败，这不是代码问题。
- 验证命令只有：`openfl build html5`（全量编译检查）、`haxe test.hxml`（单测）、
  `bash checks/*.sh`。
- PHP 片段可以用 `php -l`/`php -r` 试跑来读懂逻辑（容器里有 php-cli）。

## 风格

- Haxe 惯例命名，但**类名、方法名、字段名保持原版**（对应关系是验收标准）。
- 注释说明为什么（尤其 `// PORT-NOTE:` 处），不复述代码做了什么。
- 不加新依赖（haxelib）；`Project.xml` 已声明的 openfl/swf/utest 够用，缺了 BLOCKED。
- 改动小而集中：一个 issue 只做一件事。

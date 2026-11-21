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
- **静态目标上 null 不能当 Int**：`_loc3_ == null`（Int）在 eval/html5 过、
  android（cpp）编译红——容器里编不了 android，只在 main 的 android CI 暴露
  （MD5.hx 两处，#7 合并后才发现）。防：Int 判空用下标范围；要「缺位」语义
  读经 `Dynamic` 再判 null。规则已进 CLAUDE.md 的语言差异清单。

## 2026-11 · #8（V3b 农田场景）

- **eval/js 的 Dynamic 反射只看见物理字段，get/set 属性一律 null**：
  probe（`/tmp` 里 haxe --interp + openfl/lime）证实两次——自有类修法是
  `@:isVar public var x(get, set)`（补物理字段）；**openfl 自家的**
  `DisplayObject.name/x/y` 等是库内 get/set、无物理字段，改不了 → 测试经
  `Dynamic` 读它们恒 null（`FarmLandsViewTest.test_createLandTiles` 15 断言，
  期望值本身和 FarmLandsView.as:118-146 对得上，是读法机制错）。防：测试
  断言只读自有类的物理字段；要验显示对象坐标就强类型读，别走 `Dynamic`。
- **`arr.splice(0)`（AS3 删到尾）在 Haxe 编不过**：splice 要 len——
  `splice(0, arr.length)`（Crop.hx:69）。防：全局搜 `splice(` 核对第二参。
- **`Dynamic["中文字面量"]` 在 eval 报 "String should be Int"**：动态对象
  的非标识符键下标直取走不了——`Reflect.field(o, "中文…")`（FarmLandController
  的 Language.L 取值 ×5）。防：`obj["…"]` 一律 Reflect.field/setField。
- **超类 static 不无限定解析**：AS3 里子类裸用父类静态，Haxe 要
  `父类名.成员`（Move.hx 的 `TweenEffect.getSnap/duration`）。私有跨类访问
  配 `@:allow(包.类)`。
- **AS3 `new Date()` + `setTime(ms)` → `Date.fromTime(ms)`**：Haxe 的
  `new Date()` 必须传全参且没有 setTime（FarmLandController.isOneClickMode）。
- **连锁赋值在 openfl get/set 上编不过**：`scaleX = scaleY = 1.3` 拆成两行
  （BackgroundController.switchMode）。
- **原版 bug 照抄不修**：`askSharePlane` 拼 URL 少个 `&`、`cacheAsBitmp`
  拼错（PopUpManager 字段名）——逐字保留，别「顺手修好」，偏差只进
  `spec/deviations.json`。
- **AS3 `x == "字面量"`（x 为 Dynamic）是松等，同字段有数值/字符串双形态**：
  nc_data.php 的 isRed/isAnimation 一部分作物是 `"isRed": 1`（裸数值）、另一
  部分是 `"isRed": "1"`（字符串），_vip.php 的 eType/eNum 也是数值——AS3
  `1 == "1"` 为真，Haxe 严格 == 在 eval/cpp 上失配（js 目标偶然因 JS 松等
  而同，#8 实现复审才现形：isAnimation/isRed/eType/eNum 五处）。防：Dynamic
  与字符串字面量的比较一律 `As3.eqString`（shim 既有）。
- **AMF 往返对未注册类别名的实例退化成匿名对象**：全库只给 TextFormat 注册
  过 registerClassAlias（TextFormatUtil.as:17），所以 `ObjectUtil.clone(...) as
  HealthMode` 恒 null——原版 Player.clone() 的 _healthMode 从来就是 null，
  「看起来在深拷」是错觉。防：ByteArray.writeObject/readObject 的语义按 AMF3
  规则推，别按读代码的直觉。
- **`As3.dateOf` 解析失败回 null，调用点必须先判 null**：原版 Invalid Date
  的等价是「NaN 比较恒 false ⇒ 跳过」，裸读 `null.getTime()` 直接抛
  （NPCView 构造器漏判）。防：dateOf 调用点照 FarmLand.get__goldLand 的
  null 守卫式写。
- **`obj["k"] != undefined` 的完整映射是 `hasField && field != null`**：
  AS3 里 null == undefined 为真，漏 `!= null` 半守卫会放行 null 值
  （NPCView bubble、FarmLandsView healthMode/gold、FarmLandController
  direction/error/place）。防：全局搜单独出现的 `Reflect.hasField(` 核对
  有没有漏半守卫。
  **这条防法上轮没搜干净**：implement 驳回轮又补了三处同型——NPCView tip
  （:311）、NPCModel hours（:46）、FarmLandController dogTip 的 tipText/txt
  （:726/:730，值 null 时不止行为差、直接 NPE）。核对时 `hasOwnProperty`
  和 `!= undefined` 要分开：前者单 hasField 就是完整等价（FarmLandModel
  pest/weed/exp 等多处），别一刀切全配对。
- **swf 帧脚本在本地化库处理时被丢弃（scriptSource 导出为空串）**：
  MaoPaoFlag 的 frame1 `infoTxt.text = talkInfo` 不再执行——气泡文本缺失是
  既知视觉偏差（deviations 候选）。防：涉及符号内嵌脚本的显示行为，先看
  `haxelib run swf` 处理产物的 scriptSource 是否为空再下结论。
- **Haxe for 循环变量按元素类型重新绑定，AS3「for each 写进已声明强类型
  局部」是假等价**：AS3 `var _loc2_:BaseLayer; for each (_loc2_ in arr)
  { _loc2_.name }` 把元素写进**已声明的强类型局部**，`.name` 是 getter
  调用；Haxe `for (_loc2_ in (arr:Array<Dynamic>))` 重新绑定一个**按元素
  类型（Dynamic）的新循环变量**，先声明的 `var _loc2_:BaseLayer` 是被遮
  蔽的死代码，且 Dynamic 上的属性访问编成**裸字段读写**。openfl 自家的
  get/set 属性（name/x/y/alpha/visible/scaleX/width/cacheAsBitmap）无物理
  js 字段 → 裸读恒 undefined → #8 CI 的 NPCView 崩溃就是这么来的：
  `FarmStage.getLayerByName` 查名恒落空返回 null，NPCView 构造器
  `param1.module.container.getChildByName` 抛 TypeError。修法（probe 在
  4.3.6 上验证过 codegen）：`(_loc2_ : BaseLayer).name`——ECheckType 在 js
  上抹平成强类型 `get_name()` 调用；`cast(x, T)` 是 `js_Boot.__cast` 检查
  转换（对应 AS3 会抛错的 `T(x)`）；`var c:T = cast x` 直接强类型。同因
  同修的还有 FarmApplication.getModuleByName、Crop 的 name/cacheAsBitmap
  写、FarmLandsView/FarmLandController 的 e.target.name 读（共 7 处生产
  代码）。防：译 AS3 for-each 时循环体若经元素碰 openfl 属性，访问一律
  `(元素 : 应有类型)` 强类型化；CI 红先看 pageerror 的栈帧类名链再猜。
- **`@:keep` 救不了「从未被类型化」的类，反射字符串专属类全被裁**：Haxe
  只编译从 main 可达（被引用/import）的类型；符号 shim 只经
  `getMaterial("com.qzone.ui.FarmlandS")` 这类反射字符串取用，编译期零引
  用——in-pipeline probe 证实零引用的 `@:keep` 类在 `-dce full` 产物里整
  体不存在，33 个符号 shim（FarmlandS/S2/G/G2 全色系、JPLand 四式、
  Wasteland、Crop_1_*/Crop_6_* 十档、Insect/Weed/Reclaim、
  CursorFishNet/All、canPickIcon）全被裁，LandTile 为此抛
  "Can not get land res!"。AS3 无此问题：Loader 装 swf 即把 SymbolClass
  类注册进 ApplicationDomain。修法：`SymbolClass.bind` 在启动链上必然执
  行，首次调用初始化 `dceAnchor` 类数组（运行时可达的引用）把全部 shim
  拉进类型图，各自的 @:keep 负责在 dce full 下保命——**新增符号 shim
  必须同步补一行**。锚整体 `#if !eval`：eval 按 LandItemRenderTest 的前
  提是「无资源」环境（测试断言 updateLandStatus 素材缺失会抛），锚把符
  号类编进 eval 会翻掉该前提（4 断言连红实锤）；test/ 是 append-only，
  环境前提由实现侧保。
- **小写开头的类名在 Haxe 里只能当孤儿，引用它是编译错**：原符号
  canPickIcon 小写开头。Haxe 跨模块引用小写类全形态皆编译错（import、表
  达式位置、类型位置，probe 逐一证实）；小写类文件「能编译」只是因为它
  从未被引用——即永远不进产物、反射恒 null，attempt 1 的
  src/canPickIcon.hx 就是这种死文件。修法：类名改大写 `CanPickIcon` +
  `@:native("canPickIcon")` 把 js 运行时注册键改回原符号名（probe 证实
  `$hxClasses["canPickIcon"]` 命中、`resolveClass("canPickIcon")` 可取），
  反射调用点的字符串一字不动。eval/cpp 的 resolveClass 不看 @:native 键，
  但 eval 单测不解析显示符号、cpp/android 门只编译不跑场景，不受影响。
- **删临时代码（探针/TEMP）时按 hunk 对 legacy 核，别按记忆删**：#8
  attempt 2 清 buildLayers 的探针时顺手删掉了 LAYER_DAILYMISSION 层和
  WindowLayer 两段**原版真代码**（FarmStage.as:194-197/202-204）——本地
  nodeboot 照样就绪（启动不查这两层），差一点带着显示结构回归收工。
  防：动过「先加后删」代码的文件，收工前 `git diff HEAD` 逐 hunk 问一遍
  「这个改动对应 legacy 哪一行」，对不上的还原。
- **就绪标记绿 ≠ 启动窗口干净，404 不炸 JS**：库加载 404 只走
  `onError` 分支，`__openflFarmReady` 照样置位——attempt 1/2 的 node 冒烟
  报「无 TypeError」收工，CI web-smoke 却连挂两轮（三条
  `console.error: Failed to load resource: 404`）。漏检的另一半是
  nodeboot 的 Image shim 对任意 src 发 load、不核文件存在。防：
  nodeboot 现在把服务器 404 与 Image src 缺失都计数、就绪后再跑 settle
  窗口、缺失即退 1（与 CI 的 console.error 判据对齐）；库里加载链改动
  后看的就是它，不是「有无报错」。排查 `/N?数字` 404 的正路：XHR 打栈
  （nodeboot 里包一层 `new Error().stack`）→ 帧指到
  `AssetManifest.loadFromFile` = 未声明库，库名即 URL 尾段，按数据链
  （decorative→item_info→assets→diy/N.swf）找回出处入库。
  attempt 2 曾把 `/N?数字` 误记成「原版 QQ 统计信标，可容忍」写进
  startup.md——错误结论进了 handbook 会把下一轮也带沟里，改代码依据
  前先核 handbook 结论怎么来的。
- **implement 阶段不能动 `test/TestMain.hx`——test/ 既有文件一律
  append-only，注册行也是「改」**：attempt 3 给 SceneDecorLibrariesTest
  加了 `runner.addCase(...)` 一行，整轮在跑任何检查之前就被拒，回滚的只有
  这一处（测试文件本身合法留存）。防：implement 新增测试文件时在类头注释
  和 PR 说明里标「注册待 write-tests 阶段」，把注册留给下一轮 write-tests
  （TestMain 末尾的 `// 新测试文件在这里注册` 注释就是给那个阶段的）；
  也别把注册塞进其他已注册测试文件——同样是改既有文件。注册前该测试的
  不变量由 CI web-smoke 兜底；要确认它没烂掉，可用 /tmp 侧 harness 单跑
  （`haxe -cp src -cp test -cp <tmpdir> -lib utest -lib openfl -lib lime
  -main Run --interp`，Runner 只 addCase 该类）。
- **stub 换真身会引爆已过测试里的潜伏 null 访问**：GetCropID.idState 从
  stub 恒 0 换成逐句翻译后，`haxe test.hxml` 一下红 10 个用例（FarmLandTest
  7 个、FarmLandModelTest/StartupDataParserTest 3 个），全是同一条栈：
  importObject/countNoneMatureLands → idState/timeToMature → getCropByID →
  `theApp.model`，而测试进程不跑 Main 启动链、`GetCropID.theApp` 恒 null，
  eval 上成员访问直接 "Null Access"。原版这个状态是 NPE、生产不可达（Main
  启动先于任何 FarmLand 导入设置 theApp，Main.hx:246/原版 Main.as 同位置），
  且这些已过测试的类头写的期望就是「无 app 数据 → null/0/-1」——处置：
  getCropByID 补 `theApp == null` 判 + PORT-NOTE，deviations 候选待人登记
  （本条不适用于启动链必然设置的其余 GetCropID 成员，那些测试都自设
  theApp）。防：把任何 stub 换成真身前，先全局搜它在测试进程里的调用链
  上有没有「启动才就位」的全局（theApp/Session/Settings），跑一遍已过
  测试看潜伏依赖；新测试的时钟依赖要算清漂移方向（见
  test/common/GetCropIDTest.hx 类头）。
- **SymbolClass 异步窗口吞「构造器返回后」的子件写**：`Crop_*_3` 是单帧
  符号、三个 step 子件全摆上时间轴，库**首次**拉起时 bind 只把实例入队
  （SymbolClass.hx 的 pending），构造器返回后 onCropLoaded 立即写 step1/2/3
  显隐——时间轴还没挂上，`getChildByName` 恒 null、写全丢；attach 后挂上
  的是「三档全显」的原始态（原版 SymbolClass 类定义即同步绑定，写的时候
  时间轴必然已在，没有这个窗口）。修法在 shim：`SymbolClass.afterAttach
  (target, fn)` 把待应用的写登记进 pending 条目、attach 后按登记序重放
  （已挂上则立即执行）；fn 捕获值在登记时定型，等价原版同步求值。防：
  新增符号 shim 后调用方若在 new 之后立即写**子件**（显隐/定位），一律走
  afterAttach；写实例自身的属性（name/cacheAsBitmap）不受窗口影响、照直
  写。
- **状态数组字母字段的语义只能由下发它的 PHP 行定，别按位置猜**：
  farmlandstatus 的 `{"a":2,"b":6,…}` 里 a 才是作物号、b 是 cropStatus
  （farmlandstatus_getoutput.php:62 `"cId":' . $a` 一行定死），#8 前几轮
  按「b 是第一个有语义差别的字段」猜成作物号，把快照读成「0 号地 cId=6、
  1..23 号地 cId=1」，libraries.xml 照错收了 Crop_1_1..4/Crop_6_0..4 十档、
  类头注释还把白萝卜的名字安到 cId=1 上；visit 4 attempt 1 的 CI 只报
  一条 404（缺 Crop_2_3），反查才现形。连带发现 SceneDecorLibrariesTest
  类头「billboard=9 不在 uid=1 数据里」也是同一类猜错（decorative 列确实
  没有 9，但 user_run.php:206 是按 activeItem 补发槽 9 的——快照 90001，
  看板在冒烟窗口内）——append-only 改不了，纠正落在
  CropLifecycleLibrariesTest 类头和 farmscene.md。防：字母协议/字段语义
  一律找到**拼 JSON 的那行 PHP**；「X 不在数据里」的断言要区分「列里
  没有」和「另一来源补发」两回事。
- **作物档位类名永远不出 4**：Crop.as:93-99 把 3/4/5 折叠成 _classStep=3，
  4 档类名（`Crop_<cId>_4`）构造不出来；公共分支类名带**未折叠**档位
  （Crop_1_6，素材却在 Crop_1_4.swf 里、URL 才折叠 6→4）。前几轮「生长档
  0..4，5/6 档折叠 4/3」的框架两头都错。防：涉 Crop 的库/类清单先从
  setState/onCropLoaded 的折叠行推，别从文件名枚举。
- **同名 swf 撞库名装错图，CI 冒烟不拦**：`diy/board/1.swf` 与 `diy/1.swf`
  文件名相同，LocalSwfLoader 按文件名映射库名都得到 "1"——看板槽组装载
  进的是 diy/1 背景图，无 404、无报错，冒烟只能确认「没有 404」确认不了
  「装的是对的图」（画面比对门禁在后）。修法：LocalSwfLoader 对
  diy/board/ 特判加 `board_` 前缀消歧，libraries.xml 用同款 id
  `board_1`，CropLifecycleLibrariesTest 钉「看板与背景映射必须不同库名」。
  防：新入库的 module swf 文件名先查是否与既有条目撞名；撞了就目录前缀
  消歧 + 断言，别等画面门禁。
- **stub 的类形态保真是审查条款，不是「没人调用就能省」**（implement
  驳回轮 4 点里的 3 点）：Panel 构造器默认值写成 `"Window"`（原文
  `"Panel"`，TitleWindow 的才是 `"Window"`）、Button 构造器整个签名没写
  （原文 `(String="Button", Function=null)`）、AllianceActivityManager
  register 真写表而 retrive 恒 null（半真半 stub 不对称，写出「注册了
  却取不回」）——当时都以「本片无调用方/无行为影响」为由省掉，全被驳。
  防：stub 只免**方法体**，构造器签名/默认值/字段表/成对成员照原文抄；
  一两行的成员直接真实现，别留半截。

## 2026-11 · #9（工具区 uitools）

- **大写开头的包段在 Haxe 里 import 不到**：`module.mainScene.npc.
  MonthEnd`（MonthEndWin 的包）任一引用形态全编译红——Haxe 把大写开头
  的 dot-path 段解析成**模块名**而非包段（`.*` 通配同样失败）。备选
  「MonthEnd.hx 模块文件装类」能编但腐蚀规范类型名（掉包段）。修法：
  目录改小写 `monthend`，类名/文件名不动（ShortcutBar 案例）。
  防：AS3→Haxe 建包先查有没有大写开头段，有就整段小写并在类头标
  PORT-NOTE。
- **Haxe 属性覆写只能覆 accessor，不能扩 accessor 也不能重声明**：
  基类 `(get,never)` 想在子类变 `(get,set)`——编译红「Invalid
  accessor」；子类 `override public var x(get,set)` 重声明——同样红。
  正确形态：属性声明**只在基类一次**、accessor kind 按子类需要取宽
  （基类挂 no-op set 垫底 + PORT-NOTE），子类只 `override` get_/set_
  函数，虚派发接管（ScrollBase.content → Container 案例，probe 验证）。
- **Haxe private 子类可见，原版「子类直写父类私有字段」照抄**：
  ShortcutBar 写 `direction = Direction.HORIZONTAL`（Box 私有）、
  `_vScrollPolicy = ScrollPolicy.OFF`（ScrollBase 私有）——别顺手补
  public，改可见性才是偏差。
- **AS3 `x != obj["k"]` 的 diff 比较侧不能先收敛**：updateOfflineStatus
  原文比较侧是裸 `param1["b"]`（int vs undefined：0 != undefined 成立，
  **缺键算变化**）、赋值侧才 `as int`。先 `As3.intOf` 再比会把缺键
  折成 0 != 0、吞掉整次派发（write-tests 的用例逮住：expected 1 实得
  0）。防：全局搜 `intOf(Reflect.field` 核对它只出现在赋值侧；
  FarmLandModel.hx:1172 的裸比形态是标准写法。
- **`Math.NaN` 不是合法默认参**：Haxe 默认参要字面量常量。NaN 语义写
  `Null<Float> = null` + ctor 里 `== null ? Math.NaN : x` 归一
  （ScrollEvent ctor，原文 `Number = NaN`）。
- **openfl 与 flash 的 API 有缺位/挪位**：`IOErrorEvent.NETWORK_ERROR`
  在 openfl 被注释（AIR-only）——按 AS3 常量值字面量 `"networkError"`
  注册；`BitmapFilter` 在 `openfl.filters` 不在 display（UIController
  import 修正）。防：flash.* → openfl.* 不是纯前缀替换，编译红先查
  openfl 源（`/usr/local/lib/haxelib/openfl/9,5,2`）。
- **根目录符号 shim 要显式 `import shim.SymbolClass`**：根包类（ToolBarBg/
  PackBarBg）不像 `package xxx` 类那样能裸解析 shim 包——首编报
  Unknown identifier。ItemLoading/ToolBarBg/PackBarBg 三件同模式。
- **忠实 ctor 在 eval 会因素材抛 #2007，纯状态机测试走
  `Type.createEmptyInstance`**：ToolBar 的 ctor new 素材会 addChild
  null（eval 立抛），但 setCursor/onKeyUp 是纯逻辑——空实例 + 手工钉
  字段驱动（ToolBarTest 先例）。别为测试改 ctor。
- **DefineButton2 按钮符号的垫片基类是 SimpleButton，不是 MovieClip**
  ：#9 工具条素材（ToolHand/ToolHoe 等全部）在 swf 里是 DefineButton2
  tag——AnimateButtonSymbol.__constructor 往实例写 downState/四态，js
  上 MovieClip 基类直接炸 `set_downState is not a function`（nodeboot
  点「收获」按钮即崩才发现）。修法：`extends SimpleButton` +
  `SymbolClass.bindButton`（bind/bindButton 共用 pending，target 放宽
  DisplayObject）。防：新增符号 shim 前先 probe swf 的 tag 类型
  （DefineButton/DefineButton2 char id × SymbolClass 对应），规则已进
  assets.md 符号 shim 节。
- **`Dictionary<Dynamic, Dynamic>` 落 StringMap，函数/对象键被 JS 对象
  键强转成字符串**：openfl Dictionary 是 `@:multiType`，K=Dynamic 时
  按 @:to 列表**第一个**（toStringMap）统一——UIComponent.renderCalls
  的键是方法闭包，RENDER 帧重放时字符串键 `apply` 直接 TypeError；
  EffectManager.effectInstances 键是 DisplayObject 同坑。修法：K 写成
  具体类型（`Dictionary<Dynamic->Void, …>`/`Dictionary<DisplayObject,
  …>`）落 ObjectMap，语义同 AS3 Dictionary 对象键。防：见到
  `new Dictionary<Dynamic,` 全局搜掉，键永远写实际类型。
- **AS3 `new Date("7/20/2012 00:00:00")` 解析不了得 NaN、不抛；Haxe
  `Date.fromString` 对美式串直接抛**：Settings.isGiftTime 的
  monthEnds 配置串就是美式 m/d/Y（xml.php 真实载荷），启动链
  setConfigDataModel 必经——原以为该分支不可达，Main.hx:253 打脸。
  修法：`As3.dateOf`（失败回 null）+ null 时按 NaN 语义代入（比较恒
  false）。防：原版 `new Date(单字符串参)` 一律 dateOf + null 守卫，
  别信「这个串解析不了、分支死代码」——原版解析不了**不等于分支不走**。
- **注册 Font 名字传 null 炸 AnimateDynamicTextSymbol 的兜底字体匹配**
  ：swf 文本符号实例化时若字体未嵌，兜底逻辑 `Font.enumerateFonts()` 循
  环里 `font.name.replace`——我们 `Main_EMBED_FONT_A` 桩 Font 以
  `new Font()`（name=null）注册，#9 绑 ToolUpgradeNew 时栈就断在
  replace。修法：`super("embedFontA")` 传原 fontName。防：桩类基类
  ctor 的可选参别省——先查消费方拿它做什么再定默认值。
- **openfl 的 at-target 阶段不放捕获监听；模拟点击必须点显示对象的
  子节点**：FarmLandsView 把 CLICK 监听 `useCapture=true` 注册在
  LandItemRender **本体**（FarmLandsView.hx:143），openfl 的
  `EventDispatcher.__dispatchEvent` 按
  `listener.useCapture == (phase == CAPTURING)` 过滤——直点本体
  （`land.dispatchEvent(click)`）一枪不发（drive9 全部
  act=harvest/scarify/planting/water 断言连红、又全被「树里本来就
  有」的弱断言掩护成假绿的来源）。真实鼠标命中的是 LandTile 挂进地块
  项的**底图子节点**，监听在捕获阶段触发、currentTarget==地块项
  （onMouseEvent 的 CLICK 分支正按 currentTarget 判
  `__FarmlandItem__`）。防：驱动器/本地对拍模拟点击，先看监听注册的
  useCapture 与挂载层级——捕获监听派发 target 必须是它的后代。
- **构建产物把 Haxe 类全关进 lime 的 IIFE，node 侧够不到类与
  MouseEvent 构造器；驱动句柄从 shim.Harness 出**：nodeboot --drive
  的驱动器拿不到 `openfl_Lib`/`$hxClasses`（只有 `globalThis.lime`
  被导出）。修法：`shim/Harness.hx` 在既有 `__openflFarmReady`
  注入点同时挂 `window.__openflFarmDrive = {stage, MouseEvent,
  KeyboardEvent}`（CI/浏览器侧无人读，纯本地证据链胶水）。配套：
  nodeboot 的 mync 服务器按 mod/act 换 fixture（`mync-<mod>-<act>.
  json`，按 legacy PHP echo 模板造）+ myncLog 抓 POST body；Haxe 属性
  在 js 产物上是 get_x()/set_x()、类匹配走 `o.__class__.__name__`。
  防：断言「显示树里出现了 X」必须拿**对起点的增量**（快照前后计数），
  别拿静态存在当证据——boot 树里本来就飘着别的 Floating/Crop。
- **`ERR_NETWORK_CHANGED` 先找是谁的请求在挂死，别先declare基建抖动**：
  #9 attempt 2 曾把它归类「runner 宿主网络事件、没有代码修法」而原样重跑——
  attempt 3 推翻：**传输层错照样有代码侧根因**。完整机制：CI 用真实快照后端，
  `user_run` 下发 `headPic`（user_run.php:276）＝快照配置的
  `UC_API=http://192.168.218.129/ucenter`（legacy/snapshot/home-config.php:45，
  参考部署的**局域网地址**）拼 `/avatar.php`；#9 新翻的 PersonInfo 在启动链必发
  这个头像请求（updateHostInfo → set_url → Loader.load）——runner 上该地址
  不可路由，SYN 被丢、请求挂死，恰好被 runner 网络事件杀掉 → 唯一一条
  `console.error: net::ERR_NETWORK_CHANGED` → web-smoke 红。每次 CI 同样发、
  同样挂死、同样被杀——两轮同点红不是抖动，是**注定失败的启动期请求**。
  nodeboot 一直绿的原因是双重的：fixture 里 headPic 是空串（守卫跳过加载，
  请求根本不发）＋XHR shim 对出网请求无计数（发出去也看不见）。修法：
  头像出口并入 `shim/QQOutlets.loadImage`（no-qzone-jsapi 决策族，deviations
  候选待人登记；原版跑本部署包同样取不到头像 → 空头像框，视觉不变）；
  nodeboot 的 XHR shim 补「出网请求＝必死资源错」tripwire（计数 + 打栈 +
  不真发，避免随环境漂移），fixture headPic 换成真实下发值，先本地复现
  （红）再验修复（绿）。防：smoke 资源错先分两类没错，但分类前必须先
  **定位到具体请求**——浏览器日志不给 URL，交叉证据只有 nodeboot：把 fixture
  值换成 legacy/snapshot 真实载荷再看出网栈；`ERR_NETWORK_CHANGED` 本身
  只说明「请求挂死时被网络事件杀」，挂死的请求是谁才是要查的。
- **AS3 C 风格 for 的 continue 仍走尾自增，直译 while 必须照抄自增**：
  Session.addReward（Session.as:199）原文 `for(; _loc8_<len; _loc8_++)`，
  体内 `continue` 照常推进；直译成 while + 尾部自增后，continue 跳过自增 →
  任一元素缺 eType/type 键就**死循环**（ShortcutBar.onLevelUpGift/
  setGiftData/onClicked、UIController.onLevelUpGiftAccepted 四条入口可达，
  implement 驳回轮逮住）。NavigationBar ctor :97 同坑早有先例注释，Session
  这处漏了。防：译 C 风格 for 要么写 `for (_loc8_ in 0...len)`，要么 continue
  前补 `_loc8_++`；全局搜 `continue` 核对所在循环的自增形态。
- **openfl get/set 属性的裸写和裸读一样落空**：ToolBoxBar.addToolBtn 的
  `_loc3_.name = param1`（_loc3_ 为 Dynamic）在 js 上落不到 set_name、只挂
  影子普通字段——onToolClick 的强类型读恒 ""，工具箱按钮全灭。修法
  `(_loc3_ : DisplayObject).name = param1`（NavigationBar ctor 按钮具名
  同款）。防：#8 的裸读条目只防了读侧；Dynamic 上的 openfl 属性**赋值**要
  另全局搜一遍核对。
- **e.target/currentTarget 的 `.name` 路由读是系统性雷区，别一处一处等
  CI**：openfl Event 的 target/currentTarget 静态是 Object（=Dynamic），鼠标
  处理器里 `param1.target.name` 裸读在 js 恒 undefined——#9 驳回轮 6 类十
  余处一次现形（ShortcutBar/LeftSideToolBar/PersonInfo/NavigationBar 的点击/
  悬停分发全灭；web-smoke 的驱动只点工具条与地块，这些 widget 点不到，所以
  不红）。防：新译事件处理器凡按 target 名分发，一律
  `(param1.target : DisplayObject).name` 起手（FarmLandsView 先例）；同因的
  `supermarketMove` 裸读 `_loc3_.x/.y` 会 NaN 漂移，坐标读同规则。
- **AS3 下标键的隐式数组强转走 toString()=join(",")**：
  StringUtil.getChineseNum 的 `_loc3_[_loc4_]`（_loc4_ 是 Array）——AS3 键
  强转成 "5"/"2,3"，Haxe `Std.string(Array)` 出 "[5]" 永远查不中数字表。
  修法按 AS3 语义 `_loc4_.join(",")`。教训的教训：该函数 PORT-NOTE 原本就
  写着「Array→String "5" 或 "2,3"」，实现却走了 Std.string——PORT-NOTE 与
  实现对不上时以原文推演为准，别照抄既有实现。
- **静态目标的 null-vs-Int 容器内就能提前抓——cpp typer 不需要 hxcpp**：
  同一处修法自己又踩了 CLAUDE.md 静态目标规则（`var idx:Int =
  Std.parseInt(key)` + `idx != null`），eval/html5/单测全绿，驳回方用 cpp
  typer 一行逮住。CLAUDE.md「容器编不了 android」≠「查不了」：typer 错误
  在 hxcpp 后端生成**之前**全量出，日志末尾只剩 `Error: Library hxcpp is
  not installed`（Build failed）恰是「typer 已过」的标志。做法：复用
  `export/html5/haxe/debug.hxml` 的 classpath 与前三个 `--macro`
  （ExtraParams/DefineMacro/AssetsMacro），去掉 html5 专属 `-D`
  （lime-webgl/lime-dom/howlerjs/lime-html5 等）与 `-main ApplicationMain`，
  换 `-cpp /tmp/out` + 每包一条 `--macro include('包名', true)` 强制全量
  类型化（不依赖测试可达性）；src 根级散类用 `--macro include('', true,
  null, ['src'])`（4.3.6 实际签名 `include(pack, rec, ignore, classPaths,
  strict)`，classPaths 必须限定 `['src']`——不限会把 swf 库 classpath 根的
  SWFTimelineContainer 一起扫进来，它 import format 只供 tools 用，属扫描
  假信号）。防：改动凡涉 null/NaN/Int 判空，收工前跑这两条扫描（临时探针
  类实测植入错误能被抓到），别留给 android CI 才现形；修 bug 引入的**新**
  代码同样过一遍 CLAUDE.md 的静态目标清单。

## 2026-11 · #17（T1 场景运行器，write-tests 阶段）

- **utest 的 Assert 是「记录后继续」，不是抛错中断**：Assert.fail/notNull
  之后方法体会接着跑（test_issue17_deliverables_present 三条 FFF 全录即是
  证据）——「文件缺失」类加载助手在 Assert.fail 后必须 `return null`、调用
  方跟空值守卫 return；直接落到 File.getContent 会再抛一条，报告里一条
  失败变「失败 + ERROR」两行噪音（ScenarioRunnerContractTest.loadJson 的
  三段式写法）。防：写缺文件/缺字段路径时按「fail → return null → 守卫
  return」，别依赖 Assert 替你截断；另外消息字符串里要字面 `$xxx`（如
  PHP 的 `$mod_list`）得写 `$$xxx`，`$` 后跟标识符会被当成插值编译错。

## 2026-11 · #17（T1 场景运行器，implement 阶段）

- **mync 应答不带 place 回显会把操作落到别的地块**：真实 PHP 把请求的
  place 回显进应答的 farmlandIndex（farmlandstatus_planting.php:79、
  water :65、harvest :94-95），客户端按**应答的** farmlandIndex 落地
  （FarmLandModel.onOperateSuccessPlant 等）——nodeboot 的按 act fixture
  （farmlandIndex=0）应答「种 4 号地」的请求时把 land0 的 _step 重置成 0，
  后续 harvest 被 canHavest 的 _step==5 守卫静默吞掉（无请求、无报错）。
  修法：nodeboot 按 `mync-<mod>-<act>-<place>.json` → `mync-<mod>-<act>.
  json` → user_run 整包分档。防：给交互链换地块跑，先看应答 echo 的
  farmlandIndex 是不是「请求的 place」，不是就补 -<place> fixture。
- **POST body 的 farmKey/farmTime 随墙钟漂移，进基线 diff 必红**：
  farmTime=CommonData.serverTime 随经过秒数走（CommonData.hx:144-148，
  实测 user_run 恒 0、操作请求每秒+1），farmKey=MD5(farmTime+盐)
  （Main.hx:230-236）。同一次行为两次运行必不同；scenario.mjs 记录时剥
  这两个键后实测两次运行字节级一致。防：跨侧（Ruffle）基线导出剥同样的
  键；任何「录请求做对比」的格式都要先分清哪些参数是时间敏感的校验材料。
- **新工作区 nodeboot 永不就绪，先想 assets/legacy 同步**：assets/legacy/
  不入库（构建时 scripts/sync-legacy-assets.sh 同步），新克隆/新容器里
  没有——库全 404、`__openflFarmReady` 永不置位、30s 看门狗超时，日志里
  只见 `/lite_ui_v_0?数字` 一条 404。防：跑 nodeboot/scenario 前确认
  assets/legacy/ 已同步（本地跑一遍 sync 脚本即可，不违规）。


## 2026-11 · #18（farm-basic 收尾：qui 全量 + 管理器 + levelup + greensock core）

- **AS3 密封类 hasOwnProperty ≠ Reflect.hasField**：js/eval 的 hasField 只
  看实例物理字段，原型方法（TitleWindow.keyEnter，PopUpLayer.stageKeyUp
  按名调它）和 get/set 存取器属性（UIComponent.toolTip，ToolTipLayer 靠它
  显提示）都查不到——照字面译 hasField 会把这两条行为链静默断掉（编译绿、
  门禁也未必立刻红）。防：`x.hasOwnProperty("名")` 译成 `As3.hasProp`
  （hasField || field != null，走原型链与属性 getter），见 shim/As3.hx 头注。
- **swf 符号「大写包段.小写类段」的注册键要 @:native**：`Update.bigPanel`
  这类符号名不能照原路径声明——Haxe 点路径把大写开头段解析为模块名
  （monthend-package-lowercase deviations 同因，import 直接 Type not
  found）。修法：root 包建大写类 + `@:native("Update.bigPanel")` 改运行时
  注册键，`Utils.getMaterial` 反射字符串一字不动（UpdateBigPanel.hx 等 7 枚）。
- **EffectManager 的 In/Out 第 4 参是 `...rest` 不是单参**：ToolTipLayer
  `EffectManager.In(this,tip,cb,this._toolTip)` 是「回调参数表」——stub 侧
  收成 `[this._toolTip]`，PopUpLayer 同（`[param1]`）；真身翻译时 rest →
  `args:Array<Dynamic>` 按 CLAUDE.md ...rest 规则。
- **openfl 泛型 addEventListener 可以用 Dynamic 覆写**：ExtLoader 转发
  COMPLETE/PROGRESS 到 contentLoaderInfo 的 `override public function
  addEventListener(param1:String, param2:Dynamic, ...)` —— openfl 的
  `<T>(EventType<T>, T->Void)` 与 Dynamic 双向统一，直接编过；别为覆写
  改调用方类型。
- **swf 符号具名子件的写路径 = As3.childOf + Reflect.setProperty**：
  `panelUI["levelTxt"].htmlText = ...` 在 openfl 动画运行时里子件不是实例
  字段（#8 Crop step1 先例），childOf（字段→getChildByName）取；写必须走
  setProperty，js 裸 Dynamic 写只落影子字段。`.y +=` 这类读写混合按
  getProperty + setProperty 两步拆（LevelUpWindow.createPanel 全套）。
- **include 全量 cpp typer 扫描是唯一真实编译检查，html5 绿不算数**：
  本轮新译的窗口链/levelup 类全都 dce 不可达（ApplicationMain 起没有任何
  引用链），`openfl build html5` 根本不解析这些文件——8 处硬错（protected
  关键字、无父类 super()、Float→Int、extends abstract、cast 带参、
  openfl 缺常量）在 html5 全绿的情况下躺着过了全部门禁，靠 #15 的
  `--macro include("", true, [...], ["src"])` + `-cpp` 扫描才暴露。
  新译代码即使全部门禁绿也要跑一遍扫描；只到 `Library hxcpp is not
  installed` 即算通过。两个配置坑：小写模块名（mx_internal.hx，对应关系
  钉死文件名）解析器拒载，必须进 include 的 exclude 表；include 的
  classPaths 参数必须限 `["src"]`，否则 swf 库 classpath 根下的
  SWFTimelineContainer 等也进扫描报无关错。
- **unsafe cast 的目标类型参数必须是 Dynamic**：`cast(x, Array<Seed>)`
  恒红（源是 Dynamic 也救不了），只有 `Array<Dynamic>` 合法。带类型的
  AS3 for-each 照 `for (_loc3_:Seed in cast(x, Array<Dynamic>))` 译——
  预声明的循环变量保 Seed，Dynamic 迭代元素隐式统一（Player.hx:123 起
  全仓 cast 到 Array<Dynamic> 是唯一合法形态）。
- **openfl 的 ByteArray 是 abstract，不能 extends**：openfl 9 起
  `abstract ByteArray(ByteArrayData)`，AS3 的 `extends ByteArray` 直接
  "Should extend by using a class"。改继承底层运行时类 ByteArrayData
  （模块子类型，全限定 `openfl.utils.ByteArray.ByteArrayData`，裸
  `openfl.utils.ByteArrayData` Type not found）——abstract 对 ByteArrayData
  双向隐式转换，IS-A 语义不破（mx/core/ByteArrayAsset.hx PORT-NOTE）。
- **FFDec 在无父类构造器里也照印 super()，Haxe 无父类不可调**：
  WindowLabelMaker/WindowTabBarMaker（以及 PluginProxy）原样照抄的
  `super();` 编译红——AS3 一切类默认继承 Object 所以反编译里句句有；Haxe
  无 extends 的类直接删掉这行，其余构造体照抄。
- **openfl/events/IOErrorEvent 缺 DISK/NETWORK/VERIFY_ERROR 常量**：
  openfl 源码里这三行被注释掉（IOErrorEvent.hx:20,76,77）不可引用；
  Flash Player 原值是普通字符串（"diskError"/"networkError"/"verifyError"），
  照值内联 + 注明出处（ExtLoader.addEventListener PORT-NOTE）。
- **AS3 splice(pos, 0, item) 的零删插入 = Haxe Array.insert**：
  Haxe 的 splice(pos, len) 没有 ...values 插入参，照抄 arity 直接
  "Too many arguments"；删除用途照抄可用（全仓 7 处先例），插入用途换
  insert（TileBase.addElementAt）。

## 2026-11 · #18（实现返工：review 驳回六项 + 扫尾）

- **Haxe 方法全虚，原版的 `super.init()` 必须照写**：BaseWindow.as:47 的
  `super.init()` 是非虚直落（Container→UIComponent：setSkin/setSize/
  setEnabled、_inited=true）；Haxe 里 `this.init()` 虚分派到最派生覆写
  （LevelAndExperience.init 不调 super），基类初始化整段静默丢失。防：
  AS3 源里的 `super.方法()` 一律照抄成 `super.方法()`，别顺手改
  this.；Haxe 的 private 对子类可见、super 可调，编得过。
- **AS3 String + Number 是拼接不是加**：TileList.as:124
  `_data[_loc2_ + _loc3_ * maxGrop]`，for-in 键是 String，"1"+12 得
  "112"——字符串键取 AS3 Array：正则数字串（无前导零、≤2^32-2）按下标
  （多数错位）、"00"/"012" 这类非正则串得 undefined，原版绑定本来就是
  坏的。防：`shim/As3.arrayIndex` 复刻该取值（表驱动测试
  As3ArrayIndexTest 钉死）；「顺手修好原版 bug」必须停在 deviations
  （人维护），代码照抄坏语义。
- **openfl Dictionary 的 multiType 按 K 解析，`Dictionary<Dynamic,…>` 是
  StringMap**：K=Dynamic 撞上 @:to 首选 `toStringMap<K:String>`，对象键
  `.set` 在 eval 直接抛 "Unexpected value VObject(...), expected string"
  （实测）；AS3 Dictionary 混键种一表（ViewStack.as:25 按 name 字符串键
  读、:28 按对象键写——读门恒过、去重从未生效，照译死门）要用
  `Dictionary<{}, Bool>`（解析成 ObjectMap，String 可与 {} 统一，
  字符串读恒 miss=AS3 的 undefined）。
- **AS3 Number 字段默认 NaN，Haxe Float 零初始化成 0.0**：
  TweenCore.as:44 `_pauseTime:Number` 未暂停时是 NaN，setTotalTime:274 的
  `Boolean(x) || x == 0` 门靠它才走 timeline 分支；零初始化误命中 `== 0`
  分支。防：AS3 里没赋初值的 Number 字段，Haxe 侧显式 `= Math.NaN`
  （局部变量同理；NaN 默认**参**仍禁，见 ScrollEvent 先例）。
- **AS3 `final class` 的 final 要照写**：Haxe 类不写 extends 也能被继承，
  「不写 extends 即 final 语义近似」是错觉（Payment 被驳）；公共 API
  契约差一词，照抄 `final class`。
- **`Utils.getMaterial(x) as T` 别译成双调**：条件/取值各调一次会构造两份
  符号壳（LevelUpWindow×5、BaseTileItem×2、SeedItemRender、LandRender 均
  踩过）——取一次进局部再 `Std.isOfType` 门 + 直取；`as T` 的失配落
  null 语义也在这一步保住（ContentWindow 的 `as String` 曾被丢，
  非 String 值原版落 null、端口裸透传）。

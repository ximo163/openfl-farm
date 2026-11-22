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

## 2026-11 · #10（V4 真机）

- **素材剪辑上的动态属性，静态目标（cpp）不能裸写**：原版 AS3 在 swf 素材
  剪辑上随手挂属性（`clip.tipText = ...`、`dogTip.effect = Move`）。翻译后
  素材剪辑是编译类实例（swf.exporters.animate.*）——html5/JS 上 Dynamic
  裸写落自有字段照常跑，android（cpp）上对不存在的字段写入报
  `Invalid field:tipText`（真机 logcat 实证：3 次后进程死亡），写入丢弃后
  读取 null 再崩。防：挂动态属性一律走 `src/shim/ClipProps.hx` 侧表
  （读写同通道、所有目标同一语义，`ClipPropsTest` 在 eval 单测里兜着）；
  事件处理器里读挂过的属性同样走 ClipProps.get。html5 绿≠真机绿，这类差异
  只在设备上现形——真机 logcat 的 `trace` 标签带 Haxe 文件:行，直接指到
  死点。
- **dogTip.tipText 这类「剪辑.名字」其实是具名子实例**：AS3 剪辑点取按
  子名解析到时间轴上的实例（`.htmlText` 是 TextField 证据），不是动态
  字段——hasField 双查在**所有**目标恒跳过（html5 也一直没文字，隐性
  退化没人发现）。防：剪辑点取 + 后续真属性操作（htmlText/text）的组合，
  按「具名子实例」处理，走 `As3.childOf`（先反射后 getChildByName）。
- **AS3 有、openfl 没有的属性，Dynamic 写同样是 Invalid field**：第二处
  真机闪退是 `Invalid field:enabled`（NavigationBar.currentUserChanged 的
  `m_buttons[NAV_MC].enabled`）——AS3 MovieClip.enabled 是按钮态真属性，
  openfl MovieClip 没实现。判别法：翻 openfl API 有没有这个属性；有 →
  cast 回真类型写（FarmLandController VIP 窗口的 tfHrs/tfQD/tf1/tfSum/
  btnOK 一族同批加固），没有 → ClipProps 侧表 + deviations.json 登记
  （movieclip-enabled-side-table）。防：真机修闪退别只修报出来的那一个
  字段，grep 同函数/同路径的 Dynamic 裸写一次清完，否则每轮 APK 10 分钟
  换一个字段名。
- **照译的 `stage.scaleMode = NO_SCALE` 在 Android 上是拆掉播放器盒子，
  不是 no-op**：原版 Flash 播放器盒子被 nc.htm 钉死在 860×500，NO_SCALE
  的「窗口变了不重缩放」从不发生、舞台读数恒 860×500；openfl 上 FarmLite
  构造器把 NO_SCALE 照译上去后，Android 全屏 surface（2340×1080）成为
  舞台尺寸——内容原尺寸锚左上，ToolBar/NavigationBar/FarmStage 等一切
  按 stageWidth/stageHeight 定位的 UI 全散（真机第三轮实证）。修法在宿主：
  `shim.PlayerBox.install()` 于 super() 后重映射视口（终态＝铺满全屏
  1024×自适应高，所有者 2026-11-21 拍板，deviations.json
  android-fullbleed-viewport），读舞台尺寸的翻译代码零改动。防：原版依赖
  播放器环境兜住的行为（盒子尺寸/对齐/缩放），先想它在 openfl 各目标
  的等价物，缺的归 Main.hx 宿主或 src/shim/ 补，别让照译代码背锅。
- **Android 上 openfl 文本是单字体整段渲染、无逐字形回退，设备字体请求
  全部落空**：原版动态文本用设备字体（Verdana/SimSun/微软雅黑），浏览器
  逐字形回退到系统 CJK 字体所以有汉字；openfl native 的
  TextEngine.getFontInstance 找不到名字就落 Android _serif 默认
  （DroidSerif，无 CJK）→ 汉字全部空白（#10 真机第四轮实证）。修法
  `shim.DeviceFonts`：一个真系统 CJK 字体（lime native 每实例 memcpy
  一份字体字节，**多实例＝多份 5-20MB**，必须共享 src face）+ 别名挂
  请求名与 getDefaultFont 的路径串（findFont 两类匹配都覆盖）。防：
  凡「html5 绿、真机汉字空」类文字问题先查 TextEngine 字体解析链，别猜
  翻译缺漏；加字体别名先看 lime Font.cpp 的拷贝行为再定实例数。

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
- **AS3 String + Number 是拼接不是加**：TileList.as:134
  `_data[_loc2_ + _loc3_ * maxGrop]`，for-in 键是 String，"1"+12 得
  "112"——字符串键取 AS3 Array：正则数字串（无前导零、≤2^32-2）按下标
  （多数错位）、"00"/"012" 这类非正则串得 undefined，原版绑定本来就是
  坏的。防：`shim/As3.arrayIndex` 复刻该取值（表驱动测试
  test/shim/As3ArrayIndexTest.hx 钉死；TestMain.hx 是 append-only、
  implement 阶段碰不得，注册行已由 write-tests 轮补进 TestMain.hx
  issue #18 块（review-impl 驳回点），`haxe test.hxml` 编译并跑绿全 21 断言）；
  「顺手修好原版 bug」必须停在 deviations
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

## 2026-11 · #18（implement attempt 2：main 合并后受保护文件回基线）

- **orchestrator 把 main 并进任务分支后，受保护/append-only 文件相对本
  阶段基线会出现「不是我写的 diff」**：34166ac3（merge 2e0b4a1e ⊕ main
  e43a669f）把 main 的 TestMain.hx 注册块（#10 ClipPropsTest 两行）带进
  工作树，stage 门禁按「本阶段基线（write-tests commit）→ 工作树」判
  append-only 违规，整轮 attempt 在任何检查前被拒——diff 来源是 merge
  也照样拒。恢复：驳回信点名哪个文件就用信里给的基线 commit 精确恢复
  （`git checkout <基线> -- <file>`），恢复完该文件的其余内容（来自
  main 的 CLAUDE.md/spec 等）**不要顺手一起恢复**——信没点名的动了
  反而是新违规。本轮恢复后 TestMain.hx 少了 main 的 ClipPropsTest 注册
  行，`haxe test.hxml` 只编 TestMain 可达闭包、未注册的 ClipPropsTest.hx
  不参编，全绿不受影响；回 main 的最终合并由 orchestrator/人解决。
- **merge 轮开工先自查受保护文件对基线的 diff**（`git diff <基线> --
  test/ Project.xml *.hxml`），在写任何代码前把点名文件恢复掉，别把
  一整轮花在会被预检拒掉的树上。

## 2026-11 · #18（write-tests 3/4 驳回后的 implement 返工：数字 id 形状是承重的）

- **fixture 的字段形状和值一样是测试对象**：nc_data.php 的作物 id 是 JSON
  **数字**（:6020 `"id": 1`），早期 fixture 钉成字符串，恰好绕开两处 AS3
  数字↔字符串隐式转换（Settings.as:390 松等、LevelUpModel.as:105 String
  形参收数字实参的隐式强转），exclude_seeds 过滤静默失效也测不出来——
  review-tests 连驳两轮才现形。「fixture 从真实载荷抽、改内容不可」对
  **形状**同样成立：数字就钉数字。防：写用例前先到拼 JSON 的 PHP/配置
  里确认字面形状，别按 Haxe 类型的直觉起 fixture。
- **AS3 松等的 String 一侧可以是形参/变量，不止字面量**：lessons #8 的
  防线（`== "字面量"` 一律 eqString）grep 不出这一批——Settings 四个
  getXxxByID（fish_info/secondList/item_info/crops，Settings.as:104/162/
  238/:390）与 FarmLiteModel.as:383 都是 `_loc3_["id"] == param1`，param1
  是 String 变量。本轮五个点全改 eqString。防：Dynamic 与 String 的比较
  一律 eqString，右侧不论是字面量还是变量。
- **数字实参 → String 形参的隐式强转要显式复刻**：原版
  `isNotShow(_loc3_["id"])` 把数字 256 强转 "256" 才命中 exclude_seeds；
  Haxe 裸传数字时 indexOf 严格等值恒 miss（js/eval 不报错、静默失效）。
  防：传参处显式 `Std.string(...)` + PORT-NOTE。
- **同形状全库扫尾**：`grep 'Reflect.field(...) == 变量'` 收尾——
  PopUpManager.hx:68/99 是对象引用比较（AS3/AS3 语义相同，不改）；
  ConfigMerger.hx:161 是第三种变体 `Dynamic == Dynamic`（两表 id 双数字/
  双字符串形状不一致时 AS3 松等命中、严格 miss 会把本该合并的条目
  当新条目追加），无测试钉住且在 #7 的合并中枢路径上，未动、列为
  deviations 候选待人裁决。

## 2026-11 · #19（messages 两族：Master2 侧翻译 + cpp typer 全量扫描）

- **cpp typer 上 Dynamic 的一切字符串键下标都编不过，不止中文键**：#8 只
  见到 eval 对非标识符键报 "String should be Int"，本轮 cpp typer（lessons
  #18 的 include 扫）对 `param1["code"]`、`mainData.host["uId"]`、
  `this._products[param1]`（**变量**键也一样）全部红——Haxe 把 Dynamic 的
  `[]` 当数组访问。防：`x["k"]` 一律 Reflect.field/setField，变量键
  Std.string() 后同样走 Reflect；收工前对全改动跑一遍 include 扫，别等
  android CI。
- **批量 sed/python 重写后必须重读被改文件**：把 `x["k"]` 批量改 Reflect 时，
  对象字面量的收尾 `});` 被改成 `};`、`var _loc6_` 声明两遍——typer 一下
  现形，但更早靠肉眼重读也行。防：批量重写只做机械等价替换，改完先
  `haxe --macro include` 扫或至少重读 diff 里每个表达式级改动。
- **FFDec 的构造器叫 `public function ClassName()`，是合法方法不是 new**：
  Haxe 里同名方法照编过，错误在**别处**才冒头（"Cannot call super
  constructor outside class constructor"、`new X()` 不存在）。防：翻译新
  文件时第一个动作就是把 ctor 改名 `new()`，全文件 grep
  `function 类名(` 收尾。
- **子类重声明继承字段直接红，改 override 访问器**：openfl 的
  width/height、基类已声明的 `_data`——Haxe 不允许 Redefinition。防：子类
  只 override `get_/set_` 访问器或直接用继承字段；stub 基类先想好哪些字段
  子类要碰。
- **接口的属性访问器实现必须 public，基类升可见性会传染给全部 override**：
  `implements ITip`（接口里 `function get_tX():Int` 公开签名）配
  `private function get_tX` 报 "Field … should be public as requested by …"；
  把基类访问器改 public 后，MouseTip/HouseTip/HistoryTip/HistoryItem 的
  `override private` 全部要跟改 `override public`（override 不许降可见性）。
  防：凡 implements 的类，访问器直接写 public。
- **单例 ctor 的 super() 必须全路径先调**：AS3 惯用
  `if(instance==null){super();return;} throw new Error(...)` 的 throw 路径
  不调 super，Haxe/cpp 编不过。MaterialLib 原文就是 super 前置可直接照抄；
  ViewControl/MData 原文守卫内 super，重排成 `super(); if(instance==null)
  return; throw` 加 PORT-NOTE（EventDispatcher ctor 无副作用，等价）。
- **Haxe 包段首字母不能大写**：原版包 `mc.view.main.WindowControl` 照搬
  编不过（"Unexpected WindowControl"）——目录/包改 `windowControl`，类名
  不变，头注 PORT-NOTE(命名) + deviations 候选。
- **注释文本里的 `*/` 会提前关掉 doc 注释**：写 "CHILD_*/dataList" 这种
  含星-斜杠的说明，后面的内容被当代码。防：注释里用全角／或改写措辞。
- **Master2 引用的类可能根本不在 Master2 反编译里——mcloader 同域共享**：
  `mc.control.Version`、`common.{INI,LocalData,MaterialLib}`、
  `com.qzone.corelib.js.JSProxy` 只在 `mcloader_v_53/scripts/`（预加载器
  与主 swf 共享应用域）。防：Master2 缺类先 `rg` 整个 `legacy/decompiled/`
  五棵树；注意既有 `src/common/CommonData.hx` 就是 mcloader 的那份，
  直接复用别重译。
- **AS3 把 Number 隐式截断进 int 的点要显式 Std.int**：
  `var _loc3_:int = getStringWidth(...)`（返回 Number）在 AS3 截断，
  Haxe Float→Int 编译红。防：赋值处 Std.int()，别改声明类型（原版就是
  int 收 Number）。同族：AS3 `int.toString()` 在 Haxe Int 上没有该字段
  （js 偶然可用、cpp typer 红）→ Std.string。

## 2026-11 · #19（implement attempt 1 驳回复工：崩溃语义/int 回绕/undefined 强制）

- **RegExp.exec 无匹配是崩溃路径，垫 match() 守卫=改行为**：原文
  `_loc17_.exec(_loc3_)[1]` 无匹配时 exec 得 null、null[1] 抛 TypeError
  #1010，从 genMsg 一路中断整页 dataList 渲染（两族 ProfileLog 同病）；
  attempt 1 垫了 `match() ? matched(1) : null` 守卫，渲染出
  `event:qq,null` 死链还不留痕。照译：match 失败抛
  `openfl.errors.TypeError("Error #1010: …")` + PORT-NOTE（构造器只收
  message，见下条）。防：译
  `exec(...)[n]` 前先问无匹配分支原文是什么行为，崩溃也是行为。
- **`int` 局部存 |Δms| 的 ToInt32 回绕是视觉语义，裸 Std.int 会把原版 bug
  「修好」**：compareDate `var _loc3_:int = Math.abs(Δms)` 在 AS3 按 2^32
  回绕——约 49.7-52.6 天的流水回绕成 0/1/2 天、被错标成今天/昨天/前天；
  Haxe Int 在 js/eval 是双精度不回绕，`Std.int` 或 Float 声明都让老流水
  显示真实日期。照抄走 `As3.int32`（两族六处 int 形；Master2 ProfileMsg
  是 Number 形不回绕，别一刀切）。防：`var _locN_:int = <Number 表达式>`
  一律过 int32，先看值的量级会不会越 2^31（毫秒差最会越）。
- **`as String` 得 null，垫 "" 是吞崩溃**：main3 ProfileLog 的
  `_loc3_ = param1["cn"] as String` 非 String 落 null——后续 `.indexOf`
  在 null 上抛、拼串印 "null"；attempt 1 用 isOfType 门 + "" 兜底静默改宽。
  照译：isOfType 门 + null（lessons #7 的 as 语义条在这又适用一次）。
- **AS3 键缺位是 undefined、显式 null 是 null，TextField 印的是
  "undefined"/"null" 两回事**：HistoryTip 的 null 数据路径（param1=""
  后 `""["cName"]`）原文把 "undefined" 印进 TextField；Haxe
  Reflect.field 都落 null，openfl set_text(null) 抛 #2007。复刻走
  `As3.stringField`（hasField 区分两形态）。防：`text = obj["k"]` 通道
  一律 stringField，别裸 Reflect.field。
- **stub 写出来的常量/访问器逐字镜像，不发明值也不发明 setter**：
  ConfirmWindow stub 把原文 `height=320`/`getClass("AlertWindowTitle")`/
  `"ConfirmWindow"` 写成 `ConfirmWindowTitle`/缺 height/`"confirm"`；
  MainData stub 给四个原文只读 getter（me/currentUserUin/currentUserId/
  getHostId，MainData.as:1140/738/825/1268）长了 (get, set)。stub 只免
  **方法体**，写了常量就照抄原文常量，getter-only 就 `(get, never)`
  （参照 MData.hx）。防：stub 的每一行非空体都要能指到原文行号。
- **同值局部照抄两份，别「优化」合并**：原文 `_loc4_/_loc5_` 两个 opuin
  局部各司其职（好友表键 vs 链接 href），attempt 1 给 _loc5_ 垫 ""——
  href 变 `event:,名字` 丢 QQ 号、parseInt("")=0 少 "(QQ:…)" 段。防：FFDec
  的 _locN_ 是位置命名，同值不同局部必有其用途差异，逐行对号。
- **`var x:uint = parseInt(...)` 按 Number 持有再比 `> 0`**：cpp 的 Int 会
  把 ≥2^31 的 QQ 号回绕成负（uint 是 ToUint32 保持正值显示），NaN>0 恒假
  同 uint(NaN)=0——`Float` 持有 + `> 0` 判 + 字符串拼接在各目标最接近。
- **openfl 错误类构造器未必带 flash 的 id 形参**：`openfl.errors.TypeError`
  只有 `new(message:String="")`，flash.errors.TypeError 的第二形参 id 在
  openfl 没落点——两参形态 html5 全量编译当场红（"Too many arguments"，
  eval/html5 容忍的语义坑不同，这是硬编译错）。id 并进消息文本即可
  （"#1010" 本就在串里，errorID 无消费方）。防：`new openfl.errors.*` 前先
  看本机 `openfl/<版本>/src/openfl/errors/` 的构造器签名，别按 flash
  文档默写。

## 2026-11 · #20（friends 模块）

- **CWS swf 的二进制 grep 查不到符号，符号清单只认 dump_swf.php**：部署包
  swf 全是 zlib 压缩的 CWS——`grep -a 符号名 *.swf` 连导出类名的**已存在**
  符号都打不中（本仓 farmui 全库实测，Sort0 这种确定存在的也 miss）。#20
  前段曾据「二进制搜不到」误判 Sort1/2/3 不在部署包、险些漏掉三枚等级底图
  垫片；`php tools/dump_swf.php`（先解压再吐 SymbolClass/tag 表）重核才
  纠正。防：涉「某符号在不在 swf 里」一律走 dump_swf.php，二进制 grep 的
  结果只能当「没找到」，不能当「不存在」。
- **SymbolClass 绑 BitmapData 的链接位图有既定垫片形态**：AS3 对链接位图
  `new Sort0(24,24)` 的宽高参数被 Flash 无视、实例即图像自身像素——Haxe 侧
  垫片 `extends BitmapData` + `super(w,h,true,0)`（底必须 0 全透明，落
  AS3 BitmapData 默认 0xFFFFFFFF 白就是视觉差）+ `SymbolClass.bindBitmap`
  从 `Assets.getBitmapData("库:名")` copyPixels；解析链（openfl
  Assets.getBitmapData → AnimateLibrary bitmapClassNames，导出器对
  DefineBits 类符号记 data2.className）在 SymbolClass.hx bindBitmap 头注
  里钉死。preload 库（farmui_full_v_40）构造即得像素；非 preload 库走
  bind 的按需 loadLibrary 窗口，与 MovieClip 垫片同源。防：再译「反射 new
  位图类」先照此形态，别在调用方改尺寸/改白底。
- **Haxe 的期望类型会压进三元表达式，`Int > (c ? 0 : floatOf())` 把两支
  都逼成 Int**：比较左是 Int 时右操作数按 Int 期望传播——三元里 `0` 过了、
  floatOf 支直接红「Float should be Int」（FriendItemRender:338，写成
  `0.0` 也救不了：两支一起被压）。修法：三元先落进显式 `Float` 局部再比
  （`var f:Float = c ? 0 : As3.floatOf(x); if (i > f)`）。防：`Int/Float 与
  「条件给值」直接比`的写法一律先落局部；编译红指进三元时先想期望类型
  传播，不是类型真错。
- **NEEDS-TESTS 必须是最终回复的最后一行，路由只认这一行**：#20 attempt 1
  把三处测试矛盾的完整分析写进了总结正文，但没有以 `NEEDS-TESTS: …` 单行
  收尾——orchestrator 判「verification failed (test)」按普通失败原样重跑了
  implement（attempt 2 重复得出同结论，白耗一轮）。正文分析再充分也不触发
  回 write-tests 的路由。防：判明测试错，最后一行单独输出
  `NEEDS-TESTS: <哪个测试错在哪里，legacy 的出处>`，其后不再有任何文字。
- **implement 与 approved 测试期望冲突的裁决链**：先 diff 两份反编译
  （`xfl/` vs `scripts/`，同源 FFDec 渲染一致可排除单份渲染错），再 retarget
  `tools/DumpAbcMethod.hx`（改 TARGET_METHODS）读部署 swf 的 ABC——分支
  跳转、break、就地 sort 这类控制流/引用事实字节码一锤定音，比反编译文本
  互证强。#20 的 :379/:845/:1149 三处走完这条链才 NEEDS-TESTS；同测试文件
  **自相矛盾**（:171 断言 m_sortField="exp"、:377 断言回绕页=1，而 :379/
  :1149 的期望与之冲突）是测试笔误的强信号。防：别为让错测试变绿改实现
  ——那是「针对测试写特判」，还会红掉同文件里对照 legacy 的其他断言。
- **`var n:int = Number表达式` 的截断会透过 Boolean 门显形，int 声明别
  「简化」成 Float**：openByFlashVar（FriendsModel.as:1445-1466）的
  `_loc2_ = parseInt(s)/10%10` 后接 `!Boolean(_loc2_)`——implement
  attempt 3 把 `_loc2_` 译成 Float，useflag="11111101" 的十位在 Number
  下是 0.1（真值、放行），原版 convert_i 截断成 0（禁用）；review 用
  `tools/DumpAbcMethod.hx` 读部署 swf 的 ABC（OToInt）核实。属上文
  「int 收 Number 要显式截断」一族，但这次的坑更隐蔽：截断语义只藏在
  int 声明里，反编译文本的比较链看着无害，固定部署参数
  （useflag="11111111"）又把分支掩盖成不可达。防：int 声明照抄 +
  `As3.intOf` 包赋值；被部署常量掩盖的分支按声明/字节码核，别按
  「跑起来对」放行。
- **`!= false` 与 `>= 0` 的宽松比较要按 ECMA 分运算复刻，floatOf 不是
  万能答案**：宽松等价（`_loc1_ != false`，FriendsModel.forbidden
  :1471）先 ToNumber——`""`/纯空白按 Number("")==0 与 false 判等（即
  不禁止），非数字文案 NaN ≠ 0（禁止）；而 Haxe 的 `As3.floatOf` 是
  parseFloat 语义（""/空白→NaN），须补 `StringTools.trim(Std.string(x))
  != ""`（FriendsView.onCollapseView :524 的既有形态）。关系比较
  （`data["leftQuota"] >= 0`，FriendsController.onUpdataBack）对显式
  JSON null 是 ToNumber(null)=0（成立）、键缺位是 undefined→NaN（恒
  假），宽松等价里 null==0 规范又恰为 false——同一 if 内外两层的 null
  语义相反，不能一个 floatOf 包打；Haxe 里缺位与显式 null 都落 null，
  用 `As3.hasProp` 区分后只修关系层。防：写完 PORT-NOTE 回读代码核对
  （attempt 3 的 note 语义写对、代码反着做，note 成了误导源）；同形态
  先 rg 同模块已有译法再动笔。

## 2026-11 · #21（tasks 模块：新手任务/欢迎引导）

- **`super.方法` 取不了闭包（Cannot create closure on super method）**：
  AS3 里 `addEventListener(CLICK, super.confirmButtonClick)` 合法——闭包
  绑定的是父类实现；Haxe 直接编译红。本类**没有覆写**该方法时 `this.`
  与 `super.` 是同一实现，`this.confirmButtonClick` 等价替换 + PORT-NOTE
  即可（WelcomeTaskWindow.init）。已覆写过的场景没有等价写法：抽一个
  `private function onXxx()` 成员转发再挂。防：rg `super\.` 后跟非 `(` 的
  形态（作为值传递）都要处理，别只盯调用。
- **AS3 private 字段同名异型遮蔽 = 两个独立槽，改名拆槽而不是 override**：
  WelcomeTaskWindow 声明 `_mode:int`，基类 BaseWindow 已有
  `_mode:Boolean`——AS3 private 不进子类作用域，两个 `_mode` 互不相干
  （本类从未碰基类 mode 属性的存储位）；Haxe 同名异型重定义直接红，而
  「改 override 访问器」（#18 的 Redefinition 条）在这不适用：两者语义
  无关、没有可统一的属性。修法：子类槽改名（`m_mode`）+
  `PORT-NOTE(shadow)`，读写点与原类一一对应。防：给 stub 基类补字段前
  先 rg 全部子类的同名字段；翻译时撞红先分清「同一状态量的两份声明」
  （override/accessor 路）还是「碰巧同名的两个槽」（改名路）。
- **utest 的 setup() 按**测试函数**跑，不按循环轮次跑**：一个测试函数
  内多轮 `for (i in …)` 共享同一份 setup 产物和**单例状态**——
  WelcomeModelTest 在轮内 `visitFriendFarm()` 改写
  `Session.getInstance().currentUser` 指望「下一轮 setup 复原」，实际轮
  间泄漏，后 3 轮的断言全在错误的 Session 极性下跑（#21 两例
  NEEDS-TESTS 之一）。防：测试里动单例（Session/Settings）的，要么轮内
  显式复原，要么拆成独立测试函数；write-tests 阶段对「好友/自己农场」
  这类极性翻转的用例，逐轮心算一遍 Session 状态再定期望值。
- **LocalSwfLoader 补了显示挂载（content 进显示列表）**：原版 Flash 的
  `loader.content` 恒为 loader 的唯一子件、Loader 本身被 addChild 时引导
  内容跟着可见；shim 早期只直设 `content` 字段（RSMManager 等只读字段的
  调用方够用），#21 的 help.swf 是首个把 **loader 本身挂进显示列表**的
  调用方，不 attach 内容就整屏空白。修法：onComplete 里把挂载+字段补齐
  +COMPLETE 派发整体交给 openfl 原生完成路径 `Loader_onComplete`
  （经 `@:access` 调私有成员，见下条）；直接照抄原生路径的
  `super.addChildAt(content, 0)` 是**错的**——super 只上溯一层。
  防：新的「可见 Loader」调用方（引导/全屏装饰类）直接用 LocalSwfLoader
  即可；再改这个 shim 时记得显示挂载是承重行为（assets.md 已补注）。
- **super 只上溯一层，Loader 子类照抄原生路径的 super 调用会命中
  父类自己的覆写**：openfl 原生 `Loader_onComplete`（Loader.hx content
  装载段）内部 `super.addChildAt(content, 0)` 之所以合法，是它从 **Loader
  自己**出发、super 落到 DisplayObjectContainer；从子类 LocalSwfLoader
  调 `super.addChildAt` 落到的是 **Loader 自己的 #2069 覆写**（Flash
  同款禁令：Loader 不许 addChild）——#21 attempt 1 就这么写的，本地
  html5 全量编译绿、单测绿（不跑显示链），CI web-smoke 的
  `pageerror: openfl_errors_Error` 一条红：启动链第一个走 LocalSwfLoader
  的库装载就把 ready 标记卡死。Haxe 没有 super.super，也没有任何公开口
  绕过覆写；等价口是 `@:access(openfl.display.Loader)` 调私有
  `Loader_onComplete`——它的字段补齐（content/contentLoaderInfo.content/
  宽高）/挂载/COMPLETE 派发顺序即原生语义，各目标通用（Loader.content 等
  都是 `(default, null)` 物理字段，Reflect 直写本来也通，但原生路径连
  手补的顺序风险一并免了）。
  版本耦合：Loader_onComplete 是 openfl 9.5.2 的私有函数名，升版改名会
  编译红在 LocalSwfLoader.hx（shim 定位就是版本胶水）。
  防：**给 openfl 类写子类时想复用其内部行为，先看该行为的方法体在哪个
  类层**——覆写墙（Stage 的 IllegalOperationError、Loader 的 #2069 这类
  Flash 语义禁令）只拦子类入口，openfl 自己的内部调用不受拦；子类复用
  走 @:access 进私有函数，别照抄 super 形态。
- **CI pageerror 对 Haxe 抛出的 openfl Error 只剩类名，消息和栈都不可见
  ——先 nodeboot 复现拿全栈**：`openfl.errors.Error extends
  haxe.Exception`，浏览器里不是原生 JS Error——smoke.mjs 的
  `e.stack ? e.stack : String(e)` 落到 String(e) 只打出
  `openfl_errors_Error`（没消息、没栈、没帧）；同一错误在 nodeboot 的
  uncaughtException 里 `e.stack` 是真的，打出 `Error #2069: …` + 全帧。
  #21 attempt 2 的 CI 日志就只有一行类名，凭它只能知道「openfl Error 族」，
  定位靠 nodeboot 同路径复现（30 秒内拿到消息+帧）。防：CI 红在
  `pageerror: openfl_errors_XXX` 时按类名圈范围（rg openfl 源+src/ 的
  `new XXX`），然后 nodeboot 跑启动链看完整栈，别按类名盲猜改代码。
- **eval 的 `openfl.Lib.getTimer()` 是「纪元毫秒 Int32 回绕值」，随墙钟
  漂移变号——跨时钟播种的测试是 49.7 天定时炸弹**：lime 在 eval/sys 上
  是 `Std.int(Sys.time()*1000)`（Sys.time=纪元秒，探针实测），回绕值在
  2026-11-21 ~21:25 UTC 越过 2^32 边界由负转正（As3.hx PORT-NOTE 记的
  「为负」就是负半周）。`HttpOperationExTest` 用它播种 `m_timerValue`、
  实现读 `shim.As3.getTimer()`（毫秒自首调，恒小正值），两钟零点无关：
  负半周播种恒满足超时比较（#7 批准时全绿），正半周恒不满足（#21 收工
  时同树连红，前后两轮绿的分界恰是越界时刻）。同钟播种的 probe 证明
  实现照发超时 FAULT——移植无错，测试混了两个钟域，和 legacy
  （HttpOperationEx.as:71/:108 单一 flash.utils.getTimer 种读同钟）对
  不上。防：eval 测试里一切时间戳只用 `shim.As3.getTimer` 一个域种/读；
  `haxe test.hxml` 无预兆由绿转红且只红计时类用例时，先探针两钟值再查
  代码（修法在测试 import 行，write-tests 阶段的事）。

## 2026-11 · #29（write-tests：模块桩清尾）

- **throw stub 不能落在 web-smoke 启动路径上——失败杠杆选 smoke 不经过
  的面**：FarmApplication.startup 在 web-smoke 里 500ms 派发
  MSG_LOAD_WATER → `ModuleWater.onModuleLoadSuccess` 原地执行，哪怕类
  还是 stub；write-tests 若顺手给 onModuleLoadSuccess 写 throw stub，
  write-tests 与 implement 两个 commit 之间 CI web-smoke 必挂
  pageerror。防：给「模块壳/启动链邻接」类扩被测面前先过一遍 smoke
  启动序列（architecture/startup.md 的 loadLater/直接 load 清单），
  smoke 会路过的方法保持基类 no-op 继承（Module.onModuleLoadSuccess
  本来就是空实现），用 `_reportID` 未置、空 load 覆写/unload 不调
  super 这些 smoke 不读的基类语义反转做 stub 阶段的失败点；要钉
  onModuleLoadSuccess 的分支就让测试直调私有方法（utest 里失败可控，
  smoke 里没人调它）。同轮 addFood/onZoom/PoolFish 全在交互或回包路径
  上（smoke 点不到）才敢用 throw。
- **openfl 不执行外部 swf 的 AS3 → 模块控制器的「反射失败分支」是可钉
  的移植终态**：四个模块壳的 onModuleLoadSuccess 经
  `Utils.getClass("module.shop.ShopController"…)` 从功能 swf 的
  ApplicationDomain 找控制器类；openfl 把 swf 当纯资产、AS3 字节码不
  执行，eval/html5 上 `hasDefinition` 恒 false → getClass 回 null
  （probe 验证四个类名全 null）→ 照译的解析失败分支 `_shopCtrl` 等保持
  null。这个 null 不是「还没实现」的过渡态，而是移植后的真实行为——
  测试断言 isNull 恰好把后续「功能 swf 翻译」批次的接入点钉死：那批把
  控制器类翻进主域并注册后，这组断言转红就是「接入完成、该改期望」的
  信号，不会无声漂过。防：模块壳类照译 onModuleLoadSuccess 时别给
  getClass null 加兜底/重试——失败分支照抄，配 isNull 钉板。

## 2026-11 · #29（implement：狗狗交互片 + 鱼实体 + 四模块壳）

- **Int 对 UInt 常量的比较是无符号域，负值恒翻**：AS3 `int >= uint` 两侧先
  升 Number（-1 >= 3 为假）；Haxe 的 UInt abstract 给 `>=`/`<` 等全部
  @:op 了**无符号**实现（std/UInt.hx #else 分支：异号即比符号位，-1 当
  0xFFFFFFFF），`level >= Consts.FISH_MAX_LEVEL` 在 level=-1（无配置/
  时钟偏斜）时 eval 直接恒真——PoolFishTest 两条 canHarvest 断言连红。
  修法：比较点把 uint 常量显式回 Int（`(Consts.FISH_MAX_LEVEL:Int)`，
  probe 验证恢复有符号），等值比较两个域对涉及的值同果、可不处理。
  防：uint 常量（原版 `:uint` 的那些）进比较表达式时查一眼操作数会不会
  是负值 Int；原版 `int` 的常量照 Int 声明就没有这个坑（ORGANIC_FERTILIZER_
  ID 先例）。
- **cpp 全量 include 扫描的 exclude 表要写全限定模块名**：#18 记过
  「小写模块名（mx_internal.hx）必须进 exclude 表」，4.3.6 的
  `include(pack, rec, ignore, classPaths)` 里 ignore 匹配**模块全名**——
  传 `['mx_internal']` 照样红（"Module mx.core.mx_internal does not
  have a valid name" 且只此一行、直接退），传 `['mx.core.mx_internal']`
  才放过。另：html5 debug.hxml 里的 `-D no-compilation` 也是 html5 专属
  项，一并去掉才落到「只剩 `Error: Library hxcpp is not installed`」的
  判据形态（留着则 0 错 0 输出退出 0，同样过 typer 但和文档判据对不上）。

## 2026-11 · #35（shop_v_7 功能 swf：商店整片）

- **Dynamic 回包字段上的 `== n`/`> 0` 是松等/关系比较，As3.floatOf 一族
  而不是裸 ==**：`__buyType` 在原版 ShopModel 里就是 "0" 字串与 Int 混写
  （同字段两种形态，#8 的 isRed 一族同病）；AS3 `"0" == 0` 为真，Haxe 裸
  `==` 在 cpp/eval 因类型先行判不等、js 偶然同——跨目标漂移。修法：
  `As3.floatOf(x) == n`（toNumber 强转后比），`> 0` 同理。防：Dynamic 与
  数字字面量的比较一律 floatOf 起手，grep 不到 `== "字面量"` 不代表松等
  清干净了——数字侧的字面量 grep 不出来。
- **Int 字段判 `== true`/`!= true` 的真值语义是 `== 1`/`!= 1`**：AS3
  `x == true`（x 为 int）先升 Number：-1≠1 为假、1==1 为真；`As3.truthy`
  对 -1 返真——直接套会把 `== true` 的门开反。防：见 `== true`/`!= true`
  且操作数是 Int 字段（_isFood/_isMill 默认 -1）就按 1 比。
- **`super.方法` 当回调值传（Haxe 编不过）的两种处理**：本类没有覆写时
  `this.` 等价替换（#21 先例）；已覆写时抽具名私有包装方法（BuyDiyWindow
  的 onSuperCloseClick、BuyItemWindow 的 onCancelClick）+ PORT-NOTE。
- **`setTimeout(f, ms, rest…)` 的 rest 参 + 处理器读 `arguments[0]`**：
  As3.setTimeout 无 rest——闭包在调用点捕获实参、转发进具名参量方法
  （ShopView.onSendToURLTimeout）；`arguments.callee` 自摘除监听同理用
  具名局部闭包自引用（ShopController.showBuySeedEx）。
- **stub 基类的「被 in-scope 子类真用的成员」要补到能跑**：BuyDiyWindow
  setData 的 `super.init()` 直落 AddButtonWindow——原 stub 没有这个覆写
  时 addWindowChild 缓存的子件永不上树、窗体空白（编译绿、行为黑）。
  补译按原版逐句（init/toCenterPositon），** addButton（winButton）本体
  留给 qui 窗口片**：恒 null 的后果（BuyDiyWindow._btnConfirm 休眠 NPE）
  列进后续模块依赖，别为消 NPE 顺手实现半截按钮。
- **split 出的数组越界下标必须 As3.arrAt**：`cropTime(id)` 在本仓是 stub
  返回 ""，BuyAdSeedWindow/BuySeedWindow 的 buildContent 对 `_loc4_[4]`、
  `_loc4_[4]-_loc4_[2]` 裸读在 cpp 上是越界崩；AS3 undefined→NaN→0 的
  语义用 `As3.arrAt`（越界 null）+ `As3.intSub`（null→0）复刻。防：凡
  依赖 GetCropID.cropTime 的 split 段，先看它是不是 stub。
- **模块控制器的 DCE 锚（零引用 + eval 测试前提）**：ShopController 只被
  ModuleShop 的反射字符串引用——按 LandTile 先例锚进 SymbolClass.dceAnchor
  （#35 段）+ 类上 @:keep；锚后 html5 的 hasDefinition 即真、装配链按
  spec 拉起链走通，eval 侧因锚整体 #if !eval 保持 getClass null 前提
  （ModuleShopTest:41 钉板，接入完成后该断言是「该改期望」的信号——
  本批只在 html5 接入，eval 前提不翻）。防：模块控制器类译完必须查
  反射入口有没有真实编译期引用，没有就进锚表。
- **「分支不可达」的断言要拿服务端回包逐字段核过**：#35 implement
  round 1 曾断言 cgi_fish_unlock.php 回包只含 code/money/n/fid、水晶
  分支不可达而留空——实际 :35 成功回包**恒含** crystal_id/crystal_num，
  hasOwnProperty 守卫每次解锁成功都真（review 驳回）。防：判定「不可达」
  前必须打开对应 PHP 看回包字符串，不能凭客户端守卫反推；「E4X 无对应物」
  也不是留空理由——仓库先例全是等价 Xml 遍历。
- **原版的 null 解引用/抛错路径也是行为，不许顺手加守卫**：BeastAPI.
  iniData 全 main3 无赋值点恒 null，原版 ShopController/UnlockFishWindow
  的水晶查询在 null 上抛 TypeError（悬停无提示、解锁无飘字/引导）——
  照译成「同点抛错」，加 `xml != null` 守卫或留空分支都是行为偏离，且
  属未登记 deviations 的私改。防：见到原版会在运行时抛错的点，先查该
  数据在本部署是否真为 null（grep 赋值点），是就照抛。

## 2026-11 · #36（warehouse_v_23 功能 swf：仓库/背包整片）

- **连锁赋值 `a.p = a.q = v` 在本仓工具链上可用，#8 的「拆两行」不是
  普适硬规则**：haxe 4.3.6 + openfl 9.5.2 下，普通字段与 openfl get/set
  属性（set_ 返回值类型）的链式赋值都编过、语义同 AS3（`--interp` 探针
  5,5 + #36 全量 html5 编译绿，MaterialProxyBig.scaleX/scaleY、Loader
  width/height、TextField multiline/wordWrap 等十余处）。#8 记的
  BackgroundController.switchMode 拆行可能另有成因（当时未隔离变量）。
  拆开永不出错、照抄链式也编得过——两边都不是错译，别为合哪条规则
  去改写另一形态。
- **scan_dyn_writes 的污染是文件级的：写点分诊先看接收者的声明行**：
  同文件**别处**的 `var _locN_:Dynamic`（或 producer 赋值）会把该名字
  整文件染黑——`createSendFlower` 里 `var _loc2_:TextField = new
  TextField()` 之后的 `.selectable = false` 也被报。#36 全片 42 处命中
  逐点核对全属此类（接收者实为 TextField/Button/实体类真类型）。防：
  命中行往上找 `var 同名:` 的**本函数**声明；声明是真类型就是误报，
  是 Dynamic/无声明才走 CLAUDE.md 三分流。
- **窗口类覆写 init 还是 addedToLayer 跟原文走，且原文不调 super 就
  不调**：warehouse 片的 SellFish/SellToolWindow 覆写 `init()`、
  SellPlant/SendFlower/FlowerCard 覆写 `addedToLayer()`（同片两种形态
  并存），五者原文都不调 super——BaseWindow 的基类初始化段（底板/
  closeButton）本来就不为这些窗跑。防：翻窗口先看原文覆写的是哪个
  钩子、有没有 super 调用，「补全初始化」是行为偏离（#18 super.init
  条的反向面：super 调用照抄，没有的也照抄）。
- **`super.data` 属性取值在 Haxe 编得过（编译探针证实），只有普通
  变量形态被禁**：基类 `(get,set)` 属性经 `super.data` 读走基类 getter
  （虚派发无歧义）；报错的是 `super.普通字段`。AS3 源里成片的
  `super.data["k"]` 照写 `Reflect.field(super.data, "k")` 即可，不必
  拆 this 局部。
- **Consts 常量按需补进时要带原文件行号**：FAIRY_MONEY=92003 在
  main3 的 Consts.as:586 有、本仓 Consts.hx 此前没译到（#35 用的是
  FAIRY_LADY/FAIRY_GOD）——补行时注释钉 `Consts.as:586`，防后人当
  发明值审掉。

## 2026-11 · #37（pool_v_13 功能 swf：鱼塘整片）

- **`for (x in Array<Dynamic>)` 的循环变量是全新的 Dynamic 绑定，外层
  `var x:T` 被遮蔽**：AS3 for-each 的 `_loc2_:PoolFish` 译成 Haxe 后，
  元素上的**属性 getter**（poolSize/animationUrl/fish 这类 `(get,…)`）
  经动态接收者取值——eval 返 null（`0 + null` 当场崩）、js 落
  undefined 再进算术变 NaN（**静默错值，比崩险**）；plain 字段和方法
  动态取没这事。防：`var typed:Array<T> = cast arr; for (x in typed)`
  （ShopModel「typed 收窄」先例），或循环内 `cast(x, T)`；翻 for-each
  时看循环体碰的是不是 getter。
- **写-tests 的「getClass 恒 null」前提会被后续 implement 阶段翻掉，
  且翻点可能在别的类**：ModuleWaterTest 断言 `_waterCtrl` 反射装配后仍
  null（#29 存根期前提）；#37 一旦把 FishMover 译出（其 `_waterPool:
  WaterPool` 签名是原文），FishMoverTest→FishMover→WaterPool→
  WaterController 的引用链就把控制器带进 eval 类型表，反射变真、构造
  链在无 Session 的测试环境 NPE。shop/warehouse 同款测试当时绿只是
  它们的测试集不引用够得着控制器的类。防：写模块壳反射测试时别把
  「恒 null」当永久断言；implement 阶段撞上就按测试前提过时报
  NEEDS-TESTS，别为救断言去改 1:1 签名。
- **openfl `Dictionary` 构造必须显式类型参**：@:multiType 抽象的
  `new Dictionary()` infer 不出底层 map——赋值目标的 `Dictionary<A,B>`
  也救不了（「Type parameters of multi type abstracts must be known」）。
  键值实型写全；键是函数/对象类型才能落 ObjectMap（UIComponent:24 的
  Dynamic 键陷阱是同一件事的反面）。
- **CommonData.applicationDomain 原来从没人赋过值**：原版在**外层文档
  类**（FarmWorld.as:81/FarmLite.as:424）赋 currentDomain，移植以 Main
  为根后这行缺位——此前无解引用点所以没炸。#37 的 WaterPool 是第一个
  读它建池的。防：翻译里出现 `CommonData.applicationDomain` 时先确认
  Main.init 的 boot 胶水（PORT-NOTE(boot)）在。
- **AS3 VM 的字段零值默认（int 0/Number NaN/Boolean false）在 Haxe 里
  要显式落**：eval 未赋值字段是 null（`++counter` 直接 "Invalid
  operation: null + 1"）、js 是 undefined。HealthMode:11 先例；#37 的
  ObjectPool 计数器三件、FishMover 七个 int 全靠这个起绿。防：类字段
  表逐个对原文，数值/布尔缺初始化就补 `= 0`/`= Math.NaN`/`= false`。

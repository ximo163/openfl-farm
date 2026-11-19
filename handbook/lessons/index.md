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

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

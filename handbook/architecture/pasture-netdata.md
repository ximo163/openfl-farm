# 牧场网络与数据层（mc.fBridge / mc.model / GetCropID / 通用窗件 / 窗口框架，Master2）

牧场（Master2_v_142）的运行时底座，issue #87 翻译（57 类）。legacy 出处
`decompiled/Master2_v_142/scripts/mc/` 下同包路径。光标族单独一页见
[pasture-cursor.md](pasture-cursor.md)；LipiUI 组件库底座见
[pasture-libs.md](pasture-libs.md)。注意**全篇别与 main3 农田侧的同名
概念混**——common.GetCropID（农场作物）与 mc.view.farm.GetCropID（牧场
动物）是两个类；common.FeartureManager 与 mc.fBridge.FeartureManager 同理。

## 网络（`src/mc/fBridge/`）

- **FRequest**：全部 CGI 请求的唯一出口（单例）。postRequest/postRequest2
  只是 timeout 60000/12000 的壳，真体在私有 request：act 非空先过
  RequestManager 熔断（errStr 非 null 直接回调错误对象不出网）；然后
  **lastRequest 四件先存**（LocalData 静态位）再装饰——farmTime
  （CommonData.serverTime）/farmKey（SHA1）/pastureKey/uIdx。应答闭包按
  errorType 分派 validateCode（MainCommand.showWin）/session 分支。
  Dynamic 键读写全走 Reflect/As3 助手。
- **RequestManager**：偷菜（STEAL）/进好友牧场（ENTER）错误熔断。
  actList/uinList 双表持久化在 SharedObject（LocalData.setObject），
  errNum 累到 errTotal（=3）且未在封禁中时 blocking=serverTime+
  floor(5+random*5)*60 分钟随机窗。checkAction 未到期返「X 分钟后…」
  文案（Math.ceil 分钟数）。**内存 mutation 先于 setObject**——
  SharedObject 不可用时行为不致全灭，原版设计如此。
- **FeartureManager**：按 uin 取模分桶的灰度开关（enter/steal/friendList
  三通道）。parameters 里 `pasture_<名>`（逗号分隔 a-b 区间表）+
  `pasture_<名>_mod`（模数）+ `pasture_<名>_tips`（命中文案）。
  静态方法无实例。
- **DataURLLoader**：URLLoader + postData 属性对，成员面即真身（#86 已立）。
- **EventRecorder**（`src/mc/fBridge/EventRecorder.hx`）：mcloader 侧
  外部队件的最小 stub——recordErrorEvent/recordMultiValueInCode 体空
  （no-qq-telemetry 决策族），常量面照抄。真身归 mcloader 片。

## 数据（`src/mc/model/`）

单例群（getInstance/gi），EventDispatcher 子类，setter 写后派发
ModelEvent/事件常量——**测试只钉派发行为与数值公式，时序消费在后续片**。

- **MainData**（1382 行原版全量）：约 60 个事件常量 + 全字段 getter/setter
  矩阵。关键件：me（当前用户基数据）、hostFid/currentFid（qzone 分支
  逐字 `"qzone"` 字面量）、animalData setter（40 位预 size 数组 + me 基
  窝/棚计数）、addExp（跨级派 USER_LEVEL_UP）、friendFilter/uniq、
  gradeToExp/expToGrade 级经验公式、mpData setter 派 MPScene.OPEN_MAOPAO
  （MPScene 是场景片签名 stub）、LOAD_DIY_CONFIG_COMPLETE（GetCropID 的
  mp 配置加载完成广播）。**int/Number 缺省初值按 AS3 语义补**（int→0、
  Number→NaN）——eval/html5 容错但 cpp 空 Int 直接红（lessons 静态目标条）。
- **FarmData**：农场操作数据（userSeed/farmOperate/harvestData/flyData
  等 setter 派发）+ killFly 计数逻辑。getter 缺省值 0 非 null。
- **TinItemsData**：罐头/道具条数据——concat 无参→copy()、splice 负起点
  旋转、sortOn NUMERIC→floatOf 比较。
- **OpenControl**：功能开放控制——按 INI openControl 项查 open/openlv/
  openexp/time 四面。checkTime 小时表（`serverTime*1000` 逐字照抄，eval
  Int32 回绕通道与测试同通道故断言一致——**勿拉齐成 \*1000.0**，PORT-NOTE
  在案）；checkTime2 日期窗（`*1000.0` 真纪元毫秒，美式日期串走
  As3.dateOf 失败回 null 按 NaN 语义比较恒 false）。
- **ProductData/TaskData/DiyData/MData/ToolData**：小数据件，setter 派发
  与配方表照抄。ModelEvent 是事件常量类。

## GetCropID（`src/mc/view/farm/GetCropID.hx`，777 行原版全量）

牧场 id↔名称/URL 映射中枢——商店/仓库/装饰/科研各片拼资产 URL 都靠它。

- **配置源**：`_xml` 静态缓存 INI.getInstance().data（mcloader 运行时把
  mc_data 的 animals、mc_card 的 cards 并进 mc_main 主配）。**E4X 全手译**：
  私有助手 xmlNormalize（Document→firstElement）/childNamed/childrenNamed/
  childAttr/animalEl/attrEq/textOf/numOf——仓内无通用 E4X shim，本类是
  牧场侧第一个密集消费者，后续片照这个模式写。
- **E4X 宽松比较**：`(@id == val)` 字符串 id 直比、Number id（
  getAnimalSound/numToNext 的 Float 形参）数值 coercion——attrEq 分路。
  `Number()` 化（idToSound/getChidNum/getGameRecord）走专用 numOf：
  空串/缺位 → +0（ECMA Number("") 语义），**不是** As3.floatOf 的
  空前缀 NaN——两通道别混。
- **URL 族**：getSwfUrl（folder.@url 经 addPrefix）+ 三前缀替换链
  （appimg./appimg1./appimg3. 顺序逐字、As3.replaceFirst 首处语义；
  空 appImgPrefix 或 url 已含 ".appimg" 原样）。getAnimalURL 的 _0/_1
  后缀（status∈{1,2}→_0）与 ?v= 拼接、getWareHouseIconUrl 的 >10000
  阈值、getShopIconUrl 四分支、b_s.swf 变体全逐字。
- **setNext/numToNext**：生长档推导——nextTime/nextText 逗号表拆
  split。**Dynamic 减法陷阱**：`timeList[5] - data.growTime` 两侧先
  As3.floatOf 强转（eval 裸 Dynamic 减掷 Invalid operation）；status2/5
  else 分支赋 split 原串（字符串位），status3/5 边界赋算术结果（数值）
  ——测试钉死两种形态，别统一。
- **mp 配置族**（getDiyMP/getHunterMP/hasDiyMP/getDiyTip/getDiySkin/
  getMPXMl）：_mpXml 独立加载（cgi_animal_tips），本片只译加载链照抄；
  测试期恒 null 走早退分支。
- **idToDiyUrl2 依赖 ResearchModel**（科研所片 stub，签名面在
  `src/mc/view/farm/research/ResearchModel.hx`——包段大写 Research 落
  小写 research，windowControl 同款先例）：lv>8 分支在科研片充真身前
  掷 not-implemented，是既定 stub 契约。

## 通用视图（`src/mc/view/common/`）与窗口框架

- **BaseWindow/ConfirmWindow/AddButtonWindow/MaterialLoaderProxy** 四个
  本片充真身（#19 期是签名 stub）。**init/initPanel 通道不能拆**（
  pasture-libs.md 的 LipiPanel 节）：mc 窗族覆写签名统一
  `init(param1:Rectangle = null)`。BaseWindow._closeButtonClick 撞
  LipiPanel 同名私有（AS3 private 不进虚表、Haxe 要覆写检查）——
  改名 _closeButtonClickBase，与 initPanel 同族处置。
- **LipiPanel super.addChild 修复（#87 实证）**：AVM2 super 调用静态
  绑定；openfl 的 addChild 方法体是 `addChildAt(child, numChildren)`
  **虚拟**调用——super.addChild 在 Haxe 重派进本类 addChildAt 覆写
  （重定向进 _contentPane）→ `_contentPane` 自加抛 Error #2024，
  `new LipiPanel()` 裸构造即崩。修法 super.addChildAt(x, super.numChildren)
  （索引取 super.numChildren——本类 get_numChildren 已重定向）。
  **同款地雷未排**：LipiContainer.hx 的 super.addChild 四处（:148/:157/
  :161/:386）+ addChildAt 覆写（:131）同构——`new LipiContainer()` 同样
  抛 #2024，probe 实证；属 LipiUI 底座（#86 领域），待修。
- **HList**：横向列表布局。**int 截断是原版行为**：setChildPosition 的
  `_loc1_:int`——center 分支 `(width-总宽)/2` 赋 int 即 ToInt32 截断
  （字节码 OToInt 三处实证：center/right 公式位 + 循环累加位），
  (100-119)/2=-9.5 落 **-9**，逐件累加 31/71；width=200 落 40。
  FFDec 输出看不出隐式 int 强转——**质疑 float 期望时以字节码为准**
  （工具：tools/DumpAbcMethod.hx retarget 先例）。
- **MaterialProxy**：素材代理类型分派（"1"/"11"/"4"/"7"/"5"/"6_6"/"7_7"/
  "25"/"2525"/"5_5" + "2" 落反括号通道）+ 跳过守卫 + 灰阶矩阵逐字。
  null 守卫不对称照抄（setCrop 系有守卫、setTool2/setTool2x 没有——
  原版素材缺失即 NPE 行为）。
- **AlertWindow/InfoWindow/HtmlTextWindow/ConfirmWindow**：四窗布局参数
  逐字；外链通道 JSProxy.openWindow/navigateToURL 走 shim.QQOutlets/
  shim.NavigateToURL（no-qzone-jsapi 决策族）。BeastAPI（activities 模块）
  只有签名 stub。
- **Language**：字符串表 `_l` 模板 + INI version.@language 解析。
  replaceText 的 {key} 全局替换 + #N# 序数替换两轮。
- **MoneyIcon/DataLoading/HList/MaterialProxyBig**：小件照抄。

## 窗口框架 / 视图 / 杂项

- **WControl/WindowClassLib**（windowControl 包——大写 WindowControl
  落小写先例）：窗口宿主框架。WindowClassLib 是窗名→类的注册表
  （Dynamic 对象惰性初始化），全部窗口片的宿主。
- **WindowsManager**：单例 + leftPane（snowkit Pane）存取——**不是**
  main3 的 WindowControl，别混。
- **CropLoader**：动物 swf FIFO 加载队列。**原版 bug 照抄**：非素材分支
  `_contents` 以 LoaderInfo 对象为键（不是 url 串）——死写，PORT-NOTE
  在案。
- **GameProxy**：me 真值表 + currentUser setter 派发。
- **API 三类**（mc/api/）：AppHelper（centerPopUp int 截断、20 元素灰阶
  矩阵惰性缓存、sendRequest 恒返 true 薄壳）、EmptyWindow、IAPIHelper。
  sendRequest 跑 FRequest——CommonData.getKey 未赋值时按原版行为抛
  （生产启动链先赋值，测试环境顺序件）。
- **遮罩/飘字/提示/验证码窗**：InitLoading/UserChanging（beginFill
  16777215,0.6 等参数逐字）、Float/FloatingLayer（拖随 scrollRect、
  ClockOperateFloating 是地块片签名 stub）、TipLayer（300ms 等待计时器、
  空 `if (this.tip != null) {}` 分支原版如此照抄）、MouseTip 定位数学、
  ValidateCodeWindow（320x250、maxChars=8、restrict 逐字）。

## 跨片 stub 清单（本片立、后续片充真身）

| stub | 归属片 | 谁引用 |
|---|---|---|
| `src/mc/view/farm/MPScene.hx` | 牧场场景片 | MainData.mpData setter（OPEN_MAOPAO 常量） |
| `src/mc/view/farm/research/ResearchModel.hx` | 科研所片 | GetCropID.idToDiyUrl2（lv>8 分支） |
| `src/mc/view/farm/land/ClockOperateFloating.hx` | 牧场地块片 | FloatingLayer.updateAnimalSkin |
| `src/mc/api/BeastAPI.hx` | activities 模块 wild 子系统 | AlertWindow.onLinkClicked（gotoWild） |
| `src/mc/control/MainCommand.hx` 增补签名（showWin/run/register/userReload/validateCode） | 控制/命令片 | FRequest 应答分派、ValidateCodeWindow |

## 约定

- mc.model 全员 setter 派发——写后必派对应事件常量，漏派=行为差。
- 熔断/灰度的 serverTime 全部经 CommonData.serverTime（测试驱动同位）。
- 牧场窗件构造即崩的排查顺序：先看 LipiPanel/LipiContainer 的
  super.addChild 通道（#2024 自加），再看素材缺失 null。
- 测试假素材：support/MaterialFakes 把 SuccessIcon/ErrorIcon 等 root 包
  假类压进 MaterialLib 域——eval 按引用收模块，anchor 静态引用强制入表。

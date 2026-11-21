# 站内信/留言/日志/公告（messages 两族）

个人资料窗（别人或自己的主页入口）：头部头像卡 + 多页签——消息（操作
日志）、留言（chat）、成果（收获历史）、（仅 main3）成鱼、消费（流水）、
系统（公告）。#19 整片翻译。**两族同名页但来自两个 swf，各自 1:1 翻译、
不合并**——内容文案、页签数、素材、数据栈都不同（见文末对比）。

## main3 族（农场）

`decompiled main3_v_221/scripts/module/messages/`：

- `ModuleMessages`：模块壳（Module 形态，#7 约定）。
- `MessageController`：onOpenWindow 开窗、按页签要数据。
- `MessageModel`（EventDispatcher）：数据源。事件 EVENT_DATA_CHANGED/
  LOADING/FAILED（LOG_CLEARED 声明后从未派发——照抄）。chat&act=
  getAllInfo 按 `m_flags=[2,4,8]` 旗标取页、hydra feeds 日志、sysmsg、
  双源消费流水合并（NM/WS 两旗标），留言收发/清空走 NetHelper。
- `MessageView`（qui BaseWindow）：ProfileHead + TabBar 六页签挂 ViewStack
  （qui 控件走 WindowTabBarMaker），loading 遮罩盖头/签/栈，按 model 事件
  的 index 分发各页数据。
- `widgets/ProfileMsg|ProfileHead|ProfileLog|ProfileCost|ProfileSystemMsg|
  ProfileHistory|HistoryItem`：六页 + 成果格。`ProfileHistory` 成鱼/成果
  复用同一类、靠构造 flag 分素材（HistoryItem 基类 + 鱼/作物两壳）。
- `widgets/HistoryItemTip`：成果格悬停 tip（common/view/tip/Tip 通道）。

素材：ButtonGreen/TipBg/ItemBg/ButtonOrange 均在 farmui_full_v_40.swf
（已声明库），无新增资产。时间戳格式化（今天/昨天/前天）各页自持一份
compareDate——逐份照抄，别抽公共函数。

## Master2 族（牧场）

`decompiled Master2_v_142/scripts/`：

- `mc/view/main/leftInfo/MsgIcon|PostIcon|PostWindow`：入口图标（MsgIcon/
  PostIcon 雷同两类——照抄不合并）与公告窗（NoticeWindowTitle，addButton
  通道）。
- `mc/view/main/window/profile/ProfileWindow` + 五页签 widgets + HistoryItem/
  HistoryTip：与 main3 族同名页但独立翻译。ProfileWindow 走
  `MainData.PROFILE/PROFILE_LOADING/PROFILE_ERR` 事件（MData 单例聚合），
  JerryTabNavigation 五页签（无成鱼页）。**原版 bug 照抄**：ProfileWindow.as
  :71-74 `hasOwnProperty("info")` 但读 `profile["data"]`——门和键不一致，
  照译不改（deviations 候选待人裁决）。

Master2 依赖闭包随译/桩（原类 loc 与原因见各文件头注释）：mcloader
同域类（Version/JSProxy/INI/LocalData/MaterialLib——见踩坑 mcloader 同域条）
从 `mcloader_v_53/scripts/` 译；com.minutes LipiUI 族/JerryTabNavigation 等
≤100 loc 顺手译；MainData/MainCommand/FBride 网栈等大块签名面 stub
（#pasture 补真身）。stub 的方法签名逐字取自反编译原文，**行为差异只允许
体现在体空**。

## 约定（动这块前必读）

- **两族绝不互相 import**：main3 族走 Session/NetHelper/EventRecorder，
  Master2 族走 MData/Command（stub），混用等于发明原版没有的架构。
- Master2 族目前 main3 的 Main 够不着（mcloader/Master2 未接线）——
  html5 全量编译不对其做类型检查，改完必须跑 lessons #18 的 cpp typer
  include 扫（`/tmp/scan19.hxml` 形态）。
- `x["k"]`（x:Dynamic）在 eval 只是中文键报错、cpp typer 上**一切**字符串
  键下标都红：一律 Reflect.field/setField（见踩坑 #19 条）。
- 对方页（selected>0）与本人页（me）取数据源不同：本人走 host、对方走
  currentUser——`me` 判定散在 ProfileMsg/ProfileWindow/ProfileHistory，
  照抄各处原判定，别统一。
- 留言页 genMsg 的 domain 数组是文字模板的中枢（QQ/空间/校友三渠道换
  文案），两族槽位不同（main3 成鱼在 3、Master2 留言清 1/3）——逐字照抄。

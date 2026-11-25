# tasks 模块（新手任务/欢迎引导）

11 项新手任务（收获/松土/出售/播种/浇水/除草/打药，后 4 项在好友农场做）+
首次进入的新手引导。`spec/modules/tasks.json` 的 5 个类 2026-11（#21）译完，
ModuleTask 壳同时从 stub 转正。

## 关键类与 legacy 出处

均出自 `legacy/decompiled/main3_v_221/scripts/module/task/`：

- `module/task/ModuleTask.hx` ← `ModuleTask.as`：模块壳。FarmApplication
  `initModules`（FarmApplication.hx:927 一带，LAYER_TASK）**急加载**，不走
  RSL 懒加载链——和 messages 等窗口模块不同。`onNetRequestStopped` 把停摆
  通知转给 `WelcomeModel.resetLoadingFlags`（updateTask 的 m_taskUpdating
  防重入门位在此复位），load/unload 挂 WelcomeController 的创建/销毁。
- `module/task/welcome/WelcomeModel.hx` ← `WelcomeModel.as`（223 loc）：纯
  数据层，单测覆盖（`test/module/task/welcome/WelcomeModelTest.hx`）。核心
  是 `taskList`（11 行 name+me 表，`taskComp` 完成判定的全部输入）、
  `newIDToOldID`（新 id 空间→旧 id 反查，下标即旧 id）、`currentTask`
  setter（装载即派发 TaskChanged，`_taskId < 20` 分流决定
  `Session.isNewGuideTask` 极性）和 `taskComp` 三门（flag==1 + name/me
  对表 + code==1 → updateTask）。
- `WelcomeController.hx` ← `WelcomeController.as`：监听 MSG_STARTUP_DATA
  （建 WelcomeView；`_welcome==true` 走 showNewGuide，否则装载存量的
  `_task`）和 MSG_CHECK_TASK（各处农事完成后把动作名转发给
  `model.taskComp`）。
- `WelcomeView.hx` ← `WelcomeView.as`（338 loc）：书页按钮
  （taskAwokeButton 64×49@(105,500) / taskingButton 46×36@(105,506)）、
  showNewGuide（help.swf 引导 + 0.3 白罩压底）、onTaskCompleted（开
  TaskOverWindow 领奖、addReward、MSG_LEVELUP 派发）。
- `WelcomeTaskWindow.hx` / `TaskOverWindow.hx` ← 同名 .as：任务窗（领取
  mode=0 双按钮 / 进行中 mode=1 单按钮）与完成领奖窗，都建在
  ConfirmWindow 上。

## 任务推进语义（容易读错）

task_update 应答回显的是**刚完成的旧任务**且 taskFlag=2（待领下一个）；
「id+1」发生在下一个 task_accept 应答（`task_accept.php:5-6` /
`task_update.php:6-15`）。taskid==11 完成后回 0/0，走 onTaskAllOver
（「您已完成全部新手任务！」）。onTaskUpdated 里 `taskId==0&&taskFlag==0`
的自赋值是原版死分支，照抄未删。

## 素材（task_v_2 + help 两库）

- **fresherTask 库**：运行期 URL 由 config secondList 决定（`nc_data.php:39`
  → `module/ui/main/task_v_2.swf`）。注意 `spec/modules/tasks.json` 的
  assets ref 写的是 `mc/main/task_v_1.swf`——那是规格抽样元数据，不是
  运行期 URL；两个 swf 都导出 task1..task11 + taskAwokeButton/taskingButton，
  按配置译 task_v_2（libraries.xml 注释同款说明）。
- **符号 shim**：`src/Task1.hx`..`Task11.hx` + `src/TaskAwokeButton.hx` +
  `src/TaskingButton.hx`，全部注册在 `SymbolClass.dceAnchor`。导出符号名
  小写开头（task1/taskAwokeButton/…）→ 类名大写 + `@:native("原名")`
  回键（assets.md 的 ②）。requestClass/getMaterial 经 `Type.resolveClass`
  先命中 shim 类、同步回调，不走网络窗口。
- **help 库**（`nc_data.php:38` → `outswf/help.swf`，1010×780@12fps）：
  WelcomeView.showNewGuide 用 `Loader` 装引导，经 `shim.LocalSwfLoader`
  映射入库。引导结束靠 swf 内部派发 `"closeEvent"` 字符串事件（非
  Event 常量），onGuideFinished 里 removeEventListener 用的也是裸串——
  别「顺手」换成常量。
- **help 库自带的 6 类已翻译 + 接线**（issue #65 implement 落，
  `src/help0316_fla/`）：help.swf 的 SymbolClass 绑 6 类（文档类
  MainTimeline + page1_9/page2_8/page3_7/page4_5/page5_1，#65 根因 A——
  swf 自带 AS3，openfl 只渲染时间轴不执行 ABC），方法体已按反编译原文
  逐字翻译。契约由 test/help0316_fla/ 钉死：五页 visible 翻页矩阵、按钮
  CLICK → 裸串转发，其中 **page5_1 的 closeButtonClick 是
  `new Event("closeEvent", true)`——bubbles=true 是全引导唯一冒泡点**，
  content 上 WelcomeView 的监听 → onGuideFinished 收尾链全靠它（根上的
  MainTimeline.closeButtonClick 同名事件不带 bubbles，两处极性相反）。
  **页类名小写开头 → Haxe 大写类名、不加 @:native**（write-tests 曾按
  Task 垫片的 ② 法加 `@:native("小写原名")`，implement 探针证伪撤掉：
  库实例化走 `SymbolUtils.formatClassName`——类名段**首字母大写**——
  resolveClass，恰等于 Haxe 默认注册名；@:native 把注册键改成小写原名
  反而让 resolveClass 落 null、库静默回退裸 MovieClip，翻译类永不实例
  化。② @:native 只适用于 ExportAssets 小写符号名直查（getMaterial(
  "task1") 一类）。帧脚本等价执行（frame1 接线）与 41 个 DefineEditText
  的文字修复都归 `shim/HelpGuideWiring.hx`，由
  LocalSwfLoader.attachContent 按 libraryId=="help" 挂（addFrameScript
  在无 Timeline 实例上静默丢弃，FrameScriptCompensation 头注同证）；
  文字根因 B 是 openfl 9.5.2 HTMLParser 的 `</p>` 换行不入 range
  （见 lessons #65 条），修复走 issue 路径 b（range 簿记补洞，不动文字
  内容/格式，无 deviations 项）。41 个字段里 32 个被五页帧 1 引用（树
  上全集、一次修复完备），9 个是死符号永不实例化。
- 冒烟必经：uid=1 fixture `"welcome":1` → StartupData._welcome==true →
  showNewGuide 在 CI web-smoke 一定执行，help 库缺声明就是 404 红叉。

## 约定与坑

- **ConfirmWindow 还是 stub**：farm-basic 的类，本模块只补了子类要碰的
  protected 面（按钮/文案字段 + 空 confirmButtonClick/cancelButtonClick），
  窗口真实布局/行为归 farm-basic 的全量翻译；届时删掉 stub 注记即可，
  子类不受影响（两窗只用字段 + 覆写 init/setSize/setData）。
- **`WindowControl.open` 仍是 no-op stub**（#7 闭包 stub，
  `src/common/view/window/WindowControl.hx:29`）：窗口「打开」在移植版里还
  只是设 data，不真正弹层——画面比对覆盖到窗口模块时要先转正它（窗口
  stub 链的约定见 [farmscene.md](farmscene.md) 的「qui 窗口 stub 链」节）。
- **AS3 private 同名异型遮蔽**：WelcomeTaskWindow 的 `_mode:int` 撞
  BaseWindow `_mode:Boolean`——AS3 private 不进子类作用域、是两个独立槽，
  Haxe 同名异型重定义直接红。改名 `m_mode` + `PORT-NOTE(shadow)` 拆槽，
  见 lessons（#21）。
- **super 方法取不了闭包**：`addEventListener(CLICK, super.confirmButtonClick)`
  形态 Haxe 编译红（Cannot create closure on super method）；本类未覆写该
  方法时 `this.` 与 `super.` 同一实现，等价替换 + PORT-NOTE。覆写过的
  场景见 lessons（#21）。
- **taskComp 的 me 三门**：`Session.getInstance().me` 是「当前在不在自己
  农场」，与表行的 me（任务该在哪做）比对——好友农场做 me:true 的任务
  不算数。测试这两门的用例见 test 文件（#21 attempt 1 曾有两例自相矛盾
  ——装载后没清 TaskChanged 计数、循环内没复位 Session——attempt 2 已修，
  坑记 lessons）。
- `onNetError` 里小写 `"cmdId"` 读键是原版笔误（请求侧只产 `"cmdID"`，
  该分支恒假），照抄不修；WelcomeModel.hx:96-97 有注。

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
  不算数。测试这两门的用例见 test 文件（#21 收尾有两例测试自相矛盾，
  走了 NEEDS-TESTS，见 lessons）。
- `onNetError` 里小写 `"cmdId"` 读键是原版笔误（请求侧只产 `"cmdID"`，
  该分支恒假），照抄不修；WelcomeModel.hx:96-97 有注。

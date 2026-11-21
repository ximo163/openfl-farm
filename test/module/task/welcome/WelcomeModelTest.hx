package module.task.welcome;

import com.qzone.qfa.events.CommandEvent;
import common.Session;
import common.misc.Utils;
import entities.Player;
import entities.Task;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.vo.ServiceResultVO;
import openfl.events.Event;
import utest.Assert;

/**
 * WelcomeModel 纯逻辑（issue #21）：新手任务数据层——11 项任务表与新旧 id
 * 映射、currentTask 装载（TaskChanged 派发 + Session.isNewGuideTask 极性）、
 * taskComp 完成判定三门（进行中 flag、名字+me 对表、应答 code）、
 * task_accept/task_update 应答推进与奖励载荷转发、onNetError 门位复位。
 *
 * 任务推进语义（协议出处钉死）：task_update 完成任务后 DB taskid+1 但
 * 响应回显刚完成的旧 id（taskFlag=2 待领下一个；taskid==11 时回 0/0 全部
 * 完成），客户端 taskID 因此停在旧值、由下一个 task_accept 拿到 +1 后的
 * 新 id——「推进」发生在 accept 应答，不在 update 应答。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/module/task/welcome/WelcomeModel.as
 *   （常量 :15/:17、taskList :19-64、newIDToOldID :66、ctor :74-80、
 *   onAccepted :92-104、onNetError :106-121、acceptTask :123-126、
 *   updateTask :128-136、taskComp :143-162、preSetTaskFlag :164-167、
 *   resetLoadingFlags :169-175、currentTask setter :177-198、
 *   onTaskUpdated :200-219）
 * - spec/protocol.json entries.nc.mods：
 *   task_accept（taskId = app_qqfarm_nc.taskid 原值，只读不改状态，
 *   task_accept.php:5-6）、task_update（无参数，taskid∈[0,11] 才响应；
 *   money += taskid*50、exp += 100、DB taskid+1；task.taskId 回显旧值、
 *   taskFlag=2；taskid==11 时 task:{taskId:0,taskFlag:0}；item 固定两项
 *   {eType:7,eParam:0,eNum:100}+{eType:6,eParam:0,eNum:taskid*50}；
 *   direction "恭喜您完成任务,获得100个经验和{taskid*50}个金币"；
 *   task_update.php:6-15）、user_welcome（恒空响应）
 * - cmd→mod：framework/net/ServerServices 113→mod=task&act=accept、
 *   114→mod=task&act=update（ServerServices.as:124-125）
 * - taskComp 实参形状：FarmLandModel 的 EVENT_CHECK_TASK 派发
 *   {"water":应答对象} 等（FarmLandModel.as:243/:399/:905/:1219/:1558/:1973，
 *   键=动作名、值=带 code 的服务端应答），WelcomeController.onCheckTaskComplete
 *   逐键转发 taskComp（WelcomeController.as:27-39）
 * - Session.isNewGuideTask：Session.as:32（public var，false 初值）
 *
 * 网络路径不进测试：NetHelper.sendRequest 在 theApp == null 时 no-op
 * （#7 已译，MessageModelTest/UIToolsModelTest 同口径），单测进程不跑
 * Main、theApp 恒 null——acceptTask/updateTask 只能经 m_taskUpdating
 * 门位观测（@:access 直读，FriendsModelTest 先例）；应答侧直接喂构造好的
 * CommandEvent（body 用 Utils.buildRequest 造出与真实链路同构的
 * {cmdID,__body,__method,__format}，result 装 ServiceResultVO，走
 * NetHelper.getVOData 的 m_extra 分支）。EventRecorder 已按 deviations
 * （no-qq-telemetry）DISABLED，onNetError 的上报与 :112 小写 "cmdId" 笔误
 * 分支（buildRequest 只产 "cmdID"，accept 错误分支恒假）均无观测。
 */
@:access(module.task.welcome.WelcomeModel)
class WelcomeModelTest {
	public function new() {}

	var model:WelcomeModel;

	var savedHost:Player;
	var savedCurrentUser:Player;
	var savedIsNewGuideTask:Bool;

	public function setup() {
		model = new WelcomeModel();
		// me = true（自己农场）：currentUser._uId == host._uId
		//（Session.as:108-118 的 get me）
		var host = new Player({});
		host._uId = 1;
		var currentUser = new Player({});
		currentUser._uId = 1;
		var s = Session.getInstance();
		savedHost = s.host;
		savedCurrentUser = s.currentUser;
		savedIsNewGuideTask = s.isNewGuideTask;
		s.host = host;
		s.currentUser = currentUser;
		s.isNewGuideTask = false;
	}

	public function teardown() {
		var s = Session.getInstance();
		s.host = savedHost;
		s.currentUser = savedCurrentUser;
		s.isNewGuideTask = savedIsNewGuideTask;
	}

	// —— 构造工具（实参形状照 WelcomeModel 自己的构造路径）——

	// onAccepted（:98-100）/WelcomeController.startNewTask（:21-23）的构造
	// 形态：new Task(null) 后直接写字段
	function makeTask(id:Int, flag:Int):Task {
		var t = new Task(null);
		t._taskId = id;
		t._taskFlag = flag;
		return t;
	}

	// me = false（好友农场）：currentUser 换成别的 uid
	function visitFriendFarm():Void {
		var friend = new Player({});
		friend._uId = 2;
		Session.getInstance().currentUser = friend;
	}

	// 装一个「进行中」的任务（旧 id 空间，flag=1）
	function activateOwnTask(id:Int):Void {
		model.currentTask = makeTask(id, 1);
	}

	// 两类事件全收进一个 log：{type, data}
	function listen(log:Array<Dynamic>):Void {
		model.addEventListener(WelcomeModel.EVENT_TASK_CHANGED,
			function(e:Event) log.push({type: WelcomeModel.EVENT_TASK_CHANGED, data: cast(e, CommonEvent).data}));
		model.addEventListener(WelcomeModel.EVENT_TASK_COMPLETED,
			function(e:Event) log.push({type: WelcomeModel.EVENT_TASK_COMPLETED, data: cast(e, CommonEvent).data}));
	}

	static function countType(log:Array<Dynamic>, type:String):Int {
		var n = 0;
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				n++;
			}
		}
		return n;
	}

	static function firstData(log:Array<Dynamic>, type:String):Dynamic {
		for (entry in log) {
			if (Reflect.field(entry, "type") == type) {
				return Reflect.field(entry, "data");
			}
		}
		return null;
	}

	// 应答事件：result 装 ServiceResultVO（getVOData 的 m_extra 分支）
	static function voEvent(payload:Dynamic):CommandEvent {
		var vo = new ServiceResultVO();
		vo.m_extra = payload;
		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.body = Utils.buildRequest(CommandDefs.CMD_UPDATE_TASK, null);
		ev.result = vo;
		return ev;
	}

	// 错误事件：body 与 buildRequest 同形（键 "cmdID"）；onNetError :108 要求
	// result 非 null 才走到 cmdID 分支，result 也要装上
	static function errEvent(cmd:Int):CommandEvent {
		var ev = new CommandEvent(CommandEvent.ERROR);
		ev.body = Utils.buildRequest(cmd, null);
		ev.result = new ServiceResultVO();
		return ev;
	}

	// :15/:17 事件名（WelcomeView 构造器 :47-48 按名监听）
	public function test_event_constants() {
		Assert.equals("TaskChanged", WelcomeModel.EVENT_TASK_CHANGED); // :15
		Assert.equals("TaskCompleted", WelcomeModel.EVENT_TASK_COMPLETED); // :17
	}

	// :19-64 静态任务表：键 "1"-"11"，条目 {name, me}。1-7 自己农场做
	// （me:true：收获/锄地/出售/种植/浇水/除草/杀虫），8-11 好友农场做
	// （me:false：浇水/除草/杀虫/收获）。taskComp 按当前 id 取条目对名字
	// 与 me（:149-155），这张表就是完成判定的全部输入。
	public function test_taskList_defines_11_tasks_with_names_and_me_flags() {
		Assert.notNull(WelcomeModel.taskList, "taskList 未装载（:19-64）");
		if (WelcomeModel.taskList == null) {
			return;
		}
		// {id: [name, me]}，逐条照 :19-64
		var rows:Array<Array<Dynamic>> = [
			["1", "harvest", true], // :20-23
			["2", "scarify", true], // :24-27
			["3", "sale", true], // :28-31
			["4", "planting", true], // :32-35
			["5", "water", true], // :36-39
			["6", "clearWeed", true], // :40-43
			["7", "spraying", true], // :44-47
			["8", "water", false], // :48-51
			["9", "clearWeed", false], // :52-55
			["10", "spraying", false], // :56-59
			["11", "harvest", false] // :60-63
		];
		Assert.equals(11, Reflect.fields(WelcomeModel.taskList).length);
		for (row in rows) {
			var entry:Dynamic = Reflect.field(WelcomeModel.taskList, row[0]);
			Assert.notNull(entry, 'taskList[${row[0]}] 缺条目');
			if (entry == null) {
				continue;
			}
			Assert.equals(row[1], Reflect.field(entry, "name"), 'taskList[${row[0]}].name');
			Assert.equals(row[2], Reflect.field(entry, "me"), 'taskList[${row[0]}].me');
		}
	}

	// :66 + :87-90 新旧 id 映射表：新 id 空间（服务端新版 taskid）反查旧 id
	// （下标即旧 id），WelcomeView.acceptNewTask 用它算下一任务窗的 id
	// （WelcomeView.as:173-178）。concat() 是防御性拷贝：改返回数组不得
	// 漏回表里（:89）。
	public function test_newIDToOldIDArray_table_and_defensive_copy() {
		var arr = model.newIDToOldIDArray;
		Assert.same([99, 21, 24, 25, 26, 27, 22, 23, 99, 28, 29, 30], arr); // :66
		arr[0] = 12345; // 拷贝语义：不得影响下一次取值
		Assert.equals(99, model.newIDToOldIDArray[0]); // :89 concat()
	}

	// :74-80 构造器零位：未装载任务、不在更新中
	public function test_constructor_zero_defaults() {
		Assert.equals(0, model.taskID); // :77
		Assert.equals(0, model.taskFlag); // :78
		Assert.isFalse(model.m_taskUpdating); // :79
	}

	// :183-187 旧 id 空间（_taskId < 20，本部署 task_accept 回的 0-11 就是
	// 这一支）：id 原样落 m_currentTaskID，isNewGuideTask 清 false。
	// 边界 19 是旧空间最后一档（<20 严格比较）。
	public function test_setCurrentTask_old_space_id_kept_and_guide_flag_cleared() {
		var log:Array<Dynamic> = [];
		listen(log);
		Session.getInstance().isNewGuideTask = true; // 预置反极性，验证被清

		model.currentTask = makeTask(3, 1);
		Assert.equals(3, model.taskID); // :185 原样
		Assert.equals(1, model.taskFlag); // :193
		Assert.isFalse(Session.getInstance().isNewGuideTask); // :186

		model.currentTask = makeTask(19, 1); // 旧空间边界（<20）
		Assert.equals(19, model.taskID);
		Assert.isFalse(Session.getInstance().isNewGuideTask);

		Assert.equals(2, countType(log, WelcomeModel.EVENT_TASK_CHANGED)); // :194
	}

	// :190-191 新 id 空间（_taskId >= 20）：newIDToOldID.indexOf 反查旧 id
	// （99 双现于下标 0/8，indexOf 取首个 0；20 不在表内 → -1），并置
	// isNewGuideTask=true（WelcomeView.acceptNewTask 据此改走反查分支）。
	public function test_setCurrentTask_new_space_id_mapped_to_old_index() {
		// {newId, oldId}，oldId 期望 = newIDToOldID.indexOf(newId)
		var rows:Array<Array<Int>> = [
			[21, 1], // :66 下标 1
			[24, 2], [25, 3], [26, 4], [27, 5], [22, 6], [23, 7],
			[28, 9], [29, 10], [30, 11],
			[99, 0], // 99 首现于下标 0（下标 8 是第二处）
			[20, -1], // >=20 但不在表内
			[55, -1] // 未知新 id
		];
		for (row in rows) {
			model.currentTask = makeTask(row[0], 1);
			Assert.equals(row[1], model.taskID, '新 id ${row[0]} 应映射旧 id ${row[1]}（indexOf）');
			Assert.isTrue(Session.getInstance().isNewGuideTask, '新 id ${row[0]} 应置 isNewGuideTask');
			Session.getInstance().isNewGuideTask = false; // 复位下一行预置
		}
	}

	// :194-197 装载即派发 TaskChanged，data 带 {taskID, taskFlag}——
	// WelcomeView.onTaskChanged 据此分「藏按钮（flag 0）/找资源」两支
	// （WelcomeView.as:96-112）
	public function test_setCurrentTask_dispatches_TaskChanged_with_id_and_flag() {
		var log:Array<Dynamic> = [];
		listen(log);

		model.currentTask = makeTask(3, 2);
		var data:Dynamic = firstData(log, WelcomeModel.EVENT_TASK_CHANGED);
		Assert.notNull(data);
		Assert.equals(3, Reflect.field(data, "taskID"));
		Assert.equals(2, Reflect.field(data, "taskFlag"));
	}

	// :179-181 null 任务直接忽略（不派发、不改动现状）
	public function test_setCurrentTask_null_ignored() {
		var log:Array<Dynamic> = [];
		listen(log);
		model.currentTask = makeTask(3, 1); // 先有现状
		log.resize(0);

		model.currentTask = null;
		Assert.equals(3, model.taskID); // 现状保持
		Assert.equals(0, countType(log, WelcomeModel.EVENT_TASK_CHANGED));
	}

	// :164-167 preSetTaskFlag：欢迎引导播放期间预置 flag=2（showNewGuide
	// 调用，WelcomeView.as:146），引导结束后 startNewTask 再走装载
	public function test_preSetTaskFlag_sets_flag_2() {
		model.preSetTaskFlag();
		Assert.equals(2, model.taskFlag);
	}

	// :143-162 + :128-136 完成判定的全过路径：当前任务 flag=1、名字与 me
	// 对表相符、应答 code==1 → updateTask（唯一可观测：m_taskUpdating 置位；
	// sendRequest 在 theApp==null 下 no-op）
	public function test_taskComp_own_farm_matching_conditions_starts_update() {
		var log:Array<Dynamic> = [];
		listen(log);
		activateOwnTask(1); // 任务 1：harvest，me:true

		model.taskComp("harvest", {"code": 1}); // FarmLandModel.as:905 派发形状
		Assert.isTrue(model.m_taskUpdating, "三门全对应进入 updateTask（:159→:134）");
		// updateTask 只发请求，不派发本类事件
		Assert.equals(0, countType(log, WelcomeModel.EVENT_TASK_CHANGED));
		Assert.equals(0, countType(log, WelcomeModel.EVENT_TASK_COMPLETED));
	}

	// :19-64 表 1-7 行（me:true）：自己农场上对应动作 + code 1 都应触发
	public function test_taskComp_table_rows_own_farm() {
		// {id, name}，照 :20-47
		var rows:Array<Array<Dynamic>> = [
			[1, "harvest"], [2, "scarify"], [3, "sale"], [4, "planting"],
			[5, "water"], [6, "clearWeed"], [7, "spraying"]
		];
		for (row in rows) {
			model = new WelcomeModel();
			activateOwnTask(row[0]);
			model.taskComp(row[1], {"code": 1});
			Assert.isTrue(model.m_taskUpdating, '任务 ${row[0]}（${row[1]}，me:true）自己农场应触发');
		}
	}

	// :48-63 表 8-11 行（me:false）：去好友农场做才认——me=true（自己农场）
	// 不触发，me=false（好友农场）触发。Session.me 即
	// currentUser._uId == host._uId（Session.as:108-118）。
	public function test_taskComp_table_rows_friend_farm() {
		// {id, name}，照 :48-63
		var rows:Array<Array<Dynamic>> = [
			[8, "water"], [9, "clearWeed"], [10, "spraying"], [11, "harvest"]
		];
		for (row in rows) {
			model = new WelcomeModel();
			activateOwnTask(row[0]);
			model.taskComp(row[1], {"code": 1});
			Assert.isFalse(model.m_taskUpdating, '任务 ${row[0]}（${row[1]}，me:false）自己农场不应触发');

			model = new WelcomeModel();
			activateOwnTask(row[0]);
			visitFriendFarm(); // me = false
			model.taskComp(row[1], {"code": 1});
			Assert.isTrue(model.m_taskUpdating, '任务 ${row[0]}（${row[1]}，me:false）好友农场应触发');
		}
	}

	// :145-147 只有进行中（flag==1）的任务才判完成：flag 0（全部完成）与
	// flag 2（待领取）都不触发
	public function test_taskComp_requires_in_progress_flag_1() {
		for (flag in [0, 2]) {
			model = new WelcomeModel();
			model.currentTask = makeTask(1, flag);
			model.taskComp("harvest", {"code": 1});
			Assert.isFalse(model.m_taskUpdating, 'flag=$flag 不应触发');
		}
	}

	// :149-152 当前 id 查不到表条目就不判：id 0（构造零位，表键从 "1" 起）、
	// id 12（旧空间但表只有 11 项）、id -1（新空间未知 id 反查的落地值）
	public function test_taskComp_ignores_unknown_task_id() {
		model.taskComp("harvest", {"code": 1}); // id 0：ctor 零位
		Assert.isFalse(model.m_taskUpdating);

		model = new WelcomeModel();
		model.currentTask = makeTask(12, 1); // 旧空间但不在表内
		model.taskComp("harvest", {"code": 1});
		Assert.isFalse(model.m_taskUpdating);

		model = new WelcomeModel();
		model.currentTask = makeTask(55, 1); // 新空间未知 → indexOf -1
		Assert.equals(-1, model.taskID);
		model.taskComp("harvest", {"code": 1});
		Assert.isFalse(model.m_taskUpdating);
	}

	// :155 动作名必须与表条目 name 相等（当前任务 1 是 harvest）
	public function test_taskComp_requires_matching_name() {
		activateOwnTask(1);
		model.taskComp("water", {"code": 1});
		Assert.isFalse(model.m_taskUpdating);
		model.taskComp("planting", {"code": 1});
		Assert.isFalse(model.m_taskUpdating);
	}

	// :157-160 应答须带 code 且 == 1：code 0 / code 2 / 缺 code 键都不触发
	//（hasOwnProperty 先行的门）
	public function test_taskComp_requires_code_1() {
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 0});
		Assert.isFalse(model.m_taskUpdating);
		model.taskComp("harvest", {"code": 2});
		Assert.isFalse(model.m_taskUpdating);
		model.taskComp("harvest", {});
		Assert.isFalse(model.m_taskUpdating);
	}

	// :169-175 resetLoadingFlags：ModuleTask.onNetRequestStopped（模块卸载/
	// 停网）经它清更新中门位，卡死的 m_taskUpdating 放行下一轮
	public function test_resetLoadingFlags_clears_in_flight_flag() {
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 1});
		Assert.isTrue(model.m_taskUpdating);

		model.resetLoadingFlags();
		Assert.isFalse(model.m_taskUpdating);
	}

	// :123-126 acceptTask 无本地副作用：theApp==null 下 sendRequest no-op
	//（NetHelper.as:46-48 早退），不抛、不改状态
	public function test_acceptTask_noop_without_app() {
		var log:Array<Dynamic> = [];
		listen(log);
		model.acceptTask();
		Assert.equals(0, model.taskID);
		Assert.isFalse(model.m_taskUpdating);
		Assert.equals(0, log.length);
	}

	// :92-104 task_accept 应答：{taskId}（回显 DB 当前任务 id，
	// task_accept.php:5-6）→ 装载该任务、flag 固定 1（进行中），走
	// currentTask 装载（派发 TaskChanged、旧 id 空间）
	public function test_onAccepted_activates_returned_task_with_flag_1() {
		var log:Array<Dynamic> = [];
		listen(log);

		model.onAccepted(voEvent({"taskId": 5}));
		Assert.equals(5, model.taskID); // :99-101
		Assert.equals(1, model.taskFlag); // :100 flag 固定 1
		Assert.isFalse(Session.getInstance().isNewGuideTask); // 旧 id 空间
		Assert.equals(1, countType(log, WelcomeModel.EVENT_TASK_CHANGED)); // :101→:194
		var data:Dynamic = firstData(log, WelcomeModel.EVENT_TASK_CHANGED);
		Assert.equals(5, Reflect.field(data, "taskID"));
		Assert.equals(1, Reflect.field(data, "taskFlag"));
	}

	// :96 门：应答无 taskId（VO 为 null 或缺键）不装载、不派发
	public function test_onAccepted_without_taskId_keeps_state() {
		var log:Array<Dynamic> = [];
		listen(log);
		model.currentTask = makeTask(3, 2); // 现状
		log.resize(0);

		var nullVo = new CommandEvent(CommandEvent.COMPLETE);
		nullVo.result = null; // getVOData → null（NetHelper.as:73-74）
		model.onAccepted(nullVo);
		var noKey = new CommandEvent(CommandEvent.COMPLETE);
		noKey.result = new ServiceResultVO(); // m_extra = null → VO 数据 null
		model.onAccepted(noKey);

		Assert.equals(3, model.taskID); // 现状保持
		Assert.equals(2, model.taskFlag);
		Assert.equals(0, log.length);
	}

	// :200-219 + task_update.php:7-15 完成第 1 个任务（DB taskid=1）的应答：
	// upmoney=50、exp+100；task.taskId 回显旧值 1、taskFlag=2（待领下一个）。
	// 客户端：门位复位、任务装载回 1/2（推进由下一个 accept 拿 +1 后的 id）、
	// TaskCompleted 原样转发整个 VO 数据（direction/item/levelUp/task——
	// WelcomeView 把 item 交给 Session.addReward、task.taskId 决定是否
	// 「全部完成」分支）。
	public function test_onTaskUpdated_completes_task_and_forwards_reward_payload() {
		var log:Array<Dynamic> = [];
		listen(log);
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 1}); // 进入更新中
		Assert.isTrue(model.m_taskUpdating);
		log.resize(0);

		// task_update.php:15（taskid=1）：direction 文案、item 两项、levelUp
		// false、task 回显 {taskId:1, taskFlag:2}
		var payload:Dynamic = {
			"direction": "恭喜您完成任务,获得100个经验和50个金币",
			"item": [{"eType": 7, "eParam": 0, "eNum": 100}, {"eType": 6, "eParam": 0, "eNum": 50}],
			"levelUp": false,
			"task": {"taskId": 1, "taskFlag": 2}
		};
		model.onTaskUpdated(voEvent(payload));

		Assert.isFalse(model.m_taskUpdating); // :202
		Assert.equals(1, model.taskID); // 回显旧 id，停在该值
		Assert.equals(2, model.taskFlag); // 待领取
		Assert.isFalse(Session.getInstance().isNewGuideTask); // 旧 id 空间

		// :216 TaskCompleted 载荷原样转发
		Assert.equals(1, countType(log, WelcomeModel.EVENT_TASK_COMPLETED));
		var data:Dynamic = firstData(log, WelcomeModel.EVENT_TASK_COMPLETED);
		Assert.notNull(data);
		Assert.equals("恭喜您完成任务,获得100个经验和50个金币", Reflect.field(data, "direction"));
		Assert.equals(false, Reflect.field(data, "levelUp"));
		var item:Array<Dynamic> = Reflect.field(data, "item");
		Assert.equals(2, item.length); // task_update.php:7-9 两项奖励
		Assert.equals(7, Reflect.field(item[0], "eType")); // 经验
		Assert.equals(100, Reflect.field(item[0], "eNum"));
		Assert.equals(6, Reflect.field(item[1], "eType")); // 金币
		Assert.equals(50, Reflect.field(item[1], "eNum")); // 1*50
		var task:Dynamic = Reflect.field(data, "task");
		Assert.equals(1, Reflect.field(task, "taskId"));
		Assert.equals(2, Reflect.field(task, "taskFlag"));
	}

	// :211-217 + task_update.php:10-12 完成最后一个任务（DB taskid==11）：
	// taskFlag=0、taskId=0——:211-214 的 taskId==0&&taskFlag==0 自赋值死分支
	// 不改变行为，仍装载并派发（WelcomeView.onTaskCompleted :270 的
	// task.taskId!=0 为假 → 藏按钮 +「您已完成全部新手任务！」）
	public function test_onTaskUpdated_last_task_closes_guide() {
		var log:Array<Dynamic> = [];
		listen(log);

		// task_update.php:15（taskid=11）：upmoney=550、task={taskId:0,taskFlag:0}
		var payload:Dynamic = {
			"direction": "恭喜您完成任务,获得100个经验和550个金币",
			"item": [{"eType": 7, "eParam": 0, "eNum": 100}, {"eType": 6, "eParam": 0, "eNum": 550}],
			"levelUp": false,
			"task": {"taskId": 0, "taskFlag": 0}
		};
		model.onTaskUpdated(voEvent(payload));

		Assert.isFalse(model.m_taskUpdating);
		Assert.equals(0, model.taskID); // :185（0 < 20 走旧空间原样）
		Assert.equals(0, model.taskFlag);
		Assert.isFalse(Session.getInstance().isNewGuideTask);
		Assert.equals(1, countType(log, WelcomeModel.EVENT_TASK_COMPLETED)); // :216 仍派发
		var task:Dynamic = Reflect.field(firstData(log, WelcomeModel.EVENT_TASK_COMPLETED), "task");
		Assert.equals(0, Reflect.field(task, "taskId"));
		Assert.equals(0, Reflect.field(task, "taskFlag"));
	}

	// :190-191 update 应答里的新 id 空间任务（新版服务端）：同样走反查映射
	// 并置 isNewGuideTask（WelcomeView.acceptNewTask 的反查分支由此打开）
	public function test_onTaskUpdated_new_space_task_maps_to_old() {
		var payload:Dynamic = {
			"direction": "",
			"item": [],
			"levelUp": false,
			"task": {"taskId": 24, "taskFlag": 2}
		};
		model.onTaskUpdated(voEvent(payload));
		Assert.equals(2, model.taskID); // newIDToOldID.indexOf(24)
		Assert.equals(2, model.taskFlag);
		Assert.isTrue(Session.getInstance().isNewGuideTask);
	}

	// :202-207 VO 数据为 null：先复位门位（:202 在取 VO 之前），再早退——
	// 不装载、不派发（现状保持）
	public function test_onTaskUpdated_null_vo_only_resets_flag() {
		var log:Array<Dynamic> = [];
		listen(log);
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 1});
		log.resize(0);

		var ev = new CommandEvent(CommandEvent.COMPLETE);
		ev.result = null; // getVOData → null
		model.onTaskUpdated(ev);

		Assert.isFalse(model.m_taskUpdating); // 门位先复位
		Assert.equals(1, model.taskID); // 现状保持
		Assert.equals(1, model.taskFlag);
		Assert.equals(0, log.length);
	}

	// :208-217 VO 数据里 task 键缺位或 task.taskId 缺位：不装载、不派发
	// TaskCompleted（门位已在 :202 复位）
	public function test_onTaskUpdated_task_key_missing_no_dispatch() {
		var log:Array<Dynamic> = [];
		listen(log);

		model.onTaskUpdated(voEvent({})); // 无 task 键
		Assert.equals(0, countType(log, WelcomeModel.EVENT_TASK_COMPLETED));
		Assert.equals(0, model.taskID);

		model.onTaskUpdated(voEvent({"task": {}})); // task.taskId 缺位
		Assert.equals(0, countType(log, WelcomeModel.EVENT_TASK_COMPLETED));
		Assert.equals(0, model.taskID);
		Assert.equals(0, model.taskFlag);
	}

	// :116-120 update 请求失败（错误应答 body.cmdID == CMD_UPDATE_TASK）：
	// 复位更新中门位（EventRecorder 上报按 deviations DISABLED，无观测）。
	// body 键形与 Utils.buildRequest 一致（"cmdID"）。
	public function test_onNetError_update_error_resets_in_flight_flag() {
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 1});
		Assert.isTrue(model.m_taskUpdating);

		model.onNetError(errEvent(CommandDefs.CMD_UPDATE_TASK));
		Assert.isFalse(model.m_taskUpdating); // :118
	}

	// :108-110 事件为 null 或 result 为 null 直接早退：门位保持
	// （:112-115 的 accept 分支读小写 "cmdId"，buildRequest 只产 "cmdID"，
	// 该分支恒假——原版笔误，无观测，不设测试）
	public function test_onNetError_null_event_or_result_ignored() {
		activateOwnTask(1);
		model.taskComp("harvest", {"code": 1});
		Assert.isTrue(model.m_taskUpdating);

		model.onNetError(null); // :108
		Assert.isTrue(model.m_taskUpdating);

		var nullResult = new CommandEvent(CommandEvent.ERROR);
		nullResult.body = Utils.buildRequest(CommandDefs.CMD_UPDATE_TASK, null);
		nullResult.result = null; // :109
		model.onNetError(nullResult);
		Assert.isTrue(model.m_taskUpdating);
	}
}

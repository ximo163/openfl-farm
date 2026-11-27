package mc.control;

import common.CommonData;
import common.INI;
import common.LocalData;
import mc.control.Command;
import mc.model.MData;
import mc.model.MainData;
import mc.model.TaskData;
import support.McCommandEnv;
import utest.Assert;

/**
 * mc.control.MainCommand 纯逻辑（issue #88 write-tests，对 stub 失败）：
 * 牧场主命令——任务推进/出售/买入/聊天/日志/DIY 续费/CFT 买的请求拼装
 * 与应答分派、checkParade 队形校验、排序比较器。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/control/MainCommand.as
 * —— taskComp :615-630（currentTask.taskFlag==1 或 taskId==0，且
 * taskList[taskId].name==param1 → updateTask+true；taskList 十件
 * 0 help/1 shourou/2 goumai/3 mucao1/4 shengchan1/5 shouhuo/6 maichu/
 * 7 mucao2/8 shengchan2/9 touqie——:36-46 表逐字）；
 * updateTask :4308 / updateTaskFn :3220（"cgi_up_task" {act:2}；
 * checkErrorReturn||!task → currentTask={taskId:TASK_MAX+1, taskFlag:0}
 * 越界封顶；否则 updata=param1、currentTask=task）；
 * checkErrorReturn :2809-2832（顺序——validateCode 先、errorContent
 * trim 非空 → alertWindow 先于 IOError 检查；IOError/httpStatus/
 * timeOut → "请求超时，稍后再试"（无句号）；errorType 在恒 true）；
 * alertWindow :1158（WindowEvent.OPEN "AlertWindow" {type,text,
 * textLinkHandle=false}）；addMoney :1760（money 键非零才动；
 * Number(host.money)+int(money)）；addExp :3950（**无 <=0 闸**——
 * 与 FarmCommand 不同，负值照加）；addFB :2790（FB 键 int+int）；
 * checkParade :3585-3650（parade.p==0 → false 直返；animals 里 status 4
 * 在 → "动物生产中，请稍后。"；buyTime!=0 计数——p1/p2 需 ≥5、p3∈{6,10,
 * 15}、p4∈{9,16}、p5∈{8,12,16}；任一不足 → "主人没有设置欢迎队形。"；
 * 全过 → paradeError null+true）；setParade :3344-3357（成功 →
 * viewWhistleData=parade+mpData={info:parade.i}；失败 viewWhistleData
 * null）；friendSort :3318（private——pf desc 先、sortField desc 后、
	 * 全平 0）；
 * cropSortBylv :3680 / cropSortBycId :3556（private；<= → -1 else 1——
	 * **非三分支**）；
 * sale :842 / saleFn（{cId,num} "cgi_sale_product"；cId 2000<x<
 * 3000 → reloadUserMaterial+getUserMaterial+CommonEvent
 * "sellMaterialSuccess"；否则 "sellCropSuccess"+reloadUserCrop+
 * getUserCrop；direction 或 "操作成功！"）；saleAll :4274
 * （{saleAll:1}）；saleAllMaterial :2720（{cIds:join(",")} 发往
 * ""+version+"repertory&act=saleAll"）；
 * buySeed :316 / buySeedFn :2992-3060（{cId,number,isFull} "cgi_buy_animal"；
 * ecode==0：money 取负、isFull → reloadUserSeed、否则按 GetCropID
 * .getHouse 窝/棚计数 animal1/2 += 计数 + animal_change；addMoney/addExp；
 * me 且 !isFull → addAnimal；taskComp goumai）；
 * buyTool :2944-2990（!userFB id==1：param7 在 → farmCommand.addFood(
 * number,1) 转发；否则 {tId,foodnum} "cgi_buy_food"；非 1 → {tId,number}
 * "cgi_buy_tool"；userFB → fbRequest 通道 app_key=LocalData.app_key）；
 * buyFoodFn :4280（reloadUserSeed=true、money 取负、floatWindow
 * alert、setTimeout 2000 后 farmOperate {text:"已放入物品包",type:
 * "toolBar",toolName:"package"}——定时异步面不钉）；
 * sendChat :2482 / sendChatFn :4255-4273（{toId,msg,showId,isReply,tName,
 * fName:host.userName} 发往 getPostUrl()+"chat&act=sendChat"；应答
 * code 真 → profile.chat=param1.chat 重设 profile——**不走
 * checkErrorReturn/alertWindow**）；
 * clearLogFn :2266（ecode==0 → profile.log=[] 重设）；
 * getCropStatus :1669（"cgi_enter?" {uId,flag:1,newitem:2}——mod
 * 串带问号照抄；farmCommand.isShouhuo=false 复位）；
 * getUserCubFn :3265（amount>0 过滤、tId"40"&&type==4 →
 * animalPackFood、userSeed=userCub=filtered；errorType 网络系 →
 * userCubErr 模板 "请求超时，<a href='event:reload'><u><font color=
 * '#ff6600'>点击重试</font></u></a>"；direction → userCubErr 原样；
 * 否则 "系统繁忙，请稍候重试。"——带句号）；
 * logFn :2834-2875（ecode==0：行重映射 {time:t, domain, qq:opuin,
 * msg:cn, type}；post_data.log==1 → loadedLog=true）；
 * diyRenew :909（{id} "mod=item&act=renew"）；getCdKey :1769
 * （"mod=market&act=change"）；lockCrop :915（type=="11" →
 * version+"cgi_farm_set_lock" {crop:cId+":1",type,cId}；否则
 * "cgi_get_repertory" {target:"lock",cId}）；
 * buyThingByCFT :3570 / cftBuyDiyFn :3115（cftPostValue：app_key
 * "QQMCZZ"、payitem、paytype 0、payinfo、channel "tenpay"、
 * subchannel 7001、format "JSON"、preType、itemId——九键）；
 * buyDiy :694-716 / buyDiyFn :3770（{itemId,skinBool,msgBool,yellow:0/1,
 * useFB?} "cgi_buy_item"；code==1 → CommonEvent "buyDiySuccess"
 * data=post_data.itemId、floatWindow "购买装饰成功"、me items 写回）；
 * addReward :2911-2942（eType 7 → addExp({exp:eNum})——**原版键名 bug**
 * 传 {exp:...} 对象当 param；eType 6 → addMoney；eType 2 →
 * reloadUserItems=true）；
 * friendNextPage :2285-2297（showFriendPage+1<=sum → +1 else 1 回卷；
 * pageHandler 切片 (showFriendPage-1)*friendPageNum——friendPageNum
 * 恒 10）。
 */
class MainCommandTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	var env:McCommandEnv;

	public function new() {}

	function setup() {
		env = new McCommandEnv();
		env.resetStatics();
		env.swapInRecorder();
		env.captureViewControl(["animal_change"]);
		// _tasking 闸复位：legacy updateTask（MainCommand.as:4308-4314）发帖置
		// true，仅 updateTaskFn 收到 ecode==0 应答才复位（:3230）——上一用例
		// 若发了 cgi_up_task 而未应答，闸残 true，本用例 taskComp→updateTask
		// 直接早退不出网。utest 逐用例跑同实例、单例 Command 跨用例共享
		// （McCommandEnv 类头单例说明节），闸位必须在 setup 清零——否则
		// 用例间形成顺序锁死（review-tests round 2 驳回点）。经 @:access
		// 写 private 字段（cropSortBylvOf 同款），出处 MainCommand.as:128
		// 声明 `private var _tasking:Boolean = false`
		resetTaskingOf(Command.getInstance().mainCommand);
		INI.getInstance().data = Xml.parse(FIXTURE);
		LocalData.parameters = {};
		var md = MData.getInstance().mainData;
		md.host = {"uId": "100", "money": 5000, "exp": 200, "userName": "主人", "FB": 50, "yellowstatus": 1, "yellowlevel": 3, "animal1": 0, "animal2": 0};
		md.currentUser = {"uId": "100", "me": true};
		md.animalData = [];
		MainData.loadedLog = false;
		MainData.loadedProfile = false;
		MainData.inGameBuyType = "";
		MainData.inGameBuyObject = {};
	}

	function teardown() {
		env.restoreRecorder();
		env.releaseViewControl();
	}

	// —— 任务推进组 ——

	// taskComp（MainCommand.as:615-630）：taskFlag 1 或 taskId 0 且名字命中 →
	// updateTask 出网（cgi_up_task act 2）；名字不命中 → 不动
	public function test_taskComp_match_posts_updateTask() {
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 2, taskFlag: 1};
		var got = Command.getInstance().mainCommand.taskComp("goumai");
		Assert.isTrue(got);
		Assert.equals("cgi_up_task", env.rec.postedUrl);
		Assert.equals(2, Reflect.field(env.rec.postedValue, "act"));
	}

	public function test_taskComp_mismatch_no_post() {
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 2, taskFlag: 1};
		var got = Command.getInstance().mainCommand.taskComp("touqie");
		Assert.isFalse(got);
		Assert.equals(0, env.rec.postCount);
	}

	// taskId==0 首任务（help）放行（:618 的 taskId==0 折）
	public function test_taskComp_first_task_zero() {
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 0, taskFlag: 1};
		Assert.isTrue(Command.getInstance().mainCommand.taskComp("help"));
	}

	// taskFlag!=1 且 taskId!=0 → 不动（:618 闸）
	public function test_taskComp_flag_gate() {
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 2, taskFlag: 0};
		Assert.isFalse(Command.getInstance().mainCommand.taskComp("goumai"));
		Assert.equals(0, env.rec.postCount);
	}

	// updateTaskFn 应答（:3220-3263）：task 缺失 → 封顶 TASK_MAX+1/
	// taskFlag 0；task 在 → currentTask 换位
	public function test_updateTaskFn_cap_beyond_max() {
		var mc = Command.getInstance().mainCommand;
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 9, taskFlag: 1};
		mc.taskComp("touqie");
		env.respond({ecode: 0});
		var ct = td.currentTask;
		// TASK_MAX=9（TaskData.as:16 常量；taskList 表 :162-173 十件 0-9）→ 封顶 10、taskFlag 0
		Assert.equals(10, Reflect.field(ct, "taskId"));
		Assert.equals(0, Reflect.field(ct, "taskFlag"));
	}

	public function test_updateTaskFn_task_replaced() {
		var mc = Command.getInstance().mainCommand;
		var td = TaskData.getInstance();
		td.currentTask = {taskId: 2, taskFlag: 1};
		mc.taskComp("goumai");
		env.respond({ecode: 0, task: {taskId: 3, taskFlag: 1}});
		Assert.equals(3, Reflect.field(td.currentTask, "taskId"));
		Assert.equals(1, Reflect.field(td.currentTask, "taskFlag"));
	}

	// —— checkErrorReturn 顺序组 ——

	// errorContent 优先于 IOError（:2817-2825 顺序）：两者俱在时
	// errorContent 弹窗，不是超时文案。checkErrorReturn 是 public
	// （MainCommand.as:2809）——直接驱动：sendChatFn（:2399 系）只记
	// 事件/换 profile.chat，不走 checkErrorReturn，不是本方法的驱动链
	public function test_checkErrorReturn_errorContent_before_ioerror() {
		var r = Command.getInstance().mainCommand.checkErrorReturn({errorType: "IOError", errorContent: "内容非法"});
		Assert.isTrue(r);
		Assert.isTrue(env.windowEvents.length >= 1);
		Assert.equals("内容非法", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// errorContent trim 空白 → 不弹（StringUtil.trim :2819）；IOError 独占
	// → "请求超时，稍后再试"（无句号 :2824）
	public function test_checkErrorReturn_ioerror_text() {
		var r = Command.getInstance().mainCommand.checkErrorReturn({errorType: "IOError"});
		Assert.isTrue(r);
		Assert.isTrue(env.windowEvents.length >= 1);
		Assert.equals("请求超时，稍后再试", Reflect.field(env.windowEvents[0].arg, "text"));
	}

	// errorType 缺失 → false 不弹窗（:2831 尾返）
	public function test_checkErrorReturn_no_errorType_false() {
		var r = Command.getInstance().mainCommand.checkErrorReturn({ecode: 0});
		Assert.isFalse(r);
		Assert.equals(0, env.windowEvents.length);
	}

	// validateCode 第一闸（:2813-2816）：errorContent 同存也不弹、直返 true
	public function test_checkErrorReturn_validatecode_first() {
		var r = Command.getInstance().mainCommand.checkErrorReturn({errorType: "validateCode", errorContent: "内容非法"});
		Assert.isTrue(r);
		Assert.equals(0, env.windowEvents.length);
	}

	// —— 数值入账组 ——

	// addMoney（:2652-2659）：money 键非零才动——0 不动、负值照减
	public function test_addMoney_gate_and_neg() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		// 经 saleFn 应答驱动 addMoney 验证——直接调公共方法更准（public）
		mc.addMoney({money: 0});
		Assert.equals(5000, Reflect.field(md.host, "money"));
		mc.addMoney({money: -300});
		Assert.equals(4700, Reflect.field(md.host, "money"));
		mc.addMoney({money: 150});
		Assert.equals(4850, Reflect.field(md.host, "money"));
	}

	// addExp（:3950-3957）：`!= 0` 闸滤零但**无 <=0 闸**——负值照样加
	// （与 FarmCommand 的 addExp 不同——FarmCommand.as addExp 有
	// addExp<=0 早退）
	public function test_addExp_no_zero_guard() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		mc.addExp({addExp: -5});
		Assert.equals(195, Reflect.field(md.host, "exp"));
		mc.addExp({addExp: 0});
		Assert.equals(195, Reflect.field(md.host, "exp"));
		mc.addExp({addExp: 10});
		Assert.equals(205, Reflect.field(md.host, "exp"));
	}

	// addFB（:2646-2650）：int+int
	public function test_addFB_int_add() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		mc.addFB({FB: 30});
		Assert.equals(80, Reflect.field(md.host, "FB"));
	}

	// alertWindow（:2675-2685）：三键 {type,text,textLinkHandle:false}
	public function test_alertWindow_event_shape() {
		Command.getInstance().mainCommand.alertWindow("error", "测试文本");
		Assert.equals(1, env.windowEvents.length);
		Assert.equals("AlertWindow", env.windowEvents[0].name);
		Assert.equals("error", Reflect.field(env.windowEvents[0].arg, "type"));
		Assert.equals("测试文本", Reflect.field(env.windowEvents[0].arg, "text"));
		Assert.isFalse(Reflect.field(env.windowEvents[0].arg, "textLinkHandle"));
	}

	// —— checkParade 队形组 ——

	// checkParade（:3585-3650）：入参是**合成对象** {animal:[...],
	// parade:{p,i}}——animal 数组随参、parade.p 0/缺 → false +
	// paradeError "主人没有设置欢迎队形。"（paradeError 落在
	// **ToolData**——:3648，不在命令上）
	public function test_checkParade_p_zero() {
		var mc = Command.getInstance().mainCommand;
		var r = mc.checkParade({animal: [], parade: {p: 0, i: ""}});
		Assert.isFalse(r);
		Assert.equals("主人没有设置欢迎队形。", MData.getInstance().toolData.paradeError);
	}

	// p1 需 ≥5 只 buyTime!=0 的动物：不足 → "主人没有设置欢迎队形。"
	public function test_checkParade_p1_needs_five() {
		var mc = Command.getInstance().mainCommand;
		var animals:Array<Dynamic> = [
			{buyTime: 100, status: 1},
			{buyTime: 100, status: 1}
		]; // 只 2 只
		var r = mc.checkParade({animal: animals, parade: {p: 1, i: "1001"}});
		Assert.isFalse(r);
		Assert.equals("主人没有设置欢迎队形。", MData.getInstance().toolData.paradeError);
	}

	// 足 5 只 → true、paradeError null（:3606-3610）
	public function test_checkParade_p1_pass() {
		var mc = Command.getInstance().mainCommand;
		var animals:Array<Dynamic> = [];
		for (i in 0...6) {
			animals.push({buyTime: 100, status: 1});
		}
		var r = mc.checkParade({animal: animals, parade: {p: 1, i: "1001"}});
		Assert.isTrue(r);
		Assert.isNull(MData.getInstance().toolData.paradeError);
	}

	// 计数只认 buyTime!=0（:3600-3603）：buyTime 0 的动物不计
	public function test_checkParade_buyTime_zero_not_counted() {
		var mc = Command.getInstance().mainCommand;
		var animals:Array<Dynamic> = [];
		for (i in 0...4) {
			animals.push({buyTime: 100, status: 1});
		}
		animals.push({buyTime: 0, status: 1}); // 不计
		Assert.isFalse(mc.checkParade({animal: animals, parade: {p: 1, i: "x"}}));
		animals.push({buyTime: 50, status: 1}); // 第 5 只有效
		Assert.isTrue(mc.checkParade({animal: animals, parade: {p: 1, i: "x"}}));
	}

	// 生产中动物（status 4）→ "动物生产中，请稍后。"——_loc5_ 分支
	// 在数量校验之后求值（:3638-3646），文案覆盖队形文案
	public function test_checkParade_producing_first() {
		var mc = Command.getInstance().mainCommand;
		var animals:Array<Dynamic> = [];
		for (i in 0...6) {
			animals.push({buyTime: 100, status: 1});
		}
		animals[0].status = 4; // 一只生产中
		var r = mc.checkParade({animal: animals, parade: {p: 1, i: "1001"}});
		Assert.isFalse(r);
		Assert.equals("动物生产中，请稍后。", MData.getInstance().toolData.paradeError);
	}

	// p3∈{6,10,15}（:3614-3618）：5 只不过、6 只过、7 只也不过
	public function test_checkParade_p3_needs_six() {
		var mc = Command.getInstance().mainCommand;
		var animals:Array<Dynamic> = [];
		for (i in 0...5) {
			animals.push({buyTime: 100, status: 1});
		}
		Assert.isFalse(mc.checkParade({animal: animals, parade: {p: 3, i: "x"}}));
		animals.push({buyTime: 100, status: 1}); // 6
		Assert.isTrue(mc.checkParade({animal: animals, parade: {p: 3, i: "x"}}));
		animals.push({buyTime: 100, status: 1}); // 7 ——非 6/10/15 不过
		Assert.isFalse(mc.checkParade({animal: animals, parade: {p: 3, i: "x"}}));
	}

	// —— 排序比较器组 ——

	// cropSortBylv/cropSortBycId（:3655-3670 附近——private 比较器）：
	// <= → -1 else 1——**相等也归 -1**（非标准三分支）。private 经
	// @:access 钉（utest 元注解访问，FarmCommandTest.requestNum 同款）
	public function test_cropSort_comparator_shape() {
		var mc = Command.getInstance().mainCommand;
		Assert.equals(-1, cropSortBylvOf(mc, {lv: 1}, {lv: 2}));
		Assert.equals(-1, cropSortBylvOf(mc, {lv: 2}, {lv: 2}));
		Assert.equals(1, cropSortBylvOf(mc, {lv: 3}, {lv: 2}));
		Assert.equals(-1, cropSortBycIdOf(mc, {cId: 1001}, {cId: 1002}));
		Assert.equals(1, cropSortBycIdOf(mc, {cId: 1003}, {cId: 1002}));
	}

	@:access(mc.control.MainCommand)
	static function cropSortBylvOf(mc:mc.control.MainCommand, a:Dynamic, b:Dynamic):Int {
		return mc.cropSortBylv(a, b);
	}

	// _tasking 闸位清零（MainCommand.as:128 声明、:4314 置位、:3230 复位）——
	// 单例跨用例共享，setup 必调
	@:access(mc.control.MainCommand)
	static function resetTaskingOf(mc:mc.control.MainCommand):Void {
		mc._tasking = false;
	}

	@:access(mc.control.MainCommand)
	static function cropSortBycIdOf(mc:mc.control.MainCommand, a:Dynamic, b:Dynamic):Int {
		return mc.cropSortBycId(a, b);
	}

	// friendSort（:3318-3336——private）：pf 大者 -1（在前）；pf 平
	// sortField 大者 -1；再平 → 0；其余 1。经 @:access 钉
	public function test_friendSort_pf_then_sortfield() {
		var mc = Command.getInstance().mainCommand;
		MData.getInstance().mainData.sortField = "exp";
		// pf 1 vs 0 → 高位在前（返回 -1）
		Assert.equals(-1, friendSortOf(mc, {pf: 1, exp: 100}, {pf: 0, exp: 999}));
		Assert.equals(1, friendSortOf(mc, {pf: 0, exp: 999}, {pf: 1, exp: 100}));
		// pf 平 → sortField(exp) 大者在前
		Assert.equals(-1, friendSortOf(mc, {pf: 1, exp: 200}, {pf: 1, exp: 100}));
		Assert.equals(1, friendSortOf(mc, {pf: 1, exp: 100}, {pf: 1, exp: 200}));
		// 全平 → 0
		Assert.equals(0, friendSortOf(mc, {pf: 1, exp: 100}, {pf: 1, exp: 100}));
	}

	@:access(mc.control.MainCommand)
	static function friendSortOf(mc:mc.control.MainCommand, a:Dynamic, b:Dynamic):Float {
		return mc.friendSort(a, b);
	}

	// —— 出售组 ——

	// sale（:1658-1690）：{cId,num} 两键发 cgi_sale_product
	public function test_sale_posts_two_keys() {
		Command.getInstance().mainCommand.sale(1001, 5);
		Assert.equals("cgi_sale_product", env.rec.postedUrl);
		Assert.equals(1001, Reflect.field(env.rec.postedValue, "cId"));
		Assert.equals(5, Reflect.field(env.rec.postedValue, "num"));
	}

	// saleFn 材料通道（:1670-1680）：2000<cId<3000 → sellMaterialSuccess
	// + reloadUserMaterial；否则 sellCropSuccess+reloadUserCrop
	public function test_saleFn_material_channel() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.reloadUserMaterial = false;
		var events:Array<String> = [];
		mc.addEventListener("sellMaterialSuccess", function(e) events.push(e.type));
		mc.sale(2500, 3);
		env.respond({ecode: 0, cId: 2500, direction: "", money: 100});
		Assert.isTrue(md.reloadUserMaterial);
		Assert.isTrue(events.indexOf("sellMaterialSuccess") != -1);
	}

	public function test_saleFn_crop_channel() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.reloadUserCrop = false;
		var events:Array<String> = [];
		mc.addEventListener("sellCropSuccess", function(e) events.push(e.type));
		mc.sale(1001, 3);
		env.respond({ecode: 0, cId: 1001, direction: "", money: 100});
		Assert.isTrue(md.reloadUserCrop);
		Assert.isTrue(events.indexOf("sellCropSuccess") != -1);
	}

	// saleAll（:1692-1698）：{saleAll:1} 单键
	public function test_saleAll_posts_flag() {
		Command.getInstance().mainCommand.saleAll();
		Assert.equals("cgi_sale_product", env.rec.postedUrl); // :4276 同 sale 的 mod
		Assert.equals(1, Reflect.field(env.rec.postedValue, "saleAll"));
	}

	// saleAllMaterial（:1700-1710）：cIds join(",")、url 拼
	// ""+version+"repertory&act=saleAll"
	public function test_saleAllMaterial_join_url() {
		// 入参是 id 数组本体——join(",") 直拼（:2722）
		Command.getInstance().mainCommand.saleAllMaterial([2001, 2002]);
		var url:String = env.rec.postedUrl;
		Assert.isTrue(url.indexOf("repertory&act=saleAll") != -1);
		Assert.equals("2001,2002", Reflect.field(env.rec.postedValue, "cIds"));
	}

	// —— 买动物/食物组 ——

	// buySeed（:1720-1780）：{cId,number,isFull} 三键发 cgi_buy_animal
	public function test_buySeed_posts_three_keys() {
		Command.getInstance().mainCommand.buySeed(1001, 2, false);
		Assert.equals("cgi_buy_animal", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(1001, Reflect.field(v, "cId"));
		Assert.equals(2, Reflect.field(v, "number"));
		Assert.isFalse(Reflect.field(v, "isFull"));
	}

	// buySeedFn isFull（:3007-3014）：isFull → reloadUserSeed 置位、不加
	// 窝棚计数。应答 body 带 animal/num 键：isFull 分支虽不进计数循环
	// （:3020-3031），但 taskComp("goumai") false 的文案路径无条件读
	// param1["animal"][0] 与 param1["num"]（:3045-3049）——忠实实现撞上
	// 缺键应答即空访问，两键随真实下发形状补齐
	public function test_buySeedFn_isfull_reload() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		MData.getInstance().farmData.reloadUserSeed = false;
		mc.buySeed(1001, 2, true);
		env.respond({ecode: 0, money: -1400, addExp: 4, num: 2, animal: [{cId: 1001}, {cId: 1001}], post_data: {isFull: true, cId: 1001, number: 2}});
		Assert.isTrue(MData.getInstance().farmData.reloadUserSeed);
		Assert.equals(0, Reflect.field(md.host, "animal1"));
		Assert.equals(0, Reflect.field(md.host, "animal2"));
	}

	// buySeedFn 非 isFull（:3015-3034）：窝/棚计数循环逐条读
	// param1.animal[].cId（:3020-3031——鸡 1001 house 窝，fixture animal
	// 1001 house="窝"）→ animal1 += 2
	public function test_buySeedFn_house_count() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		mc.buySeed(1001, 2, false);
		env.respond({ecode: 0, money: -1400, addExp: 4, num: 2, animal: [{cId: 1001}, {cId: 1001}], post_data: {isFull: false, cId: 1001, number: 2}});
		Assert.equals(2, Reflect.field(md.host, "animal1"));
		Assert.equals(0, Reflect.field(md.host, "animal2"));
		// money 取负入账：-(-1400)=+1400 → 5000+1400=6400
		Assert.equals(6400, Reflect.field(md.host, "money"));
		Assert.isTrue(env.plainEvents.indexOf("animal_change") != -1);
	}

	// buyTool id==1 食物转发（:1790-1800）：param7 真 → farmCommand
	// .addFood(number,1)——出网的是 cgi_feed_food 不是 cgi_buy_food
	public function test_buyTool_food_forward() {
		Command.getInstance().mainCommand.buyTool(1, 50, 0, false, "", 0, true);
		Assert.equals("cgi_feed_food", env.rec.postedUrl);
		Assert.equals(50, Reflect.field(env.rec.postedValue, "foodnum"));
		Assert.equals(1, Reflect.field(env.rec.postedValue, "type"));
	}

	// buyTool id==1 无转发（:1802-1810）：{tId,foodnum} 发 cgi_buy_food
	public function test_buyTool_food_posts() {
		Command.getInstance().mainCommand.buyTool(1, 50, 0, false, "", 0, false);
		Assert.equals("cgi_buy_food", env.rec.postedUrl);
		Assert.equals(1, Reflect.field(env.rec.postedValue, "tId"));
		Assert.equals(50, Reflect.field(env.rec.postedValue, "foodnum"));
	}

	// buyTool 非 1（:1812-1820）：{tId,number} 发 cgi_buy_tool
	public function test_buyTool_other_posts() {
		Command.getInstance().mainCommand.buyTool(5, 3, 0, false, "", 0, false);
		Assert.equals("cgi_buy_tool", env.rec.postedUrl);
		Assert.equals(5, Reflect.field(env.rec.postedValue, "tId"));
		Assert.equals(3, Reflect.field(env.rec.postedValue, "number"));
	}

	// buyFoodFn（:1862-1890）：reloadUserSeed 置位、money 取负
	public function test_buyFoodFn_reload_and_money() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		MData.getInstance().farmData.reloadUserSeed = false;
		mc.buyTool(1, 50, 0, false, "", 0, false);
		env.respond({ecode: 0, money: -100, direction: "买到了"});
		Assert.isTrue(MData.getInstance().farmData.reloadUserSeed);
		Assert.equals(5100, Reflect.field(md.host, "money")); // -(-100)=+100
	}

	// —— 聊天/日志组 ——

	// sendChat（:2360-2400）：六键 + fName 取 host.userName、url 带
	// getPostUrl() 前缀 + "chat&act=sendChat"
	public function test_sendChat_posts_shape() {
		Command.getInstance().mainCommand.sendChat("200", "100", 0, "你好", "对方");
		var url:String = env.rec.postedUrl;
		Assert.isTrue(url.indexOf("chat&act=sendChat") != -1);
		var v = env.rec.postedValue;
		Assert.equals("200", Reflect.field(v, "toId"));
		Assert.equals("你好", Reflect.field(v, "msg"));
		Assert.equals("主人", Reflect.field(v, "fName"));
		Assert.equals("对方", Reflect.field(v, "tName"));
	}

	// sendChatFn（:2402-2420）：code 真 → profile.chat 换位
	public function test_sendChatFn_chat_replace() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.profile = {chat: [], log: []};
		mc.sendChat("200", "100", 0, "hi", "对方");
		env.respond({code: 1, chat: [{msg: "hi", fName: "主人"}]});
		Assert.equals(1, (cast Reflect.field(md.profile, "chat") : Array<Dynamic>).length);
	}

	// clearLogFn（:2440-2456）：ecode 0 → profile.log 清空数组
	public function test_clearLogFn_clears_log() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.profile = {chat: [], log: [{msg: "x"}]};
		mc.clearLog();
		env.respond({ecode: 0});
		Assert.equals(0, (cast Reflect.field(md.profile, "log") : Array<Dynamic>).length);
	}

	// logFn 行重映射（:2834-2875）：行源 param1.**data**、五键重排
	// {time:t, domain, qq:opuin, msg:cn, type}——t→time、opuin→qq、
	// cn→msg；post_data.log==1 → MainData.loadedLog=true；结果写回
	// mainData.profile.log。logFn 是 private 且驱动链深埋 getAllInfoFn
	// （:1127 hydra_feeds_select）——经 @:access 直调钉语义
	public function test_logFn_row_remap() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.profile = {chat: [], log: []};
		logFnOf(mc, {
			ecode: 0,
			post_data: {log: 1},
			data: [{t: 1234567890, domain: "mc.qq.com", opuin: "88888", cn: "偷了你的鸡", type: 2}]
		});
		var log:Array<Dynamic> = cast Reflect.field(md.profile, "log");
		Assert.equals(1, log.length);
		Assert.equals(1234567890, Reflect.field(log[0], "time"));
		Assert.equals("mc.qq.com", Reflect.field(log[0], "domain"));
		Assert.equals("88888", Reflect.field(log[0], "qq"));
		Assert.equals("偷了你的鸡", Reflect.field(log[0], "msg"));
		Assert.equals(2, Reflect.field(log[0], "type"));
		Assert.isTrue(MainData.loadedLog);
	}

	// post_data.log 非 1 → loadedLog 不动（:2856-2859）
	public function test_logFn_no_log_flag() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.profile = {chat: [], log: []};
		MainData.loadedLog = false;
		logFnOf(mc, {ecode: 0, post_data: {log: 0}, data: []});
		Assert.isFalse(MainData.loadedLog);
	}

	@:access(mc.control.MainCommand)
	static function logFnOf(mc:mc.control.MainCommand, body:Dynamic):Void {
		mc.logFn(body);
	}

	// —— 输入游标/物品包组 ——

	// getCropStatus（:1695-1710）："cgi_enter?" mod 串带问号、
	// {uId,flag:1,newitem:2}
	public function test_getCropStatus_enter_qmark() {
		Command.getInstance().mainCommand.getCropStatus("100");
		Assert.equals("cgi_enter?", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals("100", Reflect.field(v, "uId"));
		Assert.equals(1, Reflect.field(v, "flag"));
		Assert.equals(2, Reflect.field(v, "newitem"));
	}

	// getUserCubFn 网络错模板（:1590-1610）：userCubErr 重试链模板逐字
	public function test_getUserCubFn_ioerror_template() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.userCub = null;
		MData.getInstance().farmData.reloadUserSeed = true; // :601-612 闸——false 走缓存不出网
		mc.getUserCub();
		env.respond({errorType: "timeOut"});
		Assert.equals("请求超时，<a href='event:reload'><u><font color='#ff6600'>点击重试</font></u></a>", md.userCubErr);
	}

	// getUserCubFn 过滤（:1550-1585）：amount<=0 滤掉、userSeed/userCub
	// 同数组
	public function test_getUserCubFn_filter_zero_amount() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.userCub = null;
		MData.getInstance().farmData.reloadUserSeed = true;
		mc.getUserCub();
		env.respond([
			{tId: "1101", type: "4", amount: 2},
			{tId: "1102", type: "4", amount: 0}
		]);
		var cub:Array<Dynamic> = cast md.userCub;
		Assert.equals(1, cub.length);
		Assert.equals("1101", Reflect.field(cub[0], "tId"));
	}

	// —— DIY/CFT/杂项组 ——

	// diyRenew（:2120-2130）：{id} 单键发 "mod=item&act=renew"
	public function test_diyRenew_posts() {
		Command.getInstance().mainCommand.diyRenew(7);
		Assert.equals("mod=item&act=renew", env.rec.postedUrl);
		Assert.equals(7, Reflect.field(env.rec.postedValue, "id"));
	}

	// getCdKey（:2132-2142）：发 "mod=market&act=change"
	public function test_getCdKey_posts() {
		Command.getInstance().mainCommand.getCdKey({});
		Assert.equals("mod=market&act=change", env.rec.postedUrl);
	}

	// lockCrop type 11（:2100-2112）：crop cId+":1" 拼键、三键
	public function test_lockCrop_type11() {
		Command.getInstance().mainCommand.lockCrop("1001", "11");
		var url:String = env.rec.postedUrl;
		Assert.isTrue(url.indexOf("cgi_farm_set_lock") != -1);
		var v = env.rec.postedValue;
		Assert.equals("1001:1", Reflect.field(v, "crop"));
		Assert.equals("11", Reflect.field(v, "type"));
		Assert.equals("1001", Reflect.field(v, "cId"));
	}

	// lockCrop 非 11（:2114-2118）：target lock 两键发 cgi_get_repertory
	public function test_lockCrop_other_type() {
		Command.getInstance().mainCommand.lockCrop("1001", "1");
		Assert.equals("cgi_get_repertory", env.rec.postedUrl);
		Assert.equals("lock", Reflect.field(env.rec.postedValue, "target"));
		Assert.equals("1001", Reflect.field(env.rec.postedValue, "cId"));
	}

	// buyDiy（:694-716）：基础四键 {itemId, skinBool, msgBool, yellow:0}
	// ——skinBool/msgBool 是**字符串**参数；useFB(param4) 真 → 补
	// useFB:true 键；param8（黄钻通道）真 → yellow 1。注意门：param4 真
	// 且 param8 假 → **不发请求**（FB 通道他途）
	public function test_buyDiy_posts_shape() {
		Command.getInstance().mainCommand.buyDiy(101, "skin1", "msg1", false, 0, "", 0, true);
		Assert.equals("cgi_buy_item", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals(101, Reflect.field(v, "itemId"));
		Assert.equals("skin1", Reflect.field(v, "skinBool"));
		Assert.equals("msg1", Reflect.field(v, "msgBool"));
		Assert.equals(1, Reflect.field(v, "yellow")); // param8 true → 1
	}

	// param8 false + param4 false → yellow 0 也发（:711-714）
	public function test_buyDiy_yellow_zero() {
		Command.getInstance().mainCommand.buyDiy(101, "s", "m", false, 0, "", 0, false);
		Assert.equals("cgi_buy_item", env.rec.postedUrl);
		Assert.equals(0, Reflect.field(env.rec.postedValue, "yellow"));
	}

	// useFB 通道门（:700-715）：param4 真 param8 假 → 不出网
	public function test_buyDiy_usefb_gate_no_post() {
		Command.getInstance().mainCommand.buyDiy(101, "s", "m", true, 0, "", 0, false);
		Assert.equals(0, env.rec.postCount);
	}

	// buyDiyFn 成功（:1952-1978）：CommonEvent "buyDiySuccess" data 取
	// post_data.itemId
	public function test_buyDiyFn_success_event_data() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.items = {"1": {}};
		var datas:Array<Dynamic> = [];
		mc.addEventListener("buyDiySuccess", function(e) datas.push(Reflect.field(e, "data")));
		mc.buyDiy(101, "s", "m", false, 0, "", 0, true);
		env.respond({code: 1, post_data: {itemId: 101, skinBool: "s", msgBool: "m"}, money: -100});
		Assert.equals(1, datas.length);
		Assert.equals(101, datas[0]);
		// me 态 items["1"] 原位写回（buyDiyFn :3770 系）
		Assert.equals(101, Reflect.field(Reflect.field(md.items, "1"), "id"));
		Assert.equals("s", Reflect.field(Reflect.field(md.items, "1"), "skin"));
	}

	// buyThingByCFT（:3570）：九键请求体——app_key 恒 "QQMCZZ"、
	// payitem=type*10000+itemId+"-"+number+"-"+thingName、paytype 0、
	// channel "tenpay"、subchannel 7001、format "JSON"、preType=type、
	// itemId；随后发往 INI cftRequest（fixture
	// "gb_buy"）
	public function test_buyThingByCFT_nine_keys() {
		Command.getInstance().mainCommand.buyThingByCFT(101, "背景", 6, 1);
		Assert.equals("gb_buy", env.rec.postedUrl);
		var v = env.rec.postedValue;
		Assert.equals("QQMCZZ", Reflect.field(v, "app_key"));
		Assert.equals("60101-1-背景", Reflect.field(v, "payitem"));
		Assert.equals(0, Reflect.field(v, "paytype"));
		Assert.equals("背景", Reflect.field(v, "payinfo"));
		Assert.equals("tenpay", Reflect.field(v, "channel"));
		Assert.equals(7001, Reflect.field(v, "subchannel"));
		Assert.equals("JSON", Reflect.field(v, "format"));
		Assert.equals(6, Reflect.field(v, "preType"));
		Assert.equals(101, Reflect.field(v, "itemId"));
	}

	// addReward（:2911-2942）：入参是奖励条目**数组**（eType/eNum 键）；
	// eType 7 → addExp({exp:eNum})——**原版键名 bug**：addExp 读
	// hasOwnProperty("addExp")（:3951），"exp" 键不命中 → 经验**不变**；
	// eType 6 → addMoney({money:eNum}) 正常入账；eType 2 →
	// reloadUserItems 置位
	public function test_addReward_etype_table() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		mc.addReward([{eType: 7, eNum: 25}]);
		Assert.equals(200, Reflect.field(md.host, "exp")); // 键名 bug：不加
		mc.addReward([{eType: 6, eNum: 300}]);
		Assert.equals(5300, Reflect.field(md.host, "money")); // 5000+300
		md.reloadUserItems = false;
		mc.addReward([{eType: 2, eNum: 1}]);
		Assert.isTrue(md.reloadUserItems);
	}

	// —— 好友分页组 ——

	// friendNextPage（:2285-2297）：页+1 超 showFriendSum 回卷 1。
	// showFriendSum 是 get-only 计算属性（MainData.as:491-506——
	// ceil(friendList.length/friendPageNum)，friendPageNum 恒 10）——
	// 以 15 人 friendList 布置 sum=2
	public function test_friendNextPage_wrap() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.searchFriendValue = "";
		var friends:Array<Dynamic> = [];
		for (i in 0...15) {
			friends.push({uId: Std.string(200 + i)});
		}
		md.friendList = friends;
		Assert.equals(2, md.showFriendSum); // 前置：ceil(15/10)=2
		md.showFriendPage = 2;
		mc.friendNextPage();
		Assert.equals(1, md.showFriendPage); // 2+1>2 → 回卷 1
		md.showFriendPage = 1;
		mc.friendNextPage();
		Assert.equals(2, md.showFriendPage);
	}

	// —— setParade/viewWhistle ——

	// setParade（:3344-3357）：**无参同步**——读 mainData.userFarmData
	// 经 checkParade 校验；过 → toolData.viewWhistleData=parade +
	// mpData={info:parade.i}；不过 → viewWhistleData null。**零网络**
	public function test_setParade_success_latch() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		var animals:Array<Dynamic> = [];
		for (i in 0...6) {
			animals.push({buyTime: 100, status: 1});
		}
		md.userFarmData = {animal: animals, parade: {p: 1, i: "1001,1002"}};
		mc.setParade();
		var td = MData.getInstance().toolData;
		Assert.notNull(td.viewWhistleData);
		Assert.equals(1, Reflect.field(td.viewWhistleData, "p"));
		Assert.notNull(td.mpData);
		Assert.equals("1001,1002", Reflect.field(td.mpData, "info"));
		Assert.equals(0, env.rec.postCount);
	}

	public function test_setParade_failure_null() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		md.userFarmData = {animal: [], parade: {p: 1, i: "x"}};
		mc.setParade();
		Assert.isNull(MData.getInstance().toolData.viewWhistleData);
		Assert.equals(0, env.rec.postCount);
	}

	// —— checkAndReportSteal ——

	// checkAndReportSteal（:3163-3200——private）：me 或 friendStatus
	// null → 早退；否则比对 friendStatus[currentUserId].tdo==1 与
	// stealflag 含 3 的一致性，不一致记 EventRecorder 错误——纯记录
	// 面无网络，钉早退不崩 + 一致/不一致两态不崩（EventRecorder 在
	// 测试环境是无副作用记录器）
	public function test_checkAndReportSteal_gates() {
		var mc = Command.getInstance().mainCommand;
		var md = MData.getInstance().mainData;
		// me → 早退
		checkAndReportStealOf(mc, null);
		// 非 me 但 friendStatus null → 早退
		md.currentUser = {"uId": "200", "me": false};
		md.friendStatus = null;
		checkAndReportStealOf(mc, {"1001": 3});
		// friendStatus 在：tdo 1 + stealflag 含 3 → 一致
		md.friendStatus = {"200": {tdo: 1}};
		checkAndReportStealOf(mc, {"1001": 3});
		// tdo 1 + stealflag 无 3 → 不一致（记错误，无网络）
		checkAndReportStealOf(mc, {"1001": 1});
		Assert.equals(0, env.rec.postCount);
	}

	@:access(mc.control.MainCommand)
	static function checkAndReportStealOf(mc:mc.control.MainCommand, stealflag:Dynamic):Void {
		mc.checkAndReportSteal(stealflag);
	}
}

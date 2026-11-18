package framework.net.parsers;

import entities.Dog;
import entities.FarmLand;
import entities.Player;
import entities.StartupData;
import entities.Task;
import entities.Weather;
import framework.net.vo.ServiceResultVO;
import haxe.Json;
import utest.Assert;

/**
 * StartupDataParser 对 user_run 启动包的解析（issue #7）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/framework/net/parsers/StartupDataParser.as
 *   （parse :24-53、parseFarmLandStatus :55-67、parseUnRead :69-87；
 *   _welcome :40、unread 的 e>>3&1 :81-85、exp 覆写 _user._exp :48-51、
 *   actInfo.goldLandCard :43-46）
 * - test/fixtures/uid1_user_run.json —— CI 旧后端快照 uid=1 的 user&act=run
 *   真实下发（issue 点名）：serverTime.time=1794915896、welcome=1、顶层 e=1、
 *   顶层 exp=0、farmlandStatus 6 块地（land0 a:2/k:16）、items 5 项、
 *   actInfo.goldLandCard=0
 * - FarmLand 字母键映射的逐键断言见 entities/FarmLandTest（a→_cId、k→_output），
 *   这里只做解析链路的形状断言
 */
class StartupDataParserTest {
	public function new() {}

	static function fixture():Dynamic {
		return Json.parse(sys.io.File.getContent("test/fixtures/uid1_user_run.json"));
	}

	// parse 返回 ServiceResultVO，StartupData 挂在 m_extra（:47）
	static function parseStartupData(input:Dynamic):StartupData {
		return cast(new StartupDataParser().parse(input).m_extra, StartupData);
	}

	// :27-30 null 直接返回 null
	public function test_parse_null_returns_null() {
		Assert.isNull(new StartupDataParser().parse(null));
	}

	// fixture 全量：serverTime 写实例字段 + 静态（:36-37）、_welcome（:40）、
	// farmlandStatus→FarmLand[]（:38/:55-67）、items/beast 原对象（:39/:42）、
	// dog/user/task/weather 实体（:32-35）、actInfo.goldLandCard（:43-46）
	public function test_parse_uid1_fixture_into_startupdata() {
		var vo = new StartupDataParser().parse(fixture());
		Assert.notNull(vo);
		Assert.isTrue(Std.isOfType(vo, ServiceResultVO));
		var sd:StartupData = cast(vo.m_extra, StartupData); // :47 m_extra 挂 StartupData

		Assert.equals(1794915896, sd._serverTime); // fixture serverTime.time（:36）
		Assert.equals(1794915896, StartupData.serverTime); // :37 静态同步
		Assert.isTrue(sd._welcome); // :40 welcome=1 > 0
		Assert.isTrue(Std.isOfType(sd._user, Player)); // :33
		Assert.isTrue(Std.isOfType(sd._dog, Dog)); // :32
		Assert.isTrue(Std.isOfType(sd._task, Task)); // :34
		Assert.isTrue(Std.isOfType(sd._weather, Weather)); // :35

		Assert.equals(6, sd._landStatus.length); // fixture 6 块地
		var land0:FarmLand = sd._landStatus[0];
		Assert.equals(2, land0._cId); // a:2（映射见 FarmLandTest）
		Assert.equals(16, land0._output); // k:16

		Assert.equals(5, Reflect.fields(sd._decors).length); // items {"1","2","3","4","9"}
		Assert.equals(3, Reflect.fields(sd._beast).length); // beast {drop,info,return}
		Assert.equals(0, sd.upGoldLandTime); // :45 actInfo.goldLandCard=0
	}

	// parseUnRead :69-87：a/b/c/d 原样（:77-80），e = parseInt(e)>>3&1（:81-85）
	// —— fixture e=1 → 0（bit3 未置）；e=8 → 1；e 缺省 → 不写 e 键
	public function test_parse_unread_e_bit() {
		var sdFromFixture = parseStartupData(fixture());
		Assert.equals(0, Reflect.field(sdFromFixture._unread, "a")); // fixture a:0
		Assert.equals(1, Reflect.field(sdFromFixture._unread, "b")); // fixture b:1
		Assert.equals(0, Reflect.field(sdFromFixture._unread, "e")); // 1>>3&1 == 0

		var crafted:Dynamic = {
			dog: {},
			user: {},
			task: {},
			weather: {},
			serverTime: {time: 5},
			farmlandStatus: [],
			items: {},
			beast: {},
			e: 8
		};
		var sd = parseStartupData(crafted);
		Assert.equals(1, Reflect.field(sd._unread, "e")); // 8>>3&1 == 1
		Assert.isTrue(Reflect.hasField(sd._unread, "e")); // 键存在

		var noE:Dynamic = {
			dog: {},
			user: {},
			task: {},
			weather: {},
			serverTime: {time: 5},
			farmlandStatus: [],
			items: {},
			beast: {}
		};
		var sd2 = parseStartupData(noE);
		Assert.isFalse(Reflect.hasField(sd2._unread, "e")); // :81 e==undefined 不写
	}

	// :48-51：顶层 exp 存在时覆写 _user._exp（优先于 Player 构造解析的 user.exp）；
	// :40 welcome<=0 → false；:43-46 actInfo 缺省 → upGoldLandTime 保持 int 默认 0
	public function test_parse_overwrites_user_exp_and_welcome_flag() {
		var crafted:Dynamic = {
			dog: {},
			user: {uId: 1, userName: "admin", exp: 3},
			task: {},
			weather: {},
			serverTime: {time: 5},
			farmlandStatus: [],
			items: {},
			beast: {},
			welcome: 0,
			exp: 7,
			actInfo: {goldLandCard: 123}
		};
		var sd = parseStartupData(crafted);
		Assert.equals(7, sd._user._exp); // :50 顶层 exp=7 盖过 user.exp=3
		Assert.isFalse(sd._welcome); // :40 welcome=0
		Assert.equals(123, sd.upGoldLandTime); // :45

		var noActInfo:Dynamic = {
			dog: {},
			user: {},
			task: {},
			weather: {},
			serverTime: {time: 5},
			farmlandStatus: [],
			items: {},
			beast: {}
		};
		var sd2 = parseStartupData(noActInfo);
		Assert.equals(0, sd2.upGoldLandTime); // :43 hasOwnProperty("actInfo") 不成立
	}
}

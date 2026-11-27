package mc.view.farm;

import common.INI;
import common.LocalData;
import mc.view.farm.GetCropID;
import utest.Assert;

/**
 * mc.view.farm.GetCropID 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * id↔名称/URL 拼装与 INI XML 属性查询。fixture 走 test/fixtures/mc-ini.xml
 * （合并 INI 配置：mcloader 把 mc_data 的 animals 并入 mc_main、mc_card 的
 * cards 同理——FarmWorld.as:227 appendChild；元素/属性出处逐条抄录在
 * fixture 头注释）。
 *
 * 期望值出处：除另行标注外全部来自
 * legacy/decompiled/Master2_v_142/scripts/mc/view/farm/GetCropID.as 的行内
 * 拼接公式（行号标在各测试注释），配置值来自 fixture 抄录的
 * legacy/deploy/QFarmFlash/source/core/source/xml/mod/mc_data.php /
 * mc_main.php / mc_card.php 行（fixture 头注释逐条注明行号）。
 *
 * INI 注入：INI.getInstance().data 是可写属性（src/common/INI.hx:36-46），
 * 测试经 setup 注入 Xml.parse(fixture)；GetCropID._xml 是静态缓存位
 * （GetCropID.as:22），每个测试先清 null 再调，逼方法重新读 INI。
 * LocalData.parameters/mode/xymode 是 plain 静态位（src/common/LocalData.hx），
 * addPrefix/getCommonUrlNc/Farm 的分支直接赋值驱动。
 */
@:access(mc.view.farm.GetCropID)
class GetCropIDTest {
	static var FIXTURE:String =
		sys.io.File.getContent("test/fixtures/mc-ini.xml");

	public function new() {}

	function setup() {
		INI.getInstance().data = Xml.parse(FIXTURE);
		GetCropID._xml = null;
		LocalData.parameters = {};
		LocalData.mode = "qzone";
		LocalData.xymode = "";
	}

	// :51-60 getSwfUrl = folder.@url 经 addPrefix；无 appImgPrefix 时原样
	// （fixture folder url 抄录 mc_main.php:10 的 $url 实例化形态）
	public function test_getSwfUrl_returns_folder_url_without_prefix() {
		Assert.equals("http://appimg.qq.com/mc/module/mc/", GetCropID.getSwfUrl());
	}

	// :211-220 addPrefix 三分支：appImgPrefix 空 → 原样；非空且 url 不含
	// ".appimg" → appimg./appimg1./appimg3. 逐字前缀替换；url 已含
	// ".appimg"（如 pyimg 不含 appimg 字面，反向钉：含 ".appimg" 的不换）
	public function test_addPrefix_branches() {
		// 空 parameters → 原样
		Assert.equals("http://appimg.qq.com/mc/module/mc/", GetCropID.addPrefix("http://appimg.qq.com/mc/module/mc/"));
		// appImgPrefix 非空 + url 无 ".appimg"……注意 fixture 的 url 本身
		// 含 "appimg.qq.com" 但不含 ".appimg"（点在前）——indexOf(".appimg")
		// 对 "http://appimg.qq.com" 命中子串位置：appimg.qq.com 里 "ppimg"
		// 前无点…… 实为："http://appimg.qq.com" 不含 ".appimg"（a 前是 /），
		// 故替换发生：appimg. → test1.appimg.
		LocalData.parameters = {appImgPrefix: "test1"};
		Assert.equals("http://test1.appimg.qq.com/mc/", GetCropID.addPrefix("http://appimg.qq.com/mc/"));
		// url 已含 ".appimg"（点开头）→ 不换
		Assert.equals("http://x.appimg.qq.com/mc/", GetCropID.addPrefix("http://x.appimg.qq.com/mc/"));
		LocalData.parameters = {};
	}

	// :261-284 getAnimalURL：param2∈{1,2} → "_0" 否则 "_1"；getAnimalV 非空
	// 才拼 "?v="。1001 鸡无 v 属性（mc_data.php:5575 ——空串分支）；1502 牛
	// v="1"（mc_data.php 抄录——非空分支）
	public function test_getAnimalURL_suffix_and_version() {
		var base = "http://appimg.qq.com/mc/module/mc/farm/aswf/";
		// 鸡（无 v）：四态全表
		Assert.equals(base + "a1001_0.swf", GetCropID.getAnimalURL("1001", 1));
		Assert.equals(base + "a1001_0.swf", GetCropID.getAnimalURL("1001", 2));
		Assert.equals(base + "a1001_1.swf", GetCropID.getAnimalURL("1001", 3));
		Assert.equals(base + "a1001_1.swf", GetCropID.getAnimalURL("1001", 6));
		// 牛（v="1"）：拼 ?v=1
		Assert.equals(base + "a1502_0.swf?v=1", GetCropID.getAnimalURL("1502", 1));
		Assert.equals(base + "a1502_1.swf?v=1", GetCropID.getAnimalURL("1502", 5));
	}

	// :406-416 getAnimalV：属性缺失 || "" 空串；v="1" 原样
	public function test_getAnimalV_missing_and_present() {
		Assert.equals("", GetCropID.getAnimalV("1001"));
		Assert.equals("1", GetCropID.getAnimalV("1502"));
	}

	// :172-190 getWareHouseIconUrl：>10000 → a(n-10000).jpg；否则 a{n}p.jpg
	public function test_getWareHouseIconUrl_threshold() {
		var base = "http://appimg.qq.com/mc/module/mc/farm/animal/";
		Assert.equals(base + "a1001p.jpg", GetCropID.getWareHouseIconUrl(1001));
		Assert.equals(base + "a10000p.jpg", GetCropID.getWareHouseIconUrl(10000));
		Assert.equals(base + "a1.jpg", GetCropID.getWareHouseIconUrl(10001));
		Assert.equals(base + "a502.jpg", GetCropID.getWareHouseIconUrl(10502));
	}

	// :310-320 idToName：animals.animal.(@id==v).@name
	public function test_idToName() {
		Assert.equals("鸡", GetCropID.idToName("1001"));
		Assert.equals("白玉猴", GetCropID.idToName("1083"));
		Assert.equals("牛", GetCropID.idToName("1502"));
	}

	// :69-91 getActivity：isActivity/isProductActivity=="1" → true。
	// 1083 白玉猴是 mc_data.php 里唯一的 isActivity=1 样本（fixture 头注释）
	public function test_getActivity_true_and_false() {
		Assert.isTrue(GetCropID.getActivity("1083"));
		Assert.isTrue(GetCropID.getActivity("1083", true));
		Assert.isFalse(GetCropID.getActivity("1001"));
		Assert.isFalse(GetCropID.getActivity("1001", true));
	}

	// :442-460 numToNext：next==6 && num==5 → "待收获期"；否则
	// nextText.@value 逗号表第 num-1 项（mc_data.php:5597 六档
	// "幼仔,成长期,生产期,生产期,待产期,收获期"）
	public function test_numToNext_status_table() {
		Assert.equals("幼仔", GetCropID.numToNext(1001, 1));
		Assert.equals("成长期", GetCropID.numToNext(1001, 2));
		Assert.equals("生产期", GetCropID.numToNext(1001, 3));
		Assert.equals("待产期", GetCropID.numToNext(1001, 5));
		Assert.equals("收获期", GetCropID.numToNext(1001, 6));
		// 特判：num=5 且 next=6 → "待收获期"（不是表项 "待产期"）
		Assert.equals("待收获期", GetCropID.numToNext(1001, 5, 6));
		// num=5 但 next≠6 仍走表
		Assert.equals("待产期", GetCropID.numToNext(1001, 5, 3));
	}

	// :708-748 setNext：status 2/3/5 三分支，timeList 取 nextTime.@value
	// 逗号表。鸡 1001 nextTime=14400,14400,129600,15,21585,158400
	// （mc_data.php:5598）
	public function test_setNext_status2() {
		var data:Dynamic = {cId: "1001", status: 2, growTime: 0};
		GetCropID.setNext(data);
		Assert.equals(3, data.statusNext);
		Assert.equals("14400", data.growTimeNext); // timeList[1] 原样（字符串位）
	}

	public function test_setNext_status3() {
		var data:Dynamic = {cId: "1001", status: 3, growTime: 10000};
		GetCropID.setNext(data);
		Assert.equals(6, data.statusNext);
		// timeList[5]-growTime = 158400-10000 = 148400
		Assert.equals(148400, data.growTimeNext);
	}

	// status 5：n1+n2>=n3 判产完——growTime+timeList[4]>=timeList[5] 则进
	// 收获态 6，否则回生产态 3 且 growTimeNext=timeList[4]
	public function test_setNext_status5_boundary() {
		// 鸡 timeList[4]=21585 timeList[5]=158400
		// 恰在边界：136815+21585=158400 → >= 成立 → statusNext 6
		var atBoundary:Dynamic = {cId: "1001", status: 5, growTime: 136815};
		GetCropID.setNext(atBoundary);
		Assert.equals(6, atBoundary.statusNext);
		Assert.equals(21585, atBoundary.growTimeNext); // 158400-136815
		// 边界下一秒：136814+21585=158399 < 158400 → statusNext 3
		var below:Dynamic = {cId: "1001", status: 5, growTime: 136814};
		GetCropID.setNext(below);
		Assert.equals(3, below.statusNext);
		Assert.equals("21585", below.growTimeNext); // timeList[4] 原样
	}

	// :644-656 getProductName = @u + @product（鸡：个+鸡蛋；牛：瓶+牛奶）
	public function test_getProductName() {
		Assert.equals("个鸡蛋", GetCropID.getProductName("1001"));
		Assert.equals("瓶牛奶", GetCropID.getProductName("1502"));
	}

	// :564-574 getProductName2 = @product（形参原文是 Object 但按 @id 比对——
	// 传字符串 id 的调用形态）
	public function test_getProductName2() {
		Assert.equals("鸡蛋", GetCropID.getProductName2("1001"));
		Assert.equals("白玉羽毛", GetCropID.getProductName2("1083"));
	}

	// :684-694 getChidNum / :696-706 getHouse / :462-472 idToSound
	public function test_animal_numeric_and_house_attrs() {
		Assert.equals(20, GetCropID.getChidNum("1001"));
		Assert.equals(12, GetCropID.getChidNum("1502"));
		Assert.equals("窝", GetCropID.getHouse("1001"));
		Assert.equals("棚", GetCropID.getHouse("1502"));
		Assert.equals(1, GetCropID.idToSound("1001"));
		Assert.equals(0, GetCropID.idToSound("1083"));
	}

	// :667-682 formatString：含 < 或 > 才转义 &<> 三字符；不含原样。
	// 注意转义顺序：先 & 后 <>（& 先转义避免二次转义）
	public function test_formatString_escaping() {
		Assert.equals("plain text", GetCropID.formatString("plain text"));
		Assert.equals("&lt;font&gt;", GetCropID.formatString("<font>"));
		Assert.equals("&lt;a&gt;&amp;&lt;/a&gt;", GetCropID.formatString("<a>&</a>"));
		// 只含 & 不含尖括号 → 不转义（indexOf 门）
		Assert.equals("a & b", GetCropID.formatString("a & b"));
	}

	// :322-364 getCommonUrlNc/Farm：mode==qzone 或 xymode=="qq.com" 走
	// common*，否则 *_pengyou 变体。**注意真实部署形态**：mc_main.php:7 的
	// postUrl 六个 url 形属性原文全部是 `$url/mymc.php?mod=`（同 $url 同
	// mymc.php——全文件零 mync、零 pyimg，fixture 头注释），pengyou 变体
	// 与非 pengyou 在生产读到**同值**。两分支因此断言同一串，本测试钉的
	// 是「分支各自取对了属性、且两属性同值」的真实配置语义，不是编造分歧。
	public function test_commonUrl_mode_branches() {
		var mymc = "http://appimg.qq.com/mc/mymc.php?mod=";
		// qzone → 非 pengyou 属性 commonNc/commonFarm
		LocalData.mode = "qzone";
		Assert.equals(mymc, GetCropID.getCommonUrlNc());
		Assert.equals(mymc, GetCropID.getCommonUrlFarm());
		// xymode=="qq.com" 同路（即便 mode 非 qzone）
		LocalData.mode = "";
		LocalData.xymode = "qq.com";
		Assert.equals(mymc, GetCropID.getCommonUrlNc());
		Assert.equals(mymc, GetCropID.getCommonUrlFarm());
		// 两者都不沾 → pengyou 变体——真实配置下同值
		LocalData.mode = "";
		LocalData.xymode = "";
		Assert.equals(mymc, GetCropID.getCommonUrlNc());
		Assert.equals(mymc, GetCropID.getCommonUrlFarm());
	}

	// :490-493 idToWareName / :638-642 idToToolName ——纯拼接（这两个方法
	// 在 stub 阶段即完整，入测试钉回归）
	public function test_pure_name_assembly() {
		Assert.equals("p1001", GetCropID.idToWareName("1001"));
		Assert.equals("Tool_1_9", GetCropID.idToToolName("9", "1"));
		Assert.equals("Tool_4_101", GetCropID.idToToolName("101", "4"));
	}

	// :425-428 canSellCubTip 原文即 return false（完整入 stub，钉回归）
	public function test_canSellCubTip_is_false() {
		Assert.isFalse(GetCropID.canSellCubTip());
	}

	// :507-517 idToCardLockStatus：cards.card.@isLock parseInt。
	// mc_card.php:8-9 抄录——真实卡表全部 8 张都是 isLock="1"，**不存在
	// isLock="0" 样本**（round 1 把 2002 编成 0，本轮按真实值重写）。两张
	// fixture 卡都钉 1。locked/missing 的 NaN→0 边界（parseInt("") → NaN、
	// Haxe 侧 int(NaN) 或 Std.parseInt 的 null→0 语义）是 implement 的取值
	// 细节，不在本测试断言——fixture 无该样本，注备录。
	public function test_idToCardLockStatus() {
		Assert.equals(1, GetCropID.idToCardLockStatus("2001"));
		Assert.equals(1, GetCropID.idToCardLockStatus("2002"));
	}

	// :552-562 idToCardName
	public function test_idToCardName() {
		Assert.equals("圣诞老人卡", GetCropID.idToCardName("2001"));
		Assert.equals("圣诞树卡", GetCropID.idToCardName("2002"));
	}

	// :626-636 idToCardSrc 经 addPrefix（无 prefix 原样）
	public function test_idToCardSrc() {
		Assert.equals("http://appimg.qq.com/mc/module/ui/allcards/Card_2001.swf", GetCropID.idToCardSrc("2001"));
	}

	// :430-440 getTipInfo：animals tip 元素文本逐字。mc_data.php:5575-5619
	// 抄录全文——注意 "chicken" 后 **四个空格**（round 1 截断并丢了空格，
	// 本轮抄原文全句）：fixture 头注释已注明 tip/<l> 排版是把原文多行缩进
	// 内联成单行、文本逐字。
	public function test_getTipInfo() {
		Assert.equals("鸡（英文：chicken    ）是家禽之一，品种很多。头部有红色肉冠，雄性的善啼好斗，能报晓，鸡肉和鸡蛋可供食用。", GetCropID.getTipInfo("1001"));
	}

	// :366-376 getProductTip：warehouse.product tip（存在性由源码证实，
	// fixture 文本值仅作解析通路钉——见 fixture 头注释）
	public function test_getProductTip() {
		Assert.equals("鸡蛋的产品提示", GetCropID.getProductTip("1001"));
	}

	// :588-596 getGameRecord：game.record[0] Number 化（同上，通路钉）
	public function test_getGameRecord() {
		Assert.equals(3, GetCropID.getGameRecord());
	}

	// :598-608 idToLibName：className 属性在部署包全部 299 个 animal 上
	// 不存在（mc_data.php 全文件零命中——fixture 头注释），恒空串
	public function test_idToLibName_empty_in_production() {
		Assert.equals("", GetCropID.idToLibName("1001"));
		Assert.equals("", GetCropID.idToLibName("1502"));
	}

	// :286-308 getUpdataAnimalIconUrl / :378-404 getShopIconUrl /
	// :576-586 getAnimalInfoIconUrl / :245-259 getHunterPicUrl /
	// :62-67 getWildAnimalIcon / :93-98 getWildIcon / :204-209 getFlopUrl /
	// :418-423 getVipAnimalURL / :533-542 getShopDiyUrl ——URL 拼接簇
	public function test_icon_url_family() {
		var base = "http://appimg.qq.com/mc/module/mc/";
		// getUpdataAnimalIconUrl 三分支
		Assert.equals(base + "farm/animal/a1001e.png", GetCropID.getUpdataAnimalIconUrl(1001));
		Assert.equals(base + "farm/animal/a1001.jpg", GetCropID.getUpdataAnimalIconUrl(1001, true));
		Assert.equals(base + "farm/animal/a1001e_b.png", GetCropID.getUpdataAnimalIconUrl(1001, false, true));
		// getShopIconUrl：param2/param3 同形 b.jpg、param4 b_s.swf、缺省 .jpg
		Assert.equals(base + "farm/animal/a1001.jpg", GetCropID.getShopIconUrl(1001));
		Assert.equals(base + "farm/animal/a1001b.jpg", GetCropID.getShopIconUrl(1001, true));
		Assert.equals(base + "farm/animal/a1001b.jpg", GetCropID.getShopIconUrl(1001, false, true));
		Assert.equals(base + "farm/animal/a1001b_s.swf", GetCropID.getShopIconUrl(1001, false, false, true));
		// getAnimalInfoIconUrl：param2 前缀 + id + .png
		Assert.equals(base + "farm/icon/food1001.png", GetCropID.getAnimalInfoIconUrl(1001, "food"));
		// getHunterPicUrl：param2 true 时 jpg→png 替换
		Assert.equals(base + "farm/hunter/h_dog.jpg", GetCropID.getHunterPicUrl("dog"));
		Assert.equals(base + "farm/hunter/h_dog.png", GetCropID.getHunterPicUrl("dog", true));
		// wild 两张
		Assert.equals(base + "farm/wild/pic/beast_2.jpg", GetCropID.getWildAnimalIcon("beast", 2));
		Assert.equals(base + "farm/wild/pic/beast_x_2.jpg", GetCropID.getWildIcon("beast", 2, "x"));
		// flop / vip / shopDiy
		Assert.equals(base + "main/windows/flopGift.swf", GetCropID.getFlopUrl());
		Assert.equals(base + "farm/VipAnimal/a1001.swf", GetCropID.getVipAnimalURL("a1001.swf"));
		Assert.equals(base + "farm/diy/z1_3_1_shop.jpg", GetCropID.getShopDiyUrl("3"));
	}

	// :192-202 toolToAnimal / :495-505 getAnimalInfo：按 @sf/@id 回 XML 节点
	// （fixture 三只 sf 全 "0"——@sf 比对取 [0] 首命中，恒鸡；XML 返回形态
	// 钉 id 属性可读）
	public function test_xml_node_lookup() {
		var node:Dynamic = GetCropID.getAnimalInfo("1502");
		Assert.notNull(node);
		Assert.equals("牛", node.get("name"));
		var toolNode:Dynamic = GetCropID.toolToAnimal("0");
		Assert.notNull(toolNode);
		Assert.equals("1001", toolNode.get("id"));
	}
}

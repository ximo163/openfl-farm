package common.misc;

import com.qzone.qfa.model.AppData;
import module.FarmApplication;
import utest.Assert;

/**
 * ConfigMerger 对真实 nc_data/nc_addon XML 载荷形状的解析与合并（issue #7）。
 *
 * CI web-smoke 曾报 pageerror: SyntaxError: Unexpected end of JSON input：真实
 * 下发里 type="json" 节点的 CDATA 前有 "\n\t\t" 纯空白排版文本，AS3 侧
 * XMLDocument(ignoreWhite=true)（ConfigMerger.as:92）与 E4X children()[0]
 * （ConfigMerger.as:185）都取不到它，Haxe Xml 却原样保留——旧实现
 * firstChild().nodeValue 把空白串喂进 Json.parse。用例按真实形状锁住回归：
 * - nc_data：CDATA 前有空白（nc_data.php:33-42 secondList、:7562-7564 waterPool）
 * - nc_addon：CDATA 紧贴起始标签（:265 secondList）与 CDATA 前有空白
 *   （:350 crops）在同一份 addon 里并存
 * - parseJSONData 按 JSON 顶层键落库，节点名不进 model（waterPool 节点的键是
 *   "fish_info"，nc_data.php:7562-7564；ConfigMerger.as:90-98）
 *
 * ConfigMerger 构造器要 FarmApplication（ConfigMerger.as:15-21），其 ctor 挂
 * stage/显示链，单测用 Type.createEmptyInstance 绕过、Reflect.setField 注入
 * _model（Application.hx:31 声明、:39 构造器本就指向 AppData 单例；flush 隔离
 * 每个用例）——同 FarmLiteTest 的先例，不碰显示对象、不联网。
 */
class ConfigMergerTest {
	private var app:FarmApplication;

	private var model:AppData;

	public function new() {}

	// 每个用例独占的空 app + 干净单例状态
	private function newApp():Void {
		this.model = AppData.gi();
		this.model.flush();
		this.app = Type.createEmptyInstance(FarmApplication);
		Reflect.setField(this.app, "_model", this.model);
	}

	// nc_data.php:33-42 的 secondList：CDATA 前有 "\n\t\t" 空白文本、CDATA 内
	// JSON 另起一行缩进。parseJSONData 无 try/catch（ConfigMerger.as:90-98），
	// 空白串喂进 Json.parse 即抛——旧实现正是 CI 的 Unexpected end of JSON input。
	public function test_parse_xml_data_reads_json_cdata_behind_whitespace() {
		newApp();
		var dataXml = '<?xml version="1.0" encoding="UTF-8"?>
<data>

	<secondList type="json">
		<![CDATA[
		{"secondList" : [{"id":"RequestErrorBG", "src":"module/ui/main/RequestError_2.swf", "className":"RequestErrorBG"}]}
		]]>
	</secondList>
</data>';
		var merger = new ConfigMerger(this.app, dataXml);
		var list:Array<Dynamic> = this.model.getData("secondList");
		Assert.notNull(list, "secondList 应按 JSON 顶层键落库");
		Assert.equals(1, list.length);
		Assert.equals("RequestErrorBG", Reflect.field(list[0], "id"));
		Assert.equals("module/ui/main/RequestError_2.swf", Reflect.field(list[0], "src"));
		Assert.equals("RequestErrorBG", Reflect.field(list[0], "className"));
	}

	// nc_data.php:7562-7564 的 waterPool：CDATA 的 JSON 顶层键是 "fish_info"，
	// parseJSONData 按键 setData（ConfigMerger.as:90-98）——节点名 waterPool 不进
	// model。asset_id 数值照抄原下发（8696/8695）。
	public function test_parse_json_data_stores_by_json_top_level_key() {
		newApp();
		var dataXml = '<data>
	<waterPool type="json">
		<![CDATA[
		{"fish_info": [{"asset_id": {"m": 8696, "s": 8695}, "crop_name": "测试鱼"}]}
		]]>
	</waterPool>
</data>';
		var merger = new ConfigMerger(this.app, dataXml);
		Assert.isNull(this.model.getData("waterPool"), "节点名不落库，落的是 JSON 顶层键");
		var fish:Array<Dynamic> = this.model.getData("fish_info");
		Assert.notNull(fish);
		Assert.equals(1, fish.length);
		Assert.equals(8696, Reflect.field(Reflect.field(fish[0], "asset_id"), "m"));
		Assert.equals(8695, Reflect.field(Reflect.field(fish[0], "asset_id"), "s"));
		Assert.equals("测试鱼", Reflect.field(fish[0], "crop_name"));
	}

	// mergeConfig 的真实调用形态（Main.hx:253-256）：data 走构造器、addon 经
	// Utils.loadXMLData 喂根元素（E4X new XML 的等价物，Utils.as:147-171）。
	// base 用 nc_data 的 crops 形状（:6017 CDATA 前有空白），addon 用 nc_addon 的
	// secondList（:265 CDATA 紧贴起始标签）+ crops（:350 CDATA 前有空白）。
	// mergeJsonArrayNode（ConfigMerger.as:158-207）：id 命中 → 原地覆盖字段；
	// 未命中 → 追加；追加项排在既有项之后（concat）。
	public function test_merge_config_merges_addon_json_arrays() {
		newApp();
		var merger = new ConfigMerger(this.app, '<data>
	<crops type="json">
		<![CDATA[
		{"crops" : [{"id":"1", "src":"old.swf"}]}
		]]>
	</crops>
</data>');
		var addon = Xml.parse('<data>
	<secondList type="json"><![CDATA[
	{"secondList" : [{"id":"levelUpUI", "src":"module/levelUp/levelUpUI_v_1.swf"}]}
	]]>
	</secondList>
	<crops type="json">
		<![CDATA[
		{"crops" : [
		{"id":"1", "src":"new.swf"},
		{"id":"2", "src":"c2.swf"}]}
		]]>
	</crops>
</data>').firstElement();
		merger.mergeConfig(addon);

		// base 里没有 secondList：checkTargetArrayData 建空数组后整体追加
		//（ConfigMerger.as:60-67）
		var list:Array<Dynamic> = this.model.getData("secondList");
		Assert.notNull(list);
		Assert.equals(1, list.length);
		Assert.equals("levelUpUI", Reflect.field(list[0], "id"));

		var crops:Array<Dynamic> = this.model.getData("crops");
		Assert.equals(2, crops.length, "一条原地更新、一条追加");
		Assert.equals("1", Reflect.field(crops[0], "id"));
		Assert.equals("new.swf", Reflect.field(crops[0], "src"), "同 id 原地覆盖字段");
		Assert.equals("2", Reflect.field(crops[1], "id"));
		Assert.equals("c2.swf", Reflect.field(crops[1], "src"));
	}

	// parseXMLData 的无 type 分支（ConfigMerger.as:90-129 else 段）：子元素按
	// `@id == undefined ? name() : @id` 键进 dict。nc_data.php:20-27 的
	// environment（无 id，按元素名键）与 :48-49 的 assets（按 id 键）。
	// 值里的 $url 是 PHP heredoc 插值（nc_data.php:2 起），客户端收到的已是
	// 插值后的绝对 URL，测试里用普通串即可。
	public function test_parse_xml_data_maps_plain_elements_to_dicts() {
		newApp();
		var dataXml = '<data>
	<environment>
		<postUrl_qz url="http://appbase.qzone.qq.com/mync.php?" />
		<items maxid="90012" />
	</environment>
	<assets>
		<asset id="946" src="http://appbase.qzone.qq.com/module/ui/farm/diy/1.jpg"/>
	</assets>
</data>';
		var merger = new ConfigMerger(this.app, dataXml);
		var env:Dynamic = this.model.getData("environment");
		Assert.notNull(env);
		Assert.equals("http://appbase.qzone.qq.com/mync.php?", Reflect.field(Reflect.field(env, "postUrl_qz"), "url"));
		Assert.equals("90012", Reflect.field(Reflect.field(env, "items"), "maxid"));
		var assets:Dynamic = this.model.getData("assets");
		Assert.notNull(assets);
		Assert.equals("http://appbase.qzone.qq.com/module/ui/farm/diy/1.jpg",
			Reflect.field(Reflect.field(assets, "946"), "src"));
	}
}

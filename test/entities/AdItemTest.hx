package entities;

import utest.Assert;

/**
 * AdItem 纯逻辑（issue #35）：shop_v_7 广告/合作专区条目实体（view_fcg
 * 下发 list 元素）的两个导入通道。importObject 走服务端键 img/rl/acurl +
 * Utils.getStrAttribute（缺键回 ""，:37-39）；importFromCache 走本地缓存
 * 键 _img/_rl/_acurl 的裸字段拷贝（:26-28，键形不重合——缓存写入方存的
 * 就是下划线形）。AS3 未初始化 String 为 null、构造器 importObject(null)
 * 早退 → 三字段保持 null。
 *
 * 非字符串形状不钉：AS3 把数字赋给 String 变量时隐式 String() 强转，
 * Haxe 端 Utils.getStrAttribute 原样返回字段（Utils.hx:184 无强转），
 * 没有可断言的等价物——view_fcg 部署桩下发的三键也全是字符串形状。
 *
 * 出处：
 * - legacy/decompiled/shop_v_7/scripts/entities/AdItem.as
 *   （字段 :8/:10/:12、ctor :14-18、importFromCache :20-29、
 *   importObject :31-40）
 * - legacy/deploy/QFarmFlash/source/core/source/nc/mod/view_fcg.php:6-10
 *   （部署桩只回 {} / ret0+data[...].ret1，不下发条目——键名取自
 *   ShopModel.onGetAdvertisementInfo 读的 list 行，调用方传原行引用）
 * - Utils.as:192-207（getStrAttribute：null 对象/空键名/缺键 → ""，
 *   其余原样返回；Haxe 在 Utils.hx:173-185）
 */
class AdItemTest {
	public function new() {}

	// ctor → importObject（:17）：全键装载；缺键经 getStrAttribute 补 ""
	public function test_ctor_imports_server_keys_with_str_defaults() {
		var full = new AdItem({img: "http://i/a.png", rl: "http://r/a", acurl: "http://c/a"});
		Assert.equals("http://i/a.png", full._img); // :37
		Assert.equals("http://r/a", full._rl); // :38
		Assert.equals("http://c/a", full._acurl); // :39

		var partial = new AdItem({img: "http://i/x.png"});
		Assert.equals("http://i/x.png", partial._img);
		Assert.equals("", partial._rl); // 缺键 → getStrAttribute ""（Utils.as:196-198）
		Assert.equals("", partial._acurl);

		// 空对象：三键全缺 → 全 ""（与 null 入参的「保持 null」形成对照）
		var empty = new AdItem({});
		Assert.equals("", empty._img);
		Assert.equals("", empty._rl);
		Assert.equals("", empty._acurl);
	}

	// ctor(null) → importObject 早退（:33-35）→ AS3 未初始化 String 的 null
	public function test_ctor_null_keeps_fields_null() {
		var item = new AdItem(null);
		Assert.isNull(item._img); // :8 AS3 未初始化 String = null
		Assert.isNull(item._rl); // :10
		Assert.isNull(item._acurl); // :12

		// 已装载实例上 importObject(null) 同样早退、原值不动
		var loaded = new AdItem({img: "http://i/a.png", rl: "http://r/a"});
		loaded.importObject(null); // :33-35
		Assert.equals("http://i/a.png", loaded._img);
		Assert.equals("http://r/a", loaded._rl);
	}

	// importFromCache（:20-29）：null 早退；裸读 _img/_rl/_acurl（下划线键），
	// 缺键落 null（AS3 undefined 赋 String → null）；服务端键形（无下划线）
	// 不命中
	public function test_importFromCache_reads_underscored_keys_raw() {
		var item = new AdItem(null);
		item.importFromCache({_img: "http://i/b.png", _rl: "http://r/b", _acurl: "http://c/b"});
		Assert.equals("http://i/b.png", item._img); // :26 裸字段拷贝
		Assert.equals("http://r/b", item._rl); // :27
		Assert.equals("http://c/b", item._acurl); // :28

		// 空对象：三键全缺 → null（对照 importObject 的 ""）
		var blank = new AdItem({img: "http://i/a.png"});
		blank.importFromCache({});
		Assert.isNull(blank._img); // Reflect.field 缺键 → null（AS3 undefined）
		Assert.isNull(blank._rl);
		Assert.isNull(blank._acurl);

		// 服务端键形不命中（importFromCache 只认下划线键）
		var mismatch = new AdItem(null);
		mismatch.importFromCache({img: "http://i/y.png"});
		Assert.isNull(mismatch._img);

		// null 早退、原值不动（:22-24）
		var keep = new AdItem({img: "http://i/a.png"});
		keep.importFromCache(null);
		Assert.equals("http://i/a.png", keep._img);
	}
}

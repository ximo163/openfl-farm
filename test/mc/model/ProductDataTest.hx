package mc.model;

import common.INI;
import mc.model.ModelEvent;
import mc.model.ProductData;
import utest.Assert;

/**
 * mc.model.ProductData 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 牧场仓库产品数据——init 建表、getProduct 查询、addCando/addProduct 的
 * 数值累加与清零/置三分支、事件派发矩阵。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/ProductData.as
 * —— 常量 :10-18（ANIMAL_FOOD "animalFood_Change" :10、PRODUCT_CHANGES
 * "product_change" :12、PRODUCT_CANDO "product_cando" :14、PRODUCT_INIT
 * "product_init" :16、PRODUCT_ADD "product_addproduct" :18）；init :27-41
 * （_products = {}、param1.animal 逐条按 cId 键建 {cName: GetCropID.
 * getProductName2(cId), amount: 0, cando: 0}、收尾派 PRODUCT_INIT）；
 * getProduct :53-56（products[param1] 直返）；addCando :58-61
 * （_products[param1].cando = param2——直接覆写非累加）；addProduct :63-87
 * （键不存在时先建条目（cName 同 init 通道）+ 派 PRODUCT_ADD（ModelEvent、
 * data=param1），随后 amount += param2，param3 true → amount = 0，
 * param4 true → cando = 3，收尾派 PRODUCT_CHANGES）。
 *
 * INI 注入同 GetCropIDTest（fixture test/fixtures/mc-ini.xml 的 animals
 * 三条抄录 mc_data.php——鸡 1001 product 鸡蛋、白玉猴 1083 product
 * 白玉羽毛、牛 1502 product 牛奶）。GetCropID.getProductName2 在 stub 期
 * throw——init/addProduct 必然等 implement 充真身才绿（write-tests 的
 * 意图即如此）。
 *
 * 注意 param1.animal 的条目形态：cId 是字符串（"1001"），键名按 AS3
 * Object 下标的字符串化语义——_products["1001"]。
 */
class ProductDataTest {
	static var FIXTURE:String = sys.io.File.getContent("test/fixtures/mc-ini.xml");

	var pd:ProductData;

	public function new() {}

	function setup() {
		INI.getInstance().data = Xml.parse(FIXTURE);
		pd = new ProductData();
	}

	function animalInput():Dynamic {
		return {
			animal: [
				{cId: "1001"},
				{cId: "1083"},
				{cId: "1502"}
			]
		};
	}

	// 常量面值（ProductData.as:10-18）
	public function test_event_constants() {
		Assert.equals("animalFood_Change", ProductData.ANIMAL_FOOD);
		Assert.equals("product_change", ProductData.PRODUCT_CHANGES);
		Assert.equals("product_cando", ProductData.PRODUCT_CANDO);
		Assert.equals("product_init", ProductData.PRODUCT_INIT);
		Assert.equals("product_addproduct", ProductData.PRODUCT_ADD);
	}

	// init（:27-41）：逐条建 {cName/amount/cando}、派发 PRODUCT_INIT
	public function test_init_builds_entries_and_dispatches() {
		var inited = false;
		pd.addEventListener(ProductData.PRODUCT_INIT, function(e) inited = true);
		pd.init(animalInput());
		Assert.isTrue(inited);
		var egg = pd.getProduct("1001");
		Assert.notNull(egg);
		Assert.equals("鸡蛋", egg.cName); // getProductName2("1001")——fixture 鸡 @product
		Assert.equals(0, egg.amount);
		Assert.equals(0, egg.cando);
		var feather = pd.getProduct("1083");
		Assert.equals("白玉羽毛", feather.cName);
		var milk = pd.getProduct("1502");
		Assert.equals("牛奶", milk.cName);
	}

	// getProduct（:53-56）：未命中键 → null（Object 下标缺失返 undefined，
	// Haxe 侧等价 null）
	public function test_getProduct_missing_returns_null() {
		pd.init(animalInput());
		Assert.isNull(pd.getProduct("9999"));
	}

	// addCando（:58-61）：直接覆写（不是累加——原文 `= param2`）
	public function test_addCando_overwrites() {
		pd.init(animalInput());
		pd.addCando("1001", 3);
		Assert.equals(3, pd.getProduct("1001").cando);
		pd.addCando("1001", 7); // 覆写非累加：7 不是 10
		Assert.equals(7, pd.getProduct("1001").cando);
	}

	// addProduct 累加（:77 `amount += param2`）：已存在条目只加量、
	// 不重复派 PRODUCT_ADD
	public function test_addProduct_accumulates_amount() {
		pd.init(animalInput());
		var adds:Array<Dynamic> = [];
		pd.addEventListener(ProductData.PRODUCT_ADD, function(e) {
			var me = cast(e, ModelEvent);
			adds.push(me.data);
		});
		pd.addProduct("1001", 5);
		Assert.equals(5, pd.getProduct("1001").amount);
		pd.addProduct("1001", 3);
		Assert.equals(8, pd.getProduct("1001").amount); // 5+3
		Assert.equals(0, adds.length); // init 已建条目——不进新建分支
	}

	// addProduct 新键（:66-76）：键不存在时建条目（amount 0/cando 0/cName
	// 走 getProductName2）+ 派 PRODUCT_ADD（data=键名）
	public function test_addProduct_new_key_creates_and_dispatches() {
		// init 只列鸡——"1502" 不在表内（fixture 有牛使 getProductName2 可解）
		pd.init({animal: [{cId: "1001"}]});
		var adds:Array<Dynamic> = [];
		pd.addEventListener(ProductData.PRODUCT_ADD, function(e) {
			var me = cast(e, ModelEvent);
			adds.push(me.data);
		});
		pd.addProduct("1502", 2);
		Assert.equals(1, adds.length);
		Assert.equals("1502", adds[0]);
		var milk = pd.getProduct("1502");
		Assert.equals("牛奶", milk.cName);
		Assert.equals(2, milk.amount); // 0+2（新建后立即进 += 累加）
	}

	// addProduct param3=true（:78-81）：累加后 amount 清零
	public function test_addProduct_param3_zeroes_amount() {
		pd.init(animalInput());
		pd.addProduct("1001", 5);
		Assert.equals(5, pd.getProduct("1001").amount);
		pd.addProduct("1001", 3, true); // += 3 → 8 然后 amount = 0
		Assert.equals(0, pd.getProduct("1001").amount);
	}

	// addProduct param4=true（:82-85）：cando 置 3
	public function test_addProduct_param4_sets_cando_3() {
		pd.init(animalInput());
		pd.addProduct("1001", 5, false, true);
		Assert.equals(3, pd.getProduct("1001").cando);
		Assert.equals(5, pd.getProduct("1001").amount); // param3 false 不清零
	}

	// param3/param4 同真：amount 清零且 cando 置 3（两分支独立）
	public function test_addProduct_param3_and_param4() {
		pd.init(animalInput());
		pd.addProduct("1001", 9, true, true);
		Assert.equals(0, pd.getProduct("1001").amount);
		Assert.equals(3, pd.getProduct("1001").cando);
	}

	// 每次 addProduct 收尾派 PRODUCT_CHANGES（:86）——无论新旧键
	public function test_addProduct_always_dispatches_changes() {
		pd.init(animalInput());
		var changes = 0;
		pd.addEventListener(ProductData.PRODUCT_CHANGES, function(e) changes++);
		pd.addProduct("1001", 1);
		pd.addProduct("1502", 2, true, true);
		Assert.equals(2, changes);
	}

	// products setter 是 plain 覆写（:48-51 无派发）
	public function test_products_setter_plain() {
		var custom = {"x1": {cName: "n", amount: 1, cando: 2}};
		pd.products = custom;
		Assert.equals(custom, pd.products);
		Assert.equals(1, pd.getProduct("x1").amount);
	}
}

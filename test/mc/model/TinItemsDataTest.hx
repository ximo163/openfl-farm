package mc.model;

import mc.model.TinItemsData;
import utest.Assert;

/**
 * mc.model.TinItemsData 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 罐头/工资道具数据的重映射与排序旋转。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/model/TinItemsData.as
 * —— addTinItems :53-130（缺 id/type 的条目整条跳过；长字段名重映射为
 * 单字母键 id/d/t/e/n/l/p/qd/y/o/lt/tips/appid/shortage；setprice/
 * ysetprice 的 "month-money;..." 串按 ";" 切段、空段跳过、"-" 拆
 * {month, money}；null/空数组 → m_tins 清空）；allTinItems :28-34
 * （副本 sortOn("o") 数值升序，splice(-4,4) 切末四项拼到最前）；
 * loadingData setter 派发 LOAD_STATUS_CHANGED（:41-44）、shopTinInfoErr
 * setter 派发 LOAD_TINS_ERROR（:46-49）、addTinItems 收尾派
 * LOAD_TINS_SUCCESS。常量值 :8-12（Load_failed/Load_success/
 * Load_status_changed）。
 *
 * 测试数据的字段形态按服务端下发键名（description/type/effect/name/
 * left/price/qdprice/yqdprice/order/limittips/tips/appid/shortage/
 * setprice/ysetprice——addTinItems 的读取键）构造；值无 legacy 下发样本
 * 可抄（罐头商店 mod 无快照），仅作重映射逻辑钉。
 */
@:access(mc.model.TinItemsData)
class TinItemsDataTest {
	var tins:TinItemsData;

	public function new() {}

	function setup() {
		tins = new TinItemsData();
	}

	function sampleItem(id:Int, order:Int):Dynamic {
		return {
			id: id,
			type: 1,
			description: "desc" + id,
			effect: "effect" + id,
			name: "name" + id,
			left: 5,
			price: 100,
			qdprice: 10,
			yqdprice: 8,
			order: order,
			limittips: "lt" + id,
			tips: "tips" + id,
			appid: 999,
			shortage: "shortage" + id
		};
	}

	// 常量面值（TinItemsData.as:8-12）
	public function test_event_constants() {
		Assert.equals("Load_failed", TinItemsData.LOAD_TINS_ERROR);
		Assert.equals("Load_success", TinItemsData.LOAD_TINS_SUCCESS);
		Assert.equals("Load_status_changed", TinItemsData.LOAD_STATUS_CHANGED);
	}

	// 长键→单字母键重映射（:64-77）
	public function test_addTinItems_key_remap() {
		tins.addTinItems([sampleItem(1, 1)]);
		var item = tins.allTinItems[0];
		Assert.equals(1, item.id);
		Assert.equals("desc1", item.d);
		Assert.equals(1, item.t);
		Assert.equals("effect1", item.e);
		Assert.equals("name1", item.n);
		Assert.equals(5, item.l);
		Assert.equals(100, item.p);
		Assert.equals(10, item.qd);
		Assert.equals(8, item.y);
		Assert.equals(1, item.o);
		Assert.equals("lt1", item.lt);
		Assert.equals("tips1", item.tips);
		Assert.equals(999, item.appid);
		Assert.equals("shortage1", item.shortage);
	}

	// 缺 id 或 type 的条目整条跳过（:62 `!(id==undefined || type==undefined)`）
	public function test_addTinItems_skips_incomplete_entries() {
		var noId = sampleItem(1, 1);
		Reflect.deleteField(noId, "id");
		var noType = sampleItem(2, 2);
		Reflect.deleteField(noType, "type");
		tins.addTinItems([noId, noType, sampleItem(3, 3)]);
		Assert.equals(1, tins.allTinItems.length);
		Assert.equals(3, tins.allTinItems[0].id);
	}

	// null/空数组 → m_tins 清空（:57-60）
	public function test_addTinItems_null_and_empty_clear() {
		tins.addTinItems([sampleItem(1, 1)]);
		Assert.equals(1, tins.allTinItems.length);
		tins.addTinItems(null);
		Assert.equals(0, tins.allTinItems.length);
		tins.addTinItems([sampleItem(1, 1)]);
		tins.addTinItems([]);
		Assert.equals(0, tins.allTinItems.length);
	}

	// setprice 拆表（:78-96）："1-100;3-270;12-900" → 三枚 {month,money}；
	// 尾分号空段跳过；"6-550;" 与 "6-550" 等价
	public function test_setprice_split() {
		var item = sampleItem(1, 1);
		item.setprice = "1-100;3-270;12-900";
		tins.addTinItems([item]);
		var sp = tins.allTinItems[0].setprice;
		Assert.equals(3, sp.length);
		Assert.equals("1", sp[0].month);
		Assert.equals("100", sp[0].money);
		Assert.equals("12", sp[2].month);
		Assert.equals("900", sp[2].money);

		var item2 = sampleItem(2, 2);
		item2.setprice = "6-550;"; // 尾分号 → 空段跳过
		tins.addTinItems([item2]);
		var sp2 = tins.allTinItems[0].setprice;
		Assert.equals(1, sp2.length);
		Assert.equals("6", sp2[0].month);
		Assert.equals("550", sp2[0].money);
	}

	// ysetprice 同构（:97-117）且与 setprice 各自独立（ysetprice 处理前
	// _loc4_ 重置为空数组——:99-100）
	public function test_ysetprice_split_independent() {
		var item = sampleItem(1, 1);
		item.setprice = "1-100";
		item.ysetprice = "1-90;12-800";
		tins.addTinItems([item]);
		var out = tins.allTinItems[0];
		Assert.equals(1, out.setprice.length);
		Assert.equals(2, out.ysetprice.length);
		Assert.equals("90", out.ysetprice[0].money);
	}

	// 无 setprice/ysetprice 键时产物不带这两个键（hasOwnProperty 门）
	public function test_no_price_keys_absent() {
		tins.addTinItems([sampleItem(1, 1)]);
		var out = tins.allTinItems[0];
		Assert.isFalse(Reflect.hasField(out, "setprice"));
		Assert.isFalse(Reflect.hasField(out, "ysetprice"));
	}

	// allTinItems：sortOn("o") 数值升序后末四项旋到最前（:28-34）。
	// 6 项 order 1..6 乱序入 → 排序后 1,2,3,4,5,6 → splice(-4,4) 切出
	// 3,4,5,6 拼前 → 3,4,5,6,1,2
	public function test_allTinItems_sort_and_rotate() {
		var items = [for (i in 0...6) sampleItem(i + 1, [3, 1, 6, 2, 5, 4][i])];
		// 入序乱序：id1 order3、id2 order1、id3 order6、id4 order2、id5 order5、id6 order4
		tins.addTinItems(items);
		var out = tins.allTinItems;
		var orders = [for (x in out) x.o];
		Assert.equals("3,4,5,6,1,2", orders.join(","));
	}

	// 恰四项：splice(-4,4) 切走全部、concat 空数组 → 顺序不变（旋转不动）
	public function test_allTinItems_exactly_four_no_rotation() {
		tins.addTinItems([for (i in 0...4) sampleItem(i + 1, i + 1)]);
		var orders = [for (x in tins.allTinItems) x.o];
		Assert.equals("1,2,3,4", orders.join(","));
	}

	// 少于四项：splice(-4,4) 同样切走全部 → 不旋转
	public function test_allTinItems_under_four() {
		tins.addTinItems([sampleItem(1, 2), sampleItem(2, 1)]);
		var orders = [for (x in tins.allTinItems) x.o];
		Assert.equals("1,2", orders.join(","));
	}

	// allTinItems 是副本（concat）——改写返回值不伤 m_tins
	public function test_allTinItems_returns_copy() {
		tins.addTinItems([sampleItem(1, 1)]);
		var out = tins.allTinItems;
		out.push({id: 999});
		Assert.equals(1, tins.allTinItems.length);
	}

	// 事件派发：loadingData 置位派 LOAD_STATUS_CHANGED（:41-44）、
	// shopTinInfoErr 置位派 LOAD_TINS_ERROR（:46-49）、addTinItems 派
	// LOAD_TINS_SUCCESS
	public function test_events_dispatch() {
		var events:Array<String> = [];
		tins.addEventListener(TinItemsData.LOAD_STATUS_CHANGED, function(e) events.push("status"));
		tins.addEventListener(TinItemsData.LOAD_TINS_ERROR, function(e) events.push("error"));
		tins.addEventListener(TinItemsData.LOAD_TINS_SUCCESS, function(e) events.push("success"));
		tins.loadingData = true;
		tins.shopTinInfoErr = "err";
		tins.addTinItems([sampleItem(1, 1)]);
		Assert.equals("status,error,success", events.join(","));
	}

	// 构造缺省态（:20-26）：m_tins 空、shopTinInfoErr ""、loadingData false
	public function test_initial_state() {
		Assert.equals(0, tins.allTinItems.length);
		Assert.equals("", tins.shopTinInfoErr);
		Assert.isFalse(tins.loadingData);
	}
}

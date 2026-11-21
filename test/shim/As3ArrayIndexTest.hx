package shim;

import openfl.utils.Dictionary;
import utest.Assert;

/**
 * As3.arrayIndex：AS3 数组按字符串键取值（issue #18 实现复审驳回返工）。
 *
 * 出处：
 * - legacy/decompiled/main3_v_221/scripts/com/qzone/qui/containers/TileList.as:124
 *   `_loc1_[dataField] = _data[_loc2_ + _loc3_ * this.maxGrop];`——_loc2_ 是
 *   for-in 的 String 键（"0","1",…），AS3 的 String + Number 是**拼接**：
 *   行 0（_loc3_=0，maxGrop=12）得键 "00","10","20"…；行 1 得 "012","112"…
 * - 字符串键取 AS3 Array：正则无符号整数字串（无前导零、≤ 2^32-2）就是
 *   下标访问（越界 undefined）；其余字串是动态属性，数组没人挂过 →
 *   undefined。原版数据绑定因此本来就是坏的（行 0 首列恒 undefined、其余
 *   列落错位元素），照译不修（TileList.hx PORT-NOTE，偏差只进
 *   spec/deviations.json）。
 * - Dictionary 混键种：legacy/decompiled/main3_v_221/scripts/com/qzone/qui/
 *   containers/ViewStack.as:25-28——读门按 name 字符串键（`!this._childObject
 *   [param1.name]`）、写入按对象键（`this._childObject[param1] = true`），
 *   字符串键从未写入 → 读门恒过（去重从未生效），ViewStack.hx 照译死门。
 */
class As3ArrayIndexTest {
	public function new() {}

	// TileList.as:124 的完整取值链：拼接键 + 字符串键取数组。
	// 24 元素数据（2 行 × maxGrop=12）下：行 0 首列 "00" 非正则 → undefined；
	// 行 0 其余列 "10","20" 落错位元素（data[10]、data[20]）；行 1 全列
	// "012"…"912" 非正则或越界 → undefined
	public function testTileListConcatKeyBinding() {
		var data:Array<Dynamic> = [];
		for (i in 0...24) {
			data[i] = "elem" + i;
		}
		var maxGrop:Int = 12;
		// 行 0（_loc3_=0）：_loc2_ + String(0*12)
		Assert.equals(null, As3.arrayIndex(data, "0" + Std.string(0 * maxGrop)), "row0 col0 key=00");
		Assert.equals("elem10", As3.arrayIndex(data, "1" + Std.string(0 * maxGrop)), "row0 col1 key=10");
		Assert.equals("elem20", As3.arrayIndex(data, "2" + Std.string(0 * maxGrop)), "row0 col2 key=20");
		Assert.equals(null, As3.arrayIndex(data, "23" + Std.string(0 * maxGrop)), "row0 col23 key=230 越界");
		// 行 1（_loc3_=1）：_loc2_ + String(1*12)
		Assert.equals(null, As3.arrayIndex(data, "0" + Std.string(1 * maxGrop)), "row1 col0 key=012");
		Assert.equals(null, As3.arrayIndex(data, "1" + Std.string(1 * maxGrop)), "row1 col1 key=112 越界");
		Assert.equals(null, As3.arrayIndex(data, "9" + Std.string(1 * maxGrop)), "row1 col9 key=912 越界");
	}

	// 正则数字串 = 下标访问的边界表
	public function testCanonicalIndexLookup() {
		var data:Array<Dynamic> = ["a", "b", "c"];
		Assert.equals("a", As3.arrayIndex(data, "0"), "单字 0 正则");
		Assert.equals("c", As3.arrayIndex(data, "2"), "末位");
		Assert.equals(null, As3.arrayIndex(data, "3"), "越界 undefined");
		Assert.equals(null, As3.arrayIndex(data, "00"), "前导零非正则");
		Assert.equals(null, As3.arrayIndex(data, "01"), "前导零非正则");
		Assert.equals(null, As3.arrayIndex(data, ""), "空串动态属性");
		Assert.equals(null, As3.arrayIndex(data, "1.5"), "小数串动态属性");
		Assert.equals(null, As3.arrayIndex(data, "1e2"), "指数串动态属性");
		Assert.equals(null, As3.arrayIndex(data, "-1"), "带符号串动态属性");
		Assert.equals(null, As3.arrayIndex(data, "2x"), "非数串动态属性");
		Assert.equals(null, As3.arrayIndex(data, "9999999999"), "超 2^32-2 按属性名");
		Assert.equals(null, As3.arrayIndex(null, "0"), "null 数组");
	}

	// ViewStack.as:25-28 的死门机制：同一 Dictionary 对象键写入后，name
	// 字符串键读恒 miss（undefined）——去重从未生效，addView 重复入列照译
	public function testViewStackDictionaryMixedKeys() {
		var dict:Dictionary<{}, Bool> = new Dictionary<{}, Bool>();
		var child:Dynamic = {"name": "view0"};
		dict.set(child, true);
		Assert.equals(null, dict.get("view0"), "name 键从未写入恒 miss");
		Assert.equals(true, dict.get(child), "对象键照常读回");
	}
}

package mc.view.common;

import com.minutes.ui.collections.LipiListChild;
import mc.view.common.HList;
import openfl.display.DisplayObject;
import utest.Assert;

/**
 * mc.view.common.HList 纯逻辑（issue #87 write-tests，对 stub 失败）：
 * 横向滚动列表的布局数学——align 三分支首件定位、rightMove/leftMove
 * 钳制与返回值、rightEnabled/leftEnabled 使能判据、width/height 覆写。
 *
 * 期望值出处：legacy/decompiled/Master2_v_142/scripts/mc/view/common/HList.as
 * —— 构造 :32-39（_itemClass/_gap 存、_childSprite 建并入树）；
 * setChild :105-127（数据长于子件则 new _itemClass() 补、逐项写 data、
 * 多余子件尾删、收尾 setChildPosition + scrollRect(0,0,width,height)
 * 归位 + offsetX/itemPosition 清零）；setChildPosition :142-172
 * （left → 首件 x=0；center → (width - (numChildren*(child0.width+gap)
 * - 1)) / 2；其余（含 right）→ width - (numChildren*(child0.width+gap)
 * - 1)；随后逐件 x 累进 child.width+gap）；rightMove :65-83
 * （childSprite.width < width → false 不动；offsetX+width+param1 超
 * childSprite.width → offsetX 钳到 childSprite.width-width 返 false，
 * 否则累进返 true；两路都刷 scrollRect(offsetX,offsetY,width,height)）；
 * rightEnabled :91-98（offsetX >= childSprite.width - width - 5 →
 * false）；leftEnabled :200-207（offsetX <= 0 → false）；leftMove
 * :209-223（offsetX-param1 < 0 → 钳 0 返 false，否则减量返 true）；
 * width/height 覆写 :100-103/:113-117/:171-180/:182-198（返回私有
 * _width/_height（缺省 100 :16/:24），setter 清 offsetX/offsetY 并
 * 刷 scrollRect）；align setter :59-63（存并重排）；dataList setter
 * :85-89（存并 setChild）。
 *
 * 显示对象在 eval 无头环境可测（NumbericStepperTest 先例）；列表项用
 * 本文件尾部的测试渲染类（LipiListChild 子类，构造画 30×10 矩形——
 * width 由图形测量自然得 30，data setter 继承父类）。
 *
 * 布局推导（width=100、gap=10、三件各宽 30 的通用场景）：
 * left：首件 x=0，逐件 +40 → 0/40/80；childSprite 内容右缘 80+30=110。
 * center：首件 = (100 - (3*(30+10) - 1)) / 2 = (100-119)/2 = -9.5
 * → -9.5/30.5/70.5。right：首件 = 100 - 119 = -19 → -19/21/61。
 * （注意原文公式的 -1 是逐字语义——非排版直觉的 -gap，照抄。）
 *
 * stub 期 ctor 起全 throw not implemented——本测试必然等 implement
 * 充真身才绿（write-tests 的意图即如此）。
 */
@:access(mc.view.common.HList)
class HListTest {
	public function new() {}

	// 通用场景：gap=10 三件宽 30（构造即建 _childSprite 入树——:37-38）
	function buildList(w:Float = 100):HList {
		var list = new HList(TestHListItem, 10);
		list.width = w;
		return list;
	}

	function fill3(list:HList):Void {
		list.dataList = [{n: 1}, {n: 2}, {n: 3}];
	}

	function childX(list:HList, i:Int):Float {
		return cast(list._childSprite.getChildAt(i), DisplayObject).x;
	}

	// setChild 实例化与 data 通道（:105-127）：dataList 三项 → 三个
	// _itemClass 实例入 _childSprite、逐项写 data
	public function test_setChild_instantiates_and_assigns_data() {
		var list = buildList();
		fill3(list);
		Assert.equals(3, list._childSprite.numChildren);
		var item0 = cast(list._childSprite.getChildAt(0), LipiListChild);
		Assert.equals(1, item0.data.n);
		var item2 = cast(list._childSprite.getChildAt(2), LipiListChild);
		Assert.equals(3, item2.data.n);
	}

	// setChild 收缩（:119-122）：dataList 从 3 缩 1 → 尾删到 1 件
	public function test_setChild_removes_surplus() {
		var list = buildList();
		fill3(list);
		list.dataList = [{n: 9}];
		Assert.equals(1, list._childSprite.numChildren);
		Assert.equals(9, cast(list._childSprite.getChildAt(0), LipiListChild).data.n);
	}

	// setChild 复用（:111-115）：已有子件不重建只重写 data——同实例保留
	public function test_setChild_reuses_existing_children() {
		var list = buildList();
		fill3(list);
		var before = list._childSprite.getChildAt(0);
		list.dataList = [{n: 7}, {n: 8}, {n: 9}];
		Assert.equals(before, list._childSprite.getChildAt(0));
		Assert.equals(7, cast(list._childSprite.getChildAt(0), LipiListChild).data.n);
	}

	// align left 定位（:146-149 + :165-171）：首件 x=0、逐件 +宽+gap
	public function test_align_left_positions() {
		var list = buildList();
		fill3(list);
		Assert.equals(0.0, childX(list, 0));
		Assert.equals(40.0, childX(list, 1));
		Assert.equals(80.0, childX(list, 2));
	}

	// align center（:150-159）：首件 = (100 - (3*40 - 1)) / 2 = -9.5
	public function test_align_center_positions() {
		var list = buildList();
		fill3(list);
		list.align = "center";
		Assert.floatEquals(-9.5, childX(list, 0));
		Assert.floatEquals(30.5, childX(list, 1));
		Assert.floatEquals(70.5, childX(list, 2));
	}

	// align right（else 分支 :161-164）：首件 = 100 - 119 = -19
	public function test_align_right_positions() {
		var list = buildList();
		fill3(list);
		list.align = "right";
		Assert.floatEquals(-19.0, childX(list, 0));
		Assert.floatEquals(21.0, childX(list, 1));
		Assert.floatEquals(61.0, childX(list, 2));
	}

	// width=200 场景的三分支（钉公式对 width 的依赖）：
	// center (200-119)/2=40.5；right 200-119=81
	public function test_align_positions_width200() {
		var list = buildList(200);
		fill3(list);
		list.align = "center";
		Assert.floatEquals(40.5, childX(list, 0));
		list.align = "right";
		Assert.floatEquals(81.0, childX(list, 0));
		list.align = "left";
		Assert.equals(0.0, childX(list, 0));
	}

	// width/height 覆写（:100-103/:182-186）：缺省 100、setter 写后回读
	public function test_width_height_defaults_and_override() {
		var list = new HList(TestHListItem, 10);
		Assert.equals(100.0, list.width);
		Assert.equals(100.0, list.height);
		list.width = 250;
		list.height = 60;
		Assert.equals(250.0, list.width);
		Assert.equals(60.0, list.height);
	}

	// rightMove 正常累进（:77-80）：内容 110 宽、视口 100 → 可右移。
	// rightMove(5)：0+100+5=105 不超 110 → offsetX=5 返 true、
	// scrollRect.x=5
	public function test_rightMove_moves_and_returns_true() {
		var list = buildList();
		fill3(list);
		Assert.isTrue(list.rightMove(5));
		Assert.equals(5.0, list.scrollRect.x);
		Assert.equals(100.0, list.scrollRect.width);
	}

	// rightMove 钳制（:72-76）：offsetX 5 再移 20 → 5+100+20=125>110
	// → offsetX 钳 110-100=10、返 false、scrollRect.x=10
	public function test_rightMove_clamps_at_edge() {
		var list = buildList();
		fill3(list);
		list.rightMove(5);
		Assert.isFalse(list.rightMove(20));
		Assert.equals(10.0, list.scrollRect.x);
	}

	// rightMove 内容不足（:67-70）：width 200 > 内容 110 → false 且
	// scrollRect 不刷（提前 return，:81 不到——x 保持 setChild 归位的 0）
	public function test_rightMove_narrow_content_returns_false() {
		var list = buildList(200);
		fill3(list);
		Assert.isFalse(list.rightMove(5));
		Assert.equals(0.0, list.scrollRect.x); // 未刷——setChild 归位态原样
	}

	// rightEnabled（:91-98）：offsetX 0 → 0 >= 110-100-5=5 不成立 → true；
	// 钳到右缘 offsetX=10 → 10>=5 → false
	public function test_rightEnabled() {
		var list = buildList();
		fill3(list);
		Assert.isTrue(list.rightEnabled);
		list.rightMove(50); // 钳到 10
		Assert.isFalse(list.rightEnabled);
	}

	// leftMove（:209-223）：右移后左移——offsetX 10 减 5 → 5 返 true；
	// 再减 10 → 5-10<0 → 钳 0 返 false
	public function test_leftMove_moves_and_clamps() {
		var list = buildList();
		fill3(list);
		list.rightMove(50); // 钳到 offsetX=10
		Assert.isTrue(list.leftMove(5));
		Assert.equals(5.0, list.scrollRect.x);
		Assert.isFalse(list.leftMove(10));
		Assert.equals(0.0, list.scrollRect.x);
	}

	// leftEnabled（:200-207）：offsetX<=0 → false；右移后 → true
	public function test_leftEnabled() {
		var list = buildList();
		fill3(list);
		Assert.isFalse(list.leftEnabled);
		list.rightMove(5);
		Assert.isTrue(list.leftEnabled);
	}

	// setChild 归位（:124-126）：滚动后重设 dataList → scrollRect 回
	// (0,0,w,h)、offsetX 清 0——rightEnabled 立即可用
	public function test_setChild_resets_scroll() {
		var list = buildList();
		fill3(list);
		list.rightMove(5);
		list.dataList = [{n: 1}, {n: 2}, {n: 3}];
		Assert.equals(0.0, list.scrollRect.x);
		Assert.isTrue(list.rightEnabled);
		Assert.isFalse(list.leftEnabled);
	}

	// width setter 清滚动（:174-180）：offsetX 清 0、scrollRect 重刷
	public function test_width_setter_resets_scroll() {
		var list = buildList();
		fill3(list);
		list.rightMove(5);
		list.width = 150;
		Assert.equals(0.0, list.scrollRect.x);
		Assert.equals(150.0, list.scrollRect.width);
	}

	// dataList getter（:187-190）：存入数组同一引用返回
	public function test_dataList_roundtrip() {
		var list = buildList();
		var data:Array<Dynamic> = [{n: 1}];
		list.dataList = data;
		Assert.equals(data, list.dataList);
	}

	// align getter 缺省 "left"（:14 + :54-57）
	public function test_align_default_left() {
		var list = new HList(TestHListItem, 10);
		Assert.equals("left", list.align);
	}
}

/**
 * 测试渲染项：LipiListChild 子类、零参构造（:113 `new _itemClass()`
 * 的实例化形态），构造画 30×10 矩形使 width 测量为 30。
 */
class TestHListItem extends LipiListChild {
	public function new() {
		super();
		this.graphics.beginFill(0);
		this.graphics.drawRect(0, 0, 30, 10);
		this.graphics.endFill();
	}
}

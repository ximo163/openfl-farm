package common.cache;

import openfl.errors.Error;
import utest.Assert;

/**
 * ObjectPool/SimpleFactory 纯逻辑（issue #37）：pool_v_13 特有
 * common.cache 包的通用对象池（供 FishMCPoolObjectMgr 回收鱼
 * MovieClip）。allocate 预建与计数、borrow 借尽抛「object pool
 * exhausted.」、grow=true 借满翻一档 initSize、restore 归还后同实例复用、
 * purge 的 idle 裁回 initSize / 有借出时只留借出节点并补足、initialze
 * 对全池反射调方法、destroy 后可重建、setFactory 注入工厂、
 * SimpleFactory 的 null 类返回 null。
 * 全部走公开 API，无显示对象/网络/时间。
 *
 * 出处：
 * - legacy/decompiled/pool_v_13/scripts/common/cache/ObjectPool.as
 *   （ctor :24-28、size :30-33、purge :35-113、setFactory :115-118、
 *   restore :120-128、wasteCount :130-133、createObject :135-142、
 *   usageCount :144-147、borrow :149-183、initialze :185-197、destroy
 *   :199-211、allocate :213-239）
 * - legacy/decompiled/pool_v_13/scripts/common/cache/SimpleFactory.as
 *   （ctor :10-14、create :16-22）
 * - spec/modules/water-ui.json（common.cache 三类为本 swf 特有的说明）
 */
class ObjectPoolTest {
	public function new() {}

	// allocate 无工厂可造时抛「nothing to instantiate.」（:221-224）
	public function test_allocate_without_factory_throws() {
		var pool = new ObjectPool(false);
		Assert.raises(function() pool.allocate(2, null), Error);
		try {
			pool.allocate(2, null);
			Assert.fail("应抛 Error");
		} catch (e:Error) {
			Assert.equals("nothing to instantiate.", e.message); // :223
		}
	}

	// allocate(size, cls)：size/usageCount/wasteCount（:225-238 + :30-33/
	// :130-133/:144-147）
	public function test_allocate_counters() {
		var pool = new ObjectPool(false);
		Assert.equals(0, pool.size); // 未 allocate
		pool.allocate(3, PoolToy);
		Assert.equals(3, pool.size);
		Assert.equals(0, pool.usageCount);
		Assert.equals(3, pool.wasteCount);
	}

	// grow=false：借尽抛「object pool exhausted.」（:155-160）；未 allocate
	// 的池 currSize=0 同样抛
	public function test_borrow_exhausts_and_throws() {
		var pool = new ObjectPool(false);
		pool.allocate(2, PoolToy);
		var a = pool.borrow();
		var b = pool.borrow();
		Assert.isTrue(a != null && b != null);
		Assert.isFalse(a == b); // 两个不同实例
		Assert.equals(2, pool.usageCount);
		Assert.equals(0, pool.wasteCount);
		Assert.raises(function() pool.borrow(), Error);
		try {
			pool.borrow();
			Assert.fail("应抛 Error");
		} catch (e:Error) {
			Assert.equals("object pool exhausted.", e.message); // :159
		}

		var fresh = new ObjectPool(false); // 未 allocate
		Assert.raises(function() fresh.borrow(), Error);
	}

	// grow=true：借满后 _currSize += _initSize（:157-177）
	public function test_grow_pool_extends_by_initSize() {
		var pool = new ObjectPool(true);
		pool.allocate(2, PoolToy);
		Assert.equals(2, pool.size);
		pool.borrow();
		pool.borrow();
		Assert.equals(2, pool.size);
		var c = pool.borrow(); // 第三次：翻档到 4
		Assert.isTrue(c != null);
		Assert.equals(4, pool.size); // :161
		Assert.equals(3, pool.usageCount);
	}

	// restore 归还计数（:120-128），随后 borrow 复用同一实例（环形 _emptyNode
	// 回填 :125-126 + borrow 取 _allocNode :178-182）
	public function test_restore_recycles_same_instance() {
		var pool = new ObjectPool(false);
		pool.allocate(2, PoolToy);
		var a = pool.borrow();
		var b = pool.borrow();
		Assert.equals(2, pool.usageCount);
		pool.restore(a);
		Assert.equals(1, pool.usageCount); // :124
		Assert.equals(1, pool.wasteCount);
		var c = pool.borrow();
		Assert.equals(a, c); // 同实例复用
		Assert.equals(2, pool.usageCount);
		Assert.isTrue(c != b);
	}

	// setFactory 注入（:115-118 + allocate 的 :221 分支）
	public function test_setFactory_path() {
		var pool = new ObjectPool(false);
		pool.setFactory(new SimpleFactory(PoolToy));
		pool.allocate(2, null); // 无 cls 但有工厂：可造
		Assert.equals(2, pool.size);
		Assert.isTrue(pool.borrow() != null);
	}

	// SimpleFactory：null 类返回 null（:17-19），正类 new 实例（:20-21）
	public function test_simpleFactory_create() {
		Assert.isNull(new SimpleFactory(null).create());
		var made = new SimpleFactory(PoolToy).create();
		Assert.isTrue(Std.isOfType(made, PoolToy));
		Assert.isFalse(made == new SimpleFactory(PoolToy).create()); // 每次 new
	}

	// purge idle（usageCount==0）：currSize > initSize 时裁回 initSize
	// （:49-62）；已等于 initSize 时早退不变（:45-48）
	public function test_purge_shrinks_idle_pool_to_initSize() {
		var pool = new ObjectPool(true);
		pool.allocate(2, PoolToy);
		var toys = [];
		for (i in 0...3) {
			toys.push(pool.borrow()); // 第三次借出触发翻档到 4
		}
		for (t in toys) {
			pool.restore(t);
		}
		Assert.equals(0, pool.usageCount);
		Assert.equals(4, pool.size);

		pool.purge();
		Assert.equals(2, pool.size); // :60 裁回 initSize
		Assert.equals(0, pool.usageCount);
		Assert.equals(2, pool.wasteCount);
		Assert.isTrue(pool.borrow() != null); // 池仍可用

		var idle = new ObjectPool(false); // 未增长：purge 早退
		idle.allocate(2, PoolToy);
		idle.purge();
		Assert.equals(2, idle.size);
		Assert.equals(0, idle.usageCount);
	}

	// purge 有借出（:66-111）：只留借出节点重建环（_currSize=_usageCount=
	// 借出数，:80-81），再补足到 initSize（:93-95），allocNode 指向补足的
	// 新节点（:110）——下一次 borrow 拿到新对象，已借出的 a 不受影响
	public function test_purge_with_active_usage_tops_up() {
		var pool = new ObjectPool(false);
		pool.allocate(2, PoolToy);
		var a = pool.borrow();
		Assert.equals(1, pool.usageCount);

		pool.purge();
		Assert.equals(2, pool.size); // 补足回 initSize
		Assert.equals(1, pool.usageCount);
		Assert.equals(1, pool.wasteCount);

		var fresh = pool.borrow();
		Assert.isFalse(fresh == a); // 新节点的新对象
		Assert.equals(2, pool.usageCount);
	}

	// initialze（原版拼写）对全池对象按名反射调方法（:185-197）
	public function test_initialze_invokes_method_on_all_pooled_objects() {
		var pool = new ObjectPool(false);
		pool.allocate(3, PoolToy);
		pool.initialze("touch", ["pinned"]);
		var seen = 0;
		for (i in 0...3) {
			var toy:PoolToy = pool.borrow();
			if (toy.tag == "pinned") {
				seen++;
			}
		}
		Assert.equals(3, seen);
	}

	// destroy 清链（:199-211），随后 allocate 重建为全新池（:213-216 先
	// destroy）：size/usageCount 归零起步，对象为新实例
	public function test_destroy_then_allocate_rebuilds() {
		var pool = new ObjectPool(false);
		pool.allocate(2, PoolToy);
		var a = pool.borrow();
		pool.destroy();
		pool.allocate(2, PoolToy);
		Assert.equals(2, pool.size);
		Assert.equals(0, pool.usageCount);
		var b = pool.borrow();
		Assert.isFalse(b == a); // 重建后的新对象
	}
}

// 池化目标类型（initialze 反射调 touch）
private class PoolToy {
	public var tag:String;

	public function new() {
		this.tag = "";
	}

	public function touch(s:String):Void {
		this.tag = s;
	}
}

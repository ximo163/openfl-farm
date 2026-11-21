package com.qzone.sns.entities;

import utest.Assert;

/**
 * Payment 纯逻辑（issue #18）：支付单实体——全局序号分配、对账参数拼装、
 * 回调派发。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/sns/entities/Payment.as
 * （BILL_SEQ :8、字段 :10-24、ctor :26-37、nextSeq :39-42、notify :44-50、
 * buildCheckParams :52-61）。支付参数最终发往 Qzone 收银台（域外联，
 * QQOutlets shim 出口），mync.php 白名单无对应 mod，客户端反编译即唯一依据。
 * _stamp 取 getTimer()（:36 真实时钟），不断言；BILL_SEQ 是全局静态，
 * teardown 复位避免影响其它用例。
 */
class PaymentTest {
	public function new() {}

	public function teardown() {
		Payment.BILL_SEQ = 1; // :8 初值
	}

	// :29 ctor bill = BILL_SEQ++（首单 1）、:39-42 nextSeq 再取 2 —— 全局递增
	public function test_bill_seq_increments_across_payments_and_nextSeq() {
		var p1 = new Payment(1001, 2, 3, 4);
		Assert.equals(1, p1.bill);
		Assert.equals(2, Payment.nextSeq());
		var p2 = new Payment(1005, 1, 1, 1);
		Assert.equals(3, p2.bill);
		Assert.equals(4, Payment.BILL_SEQ);
	}

	// :27-35 ctor 字段就位（id/type/num/shopType 按位；misc/callback 显式 null）
	public function test_constructor_assigns_fields_in_order() {
		var p = new Payment(1001, 2, 3, 4);
		Assert.equals(1001, p.id);
		Assert.equals(2, p.type);
		Assert.equals(3, p.num);
		Assert.equals(4, p.shopType);
		Assert.isNull(p.misc);
		Assert.isNull(p.callback);
	}

	// :52-61 对账参数五键，键名逐字（clientBill/itemId/itemType/itemNum/shopType）
	public function test_buildCheckParams_assembles_five_check_keys() {
		var p = new Payment(1001, 2, 3, 4);
		var o:Dynamic = p.buildCheckParams();
		Assert.equals(1, Reflect.field(o, "clientBill")); // 本单 bill
		Assert.equals(1001, Reflect.field(o, "itemId"));
		Assert.equals(2, Reflect.field(o, "itemType"));
		Assert.equals(3, Reflect.field(o, "itemNum"));
		Assert.equals(4, Reflect.field(o, "shopType"));
	}

	// :44-50 notify → callback(flag, success, payment自身, rawData) 四参透传
	public function test_notify_forwards_four_args_to_callback() {
		var p = new Payment(1001, 2, 3, 4);
		var got:Array<Dynamic> = [];
		p.callback = function(flag:Int, ok:Bool, self:Payment, data:Dynamic):Void {
			got.push(flag);
			got.push(ok);
			got.push(self);
			got.push(data);
		};
		p.notify(7, true, "misc");
		Assert.equals(4, got.length);
		Assert.equals(7, got[0]);
		Assert.isTrue(got[1]);
		Assert.equals(p, got[2]); // :48 第三参是 this
		Assert.equals("misc", got[3]);
	}

	// :46-47 callback 为 null 时 notify 静默返回（ctor 默认即 null）
	public function test_notify_without_callback_is_silent_noop() {
		var p = new Payment(1001, 2, 3, 4);
		Assert.isNull(p.callback);
		p.notify(1, false, null); // 不抛即过
		Assert.isTrue(true);
	}
}

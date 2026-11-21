package com.qzone.sns.entities;

import shim.As3;

/**
 * com.qzone.sns.entities.Payment —— Payment.as 逐句对应（issue #18 farm-basic
 * 收尾：支付片整类翻译）。支付单实体：全局序号、对账参数拼装、回调派发。
 * AS3 `public final class` → Haxe `final class`（不写 extends 并不等于
 * final——Haxe 类默认可继承，final 必须显式）。支付参数最终发往 Qzone
 * 收银台（域外联，QQOutlets shim 出口），客户端反编译即唯一依据。
 * _stamp 取 getTimer() 真实时钟（:36）。
 */
final class Payment {
	// Payment.as:8
	public static var BILL_SEQ:UInt = 1;

	// :10-24
	public var _stamp:Int;

	public var callback:Dynamic;

	public var num:Int;

	public var bill:Int;

	public var shopType:Int;

	public var misc:Dynamic;

	public var type:Int;

	public var id:Int;

	// :26-37
	public function new(param1:UInt, param2:Int, param3:UInt, param4:Int) {
		this.bill = BILL_SEQ++;
		this.misc = null;
		this.callback = null;
		this.id = param1;
		this.type = param2;
		this.shopType = param4;
		this.num = param3;
		this._stamp = As3.getTimer();
	}

	// :39-42
	public static function nextSeq():UInt {
		return BILL_SEQ++;
	}

	// :44-50（AS3 Function 调用 → Dynamic 反射调用）
	public function notify(param1:Int, param2:Bool, param3:Dynamic):Void {
		if (this.callback != null) {
			this.callback(param1, param2, this, param3);
		}
	}

	// :52-61
	public function buildCheckParams():Dynamic {
		return {
			"clientBill": this.bill,
			"itemId": this.id,
			"itemType": this.type,
			"itemNum": this.num,
			"shopType": this.shopType
		};
	}
}

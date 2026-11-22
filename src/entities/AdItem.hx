package entities;

import openfl.errors.Error;

// entities.AdItem —— issue #35 write-tests 签名 stub（AdItem.as 44 loc，
// shop_v_7 广告条目实体；AS3 final 照写）。合作专区/广告位条目
// （view_fcg 下发的 list 元素）：img 为服务端外链图片地址、rl 为落地页。
// importObject 走 Utils.getStrAttribute（缺键回 ""），importFromCache 裸读
// 同名字段（AS3 未初始化 String 为 null，构造器 importObject(null) 早退后
// 三字段保持 null）。字段与方法签名照抄 AS3，体 throw not implemented。
@:final
class AdItem {
	// AdItem.as:8
	public var _img:String;

	// AdItem.as:10
	public var _rl:String;

	// AdItem.as:12
	public var _acurl:String;

	// AdItem.as:14-18（ctor 只调 importObject；importObject 是实现内容，
	// stub 只保可构造）
	public function new(param1:Dynamic) {}

	// AdItem.as:20-29
	public function importFromCache(param1:Dynamic):Void {
		throw new Error("not implemented");
	}

	// AdItem.as:31-40
	public function importObject(param1:Dynamic):Void {
		throw new Error("not implemented");
	}
}

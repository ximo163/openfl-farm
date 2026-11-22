package entities;

import common.misc.Utils;

// entities.AdItem —— AdItem.as 逐句对应（issue #35 功能 swf 翻译：商店）。
// shop_v_7 广告条目实体（view_fcg 下发的 list 元素）：img 为服务端外链图片
// 地址、rl 为落地页。AS3 final 照写。
// 字段不内联初始化：AS3 未初始化 String 为 null，构造器 importObject(null)
// 早退后三字段保持 null（AdItemTest 钉此行为）。
@:final
class AdItem {
	// AdItem.as:8
	public var _img:String;

	// AdItem.as:10
	public var _rl:String;

	// AdItem.as:12
	public var _acurl:String;

	// AdItem.as:14-18
	public function new(param1:Dynamic) {
		this.importObject(param1);
	}

	// AdItem.as:20-29
	public function importFromCache(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._img = param1._img;
		this._rl = param1._rl;
		this._acurl = param1._acurl;
	}

	// AdItem.as:31-40
	public function importObject(param1:Dynamic):Void {
		if (param1 == null) {
			return;
		}
		this._img = Utils.getStrAttribute(param1, "img");
		this._rl = Utils.getStrAttribute(param1, "rl");
		this._acurl = Utils.getStrAttribute(param1, "acurl");
	}
}

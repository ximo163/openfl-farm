package common.view;

import com.qzone.qfa.managers.ResourceManager;
import openfl.display.Sprite;

/**
 * common.view.MaterialProxyBig —— MaterialProxyBig.as 逐句对应
 * （issue #35 功能 swf 翻译：商店）。放大版物品图标代理：ItemBg 底板
 * （ResourceManager 反射取）+ MaterialProxy(BIG)。买入窗口的物品预览位。
 * 同包引用 main3 common.view.MaterialProxy（AS3 未 import，Haxe 同包同样
 * 无需 import）。warehouse_v_23 另有一份本地副本、内容略有差异（spec notes）。
 */
class MaterialProxyBig extends Sprite {
	// MaterialProxyBig.as:9
	private var materialProxy:MaterialProxy;

	// MaterialProxyBig.as:11-21
	public function new(param1:Int = 120) {
		var _loc2_:Sprite = null;
		super();
		// getClassInstance 返回 Dynamic；cast 到真类型后 width/height 走
		// openfl Sprite 真属性（禁 Dynamic 裸写的分流规则）。
		_loc2_ = cast ResourceManager.gi().getClassInstance("ItemBg");
		_loc2_.name = "ItemBg";
		_loc2_.width = param1;
		_loc2_.height = param1;
		addChild(_loc2_);
		this.materialProxy = new MaterialProxy(MaterialProxy.BIG);
		addChild(this.materialProxy);
	}

	// MaterialProxyBig.as:23-26
	public function loadBillBoard(param1:String):Void {
		this.materialProxy.loadBillBoard(param1);
	}

	// MaterialProxyBig.as:28-31
	public function setContent(param1:String, param2:Int, param3:Bool = true):Void {
		this.materialProxy.setContent(param1, param2, param3);
	}
}

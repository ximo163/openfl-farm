package mc.model;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import mc.view.farm.GetCropID;
import shim.As3;

/**
 * mc.model.ProductData —— ProductData.as 逐句对应（issue #19 Master2 闭包
 * 顺手译）。_products 是字符串键对象，经 Dynamic 下标读写（等价 AS3 E4X 式
 * 下标）。GetCropID 为牧场片 stub（777 行，真身待译——#pasture）。
 */
@:keep
class ProductData extends EventDispatcher {
	// ProductData.as:10-18
	public static final ANIMAL_FOOD:String = "animalFood_Change";
	public static final PRODUCT_CHANGES:String = "product_change";
	public static final PRODUCT_CANDO:String = "product_cando";
	public static final PRODUCT_INIT:String = "product_init";
	public static final PRODUCT_ADD:String = "product_addproduct";

	private var _products:Dynamic;

	public function new() {
		super();
	}

	// ProductData.as:27-41（AS3 for-in 键仅用于取元素，稠密数组按值迭代等价；
	// for-in over null 原版零次迭代，加 null 守卫；字符串键下标按 AS3 的
	// String(键) 强转经 Reflect.setField/field 读写）
	public function init(param1:Dynamic):Void {
		this._products = {};
		var _loc2_:Array<Dynamic> = Reflect.field(param1, "animal");
		if (_loc2_ != null) {
			for (_loc3_ in _loc2_) {
				Reflect.setField(this._products, Std.string(_loc3_.cId), {
					"cName": GetCropID.getProductName2(_loc3_.cId),
					"amount": 0,
					"cando": 0
				});
			}
		}
		dispatchEvent(new Event(ProductData.PRODUCT_INIT));
	}

	// ProductData.as:43-51
	public var products(get, set):Dynamic;

	private function get_products():Dynamic {
		return this._products;
	}

	private function set_products(param1:Dynamic):Dynamic {
		this._products = param1;
		return param1;
	}

	// ProductData.as:53-56
	public function getProduct(param1:String):Dynamic {
		return Reflect.field(this._products, param1);
	}

	// ProductData.as:58-61
	public function addCando(param1:String, param2:Float):Void {
		Reflect.setField(Reflect.field(this._products, param1), "cando", param2);
	}

	// ProductData.as:63-87
	public function addProduct(param1:String, param2:Float, param3:Bool = false, param4:Bool = false):Void {
		var _loc5_:ModelEvent = null;
		if (!As3.truthy(Reflect.field(this._products, param1))) {
			Reflect.setField(this._products, param1, {
				"cName": GetCropID.getProductName2(param1),
				"amount": 0,
				"cando": 0
			});
			_loc5_ = new ModelEvent(ProductData.PRODUCT_ADD);
			_loc5_.data = param1;
			dispatchEvent(_loc5_);
		}
		var _loc6_:Dynamic = Reflect.field(this._products, param1);
		_loc6_.amount += param2;
		if (param3) {
			Reflect.setField(_loc6_, "amount", 0);
		}
		if (param4) {
			Reflect.setField(_loc6_, "cando", 3);
		}
		dispatchEvent(new Event(ProductData.PRODUCT_CHANGES));
	}
}

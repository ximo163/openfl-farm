package entities;

// Item.as —— V3b/V3c 模块翻译（issue #7 闭包类：ItemsDataParser 只把它设为
// _class 反射构造，商店/道具数据本片不加载），stub 同 entities/Dog 先例。
@:keep
class Item {
	public function new(param1:Dynamic = null) {}

	// ---- issue #9 补的闭包成员（UIController.onGetDogValidTime 构造藏獒
	// Item 派发 MSG_SHOW_BUY_DOG_FOOD，字段声明照抄 Item.as，构造器默认值
	// 照抄 Item.as:52-54）----
	// Item.as:8（构造器 :52 置 false）
	public var _isQDDog:Bool = false;
	// Item.as:16（构造器 :52 置 false）
	public var _renew:Bool = false;
	// Item.as:42
	public var _id:Int;
	// Item.as:18
	public var _type:Int;
	// Item.as:28
	public var _name:String;
	// Item.as:12
	public var _price:Int;
	// Item.as:34
	public var _desc:String;
	// Item.as:36
	public var _fb:Int;
	// Item.as:44
	public var _yfb:Int;
	// Item.as:32
	public var _timeLimit:Int;
	// Item.as:40/:54（构造器清零）
	public var _buy_1:Int = 0;
	// Item.as:46/:54
	public var _buy_6:Int = 0;
	// Item.as:26/:54
	public var _buy_12:Int = 0;
	// Item.as:30/:54
	public var _Ybuy_1:Int = 0;
	// Item.as:24/:54
	public var _Ybuy_6:Int = 0;
	// Item.as:14/:54
	public var _Ybuy_12:Int = 0;
}

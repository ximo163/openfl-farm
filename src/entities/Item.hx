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
	// ---- issue #29 write-tests 补的闭包成员（DogFoodWindow.addFood 落
	// _effect/_saleOut 字段，声明照抄 Item.as）----
	// Item.as:38（AS3 `*` → Dynamic）
	public var _effect:Dynamic;
	// Item.as:10（构造器 :51 置 false；addFood 置 false 后按 selfDogFood 覆盖）
	public var _saleOut:Bool;
	// ---- issue #35 补的闭包成员（BuyItemWindow.as:410/:593 读 `_vip == 1`、
	// :445 读 `_shortage == true` 切元宝/VIP/缺货按钮排布；写入方是 main3 侧
	// 道具数据解析，随其模块片接入，声明照抄 Item.as）----
	// Item.as:20
	public var _vip:Int;
	// Item.as:22
	public var _shortage:Bool;
}

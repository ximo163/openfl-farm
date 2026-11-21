package module.mainScene.npc.widgets;

import common.Consts;
import common.Language;
import common.misc.Utils;
import common.view.window.AddButtonWindow;
import entities.Item;
import events.CommonEvent;
import interfaces.IMsgCenter;
import module.mainScene.npc.NPCController;
import module.mainScene.npc.NPCView;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import report.UserActionRecorder;
import shim.As3;

/**
 * module.mainScene.npc.widgets.DogFoodWindow —— DogFoodWindow.as 逐句对应
 * （issue #29 替换闭包 stub）。狗粮购买窗：init 建按钮 + 狗粮图/边框/剩余
 * 时长文本，setData 按 hours 拼 html，addFood 构造 9002 礼包派发
 * MSG_SHOW_BUY_DOG_FOOD。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/npc/widgets/DogFoodWindow.as
 */
class DogFoodWindow extends AddButtonWindow {
	// DogFoodWindow.as:21（宿主视图）
	private var m_parent:NPCView;

	// DogFoodWindow.as:23（剩余时长文本，setData 写 htmlText）
	private var m_leftime:TextField;

	// DogFoodWindow.as:25-33（`app as IMsgCenter` 单调进局部过类型门
	//（lessons #18），失配落 null）
	public function new(param1:NPCView) {
		var _locm_:Dynamic = param1.controller.module.app;
		super(Std.isOfType(_locm_, IMsgCenter) ? cast(_locm_, IMsgCenter) : null);
		this.width = 400;
		this.height = 250;
		this.title = Reflect.field(Language.L, "狗狗粮食");
		this.mode = true;
		this.m_parent = param1;
		this.m_leftime = null;
	}

	// DogFoodWindow.as:35-41
	private var controller(get, never):NPCController;

	private function get_controller():NPCController {
		if (this.m_parent == null) {
			return null;
		}
		return this.m_parent.controller;
	}

	// DogFoodWindow.as:45-66（addFood：关窗 → 构造 9002 狗粮礼包 Item → 按
	// selfDogFood["saleOut"] 覆盖 _saleOut → 派发 MSG_SHOW_BUY_DOG_FOOD + 上报）
	private function addFood():Void {
		super.close();
		var _loc1_:Item = new Item(null);
		_loc1_._id = 9002;
		_loc1_._type = 909090;
		_loc1_._name = "狗粮5送2礼包";
		_loc1_._desc = "一次性购买5天狗粮，可额外获赠2天狗粮，让狗狗为您看守农场一周。";
		_loc1_._effect = "";
		_loc1_._price = 0;
		_loc1_._fb = 20;
		_loc1_._yfb = 16;
		_loc1_._timeLimit = 0;
		_loc1_._saleOut = false;
		var _loc2_:Dynamic = this.controller.model.selfDogFood;
		// `["saleOut"] != undefined` 完整映射：AS3 里缺键与 null 都算
		// undefined（lessons #8 双判）
		if (_loc2_ != null && Reflect.hasField(_loc2_, "saleOut") && Reflect.field(_loc2_, "saleOut") != null) {
			// PORT-NOTE: `["saleOut"] as Boolean` 是 AS3 真值转换（""/null 假，
			// "0" 真）→ As3.truthy
			_loc1_._saleOut = As3.truthy(Reflect.field(_loc2_, "saleOut"));
		}
		this.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_BUY_DOG_FOOD, _loc1_));
		UserActionRecorder.recordAction(UserActionRecorder.HF_DOGFOODWINDOW_BUY_CLICKED);
	}

	// DogFoodWindow.as:68-118（init：按钮 + 狗粮图 + 边框 mask + 两段文本。
	// 狗粮图素材 DogFood/DogFoodNull、边框 ItemBorder 均经反射构造，符号
	// shim 见 src/DogFood.hx 等）
	override private function init():Void {
		var _loc5_:Sprite = null;
		var _loc6_:TextField = null;
		var _locm_:Dynamic = null;
		removeAllButton();
		addButton("购买狗粮", "ButtonOrange", 65, 25, this.addFood);
		// PORT-NOTE: 原版此处传 `super.close`（闭包值）。Haxe 不支持 super
		// 方法取值 → this.close（lessons #21）；本类与 AddButtonWindow/
		// BaseWindow 均未覆写 close，分派目标同为 TitleWindow.close，等价
		addButton(Reflect.field(Language.L, "取消"), "ButtonBlue", 60, 25, this.close);
		var _loc1_:String = "DogFoodNull";
		// 原版 `dogHungry == 0`（Boolean 对 0：false==0 成立）≡ == false
		if (this.controller.model.dogHungry == false) {
			_loc1_ = "DogFood";
		}
		_locm_ = Utils.getMaterial(_loc1_);
		var _loc2_:Sprite = Std.isOfType(_locm_, Sprite) ? cast(_locm_, Sprite) : null;
		addChild(_loc2_);
		_loc2_.x = 30;
		_loc2_.y = 70;
		addWindowChild(_loc2_);
		var _loc3_:Class<Dynamic> = Utils.getClass("ItemBorder");
		_locm_ = Type.createInstance(_loc3_, []);
		var _loc4_:Sprite = Std.isOfType(_locm_, Sprite) ? cast(_locm_, Sprite) : null;
		_locm_ = Type.createInstance(_loc3_, []);
		_loc5_ = Std.isOfType(_locm_, Sprite) ? cast(_locm_, Sprite) : null;
		_loc4_.x = 20;
		_loc4_.y = 45;
		_loc5_.x = 20;
		_loc5_.y = 45;
		_loc4_.width = 120;
		_loc4_.height = 120;
		_loc5_.width = 120;
		_loc5_.height = 120;
		_loc2_.mask = _loc4_;
		addWindowChild(_loc4_);
		addWindowChild(_loc5_);
		_loc6_ = new TextField();
		_loc6_.height = 50;
		_loc6_.wordWrap = true;
		_loc6_.text = Reflect.field(Language.L, "剩余狗粮还可以给狗狗吃");
		_loc6_.setTextFormat(new TextFormat("Verdana", 14, 3355443, false, null, null, null, null, TextFormatAlign.LEFT));
		_loc6_.width = 200;
		_loc6_.x = 170;
		_loc6_.y = 45;
		_loc6_.selectable = false;
		addWindowChild(_loc6_);
		this.m_leftime = new TextField();
		this.m_leftime.width = 200;
		this.m_leftime.x = 170;
		this.m_leftime.y = 80;
		this.m_leftime.selectable = false;
		this.m_leftime.wordWrap = true;
		this.m_leftime.multiline = true;
		addWindowChild(this.m_leftime);
		// PORT-NOTE: 原版 super.init() 直落 AddButtonWindow.init（缓存子件
		// 上树 + 按钮排布 + toCenterPositon，不再上行）。AddButtonWindow
		// （155 loc）属 qui 窗口片、本片仍是签名 stub（addButton 返回 null、
		// init 未翻），super 落到 Container.init——基类 chrome 初始化在原版经
		// ADDED_TO_STAGE 的 BaseWindow.initalize 补跑（AddButtonWindow.init
		// 不置 _inited），这里提前到本行跑，_inited 同样只置一次；按钮排布/
		// 居中/缓存子件上树随 AddButtonWindow 整类翻译补齐（后续模块依赖）
		super.init();
	}

	// DogFoodWindow.as:120-149（setData：m_leftime 未建早退；hours 门内
	// parseInt 天数 %24 小时 + <24 文案分岔，门外 htmlText 落 ""）
	override private function setData():Void {
		var _loc3_:Int = 0;
		var _loc4_:Int = 0;
		if (this.m_leftime == null) {
			return;
		}
		this.graphics.clear();
		var _loc1_:Dynamic = super.data;
		var _loc2_:String = "";
		// `["hours"] != undefined` 完整映射（lessons #8 双判；含数字 0）
		if (Reflect.hasField(_loc1_, "hours") && Reflect.field(_loc1_, "hours") != null) {
			// AS3 parseInt 返回 Number，`_loc3_:int` 隐式截断 → Std.int
			_loc3_ = Std.int(As3.parseInt(Reflect.field(_loc1_, "hours")));
			_loc4_ = Std.int(_loc3_ / 24);
			_loc2_ = '<p align="left"><font size="11" face="Verdana" color="#FF6600"><b>' + _loc4_
				+ '</b></font> 天 <font  face="Verdana" size="11" color="#FF6600"><b>' + _loc3_ % 24
				+ '</b></font> 小时 </font><br><br>';
			if (_loc3_ < 24) {
				_loc2_ += '<font size="14" face="Verdana" color="0x333333">您的狗粮不足,赶紧购买吧!</font></p>';
			} else {
				_loc2_ += '<font size="14" face="Verdana" color="0x333333">记得及时给自己的狗买狗粮！</font></p>';
			}
		}
		this.m_leftime.htmlText = _loc2_;
	}
}

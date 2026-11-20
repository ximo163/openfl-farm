package module.mainScene.background;

import com.qzone.utils.ObjectUtil;
import common.Consts;
import common.GetCropID;
import common.Session;
import events.CommonEvent;
import openfl.events.EventDispatcher;

/**
 * module.mainScene.background.BackgroundModel —— V3b 翻译（issue #8）。
 * 装饰槽位模型（背景/房子/栅栏/狗屋/木牌五槽 + 变更事件）。BackgroundModel.as
 * 220 loc 逐句对应。PORT-NOTE(动态取键)：槽对象是 JSON 匿名结构，AS3 的
 * `decors[i]["url"]` 读写 → Reflect.setField/field；`param2.toString()` →
 * Std.string；`idTo*Url(itemId)` 的 AS3 隐式转 String → Std.string。
 * legacy/decompiled/main3_v_221/scripts/module/mainScene/background/BackgroundModel.as
 */
@:keep
class BackgroundModel extends EventDispatcher {
	// BackgroundModel.as:13-25（internal static const → public：AS3 internal 是
	// 包内可见，Haxe 无包可见性，同包 Screen/Controller 原版同样引用）
	public static final DECOR_INDEX_BG:Int = 0;
	public static final DECOR_INDEX_HOUSE:Int = 1;
	public static final DECOR_INDEX_FENCE:Int = 2;
	public static final DECOR_INDEX_DOG_HOUSE:Int = 3;
	public static final DECOR_INDEX_BOARD:Int = 4;
	public static final DECOR_INDEX_MAX:Int = 5;
	public static final EVENT_DECORS_CHANGED:String = "DecorDataChanged";

	// BackgroundModel.as:27
	private var m_decors:Array<Dynamic>;

	// BackgroundModel.as:29-33
	public function new() {
		super();
		this.m_decors = null;
	}

	// BackgroundModel.as:35-58（internal static → public，同上）
	public static function INDEX_TO_TYPE_MAP(param1:Int):Int {
		if (param1 == DECOR_INDEX_BG) {
			return Consts.DECOR_BACKGROUND;
		}
		if (param1 == DECOR_INDEX_HOUSE) {
			return Consts.DECOR_HOUSE;
		}
		if (param1 == DECOR_INDEX_FENCE) {
			return Consts.DECOR_FENCE;
		}
		if (param1 == DECOR_INDEX_DOG_HOUSE) {
			return Consts.DECOR_DOGHOUSE;
		}
		if (param1 == DECOR_INDEX_BOARD) {
			return Consts.DECOR_BILLBOARD;
		}
		return -1;
	}

	// BackgroundModel.as:60-83（没有 DECOR_DOG 分支——那是 NPC 不是装饰槽）
	public static function TYPE_TO_INDEX_MAP(param1:Int):Int {
		if (param1 == Consts.DECOR_BACKGROUND) {
			return DECOR_INDEX_BG;
		}
		if (param1 == Consts.DECOR_HOUSE) {
			return DECOR_INDEX_HOUSE;
		}
		if (param1 == Consts.DECOR_FENCE) {
			return DECOR_INDEX_FENCE;
		}
		if (param1 == Consts.DECOR_DOGHOUSE) {
			return DECOR_INDEX_DOG_HOUSE;
		}
		if (param1 == Consts.DECOR_BILLBOARD) {
			return DECOR_INDEX_BOARD;
		}
		return -1;
	}

	// BackgroundModel.as:85-108
	public function removeDecor(param1:Int, param2:Int):Void {
		var _loc3_:Int = TYPE_TO_INDEX_MAP(param2);
		if (_loc3_ == -1) {
			return;
		}
		var _loc4_:String = "";
		if (param2 == Consts.DECOR_BACKGROUND) {
			if (param1 == -1) {
				param1 = 1;
			}
			_loc4_ = GetCropID.idToDiyUrl2(Std.string(param1));
			if (_loc4_ == "") {
				return;
			}
		}
		Reflect.setField(this.m_decors[_loc3_], "url", _loc4_);
		Reflect.setField(this.m_decors[_loc3_], "id", param1);
		dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED, {"type": param2}));
	}

	// BackgroundModel.as:110-151
	public function changeDecor(param1:Int, param2:Int):Dynamic {
		var _loc6_:Dynamic;
		var _loc3_:Dynamic = null;
		var _loc4_:Int = TYPE_TO_INDEX_MAP(param2);
		if (_loc4_ == -1) {
			return _loc3_;
		}
		if (param1 == -1) {
			// 先取移除前快照再清槽（removeDecor 里 -1 → 1 的 BG 分支早退时槽不动）
			_loc3_ = ObjectUtil.clone(this.m_decors[_loc4_]);
			this.removeDecor(param1, param2);
			return _loc3_;
		}
		var _loc5_:String = "";
		if (param2 == Consts.DECOR_BILLBOARD) {
			_loc5_ = GetCropID.idToBoardUrl(Std.string(param1));
		} else {
			_loc5_ = GetCropID.idToDiyUrl2(Std.string(param1));
		}
		if (_loc5_ == "" || _loc5_ == Reflect.field(this.m_decors[_loc4_], "url")) {
			return _loc3_;
		}
		_loc3_ = ObjectUtil.clone(this.m_decors[_loc4_]);
		Reflect.setField(this.m_decors[_loc4_], "id", param1);
		Reflect.setField(this.m_decors[_loc4_], "url", _loc5_);
		if (param2 != Consts.DECOR_DOG) {
			_loc6_ = Session.getInstance().sceneDecorates;
			if (_loc6_ != null) {
				Reflect.setField(_loc6_, Std.string(param2), {"itemId": param1});
			}
		}
		dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED, {"type": param2}));
		return _loc3_;
	}

	// BackgroundModel.as:153-162
	public function setDecors(param1:Dynamic):Void {
		this.m_decors = new Array<Dynamic>();
		this.buildDecor(param1, Std.string(Consts.DECOR_BACKGROUND));
		this.buildDecor(param1, Std.string(Consts.DECOR_HOUSE));
		this.buildDecor(param1, Std.string(Consts.DECOR_FENCE));
		this.buildDecor(param1, Std.string(Consts.DECOR_DOGHOUSE));
		this.buildDecor(param1, Std.string(Consts.DECOR_BILLBOARD));
		dispatchEvent(new CommonEvent(EVENT_DECORS_CHANGED, {"type": -1}));
	}

	// BackgroundModel.as:164-172
	public var decors(get, set):Array<Dynamic>;

	private function get_decors():Array<Dynamic> {
		return this.m_decors;
	}

	private function set_decors(param1:Array<Dynamic>):Array<Dynamic> {
		this.m_decors = param1;
		return param1;
	}

	// BackgroundModel.as:174-218（param1.hasOwnProperty(键) ≡ Reflect.hasField）
	private function buildDecor(param1:Dynamic, param2:String):Void {
		var _loc3_:Dynamic;
		var _loc4_:String = null;
		var _loc5_:Dynamic;
		if (param1 == null) {
			return;
		}
		if (Reflect.hasField(param1, param2) == true) {
			_loc3_ = Reflect.field(param1, param2);
			_loc4_ = "";
			if (param2 == Std.string(Consts.DECOR_BILLBOARD)) {
				// AS3 把 itemId 隐式转 String 传参
				_loc4_ = GetCropID.idToBoardUrl(Std.string(Reflect.field(_loc3_, "itemId")));
			} else {
				_loc4_ = GetCropID.idToDiyUrl2(Std.string(Reflect.field(_loc3_, "itemId")));
			}
			_loc5_ = {
				"id": Reflect.field(_loc3_, "itemId"),
				"type": param2,
				"url": _loc4_
			};
			this.m_decors.push(_loc5_);
		} else if (param2 == Std.string(Consts.DECOR_BACKGROUND)) {
			this.m_decors.push({
				"id": -1,
				"type": param2,
				"url": GetCropID.idToDiyUrl2("1")
			});
		} else {
			this.m_decors.push({"id": -1, "type": param2, "url": ""});
		}
	}
}

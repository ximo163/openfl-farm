package module.levelup;

import com.qzone.qfa.events.CommandEvent;
import common.Session;
import common.Settings;
import common.misc.Utils;
import entities.Seed;
import events.CommonEvent;
import framework.net.CommandDefs;
import framework.net.NetHelper;
import openfl.events.EventDispatcher;
import report.EventRecorder;
import shim.As3;

/**
 * module.levelup.LevelUpModel —— LevelUpModel.as 逐句对应（issue #18 升级
 * 模块片整类翻译）。升级模块数据层：土地档位表、升级可送种子列表过滤
 * （exclude_seeds / isVIP / isMill）、加载门位、面板 URL。
 * onGetSeedsInfo :107 的 `_loc3_["isVIP"] == "1"` 是 AS3 宽松等值（配置里
 * isVIP 是数字 1），As3.eqString 复刻；hasOwnProperty/undefined →
 * Reflect.hasField（匿名配置对象语义同源）。loadSeedsInfo 的
 * NetHelper.sendRequest 在 theApp == null 时 no-op，单测进程不跑 Main。
 */
class LevelUpModel extends EventDispatcher {
	// LevelUpModel.as:17-21
	public static final NORMAL_LAND_UPDATE_INFO:Array<Dynamic> = [5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29,
		31, 33, 35, 37, 39];

	public static final RED_LAND_UPDATE_INFO:Array<Dynamic> = [28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
		41, 42, 43, 44, 45, 47, 49, 51, 53, 55, 57];

	public static final BLACK_LAND_UPDATE_INFO_NUM:Array<Dynamic> = [40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
		52, 53, 54, 55, 56, 57, 59, 61, 63, 65, 67, 69];

	// :23
	public static final EVENT_SEEDS_DATA_LOADED:String = "levelUpSeedsDataLoaded";

	// :25-29
	private var m_seeds:Array<Dynamic>;

	private var _notShowIdArr:Array<Dynamic>;

	private var _loading:Bool;

	public function new() {
		super();
	}

	// :36-38
	public function getPanelURL():String {
		return Utils.addPrefix(Settings.getInstance().getSecondUrl("levelUpUI"));
	}

	// :41-44
	public var seeds(get, never):Array<Dynamic>;

	private function get_seeds():Array<Dynamic> {
		return this.m_seeds;
	}

	// :46-48
	public function getYellowURL():String {
		return Settings.getInstance().getStringAttribute("vipSeedLink");
	}

	// :51-67
	private function isNotShow(param1:String):Bool {
		var _loc2_:String = null;
		if (this._notShowIdArr == null) {
			_loc2_ = Settings.getInstance().getStringAttribute("exclude_seeds");
			if (_loc2_ != null && _loc2_ != "") {
				this._notShowIdArr = _loc2_.split(",");
			}
		}
		if (this._notShowIdArr.indexOf(param1) != -1) {
			return true;
		}
		return false;
	}

	// :69-71
	public function getLevelUpPicURL():String {
		return Utils.addPrefix("module/ui/icons/levelUp.jpg");
	}

	// :74-82
	public function loadSeedsInfo():Void {
		if (this.m_seeds != null || this._loading) {
			return;
		}
		this._loading = true;
		NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED, null, this.onGetSeedsInfo, this.onGetSeedsInfoFail);
	}

	// :84-86
	private function onGetSeedsInfoFail(param1:CommandEvent):Void {
		EventRecorder.recordErrorEvent("160848", null, 4);
	}

	// :89-116
	private function onGetSeedsInfo(param1:CommandEvent):Void {
		var _loc3_:Dynamic = null;
		var _loc4_:Seed = null;
		this._loading = false;
		var _loc2_:Dynamic = NetHelper.getVOData(param1);
		if (_loc2_ == null) {
			return;
		}
		this.m_seeds = [];
		for (_loc4_ in (_loc2_:Array<Dynamic>)) {
			// :102（AS3 Int.toString() → Std.string，#8 BackgroundModel 同款约定）
			_loc3_ = Settings.getInstance().getCropByID(Std.string(_loc4_._id));
			if (_loc3_ != null) {
				if (!(Reflect.hasField(_loc3_, "id") && this.isNotShow(Reflect.field(_loc3_, "id")))) {
					if (!(Reflect.hasField(_loc3_, "isVIP") && As3.eqString(Reflect.field(_loc3_, "isVIP"), "1")
						|| Reflect.hasField(_loc3_, "isMill") && As3.eqString(Reflect.field(_loc3_, "isMill"), "1"))) {
						this.m_seeds.push(_loc4_);
					}
				}
			}
		}
		dispatchEvent(new CommonEvent(EVENT_SEEDS_DATA_LOADED, null));
		EventRecorder.recordSueecssEvent("160848", null);
	}

	// :118-120
	public function isYellow():Bool {
		return Session.getInstance().isMeVIP;
	}
}

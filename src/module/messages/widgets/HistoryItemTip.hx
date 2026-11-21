package module.messages.widgets;

import common.Consts;
import common.Language;
import common.misc.Utils;
import common.view.tip.Tip;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import shim.As3;

/**
 * module.messages.widgets.HistoryItemTip —— HistoryItemTip.as 逐句对应
 * （issue #19，替换 #7 的闭包 stub）。成果/成鱼瓦片悬停提示：TipBg 素材 +
 * 作物名 + 「累计收获/累计偷窃（摘取）」两行数字；harvestNumber 缺位走
 * 成鱼 hn/sn 文案。mX/mY 覆写把鼠标坐标换算成提示坐标。
 */
@:keep
class HistoryItemTip extends Tip {
	// HistoryItemTip.as:13
	private var _tipBg:Sprite;

	// HistoryItemTip.as:15
	private var _text1:TextField;

	// HistoryItemTip.as:17
	private var _text2:TextField;

	// HistoryItemTip.as:19
	private var _cName:TextField;

	// HistoryItemTip.as:21
	private var _label2:TextField;

	public function new() {
		var _loc1_:TextField = null;
		super();
		_tipName = Consts.TIP_NAME_PROFILE_HISTORY;
		// `Utils.getMaterial("TipBg") as Sprite`
		var _bgMat:Dynamic = Utils.getMaterial("TipBg");
		this._tipBg = Std.isOfType(_bgMat, Sprite) ? cast(_bgMat, Sprite) : null;
		this._tipBg.width = 140;
		this._tipBg.height = 70;
		this._tipBg.x = -20;
		this._tipBg.y = 15;
		addChild(this._tipBg);
		this._cName = new TextField();
		this._cName.x = -5;
		this._cName.y = 20;
		this._cName.width = 90;
		this._cName.height = 22;
		this._cName.defaultTextFormat = new TextFormat("Verdana", 14, 3355443, true);
		this._cName.text = "";
		addChild(this._cName);
		_loc1_ = new TextField();
		_loc1_.autoSize = TextFieldAutoSize.LEFT;
		_loc1_.x = -10;
		_loc1_.y = 45;
		_loc1_.height = 22;
		_loc1_.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		_loc1_.text = Reflect.field(Language.L, "累计收获:");
		addChild(_loc1_);
		var _loc2_:TextField = new TextField();
		_loc2_.autoSize = TextFieldAutoSize.LEFT;
		_loc2_.x = -10;
		_loc2_.y = 60;
		_loc2_.width = 90;
		_loc2_.height = 22;
		_loc2_.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		_loc2_.text = Reflect.field(Language.L, "累计偷窃:");
		addChild(_loc2_);
		this._label2 = _loc2_;
		this._text1 = new TextField();
		this._text1.x = _loc1_.x + _loc1_.width + 3;
		this._text1.y = 45;
		this._text1.width = 90;
		this._text1.height = 22;
		this._text1.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this._text1.text = "111";
		addChild(this._text1);
		this._text2 = new TextField();
		this._text2.x = _loc2_.x + _loc2_.width + 3;
		this._text2.y = 60;
		this._text2.width = 90;
		this._text2.height = 22;
		this._text2.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this._text2.text = "111";
		addChild(this._text2);
	}

	// HistoryItemTip.as:92-112
	override private function set_data(param1:Dynamic):Dynamic {
		super.data = param1;
		if (param1 == null) {
			// 原版置 "" 后按字符串下标取（各字段 undefined）；Haxe
			// Reflect.field 对串与缺键同落 null（eval 实测），同走兜底分支
			param1 = "";
		}
		this._cName.text = Reflect.field(param1, "cName");
		// `param1["harvestNumber"] != undefined`：键缺位或值 null 都算无
		if (As3.hasProp(param1, "harvestNumber") && Reflect.field(param1, "harvestNumber") != null) {
			this._text1.text = Reflect.field(param1, "harvestNumber");
			this._text2.text = Reflect.field(param1, "scroungeNumber");
			this._label2.text = Reflect.field(Language.L, "累计偷窃:");
		} else {
			this._text1.text = Reflect.field(param1, "hn");
			this._text2.text = Reflect.field(param1, "sn");
			this._label2.text = "累计摘取:";
		}
		return param1;
	}

	// HistoryItemTip.as:114-118
	override private function set_mX(param1:Float):Float {
		super.mX = param1;
		x = param1 - 5;
		return param1;
	}

	// HistoryItemTip.as:120-124
	override private function set_mY(param1:Float):Float {
		super.mY = param1;
		y = param1 + 15;
		return param1;
	}
}

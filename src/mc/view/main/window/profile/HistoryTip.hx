package mc.view.main.window.profile;

import common.MaterialLib;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import mc.view.main.tip.Tip;
import shim.As3;

/**
 * mc.view.main.window.profile.HistoryTip —— HistoryTip.as 逐句对应
 * （issue #19）。成果格悬浮提示：品名 + 饲养收获/其他收获（便便特判）。
 * 原文件
 * legacy/decompiled/Master2_v_142/scripts/mc/view/main/window/profile/HistoryTip.as。
 */
@:keep
class HistoryTip extends Tip {
	private var tipBg:Sprite;

	private var text1:TextField;

	private var text2:TextField;

	private var cName:TextField;

	private var label1:TextField = new TextField();

	private var label2:TextField = new TextField();

	public function new() {
		super();
		this.tipBg = cast MaterialLib.getInstance().getMaterial("TipBg");
		this.tipBg.width = 140;
		this.tipBg.height = 70;
		this.tipBg.x = -20;
		this.tipBg.y = 15;
		addChild(this.tipBg);
		this.cName = new TextField();
		this.cName.x = -5;
		this.cName.y = 20;
		this.cName.width = 120;
		this.cName.height = 22;
		this.cName.defaultTextFormat = new TextFormat("Verdana", 14, 3355443, true);
		this.cName.text = "";
		addChild(this.cName);
		this.label1.autoSize = TextFieldAutoSize.LEFT;
		this.label1.x = -10;
		this.label1.y = 45;
		this.label1.height = 22;
		this.label1.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this.label1.text = "饲养收获:";
		addChild(this.label1);
		this.label2.autoSize = TextFieldAutoSize.LEFT;
		this.label2.x = -10;
		this.label2.y = 60;
		this.label2.width = 90;
		this.label2.height = 22;
		this.label2.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this.label2.text = "其他收获:";
		addChild(this.label2);
		this.text1 = new TextField();
		this.text1.x = this.label1.x + this.label1.width + 3;
		this.text1.y = 45;
		this.text1.width = 90;
		this.text1.height = 22;
		this.text1.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this.text1.text = "111";
		addChild(this.text1);
		this.text2 = new TextField();
		this.text2.x = this.label2.x + this.label2.width + 3;
		this.text2.y = 60;
		this.text2.width = 90;
		this.text2.height = 22;
		this.text2.defaultTextFormat = new TextFormat("Verdana", 12, 3355443);
		this.text2.text = "111";
		addChild(this.text2);
	}

	// HistoryTip.as:75-95（param1==null 时改投 ""：AS3 的 `""["cName"]` 得
	// undefined、TextField 印 "undefined"——stringField 复刻该强制，不抛）
	override public function set_data(param1:Dynamic):Dynamic {
		if (param1 == null) {
			param1 = "";
		}
		this.cName.text = As3.stringField(param1, "cName");
		this.text1.text = As3.stringField(param1, "harvest");
		this.text2.text = As3.stringField(param1, "scrounge");
		if (As3.floatOf(Reflect.field(param1, "cId")) == 1506) {
			this.label1.text = "便便数量:";
			this.label2.text = "";
			this.text2.text = "";
		} else {
			this.label1.text = "饲养收获:";
			this.label2.text = "其他收获:";
		}
		return param1;
	}

	// HistoryTip.as:97-101
	override public function set_mX(param1:Float):Float {
		super.set_mX(param1);
		x = param1 - 5;
		return param1;
	}

	// HistoryTip.as:103-107
	override public function set_mY(param1:Float):Float {
		super.set_mY(param1);
		y = param1 + 15;
		return param1;
	}
}

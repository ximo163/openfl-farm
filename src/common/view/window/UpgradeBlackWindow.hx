package common.view.window;

import com.qzone.utils.AlignUtil;
import common.Language;
import common.misc.QzoneJSAPI;
import common.misc.Utils;
import interfaces.IMsgCenter;
import openfl.display.DisplayObject;
import openfl.display.MovieClip;
import openfl.events.MouseEvent;
import shim.As3;

/**
 * common.view.window.UpgradeBlackWindow —— UpgradeBlackWindow.as 逐句对应
 * （issue #41 替换 #7 的闭包 stub）。黑土地升级分享窗：farmui2 的
 * BlackUpgradeShare 整幅素材做窗体，share/cancel 两个时间轴按钮分别走
 * onShare（拼 cgi_qzshare_onekey 分享参数开 Qzone 分享窗）与关窗。
 *
 * 时间轴具名子件（btnShare/btnCancel/tfNum/tfPlace）按三选一规则走
 * As3.childOf 取出再 cast 真类型（MovieClip 子件是 Dynamic，裸字段写
 * 在 cpp 上会 Invalid field）。
 */
@:keep
class UpgradeBlackWindow extends BaseWindow {
	// UpgradeBlackWindow.as:14
	private var _shareContent:MovieClip;

	// UpgradeBlackWindow.as:16-38
	public function new(param1:IMsgCenter) {
		super(param1);
		autoLayout = true;
		windowName = "BlackUpgradeShare";
		title = "";
		mode = true;
		this._shareContent = Std.isOfType(Utils.getMaterial("BlackUpgradeShare"),
			MovieClip) ? cast(Utils.getMaterial("BlackUpgradeShare"), MovieClip) : null;
		this._shareContent.gotoAndStop(1);
		width = this._shareContent.width + marginL + marginR - 12;
		height = this._shareContent.height + marginT + marginB - 140;
		this._shareContent.x = marginL - 2;
		this._shareContent.y = marginT + 7;
		addChild(this._shareContent);
		if (As3.childOf(this._shareContent, "btnShare") != null) {
			cast(As3.childOf(this._shareContent, "btnShare"), DisplayObject).addEventListener(MouseEvent.CLICK,
				this.onShare, false, 0, true);
		}
		if (As3.childOf(this._shareContent, "btnCancel") != null) {
			// PORT-NOTE: 原文 `super.onClose` 取基类方法引用——Haxe 不能对
			// super 方法取闭包。本类未覆写 onClose（BaseWindow/TitleWindow
			// 链上无中间覆写），this.onClose 与 super.onClose 同一方法
			cast(As3.childOf(this._shareContent, "btnCancel"), DisplayObject).addEventListener(MouseEvent.CLICK,
				this.onClose, false, 0, true);
		}
	}

	// UpgradeBlackWindow.as:40-66。`encodeURIComponent` ≡ StringTools.urlEncode
	// （FarmLandsView 先例）；`"" + _loc2_` 的 int→字符串照 AS3 显式 Std.string
	private function onShare(param1:MouseEvent):Void {
		var _loc2_:Int = 21 + As3.intOf(Reflect.field(this.data, "place"));
		var _loc3_:Dynamic = {
			"place": Reflect.field(this.data, "place") + 1,
			"rank": Reflect.field(this.data, "rank"),
			"stat": _loc2_
		};
		var _loc4_:String = "";
		if (Reflect.field(this.data, "place") == 0) {
			_loc4_ = Language.replaceText("BlackUpShare1", _loc3_);
		} else {
			_loc4_ = Language.replaceText("BlackUpShare2", _loc3_);
		}
		var _loc5_:String = "mod=cgi_qzshare_onekey";
		_loc5_ = _loc5_ + ("url=" + StringTools.urlEncode(Std.string(_loc2_)));
		_loc5_ = _loc5_ + ("&desc=" + StringTools.urlEncode(""));
		_loc5_ = _loc5_ + ("&summary=" + StringTools.urlEncode(_loc4_));
		_loc5_ = _loc5_ + ("&title=" + StringTools.urlEncode("点击进农场>>升级黑土地"));
		_loc5_ = _loc5_ + ("&site=" + StringTools.urlEncode("QQ农场升级黑土地"));
		_loc5_ = _loc5_ + ("&pics=" + StringTools.urlEncode("module/ui/icons/blackland.jpg"));
		QzoneJSAPI.openWindow(_loc5_);
		super.close();
	}

	// UpgradeBlackWindow.as:68-86。String.slice → substring（下标恒非负，语义同）
	private function formatNumber(param1:UInt):String {
		if (param1 == 0) {
			return "";
		}
		var _loc2_:String = Std.string(param1);
		var _loc3_:UInt = _loc2_.length;
		if (_loc3_ > 8) {
			_loc2_ = _loc2_.substring(0, _loc3_ - 8) + "," + _loc2_.substring(_loc3_ - 8, _loc3_);
		}
		if (_loc3_ > 4) {
			_loc3_ = _loc2_.length;
			_loc2_ = _loc2_.substring(0, _loc3_ - 4) + "," + _loc2_.substring(_loc3_ - 4, _loc3_);
		}
		return _loc2_;
	}

	// UpgradeBlackWindow.as:88-92
	override private function setSize():Void {
		super.setSize();
		panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
	}

	// UpgradeBlackWindow.as:94-117。`_shareContent["tfX"].text = int` 的
	// AS3 隐式 int→String 在 Haxe 显式 Std.string
	override private function setData():Void {
		this.graphics.clear();
		super.setData();
		if (this._shareContent != null) {
			if (Reflect.field(this.data, "place") == 0) {
				this._shareContent.gotoAndStop(1);
			} else {
				this._shareContent.gotoAndStop(2);
			}
			if (As3.childOf(this._shareContent, "tfNum") != null) {
				cast(As3.childOf(this._shareContent, "tfNum"),
					openfl.text.TextField).text = this.formatNumber(Reflect.field(this.data, "rank"));
			}
			if (As3.childOf(this._shareContent, "tfPlace") != null) {
				cast(As3.childOf(this._shareContent, "tfPlace"),
					openfl.text.TextField).text = Std.string(Reflect.field(this.data, "place") + 1);
			}
		}
	}
}

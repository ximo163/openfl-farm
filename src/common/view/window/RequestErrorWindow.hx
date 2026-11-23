package common.view.window;

import com.qzone.qui.controls.Button;
import com.qzone.qui.core.Align;
import com.qzone.utils.AlignUtil;
import common.CommonData;
import common.Consts;
import common.Settings;
import common.misc.Utils;
import framework.net.core.RequestChecker;
import interfaces.IMsgCenter;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import report.EventRecorder;

/**
 * common.view.window.RequestErrorWindow —— RequestErrorWindow.as 逐句对应
 * （issue #41 替换 #7 的闭包 stub）。限流/封禁错误窗：errorUrl 按 url 关键词
 * （harvest/scrounge/planting/scarify/cgi_farm_index）+ RequestChecker 记录
 * 拼五路文案，首见（showed=false）配 RequestError_2 的位图素材（类名恒
 * "RequestErrorBG"），复见落 defaultError 的 TipIcon 兜底。
 */
@:keep
class RequestErrorWindow extends BaseWindow {
	// RequestErrorWindow.as:25
	private var m_info:String;

	// RequestErrorWindow.as:27
	private var m_okButton:Button;

	// RequestErrorWindow.as:29
	private var m_img:Bitmap;

	// RequestErrorWindow.as:31
	private var m_lbInfo:TextField;

	// RequestErrorWindow.as:33
	private var m_imgName:String;

	// RequestErrorWindow.as:35-46
	public function new(param1:IMsgCenter = null) {
		super(param1);
		width = 390;
		height = 310;
		windowName = Consts.WINDOW_NAME_REQUEST_ERROR;
		this.m_info = "";
		this.m_img = null;
		this.m_imgName = "";
		this.m_lbInfo = null;
		this.m_okButton = null;
	}

	// RequestErrorWindow.as:48-69。`new _loc1_(270,125) as BitmapData` →
	// Type.createInstance + isOfType 检查（RequestErrorBG/ZZ/HP/FZ 都是
	// 270x125 DefineBitsJPEG 位图类，见 assets 清单）
	private function onImageLoaded():Void {
		var _loc1_:Class<Dynamic> = Utils.getClass(this.m_imgName);
		if (_loc1_ == null) {
			return;
		}
		if (this.m_img != null && this.m_img.parent != null) {
			removeChild(this.m_img);
		}
		var _loc2_:DisplayObject = getChildByName("__error__");
		if (_loc2_ != null) {
			removeChild(_loc2_);
		}
		var _loc3_:Dynamic = Type.createInstance(_loc1_, [270, 125]);
		this.m_img = new Bitmap(Std.isOfType(_loc3_, BitmapData) ? cast(_loc3_, BitmapData) : null);
		this.m_img.x = AlignUtil.middle(width, this.m_img.width);
		this.m_img.y = 100;
		addChild(this.m_img);
		EventRecorder.recordErrorEvent(EventRecorder.HF_SNOW, 0, EventRecorder.SUEECSS, "BlizzardError");
	}

	// RequestErrorWindow.as:71-74
	private function onOK(param1:MouseEvent):Void {
		super.close();
	}

	// RequestErrorWindow.as:76-100
	private function defaultError(param1:String = "ErrorIcon"):Void {
		title = "提示";
		if (titleAlign == Align.CENTER) {
			panelTitle.x = AlignUtil.middle(_width, panelTitle.width);
		} else {
			panelTitle.x = 4;
		}
		if (this.m_img != null && this.m_img.parent != null) {
			removeChild(this.m_img);
		}
		var _loc2_:Sprite = Std.isOfType(Utils.getMaterial(param1), Sprite) ? cast(Utils.getMaterial(param1),
			Sprite) : null;
		_loc2_.x = (width - _loc2_.width) / 2;
		_loc2_.y = 50;
		_loc2_.name = "__error__";
		addChild(_loc2_);
		this.m_lbInfo.y = 150;
		height = 250;
		this.m_okButton.x = width / 2 - this.m_okButton.width / 2;
		this.m_okButton.y = height - 45;
	}

	// RequestErrorWindow.as:102-135
	override private function init():Void {
		var _loc1_:TextFormat = null;
		if (this.m_lbInfo == null) {
			this.m_lbInfo = new TextField();
			this.m_lbInfo.selectable = false;
			this.m_lbInfo.autoSize = TextFieldAutoSize.LEFT;
			this.m_lbInfo.multiline = true;
			this.m_lbInfo.x = 20;
			this.m_lbInfo.y = 45;
			addChild(this.m_lbInfo);
			_loc1_ = new TextFormat("Verdana", 14, 6710886);
			_loc1_.leading = 6;
			this.m_lbInfo.defaultTextFormat = _loc1_;
		}
		if (this.m_info != "") {
			this.m_lbInfo.htmlText = this.m_info;
			this.m_lbInfo.x = AlignUtil.middle(width, this.m_lbInfo.width);
		}
		if (this.m_okButton == null) {
			this.m_okButton = new Button();
			this.m_okButton.defaultSkin = Utils.getClass("ButtonOrange");
			this.m_okButton.width = 65;
			this.m_okButton.height = 25;
			this.m_okButton.addEventListener(MouseEvent.CLICK, this.onOK);
			this.m_okButton.text = "确定";
			this.m_okButton.x = width / 2 - this.m_okButton.width / 2;
			this.m_okButton.y = height - 45;
			addChild(this.m_okButton);
		}
	}

	// RequestErrorWindow.as:137-236（AS3 setter 无返回值，Haxe 属性 setter
	// 返回入参）。五路文案里的 `\'` 是 AS3 单引号串内的转义，落值为单引号
	private function set_errorUrl(param1:String):String {
		var _loc2_:Dynamic = null;
		var _loc3_:String = null;
		if (param1 == null || param1.length == 0) {
			return param1;
		}
		this.m_imgName = "";
		if (RequestChecker.checkRequest(param1) == false) {
			_loc2_ = RequestChecker.getInofByUrl(param1);
			if (_loc2_ != null) {
				title = "温馨提示";
				if (param1.indexOf("harvest") != -1) {
					if (Reflect.field(_loc2_, "showed") == false) {
						this.m_info = "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color='#ff9900'>"
							+ Reflect.field(_loc2_, "limitMinute") + "</font>分钟后才会返回，暂时无法收获果实。";
						this.m_imgName = "RequestErrorBG";
					} else {
						this.m_info = "您还不可以进行收获操作，可以等一会儿再试。";
						this.defaultError("TipIcon");
					}
				} else if (param1.indexOf("scrounge") != -1) {
					if (Reflect.field(_loc2_, "showed") == false) {
						this.m_info = "抱歉，您的准摘证已过期。村委会需要花<font color='#ff9900'>"
							+ Reflect.field(_loc2_, "limitMinute") + "分钟为您重<br/>新办理，办理完毕之前您没有权限摘取好友的果实。";
						this.m_imgName = "RequestErrorZZ";
					} else {
						this.m_info = "您还不可以进行摘取操作，可以等一会儿再试。";
						this.defaultError("TipIcon");
					}
				} else if (param1.indexOf("planting") != -1) {
					if (Reflect.field(_loc2_, "showed") == false) {
						this.m_info = "好友家临时举办了一场隆重的宴会，您受邀前往参<br/>加，<font color='#ff9900'>"
							+ Reflect.field(_loc2_, "limitMinute") + "</font>分钟后才会返回，暂时无法耕种田地。";
						this.m_imgName = "RequestErrorBG";
					} else {
						this.m_info = " 您还不可以进行种植操作，可以等一会儿再试。";
						this.defaultError("TipIcon");
					}
				} else if (param1.indexOf("scarify") != -1) {
					if (Reflect.field(_loc2_, "showed") == false) {
						this.m_info = "和平天使降临，农场一片祥和宁静。大使感召您花<font color='#ff9900'>"
							+ Reflect.field(_loc2_, "limitMinute") + "分<br/>钟和她一起祈祷世界和平，此期间需要您停止翻地。";
						this.m_imgName = "RequestErrorHP";
					} else {
						this.m_info = "您还不可以进行翻地操作，可以等一会儿再试。";
						this.defaultError("TipIcon");
					}
				} else if (param1.indexOf("cgi_farm_index") != -1) {
					if (Reflect.field(_loc2_, "showed") == false) {
						this.m_info = "2012即将到来，黎明前的黑暗总是恐怖的，您被限制访问<br/>该好友的农场<font color='#ff9900'>"
							+ Reflect.field(_loc2_, "limitMinute") + "</font>分钟。诺亚方舟即将建成，等待希望的出现吧！";
						this.m_imgName = "RequestErrorFZ";
					} else {
						this.m_info = "您还不可以访问该好友，可以等一会儿再试。";
						this.defaultError("TipIcon");
					}
				} else {
					this.m_info = "请求失败，请稍后再试。";
					width = 320;
					this.defaultError();
				}
				if (this.m_imgName != "") {
					// :225 素材类名恒为 "RequestErrorBG"（与 m_imgName 的
					// BG/ZZ/HP/FZ 无关——原版如此，加载靠 RequestError_2 库
					// 里四个同名导出位图类各自 resolve）
					_loc3_ = "RequestErrorBG";
					param1 = Settings.getInstance().getSecondUrl(_loc3_);
					CommonData.rslManager.requestClass(_loc3_, this.onImageLoaded, param1);
				}
				Reflect.setField(_loc2_, "showed", true);
				return param1;
			}
		}
		this.m_info = "请求失败，请稍后再试。";
		width = 320;
		this.defaultError();
		return param1;
	}

	public var errorUrl(never, set):String;

	// RequestErrorWindow.as:238-247。`super.data["url"] as String`：经
	// 基类 getter 取 _data，as String → isOfType 检查
	override private function setData():Void {
		var _loc1_:Dynamic = super.data;
		this.graphics.clear();
		this.errorUrl = Std.isOfType(Reflect.field(_loc1_, "url"), String) ? cast(Reflect.field(_loc1_, "url"),
			String) : null;
		if (this.m_info != "") {
			this.m_lbInfo.htmlText = this.m_info;
			this.m_lbInfo.x = AlignUtil.middle(width, this.m_lbInfo.width);
		}
	}
}

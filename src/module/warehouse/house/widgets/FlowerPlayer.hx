package module.warehouse.house.widgets;

import com.greensock.TweenLite;
import com.qzone.qui.controls.Button;
import common.misc.Utils;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import shim.As3;

/**
 * module.warehouse.house.widgets.FlowerPlayer —— FlowerPlayer.as 逐句对应
 * （issue #36 功能 swf 翻译：仓库）。花束全屏预览播放器：半透明黑幕铺满
 * 舞台，Loader 拉 flowerPath/<fId>.swf 居中播放，2 秒后（或点关闭钮）
 * TweenLite 淡出移除。全静态。
 *
 * PORT-NOTE: Loader.load(URLRequest) 远程花束 swf 保持原调用形态（CLAUDE.md：
 * → Assets 的映射只落在 mcloader 加载器类；HarvestAnimationCustom 先例）；
 * 两个匿名闭包经 arguments.callee 自摘除 → 捕获局部 fn——COMPLETE 闭包里
 * 摘 IO_ERROR 的那行原版摘的其实是自身（callee 是 COMPLETE 闭包），照抄；
 * flash.utils.setTimeout/clearTimeout → As3.setTimeout/clearTimeout；
 * `MouseEvent.CLICK, close` 的静态函数引用 → FlowerPlayer.close。
 */
class FlowerPlayer {
	// FlowerPlayer.as:18
	private static var _root:Sprite;

	// FlowerPlayer.as:20
	private static var _closeBtn:Button;

	// FlowerPlayer.as:22
	private static var _border:Sprite;

	// FlowerPlayer.as:24
	private static var _timer:Int;

	// FlowerPlayer.as:26
	private static var _swfContainer:Sprite;

	public function new() {}

	// FlowerPlayer.as:33-46
	private static function drawBorder():Void {
		if (_root == null) {
			return;
		}
		_border = new Sprite();
		_border.graphics.clear();
		_border.graphics.lineStyle(0, 0, 0);
		_border.graphics.beginFill(0, 0.6);
		_border.graphics.drawRect(0, 0, _root.stage.stageWidth, _root.stage.stageHeight);
		_border.graphics.endFill();
		_root.addChild(_border);
	}

	// FlowerPlayer.as:48-89
	public static function play(param1:Sprite, param2:String, param3:Int):Void {
		var ld:Loader;
		var swfUrl:String;
		var root:Sprite = param1;
		var flowerPath:String = param2;
		var fId:Int = param3;
		var onComplete:Dynamic = null;
		var onIoError:Dynamic = null;
		_root = root;
		drawBorder();
		swfUrl = flowerPath + "/" + Std.string(fId) + ".swf";
		swfUrl = Utils.addPrefix(swfUrl);
		_timer = -1;
		ld = new Loader();
		onComplete = function(ev:Event):Void {
			var _loc2_:Loader = cast(cast(ev.target, openfl.display.LoaderInfo).loader, Loader);
			// 原版两行摘的都是 arguments.callee（即本闭包）：IO_ERROR 那行
			// 实际摘不掉，照抄
			_loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			_loc2_.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onComplete);
			_closeBtn = new Button();
			_closeBtn.defaultSkin = Utils.getClass("ButtonBlue");
			_closeBtn.width = 60;
			_closeBtn.height = 28;
			_closeBtn.text = "关闭";
			_closeBtn.mouseEnabled = true;
			_closeBtn.addEventListener(MouseEvent.CLICK, FlowerPlayer.close);
			_border.addChild(_closeBtn);
			_closeBtn.x = (_border.width - _closeBtn.width) / 2;
			_closeBtn.y = _border.height - 70;
			_loc2_.x = (_border.width - _loc2_.width) / 2;
			_loc2_.y = (_border.height - _loc2_.height) / 2;
			_timer = As3.setTimeout(function():Void {
				close();
			}, 2000);
		};
		onIoError = function(ev:IOErrorEvent):Void {
			// 原版两行摘的也都是 arguments.callee（即本闭包）：COMPLETE 那行
			// 实际摘不掉，照抄
			cast(ev.target, EventDispatcher).removeEventListener(Event.COMPLETE, onIoError);
			cast(ev.target, EventDispatcher).removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
			close();
		};
		ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		ld.load(new URLRequest(swfUrl));
		_border.addChild(ld);
	}

	// FlowerPlayer.as:91-112
	private static function close(param1:Dynamic = null):Void {
		var e:Dynamic = param1;
		if (_border != null) {
			if (_timer != -1) {
				As3.clearTimeout(_timer);
			}
			TweenLite.to(_border, 0.3, {
				"alpha": 0,
				"onComplete": function():Void {
					if (_border.parent != null) {
						_border.parent.removeChild(_border);
					}
					_border = null;
				}
			});
		}
	}
}

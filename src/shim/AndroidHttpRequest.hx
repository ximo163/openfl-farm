package shim;

import com.qzone.qfa.net.HttpRequest;

/**
 * android 的 CGI 出口改写（LocalSwfLoader 同款手法：翻译类只换构造点，调用
 * 形态不变，见 CmdHttpRequest.execute 的 PORT-NOTE(android-cgi)）。
 *
 * 原版：CmdHttpRequest 发出的 CGI URL 是相对的（FarmLite.startCGIUrl、
 * FarmLiteModel 的收获请求都拼出 "mync.php?mod=..."），Flash 播放器按 swf 所在
 * URL 解析到同站后端。html5 由 SwfUrlBase 包装 XMLHttpRequest.open 补基；
 * android 的网络栈是 lime/curl，没有可以从 Haxe 包装的原生边界——只能在 URL
 * 进网络前改写：包住同名 send()，把相对 *.php 指到 AndroidBackend 的局域网
 * 后端。其余目标（html5 等）编译掉改写分支、原样透传父类，行为不变。
 */
class AndroidHttpRequest extends HttpRequest {
	// HttpRequest.as:25-36 的构造签名照抄（调用方 CmdHttpRequest.execute
	// 显式传 url/method，默认值仅为形态一致）
	public function new(param1:String = "", param2:String = "post") {
		super(param1, param2);
	}

	// HttpRequest.as:57-81 send()：android 分支在 super 前改写 _url——父类
	// send 里 new URLRequest(this._url) 取的就是改写后的值（Haxe 的 private
	// 对子类可见）。改写只认相对 *.php，已是绝对 URL 的（后端 postUrl 下发）
	// 幂等不动
	override public function send(param1:Dynamic = null):Void {
		#if android
		this._url = AndroidBackend.rebaseFromSettings(this._url);
		#end
		super.send(param1);
	}
}

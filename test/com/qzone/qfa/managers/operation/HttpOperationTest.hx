package com.qzone.qfa.managers.operation;

import openfl.net.URLRequest;
import openfl.net.URLVariables;
import utest.Assert;

/**
 * qfa Operation/HttpOperation 状态机纯逻辑（issue #7，main3 自带变体）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/com/qzone/qfa/managers/operation/
 *   - Operation.as（_url :8、url get/set :15-27、send :20-22、close :27-29）
 *   - HttpOperation.as（GET_METHOD/POST_METHOD :17/:19、构造默认 method/format
 *     :29-36、send 的 GET 拼 URL :63-113、method get/set :117-120/:141-144）
 *
 * 不触网手段：send() 末尾的 this._urlLoader.load(...)（:114）通过替换
 * _urlLoader 为测试内 RecordingURLLoader 截获（openfl URLLoader.load 是普通
 * public 方法，可 override；load 之前 URL/数据都已拼好，截获点即观测点）。
 * URLVariables 多键的 for-in 顺序 AS3 不保证（Haxe Reflect.fields 同样不保证），
 * 多键用包含性断言、单键用精确串。
 */
@:access(com.qzone.qfa.managers.operation.HttpOperation)
class HttpOperationTest {
	public function new() {}

	// 构造器默认（:32-33）：无 options / options={} / 缺项 → method="post"、
	// format=URLLoaderDataFormat.TEXT（"text"）
	public function test_constructor_defaults_method_post_format_text() {
		var noArgs = new HttpOperation();
		Assert.equals(HttpOperation.POST_METHOD, noArgs.method);
		Assert.equals("post", noArgs.method); // :19 常量字面量
		Assert.equals("text", noArgs._format); // :33 默认 TEXT

		var emptyOptions = new HttpOperation("", {}); // Boolean({}) 真，但 method==null
		Assert.equals("post", emptyOptions.method);
		Assert.equals("text", emptyOptions._format);

		Assert.equals("", noArgs.url); // :34 url=param1，Operation._url 存原串
	}

	// :32-33：options 带全两项 → 照单全收
	public function test_constructor_honors_method_and_format_options() {
		var op = new HttpOperation("http://h/p", {method: "get", format: "variables"});
		Assert.equals("get", op.method);
		Assert.equals("variables", op._format);
		var mixed = new HttpOperation("", {format: "binary"});
		Assert.equals("post", mixed.method); // 只给 format
		Assert.equals("binary", mixed._format);
	}

	// method get/set :117-120/:141-144；Operation url :15-27 直存
	public function test_method_and_url_accessors() {
		var op = new HttpOperation();
		op.method = "put";
		Assert.equals("put", op.method);
		op.url = "http://h/x";
		Assert.equals("http://h/x", op.url);

		var base = new Operation(); // 基类同语义（Operation.as:15-27）
		base.url = "u";
		Assert.equals("u", base.url);
		base.send(); // :20-22 空实现，不抛即过
		base.close(); // :27-29
		Assert.isTrue(true);
	}

	// send GET :88-112：无 "?" 的 URL 补 "?"（:91-93），键值逐个 k=v& 追加
	//（:103-109，末尾留 &），随后 data 清空（:111）
	public function test_send_get_appends_params_to_plain_url() {
		var op = new HttpOperation("http://h/p", {method: HttpOperation.GET_METHOD});
		var rec = new RecordingURLLoader();
		op._urlLoader = rec;
		op.send({a: "1"});
		Assert.equals("http://h/p?a=1&", rec.lastRequest.url);
		Assert.equals("get", rec.lastRequest.method); // :86
		Assert.isNull(rec.lastRequest.data); // :111
	}

	// :91-101：已有 "?" 且末位不是 ?/& → 补 "&"；末位是 ? 或 & → 不再补
	public function test_send_get_separator_rules() {
		var cases:Array<{url:String, expected:String}> = [
			{url: "http://h/p?z=1", expected: "http://h/p?z=1&a=1&"}, // :97-101 补 &
			{url: "http://h/p?", expected: "http://h/p?a=1&"}, // :98 末位 ? 不补
			{url: "http://h/p?z=1&", expected: "http://h/p?z=1&a=1&"} // :98 末位 & 不补
		];
		for (c in cases) {
			var op = new HttpOperation(c.url, {method: HttpOperation.GET_METHOD});
			var rec = new RecordingURLLoader();
			op._urlLoader = rec;
			op.send({a: "1"});
			Assert.equals(c.expected, rec.lastRequest.url, 'url=${c.url}');
		}
	}

	// :103-109：for-in 多键顺序无保证 → 断言两个键都在；:105 空/''/null 键跳过
	//（空键合成值，行为出处即该行守卫）
	public function test_send_get_appends_all_keys_and_skips_empty_key() {
		var op = new HttpOperation("http://h/p", {method: HttpOperation.GET_METHOD});
		var rec = new RecordingURLLoader();
		op._urlLoader = rec;
		var params:Dynamic = {};
		Reflect.setField(params, "a", "1");
		Reflect.setField(params, "b", "2");
		Reflect.setField(params, "", "skipme"); // :105 空键守卫的观测点
		op.send(params);
		var url = rec.lastRequest.url;
		Assert.isTrue(StringTools.startsWith(url, "http://h/p?"));
		Assert.isTrue(url.indexOf("a=1&") != -1);
		Assert.isTrue(url.indexOf("b=2&") != -1);
		Assert.isFalse(url.indexOf("skipme") != -1); // :105 _loc6_ != ""
	}

	// :73-75：入参已是 URLVariables → 原样作为数据源（Protocol.encodeForHttp 的
	// 返回值就是 URLVariables，main3 实际请求都走这条）
	public function test_send_get_accepts_urlvariables_input() {
		var op = new HttpOperation("http://h/p", {method: HttpOperation.GET_METHOD});
		var rec = new RecordingURLLoader();
		op._urlLoader = rec;
		var uv = new URLVariables();
		uv["b"] = "2";
		op.send(uv);
		Assert.equals("http://h/p?b=2&", rec.lastRequest.url);
	}

	// POST（默认 method）：:79-87 对象转 URLVariables 挂在 data 上，URL 不动
	public function test_send_post_keeps_params_in_data() {
		var op = new HttpOperation("http://h/p"); // 默认 POST_METHOD
		var rec = new RecordingURLLoader();
		op._urlLoader = rec;
		op.send({a: "1"});
		Assert.equals("http://h/p", rec.lastRequest.url); // GET 分支不进
		Assert.equals("post", rec.lastRequest.method); // :86
		// :79-84 对象转成 URLVariables（openfl 侧是 Dynamic abstract，以键值观测）
		Assert.notNull(rec.lastRequest.data);
		Assert.equals("1", Reflect.field(rec.lastRequest.data, "a"));
	}
}

// 测试内替身：截获 load 的 URLRequest，不发任何真实请求
private class RecordingURLLoader extends openfl.net.URLLoader {
	public var lastRequest:URLRequest;

	public function new() {
		super();
	}

	public override function load(request:URLRequest):Void {
		lastRequest = request;
	}
}

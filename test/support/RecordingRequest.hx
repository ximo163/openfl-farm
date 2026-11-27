package support;

import com.minutes.net.HTTPRequest;

/**
 * HTTPRequest 记录型替身（issue #87 write-tests，FRequest/AppHelper 网络栈
 * 测试共用）：FRequest.request 的装饰段最后走
 * `HTTPRequest.getInstance().postRequest(url,value,cb,timeout,reload,format)`
 * （FRequest.as:149-171），真身会起 URLLoader——eval 单测不联网（CLAUDE.md
 * 测试规则）。本类覆写 postRequest/getRequest 只记入参不出网；经
 * Type.createEmptyInstance 构造（FakeStage 同款手法）跳过真身 ctor——真
 * 构造器既有单例守卫又有 `new Timer(1000).start()` 常驻定时器，替身都不
 * 需要。测试经 @:access 把 HTTPRequest.instance 置换为本类实例截获入参，
 * 结束后复位（restore）。
 */
class RecordingRequest extends HTTPRequest {
	// postRequest 截获的入参（对应 FRequest.as:149 的调用位）
	public var postedUrl:String;
	public var postedValue:Dynamic;
	public var postedCallback:Dynamic->Void;
	public var postedTimeout:UInt;
	public var postedReload:Bool;
	public var postedFormat:String;

	// 计数器用 (get,set) 属性 + Null<Int> backing 惰性归零，不用字段
	// 初始化器：本类经 Type.createEmptyInstance 构造，初始化器不执行——
	// eval 实证 `var x:Int = 0` 读出 null、x++ 掷 "Invalid operation:
	// null + 1"（implement round 1 反馈核实，读写面与字段形态完全一致：
	// rec.postCount 读、++ 自增都不变）
	public var postCount(get, set):Int;
	var postCountBacking:Null<Int> = null;

	// getRequest 截获的入参（对应 FRequest.as:78 的调用位）
	public var gettedUrl:String;
	public var gettedValue:Dynamic;
	public var getCount(get, set):Int;
	var getCountBacking:Null<Int> = null;

	function get_postCount():Int {
		if (postCountBacking == null) postCountBacking = 0;
		return postCountBacking;
	}

	function set_postCount(v:Int):Int {
		postCountBacking = v;
		return v;
	}

	function get_getCount():Int {
		if (getCountBacking == null) getCountBacking = 0;
		return getCountBacking;
	}

	function set_getCount(v:Int):Int {
		getCountBacking = v;
		return v;
	}

	public function new() {
		super();
	}

	public override function postRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:UInt = 60000, param5:Bool = false,
			param6:String = "text"):Void {
		this.postedUrl = param1;
		this.postedValue = param2;
		this.postedCallback = param3;
		this.postedTimeout = param4;
		this.postedReload = param5;
		this.postedFormat = param6;
		this.postCount++;
	}

	public override function getRequest(param1:String, param2:Dynamic, param3:Dynamic->Void, param4:UInt = 60000, param5:Bool = false,
			param6:String = "text"):Void {
		this.gettedUrl = param1;
		this.gettedValue = param2;
		this.getCount++;
	}
}

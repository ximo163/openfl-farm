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
	public var postCount:Int = 0;

	// getRequest 截获的入参（对应 FRequest.as:78 的调用位）
	public var gettedUrl:String;
	public var gettedValue:Dynamic;
	public var getCount:Int = 0;

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

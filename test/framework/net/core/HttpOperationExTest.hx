package framework.net.core;

import com.qzone.qfa.managers.events.RequestEvent;
import framework.net.CommandDefs;
import openfl.Lib.getTimer;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.TimerEvent;
import openfl.net.URLRequest;
import utest.Assert;

/**
 * HttpOperationEx 超时/去重状态机纯逻辑（issue #7）。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/framework/net/core/HttpOperationEx.as
 *   （m_isHandled 一次性派发门 :48-53/:121-128/:135-142/:153-160/:194-200、
 *   timerFn 超时与 reload 重试 :107-146、httpStatusHandler 状态码窗口
 *   :148-174、ioerrorHandler 错误打包 :191-204、handleError 只清不发 :57-60、
 *   reload get/set :176-179/:219-222）
 *
 * 不触网/不等待手段：
 * - timerFn 用直排 m_timerValue = getTimer()-61000 越过 :34 的 60*1000 超时窗，
 *   不真实等待（getTimer 只取单调时钟差值，断言不依赖具体钟值）；
 * - reload 重试分支的 _urlLoader.load(_urlReq)（:115）用测试内 RecordingURLLoader
 *   截获；
 * - 构造器会 start 共享静态 _timer（:40-42，repeatCount=0），eval 上不停掉会让
 *   解释器不退出 → teardown 统一 stop。
 */
@:access(framework.net.core.HttpOperationEx, com.qzone.qfa.managers.operation.HttpOperation)
class HttpOperationExTest {
	public function new() {}

	// :40-42 _timer.start() 后若无人调 clearAll，进程退出前必须停表
	public function teardown() {
		if (HttpOperationEx._timer != null) {
			HttpOperationEx._timer.stop();
		}
	}

	// :36 m_reload 构造默认 false；:219-222 setter 直存
	public function test_reload_flag_defaults_false_and_is_settable() {
		var op = new HttpOperationEx();
		Assert.isFalse(op.reload);
		op.reload = true;
		Assert.isTrue(op.reload);
	}

	// handleComplete :45-55：COMPLETE 只在 m_isHandled==false 时派发一次
	// RequestEvent.RESULT（载荷是 currentTarget.data），随后 clearAll；
	// 第二次 COMPLETE 不再派发
	public function test_handleComplete_dispatches_result_once() {
		var op = new HttpOperationEx();
		var carrier = new openfl.net.URLLoader();
		carrier.data = "payload";
		carrier.addEventListener(Event.COMPLETE, op.handleComplete); // 直排私有处理器
		var results:Array<RequestEvent> = [];
		op.addEventListener(RequestEvent.RESULT, function(e) results.push(cast(e, RequestEvent)));

		carrier.dispatchEvent(new Event(Event.COMPLETE));
		carrier.dispatchEvent(new Event(Event.COMPLETE));
		Assert.equals(1, results.length); // :48 只放行一次
		Assert.equals("payload", results[0].data); // :50-51
		Assert.isTrue(op.m_isHandled); // :52
	}

	// handleError 覆写 :57-60：只 clearAll，不派生基类的 ERR_SECURITY/ERR_IO FAULT
	public function test_handleError_is_silent_cleanup() {
		var op = new HttpOperationEx();
		var faults:Array<RequestEvent> = [];
		op.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));
		op.handleError(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		op.handleError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
		Assert.equals(0, faults.length); // 与 HttpOperation.as:38-48 基类行为相反
	}

	// ioerrorHandler :191-204：打包 {errorType: HTTP_ERR_IOERROR(-100),
	// errorContent: text} 派发 FAULT，一次；已 handled 再来不派发
	public function test_ioerrorHandler_packages_fault_once() {
		var op = new HttpOperationEx();
		var faults:Array<RequestEvent> = [];
		op.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));

		op.ioerrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "boom"));
		Assert.equals(1, faults.length);
		Assert.equals(CommandDefs.HTTP_ERR_IOERROR, Reflect.field(faults[0].data, "errorType")); // :197
		Assert.equals("boom", Reflect.field(faults[0].data, "errorContent")); // :198
		Assert.isTrue(op.m_isHandled); // :199

		op.ioerrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "second"));
		Assert.equals(1, faults.length); // :194 已 handled → 不派发，仍 clearAll
	}

	// httpStatusHandler :148-174：status ∈ (400,510] 才派发
	// {errorType: HTTP_ERR_HTTPSTATUS(-101), errorContent: status}；
	// 400/511/200 边界不派发
	public function test_httpStatusHandler_window_400_exclusive_510_inclusive() {
		for (status in [400, 511, 200, 304]) {
			var quiet = new HttpOperationEx();
			var faults:Array<RequestEvent> = [];
			quiet.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));
			quiet.httpStatusHandler(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, status));
			Assert.equals(0, faults.length, 'status=$status'); // :151 条件不成立
		}
		for (status in [401, 510]) {
			var op = new HttpOperationEx();
			var faults:Array<RequestEvent> = [];
			op.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));
			op.httpStatusHandler(new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, status));
			Assert.equals(1, faults.length, 'status=$status');
			Assert.equals(CommandDefs.HTTP_ERR_HTTPSTATUS, Reflect.field(faults[0].data, "errorType")); // :156
			Assert.equals(status, Reflect.field(faults[0].data, "errorContent")); // :157
			Assert.isTrue(op.m_isHandled); // :159
		}
	}

	// timerFn 非 reload 分支 :133-145：越过 60s 超时窗 → FAULT
	// {errorType: HTTP_ERR_TIMEOUT(-102), content: ""}（注意键是 content 不是
	// errorContent，:137-138 逐字）；m_isHandled 置位后同窗不再派发
	public function test_timerFn_timeout_faults_with_timeout_error() {
		var op = new HttpOperationEx(); // m_reload 默认 false → :133 分支
		var faults:Array<RequestEvent> = [];
		op.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));

		op.m_timerValue = getTimer() - 61000; // 直排越过 :34 的 60*1000
		op.timerFn(new TimerEvent(TimerEvent.TIMER));
		Assert.equals(1, faults.length);
		Assert.equals(CommandDefs.HTTP_ERR_TIMEOUT, Reflect.field(faults[0].data, "errorType")); // :138
		Assert.equals("", Reflect.field(faults[0].data, "content")); // :139
		Assert.isTrue(op.m_isHandled);

		op.m_timerValue = getTimer() - 61000;
		op.timerFn(new TimerEvent(TimerEvent.TIMER)); // :135 已 handled → 只清理
		Assert.equals(1, faults.length);
	}

	// timerFn reload 分支 :111-131：第一次超时 → 重发一次原请求（num 0→1，
	// 刷新计时）；第二次仍超时 → 超时 FAULT。重发请求用替身截获，不触网
	public function test_timerFn_reload_retries_once_then_times_out() {
		var op = new HttpOperationEx();
		op.reload = true;
		var rec = new RecordingURLLoader();
		op._urlLoader = rec;
		var req = new URLRequest("http://rec/once");
		op._urlReq = req;
		var faults:Array<RequestEvent> = [];
		op.addEventListener(RequestEvent.FAULT, function(e) faults.push(cast(e, RequestEvent)));

		op.m_timerValue = getTimer() - 61000;
		op.m_requestNum = 0;
		op.timerFn(new TimerEvent(TimerEvent.TIMER));
		Assert.equals(req, rec.lastRequest); // :115 重发同一 URLRequest
		Assert.equals(1, op.m_requestNum); // :117
		Assert.equals(0, faults.length); // 重试不算失败

		op.m_timerValue = getTimer() - 61000; // 重试后仍超时
		op.timerFn(new TimerEvent(TimerEvent.TIMER));
		Assert.equals(1, faults.length); // :119-131 num==1 → 超时 FAULT
		Assert.equals(CommandDefs.HTTP_ERR_TIMEOUT, Reflect.field(faults[0].data, "errorType"));
	}
}

// 测试内替身：截获 reload 重试的 load 调用，不发真实请求
private class RecordingURLLoader extends openfl.net.URLLoader {
	public var lastRequest:URLRequest;

	public function new() {
		super();
	}

	public override function load(request:URLRequest):Void {
		lastRequest = request;
	}
}

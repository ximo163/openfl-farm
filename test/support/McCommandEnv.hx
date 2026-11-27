package support;

import com.minutes.net.HTTPRequest;
import common.CommonData;
import common.LocalData;
import mc.control.ViewControl;
import mc.events.WindowEvent;

/**
 * 牧场命令层测试环境（issue #88 write-tests）：mc.control 命令类的测试
 * 共用基建。命令类全部经 FRequest.postRequest(2) 发 mod、经 ViewControl
 * 派发 WindowEvent（alertWindow/开窗关窗）与裸事件（"animal_change" 等），
 * 且构造器取 MData 单例群——本类提供三件套：
 *
 * 1. `swapInRecorder()`：HTTPRequest.instance 置换为 RecordingRequest
 *    （Type.createEmptyInstance 跳过真身 ctor——FRequestTest 同款手法，
 *    见 test/mc/fBridge/FRequestTest.hx:68-76），命令发的每个请求的
 *    mod 串/参数体/回调全部落 rec.postedUrl/postedValue/postedCallback。
 *    restore() 复位。多请求时 pushed 到 posts 队列逐条断言。
 * 2. `captureViewControl()`：监听 ViewControl 全部 WindowEvent.OPEN/CLOSE
 *    与指定裸事件名，落 captured 队列；teardown 摘除。
 * 3. `resetStatics()`：命令类消费的静态位统一复位——LocalData.lastRequest
 *    四件、CommonData.serverTime 重锚定点（FRequestTest 同锚
 *    1700000000，装饰 farmTime/pastureKey 的推算基线）。
 *
 * 单例说明：FRequest/MData 群/Command 的单例态跨用例共享——命令测试
 * 不重置单例本体（ctor 单例守卫不可逆），只驱动其公开行为面；host/me/
 * currentUser/animalData 等数据面由各测试 setup 直接布置（MData 数据
 * 类的 setter 已是 #87 充真身，可写）。
 */
@:access(com.minutes.net.HTTPRequest)
class McCommandEnv {
	public var savedInstance:HTTPRequest;
	public var rec:RecordingRequest;
	public var windowEvents:Array<{kind:String, name:String, arg:Dynamic, win:Dynamic}>;
	public var plainEvents:Array<String>;
	var plainNames:Array<String>;
	var vc:ViewControl;

	public function new() {
		savedInstance = null;
		rec = null;
		windowEvents = [];
		plainEvents = [];
		plainNames = [];
		vc = null;
	}

	// HTTPRequest 截获换入/复位（FRequestTest 同款，见其类头注释）
	public function swapInRecorder():RecordingRequest {
		savedInstance = HTTPRequest.instance;
		var r:RecordingRequest = cast Type.createEmptyInstance(RecordingRequest);
		HTTPRequest.instance = r;
		rec = r;
		return r;
	}

	public function restoreRecorder():Void {
		if (savedInstance != null) {
			HTTPRequest.instance = savedInstance;
			savedInstance = null;
		}
		rec = null;
	}

	// ViewControl 事件捕获：WindowEvent.OPEN/CLOSE 记 windowName/windowArgument/
	// window 载荷，plainNames 里的裸事件名记 type。eval 的 EventDispatcher
	// 不要求监听对象唯一——多次 capture 叠加须先 release
	public function captureViewControl(plain:Array<String>):Void {
		vc = ViewControl.getInstance();
		plainNames = plain;
		vc.addEventListener(WindowEvent.OPEN, onWindowEvent);
		vc.addEventListener(WindowEvent.CLOSE, onWindowEvent);
		for (n in plain) {
			vc.addEventListener(n, onPlain);
		}
	}

	public function releaseViewControl():Void {
		if (vc == null) {
			return;
		}
		vc.removeEventListener(WindowEvent.OPEN, onWindowEvent);
		vc.removeEventListener(WindowEvent.CLOSE, onWindowEvent);
		for (n in plainNames) {
			vc.removeEventListener(n, onPlain);
		}
		vc = null;
		plainNames = [];
	}

	function onWindowEvent(e:WindowEvent):Void {
		// 强类型读出三件载荷：windowName/windowArgument/window 全是
		// WindowEvent 的 (get,set) 访问器——eval 的 Dynamic 反射只见物理
		// 字段，若经 Dynamic 读（如 listener 参数裸 `Dynamic` 化后取用）
		// 恒 null（lessons #8「eval/js 的 Dynamic 反射」条，probe 实证：
		// Reflect.field(captured,"window") 也是 null）。此处签名即
		// WindowEvent，属性访问编译期走 getter，落进捕获数组的是读出的
		// **值**——后续测试从数组里取 win 是 Dynamic 但对象本体是
		// ConfirmWindow 真身，再 cast 回强类型即可读窗的访问器
		windowEvents.push({kind: e.type, name: e.windowName, arg: e.windowArgument, win: e.window});
	}

	function onPlain(e:openfl.events.Event):Void {
		plainEvents.push(e.type);
	}

	// 静态位复位：serverTime 重锚 1700000000（FRequestTest 同锚——
	// farmTime=String(int(serverTime)) 断言 "1700000000" 的定点基线，
	// 见 FRequestTest 类头 serverTime 锚点漂移节）；lastRequest 四件清
	public function resetStatics():Void {
		CommonData.serverTime = 1700000000;
		LocalData.lastRequestValue = null;
		LocalData.lastRequestUrl = null;
		LocalData.lastRequestHandle = null;
		LocalData.lastRequestFn = null;
	}

	// 应答驱动：命令的回调经 rec.postedCallback 同步回放应答体——
	// eval 单测不联网，回调是否异步是 HTTPRequest 真身内部事；
	// FRequest 的应答闭包包装是同步直通（FRequest.hx request），直接调用
	// 即等价网络应答到达后的行为面
	public function respond(body:Dynamic):Void {
		if (rec != null && rec.postedCallback != null) {
			rec.postedCallback(body);
		}
	}
}

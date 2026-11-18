package module.mainScene.farmLand;

import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;

/**
 * module.mainScene.farmLand.OperationQueue —— 闭包 stub（issue #7，后续模块
 * 翻译，stub 同 module/Main 先例）。原版 293 loc > 100，issue 闭包规则走 stub：
 * FarmLandModel 只用到常量（构造器 :110-111 监听 EVENT_OPERATE_SUCCES、
 * operate_* 的 delayRequest）与定时合批网络行为，后者属 V3b/V3c 片；
 * 这里常量取值照抄，delayRequest 空实现（不发起任何网络）。
 */
class OperationQueue extends EventDispatcher {
	// OperationQueue.as:17-27（internal static const → private static final）
	static final EVENT_OPERATE_SUCCES:String = "OperateSuccess";
	static final EVENT_OPERATE_ERROR:String = "OperateError";
	static final ADD_WEED:Int = 0;
	static final CLEAR_WEED:Int = 1;
	static final ADD_BUG:Int = 2;
	static final CLEAR_BUG:Int = 3;
	static final QUEUE_LEN:Int = 4;

	public function new(param1:UInt = 1000, param2:IEventDispatcher = null) {
		super(param2);
	}

	// OperationQueue.as:246-261（stub：不入队、不定时、不发请求）
	public function delayRequest(param1:Int, param2:Dynamic):Void {}
}

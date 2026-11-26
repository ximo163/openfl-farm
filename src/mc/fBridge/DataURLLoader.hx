package mc.fBridge;

import openfl.net.URLLoader;
import openfl.net.URLRequest;

/**
 * mc.fBridge.DataURLLoader —— DataURLLoader.as 的编译 stub（成员面照原
 * 文抄全；类体太小——仅 postData 属性对——成员面即真身）。本类归「网络」
 * 后续模块（mc.FBridge 片：FRequest/RequestManager/EventRecorder 等一整
 * 族）；本 stub 仅为 com.minutes.net.HTTPRequest 的编译链而落，网络模块
 * 立项时归并复审。
 * legacy/decompiled/Master2_v_142/scripts/mc/FBridge/DataURLLoader.as。
 *
 * PORT-NOTE(命名)：原包 `mc.FBridge` 的 FBridge 段首字母大写，Haxe 包段
 * 必须小写开头，落 `fBridge`（类名不变——lessons 的 windowControl 同款
 * 先例，deviations 候选）。
 */
@:keep
class DataURLLoader extends URLLoader {
	// DataURLLoader.as:9
	private var _postData:Dynamic;

	// :11-14
	public function new(param1:URLRequest = null) {
		super(param1);
	}

	// :16-24
	public var postData(get, set):Dynamic;

	private function get_postData():Dynamic {
		return this._postData;
	}

	private function set_postData(param1:Dynamic):Dynamic {
		this._postData = param1;
		return param1;
	}
}

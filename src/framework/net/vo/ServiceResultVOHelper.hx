package framework.net.vo;

import com.qzone.qfa.events.CommandEvent;

// framework.net.vo.ServiceResultVOHelper —— ServiceResultVOHelper.as 逐句对应。
class ServiceResultVOHelper {
	public function new() {}

	// ServiceResultVOHelper.as:14-26。PORT-NOTE: AS3 `as` 失配返回 null →
	// Std.isOfType 门 + 直取（eval 上裸 cast 不做运行时检查，语义不等价）
	public static function getVOData(param1:CommandEvent):Dynamic {
		if (param1 == null || param1.result == null) {
			return null;
		}
		if (!Std.isOfType(param1.result, ServiceResultVO)) {
			return null;
		}
		var _loc2_:ServiceResultVO = param1.result;
		return _loc2_.m_extra;
	}
}

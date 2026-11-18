package framework.net.vo;

// framework.net.vo.ServiceResultVO —— ServiceResultVO.as 逐句对应。
class ServiceResultVO {
	// ServiceResultVO.as:7-11
	public var m_message:String;
	public var m_extra:Dynamic;
	public var m_result:String;

	// ServiceResultVO.as:13-20
	public function new() {
		m_result = "";
		m_message = "";
		m_extra = null;
	}

	// ServiceResultVO.as:22-25
	public function toString():String {
		return "[ServiceResultVO]result:" + m_result + ", message:" + m_message + ", extra:" + m_extra;
	}
}

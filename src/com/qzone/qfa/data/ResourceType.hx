package com.qzone.qfa.data;

// ResourceType.as 逐句对应。
class ResourceType {
	// ResourceType.as:19-25
	public static final TYPE_BITMAP:String = "tBitmap";

	// ResourceType.as:19,26-27
	public static final TYPE_TEXT:String = "tText";

	// ResourceType.as:19,28-29
	public static final TYPE_SWF:String = "tSWF";

	// ResourceType.as:19,30-31
	public static final TYPE_BINARY:String = "tBin";

	public function new() {
	}

	// ResourceType.as:35-52。FFDec 打出的正则里 `.` 未转义（任意字符），照抄
	public static function getType(param1:String):String {
		var _loc2_ = new EReg("(.*?).(jpg|jpeg|png|gif)", "i");
		var _loc3_ = new EReg("(.*?).(txt|js|xml|css)", "i");
		var _loc4_ = new EReg("(.*?).(swf)", "i");
		if (_loc2_.match(param1)) {
			return TYPE_BITMAP;
		}
		if (_loc3_.match(param1)) {
			return TYPE_TEXT;
		}
		if (_loc4_.match(param1)) {
			return TYPE_SWF;
		}
		return TYPE_BINARY;
	}
}

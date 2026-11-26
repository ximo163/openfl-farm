package cn.snowkit.utils;

// cn.snowkit.utils.ObjectCopy —— ObjectCopy.as 逐句对应（issue #86 牧场库底座，
// snowkit 片）。AMF 序列化深拷贝。
// PORT-NOTE(copy)：原版走 ByteArray.writeObject/readObject 的 AMF 往返深
// 拷贝；本仓既定等价物是 com.qzone.utils.ObjectUtil.clone（反射递归，AMF
// 退化语义见彼处注释），复用同通道（common.Utils.objectCopy、LipiUtil.clone
// 同款先例——handbook/architecture/pasture-libs.md 第三方库节）。
@:keep
class ObjectCopy {
	// ObjectCopy.as:8-11
	public function new() {}

	// ObjectCopy.as:13-19（AMF 等价物复用，见类头 PORT-NOTE）
	public static function copy(param1:Dynamic):Dynamic {
		return com.qzone.utils.ObjectUtil.clone(param1);
	}
}

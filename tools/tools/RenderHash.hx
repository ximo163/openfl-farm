package tools;

import tools.RenderTypes.ShotImage;

/**
 * T2 资产渲染对拍——图像内容哈希（issue #57；write-tests 阶段为 stub，
 * 契约由 test/tools/RenderHashTest.hx 钉死）。自回归基线「首跑截图入库、
 * 后续跑比对」的指纹：同图同哈希、一字节之差必变（基线文件里存的就是它）。
 *
 * 算法与布局钉死（// issue #57——基线兼容性要求：换算法=全量基线作废，
 * 必须能被门禁发现，故不留给实现自由选）：
 * - 规范文本 = "<width>x<height>:" + pixels 十进制逗号连接（ASCII；
 *   与 haxe.crypto.Md5 的入参域一致——该库只吃 String，二进制布局会在
 *   eval/js 目标间踩字符串编码坑，文本布局跨目标无歧义）；
 * - 哈希 = haxe.crypto.Md5.encode(规范文本)，32 位小写十六进制。
 * - width/height 参与布局：1×2 与 2×1 的同字节像素序列不撞同一条目。
 * - pixels.length != width*height*4 抛 haxe.Exception 且消息含 "长度"
 *   （坏图像不得静默混进基线）。
 */
class RenderHash {
	/** ShotImage → 32 位小写十六进制 MD5（布局见类头；跨跑/跨目标确定）。 */
	static public function imageHash(image:ShotImage):String {
		throw new haxe.Exception("not implemented");
	}
}

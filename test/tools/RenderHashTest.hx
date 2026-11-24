package tools;

import tools.RenderTypes.ShotImage;
import utest.Assert;

/**
 * T2 图像内容哈希纯逻辑：基线条目指纹（issue #57，write-tests 阶段对 stub
 * 失败）。被测 tools.RenderHash 只做纯计算，不碰显示对象/文件。stub 在
 * tools/tools/RenderHash.hx（「stub 归树」规矩，implement 原地填充）。
 *
 * 期望值出处：
 * - 哈希进基线的角色（「首跑对清单内资产逐符号截图，哈希/基线文件入库或
 *   CI cache；后续跑比对」）与确定性要求：// issue #57（自回归基线抓
 *   「没变」——同图同哈希是最低门槛）。
 * - 算法与布局（MD5 over 规范文本 "<width>x<height>:" + pixels 十进制逗号
 *   连接、宽高参与、小写十六进制）：原版没有的工具行为，// issue #57
 *   契约钉死——基线兼容性要求换算法=全量基线作废必须能被发现，不留实现
 *   自由度。文本域而非二进制域的原因见 stub 类头（haxe.crypto.Md5 只吃
 *   String）。
 * - 具体期望值：容器内 python3 hashlib.md5 对同一规范文本（ASCII 同串）
 *   独立计算，另经 haxe.crypto.Md5（--interp 容器实测）交叉一致——期望
 *   值与被测实现无共享代码。像素数据为合成小图：被测的是指纹行为，不涉
 *   及资产画面（// issue #57）。
 */
class RenderHashTest {
	public function new() {}

	// ---- 已知值：布局与算法的钉死（基线兼容性哨兵） ----

	function test_imageHash_known_values() {
		// src 里写明规范文本（期望值即 md5(该文本)，python3 独立算得）
		var rows:Array<{src:String, image:ShotImage, expected:String}> = [
			{
				src: "1×1 红：规范文本 \"1x1:255,0,0,255\"",
				image: img(1, 1, [255, 0, 0, 255]),
				expected: "d6d1fa69b3fe021726220b7ec3152816"
			},
			{
				src: "2×1 红|绿：\"2x1:255,0,0,255,0,255,0,255\"",
				image: img(2, 1, [255, 0, 0, 255, 0, 255, 0, 255]),
				expected: "dcde3284c65bd5722c2df232197d91e0"
			},
			{
				src: "1×2 与上行同字节像素：\"1x2:255,0,0,255,0,255,0,255\"",
				image: img(1, 2, [255, 0, 0, 255, 0, 255, 0, 255]),
				expected: "bd05044acfb5fb1fcb030c796df3d2f8"
			},
			{
				src: "2×2 全零：\"2x2:0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\"",
				image: img(2, 2, zeros()),
				expected: "2c3b9bbcd90c3db85d7b93f96caccb33"
			},
			{
				src: "上行首字节改 3：\"2x2:3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\"",
				image: img(2, 2, [3].concat(zeros().slice(1))),
				expected: "9d68b1cb298e209af36079fd93642584"
			}
		];
		for (r in rows) {
			Assert.equals(r.expected, RenderHash.imageHash(r.image), r.src);
			// 小写十六进制 32 位（文件里存的就是这个形态）
			var h = RenderHash.imageHash(r.image);
			Assert.equals(32, h.length, r.src);
			Assert.isTrue(~/^[0-9a-f]{32}$/.match(h), r.src);
		}
	}

	// ---- 确定性与敏感性（自回归「没变」检测的最低门槛） ----

	function test_imageHash_deterministic_and_sensitive() {
		var a = img(2, 2, base2x2());
		// 同内容两个实例（不同数组身份）：跨跑/跨目标同哈希
		Assert.equals(RenderHash.imageHash(a), RenderHash.imageHash(img(2, 2, base2x2().map(v -> v))));
		// 一字节之差必变（基线比对抓「变了」的全部依赖）
		var b = base2x2();
		b[5] += 1;
		Assert.isFalse(RenderHash.imageHash(a) == RenderHash.imageHash(img(2, 2, b)));
	}

	function test_imageHash_width_height_participate() {
		// 宽高参与布局（1×2 与 2×1 不撞同一条目）——已知值表里两行哈希
		// 不同已证，这里以独立断言钉语义
		var horizontal = img(2, 1, [255, 0, 0, 255, 0, 255, 0, 255]);
		var vertical = img(1, 2, [255, 0, 0, 255, 0, 255, 0, 255]);
		Assert.isFalse(RenderHash.imageHash(horizontal) == RenderHash.imageHash(vertical));
	}

	// ---- 长度契约：坏图像不得静默混进基线 ----

	function test_imageHash_length_throws() {
		var msg:String = null;
		try {
			RenderHash.imageHash(img(2, 2, base2x2().slice(0, 15)));
		} catch (e:haxe.Exception) {
			msg = e.message;
		}
		Assert.isTrue(msg != null && StringTools.contains(msg, "长度"), "pixels 长度 != width*height*4：须抛消息含 长度 的 haxe.Exception");
	}

	// ---- 测试自用：合成小图（指纹行为的输入，见类头） ----

	static function img(width:Int, height:Int, pixels:Array<Int>):ShotImage {
		return {width: width, height: height, pixels: pixels};
	}

	/** 2×2 四像素基准（与 PixelDiffTest 的 base2x2 同值：两测试各自独立定义，不共享）。 */
	static function base2x2():Array<Int> {
		return [10, 20, 30, 255, 40, 50, 60, 255, 70, 80, 90, 255, 100, 110, 120, 255];
	}

	static function zeros():Array<Int> {
		return [for (_ in 0...16) 0];
	}
}

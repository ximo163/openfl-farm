package common.view.window;

import com.qzone.qui.containers.Panel;
import com.qzone.qui.controls.Button;
import common.view.window.PostWindow;
import openfl.events.Event;
import openfl.text.TextField;
import utest.Assert;

/**
 * PostWindow 纯逻辑（issue #45，#31 漏翻补齐）：构造器常量与 param2/3/4
 * 落位、setData→text 路由、text/imgUrl 守卫、enableBtn 的 _btn 门、
 * confirmFn 关窗+回调、fixSize 只写。
 *
 * 出处：legacy/decompiled/main3_v_221/scripts/common/view/window/PostWindow.as
 * （ctor :38-72：_defaultSkin 初值 true :42、param4==false 的 PostWindowBG
 * 守卫 :43-55、param4==true 边距 L3/R5/T27/B5 :56-62、_width=442.1 :63/
 * _height=435.8 :64、mode=true :65、_text="" :66、_btn=null :67、
 * _btnText=param2 :68、_btnCallback=param3 :69、windowName=
 * Consts.WINDOW_NAME_SYS_POST_MSG :70、_fixSize=true :71；enableBtn :147-153
 * （_btn null 门 :149）；set text :155-166（_postText.htmlText :160）；
 * confirmFn :168-175（super.close() :170 → TitleWindow.close 派
 * Event.CLOSE、_btnCallback null 门 :171-174）；setData :192-198
 * （super.data null 门 :194、text=data["text"] :196）；get text :200-203；
 * set imgUrl 空值守卫 :205-209；set fixSize :237-240）。
 * windowName 值 "SystemPostMsgWindow" 出 Consts.as:188（WINDOW_NAME_SYS_POST_MSG，
 * 常量本体随 implement 进 Consts.hx，测试按字面钉）；param4==false 时边距
 * 保持 Panel 默认 T22/B28/L5/R5（Panel.as:54-57 ← Style.as:70/74/76）。
 *
 * eval 适配（ConfirmWindowTest 先例）：_postText/_btn 钉等价对象（TextField/
 * Button）。init() 的显示装配（_postText 建立参数 17/36/420/224、按钮 y-=100）
 * 与 imgUrl 非空路径（new Loader + load + FarmLoading :211-228、onLoaded 的
 * 定尺寸/重排 :97-123）是显示/网络面，留给 CI 画面比对。测试环境无库加载，
 * ApplicationDomain 无 "PostWindowBG" 定义（ResourceManager.getClass →
 * null，与 AddButtonWindowTest.addButton 的皮肤反射同通道），:45 守卫必走
 * 不落地分支。
 */
@:access(common.view.window.PostWindow)
@:access(com.qzone.qui.containers.Panel)
class PostWindowTest {
	public function new() {}

	// ConfirmWindowTest 先例：init() 产出的 _postText 钉等价对象
	private function buildWindow():PostWindow {
		var win = new PostWindow(null);
		win._postText = new TextField();
		return win;
	}

	// :38-72：构造器常量（默认参形态 param2 ""/param4 false）
	public function test_ctor_constants() {
		var win = new PostWindow(null);
		Assert.equals("", win.text); // :66
		Assert.equals("SystemPostMsgWindow", win.windowName); // :70（Consts.as:188）
		Assert.equals(442.1, win.width); // :63
		Assert.equals(435.8, win.height); // :64
		Assert.isTrue(win.mode); // :65
		Assert.isTrue(win._fixSize); // :71
		Assert.isTrue(win._defaultSkin); // :42；PostWindowBG 无定义 → :49 不落地
		Assert.isNull(win._btn); // :67
		Assert.isNull(win._postText); // :22 声明位，init() 才建
		Assert.isNull(win._loader); // :32 声明位，imgUrl 非空才建
	}

	// :68-69：param2/param3 落位（公告窗按钮文案与确认回调）
	public function test_ctor_stores_btn_params() {
		var fn = function() {};
		var win = new PostWindow(null, "确 定", fn);
		Assert.equals("确 定", win._btnText); // :68
		Assert.isTrue(Reflect.compareMethods(win._btnCallback, fn)); // :69
	}

	// :56-62 + :43-55：param4=true 覆写四向边距；false 时 PostWindowBG
	// 无定义守卫不落地，保持 Panel 默认
	public function test_ctor_margins_by_param4() {
		var win = new PostWindow(null, "", null, true);
		Assert.equals(3, win.marginL); // :58
		Assert.equals(5, win.marginR); // :59
		Assert.equals(27, win.marginT); // :60
		Assert.equals(5, win.marginB); // :61
		Assert.isTrue(win._defaultSkin); // else 分支不动 :42 初值

		var win2 = new PostWindow(null); // param4=false，eval 无 PostWindowBG
		Assert.equals(5, win2.marginL); // Panel.as:57（Style.panelPaddingH）
		Assert.equals(5, win2.marginR); // Panel.as:56
		Assert.equals(22, win2.marginT); // Panel.as:54（Style.panelHeadHeight）
		Assert.equals(28, win2.marginB); // Panel.as:55
	}

	// :192-198 + BaseWindow set_data → setData：data 的 text 键路由进 text
	public function test_setData_routes_text() {
		var win = buildWindow();
		win.data = {text: "<b>农场公告</b>"};
		Assert.equals("<b>农场公告</b>", win.text); // :196 → set text :157
		Assert.equals("<b>农场公告</b>", win._postText.htmlText); // :160

		// :194 super.data null 门：text 不动
		win.data = null;
		Assert.equals("<b>农场公告</b>", win.text);
	}

	// :155-166 + :200-203：text 存取；_postText 非空时同步刷 htmlText
	public function test_text_setter_updates_postText() {
		var win = buildWindow();
		win.text = "第一条公告";
		Assert.equals("第一条公告", win.text); // :200-203
		Assert.equals("第一条公告", win._postText.htmlText); // :160

		// _postText 未建（init 之前）：只存 _text，不炸（:158 null 门）
		var win2 = new PostWindow(null);
		win2.text = "第二条";
		Assert.equals("第二条", win2.text);
	}

	// :205-209：imgUrl 空值守卫在建 Loader 之前 return
	public function test_imgUrl_empty_guards_no_loader() {
		var win = new PostWindow(null);
		win.imgUrl = null;
		Assert.isNull(win._loader); // :207
		win.imgUrl = "";
		Assert.isNull(win._loader); // :208
	}

	// :147-153：enableBtn 的 _btn null 门与按钮写入
	public function test_enableBtn_guards_and_writes_button() {
		var win = new PostWindow(null);
		win.enableBtn(false); // _btn null → no-op 不炸（:149）

		var btn = new Button();
		win._btn = btn;
		win.enableBtn(false);
		Assert.isFalse(btn.enabled); // :151
		win.enableBtn(true);
		Assert.isTrue(btn.enabled);
	}

	// :168-175：confirmFn 关窗（super.close → Event.CLOSE）+ 回调；
	// 回调用后不清（对照 ConfirmWindow.confirmButtonClick 的清空）、null 不炸
	public function test_confirmFn_closes_and_fires_callback() {
		var win = new PostWindow(null);
		var closeCount = 0;
		win.addEventListener(Event.CLOSE, function(e) closeCount++);
		var called = 0;
		win._btnCallback = function() called++;
		win.confirmFn();
		Assert.equals(1, closeCount); // :170 super.close()（TitleWindow.close :98-103）
		Assert.equals(1, called); // :171-174

		// 二次调用：回调保留（:168-175 无清空语句，与 ConfirmWindow :155 相异）
		win.confirmFn();
		Assert.equals(2, called);
		Assert.equals(2, closeCount);

		// :171 null 门：无回调只关窗
		var win2 = new PostWindow(null);
		var closeCount2 = 0;
		win2.addEventListener(Event.CLOSE, function(e) closeCount2++);
		win2.confirmFn();
		Assert.equals(1, closeCount2);
	}

	// :237-240：fixSize 只写
	public function test_fixSize_setter() {
		var win = new PostWindow(null);
		win.fixSize = false;
		Assert.isFalse(win._fixSize);
		win.fixSize = true;
		Assert.isTrue(win._fixSize);
	}
}

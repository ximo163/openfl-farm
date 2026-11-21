package shim;

import openfl.display.LoaderInfo;

/**
 * 宿主页面 shim：openfl 不解析页面 flashvar（LoaderInfo.parameters 恒为空对象），
 * 这里按原版宿主页 legacy/deploy/QFarmFlash/source/core/view/qf_default/nc.htm
 * 渲染出同样的 FLASH_VARS，注入 loaderInfo.parameters——翻译后的 Settings /
 * FarmLite 与原版一样从 stage.loaderInfo.parameters 读取，调用点不动。
 *
 * 模板变量渲染规则（nc.htm 的 {:$xml}/{:FARM_DAY} + 页面尾部的两行动态注入）：
 * - config_url/config_data/config_addon（nc.htm:84-86）：{:$xml} 取
 *   source/core/common.php:59-69 里 gzipcompress==1 分支的 "xml.php?mod="；
 *   FARM_DAY=20120905（common.php:8-9，'7.0 Final Build 20120905.1700' 的
 *   substr(16,8)）。快照后端实际是 gzipcompress=0（$xml='data/xml/'），但那个
 *   分支请求的 data/xml/load_main_v_20120905.xml 与它自建的静态文件名
 *   nc_main_20120905.xml（common.php:62-66 按模块名生成）对不上，原部署下该
 *   URL 从不命中；真正可用的是 xml.php 动态端点（本任务也指定 config 走
 *   xml.php，CI 冒烟代理只转发 *.php）——见 PR 说明的 deviations 候选。
 * - mode（nc.htm:92）：SwfAppLib.platform.isQzone ? 1 : 2，独立页面不在 QZone
 *   宿主，取 "2"（xiaoyou 分支：startCGIUrl 不加 qzone.qq 前缀，走同源相对
 *   mync.php，正好匹配冒烟代理的同源语义）。
 * - pageDomain（nc.htm:93）：document.domain，即不带端口的页面 hostname。
 * - android 分支（issue #10）：真机没有宿主页也没有同源站点，config_url/
 *   config_data/config_addon 的相对 xml.php 在这里改写成局域网后端绝对地址
 *   （shim.AndroidBackend；CGI 出口的同类改写在 shim.AndroidHttpRequest——
 *   那边的 URL 是运行时拼的，flashvar 里改不到）。
 */
class FlashVars {
	public static function inject(loaderInfo:LoaderInfo):Void {
		// nc.htm:18-91 的 FLASH_VARS 字面量逐键照抄（模板串按上面注释的规则渲染）
		var vars:Dynamic = {
			"hmv2level": "0",
			"hmv2CloseTime": "1261929600",
			"batchStealHour": "5-10,12-13,19-22",
			"cacheSeed": "293",
			"buyToolHour": "0-24",
			"buyToolTips": "最近化肥使用量激增导致供应紧张，目前暂不能购买。",
			"healthModeTime": "00:00 - 06:00",
			"reqYellowlevel": "2",
			"ShopToolLink": "",
			"ShopHeadLink": "",
			"filterUrl": "http://qbar.qq.com/application/r/?839782",
			"noFoodTips": "最近狗粮原材料供应紧张，目前暂不能购买。",
			"missionTitle": "中秋国庆时，欢聚农牧场！",
			"missionPrepareTime": "2010-9-8 02:00:00",
			"missionAutumnBeginTime": "2010-9-20 00:00:00",
			"missionNationalBeginTime": "2010-9-26 00:00:00",
			"missionEndTime": "2010-10-9 00:10:00",
			"fstTimeZq": "2010-9-20 10:00:00",
			"sndTimeZq": "2010-9-20 12:00:00",
			"trdTimeZq": "2010-9-20 14:00:00",
			"fourthTimeZq": "2010-9-20 16:00:00",
			"fifthTimeZq": "2010-9-20 18:00:00",
			"fstTimeGq": "2010-9-26 10:00:00",
			"sndTimeGq": "2010-9-26 12:00:00",
			"trdTimeGq": "2010-9-26 14:00:00",
			"fourthTimeGq": "2010-9-26 16:00:00",
			"fifthTimeGq": "2010-9-26 18:00:00",
			"missionPrepareHtml": "",
			"config_url_qz": "",
			"config_url_xy": "",
			"miniFactoryText": "",
			"snowslide": "3",
			"uinMode": "1",
			"flowerDayTips": "内测期间开放给黄钻以及农场15级以上（含15级）用户，每天每人可赠送一束鲜花哦！",
			"flowerYDLevel": "1",
			"qShowAtFarm": "qShowAtFarm.swf",
			"qShowLevel": "0",
			"restaurantConfig": "",
			"mill": "appid=376",
			"millLimitYDLevel": "1",
			"TVShow": "",
			"buyTin": "1",
			"qixiPrepareTime": "2010-9-19 00:00:00",
			"qixiBeginTime": "2010-9-19 23:35:00",
			"qixiEndTime": "2010-9-26 00:05:00",
			"diyLimitYDLevel": "4",
			"domian_qz": "farm.qzone",
			"domian_xy": "farm.xiaoyou",
			"loadingUrl": "module/loading2_v_3.swf",
			"friend_list_mod_qz": "1000",
			"friend_list_mod_xy": "1000",
			"friend_list_qz": "",
			"friend_list_xy": "",
			"friend_list_tips": "系统繁忙，请稍后再试！",
			"steal_mod": "1000",
			"steal": "",
			"steal_tips": "为保证更加稳定的服务，系统正在对部分号码进行数据维护。在此时间段系统将暂停您的 “摘取”操作以保护您的数据安全。期间好友也不能摘取您的作物，其他操作正常！谢谢您的支持！",
			"steal_tips_other": "为保证更加稳定的服务，系统正在对部分号码进行数据维护。在此号段的农场在维护期间将停止摘取以保护您的数据安全。期间好友也不能摘取您的作物，其他操作正常！谢谢您的支持！",
			"steal_tips_2": "系统维护中，暂时不能摘取，请稍后再试。",
			"friend_list_tips_2": "系统维护中，暂时不能查看好友信息，请稍后再试。",
			"index_tips": "系统维护中，请耐心等待。",
			"enter_into_mod": "1000",
			"enter_into": "",
			"redirect_url_qz": "",
			"redirect_url_xy": "",
			"config_url": "xml.php?mod=load_main_v_20120905.xml",
			"config_data": "xml.php?mod=data_zh_CN_v_20120905.xml",
			"config_addon": "xml.php?mod=addon_v_20120905.xml",
			"useflag": "11111111",
			"usercheck": "7da443769f0243036e1f92b269f93a72",
			"app_status_bitmap": "000000000000000f",
			"app_request_num": "0"
		};
		// nc.htm:92-93 的动态注入
		Reflect.setField(vars, "mode", "2");
		Reflect.setField(vars, "pageDomain", pageDomain());

		// android 真机侧接线：基址先按「flashvar 覆盖优先」解析（parameters
		// 已带 farm_backend 用它，否则 AndroidBackend 默认值），写回 vars 让
		// Settings 成为基址的唯一来源（AndroidHttpRequest 从那里读）
		#if android
		var backend:String = AndroidBackend.resolveBase(loaderInfo.parameters);
		Reflect.setField(vars, AndroidBackend.BACKEND_VAR, backend);
		Reflect.setField(vars, "config_url", AndroidBackend.rebase(backend, Reflect.field(vars, "config_url")));
		Reflect.setField(vars, "config_data", AndroidBackend.rebase(backend, Reflect.field(vars, "config_data")));
		Reflect.setField(vars, "config_addon", AndroidBackend.rebase(backend, Reflect.field(vars, "config_addon")));
		#end

		var params = loaderInfo.parameters;
		for (key in Reflect.fields(vars)) {
			Reflect.setField(params, key, Reflect.field(vars, key));
		}
	}

	static function pageDomain():String {
		// document.domain = 不带端口的页面 hostname；非 html5 目标没有页面概念，取空串
		#if html5
		return js.Browser.location.hostname;
		#else
		return "";
		#end
	}
}

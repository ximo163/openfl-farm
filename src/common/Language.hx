package common;

// common.Language —— Language.as 逐句对应（语言表 + L 查询 + replaceText 模板
// 替换；cn 表从原文逐条抄录）。RegExp("{"+k+"}","g") 的 E4X 字符串正则按
// Haxe EReg 等价改写（{ 转义）。
class Language {
	// Language.as:7
	public static final CN:String = "cn";

	// Language.as:9-（_l 表；表内容逐条对应原文）
	private static var _l:Dynamic = {"cn":{
			"warehouseTitle": "仓库",
			"warehouseDirection": "作物锁定功能只记录在本地电脑，清空IE或更换电脑需要重新设置",
			"toolTileDirection": "购买化肥，让作物生长时间缩短，提前收获，防止被摘取。",
			"diyTileDirection": "购买装饰，打造的个性农场，更可获得经验奖励，更快升级。",
			"adTileDirection": "参与活动，免费获得农场种子、道具和装饰。",
			"diyTagDiy": "农场装饰",
			"diyTagQShow": "QQ秀装饰",
			"shopTitle": "商店",
			"dialTitle": "开心大转盘",
			"gainTitle": "开心大转盘",
			"sellSome": "卖出果实",
			"sellSomeSeeds": "卖出种子",
			"sellSomeTip": "卖出果实（不包含锁定的果实）",
			"该果实已锁定不能卖出": "已锁定不能卖出",
			"shopTagSell": "种子",
			"shopTagFertilizer": "道具",
			"shopTagDecorate": "装饰",
			"shopTagAdvertisement": "活动",
			"sumGold": "总价值：",
			"shopSeedWindow": "购买种子",
			"shopToolWindow": "购买道具",
			"sellCropWindow": "卖出果实",
			"sellMaterialWindow": "卖出材料",
			"alertTitle": "提示",
			"开通牧场": "开通QQ牧场",
			"开通牧场说明": "<TEXTFORMAT LEADING=\"2\"><P ALIGN=\"CENTER\"><FONT FACE=\"Verdana\" SIZE=\"12\" COLOR=\"#333333\" LETTERSPACING=\"0\" KERNING=\"0\">QQ牧场已正式发布，您是否现在开通？</FONT></P></TEXTFORMAT>",
			"开通牧场等级不足": "<p align=\'left\'>抱歉，牧场暂对满足以下任一条件的农场用户开放公测：\n1.农场{level}级及以上用户 \n2.VIP LV{lv} 及以上用户，或年费VIP用户</p>",
			"开通牧场才能访问": "<p align=\'left\'>抱歉，暂只对年费VIP或VIP LV{lv}用户开放</p>",
			"登录过期，": "登录过期，",
			"点击重新登录": "点击重新登录",
			"初始化错误，": "初始化错误，",
			"点击重试": "点击重试",
			"请求超时，稍后再试": "请求超时，稍后再试",
			"请求超时，": "请求超时，",
			"buySeedFnText": "购买成功，共花费金币<font color=\'#FF6600\'>{money}</font>，购买了<font color=\"#0099FF\"> <b>{num}</b> </font>个{cName}种子。",
			"buyFishFnText": "购买成功，共花费金币<font color=\'#FF6600\'>{money}</font>，购买了<font color=\"#0099FF\"> <b>{num}</b> </font>个{name}鱼苗。",
			"plantFishTip": "鱼苗放养成功，占用容量 <font color=\"#0099FF\"> <b>{size}</b> </font><br/>池塘剩余容量为 <font color=\"#0099FF\"> <b>{num}</b> </font>",
			"购买装饰成功": "购买装饰成功",
			"设置装饰失败": "设置装饰失败",
			"saleAllFnText": "成功卖出仓库里所有未锁定果实，得到金币 <font color=\"#FF6600\">&nbsp;<b>{money}</b>&nbsp;</font>。",
			"saleAllFishFnText": "成功卖出仓库里所有未锁定成鱼，得到金币 <font color=\"#FF6600\">&nbsp;<b>{money}</b>&nbsp;</font>。",
			"saleAllFnText2": "成功卖出所有种子，得到金币 <font color=\"#FF6600\">&nbsp;<b>{money}</b>&nbsp;</font>。",
			"saleFishText": "成功卖出<font color=\"#0099FF\"> <b>{num}</b> </font>个{name}，得到金币<font color=\"#FF6600\"> <b>{money}</b> </font>",
			"不可以对空地进行这个操作啦！": "不可以对空地进行这个操作啦！",
			"这块地不需要浇水啦！": "这块地不需要浇水啦！",
			"这块地不需要除草啦！": "这块地不需要除草啦！",
			"这块地不需要除虫啦！": "这块地不需要除虫啦！",
			"这块地无法种草啦！": "这块地无法种草啦！",
			"作物这个阶段不会长草！": "作物这个阶段不会长草！",
			"这块地无法放虫啦！": "这块地无法放虫啦！",
			"作物这个阶段不会生虫！": "作物这个阶段不会生虫！",
			"这块地没东西可收获！": "这块地没东西可收获！",
			"这块地没东西可偷！": "这块地没东西可摘！",
			"狗盯上了您，别做坏事了。": "狗盯上了您，别做坏事了。",
			"做人不能贪得无厌！": "做人不能贪得无厌！",
			"行行好吧，我所剩无几了！": "行行好吧，我所剩无几了！",
			"铲除作物": "铲除作物",
			"作物还没有收获，真的要铲除吗？": "作物还没有收获，真的要铲除吗？",
			"不可以种在这里哦！": "不可以种在这里哦！",
			"作物这个阶段不需要施肥": "作物这个阶段不需要施肥",
			"施过肥了，下个阶段再施吧": "施过肥了，下个阶段再施吧",
			"按钮": "按钮",
			"确定": "确定",
			"取消": "取消",
			"卖出": "卖出",
			"关闭": "关闭",
			"狗狗粮食": "狗狗粮食",
			"剩余狗粮还可以给狗狗吃": "剩余狗粮还可以给狗狗吃",
			"小时": "小时",
			"补充狗粮需要": " 补充狗粮需要",
			"狗粮充足，不需要补充狗粮了。": "狗粮充足，不需要补充狗粮了。",
			"状态(可怕)": "状态(可怕) ",
			"状态(糟糕)": "状态(糟糕) ",
			"状态(欠佳)": "状态(欠佳) ",
			"状态(良好)": "状态(良好) ",
			"状态(优秀)": "状态(优秀) ",
			"对不起，您的金币和等级均不足。": "对不起，您的金币和等级均不足。",
			"对不起，您的等级不足。": "对不起，您的等级不足。",
			"对不起，您的金币不足。": "对不起，您的金币不足。",
			"对不起，您的元宝不足。": "对不起，您的元宝不足。",
			"扩建农场": "扩建农场",
			"reclaimPayText": "扩建这块土地需要等级<font color=\'#0099ff\'> {level} </font>级和<br> 金币 <font color=\'#FF6600\'>{money}</font>。",
			"包裹里什么都没有，去商店里逛逛吧！": "包裹里什么都没有，去商店里逛逛吧！",
			"去商店": "去商店",
			"cropSeedName": "{cName}种子",
			"可拖动屏幕": "可拖动屏幕",
			"我的物品包": "我的物品包",
			"在地里放杂草": "在地里放杂草",
			"在地里放害虫": "在地里放害虫",
			"清除地里的杂草": "清除地里的杂草",
			"可用来翻地": "可用来翻地",
			"清除地里的害虫": "清除地里的害虫",
			"用来收获果实": "用来收获果实",
			"偷窃好友的果实": "摘取好友的果实",
			"用来浇水": "用来浇水",
			"刷新": "刷新",
			"上一页": "上一页",
			"下一页": "下一页",
			"查找": "查找",
			"当前经验:": "当前经验:",
			"升级还需经验:": "升级还需经验:",
			"我的农场": "我的农场",
			"我的牧场": "我的牧场",
			"仓库（收获的果子会在这里）": "仓库（收获的果子会在这里）",
			"开心商店（来这里买种子）": "开心商店（来这里买种子）",
			"装饰农场": "装饰农场",
			"晴天，有可能长虫、长草或干旱。": "晴天，有可能长虫、长草或干旱。",
			"雨天，土地不会干旱。": "雨天，土地不会干旱。",
			"夜晚，您可以好好休息哦。": "夜晚，您可以好好休息哦。",
			"给TA留言": "给TA留言",
			"礼包": "礼包",
			"消息": "消息",
			"留言": "留言",
			"公告": "公告",
			"数据初始化中...": "数据初始化中...",
			"等级和经验": "等级和经验",
			"接受": "接受",
			"欢迎": "欢迎",
			"到期时间：无限期": "到期时间：无限期",
			"到期时间：": "到期时间：",
			"农场装饰": "装饰",
			"背景": "背景",
			"房子": "房子",
			"狗窝": "狗窝",
			"栅栏": "栅栏",
			"已装饰": "已装饰",
			"装饰续费": "装饰续费",
			"续费": "续费",
			"outtime": "您的装饰物还剩{day}天到期",
			"原价：": "原价：",
			"折后价：": "折后价：",
			"立即节省：": "立即节省：",
			"可获得经验：": "可获得经验：",
			"今天": "今天 ",
			"昨天": "昨天 ",
			"前天": "前天 ",
			"累计收获:": "累计收获:",
			"累计偷窃:": "累计摘取:",
			"个人信息": "个人信息",
			"成果": "成果",
			"等级:": "等级:",
			"经验:": "经验:",
			"现金:": "现金:",
			"去TA的首页": "去TA的首页",
			"清空记录": "清空记录",
			"确认清空消息记录？": "确认清空消息记录？",
			"清空消息记录": "清空消息记录",
			"清空留言记录": "清空留言记录",
			"确认删除您的留言记录？": "确认删除您的留言记录？",
			"回复": " 回复 ",
			"购买装饰": "购买装饰",
			"预览": "预览",
			"购买": "购买",
			"用金币购买": "用金币购买",
			"用元宝购买": "用元宝购买",
			"您的金币不足。": "您的金币不足。",
			"您的元宝不足。": "您的元宝不足。",
			"您的元宝和金币都不足。": "您的元宝和金币都不足。",
			"有效期：": "有效期：",
			"validTime": "{day}天",
			"可获得经验：": "可获得经验：",
			"取消预览": "取消预览",
			"buyNum": "输入购买数量（{minNum}~{maxNum}）",
			"sellNum": "输入卖出数量（{minNum}~{maxNum}）",
			"maturingTime": "{maturingNum}季作物",
			"化肥": "化肥",
			"狗": "狗",
			"仓库里空空": "仓库里空空的，连老鼠都不来光顾，一分耕耘一分收获，赶紧种植去吧！",
			"没有材料了": "材料仓库空空的，赶紧去点击圣诞老人参与圣诞活动获得卡片吧！",
			"allSellText": "当前售出果实的总价值：（不包含锁定的果实）<br/><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？",
			"lovesallSellText": "<font color=\'#FF0000\'>情人节活动9倍收购果实“红宝石情花”默认不锁定</font><br>当前售出果实的总价值：（不包含锁定的果实）<br/><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？",
			"allFishSellText": "当前售出成鱼的总价值：（不包含锁定的成鱼）<br/><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？",
			"allMaterialSellText": "当前售出材料的总价值：（不包含锁定的材料）<br/><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？",
			"allSellText2": "您仓库内所有作物都处于锁定状态，无法出售。<br/>请先解除您想卖出的果实的锁定状态。",
			"allFishSellText2": "您仓库内所有成鱼都处于锁定状态，无法出售。<br/>请先解除您想卖出的成鱼的锁定状态。",
			"allMaterialSellText2": "您仓库内所有材料都处于锁定状态，无法出售。<br/>请先解除您想卖出的材料的锁定状态。",
			"allSellSeedsText": "当前种子售出后将得到金币：<font color=\'#FF6600\'>{goldValue}</font><br/>回收价值&nbsp;<font color=\'#FF0000\'><b>低于</b></font>&nbsp;原售价<br/>是否全部卖出？",
			"allSellSeedsText2": "您仓库内所有作物都处于锁定状态，无法出售。<br/>请先解除您想卖出的果实的锁定状态。",
			"查看新任务": "查看新任务",
			"查看当前任务": "查看当前任务",
			"您已完成全部新手任务！": "您已完成全部新手任务！",
			"完成任务": "完成任务",
			"进行下一个任务": "进行下一个任务",
			"领取任务": "领取任务",
			"任 务": "任 务",
			"(此任务进行中)": " (此任务进行中) ",
			"(每条最多 50 字)": "(每条最多 50 字)",
			"发送留言": "留言",
			"growText": "({timeText}{section})",
			"hrsText": "{hrs}小时",
			"minsText": "{mins}分钟",
			"ripeText": "第{season}季 ({ups}产{units} 剩{left})",
			"-已偷过": "-已摘取",
			"马上开启健康模式": "马上开启健康模式",
			"已开启健康模式": "已开启健康模式",
			"取消健康模式": "取消设置",
			"已进入健康模式": "已进入健康模式",
			"赠送花束": "赠送花束",
			"HM_TITLE": "健康模式（内测版）",
			"HM_TO_OPEN": "为了让大家更健康的享受农场带来的乐趣，我们为您提供了农场健康模式。<br/>通过这项功能您可以根据自己的作息习惯设置适合自己的健康时间。<textformat leading=\'-5\'><br/>&nbsp;<br/></textformat>1)您可以选择任意@healModeTotalHour小时为自己的健康时间，设置后好友不能对您的作物进行摘取操作；<br/>2)公平起见，在此时间段您同样不能摘取好友的作物，也不能收获自己的作物；<br/>3)健康模式生效前可取消设置，生效后则不能更改设置，有效期为@totalDay天，到期自动解除；<br/><font color=\'#F47600\'>设置北京时间&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color=\'#39C4F8\'>：</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;到 <font color=\'#39C4F8\'><b>@endTime</b></font> 为每天的健康时间，@totalDay天有效。</font>",
			"HM_OPEN_CONFIRM": "<p align=\'left\'><font size=\'12\'>您确定将每天的<font color=\'#39C4F8\'><b>@time</b></font>设置为农场健康时间吗？<br/>健康模式启动后，将不能更改设置，有效期为@totalDay天，到期自动解除。</font></p>",
			"HM_OPEN_SUCCESS": "<p align=\'left\'><font size=\'12\'>健康模式设置成功！<br/>有效期：@period<br/>生效时间：北京时间&nbsp;@time<br/>ＱＱ农场，健康农场，希望我们能为您带来更多的快乐！</font></p>",
			"HM_SET_FAILED": "非常抱歉，因网络繁忙，健康模式设置失败，请您重试。",
			"HM_FRIEND_PICK": "<p align=\"left\"><font size=\"12\">该好友已将每天的@time设置为农场健康时间。<br/>在此时间段该好友与您互相停止摘取操作。现在是北京时间@now。<br/><font color=\'#0000FF\'><u><a href=\"event:whatIsHealthMode\">什么是健康模式？</a></u></font></font></p>",
			"HM_SELF_PICK": "<p align=\"left\"><font size=\"12\">您已设置北京时间@time为农场健康时间。<br/>此时间段不能摘取作物（包括主人和好友）。<br/>@endDate健康模式将自动解除。现在是北京时间@now。</font></p>",
			"HM_TO_PICK_FRIEND": "<p align=\"left\"><font size=\"12\">您已设置北京时间@time为农场健康时间。<br/>您与好友互相停止摘取作物，其他操作正常。<br/>@endDate健康模式将自动解除。现在是北京时间@now。</font></p>",
			"HM_CLOSE_CONFIRM": "<font size=\'12\'>&nbsp;&nbsp;您确定要取消健康模式吗？&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font>",
			"HM_CLOSE_SUCCESS": "<p align=\'left\'><font size=\'12\'>健康模式取消成功。<br/>ＱＱ农场，健康农场！希望我们能为您带来更多的快乐！</font></p>",
			"HM_TO_CLOSE": "为了让大家更健康的享受农场带来的乐趣，我们为您提供了农场健康模式。<br/>通过这项功能您可以根据自己的作息习惯设置适合自己的健康时间。<textformat leading=\'-5\'><br/>&nbsp;<br/></textformat>1)您可以选择任意 @healModeTotalHour 小时为自己的健康时间，设置后好友不能对您的作物进行摘取操作；<br/>2)公平起见，在此时间段您同样不能摘取好友的作物，也不能收获自己的作物；<br/>3)健康模式生效前可取消设置，生效后则不能更改设置，有效期为@totalDay天，到期自动解除；<br/><font color=\'#F47600\'>您已设置北京时间<font color=\'#39C4F8\'><b>@time</b></font>为每天的健康时间。</font><br/><font color=\'#F47600\'>有效期为<font color=\'#39C4F8\'><b>@period</b></font>（待启动状态）</font>",
			"HM_VALID": "<p align=\"left\"><font size=\"12\">为了让大家更健康的享受农场带来的乐趣，我们为您提供了农场健康模式。<br/>通过这项功能您可以根据自己的作息习惯设置适合自己的健康时间。<textformat leading=\'-5\'><br/>&nbsp;<br/></textformat>1)您可以选择任意 @healModeTotalHour 小时为自己的健康时间，设置后好友不能对您的作物进行摘取操作；<br/>2)公平起见，在此时间段您同样不能摘取好友的作物，也不能收获自己的作物；<br/>3)健康模式生效前可取消设置，生效后则不能更改设置，有效期为@totalDay天，到期自动解除；<br/><font color=\'#F47600\'>您已设置北京时间<font color=\'#39C4F8\'><b>@time</b></font>为每天的健康时间。</font><br/><font color=\'#F47600\'>有效期为<font color=\'#39C4F8\'><b>@period</b></font>（已启动，到期自动解除）</font></font></p>",
			"HM_UPDATING": "<p align=\"left\"><font size=\"12\">农场健康模式已全面升级！自定义@healModeTotalHour小时健康时间(好友与您互相停止摘取操作)，<br/>更好的保证您的工作学习和休息时间！新功能内测期间，暂时开放给黄钻LV@hmv2Level<br/>及以上用户试用，随着功能的完善我们会在最短的时间内开放给更多用户。<br/>ＱＱ农场，健康农场，谢谢您的支持！</font></p>",
			"NoticeTitle": "通 知",
			"BackTitle": "召回请求",
			"BackTip": "<font color=\'#1A9CD0\'>农友们都想请你回来种菜，仅可选择接受一位好友请求，接受后可获得</font><font color=\'#FF6600\'>5</font><font color=\'#1A9CD0\'>个米兰种子。</font>",
			"BlackUp": "<font size=\'14\'><b>您的土地升级后，将成为肥沃的黑土地，黑土地拥有如下特权：</b></font><br/>",
			"BlackUpNoLand": "亲爱的农友，您需要先升级红土地，再把红土地升级为黑土地哦。",
			"BlackUpShare1": "我在【QQ农场】里成为【升级黑土地】{place}的第{rank}位，我不是在炫富，也不是在炫我多有，只是你刚好华丽地经过鉴证了我闪亮升级！你是第几位呢？",
			"BlackUpShare2": "我是【QQ农场里开拓黑土地{place}第{rank}人】，天空一声巨响，我再次闪亮！赶紧加入土地升级新革命吧！",
			"赠送好友": "赠送好友",
			"赠送QQ农场道具": "赠送QQ农场道具",
	}};

	// Language.as:41-45
	public function new() {
		super();
	}

	// Language.as:47-68
	public static function replaceText(param1:String, param2:Dynamic):String {
		var _loc4_:String = null;
		var _loc5_:EReg = null;
		var _loc3_:String = "";
		if (param1 == "" || param2 == null) {
			return _loc3_;
		}
		_loc3_ = Reflect.field(Language.L, param1);
		for (_loc4_ in Reflect.fields(param2)) {
			_loc5_ = new EReg("\{" + _loc4_ + "\}", "g");
			_loc3_ = _loc5_.replace(_loc3_, Std.string(Reflect.field(param2, _loc4_)));
			_loc3_ = StringTools.replace(StringTools.replace(StringTools.replace(StringTools.replace(_loc3_, "#1#", "1st"), "#2#", "2nd"), "#3#", "3rd"), "#4#", "4th");
		}
		return _loc3_;
	}

	// Language.as:70-73
	public static var L(get, never):Dynamic;

	private static function get_L():Dynamic {
		return Reflect.field(_l, lang);
	}

	// Language.as:75-89
	public static var lang(get, never):String;

	private static function get_lang():String {
		if (_currentLang != "") {
			return _currentLang;
		}
		var _loc1_:String = Settings.getInstance().getStringAttribute("language");
		if (_loc1_ == "" || _loc1_ == null) {
			_currentLang = "cn";
		} else {
			_currentLang = _loc1_;
		}
		return _currentLang;
	}

	// Language.as:11
	private static var _currentLang:String = "";
}

package;

/** issue #67 普查待分诊桶三件（gifts_v_11 / farmui_full_v_40 / farmui1_v_42）
 *  加载链考证结论（研究任务交付物，2026-11-25 考证）。格式 per 件：
 *  引用出处（文件:行）→ 活跃/非活跃 → 定级建议（三选一表态给所有者拍板，
 *  不自行裁决）。gifts/farmui_full 两件已在前置 commit 收编进 main_swfs
 *  （scripts/decompile-legacy.sh:66/:69），baseline 无账可写，按 test/**
 *  append-only 落本文件；farmui1 在 baseline mc/main/* 族账内，结论同时
 *  写进该族 reason（本文件的 FARMUI1_V_42 是同一结论的完整版）。
 *  全部出处已逐一在 legacy/ 核对（deploy 冻结基线 + decompiled 反编译）。 */
class Issue67TriageNotes {
	/** ---------------- gifts_v_11.swf（13 类 / ABC 22.7KB）----------------
	 *
	 *  【引用出处】URL 表配置 key + 代码反射链两段：
	 *  - 配置行：legacy/deploy/QFarmFlash/source/core/source/xml/mod/
	 *    nc_main.php:22 `<module name="FreeGift Module" url="$url/module/ui/
	 *    gifts_v_11.swf"/>`——main 模块的异步加载模块（URL 表配置 key，
	 *    模块注册名 "FreeGift Module" 与文件名 gifts 不一致即 issue 的疑点，
	 *    答案：注册名是模块桩名，文件名是 swf 版本名，两者经 Consts.
	 *    MODULE_FREE_GIFT = "FreeGift Module"（main3 Consts.as:34）对齐）。
	 *  - 模块桩：main3 module/FreeGift/ModuleFreeGift.as（不是 issue 猜的
	 *    ModuleGifts——main3 里没有 ModuleGifts）。桩在 FarmApplication.as
	 *    :1048-1049 `new ModuleFreeGift(this)` + `loadLater([MSG_LOAD_FREEGIFT,
	 *    MSG_SHOW_FREEGIFT], null)` 注册；onModuleLoadSuccess 里
	 *    ModuleFreeGift.as:23 `Utils.getClass("module.FreeGift.
	 *    FreeGiftController")` 反射取控制器——类体在被加载的 gifts_v_11.swf
	 *    内（legacy/decompiled/gifts_v_11/scripts/module/FreeGift/
	 *    FreeGiftController.as 等 13 类），这是外部 swf 的 AS3 在 Flash
	 *    里同域执行的玩法，openfl 侧不执行外部 swf ABC，须翻译接入。
	 *  - 加载触发：FarmApplication.as:1076-1078 启动后 setTimeout 1400ms
	 *    自动 dispatch MSG_LOAD_FREEGIFT（无须用户操作即加载，与
	 *    quickshoot/cardsgame 同批）；用户入口两处：main3 uitools/widgets/
	 *    LeftSideToolBar.as:143/:147 免费礼物图标 CLICK → dispatch
	 *    MSG_SHOW_FREEGIFT（openIndex 1/0）；Main.as:369-371 qzone 外链
	 *    actiontype=freegift → dispatch MSG_SHOW_FREEGIFT（openIndex 1）。
	 *
	 *  【活跃判定】链路活着、写路径死：
	 *  - 读路径活：nc_addon.php:229-258 freegifts 表 25 项，visible="1"
	 *    恰 8 项（id 18-25，nc_addon.php:249-257，全是「七夕」外观的妙恋
	 *    系列，外观档期注释见 nc_addon.php:115 freeGiftTime "8.20 — 9.3"
	 *    与 :248「七夕」），其余 17 项 visible="0"；gifts_v_11 SetPage.as
	 *    :99 按 visible=="0" 过滤后仍有 8 项可展示。收礼 mod
	 *    cgi_farm_request_count/list/gift_recv 在 mync.php:146/:149/:150
	 *    白名单内（ServerServices.as:165/:166/:168 CMD_FREE_COUNT/
	 *    CMD_FREE_LIST/CMD_FREE_GIFT_RECV），拉取链路在本部署可达。
	 *  - 写路径死：送礼 mod cgi_farm_request_gift_send（main3 framework/
	 *    net/ServerServices.as:167 CMD_FREE_GIFT，FreeGiftView.as:354 的
	 *    送礼调用）**不在** mync.php 白名单（:100-170 全文核对无此项）——
	 *    本部署的 PHP 会拒发，送礼操作不可达。即「能看能收不能送」。
	 *  - GiftWindow 分工（issue 疑点）：main3 common/view/window/
	 *    GiftWindow.as（注册名 WINDOW_NAME_GIFT，FarmStage.as:100）是
	 *    **静态礼包展示窗**—— FarmLandModel.as:909 农田操作结果里带
	 *    gift 时经 EVENT_SHOW_GIFT_WINDOW → FarmLandController.as:1032/
	 *    :1069 openWindowByName 弹出，440×330 标题「礼包」，只展示一次
	 *    性奖励内容；gifts_v_11 是**好友间收发礼物流程窗**（选礼物→选
	 *    好友→发送/收礼回执，FreeGiftView 573 行 + widgets2 八件）。两者
	 *    名字相近但零共享：一个展示掉落，一个社交流程。
	 *
	 *  【定级建议】**立项翻译**（进 main_swfs 已完成——decompile-legacy.sh
	 *  :66 在册，13 类反编译产物已落地；立项=开模块翻译 issue 按
	 *  shop/warehouse/pool/decorate 同族先例翻译 module.FreeGift 族 +
	 *  main3 侧 ModuleFreeGift 桩已随启动链翻译在 src/）。理由：链路现役
	 *  自动加载（1400ms 无操作触发），读路径在本部署真实可达，是农场
	 *  主程序行为面的一部分；送礼写路径死不改变翻译必要性——原版行为
	 *  就是「按钮可点、请求被拒」，翻译要复刻的正是这个行为。备选否案：
	 *  若所有者认为写路径死=功能半残不值一译，可降级 baseline 登记冻结，
	 *  但它已在 main_swfs（匹配口径），冻结需要把它移出 main_swfs=改
	 *  口径，与 issue #67 边界冲突，故不推荐。 */
	public static var GIFTS_V_11:String = "【gifts_v_11.swf 考证结论（issue #67，2026-11-25）】引用出处：nc_main.php:22 `<module name=\"FreeGift Module\" url=\"$url/module/ui/gifts_v_11.swf\"/>`（URL 表配置 key，异步加载模块）；模块桩是 main3 module/FreeGift/ModuleFreeGift.as（非 ModuleGifts，main3 无此类），ModuleFreeGift.as:23 `Utils.getClass(\"module.FreeGift.FreeGiftController\")` 反射取控制器、类体在 gifts_v_11.swf 内（decompiled/gifts_v_11/scripts/module/FreeGift/FreeGiftController.as 等 13 类）；加载触发 FarmApplication.as:1049 loadLater([MSG_LOAD_FREEGIFT,MSG_SHOW_FREEGIFT]) + :1076-1078 setTimeout 1400ms 自动 dispatch MSG_LOAD_FREEGIFT（无须用户操作）；用户入口 LeftSideToolBar.as:143/:147（openIndex 1/0）与 Main.as:369-371（qzone 外链 actiontype=freegift）。活跃判定：链路活着、写路径死——读路径活：nc_addon.php:228-258 freegifts 表 25 项 visible=\"1\" 恰 8 项（id 18-25，七夕妙恋系列，:115/:248 外观档期注释），SetPage.as:99 按 visible==\"0\" 过滤后仍有余量；cgi_farm_request_count/list/gift_recv 在 mync.php:146/:149/:150 白名单内。写路径死：cgi_farm_request_gift_send（ServerServices.as:167 CMD_FREE_GIFT）不在 mync.php 白名单——本部署 PHP 拒发，送礼不可达，「能看能收不能送」。GiftWindow 分工：main3 common/view/window/GiftWindow.as 是静态礼包展示窗（FarmLandModel.as:909 掉落结果 → FarmLandController.as:1069 弹出，440×330 标题「礼包」），gifts_v_11 是好友间收发礼物流程窗（选礼→选友→发送/回执），两者名字相近零共享。定级建议：立项翻译——链路现役自动加载、读路径真实可达，送礼写路径死不改变翻译必要性（要复刻的正是「按钮可点请求被拒」的原版行为）；decompile-legacy.sh:66 已在册反编译，立项=开模块翻译 issue 按 shop/warehouse/pool/decorate 同族先例译 module.FreeGift 族。备选否案（不推荐）：降 baseline 冻结须移出 main_swfs=改匹配口径，与 issue #67 边界冲突。";

	/** ---------------- farmui_full_v_40.swf（207 DoABC / ABC 89KB）----------------
	 *
	 *  【引用出处】URL 表配置 key，非代码硬引用：nc_main.php:11
	 *  `<material url="$url/module/ui/main/farmui_full_v_40.swf"
	 *  statusText="加载UI素材..."/>`——main 模块的 material 素材预载
	 *  （与 :12 farmui2_v_58、:13 water_ui_v_0 相邻三件同族）。main3
	 *  反编译全文 grep 无 farmui_full 文件名硬引用——素材消费走符号名
	 *  （Utils.getMaterial("FarmInfoPlus") 等）与直接 new（NPCView.as:141
	 *  new MaoPaoFlag()），符号宿主才是本库。
	 *
	 *  【207 DoABC 定性】逐类核过（legacy/decompiled/farmui_full_v_40/
	 *  scripts/ 207 个 .as 全量扫）：206/207 是纯 stub——构造体仅
	 *  super()（+帧脚本族的 addFrameScript 登记）之外零逻辑、零业务方法；
	 *  其中 190 件带 [Embed(source="/_assets/assets.swf", ...)] 标记，即
	 *  Flash IDE 为库符号自动生成的空壳关联类，「量级异常」是 IDE stub
	 *  涨量，不是隐藏的半个模块。成分分布：com/qzone/qui/skins/ 38 件
	 *  qui 皮肤空壳、com/qzone/ui/ 10 件地块皮肤（FarmlandS/G 系）空壳、
	 *  顶层 155 件按钮/图标/光标/底板符号壳。例外与活代码只有两类：
	 *  - 帧脚本族 18 件（构造器 addFrameScript 登记）：11 件 frame1=stop()
	 *    同型（光标族 CursorHand/CursorHoe/CursorWater/CursorHook/
	 *    CursorPesticide/CursorInsect/CursorWeed/CursorOneClickHand +
	 *    AddAnimation/AddHealth/SellLockIcon/lock_mc_46——CursorArrow
	 *    两帧各 stop）、MaoPaoFlag.as:17 addFrameScript(0,frame1,23,
	 *    frame24) frame24=infoTxt.text=talkInfo+stop、FarmLoading.as
	 *    frame48=gotoAndPlay("loop") 加载环回绕、GiftIcon.as frame42=
	 *    gotoAndPlay("GiftMove")、CursorArrow 双帧 stop；
	 *  - 唯一带监听的 PackageTab.as（背包三页签：btnSeed/btnTool/btnFish
	 *    CLICK → gotoAndStop + dispatchEvent("seed"/"tool"/"fish")）；
	 *  - 唯一带业务方法的 FarmInfoPlus.as（setInfo/setStep7/setOutput 等
	 *    地块信息提示版面，main3 LandInfoTip.as:50 经 getMaterial 反射
	 *    构造消费）。
	 *  这些活代码与 main3 的衔接已经是事实：src/shim/
	 *  FrameScriptCompensation.hx（issue #58）已登记 MaoPaoFlag frame24
	 *  等补偿、src/FarmInfoPlus.hx 已按 ABC 复原方法、src/ 下 40+ 符号
	 *  shim（ToolWeed/MsgIcon/VipL3…）已按 SymbolClass 绑定消费。
	 *
	 *  【farmui2_v_58 关系】同族姊妹库：两者是 nc_main.php:11-12 相邻两行
	 *  的 main material 素材预载，帧脚本族同源同病（farmui2 的帧脚本已由
	 *  baseline entries farmui2_v_58 行 tracked="#58" 挂账）；分工上
	 *  farmui_full 是「全量 UI 符号库」（农场主界面全部符号皮），farmui2
	 *  是后补增量库。两者都不是独立功能模块——没有控制器/模型，不产生
	 *  网络请求。
	 *
	 *  【活跃判定】活跃素材库：每次启动必加载（material 预载在主模块
	 *  装载链上），符号被 main3 界面全面消费。
	 *
	 *  【定级建议】**归 #58 帧脚本族跟踪，不单独立项**（等价于「维持现状
	 *  + 挂账」：素材库身份不变，18 件帧脚本的补偿登记随 #58 批次逐件
	 *  补齐——FrameScriptCompensation 已开端；206 件 stub 无行为可译，
	 *  符号 shim 按需随各模块消费点抄录——已在做）。理由：它不是功能
	 *  swf（无控制器代码），「立项翻译」没有可译对象；它已在 main_swfs
	 *  （decompile-legacy.sh:69，为帧脚本清查与符号考证提供反编译产物），
	 *  baseline 无账可写也不必入账。若所有者要对账形式上更显式，可在
	 *  baseline 增补一条说明性 entry——但那属于改匹配口径，issue #67
	 *  边界禁止，故建议就是挂 #58。 */
	public static var FARMUI_FULL_V_40:String = "【farmui_full_v_40.swf 考证结论（issue #67，2026-11-25）】引用出处：nc_main.php:11 `<material url=\"$url/module/ui/main/farmui_full_v_40.swf\" statusText=\"加载UI素材...\"/>`——main 模块 material 素材预载（URL 表配置 key，非代码硬引用；main3 反编译全文 grep 无文件名硬引用，消费走符号名 getMaterial/直接 new）。207 DoABC 定性（逐类核过 decompiled/farmui_full_v_40/scripts/ 207 类）：206/207 纯 stub（构造体仅 super()+addFrameScript 登记，190 件带 [Embed] 标记=Flash IDE 库符号自动空壳，「量级异常」是 IDE stub 涨量不是隐藏的半个模块）；活代码只两类——帧脚本族 18 件 addFrameScript（11 件 frame1=stop() 同型光标族/特效、MaoPaoFlag frame24 写文本+stop、FarmLoading frame48 gotoAndPlay(\"loop\") 回绕、GiftIcon frame42 循环、CursorArrow 双帧 stop）+ 唯一带监听的 PackageTab（背包三页签 CLICK → gotoAndStop+dispatch）+ 唯一带业务方法的 FarmInfoPlus（地块信息提示版面，LandInfoTip.as:50 getMaterial 消费）。衔接已是事实：src/shim/FrameScriptCompensation.hx（#58）已登记 MaoPaoFlag frame24 补偿，src/ 40+ 符号 shim 已 SymbolClass 绑定消费。farmui2_v_58 关系：nc_main.php:11-12 相邻两行同族素材预载姊妹库，帧脚本同源同病，farmui2 在 baseline tracked=\"#58\"；farmui_full 是全量 UI 符号库、farmui2 是后补增量，都非功能模块（无控制器/模型/网络请求）。活跃判定：活跃素材库，启动必加载，符号被 main3 全面消费。定级建议：归 #58 帧脚本族跟踪不单独立项——无功能代码可立项（stub 无行为可译），18 件帧脚本补偿随 #58 批次逐件补齐（已开端），符号 shim 按需随模块消费点抄录（已在做）；decompile-legacy.sh:69 在册为清查提供产物，baseline 入账/增补 entry 均属改匹配口径为 issue #67 边界所禁。";

	/** ---------------- farmui1_v_42.swf（110 类 / ABC 17.4KB）----------------
	 *
	 *  【引用出处】牧场侧：mc_main.php:21 `<material url="$url/module/mc/
	 *  main/farmui1_v_42.swf" statusText="加载UI素材..."/>`——牧场主模块
	 *  （Master2_v_142，mc_main.php:20）的 material 素材预载第 1 位
	 *  （URL 表配置 key），issue 原文「已确认牧场现役」复核无误。
	 *
	 *  【农场侧排查】（issue 的定级关键问题：农场侧是否也用）
	 *  - nc_main.php 全文无 farmui1：农场 material 只有三件
	 *    farmui_full_v_40/farmui2_v_58/water_ui_v_0（nc_main.php:11-13）；
	 *  - 反编译硬引用零命中：legacy/decompiled/main3_v_221/scripts/ 全文
	 *    grep "farmui1" 无结果；happyfarm3_v_149（农场预加载器）、
	 *    mcloader_v_53、Master2_v_142 的 scripts/ 同样全文零命中（注意
	 *    Master2 自己也不硬引用——它是配置驱动加载）；全部 50 个在册
	 *    decompiled/<名>/scripts/ 无一命中；
	 *  - 符号消费侧交叉验证：农场侧符号 shim（src/*.hx）全部绑定
	 *    farmui_full_v_40/farmui2_v_58 库，无一指向 farmui1；
	 *  - 结论：农场侧不用 farmui1_v_42。它是牧场专属的 UI 素材+帧脚本库
	 *    （110 类的成分考证待牧场批次开工时做——本 issue 只定级不开工，
	 *    牧场整体不开工是 issue 边界）。
	 *
	 *  【活跃判定】牧场现役（随 Master2 启动必加载）；农场侧不活跃
	 *  （无任何链路到达）。牧场入口本身是用户主动进牧场（main3
	 *  FarmApplication.as:207 onEnterPasture → mcloader 链），农场运行期
	 *  不触碰。
	 *
	 *  【定级建议】**归牧场批次**——农场侧排查结论排除了「单独定级」的
	 *  唯一理由（若农场也用才需要提前单独处理）；它留在 baseline
	 *  mc/main/* 族账内（本 issue 已把农场侧结论写进族 reason），牧场
	 *  批次开工时与 farmui2_v_44/commonui_v_12 等同族一并进 main_swfs
	 *  或专项立项。 */
	public static var FARMUI1_V_42:String = "【farmui1_v_42.swf 考证结论（issue #67，2026-11-25）】引用出处：mc_main.php:21 `<material url=\"$url/module/mc/main/farmui1_v_42.swf\"/>`——牧场主模块 Master2_v_142（mc_main.php:20）material 素材预载第 1 位（URL 表配置 key），牧场现役复核无误。农场侧排查（定级关键）：nc_main.php 全文无 farmui1（农场 material 仅 farmui_full_v_40/farmui2_v_58/water_ui_v_0 三件，nc_main.php:11-13）；decompiled/main3_v_221/scripts/ 全文 grep 零命中，happyfarm3_v_149/mcloader_v_53/Master2_v_142 及全部 50 个在册 decompiled/*/scripts/ 均零命中；农场符号 shim（src/*.hx）全部绑 farmui_full/farmui2 无一指 farmui1——农场侧不用。110 类成分考证留牧场批次（issue 边界：牧场不开工）。活跃判定：牧场现役（随 Master2 启动加载）、农场侧不活跃（无链路到达；牧场入口是用户主动进牧场 FarmApplication.as:207 onEnterPasture）。定级建议：归牧场批次——农场侧排查排除了单独定级的唯一理由；留 baseline mc/main/* 族账内（农场侧结论已写进族 reason），牧场批次开工时与 farmui2_v_44/commonui_v_12 同族一并进 main_swfs 或专项立项。";

	public function new() {}
}

package framework.net;

/**
 * framework.net.CommandDefs —— write-tests stub（issue #7）：常量表本体就是
 * 这个类的全部内容，这里照抄测试引用到的常量（值逐字来自
 * legacy/decompiled/main3_v_221/scripts/framework/net/CommandDefs.as，行号见
 * 各分组注释），其余常量在翻译阶段补齐。
 */
@:final
class CommandDefs {
	// CommandDefs.as:6-10（HTTP_ERR_*，int）
	public static final HTTP_ERR_IOERROR:Int = -100;
	public static final HTTP_ERR_HTTPSTATUS:Int = -101;
	public static final HTTP_ERR_TIMEOUT:Int = -102;

	// CommandDefs.as:12-16（启动/校验，uint）
	public static final CMD_GET_BOOT_DATA:UInt = 1;
	public static final CMD_RELOAD_GAME_DATA:UInt = 1;
	public static final CMD_CHECK_MILL_RIGHTS:UInt = 2;

	// CommandDefs.as:18-40（farmlandstatus 操作与 getOutput，uint）
	public static final CMD_OPERATE_WATER:UInt = 10;
	public static final CMD_OPERATE_CLEARWEED:UInt = 11;
	public static final CMD_OPERATE_ADDWEED:UInt = 12;
	public static final CMD_OPERATE_ADDBUG:UInt = 13;
	public static final CMD_OPERATE_CLEARBUG:UInt = 14;
	public static final CMD_OPERATE_HARVEST:UInt = 16;
	public static final CMD_OPERATE_SCARIFY:UInt = 17;
	public static final CMD_OPERATE_PLANT:UInt = 18;
	public static final CMD_OPERATE_FERTILIZE:UInt = 19;
	public static final CMD_OPERATE_CHECKSTATUS:UInt = 20;
	public static final CMD_OPERATE_SCROUNGE_NEW:UInt = 21;
	public static final CMD_GET_OUTPUT:UInt = 31;

	// CommandDefs.as:42-86（商店/仓库/系统消息等，uint）
	public static final CMD_GET_BAG_DATA:UInt = 32;
	public static final CMD_GET_SHOP_SEED:UInt = 33;
	public static final CMD_GET_SYSTEM_POST_MSG:UInt = 43;
	public static final CMD_GET_SYSTEM_MSG:UInt = 53;
	public static final CMD_GET_WAREHOUSE_CRYSTAL:UInt = 55;

	// CommandDefs.as:112-146（开垦/红地/清 feed，uint）
	public static final CMD_RECLAIM_CONDITION:UInt = 83;
	public static final CMD_RECLAIM_PAY:UInt = 84;
	public static final CMD_UPGRADE_RED:UInt = 85;
	public static final CMD_CLEAR_ALL_FEEDS:UInt = 104;

	// CommandDefs.as:190-254（鱼塘/白名单/活动灰度/广告，值与 int/uint 原样）
	public static final CMD_GET_FISHES:Int = 300;
	public static final WHITE_LIST:Int = 400;
	public static final CMD_ACTIVITY_GRAY:Int = 501;
	public static final CMD_WB_PROFILE:Int = 500;
	public static final CMD_GET_SNS_AD:UInt = 52;
	public static final CMD_SET_ADSEED_COOKIE:UInt = 66;
}

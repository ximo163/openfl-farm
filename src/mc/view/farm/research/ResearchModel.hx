package mc.view.farm.research;

import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;

/**
 * mc.view.farm.Research.ResearchModel —— ResearchModel.as 的签名面 stub
 * （原类 619 loc，归「科研所」子系统后续片充真身——spec/modules/pasture.json
 * 科研所条目；issue #87 只保 GetCropID.idToDiyUrl2 编译链用到的成员面：
 * gi/UpdataW2/UpdataP2/canGetDenAnimal/canGetShedAnimal，签名逐字取自
 * 反编译原文、行号对应 ResearchModel.as）。其余成员（含 UpdataW2/UpdataP2
 * 的 setter——原文带 ResearchEvent 派发，事件类同属科研所片）随科研所片
 * 补全，本 stub 整体届时由该片的真身替换。
 * legacy/decompiled/Master2_v_142/scripts/mc/view/farm/Research/ResearchModel.as。
 *
 * PORT-NOTE(命名)：原包 `mc.view.farm.Research` 的 Research 段首字母大写，
 * Haxe 包段必须小写开头，落 `research`（类名不变——lessons 的
 * windowControl/monthend 同款先例，deviations 候选）。
 * PORT-NOTE：gi 的调用在 idToDiyUrl2 里不可空（`int(_loc4_) > 8` 才进
 * 分支、生产 gi() 恒非 null）——单例骨架本身无外部依赖，按原文译出；
 * 四位成员体空（抛 not implemented），idToDiyUrl2 的 lv>8 科研态分支
 * 在科研所片落地前不可达（调用方养殖场装饰加载链同属后续片）。
 */
@:keep
class ResearchModel extends EventDispatcher {
	// ResearchModel.as:16（原文拼写 intence，照抄）
	private static var intence:ResearchModel;

	// ResearchModel.as:111/121（backing）
	private var _updataW2:Array<Dynamic>;
	private var _updataP2:Array<Dynamic>;

	// ResearchModel.as:189-193（ctor(param1:IEventDispatcher = null)——
	// 原文还建 ResearchController(:191)，科研所片依赖，stub 略）
	public function new(param1:IEventDispatcher = null) {
		super(param1);
	}

	// ResearchModel.as:195-202
	public static function gi():ResearchModel {
		if (intence == null) {
			intence = new ResearchModel();
		}
		return intence;
	}

	// ResearchModel.as:398-401
	public var UpdataW2(get, never):Array<Dynamic>;

	private function get_UpdataW2():Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// ResearchModel.as:465-468
	public var UpdataP2(get, never):Array<Dynamic>;

	private function get_UpdataP2():Array<Dynamic> {
		throw new openfl.errors.Error("not implemented");
	}

	// ResearchModel.as:486-496
	public function canGetDenAnimal(param1:Int):Bool {
		throw new openfl.errors.Error("not implemented");
	}

	// ResearchModel.as:558-568
	public function canGetShedAnimal(param1:Int):Bool {
		throw new openfl.errors.Error("not implemented");
	}
}

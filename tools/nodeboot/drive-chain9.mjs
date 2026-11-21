// drive-chain9 —— issue #9「种收交互」本地全链驱动（nodeboot --drive 专用，
// 与 boot 同进程同 globalThis，经 shim.Harness 挂的 __openflFarmDrive 句柄拿
// stage 与 MouseEvent/KeyboardEvent——构建产物把 Haxe 类全关进 lime 的 IIFE
// 闭包，node 侧够不到 openfl.events.* 构造器）。CI web-smoke 只等
// __openflFarmReady 不点鼠标（harness/smoke.mjs），#9 的操作链证据在这里补。
//
// 点击的派发语义（踩过的坑，别改回直点 LandItemRender）：FarmLandsView 把
// CLICK 监听 useCapture=true 注册在地块项上（FarmLandsView.hx:143），openfl
// 的 at-target 阶段只放非捕获监听（EventDispatcher.__dispatchEvent 按
// `listener.useCapture == (phase == CAPTURING)` 过滤），直点 LandItemRender
// 一枪不发；真实鼠标命中的是 LandTile 挂在地块项下的底图子节点，监听在
// 捕获阶段触发、currentTarget==地块项（onMouseEvent 的 CLICK 分支正按
// currentTarget 判 __FarmlandItem__，target 只用来分 __reclaim__）——所以
// 这里点「地块项的底图子节点」等价于真实命中。
//
// 链路与出处（应答数值全部按 legacy PHP 对 fixture 地块 0/2 的真实取值）：
//  1 收：点工具条「收获」ToolHand（ToolBar TOOLS 表，DefineButton2 →
//      SimpleButton 垫片）→ setCursor(CURSOR_STYLE_HAND) → 点成熟地块 0
//      （user-run fixture a=2 白萝卜 b=6；白萝卜 cropGrow="7200,14400,25200,
//      36000,36000,2000000000"（nc_data.php:6021）、q 距 serverTime 36030s
//      ≥36000 → FarmLand.importObject 里 idState=5 成熟）→ mync
//      mod=farmlandstatus&act=harvest（POST place=0，buildCommonPostParams）
//      → 应答按 farmlandstatus_harvest.php:95 echo（exp=15 harvest=16
//      status.cropStatus=7——j+1==maturingTime=1 走 b=7 分支，cropstype.php:5
//      cropExp=15）→ copyFrom 落 _cropStatus=7；EVENT_HARVEST_DATA →
//      FarmLandsView.onHarvestData → openFloat → HarvestAnimation 飘字挂树。
//  2 锄：ToolHoe → CursorHoe → 等 growLoop（CountDown(10) 一拍）把收后地块
//      的 _step 重算成 7（idState 见 cropStatus==7 直回 7）再点——
//      operate_scarify :290-291 _step==6||7 直走 executeScarify 不弹确认窗
//      → act=scarify → 应答按 farmlandstatus_scarify.php:66 →
//      onOperateSuccessSacrify 落 _cId=0。
//  3 种：CursorControl.setCursor(CURSOR_STYLE_CROPSEED, "1,2")（原版同一
//      入口在背包选种——repertory 模块 swf，不在 #9 清单、未移植；
//      FarmLandController.clickOnLand 的 CROPSEED 分支只认 cursorArgument
//      "1,<cId>"，Consts.ITEM_TYPE_SEED=="1"）→ 点空地块 0 → act=planting
//      （POST cId=2）→ 应答按 farmlandstatus_planting.php:79 →
//      onOperateSuccessPlant 落 _cId=2、EVENT_LAND_CHANGED → updateLandItem
//      → 长出 Crop 实例（module.mainScene.farmLand.widgets.Crop）。
//  4 浇：stage keyUp Q（ToolBar.onKeyUp :339 的 Q → 浇水光标，键盘链与按钮
//      链二选一都能到）→ 点干旱地块 2（fixture a=2 b=1 h=0）→ act=water
//      （POST place=2）→ 应答按 farmlandstatus_water.php:65（humidity=1）→
//      farmChange 落 _humidity=1。
// 每步都断言 myncLog 里出现了对应请求（URL+POST body）且模型/显示树真的
// 变了；全程 nodeboot 的 uncaughtException / 缺失资源兜底照常生效。

export default async function chain(ctx) {
  const g = globalThis;
  const { myncLog, sleep } = ctx;
  const log = (...a) => console.log("[drive9]", ...a);
  let failures = 0;
  const assert = (ok, msg) => {
    log((ok ? "OK   " : "FAIL ") + msg);
    if (!ok) failures++;
  };

  // shim.Harness 挂的驱动句柄（见其头注）：产物把类关进 IIFE 闭包，node 侧
  // 只有这里能拿到 stage 与 MouseEvent/KeyboardEvent 构造器
  const hd = g.__openflFarmDrive;
  if (!hd || !hd.stage) {
    log("FAIL __openflFarmDrive 句柄缺失（shim/Harness.hx 未生效？）");
    return 1;
  }
  const MouseEvent = hd.MouseEvent;
  const KeyboardEvent = hd.KeyboardEvent;
  const stage = hd.stage;

  const walk = (o, fn, depth) => {
    if (!o || depth > 60) return;
    fn(o);
    for (const k of o.__children || []) walk(k, fn, depth + 1);
  };
  // 类匹配走 __class__.__name__（bundle 闭包外拿不到类对象本身）
  const findByClassName = (name) => {
    const out = [];
    walk(stage, (o) => {
      if (o.__class__ && o.__class__.__name__ === name) out.push(o);
    }, 0);
    return out;
  };
  const waitFor = async (pred, ms) => {
    const end = Date.now() + ms;
    while (Date.now() < end) {
      if (pred()) return true;
      await sleep(100);
    }
    return pred();
  };
  const countFloats = () => {
    let n = 0;
    walk(stage, (o) => {
      if (o.__class__ && String(o.__class__.__name__).match(/Floating|Harvest/)) n++;
    }, 0);
    return n;
  };

  const toolBar = findByClassName("module.uitools.widgets.ToolBar")[0];
  const landsView = findByClassName("module.mainScene.farmLand.FarmLandsView")[0];
  assert(toolBar && landsView, "启动后显示树里有 ToolBar / FarmLandsView");
  if (!(toolBar && landsView)) return 1;

  // 光标/模型经 FarmLandsView.m_controller（FarmLandController：m_module/m_model，
  // 与原版字段同名，js 产物未改名）
  const ctrlOf = () => landsView.m_controller.m_module.get_app().get_farmView().get_cursorCtrl();
  const model = () => landsView.m_controller.m_model;
  const landOf = (i) => landsView.m_items.find((it) => it.get_index() === i);
  const clickOn = (o) => o.dispatchEvent(new MouseEvent("click"));
  // 点「地块项的底图子节点」（见文件头注的派发语义）。__reclaim__ 是荒地开垦
  // 板（onMouseEvent CLICK 分支单独分走）；Crop/Byproduct 之外的第一个子节点
  // 即 LandTile 底图。
  const clickLand = (land) => {
    const kids = (land.__children || []).filter(Boolean);
    const soil = kids.find((c) => c.parent === land && c.name !== "__reclaim__"
      && !String(c.__class__ ? c.__class__.__name__ : "").match(/Crop$|Byproduct/));
    if (!soil) {
      throw new Error("地块项下没有可点子节点（LandTile 底图缺失？）："
        + kids.map((c) => `${c.__class__ && c.__class__.__name__}:${c.name}`).join(", "));
    }
    soil.dispatchEvent(new MouseEvent("click"));
  };
  const landState = (i) => {
    const f = model().m_farmlandData[i];
    return `_cId=${f._cId} _cropStatus=${f._cropStatus} _step=${f._step} _humidity=${f._humidity}`;
  };
  // POST body 容两种编码（URLVariables 的 k=v / JSON 的 "k":"v"）
  const hasParam = (body, k, v) =>
    body.includes(`${k}=${v}`) || body.includes(`"${k}":"${v}"`) || body.includes(`"${k}":${v}`);
  const reqFor = (act) => myncLog.find((r) => r.url.includes("mod=farmlandstatus") && r.url.includes(`act=${act}`));
  const awaitReq = (act, ms) => waitFor(() => reqFor(act) != null, ms);

  const land0 = landOf(0);
  assert(land0 != null, "找到地块 0（LandItemRender.index）");
  if (land0 == null) return 1;
  const land2 = landOf(2);
  log("   起始状态 land0:", landState(0), "| land2:", landState(2));

  // ---------------------------------------------------------------- 1 收
  log("-- 收：ToolHand 按钮 → CursorHand → 点成熟地块 0");
  assert(model().m_farmlandData[0]._cId === 2 && model().m_farmlandData[0]._cropStatus === 6
    && model().m_farmlandData[0]._step === 5, "地块 0 是成熟白萝卜（a=2 b=6，_step==5）");
  assert(ctrlOf().get_name() !== "CursorHand", "起点光标不是 CursorHand");
  const floats0 = countFloats();
  clickOn(toolBar._tools[1]); // TOOL_HAND=1（ToolBar.as TOOLS 表）
  assert(ctrlOf().get_name() === "CursorHand", "点击「收获」按钮后光标切到 CursorHand");
  clickLand(land0);
  const harvestReq = await awaitReq("harvest", 5000);
  assert(harvestReq, "发出 mync mod=farmlandstatus&act=harvest");
  if (harvestReq) {
    log("   请求体：", reqFor("harvest").body.replace(/\s+/g, " ").slice(0, 160));
    assert(hasParam(reqFor("harvest").body, "place", "0"), "harvest 请求体带 place=0");
  }
  // copyFrom(status.cropStatus=7) 落地后才算应答处理完
  const harvested = await waitFor(() => model().m_farmlandData[0]._cropStatus === 7, 5000);
  assert(harvested, "应答落地：地块 0 _cropStatus==7（收一次进 b=7，仍占位）");
  // EVENT_HARVEST_DATA → openFloat → HarvestAnimation 飘字（对起始快照增量）
  const floatSeen = await waitFor(() => countFloats() > floats0, 5000);
  assert(floatSeen, "收获飘字挂上显示树（HarvestAnimation/Floating，比起点多）");

  // ---------------------------------------------------------------- 2 锄
  log("-- 锄：ToolHoe 按钮 → CursorHoe → 点 b=7 地块 0（_step==7 直走不弹窗）");
  clickOn(toolBar._tools[3]); // TOOL_HOE=3
  assert(ctrlOf().get_name() === "CursorHoe", "点击「锄头」按钮后光标切到 CursorHoe");
  // growLoop（FarmLandController.n 的 CountDown(10) 一拍）才会把 _step 从 5
  // 重算成 7——没等到就点会走 EVENT_CONFIRM_SCARIFY 弹窗分支
  const step7 = await waitFor(() => model().m_farmlandData[0]._step === 7, 20000);
  assert(step7, "收后 _step 经 growLoop 重算成 7（idState 对 cropStatus==7 直回 7）");
  clickLand(land0);
  const scarifyReq = await awaitReq("scarify", 5000);
  assert(scarifyReq, "发出 mync mod=farmlandstatus&act=scarify");
  if (scarifyReq) {
    log("   请求体：", reqFor("scarify").body.replace(/\s+/g, " ").slice(0, 160));
  }
  const cleared = await waitFor(() => model().m_farmlandData[0]._cId === 0, 5000);
  assert(cleared, "应答落地：地块 0 清空（_cId==0）");

  // ---------------------------------------------------------------- 3 种
  log("-- 种：CursorCropSeed(\"1,2\") → 点空地块 0");
  ctrlOf().setCursor("CursorCropSeed", "1,2"); // Consts.CURSOR_STYLE_CROPSEED / ITEM_TYPE_SEED=="1"，背包选种同一入口
  assert(ctrlOf().get_name() === "CursorCropSeed", "光标切到 CursorCropSeed（带种子参数）");
  clickLand(land0);
  const plantReq = await awaitReq("planting", 5000);
  assert(plantReq, "发出 mync mod=farmlandstatus&act=planting");
  if (plantReq) {
    log("   请求体：", reqFor("planting").body.replace(/\s+/g, " ").slice(0, 160));
    assert(hasParam(reqFor("planting").body, "cId", "2"), "播种请求体带 cId=2（白萝卜）");
  }
  const planted = await waitFor(() => model().m_farmlandData[0]._cId === 2, 5000);
  assert(planted, "应答落地：地块 0 _cId==2（新白萝卜）");
  // EVENT_LAND_CHANGED → updateLandItem → createCrop（LandItemRender addChildAt）
  const cropSeen = await waitFor(() => (land0.__children || []).some((c) => c.__class__
    && c.__class__.__name__ === "module.mainScene.farmLand.widgets.Crop"), 5000);
  assert(cropSeen, "地块 0 上长出 Crop 实例（module...widgets.Crop）");

  // ---------------------------------------------------------------- 4 浇
  log("-- 浇：stage keyUp Q → CursorWater → 点干旱地块 2");
  stage.dispatchEvent(new KeyboardEvent("keyUp", true, false, 0, 81)); // 'Q'
  assert(ctrlOf().get_name() === "CursorWater", "Q 键后光标切到 CursorWater");
  assert(land2 != null && model().m_farmlandData[2]._humidity === 0
    && model().m_farmlandData[2]._cId !== 0, "地块 2 干旱（h=0 且有苗，canHandler 放行）");
  if (land2 == null) return 1;
  clickLand(land2);
  const waterReq = await awaitReq("water", 5000);
  assert(waterReq, "发出 mync mod=farmlandstatus&act=water");
  if (waterReq) {
    log("   请求体：", reqFor("water").body.replace(/\s+/g, " ").slice(0, 160));
    assert(hasParam(reqFor("water").body, "place", "2"), "浇水请求体带 place=2");
  }
  const wet = await waitFor(() => model().m_farmlandData[2]._humidity === 1, 5000);
  assert(wet, "应答落地：地块 2 _humidity==1（farmChange 按 farmlandstatus_water.php:65）");

  log(failures === 0 ? "[drive9] 全链 PASS：收→锄→种→浇" : `[drive9] ${failures} 个断言失败`);
  return failures === 0 ? 0 : 1;
}

# 网络层

命令派发 → 请求 → 返回解析的链路。#7（V3a）翻译时核实。

## 链路

- 发起：业务类 `theApp.run(CommandList.<CMD>, params, ...)` →
  `Utils.buildRequest`（NET_HTTP_METHOD_GET）→ ServiceRequest /
  HttpOperationEx → 回派 `CommandEvent`。
- 解析：各 parser（`src/framework/net/parsers/`）产
  `ServiceResultVO`；`NetHelper.getVOData`（NetHelper.as:77-93）：
  `result as ServiceResultVO`，null 时 `result is Array` 直接回数组，
  否则 null。
- 协议规则权威在 `legacy/deploy/` 的 PHP（mync.php / nc_main.php /
  nc_addon.php 等，入口见 `legacy/manifest.json`）。mod 参数拼装、返回
  字段的测试期望值必须带 PHP 出处。

## 约定（都是踩过坑的）

- **JSON 解析一律走 `com.adobe.serialization.json.JSON.decode` 门面**
  （as3corelib 宽松语义 + 串内控制字符消毒）。直连 `haxe.Json.parse` 在
  html5 上是 V8 严格模式，真后端 80KB 配置里的裸控制字符直接抛异常
  （#7 web-smoke 红了两轮才定位）；`checks/json-facade-only.sh` 在
  verify 里拦直连。
- **eval 目标裸 `cast` 不做运行时检查**：AS3 `x as T` 失配返回 null 的
  语义要译成 `Std.isOfType` 门 + 直取（#7 review-impl round 1 的驳回点，
  NetHelper.hx:75），后面的回退分支必须保持可达。
- 测试 fixture 从 `legacy/snapshot/` 的真实下发抽（裁剪可、改内容不可），
  自编的干净 JSON 查不出脏数据问题。

## cpp 目标的基址改写（#10 android / #64 linux，同族两分支）

原版相对 *.php 靠 Flash 播放器「按 swf 所在 URL 解析」到同站后端；cpp 目标
的网络栈是 lime/curl，没有「源」也没有可包装的 XHR 边界——只能在 URL 进
网络前显式改写，三个落点各司其职：

- **flashvar 注入时改写 config 三件**（`src/shim/FlashVars.hx`）：config_url/
  config_data/config_addon 在 inject 时直接改成绝对地址——xml.php 走
  LoadManager 的裸 URLLoader，不改在这里就没有第二道门。android 基址经
  `AndroidBackend.resolveBase`（flashvar farm_backend 覆盖优先），linux 基址
  经环境变量 `QFARM_BASE_URL`（`SwfUrlBase.BASE_URL_ENV` 常量钉死单点，
  冒烟脚本设置侧同读）。
- **CGI 出口改写**（`src/shim/AndroidHttpRequest.hx`）：mync.php 族运行时拼
  的 URL 在 send() 前改写。类名带 Android 但 `#if linux` 分支同样挂这——
  构造点统一（CmdHttpRequest 不换名），改写分支按目标编译，行为互不影响。
- **改写契约三处同款**（`SwfUrlBase.resolve`/`resolveCpp`、
  `AndroidBackend.rebase`）：只动「相对的 *.php」（无 scheme、不以 / 或 #
  开头、? 之前的路径以 .php 结尾），拼到 `<base>/home/qqfarm/core/`——
  build.sh:40 的部署事实在这三处各有一份拷贝，动一处必须三处同动。
  base 缺位（android 不可能——DEFAULT_BASE 兜底；linux 是 QFARM_BASE_URL
  没设）原样透传，行为不变。

cpp linux 冒烟（`tools/cpp-boot-smoke.sh`，#64）就是这条链的机器验收：
QFARM_BASE_URL 指到 CI 后端，xvfb 起二进制走启动链，断言无 Invalid field
/Uncaught exception/Called from。判定纯逻辑在 `tools/tools/BootSmokeVerdict.hx`
（bash 只剩进程编排，与 CppTyperScan 同款分层）。

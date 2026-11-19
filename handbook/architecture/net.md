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

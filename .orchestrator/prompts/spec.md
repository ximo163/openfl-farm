从 legacy/ 提取规格，写进 spec/。只能改 spec/。先读 CLAUDE.md，再读
`legacy/manifest.json` 找到要读的文件。

- spec/ 下的文件都是 JSON，顶层带 `"version": 1`，`checks/spec-valid.sh` 会检查。
- 规格只描述原版**是什么**，不做设计。每一条都带 `source` 字段，写明出处（如
  `"legacy/deploy/QFarmFlash/source/core/mync.php farmlandstatus_harvest 分支"`，
  或 `"legacy/decompiled/.../main3/scripts/xxx.as: onTileClick"`）。
- 推不确定的地方不要猜：用 `"unknown": "<说明>"` 标出来。
- 需要设计决定的规格（`spec/interaction-map.json` 里触屏交互的做法）按 issue 给出
  的默认规则生成，每一条加 `"approved": false`，表示等人最终确认。
- 数值、公式、枚举照原样抄，不换单位、不取整；原版用帧数的就写帧数并注明帧率。
  PHP 里的中文键名照抄。
- `spec/modules/*.json` 的模块拆分以 issue 给的模块表为准；每个反编译类恰好归入
  一个模块，不移植的类归入 `ignored` 并写理由。
- 只读需要的部分：先 `rg -n` 找名字，再读附近的行。mod 分发在 `mync.php`/`mymc.php`
  的 mod_list，实现在 `source/nc(mod)/mod/` 下的同名文件。
- 最后的回答里列出新增或修改的规格文件，以及标成 unknown 的条目。

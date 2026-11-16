#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 生成资产 swf 清单 spec/swf-inventory.json：遍历 legacy/deploy/QFarmFlash/source/core/module/
# 下的全部 swf，按命名规律归类（作物/动物/界面/装饰/活动……），读出头部的帧率、帧数、
# 舞台尺寸。6270 个资产不反编译（走 openfl/swf 库原样消费），这个清单是它们唯一的索引，
# 也是 tools/check-asset-refs（后置）做引用对账的输入。
#
# 只用标准库。用法：python3 scripts/swf-inventory.py [--root legacy/deploy/QFarmFlash/source/core/module]
#                  [--out spec/swf-inventory.json]
import argparse
import json
import os
import re
import struct
import sys
import zlib


def read_header(path):
    """读 swf 头：返回 (fps, frames, stage_w, stage_h) 或 None（解不开不中断）。"""
    try:
        with open(path, "rb") as f:
            head = f.read(8)
            if len(head) < 8:
                return None
            if head[:3] == b"CWS":
                body = zlib.decompress(f.read())
                data = b"FWS" + head[3:8] + body  # 解压后按未压缩 swf 解析头部
            elif head[:3] == b"FWS":
                f.seek(0)
                data = f.read(64)
            else:
                return None
        # 解析 RECT（位字段）：5 位 nbits + 4 个 nbits 位的坐标（twips）
        pos = 8
        b0 = data[pos]
        nbits = b0 >> 3
        total_bits = 5 + nbits * 4
        total_bytes = (total_bits + 7) // 8
        rect_end = pos + total_bytes
        vals = []
        acc = 0
        acc_bits = 0
        for byte in data[pos:rect_end]:
            acc = (acc << 8) | byte
            acc_bits += 8
        acc >>= acc_bits - total_bits       # 去掉尾部填充位
        acc &= (1 << (4 * nbits)) - 1       # 去掉开头的 5 位 nbits 字段
        for i in range(4):
            vals.append((acc >> (nbits * (3 - i))) & ((1 << nbits) - 1))
        xmin, xmax, ymin, ymax = vals
        # 帧率（8.8 定点）和总帧数在 RECT 之后
        fps_raw, frames = struct.unpack("<HH", data[rect_end:rect_end + 4])
        return {
            "fps": fps_raw >> 8,
            "frames": frames,
            "stage": [ (xmax - xmin) // 20, (ymax - ymin) // 20 ],
        }
    except Exception:
        return None


def categorize(rel):
    """按目录和命名规律归类。rel 相对 module/。"""
    parts = rel.replace("\\", "/").split("/")
    name = parts[-1]
    if parts[0] == "ui":
        if "allcrops" in parts:
            return "crop"
        if re.match(r"^Crop_\d+_", name):
            return "crop"
        return "ui"
    if parts[0] == "mc":
        if "aswf" in parts and re.match(r"^a\d+", name):
            return "animal"
        return "mc"
    if parts[0] == "plugin":
        return "plugin"
    return "module"  # 主代码 swf 和活动目录（wildAdv/collect/labor）


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default="legacy/deploy/QFarmFlash/source/core/module")
    ap.add_argument("--out", default="spec/swf-inventory.json")
    args = ap.parse_args()

    items = []
    bad = []
    for dirpath, _dirs, files in os.walk(args.root):
        for fn in sorted(files):
            if not fn.lower().endswith(".swf"):
                continue
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, args.root).replace("\\", "/")
            h = read_header(full)
            entry = {
                "path": "module/" + rel,
                "bytes": os.path.getsize(full),
                "category": categorize(rel),
            }
            if h:
                entry.update(h)
            else:
                entry["unparsed"] = True
                bad.append(entry["path"])
            items.append(entry)

    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump({"version": 1, "source": args.root, "count": len(items), "swfs": items},
                  f, ensure_ascii=False, indent=1)
    cats = {}
    for it in items:
        cats[it["category"]] = cats.get(it["category"], 0) + 1
    print("swf-inventory: {} 个 swf -> {}（分类：{}；头部解不开 {} 个）".format(
        len(items), args.out, ", ".join(f"{k}={v}" for k, v in sorted(cats.items())), len(bad)))
    for p in bad[:10]:
        print("  解不开：", p)
    return 0


if __name__ == "__main__":
    sys.exit(main())

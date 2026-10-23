#!/usr/bin/env python3
"""从原始素材生成 App 资源：四种水果抠图 PNG + App 图标(.icns)。

用法: python3 prepare_assets.py
"""
import os
from collections import deque
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
FRUIT_SHEET = os.path.join(HERE, "fruits.jpg")
COVER = os.path.join(HERE, "cover.jpg")
OUT_DIR = os.path.join(HERE, "fruits")

# 素材是 3x3 网格，但水果会溢出单元格边界，因此按实测像素框精确裁切。
FRUIT_BOXES = {
    "pineapple": (350, 5, 535, 225),     # 右上
    "strawberry": (360, 222, 540, 352),  # 右中（两颗）
    "avocado": (350, 344, 552, 542),     # 右下
    "watermelon": (28, 338, 192, 536),   # 左下
}


def key_background(img, tol=26.0):
    """从四边泛洪去掉纯色背景，边缘做 1.2px 羽化。"""
    img = img.convert("RGB")
    w, h = img.size
    px = img.load()
    bg = px[0, 0]
    bg_rgb = (bg[0], bg[1], bg[2])
    visited = bytearray(w * h)
    q = deque()

    def near(x, y):
        r, g, b = px[x, y]
        d = ((r - bg_rgb[0]) ** 2 + (g - bg_rgb[1]) ** 2 + (b - bg_rgb[2]) ** 2) ** 0.5
        return d < tol

    for x in range(w):
        for y in (0, h - 1):
            if near(x, y) and not visited[y * w + x]:
                visited[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if near(x, y) and not visited[y * w + x]:
                visited[y * w + x] = 1
                q.append((x, y))

    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny * w + nx] and near(nx, ny):
                visited[ny * w + nx] = 1
                q.append((nx, ny))

    mask = Image.new("L", (w, h), 255)
    mp = mask.load()
    for i, v in enumerate(visited):
        if v:
            mp[i % w, i // w] = 0
    mask = mask.filter(ImageFilter.GaussianBlur(1.2))

    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def drop_neighbor_fragments(img, min_ratio=0.30):
    """网格单元格之间有溢出：丢掉贴着边且明显很小的连通块（邻居水果的碎片）。"""
    w, h = img.size
    alpha = img.getchannel("A")
    ap = alpha.load()
    seen = bytearray(w * h)
    comps = []
    for y0 in range(h):
        for x0 in range(w):
            idx = y0 * w + x0
            if seen[idx] or ap[x0, y0] < 12:
                continue
            comp = []
            q = deque([(x0, y0)])
            seen[idx] = 1
            touches = False
            while q:
                x, y = q.popleft()
                comp.append((x, y))
                if x <= 1 or y <= 1 or x >= w - 2 or y >= h - 2:
                    touches = True
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h:
                        ni = ny * w + nx
                        if not seen[ni] and ap[nx, ny] >= 12:
                            seen[ni] = 1
                            q.append((nx, ny))
            comps.append((comp, touches))
    if not comps:
        return img
    largest = max(len(c) for c, _ in comps)
    keep = [c for c, touches in comps if not touches or len(c) >= largest * min_ratio]
    if len(keep) == len(comps):
        return img
    mask = Image.new("L", (w, h), 0)
    mp = mask.load()
    for comp in keep:
        for x, y in comp:
            mp[x, y] = 255
    out = img.copy()
    out.putalpha(Image.composite(img.getchannel("A"), Image.new("L", (w, h), 0), mask))
    return out


def trim(img, pad=6):
    bbox = img.getbbox()
    if not bbox:
        return img
    l, t, r, b = bbox
    l, t = max(0, l - pad), max(0, t - pad)
    r, b = min(img.width, r + pad), min(img.height, b + pad)
    return img.crop((l, t, r, b))


def build_fruits():
    os.makedirs(OUT_DIR, exist_ok=True)
    sheet = Image.open(FRUIT_SHEET).convert("RGB")
    for name, box in FRUIT_BOXES.items():
        cell = sheet.crop(box)
        cut = trim(drop_neighbor_fragments(key_background(cell)))
        # 统一到不超过 380px 长边，保留细节
        scale = min(1.0, 380.0 / max(cut.size))
        if scale < 1.0:
            cut = cut.resize((round(cut.width * scale), round(cut.height * scale)), Image.LANCZOS)
        path = os.path.join(OUT_DIR, f"{name}.png")
        cut.save(path)
        print(f"{name:11s} {cell.size} -> {cut.size} -> {path}")


def build_icon():
    cover = Image.open(COVER).convert("RGB")
    cream = cover.getpixel((2, 2))
    canvas = Image.new("RGB", (1024, 1024), cream)
    art = cover.resize((1024, 1024), Image.LANCZOS).filter(
        ImageFilter.UnsharpMask(radius=2.0, percent=60, threshold=2))
    canvas.paste(art, (0, 0))
    iconset = os.path.join(HERE, "AppIcon.iconset")
    os.makedirs(iconset, exist_ok=True)
    for size in (16, 32, 64, 128, 256, 512):
        for suffix in ("", "@2x"):
            px = size * (2 if suffix else 1)
            im = canvas.resize((px, px), Image.LANCZOS)
            im.save(os.path.join(iconset, f"icon_{size}x{size}{suffix}.png"))
    canvas.save(os.path.join(HERE, "icon_1024.png"))
    print("icon sources ready:", iconset)


if __name__ == "__main__":
    build_fruits()
    build_icon()

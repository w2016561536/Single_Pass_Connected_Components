import re
import cv2
import numpy as np


def parse_components(txt_path):
    """
    解析 txt 文件中的组件信息。
    每行格式示例：
    Component 0: area=246, xc=233, yc=28, xmin=201, xmax=266, ymin=15, ymax=42
    """
    pattern = re.compile(
        r"Component\s+\d+:\s*"
        r"area=(\d+),\s*"
        r"xc=(\d+),\s*"
        r"yc=(\d+),\s*"
        r"xmin=(\d+),\s*"
        r"xmax=(\d+),\s*"
        r"ymin=(\d+),\s*"
        r"ymax=(\d+)"
    )

    components = []
    with open(txt_path, "r", encoding="utf-8") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue

            match = pattern.search(line)
            if not match:
                print(f"警告：第 {line_num} 行格式无法解析，已跳过：{line}")
                continue

            area, xc, yc, xmin, xmax, ymin, ymax = map(int, match.groups())
            components.append({
                "area": area,
                "xc": xc,
                "yc": yc,
                "xmin": xmin,
                "xmax": xmax,
                "ymin": ymin,
                "ymax": ymax,
            })

    return components


def annotate_image(image_path, txt_path, output_path, scale=4):
    """
    根据 txt 中的边界框信息对图像进行标注。
    要求：
    - 标注前图像放大 4 倍
    - 外框相对原始标注区域四周扩大 1 像素
    - 中心点画点
    - area > 100 时，将面积数字写入框内
    """
    image = cv2.imread(image_path)
    if image is None:
        raise FileNotFoundError(f"无法读取图片：{image_path}")

    components = parse_components(txt_path)
    if not components:
        raise ValueError("未从 txt 文件中解析到任何有效组件信息。")

    h, w = image.shape[:2]

    # 先放大图像 4 倍
    enlarged = cv2.resize(
        image,
        (w * scale, h * scale),
        interpolation=cv2.INTER_CUBIC
    )

    H, W = enlarged.shape[:2]

    # 一些绘图参数，可按需调整
    rect_color = (0, 255, 0)      # 绿色框
    center_color = (0, 0, 255)    # 红色中心点
    text_color = (255, 0, 0)      # 蓝色文字
    rect_thickness = max(1, scale)   # 放大后适当加粗
    point_radius = max(2, scale)
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.6 * scale / 2
    text_thickness = max(1, scale // 2)

    for comp in components:
        area = comp["area"]
        xc = comp["xc"]
        yc = comp["yc"]
        xmin = comp["xmin"]
        xmax = comp["xmax"]
        ymin = comp["ymin"]
        ymax = comp["ymax"]


        # 原框四周扩大 1 像素
        xmin_exp = xmin - 1
        xmax_exp = xmax + 1
        ymin_exp = ymin - 1
        ymax_exp = ymax + 1

        # 防止越界（基于原图坐标裁剪）
        xmin_exp = max(0, xmin_exp)
        ymin_exp = max(0, ymin_exp)
        xmax_exp = min(w - 1, xmax_exp)
        ymax_exp = min(h - 1, ymax_exp)

        # 映射到放大后的坐标
        x1 = xmin_exp * scale
        y1 = ymin_exp * scale
        x2 = xmax_exp * scale
        y2 = ymax_exp * scale

        cx = xc * scale
        cy = yc * scale

        # 再做一次安全裁剪
        x1 = max(0, min(W - 1, x1))
        y1 = max(0, min(H - 1, y1))
        x2 = max(0, min(W - 1, x2))
        y2 = max(0, min(H - 1, y2))
        cx = max(0, min(W - 1, cx))
        cy = max(0, min(H - 1, cy))

        # 画框
        cv2.rectangle(enlarged, (x1, y1), (x2, y2), rect_color, rect_thickness)

        # 画中心点
        cv2.circle(enlarged, (cx, cy), point_radius, center_color, -1)

        # 面积大于100时，在框内写面积
        if area > 100:
            text = str(area)
            (tw, th), baseline = cv2.getTextSize(text, font, font_scale, text_thickness)

            # 优先放左上角内侧
            tx = x1 + 2 * scale
            ty = y1 + th + 2 * scale

            # 如果文字太靠外，则修正
            tx = min(tx, max(x1, x2 - tw - 2 * scale))
            ty = min(ty, max(y1 + th, y2 - baseline - 2 * scale))

            # 为保证可读性，先画白底
            pad = 2
            bg_x1 = max(0, tx - pad)
            bg_y1 = max(0, ty - th - pad)
            bg_x2 = min(W - 1, tx + tw + pad)
            bg_y2 = min(H - 1, ty + baseline + pad)

            cv2.rectangle(enlarged, (bg_x1, bg_y1), (bg_x2, bg_y2), (255, 255, 255), -1)
            cv2.putText(
                enlarged,
                text,
                (tx, ty),
                font,
                font_scale,
                text_color,
                text_thickness,
                lineType=cv2.LINE_AA
            )

    ok = cv2.imwrite(output_path, enlarged)
    if not ok:
        raise IOError(f"结果图保存失败：{output_path}")

    print(f"标注完成，输出文件：{output_path}")


if __name__ == "__main__":
    # === 修改为你的实际路径 ===
    image_path = "received_image_bin_red.bmp"
    txt_path = "tb/CCATEST/output.txt"
    output_path = "output_annotated.png"

    annotate_image(
        image_path=image_path,
        txt_path=txt_path,
        output_path=output_path,
        scale=4
    )

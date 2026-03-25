import cv2
import numpy as np
from collections import deque


def load_binary_image(image_path, threshold=127):
    """
    从本地读取图片并转成二值图
    前景像素=1，背景像素=0
    """
    gray = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if gray is None:
        raise FileNotFoundError(f"无法读取图片: {image_path}")

    _, binary = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY)
    binary = (binary > 0).astype(np.uint8)
    return binary


def connected_components_8(binary):
    """
    8向连通域查找
    返回连通域列表，每个元素是:
    {
        'area': ...,
        'xmin': ...,
        'xmax': ...,
        'ymin': ...,
        'ymax': ...
    }
    """
    h, w = binary.shape
    visited = np.zeros((h, w), dtype=np.uint8)
    components = []

    # 8邻域方向
    directions = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1),           (0, 1),
        (1, -1),  (1, 0),  (1, 1)
    ]

    for y in range(h):
        for x in range(w):
            # 前景且未访问
            if binary[y, x] == 1 and visited[y, x] == 0:
                queue = deque()
                queue.append((x, y))
                visited[y, x] = 1

                area = 0
                xmin, xmax = x, x
                ymin, ymax = y, y

                while queue:
                    cx, cy = queue.popleft()
                    area += 1

                    if cx < xmin:
                        xmin = cx
                    if cx > xmax:
                        xmax = cx
                    if cy < ymin:
                        ymin = cy
                    if cy > ymax:
                        ymax = cy

                    for dx, dy in directions:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            if binary[ny, nx] == 1 and visited[ny, nx] == 0:
                                visited[ny, nx] = 1
                                queue.append((nx, ny))

                components.append({
                    "area": area,
                    "xmin": xmin,
                    "xmax": xmax,
                    "ymin": ymin,
                    "ymax": ymax
                })

    return components


def main():
    image_path = "received_image_bin_yellow.bmp"  # 改成你的本地图片路径

    binary = load_binary_image(image_path, threshold=127)
    components = connected_components_8(binary)

    # 过滤面积 < 100
    filtered_components = [comp for comp in components if comp["area"] >= 00]

    print(f"总连通域数量（过滤后 area >= 100）: {len(filtered_components)}")
    for i, comp in enumerate(filtered_components, 1):
        print(
            f"Component {i}: "
            f"area={comp['area']}, "
            f"xc={(comp['xmin'] + comp['xmax']) // 2}, "
            f"yc={(comp['ymin'] + comp['ymax']) // 2}, "
            f"xmin={comp['xmin']}, xmax={comp['xmax']}, "
            f"ymin={comp['ymin']}, ymax={comp['ymax']}"
            
        )


if __name__ == "__main__":
    main()
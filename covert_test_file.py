import cv2
import numpy as np

# 读取图片（注意：cv2.imread 默认以 BGR 顺序读取）
image = cv2.imread('received_image_bin_red.bmp')

# 获取图片尺寸
rows, cols, channels = image.shape

# 打开文件用于写入
with open('C:\\Users\\w2016\\Desktop\\test.txt', 'w') as fid:
    # 遍历每个像素
    for i in range(rows):
        for j in range(cols):
            # 如果任一通道的值大于 0，则认为该像素非黑色
            if image[i, j, 0] > 0 or image[i, j, 1] > 0 or image[i, j, 2] > 0:
                image[i, j] = [255, 255, 255]  # 将像素设置为白色
                fid.write("1 ")
            else:
                image[i, j] = [0, 0, 0]        # 保持黑色
                fid.write("0 ")

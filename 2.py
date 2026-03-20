from PIL import Image, ImageDraw
import os

# 创建文件夹
if not os.path.exists('installer_images'):
    os.makedirs('installer_images')

# 创建不同尺寸的图标
sizes = [16, 32, 48, 64, 128, 256]
images = []

for size in sizes:
    # 创建圆形图标（时间管理主题）
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 绘制圆形背景（蓝色）
    draw.ellipse([2, 2, size - 2, size - 2], fill=(46, 134, 171))

    # 添加时钟图标
    center = size // 2
    radius = size // 3

    # 时钟外圈
    draw.ellipse([center - radius, center - radius, center + radius, center + radius],
                 outline='white', width=2)

    # 时钟指针
    draw.line([center, center, center, center - radius + 5], fill='white', width=2)
    draw.line([center, center, center + radius - 5, center], fill='white', width=2)

    images.append(img)

# 保存为ICO文件（包含所有尺寸）
images[0].save('installer_images/app_icon.ico', format='ICO',
               append_images=images[1:], save_all=True)

print("✅ 图标文件创建完成: installer_images/app_icon.ico")
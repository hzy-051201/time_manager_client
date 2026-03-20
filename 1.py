from PIL import Image, ImageDraw

# 创建大背景图（164x314）
img_bg = Image.new('RGB', (164, 314), color='#2E86AB')
draw = ImageDraw.Draw(img_bg)

# 添加渐变效果
for i in range(314):
    r = int(46 + (i/314)*50)  # 蓝色渐变
    g = int(134 + (i/314)*50)
    b = int(171 + (i/314)*50)
    draw.line([(0, i), (164, i)], fill=(r, g, b))

# 添加文字或Logo
draw.text((20, 150), "时间管理", fill='white')
img_bg.save('installer_images/wizard_bg.bmp')

# 创建小图标（55x58）
img_small = Image.new('RGB', (55, 58), color='#2E86AB')
img_small.save('installer_images/wizard_small.bmp')
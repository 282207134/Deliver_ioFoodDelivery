"""Build visual indexes from the captured and exported pages."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

root = Path(__file__).resolve().parents[1]
for folder in ['screenshots', 'design-reference']:
    directory = root / 'docs' / folder
    images = sorted(directory.glob('[0-9]*.png'))
    board = Image.new('RGB', (1200, ((len(images) + 5) // 6) * 310), '#e7e8eb')
    draw = ImageDraw.Draw(board)
    for index, path in enumerate(images):
        x, y = (index % 6) * 200 + 8, (index // 6) * 310
        board.paste(ImageOps.contain(Image.open(path), (184, 278)), (x, y + 22))
        draw.text((x, y + 4), path.stem[:27], fill='#161616')
    board.save(directory / 'contact-sheet.jpg', quality=90)

names = ['10_home_screen', '33_restaurant_page', '34_product_detail_screen',
         '43_cart_a_lot_of_dishes', '45_payment_a_lot_of_dishes', '18_my_orders_tracker_screen']
labels = ['Home', 'Restaurant', 'Product', 'Cart', 'Checkout', 'Tracking']
board = Image.new('RGB', (1200, 1800), '#eceef0')
draw = ImageDraw.Draw(board)
for index, (name, label) in enumerate(zip(names, labels)):
    x, y = (index % 3) * 400 + 20, (index // 3) * 900
    image = Image.open(root / 'docs/screenshots' / (name + '.png'))
    board.paste(ImageOps.contain(image, (360, 820)), (x, y + 48))
    draw.text((x, y + 20), label, fill='#2a3037')
board.save(root / 'docs/screenshots/main-screens.jpg', quality=92)

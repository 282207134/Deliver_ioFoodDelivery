# Deliver.io · Flutter 外卖 App

根据 Pixso 文件 **Deliver.IO in BOX+** 开发。已读取 `Screens` 的 **51 个界面/状态**，以及 `Components` 的组件、字体和颜色规范；使用真实 Flutter 控件实现交互，照片、插画、地图和品牌素材均提取自设计稿。

## 交付内容

- [项目说明与结构架构](docs/PROJECT_GUIDE.md)
- [51 个页面的设计稿与 App 截图索引](docs/SCREEN_INDEX.md)
- [全部 App 截图总览](docs/screenshots/contact-sheet.jpg)
- [设计稿总览](docs/design-reference/contact-sheet.jpg)
- [Android 安装包](deliverables/DeliverIO-demo.apk)
- [验证记录](docs/VALIDATION.md)

## 主要界面

以下为 Android 模拟器实际运行截图。

| 首页 | 餐厅菜单 | 菜品详情 |
| --- | --- | --- |
| ![首页](docs/screenshots/10_home_screen.png) | ![餐厅菜单](docs/screenshots/33_restaurant_page.png) | ![菜品详情](docs/screenshots/34_product_detail_screen.png) |

| 购物车 | 结算 | 配送追踪 |
| --- | --- | --- |
| ![购物车](docs/screenshots/43_cart_a_lot_of_dishes.png) | ![结算](docs/screenshots/45_payment_a_lot_of_dishes.png) | ![配送追踪](docs/screenshots/18_my_orders_tracker_screen.png) |

## 快速体验

```sh
flutter pub get
flutter run -d emulator-5554
```

首次打开进入登录页。输入至少 7 位电话号码，演示验证码为 **1234**。完成引导或点击 Skip，便可浏览餐厅、搜索菜品、下单，并在 Cart → Active 中追踪订单。新安装没有历史订单和银行卡，可通过操作添加。

结算会明确显示 Demo payment，可模拟成功或失败。短信、第三方认证、支付、扫描识卡、定位和物流均未连接真实服务；资料、地址、银行卡尾号、购物车及订单保存于本机。

## 项目结构

```text
lib/
├── main.dart                # 初始化与恢复本地数据
├── app.dart                 # 应用入口与统一路由
├── core/
│   ├── theme.dart           # 色彩、字体、控件主题
│   └── widgets.dart         # 按钮、卡片、标签、表单等复用控件
├── data/
│   ├── catalog.dart         # 数据模型与演示目录
│   └── app_store.dart       # 业务状态、本地保存、购物车与订单规则
└── features/
    ├── auth/                # 登录、注册、验证码、引导
    ├── browse/              # 首页、餐厅、菜品、搜索
    ├── orders/              # 购物车、支付、订单、追踪、评价
    └── account/             # 资料、地址、银行卡、通知、邀请、FAQ

assets/                      # 本地设计素材与 Poppins 字体
android/ · ios/ · web/        # 平台工程
test/                        # 本地业务规则与存储测试
integration_test/            # Android 交互流程及设计状态巡检
test_driver/                 # Flutter 截图驱动
tool/capture_android.py      # 包含系统键盘的 Android 截图工具
docs/                        # 项目说明、参考图、实际截图、验证记录
deliverables/                # Android 演示安装包
```

运行依赖仅有 Flutter、Cupertino Icons 和 SharedPreferences；没有额外状态管理、路由或网络框架。

## 验证与构建

```sh
flutter analyze
flutter test
flutter drive -d emulator-5554 --driver test_driver/screenshots.dart --target integration_test/app_flow_test.dart
python tool/capture_android.py --device emulator-5554
flutter build apk --release
flutter build web --release
```

截图工具按设计稿顺序重建演示状态，保存到 `docs/screenshots/`。iOS 工程已提供，需在 macOS/Xcode 配置签名并验证。详细架构、功能范围和接入边界见 [项目说明](docs/PROJECT_GUIDE.md)。

# 验证与交付记录

日期：2026-10-28。

## 环境

| 项目 | 环境 |
| --- | --- |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| Android 设备 | emulator-5554，Android 15，API 35，x86_64 |
| 截图尺寸 | 1125 × 2436 像素，对应 375 × 812 逻辑尺寸 |
| 业务数据 | 本地模拟；截图测试使用隔离的演示状态 |
| 平台范围 | Android 运行验证；Web 编译验证；iOS 提供工程未编译 |

## 已完成检查

| 检查 | 结果与范围 |
| --- | --- |
| `flutter analyze` | 无问题；[日志](validation/analyze.log) |
| `flutter test` | 4 项通过：数量与金额、下单快照与再下单、资料/偏好/订单持久化、损坏数据恢复；[日志](validation/tests.log) |
| Android 页面巡检 | 51 个 Pixso 页面/状态通过异常检查并实际截图；[日志](validation/android-capture.log)。另外 3 个附加页面及购物车素材复核通过；[日志](validation/android-capture-43-52-53-54.log) |
| Android 流程测试 | 登录校验、错误/正确验证码、浏览加购结算成功、订单生成与页面布局；[日志](validation/android-flows.log) |
| Release APK | 构建完成，62.6 MiB，已输出至 `deliverables/DeliverIO-demo.apk` |
| APK 安装与启动 | 模拟器安装成功，冷启动返回 Status: ok，已进入登录界面；[启动截图](validation/release-launch.png) |
| Web release | 编译成功，Wasm dry run 成功；[日志](validation/web-build.log) |
| 文档与截图 | 51 个原稿索引、54 张 App 运行截图；主要界面图片嵌入 README 和项目说明，附加页面另列索引 |

Android UI 测试执行命令：

```sh
flutter drive -d emulator-5554 --driver test_driver/screenshots.dart --target integration_test/app_flow_test.dart
python tool/capture_android.py --device emulator-5554
```

本机 Windows `flutter_tester.exe` 在图像密集 UI 测试中出现过原生 `0xC0000005` 异常，因此 UI 流程和布局检查在 Android 模拟器执行；本地 `flutter test` 保留稳定的业务规则与存储测试。

## 截图检查

原稿读取范围为 Screens 51 个顶层节点，以及 Components 分类下的组件、字体、图标和颜色。已核对主界面的视觉层次、字体、源图片、输入状态、数量选择器、支付账单与配送地图。界面允许滚动，部分原稿弹层改为整页表单以适配系统键盘。

原生截图工具在 Flutter 画布刷新后捕获 Android 屏幕，避免捕获到上一页；系统状态栏时间与键盘样式由模拟器决定。截图使用本地演示数据，不能据此视为真实订单、支付或定位记录。

## 安装包

- 路径：`deliverables/DeliverIO-demo.apk`
- 包名：`com.deliverio.deliver_io`
- 版本：`1.0.0+1`
- SHA-256：`6AFB9DBF5C837D6BC008EB83F8C917A72995DE3BBE7FA8825298CE49714028C2`
- 使用调试签名进行 release 构建，仅用于演示安装。正式分发前需配置发布签名。

## 验证边界

没有连接短信、OAuth、支付、相机识卡、定位、地图服务、物流与推送后台。iOS 未在本机验证，Web 进行了编译检查，未将其作为移动端视觉验收平台。完整功能边界见 [项目说明](PROJECT_GUIDE.md)。



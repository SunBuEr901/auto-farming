# 硬件与连接关系

更新：2026-10-17｜设备证据：2026-10-11 历史记录；本次未连接设备。

来源：[历史测试](../reports/2026-10-11-static-tests.md)、[历史照片](../references/photos.md)及原使用说明中的用户确认记录；这些是历史依据，不是本次设备读回。

## 硬件与系统基线

| 项目 | 确认结果 | 依据 |
|---|---|---|
| 整车 | ROSMASTER X3 Plus，带机械臂 | 用户确认与现场照片 |
| 主机 | NVIDIA Jetson Orin Nano Engineering Reference Developer Kit Super | 设备树返回字符串 |
| 系统 | Ubuntu 22.04.5 LTS | SSH 实测 |
| 架构／内核 | aarch64；5.15.148-tegra | SSH 实测 |
| ROS | ROS 2 Humble，宿主机可直接使用 | SSH 实测 |
| 雷达 | YDLIDAR TG30；固件 2.1；硬件版本 1 | 驱动读回信息 |
| 雷达选择名称 | 原厂启动配置中的 `4ROS` | 现有代码与成功复测 |
| 相机 | Astra Plus 配置；Orbbec 彩色和深度 USB 设备 | 配置、USB 枚举与数据验证 |
| 底盘控制板 | 电机控制扩展板，USB 使用 CH340 | 用户照片、拔插对比 |
| 控制板精确版本 | 待确认；说明书示例为 YB-ERF01-V3.0 | 文档示例不可代替实物型号 |
| 底板固件 | 团队已为新开发刷写；版本、源码、协议待归档 | 用户最新确认 |
| 机械臂 | 已安装；型号细节、零位和通信未验证 | 用户确认 |

早期 `x3/a1` 是系统配置，不是硬件识别结果。A1 测试超时已由正确 YDLIDAR 驱动的成功测试解释，不再将它作为雷达故障证据。


## 连接关系与设备映射

```text
Windows 笔记本
  └─ 网络 → Jetson（SSH；RDP/VNC 服务已开启）
                ├─ USB HUB → YDLIDAR 转接板 Data → 彩色线 → 雷达
                ├─ USB HUB → Orbbec RGB / 深度相机
                └─ USB 数据线 → CH340 → 底盘控制板 → 四个电机
                                           └─ 机械臂（控制尚未验证）
```

黑色盒子上带 `Data/Power` 和 `TX/RX/5V/GND` 标识的模块，已由用户追线确认是雷达转接板。彩色排线连接 OLED 的部分也已单独辨认，均不能当成底盘通信线。

| 别名 | 当日目标 | 说明 |
|---|---|---|
| `/dev/ydlidar` | `/dev/ttyUSB0` | 雷达；CP2102，USB ID `10c4:ea60` |
| `/dev/rplidar` | `/dev/ttyUSB0` | 现有 udev 同时创建的别名；名称不代表实物是 RPLIDAR |
| `/dev/myserial` | `/dev/ttyUSB1` | 底盘；CH340，USB ID `1a86:7523` |

用户拔除底盘数据线时，`myserial`、`ttyUSB1` 和 CH340 同时消失，雷达保留；插回后恢复。故底盘 USB 对应关系已验证。`ttyUSB` 编号可能变化，应优先使用已经核对的设备别名。用户将底盘线称为 Type-B，说明书标为 Micro-USB 数据口，具体插头以实物为准。

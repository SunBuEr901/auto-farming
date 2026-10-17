# 短时数据录制与回放

更新：2026-10-17｜设备证据：2026-10-11 历史记录；本次未连接设备。

## 短时数据录制（待执行验证）

以下命令在 SSH 登录后的 Jetson Bash 执行，先按[软件环境](../environment/software.md#每个-ros-终端的环境准备)加载 Humble；驱动启动与停止见[传感器指南](sensors.md)。

首先检查可用空间：

```bash
df -h /home/jetson
```

2026-10-11 根分区使用率为 93%，仅约 12 GB 可用。先从 10 秒雷达录制开始；以下录制、回放命令是后续操作模板，尚未执行验收。

驱动已在其他终端启动后：

```bash
mkdir -p /home/jetson/farm_data
ros2 bag record -o /home/jetson/farm_data/scan_trial_01 /scan
```

约 10 秒后按 `Ctrl+C`，等记录器完成收尾，再检查：

```bash
ros2 bag info /home/jetson/farm_data/scan_trial_01
du -sh /home/jetson/farm_data/scan_trial_01
```

输出目录必须是新名字，下一次可改为 `scan_trial_02`。需要 RGB 和深度时，可新建一次短时录制：

```bash
ros2 bag record -o /home/jetson/farm_data/rgbd_trial_01 \
  /camera/color/image_raw /camera/color/camera_info \
  /camera/depth/image_raw /camera/depth/camera_info
```

未压缩 640×480、30 Hz 的 RGB 与深度图，原始像素载荷合计约 46 MB/s（十进制估算，不含消息与存储开销），10 秒约 460 MB。实际录制空间需实测；初次不录全话题或高体积点云。检查 `ros2 bag info` 中各话题消息数，零消息需核对驱动及 QoS。

回放前停止真实驱动，在独立终端使用不同域避免与实车实时数据混淆：

```bash
export ROS_DOMAIN_ID=78
ros2 bag play /home/jetson/farm_data/scan_trial_01
```

查看回放的其他终端也设为 78；域 78 是操作模板建议的离线隔离值，不是小车现有配置。使用回放前应确认该域无其他设备使用。本例只录传感器话题。

回放结束时在回放终端按 `Ctrl+C`，检查相关节点；退出隔离终端后重新按软件环境加载实车域，避免把域 78 沿用到下一次实车任务。以上结束步骤同样待执行验证。

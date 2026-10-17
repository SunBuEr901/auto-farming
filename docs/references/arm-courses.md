# 机械臂厂商课程索引

更新：2026-10-17。15 份 PDF 原件按两位课程编号和英文短名归档到机械臂模块；正文与 SHA-256 保持不变，旧名见链接文字及[迁移清单](../reports/2026-10-17-file-inventory.json)。本次提取全部页面文字用于分类和冲突检查，未逐页视觉校对截图或公式，也未执行课程命令。下载日期、具体版本和许可待确认。

| 编号 | 原标题与原件 | 页数 |
|---|---|---|
| 01 | [1、MoveIt配置](../../modules/arm/vendor/01-moveit-setup.pdf) | 15 |
| 02 | [2、MoveIt注意事项与控制真机](../../modules/arm/vendor/02-moveit-simulation-and-hardware.pdf) | 5 |
| 03 | [3、随机移动](../../modules/arm/vendor/03-random-motion.pdf) | 3 |
| 04 | [04、MoveIt运动学设计](../../modules/arm/vendor/04-moveit-kinematics.pdf) | 6 |
| 05 | [5、MoveIt笛卡尔路径](../../modules/arm/vendor/05-cartesian-path.pdf) | 3 |
| 06 | [6、MoveIt碰撞检测](../../modules/arm/vendor/06-collision-detection.pdf) | 4 |
| 07 | [7、MoveIt场景设计](../../modules/arm/vendor/07-planning-scene.pdf) | 4 |
| 08 | [8、MoveIt轨迹规划](../../modules/arm/vendor/08-trajectory-planning.pdf) | 3 |
| 09 | [9、Mediapipe手部控制](../../modules/arm/vendor/09-mediapipe-hand-control.pdf) | 3 |
| 10 | [10、Mediapipe手势控制机械臂动作组](../../modules/arm/vendor/10-mediapipe-arm-gestures.pdf) | 3 |
| 11 | [11、Mediapipe手势识别控制小车运动](../../modules/arm/vendor/11-mediapipe-chassis-gestures.pdf) | 2 |
| 12 | [12、Mediapipe手臂姿态控制机械臂](../../modules/arm/vendor/12-mediapipe-arm-pose.pdf) | 3 |
| 13 | [13、Mediapipe识别追踪手掌控制机械臂](../../modules/arm/vendor/13-mediapipe-palm-tracking.pdf) | 2 |
| 14 | [14、色块识别搬运](../../modules/arm/vendor/14-color-transport.pdf) | 4 |
| 15 | [15、自动驾驶清障](../../modules/arm/vendor/15-autopilot-obstacle-clearing.pdf) | 6 |

## 使用边界和原文疑点

- 第 1–8 课包含 ROS 1 / MoveIt 示例；第 9–15 课包含 ROS 1 `roslaunch` / `rosrun`、底盘或舵机相关示例，不能直接在宿主机 Humble 执行。项目已验证的教程入口见[操作指南](../guides/arm.md)。
- 第 1 课把 `sudo apt update` 放在“编译”的说明中，同一课末尾另给出 `catkin_make`。这是原文不一致；不将前者作为项目构建命令。实际工作空间构建仍需核对源码与环境。
- 第 7 课示例同时发布仿真关节话题和 `TargetAngle` 真机话题；“仿真示例”标题不能单独证明没有真机通路。现有教程容器没有设备映射且网络隔离，这个边界应保持明确。
- 第 9 课文件名为“手部控制”，正文标题是“手掌控制小车运动”；方向表两次写“画面下方”，对应后退与右移，存在歧义，需核对实际源码，不能猜改。
- 第 9、10 课正文提及的 launch 名称与所列命令不完全一致，具体入口待对照对应版本源码。
- 第 2 课包含真机操作和手动晃动机械臂的建议；第 9–15 课可能调用底盘或机械臂。原件不是本项目已验收的操作规程，关节值、速度、控制话题、按键与停止行为均不能直接照搬。
- 第 14 课以已有地图为前提，第 15 课描述巡线清障；它们不证明本项目已经具备导航、农田作业或真实避障能力。

课程内的其他课件路径与跳转属于厂商资料体系，仓库并不包含全部配套资料。95 个 PDF 页内链接目标已作结构检查，目标有效；103 个 `af:` 协议链接和 1 个 HTTP 链接的打开行为未验证；本仓库导航中的所有 PDF 路径纳入本地链接检查。

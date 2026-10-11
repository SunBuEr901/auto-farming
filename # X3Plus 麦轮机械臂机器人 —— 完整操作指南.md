# X3Plus 麦轮机械臂机器人 —— 完整操作指南

> 本指南涵盖从**开机**、**虚拟机配置**、**多机通讯**、**MoveIt 仿真**、**真机控制**到**数据回收**的全流程操作。
> 适用机型：亚博智能 X3Plus（麦克纳姆轮 + 5 自由度机械臂 + 夹爪）
> 适用环境：Ubuntu 18.04 (Melodic) / Ubuntu 20.04 (Noetic) + ROS + MoveIt

---

## 目录

- [1. 开机与硬件准备](#1-开机与硬件准备)
- [2. 虚拟机环境配置](#2-虚拟机环境配置)
- [3. 多机通讯配置（虚拟机 ↔ 机器人）](#3-多机通讯配置虚拟机--机器人)
- [4. MoveIt 仿真](#4-moveit-仿真)
- [5. 真机控制](#5-真机控制)
- [6. 夹爪控制](#6-夹爪控制)
- [7. 视觉交互（MediaPipe）](#7-视觉交互mediapipe)
- [8. 综合实战项目](#8-综合实战项目)
- [9. 数据回收与记录](#9-数据回收与记录)
- [10. 常见问题排查（FAQ）](#10-常见问题排查faq)
- [附录 A：核心命令速查表](#附录-a核心命令速查表)
- [附录 B：舵机与关节对照表](#附录-b舵机与关节对照表)

---

## 1. 开机与硬件准备

### 1.1 装备清单

| 部件 | 说明 |
|---|---|
| X3Plus 小车 | 麦轮底盘 + 5 自由度机械臂 + 夹爪 |
| 电池 | 建议满电开始，低电压会导致舵机抖动、行为异常 |
| SD 卡 / eMMC | 已预装机器人系统（树莓派系统或 JetPack） |
| WiFi 模块 | 用于虚拟机与机器人通讯 |
| 显示器 + 键鼠 | 可选，不接可全程 SSH 操作 |

### 1.2 开机流程

1. **检查电池电量**，装入电池并锁扣到位
2. **打开电源开关**（车身侧面），指示灯亮起
3. 等待约 40~60 秒，机器人主控开机完成（无屏幕时观察指示灯稳定常亮/闪烁）
4. 开机后机器人自动连接到**上次配置的 WiFi 热点**（首次使用需接显示器配置一次）

### 1.3 获取机器人 IP

- 有屏幕：桌面右上角网络图标查看 IP，或终端执行 `ifconfig`
- 无屏幕：路由器后台查看；或用 `nmap` 扫描：

```bash
# 虚拟机上扫描局域网（替换网段）
nmap -sn 192.168.1.0/24
```

### 1.4 SSH 连接机器人（首次必做）

```bash
# 在虚拟机终端执行（默认账号密码见官方说明，常见为 ubuntu/ubuntu）
ssh ubuntu@<机器人IP>
```

> 💡 建议配置免密登录，以后操作更顺畅：
> ```bash
> ssh-copy-id ubuntu@<机器人IP>
> ```

---

## 2. 虚拟机环境配置

### 2.1 虚拟机网络模式（关键！）

**必须使用「桥接模式」**，让虚拟机和机器人处于同一网段：

- VMware：虚拟机设置 → 网络适配器 → **桥接模式**（复制物理网络连接状态）
- VirtualBox：设置 → 网络 → 网卡 1 → **桥接网卡**

> NAT 模式下虚拟机与机器人不互通，后面多机通讯一定会失败。

### 2.2 验证 ROS 工作空间

虚拟机中已预装厂商提供的 `yahboomcar_ws` 工作空间，首次使用先编译一次：

```bash
cd ~/yahboomcar_ws
catkin_make
source devel/setup.bash
```

### 2.3 设置车型参数

编辑 `~/.bashrc`：

```bash
sudo vim ~/.bashrc
```

找到（或添加）`ROBOT_TYPE`，确保为 `X3plus`：

```bash
export ROBOT_TYPE=X3plus   # 可选值: X1 X3 X3plus R2 X7
```

使配置生效：

```bash
source ~/.bashrc
```

### 2.4 一劳永逸加载工作空间

```bash
echo "source ~/yahboomcar_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

### 2.5 验证

```bash
rosversion -d          # 应输出 melodic 或 noetic
echo $ROBOT_TYPE       # 应输出 X3plus
```

---

## 3. 多机通讯配置（虚拟机 ↔ 机器人）

真机控制的前提。核心思路：**ROS_MASTER_URI 指向主机，ROS_IP 写各自 IP**。

### 3.1 方案 A：以机器人为主机（推荐）

**机器人端**（SSH 进去后编辑 `~/.bashrc`，追加）：

```bash
export ROS_MASTER_URI=http://<机器人IP>:11311
export ROS_IP=<机器人IP>
```

**虚拟机端**（编辑 `~/.bashrc`，追加）：

```bash
export ROS_MASTER_URI=http://<机器人IP>:11311
export ROS_IP=<虚拟机IP>       # 用 ifconfig 查自己的 IP
```

### 3.2 方案 B：以虚拟机为主机

```bash
# 虚拟机端：
export ROS_MASTER_URI=http://<虚拟机IP>:11311
export ROS_IP=<虚拟机IP>

# 机器人端：
export ROS_MASTER_URI=http://<虚拟机IP>:11311
export ROS_IP=<机器人IP>
```

> ⚠️ 方案 B 需要在机器人端先启动 `roscore` 之外还要保证虚拟机端 `roscore` 常驻，虚拟机休眠会断开，故推荐方案 A。

### 3.3 两边同时生效并验证

```bash
# 双方各自执行
source ~/.bashrc

# 虚拟机上验证：能看到机器人端话题即成功
rostopic list | grep -i arm
rosservice list | head
```

> 💡 验证小技巧：机器人端发布一条测试消息，虚拟机端 `rostopic echo` 看能否收到。

---

## 4. MoveIt 仿真

> 仿真阶段**不连接真机**，先在 RViz 里把流程全部跑通，再上真机。

### 4.1 启动仿真

```bash
# 虚拟机终端 1
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=true
```

常用参数：

| 参数 | 说明 |
|---|---|
| `sim` | `true` 仿真 / `false` 真机 |
| `use_rviz` | 是否打开 RViz，默认 `true` |
| `use_gui` | 是否打开关节滑块 GUI，仅 `sim:=true` 时有效 |

**成功标志**：RViz 弹出，显示 X3Plus 完整模型，终端无红色报错。

### 4.2 RViz 手动操作（熟悉可达空间）

1. 用鼠标拖动机械臂末端的**彩色小球标记**设置目标位姿
2. **MotionPlanning → Planning** 选项卡：
   - `Plan`：仅规划（预览绿色轨迹）
   - `Execute`：执行规划
   - Goal State 可选 `random` / `home` 等预设
3. **Add → MarkerArray**（话题 `/rviz_visual_tools`）可查看轨迹线

### 4.3 仿真示例程序（由易到难）

每个命令在**新终端**执行（记得先 `source`）：

```bash
# ① 随机运动 —— 等效于界面里 Goal State=random
rosrun arm_moveit_demo 01_random_move.py      # Python 版
rosrun arm_moveit_demo 01_random_move         # C++ 版

# ② 反解：给定末端位姿（位置+姿态）求关节角并执行
rosrun arm_moveit_demo 02_set_pose_plan

# ③ 正解：给定 5 个关节角度，机械臂运动到位
rosrun arm_moveit_demo 03_set_joint_plan

# ④ 笛卡尔路径：末端走空间直线
rosrun arm_moveit_demo 04_cartesian

# ⑤ 碰撞检测：添加障碍物 + 随机运动（碰到障碍规划失败）
rosrun arm_moveit_demo 05_attached_object

# ⑥ 场景设计：夹爪开合、末端挂载工具、搭场景、导入导出
rosrun arm_moveit_demo 06_set_Scene.py

# ⑦ 多目标连续轨迹规划（三段轨迹合并为一条连续轨迹）
rosrun arm_moveit_demo 06_multi_track_motion
```

### 4.4 最小代码模板（写自己的控制程序）

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from moveit_commander.move_group import MoveGroupCommander
import rospy
from time import sleep

rospy.init_node("my_arm_ctrl")
arm = MoveGroupCommander("arm_group")

# 规划参数
arm.allow_replanning(True)              # 失败后允许重规划
arm.set_planning_time(5)                # 规划时间 (s)
arm.set_num_planning_attempts(10)       # 尝试次数
arm.set_goal_tolerance(0.01)            # 目标容差 (m)
arm.set_max_velocity_scaling_factor(0.3)     # 速度缩放（真机建议先 0.3）
arm.set_max_acceleration_scaling_factor(0.3)

# 方式 1：按关节角（正解），5 个关节值（弧度）
arm.set_joint_value_target([0, -0.69, -0.17, 0.86, 0])
arm.go(); sleep(1)

# 方式 2：按末端位姿（反解），[x, y, z, qx, qy, qz, qw]
arm.set_pose_target([0.2, 0.0, 0.3, 0, 0, 0, 1])
arm.go(); sleep(1)
```

> 📌 **反解要点**：5 自由度机械臂末端位姿不总是可达，规划失败时在 RViz 中查看 `arm_link5` 的 Position / Orientation，参考有效数值设置目标。

---

## 5. 真机控制

> ⚠️ **安全第一**：
> - 周围 1 米清空，最好将底盘架空
> - 速度缩放参数从 **0.3** 起步，验证正常后再逐步提高
> - 手边留好急停手段（电源开关）
> - 机械臂失控/抖动剧烈时**立即断电**

### 5.1 机器人端启动底层

```bash
# 机器人端（SSH 或本机）
roslaunch yahboomcar_bringup bringup.launch
```

### 5.2 虚拟机端启动 MoveIt（真机模式）

```bash
# 虚拟机端 —— 唯一区别是 sim:=false
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=false
```

启动后 RViz 中的模型会**实时反映真机关节状态**——这是联调成功的标志。

### 5.3 第一次真机动作（小幅度验证）

1. RViz 中 Goal State 选 `home` → **Plan** → 确认轨迹合理 → **Execute**
2. 真机同步运动，RViz 与真机一致 → 联调 OK
3. 再跑代码控制（盯紧真机！）：

```bash
rosrun arm_moveit_demo 01_random_move.py
```

### 5.4 真机速度建议

在任何控制程序中加入：

```python
arm.set_max_velocity_scaling_factor(0.3)
arm.set_max_acceleration_scaling_factor(0.3)
```

---

## 6. 夹爪控制

夹爪走 `TargetAngle` 话题（id=6），仿真与真机话题不同：

```python
# 真机夹爪控制
from yahboomcar_msgs.msg import ArmJoint   # 消息类型以实际功能包为准
import rospy

pub_Arm = rospy.Publisher("TargetAngle", ArmJoint, queue_size=1000)
arm_joint = ArmJoint()
arm_joint.id = 6
arm_joint.angle = 180 - 0.55 * 180 / 3.14159   # 夹爪开合角度
pub_Arm.publish(arm_joint)
```

```python
# 仿真夹爪（伪控制器话题）
from sensor_msgs.msg import JointState
pub_joint = rospy.Publisher("/move_group/fake_controller_joint_states",
                            JointState, queue_size=1000)
joint_state = JointState()
joint_state.name = ["grip_joint"]
joint_state.position = [-0.58]
```

---

## 7. 视觉交互（MediaPipe）

### 7.1 准备

- 建议**虚拟机连接 USB 摄像头**运行识别节点（主控算力有限会卡顿）
- 遥控手柄 **R2 键**为各功能的「暂停/开启」开关

```bash
# 机器人端启动基础
roslaunch arm_mediapipe mediaArm.launch
```

### 7.2 各功能启动（虚拟机端）

| 功能 | 命令 | 效果 |
|---|---|---|
| 手掌位置控底盘 | `rosrun arm_mediapipe RobotCtrl.py` | 手掌在画面上/下/左/右 → 小车前进/后退/左移/右移 |
| 手势控机械臂动作组 | `rosrun arm_mediapipe FingerCtrl.py` | 6 种手势：Yes=跳舞、OK=摇头、鄙视=跪下、1=点头、rock=伸直转动、5=鼓掌 |
| 手势控小车 | `rosrun arm_mediapipe HandCtrl.py` | 1=左移、2=右移、3=左旋、4=右旋、5=前进、拳=后退、rock=蜂鸣 |
| 手臂姿态同步 | `rosrun arm_mediapipe PoseArm.py` | 抬起右臂后机械臂模仿肩/肘/腕弯曲和手掌开合 |
| 手掌追踪 | `rosrun arm_mediapipe ArmCtrl.py` | 机械臂末端跟随手掌移动，拇指弯曲度控制夹爪 |

### 7.3 关键原理（便于二次开发）

- **MediaPipe Hands**：单帧推理 21 个手部 3D 关键点；`fingersUp()` 判断各手指是否伸直（1/0），`sum(fingers)` 统计伸直数量
- **MediaPipe Pose**：33 个人体姿态关键点，右手臂角度计算：
  - 肩关节：点 12-11-13；肘关节：11-13-15；腕关节：13-0-8；夹爪开合：4-0-8
- **手掌追踪映射**（`ArmCtrl.py`）：手部 bbox 中心 `indexX/indexY` 线性映射舵机角度，例如 `joint1 = -0.3 * indexX + 186`，参数需按相机视野和舵机行程标定

---

## 8. 综合实战项目

### 8.1 色块识别搬运（第 14 课）

前提：**已建好地图**，Astra 相机，首次使用先颜色标定。

```bash
# 机器人端
roslaunch arm_color_transport transport_base.launch map:=my_map img_show:=false
# 虚拟机端
roslaunch arm_color_transport transport_rviz.launch
```

RViz 操作：

| 工具 | 用途 |
|---|---|
| 左侧 `2D Pose Estimate` | 定位机器人初始位姿 |
| 右侧 `2D Pose Estimate` | 设置搬运完成后返回的位姿 |
| 右侧 `2D Nav Goal` | 设置各颜色（红绿蓝黄循环）的搬运目标点 |
| `Publish Point` | 清除已设目标 |

流程：空格（或 0.5s 内双击 R1）开始 → 色块填满识别框 → 识别颜色鸣笛 → 夹爪张开放入色块 → 自主导航搬运到对应颜色目标点。

### 8.2 自动驾驶清障（第 15 课）

巡线 + 机械臂清障 + 雷达避障。首次使用先做颜色标定。

```bash
# 机器人端
roslaunch arm_autopilot arm_autopilot.launch
# 虚拟机端 —— 动态调参
rosrun rqt_reconfigure rqt_reconfigure
```

主要参数（`LineDetect` 节点）：

| 参数 | 范围 | 说明 |
|---|---|---|
| `Hmin/Smin/Vmin/Hmax` | HSV | 巡线颜色阈值（核心） |
| `LaserAngle` | 10~90° | 雷达检测单侧角度 |
| `ResponseDist` | 0~8 m | 障碍物检测距离（默认 0.55） |
| `linear` | 0~1.0 | 巡线线速度（**太快看不到障碍物**） |
| `Kp/Ki/Kd`、`scale` | PID | 巡线 PID（默认 30/0/60，scale=1000） |

参数固化：写回 `arm_autopilot/scripts/autopilot_main.py` 的 `LineDetect` 类，以及 `cfg/autopilot.cfg` 中 `gen.add()` 的默认值。

---

## 9. 数据回收与记录

### 9.1 rosbag 录制（核心手段）

```bash
# 录制全部话题（数据量大，仅调试用）
rosbag record -a -O full_run.bag

# 录制指定话题（推荐）
rosbag record -O arm_run.bag \
  /joint_states \
  /move_group/display_planned_path \
  /TargetAngle \
  /cmd_vel \
  /scan

# 查看包信息
rosbag info arm_run.bag

# 回放（可配合仿真复现问题）
rosbag play arm_run.bag
```

> 💡 `rosbag play` + 仿真环境可以离线复现真机问题，是排错利器。

### 9.2 实时数据查看

```bash
rostopic echo /joint_states            # 关节状态（关节名+角度）
rostopic hz /joint_states               # 频率
rostopic list                          # 当前全部话题
rqt_graph                              # 节点关系图（截图存档）
```

图形化工具：

```bash
rqt_plot        # 实时曲线（如某关节角度随时间变化）
rqt_image_view  # 查看相机画面
rviz            # 可视化 /joint_states、/scan、轨迹等
```

### 9.3 相机图像与视频保存

```bash
# 方法 1：话题转图像序列
rosrun image_view extract_images image:=/Transport/rgb

# 方法 2：保存单帧
rostopic pub ... 或用 rqt_image_view 右键保存

# 方法 3：功能自带 —— web_video_server 浏览器看画面
# mediaArm.launch 已启动，浏览器访问：
# http://<机器人IP>:8080/stream_viewer?topic=/Transport/rgb
```

### 9.4 数据导出为 CSV（便于 MATLAB/Python 分析）

```python
# export_bag.py —— rosbag 转 CSV 示例
import rosbag
import csv

with rosbag.Bag('arm_run.bag') as bag:
    with open('joint_states.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['time', 'joint', 'position'])
        for topic, msg, t in bag.read_messages(topics=['/joint_states']):
            for name, pos in zip(msg.name, msg.position):
                writer.writerow([t.to_sec(), name, pos])
```

### 9.5 实验数据归档建议

```
data/
├── 2026-10-11_cartesian_test/
│   ├── arm_run.bag          # rosbag 原始数据
│   ├── joint_states.csv     # 导出的 CSV
│   ├── rqt_graph.png        # 节点图截图
│   └── notes.md             # 实验条件（速度参数、目标点、现象）
```

> 📌 养成习惯：**每次实验一个文件夹 + 一份 notes.md**，记录参数与现象，实验才可复现。

---

## 10. 常见问题排查（FAQ）

| 现象 | 原因 / 解决 |
|---|---|
| `roslaunch` 找不到包 | 未 `source ~/yahboomcar_ws/devel/setup.bash`；或工作空间未编译 |
| RViz 模型全白 | `ROBOT_TYPE` 未设置或设错 |
| 虚拟机 ping 不通机器人 | 虚拟机网络须为**桥接模式**；检查同一网段、关闭防火墙 |
| RViz 有模型但真机不动 | `sim:=` 忘改 `false`；多机通讯未通（检查 `ROS_MASTER_URI`/`ROS_IP`） |
| 反解规划失败 | 目标位姿不可达；调大 `set_planning_time`、开启 `allow_replanning` |
| 机械臂剧烈抖动/失控 | **立即断电**！低电量或参数越界 |
| 执行报错但规划成功 | `bringup.launch` 未运行；舵机未上电 |
| 舵机与关节对应错乱 | 对照附录 B；关节 1~6 从底座到夹爪 |
| MediaPipe 卡顿 | 改在虚拟机端接 USB 摄像头运行识别节点 |
| 巡线识别不到线 | 用 `rqt_reconfigure` 重标定 HSV；地面平整、光线均匀 |
| rosbag 录制掉帧 | 只录必要话题；换高速 SD 卡 / 本地 SSD |

---

## 附录 A：核心命令速查表

```bash
# ---------- 环境 ----------
source ~/yahboomcar_ws/devel/setup.bash
echo $ROBOT_TYPE                        # 应为 X3plus

# ---------- 仿真 ----------
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=true

# ---------- 真机 ----------
# 机器人端:  roslaunch yahboomcar_bringup bringup.launch
# 虚拟机端:  roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=false

# ---------- 示例节点 ----------
rosrun arm_moveit_demo 01_random_move.py     # 随机运动
rosrun arm_moveit_demo 02_set_pose_plan       # 反解
rosrun arm_moveit_demo 03_set_joint_plan     # 正解
rosrun arm_moveit_demo 04_cartesian           # 笛卡尔路径
rosrun arm_moveit_demo 05_attached_object     # 碰撞检测
rosrun arm_moveit_demo 06_set_Scene.py        # 场景设计
rosrun arm_moveit_demo 06_multi_track_motion  # 多段轨迹

# ---------- 视觉 ----------
roslaunch arm_mediapipe mediaArm.launch
rosrun arm_mediapipe RobotCtrl.py             # 手掌控车
rosrun arm_mediapipe FingerCtrl.py            # 手势动作组
rosrun arm_mediapipe HandCtrl.py              # 手势控车
rosrun arm_mediapipe PoseArm.py               # 手臂姿态同步
rosrun arm_mediapipe ArmCtrl.py               # 手掌追踪

# ---------- 调试 ----------
rqt_graph                    # 节点关系图
rostopic list / echo / hz     # 话题查看
rosrun rqt_reconfigure rqt_reconfigure   # 动态调参

# ---------- 数据 ----------
rosbag record -O x.bag /joint_states ...
rosbag play x.bag
rosbag info x.bag
```

## 附录 B：舵机与关节对照表

从机械臂**最低端（底座）至夹爪末端**依次编号：

| 舵机 | joint | 功能 |
|---|---|---|
| 1 | arm_joint1 | 底座旋转 |
| 2 | arm_joint2 | 大臂俯仰 |
| 3 | arm_joint3 | 小臂俯仰 |
| 4 | arm_joint4 | 腕部俯仰 |
| 5 | arm_joint5 | 腕部旋转 |
| 6 | grip_joint | 夹爪开合 |

---

## 参考

- [MoveIt 官方文档](http://docs.ros.org/en/melodic/api/moveit_tutorials/html/index.html)
- [MediaPipe 官方文档](https://mediapipe.dev/)
- 亚博智能 X3Plus 教程文档（第 1~15 课）

---

> 📄 本指南基于亚博智能 X3Plus 官方教程整理，实验前请阅读厂商安全须知。
> 上传 GitHub 时建议放在仓库根目录命名为 `README.md`，或作为 `docs/操作指南.md` 并在 README 中链接。

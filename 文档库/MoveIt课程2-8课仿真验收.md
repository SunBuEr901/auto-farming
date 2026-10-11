# MoveIt 课程 2~8 仿真验收

更新日期：2026-10-11。适用：容器 `farm-arm-noetic`（预装 Noetic 3.0.5）内 `/root/yahboomcar_ws`，对应课程《[2、MoveIt注意事项与控制真机](../机械臂文档/2、MoveIt注意事项与控制真机.pdf)》至《[8、MoveIt轨迹规划](../机械臂文档/8、MoveIt轨迹规划.pdf)》。第 1 课验收见[《MoveIt配置与仿真验证》](MoveIt配置与仿真验证.md)。

验收范围：**软件仿真**。第 2 课真机部分因容器隔离未执行（见第 3 节），本次未向真实硬件发送任何指令。

## 1. 结论总表

统一启动方式（无桌面 SSH 环境）：

```bash
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=true use_rviz:=false use_gui:=false
```

| 课 | 示例节点 | 结果 |
|---|---|---|
| 3 随机移动 | `01_random_move.py`、`01_random_move` | 两版本均通过；机械臂 5 关节角实测从全 0 / 上一位姿持续变化到随机位姿 |
| 4 运动学 | `02_set_pose_plan`（反解）、`03_set_joint_plan`（正解） | 均输出 `plan success`；正解末态关节角 ≈ {0, 0.78, -1.56, -1.57, 0}，与目标 {0, 0.79, -1.57, -1.57, 0} 一致 |
| 5 笛卡尔路径 | `04_cartesian` | `Path computed successfully. Moving the arm.`，直线路径规划并执行 |
| 6 碰撞检测 | `05_attached_object` | 添加 0.2×0.1×0.02 m 障碍物后 10 次随机规划：6 次成功、4 次 `ABORTED: TIMED_OUT`；目标触及障碍物时规划失败属本课预期现象 |
| 7 场景设计 | `06_set_Scene.py` | 需先应用 init→int 补丁（见 2.1）；补丁后添加支撑架 5 件与末端 tool 附着块，两目标间往返规划 5 次全部执行（step1/step2 × 5） |
| 8 轨迹规划 | `06_multi_track_motion` | 三个可达关节目标规划三段轨迹合并为一条连续轨迹执行，日志 `Finished` |
| 2 真机（仿真部分） | 同 3~8 的启动方式 | 仿真启动通过；`rqt_graph` 为 GUI 未截图；真机部分未执行（第 3 节） |

无 RViz 时 `moveit_visual_tools` 打印 `/rviz_visual_tools` 无法连接的 WARN 属预期；轨迹可视化需在小车桌面或远程桌面开 RViz 并添加 MarkerArray 显示。

## 2. 发现与修复

### 2.1 `06_set_Scene.py` 引用不存在的位姿名 `init`（已修复）

- 现象：`set_named_target("init")` 抛 `MoveItCommanderException: Unable to set target init`，脚本崩溃。
- 根因：SRDF 中位姿实际名为 `int`（第一课核对时已记录 PDF 写 `init`、SRDF 为 `int`）；厂商脚本按 PDF 文字写成 `init`。
- 修复：容器内将该行改为 `set_named_target("int")`。原版备份 `/root/farm_data/06_set_Scene.py.orig`，补丁版 `/root/farm_data/06_set_Scene.py.patched`。
- 容器重建后补丁会丢失，重新应用：

```bash
sed -i 's/set_named_target("init")/set_named_target("int")/' \
  /root/yahboomcar_ws/src/arm_moveit_demo/scripts/06_set_Scene.py
```

### 2.2 Python 版反解示例坐标损坏

容器内 `scripts/02_set_pose_plan.py` 的目标位姿 x≈111 m（PDF 中 C++ 版为 0.187 m，可达），Python 版规划必然失败。**反解练习请使用 C++ 版 `rosrun arm_moveit_demo 02_set_pose_plan`**；Python 版前半段 `set_named_target("down")` 仍可用。

### 2.3 无界面环境的 Python 输出缓冲

管道运行或 `timeout` 结束 Python 示例时，print 缓冲内容会丢失，易误判为无输出。复现时加 `PYTHONUNBUFFERED=1`。

## 3. 第 2 课真机控制：边界确认，未执行

- 2.2 仿真启动：通过（见总表）。
- 真机链路：`sim:=false` 时 demo 以 `required="true"` 启动 `SimulationToMachine.py`，把规划结果发布到 `TargetAngle`（`yahboomcar_msgs/ArmJoint`）；该话题由 `yahboomcar_bringup/bringup.launch` 启动的驱动节点消费并经串口控制舵机。
- 实测边界：教程容器创建脚本 `arm-noetic.sh` 使用 `--network none` 且未映射任何串口/USB 设备（容器内 `/dev` 无 ttyUSB/ttyACM），设计上即不能控制真机；原厂 `run_docker.sh` 依赖的 `/dev/camera_depth` 缺失（见《发现与变更记录》2026-10-11 首条）。
- 结论：真机验收需团队先做两项决策——创建映射串口的容器（并处理底盘自定义固件兼容性）或修复原厂脚本；且必须在人员现场条件下进行。PDF 2.3 的手柄控制表与 2.4.1 舵机读数异常处理依赖实体手柄与真机，均未验证。

## 4. 复现步骤

```bash
bash /home/jetson/farm-tools/arm-noetic.sh shell   # 进入容器
cd ~/yahboomcar_ws && catkin_make                  # 编译（已最新则秒过）
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=true use_rviz:=false use_gui:=false
# 第二个容器终端，逐课运行（每次一个节点，结束后再运行下一个）：
rosrun arm_moveit_demo 01_random_move              # 第3课 C++（py 版为 01_random_move.py）
rosrun arm_moveit_demo 02_set_pose_plan            # 第4课 反解（C++，勿用 py 版）
rosrun arm_moveit_demo 03_set_joint_plan           # 第4课 正解
rosrun arm_moveit_demo 04_cartesian                # 第5课 笛卡尔路径
rosrun arm_moveit_demo 05_attached_object          # 第6课 碰撞检测
PYTHONUNBUFFERED=1 rosrun arm_moveit_demo 06_set_Scene.py   # 第7课（先打 2.1 补丁）
rosrun arm_moveit_demo 06_multi_track_motion       # 第8课 多段轨迹合并
```

说明：第 3 课示例为无限循环，用 `timeout` 或 Ctrl+C 结束；其余节点执行完自动退出。桌面/远程桌面环境可去掉 `use_rviz:=false use_gui:=false` 用 RViz 观察。

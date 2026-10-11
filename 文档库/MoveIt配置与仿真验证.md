# MoveIt 配置与仿真验证

更新日期：2026-10-11。适用：容器 `farm-arm-noetic`（预装 Noetic 3.0.5）内 `/root/yahboomcar_ws` 的 `x3plus_moveit_config` 与 `arm_moveit_demo`。对应课程《[1、MoveIt配置.pdf](../机械臂文档/1、MoveIt配置.pdf)》。

验收范围：**软件仿真**。按项目约定，仿真启动成功不等于真实机械臂控制已通过；真机流程见《[2、MoveIt注意事项与控制真机.pdf](../机械臂文档/2、MoveIt注意事项与控制真机.pdf)》，尚未开始。

## 1. 结论

- 镜像预装的 `x3plus_moveit_config` 与第一课 PDF 各步骤逐项核对一致（见第 2 节），无需重新生成。
- 容器内 `catkin_make` 通过（工作空间全量最新，无重编项）。
- 无界面环境启动 `sim:=true` 成功：`move_group` 加载模型 `yahboomcar_X3plus`，规划、执行、运动学服务等能力全部就绪。
- 规划验证 6/6 通过（脚本 [verify_moveit_sim.py](../scripts/verify_moveit_sim.py)）：`arm_group` 预设位姿 down／int／up、随机目标（KDL 逆解 + OMPL 规划 + fake 执行），`grip_group` 预设位姿 open／close。
- 真实舵机通信与机械臂运动未验证。

## 2. PDF 步骤与预装配置包对照

| PDF 步骤 | 配置包中的证据 |
|---|---|
| 1.2.1 加载 URDF | `.setup_assistant` 记录 `yahboomcar_description/urdf/yahboomcar_X3plus.urdf`；启动日志 `Loading robot model 'yahboomcar_X3plus'` |
| 1.2.2 碰撞免检矩阵 | SRDF 内完整 `disable_collisions` 列表（Adjacent／Never／Default／Always 标注） |
| 1.2.3.1 机械臂规划组 | SRDF `arm_group` = `arm_joint1..arm_joint5`；`kinematics.yaml` 为 KDL，采样分辨率 0.005、超时 0.01 |
| 1.2.3.2 夹爪规划组 | SRDF `grip_group` = `rlink1..3`、`llink1..3` 六个连杆 |
| 1.2.4 预设位姿 | SRDF `group_state`：`up`（全 0）、`down`（joint2=-1.5708）、`int`（joint2=0.7854，joint3=joint4=-1.5708）、`close`（grip_joint=0）、`open`（grip_joint=-1.54）。注意 PDF 正文写 `init`，SRDF 实际名为 `int`，以 SRDF 为准 |
| 1.2.5 末端执行器 | SRDF `end_effector name="gripper" parent_link="arm_link5" parent_group="arm_group"` |
| 1.2.6 ROS 控制器 | `ros_controllers.yaml`：`arm_position_controller`，类型 `position_controllers/JointTrajectoryController`，关节 1..5 |
| 1.2.7 作者信息 | `.setup_assistant`：yahboom / yahboom@163.com（镜像内置，2023-09 生成） |
| 1.2.8 生成配置包 | 镜像已带成品包，本次核对成品；未重走 Setup Assistant 生成流程（练习时输出到 `/root/farm_data`，避免覆盖预装包） |
| 1.3 配置包详解 | `config/`（fake_controllers、joint_limits、kinematics、ompl_planning、srdf 等）与 `launch/`（demo、move_group、planning_context 等）齐全 |
| 1.4 配置验证 | `catkin_make` 通过；`sim:=true` 启动 + 规划 6/6（见第 3、4 节） |

`fake_controllers.yaml` 另定义 `fake_arm_group_controller`、`fake_grip_group_controller`（默认 interpolate 方式执行），初始位姿为 `up` + `close`。

## 3. 复现步骤（容器内）

前置：小车执行 `bash /home/jetson/farm-tools/arm-noetic.sh start`（或直接 `core` 启动 master）。

```bash
# 进入容器（脚本方式会自动 source ROS 与工作空间）
bash /home/jetson/farm-tools/arm-noetic.sh shell

cd ~/yahboomcar_ws && catkin_make          # 第一步：编译
roslaunch arm_moveit_demo x3plus_moveit_demo.launch sim:=true use_rviz:=false use_gui:=false
# 第二个容器终端：
python3 /root/farm_data/verify_moveit_sim.py
```

说明：

- `use_rviz:=false use_gui:=false` 是给 SSH 无界面环境用的；在小车桌面（`:0`）或远程桌面中运行时可去掉这两个参数，用 RViz 观察规划过程。
- 验证脚本从宿主机 `/home/jetson/farm-arm-data` 放入（对应容器 `/root/farm_data`），仓库副本在 [scripts/verify_moveit_sim.py](../scripts/verify_moveit_sim.py)。
- PDF 中验证路径写作 `~/yahboomcar_ws`（虚拟机场景），本机对应容器内 `/root/yahboomcar_ws`。

## 4. 实测记录（2026-10-11）

- `catkin_make`：无重编项，直接通过。
- 启动日志：`move_group` 加载 ApplyPlanningScene、CartesianPath、ExecuteTrajectory、Kinematics、MoveAction、PickPlace、PlanService、QueryPlanners、StateValidation 等全部能力；节点列表 `/move_group`、`/joint_state_publisher`、`/robot_state_publisher`、`/rosout`。
- 规划验证输出：`[PASS] arm_group 预设位姿 down / int / up`、`[PASS] arm_group 随机目标(KDL逆解+OMPL规划)`、`[PASS] grip_group 预设位姿 open / close`、`RESULT: 6/6 passed`。
- 结束后已停止本次启动的全部节点；容器保留。

## 5. 发现与未验证项

- 发现：`arm_moveit_demo/scripts/02_set_pose_plan.py` 中的位姿目标 x≈111 m，远超机械臂工作空间，属厂商示例数据问题；该脚本后半段规划失败是预期现象，不代表环境故障。其前半段 `set_named_target("down")` 可正常规划执行。
- 仿真验收，不含真实舵机/底盘控制；真机流程未开始。
- RViz 图形画面未验收（本次为无桌面会话的 SSH 环境）。
- Setup Assistant 从零重新生成的练习路径未走；预装成品包已满足当前需要。
- 验证依赖的 SRDF 位姿名为 `int`；若后续课程脚本引用 `init` 需注意此差异。
